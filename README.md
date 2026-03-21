# Beatrun | Community Edition

[![forthebadge](https://forthebadge.com/badges/60-percent-of-the-time-works-every-time.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/badges/as-seen-on-tv.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/badges/contains-tasty-spaghetti-code.svg)](https://forthebadge.com)

[**Join our Discord Community!**](https://discord.gg/93Psubbgsg)

> *[Русский | Russian](./README.ru.md)*

---

## About

Beatrun is an **infamous parkour gamemode for Garry's Mod**, now fully open-sourced and maintained by the community.
It includes various improvements, new features, and enhanced functionality.

> [!WARNING]
> This repository contains **optional** modules for showing custom statuses in Discord and Steam.\
> They are not required for Beatrun to work.
>
> You can find those modules **[here](https://github.com/JonnyBro/beatrun/tree/main/lua/bin)**.\
> And you can find their source code in the **[credits](#credits)**.

## Installation

### Steam Workshop

> [!WARNING]
> Don't forget to delete any other Beatrun versions from `garrysmod/addons`!

1. [Subscribe to this addon](https://steamcommunity.com/sharedfiles/filedetails/?id=3467179024).
1. Start the game.
1. Select the `Beatrun` gamemode in the bottom-right corner.

### Manual Installation

1. **[Download the repository](https://github.com/JonnyBro/beatrun/archive/refs/heads/master.zip).**
1. Delete the `beatrun` folder in `your_game_folder/garrysmod/addons`, if it exists.
1. Extract `beatrun-main` into `your_game_folder/garrysmod/addons`.
   - (Optional) For Discord and Steam Presence, move the contents of `beatrun-main/lua/bin` to your `your_game_folder/garrysmod/lua/bin` (create the folder if it doesn't exists).
1. Start the game.
1. Select the `Beatrun` gamemode in the bottom-right corner.

---

## Features and Updates

> [!NOTE]
> There are plenty of changes and fixes that are not documented here. If you are interested - feel free to read the commits.

### New Features

- **In-game** Courses Database UI.
  - Accessible by pressing F4 (**[source code](https://github.com/JonnyBro/beatrun-courses-server)**).
  - Default one is hosted by @JonnyBro.
- **New Deathmatch gamemode**.
- "Proper" Kick Glitch similar to the **[original game](https://www.youtube.com/watch?v=zK5y3NBUStc)**.
- **In-game** configuration in the Tools menu under **Beatrun**. All settings can be changed from there.
- Localization support in **7 languages**.
- Enhanced Build Mode: spawn props from the Spawn Menu, and they will save in your course.
- Random weapon loadouts from **MW Base**, **ARC9**, **ARCCW** and **TFA**. Or create your own in [!Helpers.lua](./gamemodes/beatrun/gamemode/sh/!Helpers.lua#L8)!
- Race your Ghost: a ghost of your best time in the current course.
- Various new/fixed abilities:
  - **Roll after ziplines:** Press `+duck` (CTRL by default).
  - **Dismount ladders:** Press `+duck` (CTRL by default).
  - **Remove ziplines created with Zipline Gun:** Press `+attack2` (RMB by default).
  - **Arrow to the next checkpoint** for easier navigation.
- New server and client configuration variables:
  - Server:
    - `Beatrun_AllowOverdriveInMultiplayer`: Allow Overdrive in multiplayer.
    - `Beatrun_AllowPropSpawn`: Let players spawn props without admin rights.
    - `Beatrun_AllowWeaponSpawn`: Let players spawn weapons without admin rights.
    - `Beatrun_HealthRegen`: Toggle health regeneration.
  - Client:
    - `Beatrun_HUDTextColor`, `Beatrun_HUDCornerColor`, `Beatrun_HUDFloatingXPColor`: Customize HUD colors.
    - `Beatrun_DisableGrapple`: Toggle the grapple ability.
    - `Beatrun_KickGlitch`: Switch between old and new Kick Glitch versions.
    - `Beatrun_QuickturnHandsOnly`: Restrict QuickTurn to the Runner Hands weapon.
- Other improvements:
  - Small camera punch effect when diving.
  - SteamID no longer displayed on your screen.

### Fixes

- Fixed playermodels showing as `ERROR` in first person.
- Improved leaderboard sorting in gamemodes.
- Fixed crashes and issues with Data Theft gamemode.
- Enabled jumping while walking.
- Grapple now follows moving entities and visible to other players.

---

## Animations

You can now change animations in the **Tools menu** under the Beatrun category.

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
- relaxtakenotes - Made this project possible.
- [MTB](https://www.youtube.com/@MTB396) - Beatrun Reanimated Project.
- [Fluffy Servers](https://github.com/fluffy-servers/gmod-discord-rpc) - Discord Rich Presence.
- [YuRaNnNzZZ](https://github.com/YuRaNnNzZZ/gmcl_steamrichpresencer) - Steam Presence.

### Fonts

> [!NOTE]
> They could be wrong, I tried to find the original sources.

- [x14y24pxHeadUpDaisy](https://hicchicc.github.io/00ff/)
- [Datto D-DIN](https://github.com/amcchord/datto-d-din)

## Star History

<!-- markdownlint-disable MD033 -->
<a href="https://www.star-history.com/#JonnyBro/beatrun&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=JonnyBro/beatrun&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=JonnyBro/beatrun&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=JonnyBro/beatrun&type=date&legend=top-left" />
 </picture>
</a>
