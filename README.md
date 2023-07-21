# beatrun
Modified beatrun's source code.<br><br>
There are lua modules, they are for Discord Rich Presence and Steam Presence to work, if you want pure Lua just don't extract them, but your Level and Map will not be shown in your Discord and Steam statuses.<br>
This version should works on any version of the game (Base version is known good, Chromium has some issues and I don't have time to fix them).

# Installation
1. **Delete or disable VManip (Base) that downloaded from Workshop!**
2. **Delete `beatrun` and `vmaniprework` folders in *addons* if you have one!**
3. Extract `beatrun` and `vmaniprework` folders to *your_game_folder/garrysmod/addons*.
4. Extract `lua` folder to *your_game_folder/garrysmod*.
	* `lua` folder constains modules for Discord Rich Presense and Steam Presence to work. They are open source, visit [this](https://github.com/fluffy-servers/gmod-discord-rpc) to see the sources of DRP and [this](https://github.com/YuRaNnNzZZ/gmcl_steamrichpresencer) for SP.

## Changes added by me
* [Custom online courses database](https://courses.beatrun.ru)! It's free 🤯
* Configurations menu - You can find it in the tool menu, in the *Beatrun* Category!\
All of the settings below can be changed in the configuration menu
* Allow Overdrive usage on the server - `Beatrun_AllowOverdriveInMultiplayer`.
* Toggle between old and new (like in ME) Kick-Glitch - `Beatrun_OldKickGlitch`.
* Change HUD's colors - `Beatrun_HUDTextColor`, `Beatrun_HUDCornerColor`, `Beatrun_HUDFloatingXPColor`.
* Allow players to spawn props without admin rights - `Beatrun_AllowPropSpawn`.
* `Beatrun_DisableGrapple` - Disables grapple ability.
* Discord Rich Presence (extract `lua` folder to `garrysmod`, along side with `addons` folder).
* Small camera punch when diving.
* Ability to remove ziplines that created with *Zipline Gun* - RMB.
* Removed your SteamID from right corner, because I can.

## TODO
- [ ] Gamemodes menu

## Fixes and changes from previous version
* `Beatrun_DisableGrapple` - Disables grapple ability.

# All changes and fixes
* Course saving works with compression and without.
* Quick turnaround only with `Unarmed`.
* Fixed leaderboard sorting in gamemodes.
* Fixed grapple usage in courses and gamemodes.
* Fixed DataTheft crash when touching data bank.
* Fixed error when loading course.
* Fixed collisions issues.
* Fixed and tweaked player-player weapon damage.
* Proper Kick Glitch (Like in original ME: https://www.youtube.com/watch?v=zK5y3NBUStc).
* Tweaked safety roll, now you can roll under things.
* You can now dive to your death =).
* Allowed punching while crouching.
* Grapple fixes. Now it moves with entity it attached to and other players can see it.
* More reliable grappling.
* Merged some anims into 1 file.

# Credits
* modeltexturesbones - Changed anims a bit.
