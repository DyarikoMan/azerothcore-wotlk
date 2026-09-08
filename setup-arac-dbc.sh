#!/usr/bin/env bash
set -euo pipefail

VOLUME="azerothcore-wotlk_ac-client-data"
SRC="$(pwd)/modules/mod-arac/patch-contents/DBFilesContent"

if [ ! -d "$SRC" ]; then
    echo "[ERROR] ARAC DBC source not found."
    echo "Run ./setup-modules.sh first."
    exit 1
fi

echo "[ARAC] Installing server DBC files..."

docker run --rm \
  --mount "type=volume,source=$VOLUME,target=/data" \
  --mount "type=bind,source=$SRC,target=/src,readonly" \
  alpine sh -c '
    cp /src/CharBaseInfo.dbc /data/dbc/
    cp /src/CharStartOutfit.dbc /data/dbc/
    cp /src/SkillRaceClassInfo.dbc /data/dbc/
  '

echo "[OK] ARAC server DBC files installed."