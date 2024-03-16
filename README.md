# Beatrun | Community edition

* [Русский](./README_ru.md)

Infamous parkour addon for Garry's Mod, fully open sourced and maintained by the community (me 😞).

> [!IMPORTANT]
> You will not find here any malicious modules, code or networking! We have modules and networking for:
>
> * Discord Rich Presence.
> * Steam Presence.
> * Custom Courses Database.
>
> **All of this is optional and you can remove all of it.**\
> Modules are located [here](https://github.com/JonnyBro/beatrun/tree/main/lua/bin) and courses database functionality is [here](https://github.com/JonnyBro/beatrun/blob/main/beatrun/gamemodes/beatrun/gamemode/cl/CoursesDatabase.lua).\
> You can find source code for modules in [Credits](#credits) section.

**PLEASE READ EVERYTHING BEFORE ASKING QUESTIONS ON OUR SERVER!**

## Automatic Installation (Recommended | Windows only)

Run the command below in Powershell.
> [!NOTE]
> Win + R > `powershell`

```powershell
iex (iwr "beatrun.ru/install" -UseBasicParsing)
```

Select the `Beatrun` gamemode in right lower corner.

## Manual Installation

1. Download this repository [here](https://github.com/JonnyBro/beatrun/archive/refs/heads/master.zip).
2. **Delete the `beatrun` folder in *your_game_folder/garrysmod/addons* if you have one.**
3. Extract the `beatrun-main/beatrun` folder to *your_game_folder/garrysmod/addons*.
4. Extract the `beatrun-main/lua` folder to *your_game_folder/garrysmod*.
5. Select the `Beatrun` gamemode in right lower corner.

## Animations

Please refer to this [README](beatrun/README.md).

## Changes

> [!IMPORTANT]
> There are many undocumented changes and fixes in this version, you better look at the commits for more specific changes.

* Jonny_Bro is hosting [custom online courses database](https://courses.beatrun.ru), which is also free and [open source](https://github.com/relaxtakenotes/beatrun-courses-server/) 🤯!
* Implemented a new gamemode - **Deathmatch** (it's way more fun than Data Theft I promise).
* Implemented "Proper" Kick Glitch just like in [original ME](https://www.youtube.com/watch?v=zK5y3NBUStc).
* Added an in-game config menu - you can find it in the tool menu, in the *Beatrun* Category.\
**All** of the Beatrun settings can be changed in the configuration menu.
* Localization support.\
Available in 5 languages now!
* Build Mode Tweaks.\
You can now spawn any prop from Spawn Menu and they will save in course.
* Added the ability to get off of ladders.
* Added an arrow that shows the next checkpoint.
* Added a ConVar to allow Overdrive usage on the server - `Beatrun_AllowOverdriveInMultiplayer`.
* Added a ConVar to toggle between old and new Kick Glitch - `Beatrun_OldKickGlitch`.
* Added some ConVars to change HUD colors - `Beatrun_HUDTextColor`, `Beatrun_HUDCornerColor`, `Beatrun_HUDFloatingXPColor`.
* Added a ConVar to allow players to spawn props and weapons without admin rights - `Beatrun_AllowPropSpawn`.
* Added a ConVar to toggle the grapple ability - `Beatrun_DisableGrapple`.
* Added a ConVar to allow QuickTurn with any weapon or only with *Runner Hands* - `Beatrun_QuickturnHandsOnly`.
* Added a ConVar to toggle the heatlh regeneration - `Beatrun_HealthRegen`.
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

## Credits

* [All contributors](https://github.com/JonnyBro/beatrun/graphs/contributors) - <3.
* [EarthyKiller127](https://www.youtube.com/channel/UCiFqPwGo4x0J65xafIaECDQ) - He made that piece of shit.
* [relaxtakenotes](https://github.com/relaxtakenotes) - Made all of this possible.
* [MTB](https://www.youtube.com/@MTB396) - Beatrun Reanimated Project.
* [Discord Rich Presence](https://github.com/fluffy-servers/gmod-discord-rpc) by Fluffy Servers.
* [Steam Presence](https://github.com/YuRaNnNzZZ/gmcl_steamrichpresencer) by YuRaNnNzZZ.
