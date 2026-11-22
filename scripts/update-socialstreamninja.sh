#!/usr/bin/env bash
set -euo pipefail

M=bucket/socialstreamninja.json
REPO=steveseguin/social_stream
ASSET=socialstreamninja-portable.exe

auth=()
if [ -n "${GH_API_TOKEN:-}" ]; then
  auth=(-H "Authorization: Bearer $GH_API_TOKEN")
fi

rels=$(curl -fsSL ${auth[@]+"${auth[@]}"} "https://api.github.com/repos/$REPO/releases?per_page=50")

# Highest versioned tag (vA.B.C) among ALL non-draft releases, pre-releases and
# test builds included, that already has the portable exe uploaded.
rel=$(jq -c --arg a "$ASSET" '
  [ .[]
    | select(.draft == false)
    | select(.tag_name | test("^v[0-9]+(\\.[0-9]+)+$"))
    | select(any(.assets[]; .name == $a)) ]
  | sort_by(.tag_name | ltrimstr("v") | split(".") | map(tonumber))
  | last // empty' <<<"$rels")

[ -n "$rel" ] || { echo "no release with $ASSET found" >&2; exit 1; }

tag=$(jq -r .tag_name <<<"$rel")
ver=${tag#v}
cur=$(jq -r .version "$M")

# Up to date, or the manifest is already ahead (for example a pre-release was
# deleted): leave it alone so it never goes backwards.
if [ "$(printf '%s\n%s\n' "$cur" "$ver" | sort -V | tail -n1)" = "$cur" ]; then
  echo "up to date ($cur)"
  exit 0
fi

url="https://github.com/$REPO/releases/download/$tag/$ASSET"

# Prefer GitHub's recorded digest; otherwise download and hash the file.
hash=$(jq -r --arg n "$ASSET" '.assets[] | select(.name==$n) | .digest // empty' <<<"$rel" | sed 's/^sha256://')
if ! [[ $hash =~ ^[0-9a-f]{64}$ ]]; then
  echo "no API digest for $ASSET, downloading to hash it" >&2
  curl -fsSL -o /tmp/asset "$url"
  [ "$(head -c2 /tmp/asset)" = "MZ" ] || { echo "$ASSET is not an exe" >&2; exit 1; }
  hash=$(sha256sum /tmp/asset | cut -d' ' -f1)
fi

jq --indent 4 --arg v "$ver" --arg u "$url" --arg h "$hash" \
   '.version=$v | .url=$u | .hash=$h' "$M" > "$M.tmp" && mv "$M.tmp" "$M"

echo "updated $cur -> $ver ($(jq -r .prerelease <<<"$rel" | sed 's/true/pre-release/; s/false/stable/'))"
