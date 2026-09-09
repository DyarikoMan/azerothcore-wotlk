# AzerothCore Playerbot Server Cheat Sheet

Personal Docker-based AzerothCore WotLK 3.3.5a setup with Playerbots and quality-of-life modules.

> Important: never commit `.env`, `backups/`, or `ChromieCraft_3.3.5a/`.
> Never run `docker compose down -v` unless you intentionally want to delete Docker volumes and database data.

## 1. Current server

- Host OS: Ubuntu 24.04 LTS
- Server LAN IP: `192.168.11.111`
- Repository: `~/azerothcore-wotlk`
- Core branch: `Playerbot`
- Docker Compose project: `azerothcore-wotlk`
- WoW client: WotLK 3.3.5a build 12340

Main services:

- `ac-database` - MySQL 8.4
- `ac-db-import` - one-shot database updater
- `ac-client-data-init` - one-shot map/DBC data initializer
- `ac-authserver` - WoW login/authentication server
- `ac-worldserver` - world/game server

`ac-db-import` and `ac-client-data-init` normally show `Exited (0)` after completing. That is expected.

## 2. Daily commands

Start the server:

```bash
cd ~/azerothcore-wotlk
docker compose up -d ac-authserver ac-worldserver
```

Stop the server without deleting anything:

```bash
cd ~/azerothcore-wotlk
docker compose stop
```

Check status:

```bash
docker compose ps
```

Worldserver logs:

```bash
docker compose logs --tail=200 ac-worldserver
```

Follow live worldserver logs:

```bash
docker compose logs -f ac-worldserver
```

Quick module/error check:

```bash
docker compose logs --tail=200 ac-worldserver | grep -Ei "playerbot|ahbot|transmog|moa|error|fatal"
```

Resource usage:

```bash
docker stats
```

## 3. Network ports and security

Current intended bindings:

- `3724/tcp` - authserver, reachable from LAN/client
- `8085/tcp` - worldserver, reachable from LAN/client
- `3306/tcp` - MySQL, localhost only
- `7878/tcp` - SOAP/admin, localhost only

`.env` contains:

```text
DOCKER_DB_EXTERNAL_PORT=127.0.0.1:3306
DOCKER_SOAP_EXTERNAL_PORT=127.0.0.1:7878
```

Expected `docker compose ps` bindings:

```text
127.0.0.1:3306->3306/tcp
127.0.0.1:7878->7878/tcp
0.0.0.0:3724->3724/tcp
0.0.0.0:8085->8085/tcp
```

Do not expose MySQL `3306` or SOAP `7878` through the router.

## 4. WoW client connection

Windows client realmlist file:

```text
ChromieCraft_3.3.5a\Data\enUS\realmlist.wtf
```

LAN configuration:

```text
set realmlist 192.168.11.111
```

The auth database realm should match the server address:

```sql
SELECT id,name,address,localAddress,localSubnetMask,port
FROM acore_auth.realmlist;
```

Current LAN values:

```text
address      = 192.168.11.111
localAddress = 192.168.11.111
port         = 8085
```

## 5. Installed server modules

### Playerbots

Repository: `mod-playerbots/mod-playerbots`

Configured random bot population:

```text
minimum: 150
maximum: 200
```

Observed in-game population is around 190-200 bots.

Useful worldserver command:

```text
playerbot rndbot stats
```

UnBot client addon is installed for easier bot control.

### AHBot

Auction House Bot is installed and active.

AHBot NPC/account data is already in the migrated database. Worldserver logs should periodically show:

```text
AHBot [702]: Begin Performing Update Cycle
```

Do not manually re-import AHBot SQL on an already configured database.

### ARAC - All Races All Classes

Installed and verified.

Examples confirmed working:

- Human Shaman
- Human Druid

ARAC requires all three parts:

1. World database SQL
2. Modified server DBC files
3. Client `Data/Patch-A.MPQ`

Server DBC installer:

```bash
./setup-arac-dbc.sh
```

Important: after rebuilding/re-running client data initialization, run `./setup-arac-dbc.sh` again and restart the worldserver so the ARAC DBC files are definitely present.

### Transmog

Installed and verified.

Transmogrifier NPC entry:

```text
190010
```

GM test command:

```text
.npc add 190010
```

The Warpweaver menu supports armor slots, weapons, saved sets, removing transmogs, and updating the menu.

### Account-wide mounts

Installed and verified.

Mounts are stored in:

```text
acore_auth.mod_mounts_on_account
```

A mount learned on one character becomes available to eligible characters on the same account once they have the required Riding skill.

Current config includes:

```text
moa.enable = true
moa.enable.learn = true
moa.enable.learn.on.login = true
moa.enable.account.cache = true
moa.skip.bots.on.login = true
```

### No Hearthstone Cooldown

Installed and verified.

The Hearthstone can be used again immediately after teleporting.

### Flying Mounts Everywhere

Installed and compiled with a local compatibility patch for the Playerbot core.

Config:

```text
Enabled = 1
BlockInBattlegrounds = 1
BlockInInstances = 1
MinLevel = 20
Debug = 0
AllowedMountSpells =
```

Empty `AllowedMountSpells` means all flying mounts are allowed.

Gameplay verification is still optional/not completed.

Compatibility patch stored in:

```text
patches/flying-playerbot.patch
```

## 6. Module setup scripts

Windows:

```powershell
.\setup-modules.ps1
```

Ubuntu:

```bash
./setup-modules.sh
```

Fresh database only:

```bash
./setup-module-sql.sh
```

Do NOT run `setup-module-sql.sh` after restoring the current full AzerothCore database backup. The module SQL is already present in the restored databases.

