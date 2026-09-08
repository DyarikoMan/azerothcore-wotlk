@'
# My AzerothCore Playerbot Setup

Personal AzerothCore WotLK 3.3.5a setup based on the `Playerbot` branch.

The goal is a Docker-based WoW server that can run on Windows or Ubuntu and be played mostly/fully solo with AI players.

## Server stack

- AzerothCore WotLK
- Playerbot branch
- Docker Compose
- MySQL 8.4
- Authserver
- Worldserver

## Installed modules

### Playerbots
Repository:
`mod-playerbots/mod-playerbots`

Adds AI-controlled players that populate the world and can be used for solo/group gameplay.

Current Docker configuration targets roughly 150-200 random bots online.

### Auction House Bot
Repository:
`azerothcore/mod-ah-bot`

Populates Alliance, Horde and Neutral auction houses and performs buying/selling cycles.

### Transmog
Repository:
`azerothcore/mod-transmog`

Adds appearance collection and transmogrification.

Transmog NPC:
`190010`

### Account-wide mounts
Repository:
`pangolp/mod-mounts-on-account`

Shares learned mounts between characters on the same account.

Login synchronization is enabled.

### No Hearthstone Cooldown
Repository:
`BytesGalore/mod-no-hearthstone-cooldown`

Removes the normal Hearthstone cooldown.

### Flying Mounts Everywhere
Repository:
`Dochoppy/mod-flying-mounts-everywhere`

Allows flying outside the normal WotLK flying zones.

This repository contains a compatibility patch in:

`patches/flying-playerbot.patch`

The patch updates the module for the current AzerothCore Playerbot APIs.

Current configuration:

- enabled
- minimum level 20
- all flying mounts allowed
- battleground flying blocked
- instance flying blocked

### ARAC - All Races All Classes
Repository:
`heyitsbench/mod-arac`

Allows normally unavailable race/class combinations.

ARAC requires:

- world SQL
- modified server DBC files
- client `Patch-A.MPQ`

The client patch is NOT stored in this repository.

## Module setup

### Windows

Run from PowerShell:

```powershell
pwsh -ExecutionPolicy Bypass -File .\setup-modules.ps1