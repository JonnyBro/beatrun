*Note: The code in here is **kinda** garbage, especially the parts that I made myself. I don't do networking, and I sort of suck at coding, so don't expect any high quality bug-free stuff or anything. (To be fair, Beatrun was never bug-free to begin with.) Any constructive criticism about the code is appreciated.*

# Beatrun | Community edition

*Looking for the replay stuff? This isn't the branch for that. It's on the [`jonny/replays`](https://github.com/UnderSet/beatrun-jonny/tree/jonny/replays) branch instead.*
* [Русский](./README_ru.md) (Outdated, I don't speak Russian)

Infamous parkour addon for Garry's Mod, fully open sourced and maintained by the community.

**READ THE ***ENTIRE*** README BEFORE ASKING QUESTIONS ON THE [beatrun.ru](https://beatrun.ru) DISCORD!**

> [!NOTE]
> This version does not include malicious modules, code or networking. What it does contain is:
> * Lua modules for Discord Rich Presence
> * Lua modules for Steam Presence
> * Network connectivity for courses (activates only when you load or upload courses, and by default `courses.beatrun.ru` is used)
>
> **All of this is optional and you may remove all of it.
> Modules are located in [/lua/bin](/lua/bin/) and online courses functionality is in [OnlineCourse.lua](/beatrun/gamemodes/beatrun/gamemode/cl/OnlineCourse.lua)**

## Manual Installation
1. Download this repository [here](https://github.com/JonnyBro/beatrun/archive/refs/heads/master.zip).
2. **Delete the `beatrun` folder in *your_game_folder/garrysmod/addons* if you have one.**
3. Extract the `beatrun` folder to *your_game_folder/garrysmod/addons*.
4. Extract the `lua` folder to *your_game_folder/garrysmod*.

## Animations
You can use "**BeatrunAnimInstaller**" (located in `beatrun` [here](https://github.com/JonnyBro/beatrun/tree/master/beatrun)) for custom animations. Currently there's:
* Beatrun Reanimated
* Fixed Original<br>

Start the executable and press a key on your keyboard with the number of the animation you want to install (if nothing's changed, run the program as admin).<br>
Installer's source can be found [here](/BeatrunAnimInstaller).

## Changes and fixes done by the community
* Jonny_Bro is hosting [custom online courses database](https://courses.beatrun.ru), which is also free and [open source](https://github.com/relaxtakenotes/beatrun-courses-server/) 🤯!
* Implemented a new gamemode - **Deathmatch** (it's way more fun than Data Theft I promise).
* Implemented "Proper" Kick Glitch just like in [original ME](https://www.youtube.com/watch?v=zK5y3NBUStc).
* Added an in-game config menu - you can find it in the tool menu, in the *Beatrun* Category.\
**All** of the Beatrun settings can be changed in the configuration menu.
* Localization support.\
For now Russian and English are supported.
* Added the ability to get off of ladders.
* Added an arrow that shows the next checkpoint.
* Added a ConVar to allow Overdrive usage on the server - `Beatrun_AllowOverdriveInMultiplayer`.
* Added a ConVar to toggle between old and new Kick Glitch - `Beatrun_OldKickGlitch`.
* Added some ConVars to change HUD colors - `Beatrun_HUDTextColor`, `Beatrun_HUDCornerColor`, `Beatrun_HUDFloatingXPColor`.
* Added a ConVar to allow players to spawn props and weapons without admin rights - `Beatrun_AllowPropSpawn`.
* Added a ConVar to disable grapple ability - `Beatrun_DisableGrapple`.
* Added a ConVar to allow QuickTurn with any weapon or only with *Runner Hands* - `Beatrun_QuickturnHandsOnly`.
* Added small camera punch when diving.
* Added the ability to remove ziplines that created with *Zipline Gun* - `RMB`.
* Implemented Discord Rich Presence using [open source](#credits) module.

## Fixes

* Your SteamID in the right corner is no longer present.
* Fixed some playermodels show up as ERROR.
* Done various tweaks to the Courses Menu (F4).
* Allowed jumping while walking (🤷).
* Fixed leaderboard sorting in gamemodes.
* Fixed grapple usage in courses and gamemodes.
* Fixed a crash in Data Theft when touching Data Bank.
* Fixed an error on course loading.
* Fixed collisions issues. (PvP damage not going through in gamemodes other than Data Theft)
* Tweaked safety roll, now you can roll under things.
* Tweaked some grapple related stuff. Now it moves with the entity it was attached to and other players can see the rope.
* Made it possible to dive to your death =).

## TODO

* [ ] Loadouts creation menu for Data Theft and Deathmatch. (idk how to properly implement this for know).

## Related

* [Beatrun Reanimated Project](https://github.com/JonnyBro/beatrun-anims).

# Credits <3
* All contributors.
* **[JonnyBro](https://github.com/JonnyBro)** - Making most, if not all of the fixes in this repository
* **[EarthyKiller127](https://www.youtube.com/channel/UCiFqPwGo4x0J65xafIaECDQ)**, a.k.a ***datæ*** - He made that piece of shit.
* **[relaxtakenotes](https://github.com/relaxtakenotes)** - Made all of this possible.
* **[MTB](https://www.youtube.com/@MTB396)** - Beatrun Reanimated project.
* **[Discord Rich Presence](https://github.com/fluffy-servers/gmod-discord-rpc)** by Fluffy Servers.
* **[Steam Presence](https://github.com/YuRaNnNzZZ/gmcl_steamrichpresencer)** by YuRaNnNzZZ.
