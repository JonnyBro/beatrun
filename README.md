# beatrun
Modified beatrun's source code.<br><br>
There are lua modules ([source](https://github.com/fluffy-servers/gmod-discord-rpc)), they are for Discord Rich Presence to work, if you want pure Lua just don't extract them, but your Level and Map will not be shown in your Discord status.<br>
This version of the beatrun works on any version of the game (Chromium or not).

# Installation
[here](/INSTALLATION.md)

## Changes added by me
* [Custom online courses database](https://courses.beatrun.ru)! It's free 🤯!
* Allow Overdrive usage on the server - `Beatrun_AllowOvedriveInMultiplayer`.
* Change HUD's colors - `Beatrun_HUDTextColor`, `Beatrun_HUDCornerColor`, `Beatrun_HUDFloatingXPColor`.
* Discord Rich Presence (extract `lua` folder to `garrysmod`, along side with `addons` folder).
* Small camera punch when diving.
* Change max moving speed - `Beatrun_MaxSpeed`.
* Ability to remove ziplines that created with *Zipline Gun* - RMB.
* Removed your SteamID from right corner, because I can.
* Allow players to spawn props without admin rights - `Beatrun_AllowPropSpawn`.

## Fixes from previous version
* Working on a new Gamemodes menu... (currently doesn't work at all).

# All changes and fixes
* Course saving works with compression and without.
* Quick turnaround only with `Unarmed`.
* Fixed leaderboard sorting in gamemodes.
* Fixed grapple usage in courses and gamemodes.
* Fixed DataTheft crash when touching data bank.
* Fixed error when loading course.
* Fixed collisions issues.
