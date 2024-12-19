# Beatrun | Community Edition

[![Powered by Electricity](https://forthebadge.com/images/featured/featured-powered-by-electricity.svg)](https://forthebadge.com)
[![Powered by Black Magic](https://forthebadge.com/images/badges/powered-by-black-magic.svg)](https://forthebadge.com)

[**Присоединяйтесь к нашему сообществу в Discord!**](https://discord.gg/93Psubbgsg)

> *[English | Английский](./README.md)*

---

## 🚨 Важное уведомление

### Пожалуйста, прочитайте этот README полностью перед тем, как задавать вопросы

### **Единственный официальный источник** этого форка — этот репозиторий на GitHub. Версии в Workshop устарели и не поддерживаются

---

## О проекте

Beatrun — это **знаменитый паркур-аддон для Garry's Mod**, теперь с полностью открытым исходным кодом и поддерживаемый сообществом.
Включает различные улучшения, новые функции и расширенную функциональность.

> [!WARNING]
> **В этом репозитории нет вредоносных модулей.** Однако доступны опциональные модули, такие как показ статусов в Discord и Steam, для дополнительного функционала.
> Эти модули **абсолютно опциональны** и могут быть удалены в любое время.
>
> - Модули находятся **[здесь](https://github.com/JonnyBro/beatrun/tree/main/lua/bin)**.
> - Ознакомьтесь с разделом **[Благодарности](#благодарности)** для их исходного кода.

---

## Установка

### 🔧 Автоматическая установка (Рекомендуется для Windows 10/11)

> [!NOTE]
> Windows 7 и старые версии Windows 10 не поддерживаются. Обновите свою ОС.

Запустите данную команду в PowerShell (Запустите от админа если Steam и/или игра установлены на системный (C:) диск):

```powershell
irm https://beatrun.jonnybro.ru/install | iex
```

1. Запустите игру.
2. Выберите режим `Beatrun` в правом нижнем углу.

### 🛠️ Ручная установка

1. **[Скачать репозиторий](https://github.com/JonnyBro/beatrun/archive/refs/heads/master.zip)**.
2. Удалите папку `beatrun` в `путь_к_игре/garrysmod/addons`, если она существует.
3. Извлеките `beatrun-main/beatrun` в `путь_к_игре/garrysmod/addons`.
4. *(Опционально)* Для показа статусов в Discord и Steam извлеките `beatrun-main/lua` в `путь_к_игре/garrysmod`.
5. Запустите игру.
6. Выберите режим `Beatrun` в правом нижнем углу.

---

## Особенности и обновления

### Новые возможности

- **База курсов** от Jonny_Bro: **[Доступна здесь](https://courses.jonnybro.ru)** (бесплатна и имеет **[открытый исходный код](https://git.jonnybro.ru/jonny_bro/beatrun-courses-server)**).
- **Новый режим:** Deathmatch.
- Полностью исправленный Kick Glitch, как в **[оригинальной игре](https://www.youtube.com/watch?v=zK5y3NBUStc)**.
- Меню настроек в игре в категории **Beatrun** в меню Инструментов.
  Здесь можно настроить **все** параметры Beatrun.
- Поддержка локализации на **7 языках**.
- Улучшенный режим строительства курсов:
  Пропы из меню спавна сохраняются в вашем курсе.
- Новые способности:
  - **Перекат после зиплайнов:** Нажмите `CTRL`.
  - **Слезание с лестниц:** Нажмите `CTRL`.
  - **Удаление зиплайнов:** Нажмите ПКМ (`RMB`).
  - **Указатель следующего чекпоинта** для облегчения навигации.
- Новые серверные и клиентские переменные:
  - Серверные:
    - `Beatrun_AllowOverdriveInMultiplayer` — разрешает Overdrive в мультиплеере.
    - `Beatrun_AllowPropSpawn` — разрешает спавн пропов и оружия без прав администратора.
    - `Beatrun_HealthRegen` — переключает регенерацию здоровья.
  - Клиентские:
    - `Beatrun_HUDTextColor`, `Beatrun_HUDCornerColor`, `Beatrun_HUDFloatingXPColor` — настройка цветов интерфейса.
    - `Beatrun_DisableGrapple` — включение/выключение крюка-кошки.
    - `Beatrun_OldKickGlitch` — переключение между старым и новым Kick Glitch.
    - `Beatrun_QuickturnHandsOnly` — ограничение QuickTurn только для оружия Runner Hands.
- Прочие улучшения:
  - Лёгкий толчок камеры при нырянии.
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
- [EarthyKiller127/datae](https://www.youtube.com/channel/UCiFqPwGo4x0J65xafIaECDQ) — создатель оригинального Beatrun.
- [relaxtakenotes](https://github.com/relaxtakenotes) — этот проект стал возможен благодаря ему.
- [MTB](https://www.youtube.com/@MTB396) — проект Beatrun Reanimated.
- [Fluffy Servers](https://github.com/fluffy-servers/gmod-discord-rpc) — модуль показа статусов в Discord.
- [YuRaNnNzZZ](https://github.com/YuRaNnNzZZ/gmcl_steamrichpresencer) — модуль показа статусов в Steam (создатель TFA Base).
