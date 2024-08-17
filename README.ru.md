# Beatrun | Community edition

[![forthebadge](https://forthebadge.com/images/featured/featured-powered-by-electricity.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/powered-by-black-magic.svg)](https://forthebadge.com)

[Нажми чтобы присоединиться к нашему Discord серверу!](https://discord.gg/93Psubbgsg)

* [English](./README.md)

**ПОЖАЛУЙСТА, ПРОЧИТАЙТЕ ЭТОТ ФАЙЛ ПЕРЕД ТЕМ КАК ЗАДАВАТЬ ВОПРОСЫ!**\
**МЫ ОПИСАЛИ ДОСТАТОЧНО, ЧТОБЫ ВЫ МОГЛИ УСТАНОВИТЬ ЭТОТ МОД САМОСТОЯТЕЛЬНО**

Печально известный паркур мод для Garry's Mod.\
Мод с открытым исходным кодом и поддерживаемый сообществом (мной 😞).

> [!IMPORTANT]
> Данный проект не содержит вредоносных модулей. Здесь присутствуют модули для доп. функций, таких как:
>
> * Показ статуса в Discord.
> * Показ статуса в Steam.
>
> **Данные модули опциональны и могут быть удалены в любой момент.**\
> Все модули можно найти **[здесь](https://github.com/JonnyBro/beatrun/tree/main/lua/bin)**.\
> Проверьте **[Благодарности](#благодарности)** чтобы найти исходный код модулей.

## Автоматическая установка (Рекомендуемое | Windows 10/11)

> [!WARNING]
> Windows 7 не поддерживается.\
> Кому-то давно пора обновиться...

Запустите команду в Powershell.
> [!NOTE]
> Win + R > `powershell` > *Enter*

```powershell
irm https://beatrun.jonnybro.ru/install | iex
```

* Выберите режим `Beatrun` в правом нижнем углу.

## Ручная установка

1. **[Скачайте проект](https://github.com/JonnyBro/beatrun/archive/refs/heads/master.zip)**.
2. **Удалите папку `beatrun` по пути *путь_к_игре/garrysmod/addons* если присутствует.**
3. Извлеките папку `beatrun-main/beatrun` по пути *путь_к_игре/garrysmod/addons*.
4. Если вы хотите показ статусов в Discord и Steam:
   * Извлеките папку `beatrun-main/lua` по пути *путь_к_игре/garrysmod*.
5. Выберите режим `Beatrun` в правом нижнем углу.

## Анимации

[Читаем тут](beatrun/README.md)

## Особенности

> [!IMPORTANT]
> Множество изменений и исправлений не задокументированы, обратитесь к списку коммитов для более подробного списка изменений.

* Jonny_Bro поддерживает **[свою базу курсов](https://courses.jonnybro.ru)**, которая так же **бесплатна** к использованию и имеет **[открытый исходный код](https://git.jonnybro.ru/jonny_bro/beatrun-courses-server-express)**!
* Новый режим - **Deathmatch** (намного веселее чем Data Theft, честно).
* "Правильный" Kick Glitch прямо как в **[оригинальной игре](https://www.youtube.com/watch?v=zK5y3NBUStc)**.
* Меню настроек - найти его можно в меню инструментов, в категории **Beatrun**.\
  **Все** настройки Beatrun можно найти там!
* Показ статусов в Steam и Discord.
* Поддержка локализаций.\
  Доступно 7 языков!
* Улучшения режима строительства.
  Можно заспавнить любой проп из меню спавна и он сохранится в курсе.
* Возможность переката после зиплайнов на CTRL 🤯 (спасибо c4nk <3).
* Возможность спрыгивать с лестниц - Нажмите CTRL.
* Возможность удалять зиплайны созданные *Zipline Gun* - Нажмите ПКМ.
* Стрелка, показывающая местоположение след. контрольной точки.
* Переменная, разрешающая использование Overdrive (сервер) - `Beatrun_AllowOverdriveInMultiplayer`.
* Переменная, разрешающая создание объектов без прав администратора (сервер) - `Beatrun_AllowPropSpawn`.
* Переменная, переключающая регенерацию здоровья (сервер) - `Beatrun_HealthRegen`.
* Переменные, изменяющие цвет HUD (клиент) - `Beatrun_HUDTextColor`, `Beatrun_HUDCornerColor`, `Beatrun_HUDFloatingXPColor`.
* Переменная, переключающая использование крюка-кошки (клиент) - `Beatrun_DisableGrapple`.
* Переменная, переключающая режим Kick Glitch (клиент) - `Beatrun_OldKickGlitch`.
* Переменная, переключающая использование Quickturn только с *Runner Hands* или любым оружием (клиент) - `Beatrun_QuickturnHandsOnly`.
* Небольшой толчёк камеры при нырянии.
* Убран SteamID с экрана.

## Исправления

* Отображение моделей как **ERROR**.
* Сортировка таблицы лидеров.
* Использование крюка-кошки в режимах.
* Краш в Data Theft при касании с Data Bank.
* Ошибки с коллиизей - урон в PvP не проходил, если режим не Data Theft.
* Возможность прыгать во время ходьбы (🤷).
* Подправлен кувырок - можно кувыркаться под объектами.
* Подправлена крюк-кошка - движется с объектом к которому прикреплена и видна другим игрокам.

## TODO

* [ ] Меню создания снаряжений для Deathmatch/Data Theft.

## Известные проблемы

* [Тут](https://github.com/JonnyBro/beatrun/issues).
* Может ещё чего, я не помню 💀.

## Связанные проекты

* [Beatrun Reanimated Project](https://github.com/JonnyBro/beatrun-anims).

## Благодарности

* [Все участники](https://github.com/JonnyBro/beatrun/graphs/contributors) - <3.
* [EarthyKiller127](https://www.youtube.com/channel/UCiFqPwGo4x0J65xafIaECDQ) - Создатель этого ужаса.
* [relaxtakenotes](https://github.com/relaxtakenotes) - Без него этого проекта бы не существовало.
* [MTB](https://www.youtube.com/@MTB396) - Beatrun Reanimated Project.
* [Fluffy Servers](https://github.com/fluffy-servers/gmod-discord-rpc) - Discord Rich Presence.
* [YuRaNnNzZZ](https://github.com/YuRaNnNzZZ/gmcl_steamrichpresencer) - Steam Presence.
