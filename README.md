<div align="center">

# ✨ MoroLumina UI

**Современная, лёгкая и красивая UI-библиотека для Roblox**

</div>

---

## 📖 О библиотеке

**MoroLumina UI** — это гибкая библиотека интерфейсов для Roblox-скриптов. Поддерживает вкладки, секции, множество элементов, систему конфигов, кастомизацию акцентов и плавную анимацию.

### ✨ Возможности
- 🪟 Перетаскиваемое окно с изменяемым размером
- 📂 Вкладки с иконками (поддержка [Lucide](https://lucide.dev/icons/))
- 🧩 Множество элементов (тоглы, слайдеры, дропдауны и др.)
- 💾 Система сохранения конфигов
- 🎨 20 пресетов акцентного цвета
- 🔧 Настройка масштаба интерфейса
- 🔔 Красивые уведомления

---

## 📦 Загрузка

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Morozhka144/GUI2222/refs/heads/main/Lumina.lua)"))()
```

---

## 🪟 Создание окна

```lua
local Window = Library:CreateWindow({
    Title = "MOROLUMINA.lua",
})
```

| Параметр | Тип | Описание |
|----------|-----|----------|
| `Title` | string | Текст в верхней панели окна |

---

## 📂 Вкладки

```lua
local Tab = Window:CreateTab({
    Name = "Main",
    Icon = "home",
})
```

| Параметр | Тип | Описание |
|----------|-----|----------|
| `Name` | string | Подпись вкладки |
| `Icon` | string | Имя [Lucide](https://lucide.dev/icons/)-иконки или `rbxassetid://...` |

### Колонки
Каждая вкладка делится на левую и правую колонки:

```lua
Tab:Column("left")   -- по умолчанию
Tab:Column("right")
```

---

## 🗂️ Секции

```lua
local Section = Tab:CreateSection({
    Name = "Combat",
})
```

---

## 🧩 Элементы

> Все элементы создаются внутри секции: `Section:AddХХХ({...})`

### 🔘 Button
```lua
Section:AddButton({
    Name = "Click me",
    Primary = false,   -- true = акцентная кнопка
    Callback = function()
        print("нажали!")
    end,
})
```

### 🏷️ Label
```lua
local lbl = Section:AddLabel("Просто текст")
lbl.Set("Новый текст")
```

### 🎚️ Toggle
```lua
Section:AddToggle({
    Name = "Enable ESP",
    Icon = "eye",
    Default = false,
    Flag = "ESP_Enabled",
    Callback = function(value)
        print("ESP:", value)
    end,
})
```

### 🎛️ Slider
```lua
Section:AddSlider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Decimals = 0,
    Suffix = " studs",
    Flag = "WalkSpeed",
    Callback = function(value)
        print("Speed:", value)
    end,
})
```

### 📋 Dropdown
```lua
local drop = Section:AddDropdown({
    Name = "Mode",
    Options = {"Easy", "Normal", "Hard"},
    Default = "Normal",
    Flag = "GameMode",
    Callback = function(option)
        print("Выбрано:", option)
    end,
})

drop.Set("Hard")
drop.Get()
drop.Refresh({"A","B","C"})        -- сброс выбора
drop.Refresh({"A","B","C"}, true)  -- сохранить выбор
```

### ☑️ MultiDropdown
```lua
local multi = Section:AddMultiDropdown({
    Name = "Items",
    Options = {"Sword","Shield","Potion","Bow"},
    Default = {"Sword"},
    Max = 3,
    Placeholder = "None",
    Flag = "SelectedItems",
    Callback = function(selectedList, changedOption, isSelected)
        print(table.concat(selectedList, ", "))
    end,
})

multi.Get()
multi.Set({"Bow"})
multi.SelectAll()
multi.ClearAll()
multi.IsSelected("Bow")
multi.Refresh(newList, keepSelection)
```

### ⌨️ Textbox
```lua
local box = Section:AddTextbox({
    Name = "Player Name",
    Placeholder = "Enter name...",
    Default = "",
    Numeric = false,
    Flag = "TargetName",
    Callback = function(text, enterPressed)
        print("Ввели:", text)
    end,
})

box.Set("Hello")
box.Get()
```

### 🎹 Keybind
```lua
Section:AddKeybind({
    Name = "Fly Toggle",
    Default = Enum.KeyCode.F,
    Flag = "FlyKey",
    Callback = function()
        print("клавиша нажата!")
    end,
    ChangedCallback = function(newKey)
        print("новая клавиша:", newKey.Name)
    end,
})
```

### 🎨 ColorPicker
```lua
Section:AddColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Flag = "ESPColor",
    Callback = function(color)
        print("Цвет:", color)
    end,
})
```

---

## 🔔 Уведомления

```lua
Window:Notify({
    Title = "Привет!",
    Content = "Это уведомление",
    Type = "Success",   -- "Info" / "Success" / "Warning" / "Error"
    Duration = 4,
})
```

---

## ⚙️ Встроенная вкладка настроек

```lua
Window:AddSettingsTab()
```

Включает:
- 🔧 **UI Scale** — масштаб интерфейса
- ⌨️ **Menu Toggle** — клавиша открытия меню
- 🎨 **Accent Color** — цвет акцента (20 пресетов)
- 💾 **Configuration** — система конфигов

---

## 💾 Система конфигов

> Требуются файловые функции исполнителя (`writefile`, `readfile`)

```lua
Library:SaveConfig("my_config")
Library:LoadConfig("my_config")
Library:DeleteConfig("my_config")
Library:GetConfigs()

Library:SetAutoLoad("my_config")
Library:GetAutoLoad()
Library:ClearAutoLoad()
```

> ⚠️ Чтобы элемент сохранялся — обязательно укажи `Flag`!

---

## 🧱 Полный пример

```lua
local Library = loadstring(game:HttpGet("ССЫЛКА"))()

local Window = Library:CreateWindow({ Title = "MyHub.lua" })
local Main = Window:CreateTab({ Name = "Main", Icon = "home" })

-- Левая колонка
Main:Column("left")
local Combat = Main:CreateSection({ Name = "Combat" })

Combat:AddToggle({
    Name = "Aimbot",
    Default = false,
    Flag = "Aimbot",
    Callback = function(v) print("Aimbot:", v) end,
})

Combat:AddSlider({
    Name = "FOV",
    Min = 0, Max = 500, Default = 100,
    Flag = "FOV",
    Callback = function(v) print("FOV:", v) end,
})

-- Правая колонка
Main:Column("right")
local Visuals = Main:CreateSection({ Name = "Visuals" })

Visuals:AddToggle({
    Name = "ESP",
    Default = true,
    Flag = "ESP",
})

Visuals:AddColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(0, 255, 0),
    Flag = "ESPColor",
})

Window:AddSettingsTab()

Window:Notify({
    Title = "Загружено!",
    Content = "MyHub успешно запущен",
    Type = "Success",
})
```

---

## ❓ FAQ

**Как открыть/закрыть меню?**
Нажми кнопку **OPEN** или назначь клавишу в Settings → Menu Toggle.

**Почему не сохраняется конфиг?**
Убедись, что у элемента есть `Flag`, и что исполнитель поддерживает `writefile`.

**Можно ли менять размер окна?**
Да — тяни за края окна.

**Можно ли двигать окно?**
Да — тяни за верхнюю панель.

**Какие иконки доступны?**
Любые из [Lucide](https://lucide.dev/icons/) — просто укажи имя.

---

## 📌 Шпаргалка по методам

```lua
-- Window
Window:CreateTab({...})
Window:Notify({...})
Window:AddSettingsTab()
Window:Toggle(true/false)

-- Tab
Tab:Column("left"/"right")
Tab:CreateSection({...})

-- Section
Section:AddButton({...})
Section:AddLabel(text)
Section:AddToggle({...})
Section:AddSlider({...})
Section:AddDropdown({...})
Section:AddMultiDropdown({...})
Section:AddTextbox({...})
Section:AddKeybind({...})
Section:AddColorPicker({...})

-- Library
Library:SaveConfig(name)
Library:LoadConfig(name)
Library:DeleteConfig(name)
Library:GetConfigs()
Library:SetAutoLoad(name)
```

---

<div align="center">

Made with ❤️ for the Roblox scripting community

⭐ Поставь звезду, если библиотека была полезна!

</div>
```

Готово! 🎉

Просто замени:
- `ССЫЛКА_НА_СКРИПТ` / `ССЫЛКА` — на реальный raw-линк твоего скрипта
- `MoroLumina UI` — на название твоей либы, если оно другое
- ссылку в бейдже `License` — если у тебя другая лицензия

Хочешь, добавлю секцию **«Установка через GitHub raw»** с готовой ссылкой или **скриншоты/GIF** интерфейса?
