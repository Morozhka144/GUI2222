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
- 🗂️ Сворачиваемые секции (Collapsible Sections) с плавной анимацией
- 📎 Суб-элементы к тогглам (`AddColorPicker` и `AddKeybind` в одной строке)
- ⌨️ Кейбинды с режимами (`Toggle`, `Hold`, `Always`) и экранным оверлеем (Keybind List HUD)
- ⚡ Fast Menu — быстрое экранное меню для избранных функций
- 🧩 Множество элементов (тоглы, слайдеры, дропдауны и др.)
- 💾 Автоматическая система конфигов (по имени элементов или функциям)
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
    ToggleKey = Enum.KeyCode.RightShift, -- по умолчанию RightShift (R Shift)
})
```

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `Title` | string | `"MOROLUMINA.lua"` | Текст в верхней панели окна |
| `ToggleKey` | KeyCode / UserInputType / string | `Enum.KeyCode.RightShift` | Клавиша открытия/закрытия меню на ПК |

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

## 🗂️ Секции (Collapsible Sections)

Секции поддерживают сворачивание/разворачивание по клику на заголовок с плавной анимацией шеврона.

```lua
local Section = Tab:CreateSection({
    Name = "Combat",
    Collapsible = true,      -- можно ли сворачивать (по умолчанию true)
    Collapsed = false,       -- начальное состояние (по умолчанию false)
    Flag = "Combat_Section", -- (опционально) сохранение состояния в конфиг
    Callback = function(isCollapsed)
        print("Секция свернута:", isCollapsed)
    end,
})

-- Программное управление
Section:SetCollapsed(true)   -- свернуть
Section:SetCollapsed(false)  -- развернуть
print(Section:IsCollapsed()) -- проверка состояния (boolean)
```

| Параметр | Тип | По умолчанию | Описание |
|----------|-----|--------------|----------|
| `Name` | string | `"Section"` | Заголовок секции |
| `Collapsible` | boolean | `true` | Доступность сворачивания при клике |
| `Collapsed` | boolean | `false` | Начальное состояние секции (свернута/развернута) |
| `Flag` | string | `nil` | Ключ для сохранения состояния в конфиг |
| `Callback` | function | `nil` | Вызывается при сворачивании/разворачивании `function(isCollapsed)` |

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

### 🎚️ Toggle & 📎 Суб-элементы

Тогглы поддерживают прикрепление компактных **суб-элементов прямо в строку тоггла** (ColorPicker и Keybind)!

```lua
local toggle = Section:AddToggle({
    Name = "Player ESP",
    Icon = "eye",
    Default = false,
    Callback = function(value)
        print("ESP:", value)
    end,
})

-- Суб-элемент: ColorPicker (компактный цветной квадрат рядом с переключателем)
local colorPicker = toggle:AddColorPicker({
    Default = Color3.fromRGB(0, 255, 134),
    Callback = function(color)
        print("ESP Color:", color)
    end,
})

-- Суб-элемент: Keybind (клавиша управления этим тогглом прямо в строке)
local keybind = toggle:AddKeybind({
    Default = Enum.KeyCode.E,
    Mode = "Toggle", -- "Toggle" (переключение), "Hold" (зажатие), "Always" (всегда активен)
})
```

> 💡 **Особенности суб-элементов:**
> - Кейбинд в тоггле автоматически включает/выключает родительский тоггл согласно выбранному режиму.
> - **ПКМ (правый клик)** по кнопке кейбинда циклически меняет режим: `Toggle` ➔ `Hold` ➔ `Always`.
> - Все привязанные кейбинды автоматически попадают в экранный оверлей **Keybind List HUD**.

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

Полноценные кейбинды с поддержкой режимов работы (`Toggle`, `Hold`, `Always`) и интеграцией в экранный оверлей:

```lua
local kb = Section:AddKeybind({
    Name = "Fly",
    Default = Enum.KeyCode.F,
    Mode = "Toggle", -- "Toggle" (переключение), "Hold" (зажатие), "Always" (всегда активен)
    Callback = function(active)
        print("Fly состояние:", active)
    end,
    ChangedCallback = function(newKey)
        print("Новая клавиша:", newKey.Name)
    end,
    ModeCallback = function(newMode)
        print("Новый режим:", newMode)
    end,
})

