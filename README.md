# Beatrun | Community version

Infamous parkour addon for Garry's Mod, fully open sourced and maintained by the community.

This version does not include malicious modules, code or networking. What it does contain is:
* Lua modules for Discord Rich Presence
* Lua modules for Steam Presence
* Network connectivity for courses (activates only when you load or upload courses, and by default `courses.beatrun.ru` is used)

**All of this is optional and you may remove all of it. (modules are located [here](https://github.com/JonnyBro/beatrun/blob/master/lua/bin/) and online courses functionality is [here](https://github.com/JonnyBro/beatrun/blob/master/beatrun/gamemodes/beatrun/gamemode/cl/OnlineCourse.lua))**

## **PLEASE READ ALL BEFORE ASKING QUESTIONS ON OUR SERVER!**

# (Prefered) Installation (Automatic | Windows only)
Run the command below in the Powershell.
> (Win + R > powershell > command in question)
```powershell
iex (iwr "beatrun.ru/install.ps1" -UseBasicParsing)
```

## Installation (Manual)
1. Download this repository [here](https://github.com/JonnyBro/beatrun/archive/refs/heads/master.zip).
2. Delete the `beatrun` folder in *addons* if you have one!
3. Extract the `beatrun` folder to *your_game_folder/garrysmod/addons*.
4. Extract the `lua` folder to *your_game_folder/garrysmod*.
	* `lua` folder contains modules for Discord Rich Presense and Steam Presence. They are optional. You can find their source code in the [credits](https://github.com/JonnyBro/beatrun?tab=readme-ov-file#credits-3) section<br><br>

## Animations
You can use "**BeatrunAnimInstaller**" (located in `beatrun` [here](https://github.com/JonnyBro/beatrun/tree/master/beatrun)) for custom animations. Currently there's:
* Beatrun Reanimated
* Fixed Original<br><br>

Start the executable and press a key on your keyboard with the number of the animation you want to install (if nothing's changed, run the program as admin).<br>
Installer's source can be found [here](/BeatrunAnimInstaller).

## Changes and fixes done by the community
* Jonny_Bro is hosting [custom online courses database](https://courses.beatrun.ru), which is also free and [open source](https://github.com/relaxtakenotes/beatrun-courses-server/) 🤯!
* Added a new gamemode - *Deathmatch*, it's like Data Theft, but you collect kills not cubes! (it's way more fun I promise)
* Added an in-game config menu - You can find it in the tool menu, in the *Beatrun* Category!\
**All** of the Beatrun settings can be changed in the configuration menu.
* Added the ability to get off of ladders.
* Allowed jumping while slowwalking (🤷).
* Done various tweaks to the Time Trials Menu (F4).
* Added an arrow that shows the next checkpoint.
* Added a ConVar to allow Overdrive usage on the server - `Beatrun_AllowOverdriveInMultiplayer`.
* Added a ConVar to toggle between old and new (like in ME) Kick-Glitch - `Beatrun_OldKickGlitch`.
* Added some ConVars to change HUD colors - `Beatrun_HUDTextColor`, `Beatrun_HUDCornerColor`, `Beatrun_HUDFloatingXPColor`.
* Added a ConVar to allow players to spawn props without admin rights - `Beatrun_AllowPropSpawn`.
* Added a ConVar to disable grapple ability - `Beatrun_DisableGrapple`.
* Added a ConVar to allow QuickTurn with any weapon or only with *Runner Hands* - `Beatrun_QuickturnHandsOnly`.
* Implemented Discord Rich Presence using open source tools (See [credits](https://github.com/JonnyBro/beatrun?tab=readme-ov-file#credits-3)).
* Added small camera punch when diving.
* Added the ability to remove ziplines that created with *Zipline Gun* - `RMB`.
* Fixed some playermodels show up as ERROR.
* SteamID in the right corner is no longer present.

## Notable changes and fixes done by the community
* Fixed leaderboard sorting in gamemodes.
* Fixed grapple usage in courses and gamemodes.
* Fixed a crash in DataTheft when touching data bank.
* Fixed an error on course load.
* Fixed collisions issues. (PvP damage not going through in gamemodes other than DataTheft)
* Added Proper Kick Glitch ([Like in original ME](https://www.youtube.com/watch?v=zK5y3NBUStc)). (cry about prediction errors l0l)
* Tweaked safety roll, now you can roll under things.
* Made it possible to dive to your death =).
* Added some grapple related stuff. Now it moves with the entity it was attached to and other players can see the rope.

## TODO
- [ ] Gamemodes menu. (idk how to properly implement this for know)

# Related
* [beatrun-anims](https://github.com/JonnyBro/beatrun-anims) - Decompiled and reworked Beatrun animations.

# Credits <3
* All contributors.
* [EarthyKiller127](https://www.youtube.com/channel/UCiFqPwGo4x0J65xafIaECDQ) - He made that piece of shit.
* [relaxtakenotes](https://github.com/relaxtakenotes) - Made all of this possible.
* [MTB](https://www.youtube.com/@MTB396) - Beatrun Reanimated project.
* [Discord Rich Presence](https://github.com/fluffy-servers/gmod-discord-rpc) by Fluffy Servers.
* [Steam Presence](https://github.com/YuRaNnNzZZ/gmcl_steamrichpresencer) by YuRaNnNzZZ.
