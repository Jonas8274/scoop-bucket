#!/usr/bin/env bash
set -euo pipefail

M=bucket/mornye.json
REPO=mornyeapp/Mornye-Desktop

tag=$(curl -fsSL "https://api.github.com/repos/$REPO/releases/latest" | jq -r .tag_name)
ver=${tag#v}
cur=$(jq -r .version "$M")

if [ "$ver" = "$cur" ]; then
  echo "up to date ($cur)"
  exit 0
fi

base="https://github.com/$REPO/releases/download/$tag"
sums=$(curl -fsSL "$base/SHA256SUMS.txt")

hash_of() {
  echo "$sums" | awk -v f="$1" '{n=$2; sub(/^\*/,"",n); if (n==f) print $1}'
}

x64=$(hash_of "Mornye-$tag-windows-x64-portable.zip")
arm=$(hash_of "Mornye-$tag-windows-arm64-portable.zip")

if [ -z "$x64" ] || [ -z "$arm" ]; then
  echo "hash not found in SHA256SUMS.txt for $tag" >&2
  exit 1
fi

jq --indent 4 \
  --arg v "$ver" --arg x "$x64" --arg a "$arm" \
  --arg ux "$base/Mornye-$tag-windows-x64-portable.zip" \
  --arg ua "$base/Mornye-$tag-windows-arm64-portable.zip" \
  '.version=$v
   | .architecture["64bit"].url=$ux | .architecture["64bit"].hash=$x
   | .architecture.arm64.url=$ua   | .architecture.arm64.hash=$a' \
  "$M" > "$M.tmp" && mv "$M.tmp" "$M"

echo "updated $cur -> $ver"