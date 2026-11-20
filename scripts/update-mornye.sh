#!/usr/bin/env bash
set -euo pipefail

M=bucket/mornye.json
REPO=mornyeapp/Mornye-Desktop

# Optional GitHub token (read-only, public repos) to lift the 60 requests/hour
# unauthenticated limit. Named GH_API_TOKEN on purpose: CI systems often set
# GITHUB_TOKEN to their own token, which api.github.com would reject.
auth=()
if [ -n "${GH_API_TOKEN:-}" ]; then
  auth=(-H "Authorization: Bearer $GH_API_TOKEN")
fi

rel=$(curl -fsSL ${auth[@]+"${auth[@]}"} "https://api.github.com/repos/$REPO/releases/latest")
tag=$(jq -r .tag_name <<<"$rel")
ver=${tag#v}
cur=$(jq -r .version "$M")

if [ "$ver" = "$cur" ]; then
  echo "up to date ($cur)"
  exit 0
fi

base="https://github.com/$REPO/releases/download/$tag"

# Primary source: SHA256SUMS.txt, normalised to "<hash> <filename>" lines.
# A missing file is not fatal; we fall back to the API digests below.
sums=$(curl -fsSL "$base/SHA256SUMS.txt" | tr -d '\r' \
  | awk '{n=$2; sub(/^\*/,"",n); print $1, n}') || sums=""

# Fallback source: the SHA-256 digest GitHub records for each release asset,
# taken from the release JSON we already fetched (no extra API call).
api_sums=$(jq -r '.assets[] | select(.digest != null)
  | "\(.digest | sub("^sha256:"; "")) \(.name)"' <<<"$rel")

pick() { printf '%s\n' "$2" | grep -E "$1" || true; }

# Print "<hash> <filename>" for the one file matching the pattern, else fail.
# Tries SHA256SUMS.txt first and only falls back if it has no match at all.
find_asset() {
  local pat=$1 m
  m=$(pick "$pat" "$sums")
  if [ -z "$m" ]; then
    echo "no /$pat/ in SHA256SUMS.txt for $tag, trying GitHub API digests" >&2
    m=$(pick "$pat" "$api_sums")
  fi
  if [ "$(printf '%s\n' "$m" | grep -c .)" -ne 1 ]; then
    echo "expected exactly one match for /$pat/ for $tag, got:" >&2
    echo "$m" >&2
    exit 1
  fi
  if ! [[ ${m%% *} =~ ^[0-9a-fA-F]{64}$ ]]; then
    echo "not a valid SHA-256 for /$pat/: $m" >&2
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