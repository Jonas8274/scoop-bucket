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
sums=$(curl -fsSL "$base/SHA256SUMS.txt" | tr -d '\r')

# Print "<hash> <filename>" for the one file matching the pattern, else fail.
find_asset() {
  local m
  m=$(echo "$sums" | awk '{n=$2; sub(/^\*/,"",n); print $1, n}' | grep -E "$1" || true)
  if [ "$(echo "$m" | grep -c .)" -ne 1 ]; then
    echo "expected exactly one match for /$1/ in SHA256SUMS.txt for $tag, got:" >&2
    echo "$m" >&2
    exit 1
  fi
  echo "$m"
}

x64=$(find_asset 'windows-x64-portable.*\.zip$')
arm=$(find_asset 'windows-arm64-portable.*\.zip$')
x64_hash=${x64%% *};  x64_name=${x64#* }
arm_hash=${arm%% *};  arm_name=${arm#* }

jq --indent 4 \
  --arg v "$ver" \
  --arg xh "$x64_hash" --arg xu "$base/$x64_name" \
  --arg ah "$arm_hash" --arg au "$base/$arm_name" \
  '.version=$v
   | .architecture["64bit"].url=$xu | .architecture["64bit"].hash=$xh
   | .architecture.arm64.url=$au   | .architecture.arm64.hash=$ah' \
  "$M" > "$M.tmp" && mv "$M.tmp" "$M"

echo "updated $cur -> $ver"