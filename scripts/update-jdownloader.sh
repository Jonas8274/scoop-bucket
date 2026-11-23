#!/usr/bin/env bash
set -euo pipefail

M=bucket/jdownloader.json
URL=https://installer.jdownloader.org/JDownloader.jar

# Download the official bootstrap JAR and hash it.
curl -fsSL -o /tmp/JDownloader.jar "$URL"
[ "$(head -c2 /tmp/JDownloader.jar)" = "PK" ] || { echo "download is not a jar" >&2; exit 1; }
hash=$(sha256sum /tmp/JDownloader.jar | cut -d' ' -f1)
cur_hash=$(jq -r .hash "$M")

if [ "$hash" = "$cur_hash" ]; then
  echo "up to date ($hash)"
  exit 0
fi

# Version = date and time the file was last modified (falls back to now).
lm=$(curl -fsSI "$URL" | tr -d '\r' | grep -i '^last-modified:' | head -1 | cut -d' ' -f2- || true)
ver=$(date -u -d "${lm:-now}" +%Y.%m.%d.%H%M 2>/dev/null || date -u +%Y.%m.%d.%H%M)
cur=$(jq -r .version "$M")

jq --indent 4 --arg v "$ver" --arg h "$hash" '.version=$v | .hash=$h' \
   "$M" > "$M.tmp" && mv "$M.tmp" "$M"

echo "updated $cur -> $ver"
