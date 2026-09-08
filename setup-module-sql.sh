#!/usr/bin/env bash
set -euo pipefail

if [ ! -f ".env" ]; then
    echo "[ERROR] .env not found"
    exit 1
fi

DB_PASSWORD="$(grep '^DOCKER_DB_ROOT_PASSWORD=' .env | cut -d= -f2-)"

if [ -z "$DB_PASSWORD" ]; then
    echo "[ERROR] DOCKER_DB_ROOT_PASSWORD is missing from .env"
    exit 1
fi

import_sql() {
    database="$1"
    file="$2"

    if [ ! -f "$file" ]; then
        echo "[ERROR] Missing: $file"
        exit 1
    fi

    echo "[SQL] $database <- $file"
    docker exec -i ac-database \
        mysql -uroot "-p${DB_PASSWORD}" "$database" < "$file"
}

echo "Installing module database files..."

# AHBot
import_sql acore_world "modules/mod-ah-bot/data/sql/db-world/mod_auctionhousebot.sql"
import_sql acore_world "modules/mod-ah-bot/data/sql/db-world/auctionhousebot_professionItems.sql"
import_sql acore_world "modules/mod-ah-bot/data/sql/db-world/z_filter_disabled_and_trash.sql"

# Account-wide mounts
import_sql acore_auth "modules/mod-mounts-on-account/data/sql/db-auth/base/mod_mounts_on_account.sql"
import_sql acore_world "modules/mod-mounts-on-account/data/sql/db-world/base/moa_acore_string.sql"

# ARAC
import_sql acore_world "modules/mod-arac/data/sql/db-world/arac.sql"

# Transmog
import_sql acore_auth "modules/mod-transmog/data/sql/db-auth/acore_cms_subscriptions.sql"
import_sql acore_characters "modules/mod-transmog/data/sql/db-characters/trasmorg.sql"

import_sql acore_world "modules/mod-transmog/data/sql/db-world/trasm_world_NPC.sql"
import_sql acore_world "modules/mod-transmog/data/sql/db-world/trasm_world_VendorItems.sql"
import_sql acore_world "modules/mod-transmog/data/sql/db-world/trasm_world_texts.sql"

echo
echo "[OK] Module SQL installation complete."