# Beatrun | Community Edition

[![Powered by Electricity](https://forthebadge.com/images/featured/featured-powered-by-electricity.svg)](https://forthebadge.com)
[![Powered by Black Magic](https://forthebadge.com/images/badges/powered-by-black-magic.svg)](https://forthebadge.com)

[**Join our Discord Community!**](https://discord.gg/93Psubbgsg)

> *[Русский | Russian](./README.ru.md)*

---

## 🚨 Important Notice

### Please read this README thoroughly before asking questions

### The **only official source** for this fork is this repository and [my workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=3467179024). Other workshop versions are not supported

### Whoever else that claims to have an "official" repository and does not have a license other than WTFPL is NOT to be trusted. This project is not that legal, so licenses DO NOT apply under any circumstances

### This repository is the original one and is maintained by the original people that cracked Beatrun

---

## About

Beatrun is an **infamous parkour addon for Garry's Mod**, now fully open-sourced and maintained by the community.
It includes various improvements, new features, and enhanced functionality.

> [!WARNING]
> **This repository contains no malicious modules.** However, optional modules such as Discord Rich Presence and Steam Presence are available for additional features.
> These are **completely optional** and can be removed at any time.
>
> - Modules are located **[here](https://github.com/JonnyBro/beatrun/tree/main/lua/bin)**.
> - Refer to the **[Credits](#credits)** section for their source code.

## Installation

### VERY Easy Installation

> [!WARNING]
> Don't forget to delete the Beatrun's folder from the addons.

[Click Here](https://steamcommunity.com/sharedfiles/filedetails/?id=3467179024)

### 🔧 Automatic Installation (Recommended for Windows 10/11)

> [!NOTE]
> Windows 7 and old versions of Windows 10 are not supported. Please update your OS.

Run the following command in PowerShell (Run as Administrator if Steam and/or the game is installed on the system (C:) drive):

```powershell
irm https://beatrun.jonnybro.ru/install | iex
```

1. Start the game.
2. Select the `Beatrun` gamemode in the bottom-right corner.

### 🛠️ Manual Installation

1. **[Download this repository](https://github.com/JonnyBro/beatrun/archive/refs/heads/master.zip).**
2. Delete the `beatrun` folder in `your_game_folder/garrysmod/addons`, if it exists.
3. Extract `beatrun-main` into `your_game_folder/garrysmod/addons`.
4. (Optional) For Discord and Steam Presence, move `your_game_folder/garrysmod/addons/beatrun-main/lua` to `your_game_folder/garrysmod`.
5. Start the game.
6. Select the `Beatrun` gamemode in the bottom-right corner.

---

## Features and Updates

### New Features

- **Custom Courses Database** hosted by Jonny_Bro: **[Access Here](https://courses.jonnybro.ru)** (free and **[open source](https://git.jonnybro.ru/jonny_bro/beatrun-courses-server)**).
- **New Gamemode:** Deathmatch.
- "Proper" Kick Glitch similar to the **[original game](https://www.youtube.com/watch?v=zK5y3NBUStc)**.
- In-game configuration menu in the Tools menu under **Beatrun**. All settings can be modified here.
- Localization support in **7 languages**.
- Enhanced Build Mode: spawn props from the Spawn Menu, and they will save in your course.
- Random weapon loadouts from MW Base, ARC9, ARCCW and TFA. Or create your own in [!Helpers.lua](./gamemodes/beatrun/gamemode/sh/!Helpers.lua#L7)!
- Various new abilities:
  - **Roll after ziplines:** Press `+duck` (CTRL by default).
  - **Dismount ladders:** Press `+duck` (CTRL by default).
  - **Remove ziplines created with Zipline Gun:** Press `+attack2` (RMB by default).
  - **Next checkpoint arrow** for easier navigation.
- New server and client configuration variables:
  - Server:
    - `Beatrun_AllowOverdriveInMultiplayer`: Allows Overdrive in multiplayer.
    - `Beatrun_AllowPropSpawn`: Lets players spawn props and weapons without admin rights.
    - `Beatrun_HealthRegen`: Toggles health regeneration.
  - Client:
    - `Beatrun_HUDTextColor`, `Beatrun_HUDCornerColor`, `Beatrun_HUDFloatingXPColor`: Customize HUD colors.
    - `Beatrun_DisableGrapple`: Toggle the grapple ability.
    - `Beatrun_KickGlitch`: Switch between old and new Kick Glitch versions.
    - `Beatrun_QuickturnHandsOnly`: Restrict QuickTurn to the Runner Hands weapon.
- Other improvements:
  - Small camera punch effect when diving.
  - SteamID no longer displayed on screen.

### Fixes

- Fixed playermodels showing as `ERROR` in first person.
- Improved leaderboard sorting in gamemodes.
- Fixed crashes and issues with Data Theft gamemode.
- Enabled jumping while walking.
- Grapples now follow moving entities and are visible to other players.

---

## Animations

The animations installer has been removed. You can now switch animations directly in the **Tools menu** under the Beatrun category.

---

## Known Issues

- See the full list of issues **[here](https://github.com/JonnyBro/beatrun/issues)**.

---

## Related Projects

- **[Beatrun Reanimated Project](https://github.com/JonnyBro/beatrun-anims)**

---

## Credits

- **[All contributors](https://github.com/JonnyBro/beatrun/graphs/contributors)** ❤️
- [EarthyKiller127/datae](https://www.youtube.com/channel/UCiFqPwGo4x0J65xafIaECDQ) - Original creator of Beatrun.
- [relaxtakenotes](https://github.com/relaxtakenotes) - Made this project possible.
- [MTB](https://www.youtube.com/@MTB396) - Beatrun Reanimated Project.
- [Fluffy Servers](https://github.com/fluffy-servers/gmod-discord-rpc) - Discord Rich Presence.
- [YuRaNnNzZZ](https://github.com/YuRaNnNzZZ/gmcl_steamrichpresencer) - Steam Presence (TFA Base creator).
