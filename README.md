# beatrun
Modified beatrun's source code.<br><br>
There are lua modules, they are for Discord Rich Presence to work, if you want pure Lua just don't extract them, but your Level and Map will not be shown in your Discord status.<br>
This version of the beatrun works on any version of the game (Chromium or not).

[Old Kick Glitch Version](https://github.com/JonnyBro/beatrun/tree/old-kickglitch)

# Installation
0. Delete `beatrun` folder in *addons* if you have it!
1. Extract `beatrun` folder to *your_game_folder/garrysmod/addons*.
2. Extract `lua` folder to *your_game_folder/garrysmod*.
    * `lua` folder constains modules for Discord Rich Presense to work. They are open source, visit [this](https://github.com/fluffy-servers/gmod-discord-rpc) to see the source.

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

## TODO
- [ ] Configuration menu
- [ ] Gamemodes menu

## Fixes and changes from previous version
* You can now dive to your death =)

# All changes and fixes
* Course saving works with compression and without.
* Quick turnaround only with `Unarmed`.
* Fixed leaderboard sorting in gamemodes.
* Fixed grapple usage in courses and gamemodes.
* Fixed DataTheft crash when touching data bank.
* Fixed error when loading course.
* Fixed collisions issues.
* Fixed and tweaked player-player weapon damage.
* Proper Kick Glitch (Like in original ME: https://www.youtube.com/watch?v=zK5y3NBUStc)
* Grapple fixes. Now it moves with entity it attached to and other players can see it.
* More reliable grappling.
