# MoroElite

UI-библиотека для Roblox-скриптов. Окно с вкладками и подвкладками, секции в две колонки, обычный набор элементов, конфиги и вкладка настроек, которую не надо писать самому.

`Lumina.lua` в этом репозитории старый, его больше не обновляю. Новые скрипты пишите на `MoroElite.lua`.

## Подключение

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Morozhka144/GUI2222/main/MoroElite.lua"))()
```

Нужны `writefile` / `readfile` (для конфигов и настроек) и `getcustomasset` (для звуков, картинок и логотипа). Без них меню работает, просто без этих частей.

## Окно

```lua
local Window = Library:CreateWindow({
    Title = "Moro Hub",
    Subtitle = "Doors",
    ToggleKey = Enum.KeyCode.RightShift,
})
```

| Параметр | По умолчанию | Что делает |
|---|---|---|
| `Title` | `"MoroElite"` | Название в сайдбаре |
| `Subtitle` | версия библиотеки | Строка под названием |
| `ToggleKey` | `RightShift` | Клавиша открытия меню |
| `Logo` | логотип MoroElite | `false` вместо него ставит первую букву названия, `"rbxassetid://..."` ставит свою картинку |
| `OpenControl` | `"Bar"` | Как открыть меню без клавиатуры: `"Bar"`, `"Button"` или `"Off"` |
| `TopButtons` | нет | Доп. кнопки сверху: `{ "bell", "key", "settings", "user" }` |
| `Art`, `MenuArt` | картинки из репозитория | `false` отключает картинки персонажей |
| `TeleportFile` | `"Doors.lua"` | Файл, который запускается после смены сервера |
| `TeleportDelay` | `5` | Сколько секунд ждать перед этим запуском |

Окно двигается за верхнюю часть сайдбара и растягивается за края. На телефоне по умолчанию оно меньше и масштаб 75%.

## Вкладки и колонки

```lua
Window:AddTabLabel("Main")                       -- подпись над группой вкладок
local Main = Window:CreateTab({ Name = "Player", Icon = "user" })
local Left, Right = Main:Column("left"), Main:Column("right")
```

Иконки берутся по имени из [Lucide](https://lucide.dev/icons/) или `rbxassetid://...`.

Подвкладки показываются рядом кнопок вверху страницы, у каждой свои две колонки. Ряд не прокручивается вместе со страницей. Если подвкладок много и они не влезают, ряд листается вбок.

```lua
local Visuals = Window:CreateTab({ Name = "Visuals", Icon = "eye" })
local esp = Visuals:SubTab({ Name = "ESP", Icon = "eye" })
local skins = Visuals:SubTab({ Name = "Skin Changer", Icon = "shirt" })
local sec = esp:Column("left"):CreateSection({ Name = "ESP" })
```

После первой подвкладки обычные колонки вкладки скрываются, так что всё кладите в подвкладки.

## Секции

```lua
local Movement = Left:CreateSection({ Name = "Movement", Icon = "footprints", Collapsible = true })
Movement:SetCollapsed(true)
```

Сворачиваются кликом по заголовку, если `Collapsible = true`.

## Элементы

У любого элемента можно указать `Tooltip` (подсказка при наведении) и `Description` (серая строка под названием).

```lua
local speed = Movement:AddToggle({ Name = "Speed", Default = false, Callback = function(on) end })
speed:AddKeybind({ Default = Enum.KeyCode.X, Mode = "Toggle" })  -- клавиша прямо в строке тоггла
speed:AddColorPicker({ Default = Color3.fromRGB(0, 255, 140) })   -- цвет прямо в строке тоггла

Movement:AddSlider({ Name = "Walk Speed", Min = 16, Max = 100, Default = 32, Decimals = 0, Suffix = " st", Callback = print })
Movement:AddDropdown({ Name = "Mode", Options = { "Legit", "Rage" }, Default = "Legit", Callback = print })
Movement:AddMultiDropdown({ Name = "Targets", Options = { "Rush", "Ambush", "Seek" }, Max = 2, Callback = print })
Movement:AddTextbox({ Name = "Player", Placeholder = "ник...", Callback = print })
Movement:AddKeybind({ Name = "Panic", Default = Enum.KeyCode.P, Mode = "Hold", Callback = print })
Movement:AddColorPicker({ Name = "ESP Color", Default = Color3.fromRGB(255, 80, 100) })
Movement:AddButton({ Name = "Teleport", Primary = true, Callback = function() end })
Movement:AddLabel("Обычный текст")
Movement:AddDivider()
Movement:AddStat({ Name = "Ping", Interval = 0.5, Get = function() return "42 ms" end })
Movement:AddCharacterPreview({ Height = 240 })
```

