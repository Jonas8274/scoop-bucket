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
tag=$(jq -r '
  [ .[]
    | select(.draft == false and .prerelease == false)
    | select(.tag_name | test("^v[0-9]+(\\.[0-9]+){3}$"))
    | select((.name // "") | test("beta"; "i") | not)
    | .tag_name ]
  | sort_by(ltrimstr("v") | split(".") | map(tonumber))
  | last // empty' <<<"$rels")

[ -n "$tag" ] || { echo "no stable versioned release found" >&2; exit 1; }

ver=${tag#v}
cur=$(jq -r .version "$M")

if [ "$ver" = "$cur" ]; then
  echo "up to date ($cur)"
  exit 0
fi

url="https://raw.githubusercontent.com/$REPO/$tag/release/fxsound_setup.exe"
curl -fsSL -o /tmp/fxsound_setup.exe "$url"
[ "$(head -c2 /tmp/fxsound_setup.exe)" = "MZ" ] || { echo "download is not an exe" >&2; exit 1; }
hash=$(sha256sum /tmp/fxsound_setup.exe | cut -d' ' -f1)

jq --indent 4 --arg v "$ver" --arg u "$url" --arg h "$hash" \
   '.version=$v | .architecture["64bit"].url=$u | .architecture["64bit"].hash=$h' \
   "$M" > "$M.tmp" && mv "$M.tmp" "$M"

echo "updated $cur -> $ver"