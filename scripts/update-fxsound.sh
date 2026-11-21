#!/usr/bin/env bash
set -euo pipefail

M=bucket/fxsound.json
REPO=fxsound2/fxsound-app

auth=()
if [ -n "${GH_API_TOKEN:-}" ]; then
  auth=(-H "Authorization: Bearer $GH_API_TOKEN")
fi

rels=$(curl -fsSL ${auth[@]+"${auth[@]}"} "https://api.github.com/repos/$REPO/releases?per_page=50")

# Highest versioned tag (vA.B.C.D) that is not a draft, pre-release or "Beta" title.
rel=$(jq -c '
  [ .[]
    | select(.draft == false and .prerelease == false)
    | select(.tag_name | test("^v[0-9]+(\\.[0-9]+){3}$"))
    | select((.name // "") | test("beta"; "i") | not) ]
  | sort_by(.tag_name | ltrimstr("v") | split(".") | map(tonumber))
  | last // empty' <<<"$rels")

[ -n "$rel" ] || { echo "no stable versioned release found" >&2; exit 1; }

tag=$(jq -r .tag_name <<<"$rel")
ver=${tag#v}
cur=$(jq -r .version "$M")

if [ "$ver" = "$cur" ]; then
  echo "up to date ($cur)"
  exit 0
fi

# Print "<url> <sha256>" for an exact asset name; use GitHub's digest if present,
# otherwise download the file and hash it.
asset_info() {
  local name=$1 url hash
  url=$(jq -r --arg n "$name" '.assets[] | select(.name==$n) | .browser_download_url' <<<"$rel")
  [ -n "$url" ] || { echo "asset $name not found in $tag" >&2; exit 1; }
  hash=$(jq -r --arg n "$name" '.assets[] | select(.name==$n) | .digest // empty' <<<"$rel" | sed 's/^sha256://')
  if ! [[ $hash =~ ^[0-9a-f]{64}$ ]]; then
    echo "no API digest for $name, downloading to hash it" >&2
    curl -fsSL -o "/tmp/$name" "$url"
    [ "$(head -c2 "/tmp/$name")" = "MZ" ] || { echo "$name is not an exe" >&2; exit 1; }
    hash=$(sha256sum "/tmp/$name" | cut -d' ' -f1)
  fi
  echo "$url $hash"
}

x64=$(asset_info fxsound_setup.exe)
arm=$(asset_info fxsound_setup.arm64.exe)

jq --indent 4 --arg v "$ver" \
   --arg xu "${x64%% *}" --arg xh "${x64##* }" \
   --arg au "${arm%% *}" --arg ah "${arm##* }" \
   '.version=$v
    | .architecture["64bit"].url=$xu | .architecture["64bit"].hash=$xh
    | .architecture.arm64.url=$au    | .architecture.arm64.hash=$ah' \
   "$M" > "$M.tmp" && mv "$M.tmp" "$M"

echo "updated $cur -> $ver"