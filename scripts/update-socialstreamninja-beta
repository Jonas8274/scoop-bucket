#!/usr/bin/env bash
set -euo pipefail

M=bucket/socialstreamninja-beta.json
REPO=steveseguin/social_stream
ASSET='^socialstreamninja-portable\.exe$'

auth=()
if [ -n "${GH_API_TOKEN:-}" ]; then
  auth=(-H "Authorization: Bearer $GH_API_TOKEN")
fi

# /releases/latest never returns pre-releases, so list releases and take the
# newest one that is flagged as a pre-release (the API returns newest first).
rel=$(curl -fsSL ${auth[@]+"${auth[@]}"} "https://api.github.com/repos/$REPO/releases?per_page=30" \
  | jq 'map(select(.prerelease == true and .draft == false)) | first')

if [ "$rel" = "null" ] || [ -z "$rel" ]; then
  echo "no pre-release found for $REPO" >&2
  exit 1
fi

tag=$(jq -r .tag_name <<<"$rel")
ver=${tag#v}
cur=$(jq -r .version "$M")

if [ "$ver" = "$cur" ]; then
  echo "up to date ($cur)"
  exit 0
fi

name=$(jq -r '.assets[].name' <<<"$rel" | grep -E "$ASSET" || true)
if [ "$(printf '%s\n' "$name" | grep -c .)" -ne 1 ]; then
  echo "expected exactly one asset matching /$ASSET/ in $tag, got:" >&2
  echo "$name" >&2
  exit 1
fi

url="https://github.com/$REPO/releases/download/$tag/$name"

# Prefer GitHub's recorded digest; otherwise download and hash the file.
hash=$(jq -r --arg n "$name" '.assets[] | select(.name==$n) | .digest // empty' <<<"$rel" | sed 's/^sha256://')
if ! [[ $hash =~ ^[0-9a-f]{64}$ ]]; then
  echo "no API digest for $name, downloading to hash it" >&2
  curl -fsSL -o /tmp/asset "$url"
  hash=$(sha256sum /tmp/asset | cut -d' ' -f1)
fi

jq --indent 4 --arg v "$ver" --arg u "$url" --arg h "$hash" \
   '.version=$v | .url=$u | .hash=$h' "$M" > "$M.tmp" && mv "$M.tmp" "$M"

echo "updated $cur -> $ver"