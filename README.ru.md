# Beatrun | Community edition

[![forthebadge](https://forthebadge.com/images/featured/featured-powered-by-electricity.svg)](https://forthebadge.com)
[![forthebadge](https://forthebadge.com/images/badges/powered-by-black-magic.svg)](https://forthebadge.com)

[Нажмите чтобы присоедениться к нашему Discord серверу!](https://discord.gg/93Psubbgsg)

* [English](./README.md)

**ПОЖАЛУЙСТА, ПРОЧИТАЙТЕ ВЕСЬ ДОКУМЕНТ ПЕРЕД ТЕМ КАК ЗАДАВАТЬ ВОПРОСЫ!**

Печально известный паркур аддон для Garry's Mod. Теперь, с полностью открытым исходным кодом и поддерживаемый сообществом (мной 😞).

> [!IMPORTANT]
> Данный репозиторий не содержит вредоносных модулей. Однако, мы имеем несколько модулей для дополнительного функционала:
>
> * Модуль для показа статуса в Discord.
> * Модуль для показа статуса в Steam.
>
> **Они не обязательны и могут быть удалены в любой момент.**\
> Список всех модуйлей находится **[здесь](https://github.com/JonnyBro/beatrun/tree/main/lua/bin)**.\
> Проверьте **[Благодарности](#благодарности)** чтобы найти их исходный код.

## Автоматическая установка (Рекомендуется | Windows 10/11)

> [!WARNING]
> Windows 7 и старые сборки Windows 10 не поддерживаются.
> Обновитесь, пожалуйста.

Запустите команду ниже в Powershell (запустите от администратора если Steam или игра расположены на диске C:).
> [!NOTE]
> Win + R > `powershell` > *Enter*

```powershell
irm https://beatrun.jonnybro.ru/install | iex
```

* Запустить игру.
* Выбрать режим `Beatrun` в правом нижнем углу.

## Ручная установка

1. **[Скачать репозиторий](https://github.com/JonnyBro/beatrun/archive/refs/heads/master.zip)**.
1. **Удалить папку `beatrun` в *путь_к_игре/garrysmod/addons*, если у вас такова имеется.**
1. Извлечь папку `beatrun-main/beatrun` в *путь_к_игре/garrysmod/addons*.
1. Если вы хотите показ статуса в Discord и Steam:
   * Извлечь папку `beatrun-main/lua` в *путь_к_игре/garrysmod*.
1. Запустить игру.
1. Выбрать режим `Beatrun` в правом нижнем углу.

## Анимации

Установщик анимаций был удалён, теперь анимации можно переключить в меню Инструментов в категории Beatrun.

## Отличия от оригинала

> [!IMPORTANT]
> Множество изменений не задокументированы, проверьте коммиты для полного списка изменений.

* Jonny_Bro поддерживает свою **[базу курсов](https://courses.jonnybro.ru)**, которая так же **бесплатна** для использования и имеет **[открытый исходный код](https://git.jonnybro.ru/jonny_bro/beatrun-courses-server-docker)**!
* Новый режим - **Deathmatch** (намного интереснее Data Theft, честно).
* Оригинальный Kick Glitch как в **[оригинальной игре](https://www.youtube.com/watch?v=zK5y3NBUStc)**.
* Внутриигровое меню настроек - оно находится в меню Инструментов в категории **Beatrun**.\
  Там можно найти **все** настройки Beatrun!
* Показ статуса в Discord и Steam.
* Поддержка локализации.\
  Доступно на 7 языках!
* Изменения в режиме строительства курсов.\
  Любой проп из меню спавна теперь сохраняется в курсе.
* Возможность переката на кнопку приседания (CTRL) после зиплайнов (спасибо c4nk <3).
* Возможность спрыгивать с лестниц на кнопку приседания (CTRL).
* Возможность удалять зиплайны, созданные *Zipline Gun* по нажатию на второстепенный огонь (ПКМ).
* Стрелка, указывающая на следующий чекпоинт.
* Серверная переменная которая разрешает использование Overdrive в мультиплеере - `Beatrun_AllowOverdriveInMultiplayer`.
* Серверная переменная которая разрешает создание оружия и объектов из меню спавна без прав администратора - `Beatrun_AllowPropSpawn`.
* Серверная переменная которая переключает регенерацию здоровья - `Beatrun_HealthRegen`.
* Клиентские переменные для изменения цвета интерфейса - `Beatrun_HUDTextColor`, `Beatrun_HUDCornerColor`, `Beatrun_HUDFloatingXPColor`.
* Клиентская переменная которая переключает использование крюка-кошки - `Beatrun_DisableGrapple`.
* Клиентская переменная которая переключает использование старого и нового Kick Glitch - `Beatrun_OldKickGlitch`.
* Клиентская переменная которая переключает быстрый разворот с оружием или только с *Runner Hands* - `Beatrun_QuickturnHandsOnly`.
* Небольшой толчок камеры при нырянии.
* SteamID больше не видно на экране.

## Исправления

* Некоторые модельки игрока отображались как ERROR от первого лица.
* Сортировка таблиц лидеров в режимах.
* Использование крюка-кошки в режимах и курсах.
* Краш игры в режиме Data Theft при использовании Data Bank.
* Урон между игроками проходил только в Data Theft.
* Разрешены прыжки при ходьбе.
* Возможность переката **под** объектами.
* Крюк-кошка теперь следует за объектом к которому она присоединена, так же её видят другие игроки.

## Известные проблемы

* [Проблемы](https://github.com/JonnyBro/beatrun/issues).

## Связанные проекты

* [Проект Beatrun Reanimated](https://github.com/JonnyBro/beatrun-anims).

## Благодарности

* [Все участники](https://github.com/JonnyBro/beatrun/graphs/contributors) - <3.
* [EarthyKiller127/datae](https://www.youtube.com/channel/UCiFqPwGo4x0J65xafIaECDQ) - Создатель оригинального Beatrun.
* [relaxtakenotes](https://github.com/relaxtakenotes) - Без него этот проект не существовал бы.
* [MTB](https://www.youtube.com/@MTB396) - Проект Beatrun Reanimated.
* [Fluffy Servers](https://github.com/fluffy-servers/gmod-discord-rpc) - Модуль показа статусов в Discord.
* [YuRaNnNzZZ](https://github.com/YuRaNnNzZZ/gmcl_steamrichpresencer) - Модуль показа статусов в Steam (создатель TFA Base!).
