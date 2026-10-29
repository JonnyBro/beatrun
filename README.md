# Beatrun | Community Edition

[![forthebadge](https://forthebadge.com/badges/60-percent-of-the-time-works-every-time.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/badges/as-seen-on-tv.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/badges/contains-tasty-spaghetti-code.svg)](https://forthebadge.com)

[**Join our Discord Community!**](https://discord.gg/93Psubbgsg)

> *[Русский | Russian](./README.ru.md)*

---

## About

Beatrun is an **infamous parkour gamemode for Garry's Mod**, now fully open-sourced and maintained by the community.

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

1. **[Download the repository](https://github.com/JonnyBro/beatrun/archive/refs/heads/main.zip).**
1. Delete the `beatrun` folder in `your_game_folder/garrysmod/addons`, if it exists.
1. Extract `beatrun-main` into `your_game_folder/garrysmod/addons`.
   - (Optional) For Discord and Steam Presence, move the contents of `beatrun-main/lua/bin` to your `your_game_folder/garrysmod/lua/bin` (create the folder if it doesn't exists).
1. Start the game.
1. Select the `Beatrun` gamemode in the bottom-right corner.

---

## Features and Updates

> [!NOTE]
> There are plenty of changes and fixes that are not documented here. If you are interested - feel free to read the commits.

### New UI

- The whole interface was rewritten to Beatrun's style, with 3 themes to choose from in F4 → Settings.
- **Settings menu** with every Beatrun setting, both client and server. Open it from the context menu (`C`), from F4 → Settings or with `beatrun_settings`.\
  The Tools menu category is gone.
- HUD and keystrokes hide when a big window is open.
- Keystrokes show the real key state and have a walk key now.
- New scoreboard.
- Localization in **9 languages**.

### Courses Database

- **[courses.jbro.top](https://courses.jbro.top)** - website with every uploaded course, previews, leaderboards and player profiles (**[source code](https://github.com/JonnyBro/beatrun-courses-server)**).
- Press F4 in game to browse courses, load them by code or upload yours.
- Your times are sent to the leaderboards automatically when you finish a course, just set your key in F4 → Profile.
- You can update your course without changing its code, from the game or from the website. Its leaderboard gets wiped though.
- Saving a course over an old local file of it, so you don't end up with 20 copies.

### Build Mode

- New interface with a props palette, search and hints for the keys you can press right now. Press `H` to see all of them.
- Grid snapping (`N`), undo and redo (`CTRL+Z` / `CTRL+Y`).
- Any model by its path, and props from the Spawn Menu are saved in your course too.
- **Vehicles and NPCs** in courses. NPCs spawn with AI off, `I` toggles it.
- Checkpoints work in vehicles, and respawning on a checkpoint puts you back in your vehicle.

### Gamemodes

- **Deathmatch** gamemode.
- New event menu (F2).
- Loadouts editor with a proper weapon picker and a blacklist for random loadouts.
- Random loadouts from **MW Base**, **ARC9**, **ARCCW**, **TFA** or from any weapon you have.

### ULX

If you have ULX, there are commands for most things: `!loadcourse`, `!stopcourse`, `!restart`, `!tpcp`, `!tolastcp`, `!invalidaterun`, `!buildperm`, `!gamemode`, `!manager`, `!suspend`, `!setlevel`, `!addxp`, `!resetlevel` and `!br` for server settings.

### Other

- "Proper" Kick Glitch similar to the **[original game](https://www.youtube.com/watch?v=zK5y3NBUStc)**.
- Race your Ghost: a ghost of your best time in the current course.
- Serverside levels on dedicated servers, local ones in singleplayer and P2P.
- Various new/fixed abilities:
  - **Roll after ziplines:** Press `+duck` (CTRL by default).
  - **Dismount ladders:** Press `+duck` (CTRL by default).
  - **Remove ziplines created with Zipline Gun:** Press `+attack2` (RMB by default).
  - **Wall brace:** stand against a wall with your hand.
  - **Arrow to the next checkpoint** for easier navigation.
- Small camera punch effect when diving.
- SteamID no longer displayed on your screen.

### Fixes

- Fixed playermodels showing as `ERROR` in first person.
- Fixed crashes and issues with Data Theft gamemode.
- Fixed an exploit in Infection with player names, and infecting doesn't depend on the nametags setting anymore.
- Fixed random loadouts freezing the server when there aren't enough weapons.
- Fixed the online courses tab not warning you about a different map.
- A lot of animation fixes.
- Improved leaderboard sorting in gamemodes.
- Enabled jumping while walking.
- Grapple now follows moving entities and visible to other players.
- Removed a bunch of unused files, the addon is a little smaller now.

---

## Animations

You can change animations in the **Settings menu** under Gameplay.

---

## Known Issues

- See the full list of issues **[here](https://github.com/JonnyBro/beatrun/issues)**.

---

## Related Projects

- **[Beatrun Reanimated Project](https://github.com/JonnyBro/beatrun-anims)**
- **[Beatrun Courses Database](https://github.com/JonnyBro/beatrun-courses-server)**

---

## Credits

- **[All contributors](https://github.com/JonnyBro/beatrun/graphs/contributors)** ❤️
- [EarthyKiller127/datae](https://www.youtube.com/channel/UCiFqPwGo4x0J65xafIaECDQ) - Original creator of Beatrun.
- relaxtakenotes - Made this project possible.
- [MTB](https://www.youtube.com/@MTB396) - Beatrun Reanimated Project.
- [Fluffy Servers](https://github.com/fluffy-servers/gmod-discord-rpc) - Discord Rich Presence.
- [YuRaNnNzZZ](https://github.com/YuRaNnNzZZ/gmcl_steamrichpresencer) - Steam Presence.
- [\[aka\]bomb's FOV Remap](https://steamcommunity.com/sharedfiles/filedetails/?id=2831115438) - CalcView fix (camera under map).

### Fonts

> [!NOTE]
> They could be wrong, I tried to find the original sources.

- [x14y24pxHeadUpDaisy](https://hicchicc.github.io/00ff/)
- [Datto D-DIN](https://github.com/amcchord/datto-d-din)

## Star History

<!-- markdownlint-disable MD033 -->
<a href="https://star-history.dera.page/#JonnyBro/beatrun">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://star-history.dera.page/svg?repos=JonnyBro/beatrun&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://star-history.dera.page/svg?repos=JonnyBro/beatrun" />
   <img alt="Star History Chart" src="https://star-history.dera.page/svg?repos=JonnyBro/beatrun" />
 </picture>
</a>