-- Программное управление
kb.Set(Enum.KeyCode.G)
kb.SetMode("Hold")
print(kb.Get(), kb.GetMode(), kb.GetActive())
```

> 🖱️ **Быстрое переключение режима:**
> - **ЛКМ** по кнопке — назначение новой клавиши (`...`).
> - **ПКМ (правый клик)** по кнопке — циклическая смена режима (`Toggle` ➔ `Hold` ➔ `Always`).
> - Все настроенные кейбинды автоматически попадают в экранный оверлей **Keybind List HUD**!

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
- ⚡ **Fast Menu** — плавающее мини-меню с выбранными тогглами
- ⌨️ **Keybind List** — плавающий экранный оверлей активных кейбиндов
- 💾 **Configuration** — система конфигов

---

## ⚡ Fast Menu (Быстрое меню)

Плавающий виджет на экране, позволяющий быстро включать и выключать выбранные функции без необходимости каждый раз открывать основное меню.

- 🔘 **Выбор функций**: через множественный выбор (`Select Functions`) выбираются только нужные пользователю функции (тогглы).
- 🖱️ **Перемещение**: зажав заголовок мини-меню, его можно перетащить в любую точку экрана.
- 🔒 **Фиксация (Lock Position)**: переключатель для закрепления меню на экране, предотвращающий случайные сдвиги во время игры.
- 🔍 **Масштаб (Menu Scale)**: регулировка размера оверлея от 50% до 150%.
- 🔄 **Мгновенная синхронизация**: переключение тоггла в Fast Menu сразу обновляет элемент в основном меню, запускает Callback и наоборот.

---

## ⌨️ Keybind List HUD (Экранный оверлей кейбиндов)

Стильный плавающий оверлей в духе премиум чит-меню (Neverlose / Gamesense), отображающий все привязанные клавиши, их текущий режим и статус активности:

- 📋 **Список клавиш**: отображает имя функции, назначенную клавишу и режим (`[T]` для Toggle, `[H]` для Hold, `[A]` для Always).
- 💡 **Индикация активности**: когда функция активна или клавиша зажата, строка и бейдж подсвечиваются ярким акцентным цветом.
- 🖱️ **Перетаскивание и блокировка**: оверлей можно свободно двигать по экрану и блокировать позицию (`Lock Position`).
- 🔍 **Масштабирование**: настройка размера (`HUD Scale`) от 50% до 150%.
- 💻 **API**:
  ```lua
  local kbHud = Window:GetKeybindList()
  kbHud.SetVisible(true)    -- показать/скрыть
  kbHud.SetLocked(true)     -- закрепить
  kbHud.SetScale(1.2)       -- масштаб
  kbHud.Refresh()           -- принудительное обновление
  ```

---

## 💾 Система конфигов

> Требуются файловые функции исполнителя (`writefile`, `readfile`)

Все функции и элементы интерфейса (`AddToggle`, `AddSlider`, `AddDropdown` и т.д.) сохраняются в конфиг **автоматически по их названию (`Name`)** — указывать флаги больше не требуется!

```lua
-- Управление файлами конфигов
Library:SaveConfig("my_config")
Library:LoadConfig("my_config")
Library:DeleteConfig("my_config")
Library:GetConfigs()

Library:SetAutoLoad("my_config")
Library:GetAutoLoad()
Library:ClearAutoLoad()

-- Программная работа с таблицей конфига
local configData = Library:GetConfig()   -- получить текущее состояние всех функций
Library:ApplyConfig(configData)          -- применить настройки из таблицы

-- Регистрация любой кастомной функции в конфиг (без UI элемента)
Library:RegisterFunction("CustomFeature", function()
    return myVariable                    -- getter
end, function(value)
    myVariable = value                   -- setter
end)
```

> 💡 **Флаги больше не нужны!** Элементы автоматически сохраняются и восстанавливаются по имени `Name`. Если нужно исключить элемент из конфига, укажи `NoConfig = true`. (Параметр `Flag` по-прежнему поддерживается для обратной совместимости).

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
local Visuals = Main:CreateSection({ Name = "Visuals", Collapsible = true })

local esp = Visuals:AddToggle({
    Name = "ESP",
    Default = true,
})

-- Добавляем суб-элементы к тогглу ESP:
esp:AddColorPicker({
    Default = Color3.fromRGB(0, 255, 134),
    Callback = function(col) print("ESP Color:", col) end,
})

esp:AddKeybind({
    Default = Enum.KeyCode.X,
    Mode = "Toggle", -- ПКМ для переключения Toggle / Hold / Always
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
Нажми клавишу **Right Shift** (по умолчанию для ПК), нажми плавающую кнопку **OPEN** (для мобильных/ПК) или переназначь клавишу в Settings → Menu Toggle.

**Работает ли курсор мыши в играх от первого лица (Doors и др.)?**
Да! Библиотека автоматически разблокирует и отображает курсор мыши при открытии меню, отключая вращение камеры, а при закрытии меню управление возвращается игре.

**Почему не сохраняется конфиг?**
Убедись, что исполнитель поддерживает `writefile` / `readfile`. Все функции теперь сохраняются автоматически по имени (`Name`)!

**Как сменить режим кейбинда?**
Нажми **ПКМ (правой кнопкой мыши)** по кнопке кейбинда, чтобы переключить режим между `Toggle`, `Hold` и `Always`.

**Можно ли сворачивать секции?**
Да! Просто кликни по заголовку любой секции.

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
Window:IsOpen()
Window:SetToggleKey(Enum.KeyCode.RightShift)
Window:GetToggleKey()
Window:GetFastMenu()
Window:GetKeybindList()

-- Tab
Tab:Column("left"/"right")
Tab:CreateSection({...})

-- Section
Section:SetCollapsed(bool)
Section:IsCollapsed()
Section:AddButton({...})
Section:AddLabel(text)
Section:AddToggle({...})
Section:AddSlider({...})
Section:AddDropdown({...})
Section:AddMultiDropdown({...})
Section:AddTextbox({...})
Section:AddKeybind({...})
Section:AddColorPicker({...})

-- Toggle Sub-elements
local cp = toggle:AddColorPicker({...})
local kb = toggle:AddKeybind({...})

-- Keybind Object
kb.Set(Enum.KeyCode.F)
kb.SetMode("Hold")
kb.Get()
kb.GetMode()
kb.GetActive()

-- Library
Library:SaveConfig(name)
Library:LoadConfig(name)
Library:DeleteConfig(name)
Library:GetConfigs()
Library:SetAutoLoad(name)
Library:GetConfig()
Library:ApplyConfig(data)
Library:RegisterFunction(name, getter, setter)
```

---

<div align="center">

Made with ❤️ for the Roblox scripting community

</div>
