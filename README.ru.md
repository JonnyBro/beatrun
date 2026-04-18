# Beatrun | Community Edition

[![forthebadge](https://forthebadge.com/badges/60-percent-of-the-time-works-every-time.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/badges/as-seen-on-tv.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/badges/contains-tasty-spaghetti-code.svg)](https://forthebadge.com)

[**Присоединяйтесь к нашему сообществу в Discord!**](https://discord.gg/93Psubbgsg)

> *[English | Английский](./README.md)*

---

## О проекте

Beatrun - это **небезызвестный паркур режим для Garry's Mod**, теперь с полностью открытым исходным кодом и поддерживаемый сообществом.
Включает различные улучшения, новые функции и расширенную функциональность.

> [!WARNING]
> Этот репозиторий содержит **опциональные** модули для показа статусов в Discord и Steam.\
> Эти модули не обязательны для работы аддона.
>
> Модули находятся **[здесь](https://github.com/JonnyBro/beatrun/tree/main/lua/bin)**.\
> Вы можете найти их исходный код в разделе **[благодарностей](#благодарности)**.

---

## Установка

### Steam Workshop

> [!WARNING]
> Не забудьте удалить старый Beatrun из папки `garrysmod/addons`!

1. [Подписаться на аддон](https://steamcommunity.com/sharedfiles/filedetails/?id=3467179024).
1. Запустить игру.
1. Выбрать режим `Beatrun` в правом нижнем углу в меню.

### Установка вручную

1. **[Скачать репозиторий](https://github.com/JonnyBro/beatrun/archive/refs/heads/master.zip).**
1. Удалить старую папку `beatrun` в `папка_игры/garrysmod/addons`, если она существует.
1. Извлечь `beatrun-main` в `папка_игры/garrysmod/addons`.
   - (По желанию) Для статусов в Discord и Steam, скопировать содержимое `beatrun-main/lua/bin` в `папка_игры/garrysmod/lua/bin`, создать папку если не существует.
1. Запустить игру.
1. Выбрать режим `Beatrun` в правом нижнем углу в меню.

---

## Особенности и обновления

> [!NOTE]
> Здесь выписаны не все исправления и функции. Если Вам интересно - читайте коммиты.

### Новые возможности

- **Внутриигровой список курсов**.
  - Открывается нажатием F4 (**[исходный код базы](https://github.com/JonnyBro/beatrun-courses-server)**).
  - Стандартную хостит @JonnyBro.
- **Новый режим Deathmatch**.
- Новый Kick Glitch, как в **[оригинальной игре](https://www.youtube.com/watch?v=zK5y3NBUStc)**.
- Меню настроек **в игре** в категории **Beatrun** в меню Инструментов. Здесь можно настроить **все** параметры Beatrun.
- Поддержка локализации на **8 языках**.
- Интерфейсы для создания наборов оружия и чёрного списка.
- Серверные и одиночные/P2P уровни.
- Улучшенный режим строительства курсов: пропы из меню спавна сохраняются в вашем курсе.
- Случайные наборы оружия из модов **MW Base**, **ARC9**, **ARCCW** и **TFA**. Либо создавайте свои собственные в файле [!Helpers.lua](./gamemodes/beatrun/gamemode/sh/!Helpers.lua#L8)!
- Гонка с призраком: в курсах появится призрак вашего лучшего времени в текущем курсе.
- Новые/починеные способности:
  - **Перекат после зиплайнов:** Нажать `+duck` (CTRL по умолчанию)..
  - **Слезание с лестниц:** Нажать `+duck` (CTRL по умолчанию)..
  - **Удаление зиплайнов:** Нажать `+attack2` (RMB по умолчанию).
  - **Указатель следующего чекпоинта** для облегчения навигации.
- Новые серверные и клиентские переменные:
  - Серверные:
    - `Beatrun_AllowOverdriveInMultiplayer` - разрешает Overdrive в мультиплеере.
    - `Beatrun_AllowPropSpawn` - разрешает спавн пропов и оружия без прав администратора.
    - `Beatrun_HealthRegen` - переключает регенерацию здоровья.
  - Клиентские:
    - `Beatrun_HUDTextColor`, `Beatrun_HUDCornerColor`, `Beatrun_HUDFloatingXPColor` - настройка цветов интерфейса.
    - `Beatrun_DisableGrapple` - включение/выключение крюка-кошки.
    - `Beatrun_KickGlitch` - переключение между старым и новым Kick Glitch.
    - `Beatrun_QuickturnHandsOnly` - ограничение QuickTurn только для оружия Runner Hands.
- Прочие улучшения:
  - Небольшой толчок камеры при нырянии.
  - SteamID больше не отображается на экране.

### Исправления

- Исправлено отображение моделей игроков как `ERROR` от первого лица.
- Улучшена сортировка таблиц лидеров в режимах.
- Исправлены краши и баги в режиме Data Theft.
- Включены прыжки при ходьбе.
- Крюк-кошка теперь следует за перемещаемыми объектами и видна другим игрокам.

---

## Анимации

Установщик анимаций удалён. Теперь их можно переключать в **меню Инструментов** в категории Beatrun.

---

## Известные проблемы

- Полный список доступен **[здесь](https://github.com/JonnyBro/beatrun/issues)**.

---

## Связанные проекты

- **[Beatrun Reanimated Project](https://github.com/JonnyBro/beatrun-anims)**

---

## Благодарности

- **[Все участники](https://github.com/JonnyBro/beatrun/graphs/contributors)** ❤️
- [EarthyKiller127/datae](https://www.youtube.com/channel/UCiFqPwGo4x0J65xafIaECDQ) - создатель оригинального Beatrun.
- relaxtakenotes - этот проект стал возможен благодаря ему.
- [MTB](https://www.youtube.com/@MTB396) - проект Beatrun Reanimated.
- [Fluffy Servers](https://github.com/fluffy-servers/gmod-discord-rpc) - модуль показа статусов в Discord.
- [YuRaNnNzZZ](https://github.com/YuRaNnNzZZ/gmcl_steamrichpresencer) - модуль показа статусов в Steam (создатель TFA Base).

### Шрифты

> [!NOTE]
> Могут быть ошибочными, я старался найти оригиналы.

- [x14y24pxHeadUpDaisy](https://hicchicc.github.io/00ff/)
- [Datto D-DIN](https://github.com/amcchord/datto-d-din)

## Звёздочки

<!-- markdownlint-disable MD033 -->
<a href="https://www.star-history.com/#JonnyBro/beatrun&type=date&legend=top-left">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=JonnyBro/beatrun&type=date&theme=dark&legend=top-left" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=JonnyBro/beatrun&type=date&legend=top-left" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=JonnyBro/beatrun&type=date&legend=top-left" />
 </picture>
</a>
