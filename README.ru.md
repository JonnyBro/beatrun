# Beatrun | Community Edition

[![forthebadge](https://forthebadge.com/badges/60-percent-of-the-time-works-every-time.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/badges/as-seen-on-tv.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/badges/contains-tasty-spaghetti-code.svg)](https://forthebadge.com)

[**Присоединяйтесь к нашему сообществу в Discord!**](https://discord.gg/93Psubbgsg)

> *[English | Английский](./README.md)*

---

## О проекте

Beatrun - это **небезызвестный паркур режим для Garry's Mod**, теперь с полностью открытым исходным кодом и поддерживаемый сообществом.

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

1. **[Скачать репозиторий](https://github.com/JonnyBro/beatrun/archive/refs/heads/main.zip).**
1. Удалить старую папку `beatrun` в `папка_игры/garrysmod/addons`, если она существует.
1. Извлечь `beatrun-main` в `папка_игры/garrysmod/addons`.
   - (По желанию) Для статусов в Discord и Steam, скопировать содержимое `beatrun-main/lua/bin` в `папка_игры/garrysmod/lua/bin`, создать папку если не существует.
1. Запустить игру.
1. Выбрать режим `Beatrun` в правом нижнем углу в меню.

---

## Особенности и обновления

> [!NOTE]
> Здесь выписаны не все исправления и функции. Если Вам интересно - читайте коммиты.

### Новый интерфейс

- Весь интерфейс переписан под стиль режима, на выбор 3 темы в F4 → Настройки.
- **Меню настроек** со всеми настройками Beatrun, и клиентскими, и серверными. Открывается из контекстного меню (`C`), из F4 → Настройки или командой `beatrun_settings`.\
  Категории в меню Инструментов больше нет.
- HUD и клавиши прячутся, когда открыто большое окно.
- Клавиши показывают реальное нажатие и теперь есть клавиша ходьбы.
- Новая таблица игроков.
- Локализация на **9 языках**.

### База курсов

- **[courses.jbro.top](https://courses.jbro.top)** - сайт со всеми загруженными курсами, превью, таблицами рекордов и профилями игроков (**[исходный код](https://github.com/JonnyBro/beatrun-courses-server)**).
- В игре по F4 можно смотреть курсы, загружать их по коду или выкладывать свои.
- Время после прохождения курса само отправляется в таблицу рекордов, просто укажите ключ в F4 → Профиль.
- Свой курс можно обновить без смены кода, из игры или с сайта. Таблица рекордов при этом очищается.
- Сохранение курса поверх его старого локального файла, чтобы не копилось 20 копий.

### Режим строительства

- Новый интерфейс с палитрой пропов, поиском и подсказками по клавишам, которые можно нажать прямо сейчас. Все клавиши по `H`.
- Привязка к сетке (`N`), отмена и повтор (`CTRL+Z` / `CTRL+Y`).
- Любая модель по пути, а пропы из меню спавна тоже сохраняются в курсе.
- **Транспорт и NPC** в курсах. NPC появляются с выключенным ИИ, `I` его переключает.
- Чекпоинты работают в транспорте, а респавн на чекпоинте возвращает обратно в машину.

### Режимы

- Режимы **Deathmatch**, **Data Theft** и **Infection**.
- Новое меню ивентов (F2).
- Редактор снаряжений с нормальным выбором оружия и чёрный список для случайных снаряжений.
- Случайные снаряжения из **MW Base**, **ARC9**, **ARCCW**, **TFA** или из любого оружия, что у вас есть.

### ULX

Если стоит ULX, есть команды почти на всё: `!loadcourse`, `!stopcourse`, `!restart`, `!tpcp`, `!tolastcp`, `!invalidaterun`, `!buildperm`, `!gamemode`, `!manager`, `!suspend`, `!setlevel`, `!addxp`, `!resetlevel` и `!br` для серверных настроек.

### Прочее

- Новый Kick Glitch, как в **[оригинальной игре](https://www.youtube.com/watch?v=zK5y3NBUStc)**.
- Гонка с призраком: в курсах появится призрак вашего лучшего времени в текущем курсе.
- Серверные уровни на выделенных серверах, локальные в одиночке и P2P.
- Новые/починеные способности:
  - **Перекат после зиплайнов:** Нажать `+duck` (CTRL по умолчанию).
  - **Слезание с лестниц:** Нажать `+duck` (CTRL по умолчанию).
  - **Удаление зиплайнов:** Нажать `+attack2` (RMB по умолчанию).
  - **Упор рукой в стену.**
  - **Указатель следующего чекпоинта** для облегчения навигации.
- Небольшой толчок камеры при нырянии.
- SteamID больше не отображается на экране.

### Исправления

- Исправлено отображение моделей игроков как `ERROR` от первого лица.
- Исправлены краши и баги в режиме Data Theft.
- Исправлен эксплойт в Infection с никами игроков, и заражение больше не зависит от настройки ников.
- Случайные снаряжения больше не вешают сервер, когда оружия не хватает.
- Вкладка онлайн курсов теперь предупреждает о другой карте.
- Куча фиксов анимаций.
- Улучшена сортировка таблиц лидеров в режимах.
- Включены прыжки при ходьбе.
- Крюк-кошка теперь следует за перемещаемыми объектами и видна другим игрокам.
- Удалена куча неиспользуемых файлов, аддон стал меньше.

---

## Анимации

Анимации переключаются в **меню настроек** во вкладке Геймплей.

---

## Известные проблемы

- Полный список доступен **[здесь](https://github.com/JonnyBro/beatrun/issues)**.

---

## Связанные проекты

- **[Beatrun Reanimated Project](https://github.com/JonnyBro/beatrun-anims)**
- **[База курсов Beatrun](https://github.com/JonnyBro/beatrun-courses-server)**

---

## Благодарности

- **[Все участники](https://github.com/JonnyBro/beatrun/graphs/contributors)** ❤️
- [EarthyKiller127/datae](https://www.youtube.com/channel/UCiFqPwGo4x0J65xafIaECDQ) - создатель оригинального Beatrun.
- relaxtakenotes - этот проект стал возможен благодаря ему.
- [MTB](https://www.youtube.com/@MTB396) - проект Beatrun Reanimated.
- [Fluffy Servers](https://github.com/fluffy-servers/gmod-discord-rpc) - модуль показа статусов в Discord.
- [YuRaNnNzZZ](https://github.com/YuRaNnNzZZ/gmcl_steamrichpresencer) - модуль показа статусов в Steam (создатель TFA Base).
- [\[aka\]bomb's FOV Remap](https://steamcommunity.com/sharedfiles/filedetails/?id=2831115438) - Фикс CalcView (камеры под землёй).
- scubamaster96 - Задники.

### Шрифты

> [!NOTE]
> Могут быть ошибочными, я старался найти оригиналы.

- [x14y24pxHeadUpDaisy](https://hicchicc.github.io/00ff/)
- [Datto D-DIN](https://github.com/amcchord/datto-d-din)

## Звёздочки

<!-- markdownlint-disable MD033 -->
<a href="https://star-history.dera.page/#JonnyBro/beatrun">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://star-history.dera.page/svg?repos=JonnyBro/beatrun&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://star-history.dera.page/svg?repos=JonnyBro/beatrun" />
   <img alt="Star History Chart" src="https://star-history.dera.page/svg?repos=JonnyBro/beatrun" />
 </picture>
</a>
