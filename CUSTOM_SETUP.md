# AzerothCore Playerbot Setup

Custom Docker-based AzerothCore WotLK 3.3.5a server.

Installed modules: Playerbots, AHBot, Transmog, account-wide mounts, no Hearthstone cooldown, Flying Mounts Everywhere, and ARAC.

Windows setup: run setup-modules.ps1.
Ubuntu setup: run setup-modules.sh, restore the database backup, then run setup-arac-dbc.sh.

Do not commit .env, backups/, or ChromieCraft_3.3.5a/.
Never run docker compose down -v unless you intentionally want to delete Docker volumes.
