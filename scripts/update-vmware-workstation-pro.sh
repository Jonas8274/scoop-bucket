#!/usr/bin/env bash
set -euo pipefail

M=bucket/vmware-workstation-pro.json
ITEM=vmwareworkstationarchive
META="https://archive.org/metadata/$ITEM/files"

files=$(curl -fsSL --retry 3 --connect-timeout 30 "$META")

# Newest Windows installer = highest build number among files like
# 26H1/VMware-Workstation-Full-26H1u1-25688693.exe (the old 17.x and older
# builds use a different name and are ignored).
latest=$(jq -c '
  [ (if type == "array" then . else (.result // .files) end)[]
    | select(.name | test("^[0-9]{2}H[0-9]/VMware-Workstation-Full-[0-9]{2}H[0-9](u[0-9]+)?-[0-9]+\\.exe$"))
    | . + { build: (.name | capture("-(?<b>[0-9]+)\\.exe$").b | tonumber),
            ver:   (.name | capture("Full-(?<v>[0-9]{2}H[0-9](u[0-9]+)?)-").v) } ]
  | sort_by(.build) | last // empty' <<<"$files")

[ -n "$latest" ] || { echo "no VMware Workstation installer found in $ITEM" >&2; exit 1; }

name=$(jq -r .name <<<"$latest")
ver=$(jq -r .ver <<<"$latest")
build=$(jq -r .build <<<"$latest")
size=$(jq -r .size <<<"$latest")
md5=$(jq -r .md5 <<<"$latest")

url="https://archive.org/download/$ITEM/$name#/setup.exe"
cur_url=$(jq -r .url "$M")

if [ "$url" = "$cur_url" ]; then
  echo "up to date ($(jq -r .version "$M"))"
  exit 0
fi

cur_build=$(sed -E 's/.*-([0-9]+)\.exe.*/\1/' <<<"$cur_url")
if [[ $cur_build =~ ^[0-9]+$ ]] && [ "$build" -le "$cur_build" ]; then
  echo "archive newest build ($build) is not newer than the manifest ($cur_build), leaving it alone"
  exit 0
fi

echo "new build $build ($ver), downloading to verify it"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
exe="$tmp/setup.exe"
curl -fSL --retry 3 --retry-delay 15 --connect-timeout 30 -o "$exe" "https://archive.org/download/$ITEM/$name"

# 1. It is a Windows executable of the size and md5 archive.org lists (transfer check).
[ "$(head -c2 "$exe")" = "MZ" ] || { echo "download is not an exe" >&2; exit 1; }
[ "$(stat -c%s "$exe")" = "$size" ] || { echo "size mismatch" >&2; exit 1; }
[ "$(md5sum "$exe" | cut -d' ' -f1)" = "$md5" ] || { echo "md5 mismatch" >&2; exit 1; }

# 2. It carries a valid digital signature from Broadcom (authenticity check).
#    archive.org is a third-party upload, so this is what protects the bucket.
if ! osslsigncode verify -in "$exe" \
     -CAfile /etc/ssl/certs/ca-certificates.crt \
     -TSA-CAfile /etc/ssl/certs/ca-certificates.crt >"$tmp/sig.txt" 2>&1; then
  cat "$tmp/sig.txt" >&2
  echo "signature verification failed, not updating" >&2
  exit 1
fi
grep -q 'Broadcom Inc' "$tmp/sig.txt" || { cat "$tmp/sig.txt" >&2; echo "installer is not signed by Broadcom Inc, not updating" >&2; exit 1; }

hash=$(sha256sum "$exe" | cut -d' ' -f1)

cur=$(jq -r .version "$M")
jq --indent 4 --arg v "$ver" --arg u "$url" --arg h "$hash" --arg b "$build" \
   '.version=$v
    | .description = "VMware Workstation Pro, build \($b) (downloaded from the vmwareworkstationarchive item on archive.org)"
    | .url=$u | .hash=$h' \
   "$M" > "$M.tmp" && mv "$M.tmp" "$M"

echo "updated $cur -> $ver (build $build)"