ARAC DBC install:

```bash
./setup-arac-dbc.sh
```

## 7. Client-side extras

These are intentionally not stored in GitHub because the WoW client directory is ignored.

Installed/used:

- RCE-patched WoW executable via RCEPatcher2
- UnBot addon
- WDM map patch
- `WDM` addon
- `!Astrolabe` addon
- VoiceOver addon
- VoiceOver Vanilla sound data
- ARAC `Data/Patch-A.MPQ`

Status to remember:

- TipTac: installed/likely present, but not positively re-verified
- Camera/mouse jerk fix: separate from the RCE patch and not installed/verified

Do not overwrite the RCE-patched executable casually.

## 8. Backups

Automatic backup script:

```text
~/azerothcore-wotlk/backup-db.sh
```

Automatic backup directory:

```text
~/azerothcore-wotlk/backups/auto/
```

The script dumps these databases:

- `acore_auth`
- `acore_characters`
- `acore_world`
- `acore_playerbots`

Manual backup:

```bash
cd ~/azerothcore-wotlk
./backup-db.sh
```

Backups are compressed as:

```text
azerothcore-YYYY-MM-DD_HH-MM-SS.sql.gz
```

Current cron job:

```cron
15 4 * * * /home/bou33ou/azerothcore-wotlk/backup-db.sh >> /home/bou33ou/azerothcore-wotlk/backups/auto/backup.log 2>&1
```

This runs every day at `04:15` in the Ubuntu server's timezone.

The backup script deletes automatic backup files older than about 7 days.

Check backup log:

```bash
tail -n 20 ~/azerothcore-wotlk/backups/auto/backup.log
```

List backups:

```bash
ls -lh ~/azerothcore-wotlk/backups/auto/
```

### Restore basics

Stop game services first:

```bash
cd ~/azerothcore-wotlk
docker compose stop ac-authserver ac-worldserver
```

Load the DB password without printing it:

```bash
DBPASS=$(grep '^DOCKER_DB_ROOT_PASSWORD=' .env | cut -d= -f2-)
```

Restore a compressed backup:

```bash
gunzip -c backups/auto/azerothcore-YYYY-MM-DD_HH-MM-SS.sql.gz \
  | docker exec -i ac-database mysql -uroot "-p$DBPASS"
```

Then run the DB updater and start the game services:

```bash
docker compose up ac-db-import
docker compose up -d ac-authserver ac-worldserver
```

After any client-data initialization/rebuild, re-run:

```bash
./setup-arac-dbc.sh
docker compose restart ac-worldserver
```

## 9. Rebuild/update workflow

A rebuild can heavily use the CPU and make the server fans loud. That is normal during C++ compilation and is much heavier than normal gameplay.

Typical workflow:

```bash
cd ~/azerothcore-wotlk
git pull
./setup-modules.sh
docker compose up -d --build
./setup-arac-dbc.sh
docker compose restart ac-worldserver
```

Then check:

```bash
docker compose ps
docker compose logs --tail=100 ac-worldserver
```

If `ac-db-import` exits with code `1`, inspect its logs before changing SQL:

```bash
docker compose logs --tail=200 ac-db-import
```

Do not delete tables simply because an updater reports that a table already exists.

## 10. Git/repository rules

Fork:

```text
DyarikoMan/azerothcore-wotlk
```

Branch:

```text
Playerbot
```

Custom tracked files include:

- `CUSTOM_SETUP.md`
- `docker-compose.override.yml`
- module configs under `env/dist/etc/modules/`
- `patches/flying-playerbot.patch`
- `setup-modules.ps1`
- `setup-modules.sh`
- `setup-module-sql.sh`
- `setup-arac-dbc.sh`

Intentionally ignored/private/local:

- `.env`
- `backups/`
- `ChromieCraft_3.3.5a/`
- cloned module repositories under `modules/*`

The setup scripts recreate the module repositories when needed.

## 11. Things never to do casually

Do not run:

```bash
docker compose down -v
```

`-v` deletes Docker volumes and can erase the MySQL database volume.

Also avoid:

- exposing port `3306` publicly
- exposing SOAP `7878` publicly
- committing `.env`
- committing database backups
- committing the WoW client
- manually importing module SQL into an already configured/updating DB unless you know exactly why

## 12. Remote play - TODO

LAN play is working now.

Goal for later: play from outside home without requiring Tailscale on every WoW client.

Not configured yet.

Possible approaches to evaluate:

1. Direct router port forwarding for `3724` and `8085` plus a DNS/DDNS name and firewall rules.
2. Cloudflare Spectrum if a suitable plan is available for transparent raw TCP proxying.
3. Cloudflare Zero Trust/WARP private networking, but that normally requires client-side Cloudflare software.
4. Tailscale remains the simplest private option, but requires Tailscale on the client.

Normal Cloudflare HTTP Tunnel is not a transparent replacement for raw WoW TCP connections from an unmodified client.

When remote access is configured, update both the AzerothCore `realmlist.address` and the client `realmlist.wtf` to the externally reachable hostname/IP as appropriate.

## 13. Verified status

Verified in-game/on-server:

- Ubuntu server migration
- Windows client login to Ubuntu
- existing character/database migration
- Playerbots
- AHBot runtime
- ARAC
- Transmog
- account-wide mounts
- no Hearthstone cooldown
- MySQL localhost-only binding
- SOAP localhost-only binding
- automatic database backups

Still optional/to verify later:

- Flying Mounts Everywhere gameplay
- TipTac
- camera/mouse jerk fix
- remote play without Tailscale
