#!/usr/bin/env bash
set -euo pipefail

M=bucket/MicaForEveryone.json
REPO=MicaForEveryone/MicaForEveryone

auth=()
if [ -n "${GH_API_TOKEN:-}" ]; then
  auth=(-H "Authorization: Bearer $GH_API_TOKEN")
fi

# "latest" is the newest stable release (pre-releases and drafts are skipped).
rel=$(curl -fsSL ${auth[@]+"${auth[@]}"} "https://api.github.com/repos/$REPO/releases/latest")
tag=$(jq -r .tag_name <<<"$rel")
ver=${tag#v}
cur=$(jq -r .version "$M")

# Up to date, or the manifest is already ahead: leave it alone.
if [ "$(printf '%s\n%s\n' "$cur" "$ver" | sort -V | tail -n1)" = "$cur" ]; then
  echo "up to date ($cur)"
  exit 0
fi

# Print "<url> <sha256>" for the ONE asset whose name matches the regex. Uses
# GitHub's recorded digest; otherwise downloads the file and hashes it.
asset_info() {
  local re=$1 line url hash tmp
  line=$(jq -r --arg re "$re" '
    [ .assets[] | select(.name | test($re; "i")) ]
    | if length == 1 then .[0] | "\(.browser_download_url) \(.digest // "none")" else empty end' <<<"$rel")
  [ -n "$line" ] || { echo "expected exactly one asset matching /$re/ in $tag" >&2; exit 1; }
  url=${line%% *}
  hash=${line##* }
  hash=${hash#sha256:}
  if ! [[ $hash =~ ^[0-9a-f]{64}$ ]]; then
    echo "no API digest for $url, downloading to hash it" >&2
    tmp=$(mktemp)
    curl -fsSL -o "$tmp" "$url"
    [ "$(head -c2 "$tmp")" = "PK" ] || { echo "$url is not an msix/zip package" >&2; rm -f "$tmp"; exit 1; }
    hash=$(sha256sum "$tmp" | cut -d' ' -f1)
    rm -f "$tmp"
  fi
  echo "$url $hash"
}

# The app bundle plus the Windows App Runtime framework package for each CPU.
bundle=$(asset_info '^bundle\.msixbundle$')
x64=$(asset_info '^(microsoft\.windowsappruntime|wasdk)[^/]*x64\.msix$')
x86=$(asset_info '^(microsoft\.windowsappruntime|wasdk)[^/]*x86\.msix$')
arm=$(asset_info '^(microsoft\.windowsappruntime|wasdk)[^/]*arm64\.msix$')

jq --indent 4 --arg v "$ver" \
   --arg bu "${bundle%% *}" --arg bh "${bundle##* }" \
   --arg xu "${x64%% *}" --arg xh "${x64##* }" \
   --arg iu "${x86%% *}" --arg ih "${x86##* }" \
   --arg au "${arm%% *}" --arg ah "${arm##* }" \
   '.version=$v
    | .architecture["64bit"].url=[$bu,$xu] | .architecture["64bit"].hash=[$bh,$xh]
    | .architecture["32bit"].url=[$bu,$iu] | .architecture["32bit"].hash=[$bh,$ih]
    | .architecture.arm64.url=[$bu,$au]    | .architecture.arm64.hash=[$bh,$ah]' \
   "$M" > "$M.tmp" && mv "$M.tmp" "$M"

echo "updated $cur -> $ver"
