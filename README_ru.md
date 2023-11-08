# Beatrun | Версия от сообщества

* [English](./README.md)

Печально известный паркур-аддон для Garry's Mod, с полностью открытым исходным кодом и поддерживаемый сообществом (мной 😞).

> [!IMPORTANT]
> У нас вы не найдёте вредоносного кода, модулей или сетевого кода! У нас есть модули и сетевой код, который используется для:
>
> * Discord Rich Presence.
> * Steam Presence.
> * Пользовательская онлайн база курсов.
>
> **Всё это необязательно и может быть удалено.**\
> Модули находятся [тут](https://github.com/JonnyBro/beatrun/tree/main/lua/bin) и функционал онлайн базы курсов доступен [здесь](https://github.com/JonnyBro/beatrun/blob/main/beatrun/gamemodes/beatrun/gamemode/cl/CoursesDatabase.lua).\
> Исходный код модулей можно найти в [благодарностях](#благодарности).

**ПОЖАЛУЙСТА, ПРОЧТИТЕ ВЕСЬ ДОКУМЕНТ ПЕРЕД ТЕМ КАК ЗАДАВАТЬ ВОПРОСЫ НА НАШЕМ СЕРВЕРЕ!**

## Автоматическая установка (Рекомендуемое | только для Windows)

Запустите команду ниже в Powershell.
> [!NOTE]
> Win + R > `powershell`

```powershell
iex (iwr "rlxx.ru/beatrun" -UseBasicParsing)
```

## Ручная установка

1. Скачайте данный репозиторий по данной [ссылке](https://github.com/JonnyBro/beatrun/archive/refs/heads/master.zip).
2. **Удалите старую папку `beatrun` по пути *путь_к_игре/garrysmod/addons* если она у вас имеется.**
3. Извлеките папку `beatrun-main/beatrun` по пути *путь_к_игре/garrysmod/addons*.
4. Извлеките папку `beatrun-main/lua` по пути *путь_к_игре/garrysmod*.

## Анимации

Пожалуйста, обратитесь к данному [README](beatrun/README.md).

## Изменения

> [!IMPORTANT]
> Множество изменений и исправлений не задокументированы, обратитесь к списку коммитов для более подробного списка изменений.

* Jonny_Bro держит [пользовательскую онлайн базу курсов](https://courses.beatrun.ru), которая так же бесплатна и имеет [открытый исходный код](https://github.com/relaxtakenotes/beatrun-courses-server/) 🤯!
* Реализован новый режим - **Deathmatch** (намного веселее чем Data Theft, честно).
* Реализован "правильный" Kick Glitch прямо как в [оригинальной ME](https://www.youtube.com/watch?v=zK5y3NBUStc).
* Добавлено меню настроек в игре - его можно найти в списке инструментов, в категории *Beatrun*.\
Вам доступны **все** настройки Beatrun из данного меню.
* Поддержка локализации.\
На данный момент доступны Русский и Английский языки.
* Добавлена возможность слезания с лестниц.
* Добавлена стрелка указывающая на следующую контрольную точку.
* Добавлена переменная которая разрешает использование Overdrive на сервере - `Beatrun_AllowOverdriveInMultiplayer`.
* Добавлена переменная которая позволяет переключится между старым и новым Kick Glitch - `Beatrun_OldKickGlitch`.
* Добавлено несколько переменных позволяющих настроить цвета HUD - `Beatrun_HUDTextColor`, `Beatrun_HUDCornerColor`, `Beatrun_HUDFloatingXPColor`.
* Добавлена переменная которая разрешает игрокам без админ прав создавать пропы и оружие - `Beatrun_AllowPropSpawn`.
* Добавлена переменная которая позволяет переключить работу крюка-кошки - `Beatrun_DisableGrapple`.
* Добавлена переменная которая позволяет переключить использование Quickturn только с *Runner Hands* или с любым оружием - `Beatrun_QuickturnHandsOnly`.
* Добавлен небольшой толчёк камеры при нырянии.
* Добавлена возможность удаления зиплайнов созданных *Zipline Gun* - `ПКМ`.
* Реализована поддержка Discord Rich Presence используя модуль с [открытым исходным кодом](#благодарности).

## Исправления

* Ваш SteamID больше не показывается в углу экрана.
* Исправлено отображение некоторых моделей игрока как ERROR.
* Сделано несколько изменений в меню выбора курсов (F4).
* Разрешены прыжки во время ходьбы (🤷).
* Исправлена сортировка в таблице лидеров.
* Исправлено использование крюка-кошки в режимах и курсах.
* Исправлен краш при соприкосновении с Data Bank в Data Theft.
* Исправлена ошибка загрузки курсов.
* Исправлены ошибки коллизий. (PvP урон не проходил нигде, кроме Data Theft)
* Изменён кувырок, теперь можно кувыркаться под объектами.
* Изменена крюк-кошка. Теперь вы движетесь вместе с объектом к которому она прицеплена и её видят другие игроки.
* Теперь можно нырнуть до смерти =).

## TODO

* [ ] Меню выбора снаряжения для Data Theft и Deathmatch (не знаю пока как это реализовать).

## Может быть полезно

* [Beatrun Reanimated Project](https://github.com/JonnyBro/beatrun-anims).

## Благодарности

* [Все участники](https://github.com/JonnyBro/beatrun/graphs/contributors) - <3.
* [EarthyKiller127](https://www.youtube.com/channel/UCiFqPwGo4x0J65xafIaECDQ) - Создатель этого куска дерьма.
* [relaxtakenotes](https://github.com/relaxtakenotes) - Если бы не он, этого проекта бы не существовало.
* [MTB](https://www.youtube.com/@MTB396) - Создатель Beatrun Reanimated Project.
* [Discord Rich Presence](https://github.com/fluffy-servers/gmod-discord-rpc) от Fluffy Servers.
* [Steam Presence](https://github.com/YuRaNnNzZZ/gmcl_steamrichpresencer) от YuRaNnNzZZ.
