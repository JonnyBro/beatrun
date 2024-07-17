# Beatrun | Community edition

[Click to join our Discord!](https://discord.gg/93Psubbgsg)

* [Русский](./README.ru.md)

**PLEASE READ EVERYTHING BEFORE ASKING QUESTIONS ON OUR SERVER!**\
**WE DOCUMENTED EVERYTHING ENOUGH SO YOU CAN INSTALL THIS YOURSELF PRETTY EASILY**

Infamous parkour addon for Garry's Mod.\
Fully open sourced and maintained by the community (me 😞).

> [!IMPORTANT]
> This repository doesn't contain any malicious modules. It does contain some modules for additional functionality like:
>
> * Discord Rich Presence.
> * Steam Presence.
>
> **They are optional and can be removed at any time.**\
> You can find all modules **[here](https://github.com/JonnyBro/beatrun/tree/main/lua/bin)**.\
> Check **[Credits](#credits)** section for their source code.

## Steam Workshop (lmao)

[Subscribe](https://steamcommunity.com/sharedfiles/filedetails/?id=3290421288)

### Automatic Installation (Recommended | Windows 10/11)

> [!WARNING]
> Windows 7 is not supported.\
> Update already...

Run the command below in Powershell.
> [!NOTE]
> Win + R > `powershell` > *Enter*

```powershell
irm https://beatrun.jonnybro.ru/install | iex
```

* Select the `Beatrun` gamemode in right lower corner.

### Manual Installation

1. **[Download this repository](https://github.com/JonnyBro/beatrun/archive/refs/heads/master.zip)**.
2. **Delete the `beatrun` folder in *your_game_folder/garrysmod/addons* if you have one.**
3. Extract the `beatrun-main/beatrun` folder to *your_game_folder/garrysmod/addons*.
4. If you want to have Discord and Steam Presence:
   * Extract the `beatrun-main/lua` folder to *your_game_folder/garrysmod*.
5. Select the `Beatrun` gamemode in right lower corner.

## Animations

[Please refer to this file.](beatrun/README.md)

## Features

> [!IMPORTANT]
> There are many undocumented changes and fixes in this version, you better look at the commits for more specific changes.

* Jonny_Bro is hosting **[custom courses database](https://courses.jonnybro.ru)**, which is also **free** to use and **[open sourced](https://git.jonnybro.ru/jonny_bro/beatrun-courses-server-express)**!
* New gamemode - **Deathmatch** (it's way more fun than Data Theft I promise).
* "Proper" Kick Glitch just like in **[original game](https://www.youtube.com/watch?v=zK5y3NBUStc)**.
* In-game configuration menu - you can find it in the tools menu, in the **Beatrun** category.\
  **All** of the Beatrun settings can be changed in the configuration menu!
* Discord and Steam Presence.
* Localization support.\
  Available in 7 languages!
* Build Mode Tweaks.\
You can now spawn any prop from Spawn Menu and they will save in your course.
* Ability to roll after ziplines with CTRL 🤯 (thanks c4nk <3).
* Ability to get off of ladders - Press CTRL.
* Ability to remove ziplines that created with *Zipline Gun* - Press RMB.
* Arrow that shows the next checkpoint.
* ConVar to allow Overdrive usage (server) - `Beatrun_AllowOverdriveInMultiplayer`.
* ConVar to allow players to spawn props and weapons without admin rights (server) - `Beatrun_AllowPropSpawn`.
* ConVar to toggle the heatlh regeneration (server) - `Beatrun_HealthRegen`.
* ConVars to change HUD colors (client) - `Beatrun_HUDTextColor`, `Beatrun_HUDCornerColor`, `Beatrun_HUDFloatingXPColor`.
* ConVar to toggle the grapple ability (client) - `Beatrun_DisableGrapple`.
* ConVar to toggle between old and new Kick Glitch (client) - `Beatrun_OldKickGlitch`.
* ConVar to allow QuickTurn with any weapon or only with *Runner Hands* (client) - `Beatrun_QuickturnHandsOnly`.
* Small camera punch when diving.
* Your SteamID on the screen is no longer present.

## Fixes

* Some playermodels show up as **ERROR**.
* Leaderboard sorting in gamemodes.
* Grapple usage in courses and gamemodes.
* Crash in Data Theft when touching Data Bank.
* Collisions issues - PvP damage not going through in gamemodes other than Data Theft.
* Allowed jumping while walking (🤷).
* Tweaked safety roll - now you can roll under things.
* Tweaked some grapple related stuff - now it moves with the entity it was attached to and other players can see the rope.

## TODO

* [ ] Loadouts creation menu for Data Theft and Deathmatch. (idk how to properly implement this for know).

## Known issues

* [Issues](https://github.com/JonnyBro/beatrun/issues).
* Maybe more, i forgor 💀.

## Related projects

* [Beatrun Reanimated Project](https://github.com/JonnyBro/beatrun-anims).

## Credits

* [All contributors](https://github.com/JonnyBro/beatrun/graphs/contributors) - <3.
* [EarthyKiller127](https://www.youtube.com/channel/UCiFqPwGo4x0J65xafIaECDQ) - He made that piece of shit.
* [relaxtakenotes](https://github.com/relaxtakenotes) - Made all of this possible.
* [MTB](https://www.youtube.com/@MTB396) - Beatrun Reanimated Project.
* [Fluffy Servers](https://github.com/fluffy-servers/gmod-discord-rpc) - Discord Rich Presence.
* [YuRaNnNzZZ](https://github.com/YuRaNnNzZZ/gmcl_steamrichpresencer) - Steam Presence.
