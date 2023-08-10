# Beatrun
Modified Beatrun's source code.<br><br>
There are some Lua modules, they are for Discord Rich Presence and Steam Presence to work.<br>
If you want pure Lua just don't extract them, but your Level and Map will not be shown in your Discord and Steam statuses.<br><br>
This version should works on any version of the game (Base version is known good, x64 has some issues and I'm trying to fix them when I can).

## Animations
You can use **Beatrun Animations Installer** if you want to change your animations, there are new ones (from Beatrun Reanimated project) and OG (but fixed) ones, OG is default.<br>
Just start the exe and press a key on your keyboard with the number of the animations you want to install (If it doesn't change animations, run installer as admin).<br>
Installer source can be found [here](/BeatrunAnimInstaller/)

# Installation
0. Download this repository [here](https://github.com/JonnyBro/beatrun/archive/refs/heads/master.zip) (should be always up-to-date).
1. **Delete `beatrun` folder in *addons* if you have one!**
2. Extract `beatrun` folder to *your_game_folder/garrysmod/addons*.
3. Extract `lua` folder to *your_game_folder/garrysmod*.
	* `lua` folder constains modules for Discord Rich Presense and Steam Presence to work. They are open source, you can find links at the [Credits](https://github.com/JonnyBro/beatrun#credits) section.

## Changes added by me
* [Custom online courses database](https://courses.beatrun.ru), it's free 🤯!
* Configurations menu - You can find it in the tool menu, in the *Beatrun* Category!\
All of the settings below can be changed in the configuration menu.
* Getting off of ladders (don't work on x64, idk).
* Jumping while walking.
* Various tweaks to Time Trials Menu (F4).
* Arrow that shows the next checkpoint.
* Allow Overdrive usage on the server - `Beatrun_AllowOverdriveInMultiplayer`.
* Toggle between old and new (like in ME) Kick-Glitch - `Beatrun_OldKickGlitch`.
* Change HUD's colors - `Beatrun_HUDTextColor`, `Beatrun_HUDCornerColor`, `Beatrun_HUDFloatingXPColor`.
* Allow players to spawn props without admin rights - `Beatrun_AllowPropSpawn`.
* Disable grapple ability - `Beatrun_DisableGrapple`.
* Discord Rich Presence (See step 3).
* Small camera punch when diving.
* Ability to remove ziplines that created with *Zipline Gun* - RMB.
* Removed your SteamID from right corner, because I can.

## Fixes and changes from previous version
* *null*

# All changes and fixes
* Course saving works with compression and without.
* Quick turnaround only with `Unarmed`.
* Fixed leaderboard sorting in gamemodes.
* Fixed grapple usage in courses and gamemodes.
* Fixed crash in DataTheft when touching data bank.
* Fixed error on course load.
* Fixed collisions issues.
* Fixed and tweaked player-player weapon damage.
* Proper Kick Glitch (Like in original ME: https://www.youtube.com/watch?v=zK5y3NBUStc).
* Tweaked safety roll, now you can roll under things.
* You can now dive to your death =).
* Grapple fixes. Now it moves with entity it attached to and other players can see it.
* More reliable grappling.
* Merged some anims into 1 file.

## TODO
- [ ] Gamemodes menu.

# Related
[beatrun-anims](https://github.com/JonnyBro/beatrun-anims) - Sources of animations from Beatrun.

# Credits <3
* All contributors.
* [MTB](https://www.youtube.com/@MTB396) - Beatrun Reanimated project.
* [Discord Rich Presence](https://github.com/fluffy-servers/gmod-discord-rpc) by Fluffy Servers.
* [Steam Presence](https://github.com/YuRaNnNzZZ/gmcl_steamrichpresencer) by YuRaNnNzZZ.
* [datae](https://www.youtube.com/channel/UCiFqPwGo4x0J65xafIaECDQ) - He made that piece of shit code.