У элементов есть `Set`, `Get`, у списков ещё `Refresh(options, keepSelection)`, у мульти-списка `SelectAll`, `ClearAll`, `IsSelected`.

Режимы кейбинда: `Toggle`, `Hold`, `Always`. Правый клик по клавише меняет режим. Все назначенные клавиши видны в Keybind List.

## Уведомления

```lua
Window:Notify({ Title = "Готово", Text = "Скрипт загружен", Type = "success", Duration = 4 })
```

`Type`: `info`, `success`, `warning`, `error`. Прошлые уведомления открываются кнопкой с колокольчиком, если она добавлена в `TopButtons`.

## Вкладки Settings и Customization

```lua
Window:AddSettingsTab()
```

Добавляет три вкладки: Settings, Customization и Configs.

- **Settings.** Масштаб, клавиша меню, способ открытия на телефоне, Fast Menu, Keybind List, автозапуск после телепорта, Anti-AFK, Anti-Lag, Server Hop, Rejoin, звуки уведомлений.
- **Customization.** Тема, акцент (пресеты, свой цвет, радуга, градиент), шрифт, прозрачность и скругление окна, размер текста, ширина и сторона сайдбара, картинка на фоне окна, анимации, эффекты на экране (сакура, снег, дождь, звёзды, светлячки, угольки, пузыри), музыка, картинки персонажей в углу экрана и над меню.

Эти настройки общие для всех скриптов на MoroElite. Они хранятся в `MoroLumina/Settings.json` и сохраняются сами при каждом изменении. Туда же пишется место, где стоят Fast Menu и Keybind List.

## Fast Menu и Keybind List

Fast Menu: маленькая панель с выбранными тогглами и кнопками, работает при закрытом меню. Что в ней показывать, выбирается в Settings.

Keybind List: список назначенных клавиш и того, включены ли они.

```lua
local fm = Window:GetFastMenu()
fm:SetVisible(true)
fm:SetToggles({ "Speed" })
fm:SetButtons({ "Server Hop" })

local kl = Window:GetKeybindList()
kl:SetVisible(true)
kl:SetLocked(true)
```

## Конфиги

Каждый элемент попадает в конфиг по своему `Name`, флаги указывать не нужно. Исключить элемент: `NoConfig = true`. Конфиги лежат в `MoroLumina/Configs/<PlaceId>`, отдельно для каждой игры. Вкладка Configs умеет создать, загрузить, перезаписать, удалить конфиг, поставить его на автозагрузку и обменяться конфигом строкой через буфер.

```lua
Library:SaveConfig("main")
Library:LoadConfig("main")
Library:SetAutoLoad("main")

local code = Library:ExportConfig()
Library:ImportConfig(code)

-- своё значение без элемента в меню
Library:RegisterFunction("MyValue", function() return myValue end, function(v) myValue = v end)
```

В конфиг скрипта идут его собственные элементы, содержимое и масштаб Fast Menu, Keybind List и настройки телепорта. Внешний вид меню в конфиг не идёт, он общий (см. выше).

## Картинки, звуки, музыка

Берутся из папок `Art/`, `MenuArt/`, `Sounds/`, `Music/` и `Logo/` этого репозитория и кешируются в `MoroLumina/`. Если положить в `Art/` или `MenuArt/` новый PNG, он появится в списке сам, править скрипт не надо. Изменённые на GitHub файлы перекачиваются при следующем запуске.

## Шпаргалка

```lua
-- Window
Window:CreateTab(cfg)       Window:AddTabLabel(text)     Window:SelectTab(tab)
Window:AddSettingsTab()     Window:Notify(cfg)           Window:Toggle(open)
Window:IsOpen()             Window:Minimize()            Window:SetSize(w, h, animate)
Window:SetToggleKey(key)    Window:SetOpenControl(mode)  Window:SetTopButton(name, callback, icon)
Window:SetTheme(name)       Window:SetEffect(name)       Window:SetArt(name)
Window:GetFastMenu()        Window:GetKeybindList()

-- Tab
Tab:Column("left" / "right")   Tab:CreateSection(cfg)   Tab:SubTab(cfg)   Tab:GetSubTab(name)

-- Section
AddButton  AddToggle  AddSlider  AddDropdown  AddMultiDropdown  AddTextbox
AddKeybind  AddColorPicker  AddLabel  AddDivider  AddStat  AddCharacterPreview

-- Library
Library:SetAccent(color)   Library:SetFont(name)   Library:SetAnimationSpeed(k)
Library:SaveConfig(name)   Library:LoadConfig(name)   Library:GetConfigs()
Library:SetAutoLoad(name)  Library:ExportConfig()     Library:ImportConfig(code)
Library:RegisterFunction(name, getter, setter)        Library:Unload()
```

Полный пример: [MoroElite.Example.lua](MoroElite.Example.lua).
