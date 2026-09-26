--[[
███╗   ███╗ ██████╗ ██████╗  ██████╗ ██╗     ██╗   ██╗███╗   ███╗██╗███╗   ██╗ █████╗
████╗ ████║██╔═══██╗██╔══██╗██╔═══██╗██║     ██║   ██║████╗ ████║██║████╗  ██║██╔══██╗
██╔████╔██║██║   ██║██████╔╝██║   ██║██║     ██║   ██║██╔████╔██║██║██╔██╗ ██║███████║
██║╚██╔╝██║██║   ██║██╔══██╗██║   ██║██║     ██║   ██║██║╚██╔╝██║██║██║╚██╗██║██╔══██║
██║ ╚═╝ ██║╚██████╔╝██║  ██║╚██████╔╝███████╗╚██████╔╝██║ ╚═╝ ██║██║██║ ╚████║██║  ██║
╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚═╝╚═╝  ╚═══╝╚═╝  ╚═╝
                       MoroLumina UI Framework  v2.0  (Emerald Edition)
--]]

--===================================================================================--
--                                   SERVICES                                          --
--===================================================================================--
local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local HttpService       = game:GetService("HttpService")
local TeleportService   = game:GetService("TeleportService")
local CoreGui           = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

--===================================================================================--
--                                   LUCIDE ICONS                                      --
--===================================================================================--
local Lucide
do
    local LUCIDE_URL = "https://raw.githubusercontent.com/Morozhka144/GUI2222/refs/heads/main/lucide-roblox.luau"

    local ok, mod = pcall(function()
        local src = game:HttpGet(LUCIDE_URL)
        return loadstring(src)()
    end)
    if ok and mod then
        Lucide = mod
    else
        warn("[MoroLumina] Lucide failed to load:", mod)
    end
end

--===================================================================================--
--                                   THEME                                             --
--===================================================================================--
local Theme = {
    Bg          = Color3.fromRGB(8, 8, 8),
    Bg2         = Color3.fromRGB(14, 15, 14),
    Header      = Color3.fromRGB(14, 15, 14),
    Section     = Color3.fromRGB(18, 20, 19),
    Element     = Color3.fromRGB(22, 24, 23),
    Stroke      = Color3.fromRGB(25, 30, 28),
    StrokeLight = Color3.fromRGB(40, 46, 43),
    Text        = Color3.fromRGB(235, 240, 238),
    SubText     = Color3.fromRGB(140, 148, 144),
    Accent      = Color3.fromRGB(0, 225, 134),
    AccentDim   = Color3.fromRGB(0, 120, 72),
    ToggleOff   = Color3.fromRGB(45, 48, 46),
    Font        = Enum.Font.Gotham,
    FontBold    = Enum.Font.GothamBold,
    FontMed     = Enum.Font.GothamMedium,
}

local PRESET_ACCENTS = {
    ["Emerald"]   = Color3.fromRGB(0, 225, 134),
    ["Cyan"]      = Color3.fromRGB(0, 200, 255),
    ["Purple"]    = Color3.fromRGB(170, 90, 255),
    ["Crimson"]   = Color3.fromRGB(255, 60, 80),
    ["Ocean"]     = Color3.fromRGB(40, 130, 255),
    ["Gold"]      = Color3.fromRGB(255, 200, 40),
    ["Orange"]    = Color3.fromRGB(255, 130, 30),
    ["Pink"]      = Color3.fromRGB(255, 90, 180),
    ["Magenta"]   = Color3.fromRGB(255, 50, 220),
    ["Lime"]      = Color3.fromRGB(160, 255, 60),
    ["Teal"]      = Color3.fromRGB(0, 200, 180),
    ["Rose"]      = Color3.fromRGB(255, 80, 120),
    ["Indigo"]    = Color3.fromRGB(110, 80, 255),
    ["Sky"]       = Color3.fromRGB(100, 200, 255),
    ["Ruby"]      = Color3.fromRGB(225, 30, 60),
    ["Mint"]      = Color3.fromRGB(80, 255, 190),
    ["Lavender"]  = Color3.fromRGB(180, 150, 255),
    ["Coral"]     = Color3.fromRGB(255, 110, 90),
    ["Snow"]      = Color3.fromRGB(240, 245, 245),
    ["Violet"]    = Color3.fromRGB(140, 60, 255),
}

--===================================================================================--
--                                   ICON HELPER                                       --
--===================================================================================--
local function resolveIcon(name)
    if not name or name == "" then return nil end
    -- уже готовый ассет — отдаём как есть
    if type(name) == "string" and (name:match("^rbxassetid://") or name:match("^rbxasset://") or name:match("^http")) then
        return name, nil, nil
    end
    -- ищем в lucide
    if Lucide then
        local ok, asset = pcall(function()
            return Lucide.GetAsset(tostring(name), 256)  -- 256px версия — чётче
        end)
        if ok and asset then
            return asset.Url, asset.ImageRectSize, asset.ImageRectOffset
        end
    end
    return nil
end

local function applyIcon(imageLabel, name)
    local url, rectSize, rectOffset = resolveIcon(name)
    if url then
        imageLabel.Image = url
        if rectSize and rectOffset then
            imageLabel.ImageRectSize = rectSize
            imageLabel.ImageRectOffset = rectOffset
        else
            imageLabel.ImageRectSize = Vector2.new(0, 0)
            imageLabel.ImageRectOffset = Vector2.new(0, 0)
        end
        imageLabel.Visible = true
        return true
    else
        imageLabel.Image = ""
        return false
    end
end

--===================================================================================--
--                                TWEEN PRESETS                                        --
--===================================================================================--
local TW = {
    Fast   = TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Slow   = TweenInfo.new(0.40, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
    Spring = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

--===================================================================================--
--                              HELPER FUNCTIONS                                       --
--===================================================================================--
local function create(class, props, children)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then obj[k] = v end
    end
    for _, c in ipairs(children or {}) do c.Parent = obj end
    if props and props.Parent then obj.Parent = props.Parent end
    return obj
end

local function corner(parent, rad)
    return create("UICorner", { CornerRadius = UDim.new(0, rad or 10), Parent = parent })
end

local function stroke(parent, color, thick, trans)
    return create("UIStroke", {
        Color = color or Theme.Stroke,
        Thickness = thick or 1,
        Transparency = trans or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function padding(parent, all, t, b, l, r)
    return create("UIPadding", {
        PaddingTop    = UDim.new(0, t or all or 0),
        PaddingBottom = UDim.new(0, b or all or 0),
        PaddingLeft   = UDim.new(0, l or all or 0),
        PaddingRight  = UDim.new(0, r or all or 0),
        Parent = parent,
    })
end

local function tween(obj, info, props)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- Tactile springy click effect
local function addClickEffect(button, scaleTarget)
    scaleTarget = scaleTarget or 0.93
    local uiScale = button:FindFirstChildOfClass("UIScale")
    if not uiScale then
        uiScale = create("UIScale", { Scale = 1, Parent = button })
    end
    button.MouseButton1Down:Connect(function()
        tween(uiScale, TW.Fast, { Scale = scaleTarget })
    end)
    button.MouseButton1Up:Connect(function()
        tween(uiScale, TW.Spring, { Scale = 1 })
    end)
    button.MouseLeave:Connect(function()
        tween(uiScale, TW.Fast, { Scale = 1 })
    end)
end

-- Ripple effect
local function ripple(button)
    button.ClipsDescendants = true
    button.MouseButton1Down:Connect(function(x, y)
        local r = create("Frame", {
            BackgroundColor3 = Theme.Accent,
            BackgroundTransparency = 0.7,
            Position = UDim2.fromOffset(x - button.AbsolutePosition.X, y - button.AbsolutePosition.Y),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Size = UDim2.fromOffset(0, 0),
            Parent = button,
        })
        corner(r, 999)
        local size = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
        tween(r, TW.Slow, { Size = UDim2.fromOffset(size, size), BackgroundTransparency = 1 })
        task.delay(0.4, function() r:Destroy() end)
    end)
end

--===================================================================================--
--                                  LIBRARY                                            --
--===================================================================================--
local Library = {}
Library.__index = Library
Library.AccentObjects = {}   -- objects that follow accent color
Library.AccentRepainters = {} -- callbacks invoked on accent change
Library.Flags = {}           -- central state table (compat with flags & element names)
Library.Functions = Library.Flags -- alias so functions can be accessed as Library.Functions
Library.Elements = Library.Flags  -- alias so elements can be accessed as Library.Elements
Library.ConfigRegistry = {}       -- canonical registry of all saved functions/elements
Library._isListeningKeybind = false -- true when any keybind button is awaiting key input

local function registerAccent(obj, prop)
    table.insert(Library.AccentObjects, { obj = obj, prop = prop })
    obj[prop] = Theme.Accent
end

local function onAccentChange(fn)
    table.insert(Library.AccentRepainters, fn)
end

local function setAccent(color)
    Theme.Accent = color
    for _, data in ipairs(Library.AccentObjects) do
        if data.obj and data.obj.Parent then
            tween(data.obj, TW.Fast, { [data.prop] = color })
        end
    end
    -- вызываем кастомные перекраски (дропдауны, мульти-дропдауны)
    for i = #Library.AccentRepainters, 1, -1 do
        local fn = Library.AccentRepainters[i]
        local ok = pcall(fn, color)
        if not ok then table.remove(Library.AccentRepainters, i) end
    end
end

--===================================================================================--
--                              CONFIG CORE                                            --
--===================================================================================--
local hasFS = (writefile and readfile and isfolder and makefolder and listfiles) ~= nil
local PLACE = tostring(game.PlaceId)
local ROOT  = "MoroLumina"
local CFG_DIR = ROOT .. "/Configs/" .. PLACE
local AUTO_FILE = CFG_DIR .. "/_autoload.txt"

if hasFS then
    pcall(function()
        if not isfolder(ROOT) then makefolder(ROOT) end
        if not isfolder(ROOT.."/Configs") then makefolder(ROOT.."/Configs") end
        if not isfolder(CFG_DIR) then makefolder(CFG_DIR) end
    end)
end

local function serialize(v)
    if typeof(v) == "Color3" then return {__t="c", v.R, v.G, v.B} end
    if typeof(v) == "EnumItem" then return {__t="e", tostring(v)} end
    if typeof(v) == "UDim2" then return {__t="u2", v.X.Scale, v.X.Offset, v.Y.Scale, v.Y.Offset} end
    if typeof(v) == "Vector2" then return {__t="v2", v.X, v.Y} end
    if type(v) == "table" then
        if v.__t then return v end
        local t = {}
        for k, sub in pairs(v) do
            t[k] = serialize(sub)
        end
        return t
    end
    return v
end
local function deserialize(v)
    if type(v) == "table" then
        if v.__t == "c" then return Color3.new(v[1], v[2], v[3]) end
        if v.__t == "e" then
            local parts = string.split(v[1], ".")
            local e = Enum
            for i = 2, #parts do e = e[parts[i]] end
            return e
        end
        if v.__t == "u2" then
            local x1 = tonumber(v[1] or v["1"]) or 0
            local x2 = tonumber(v[2] or v["2"]) or 0
            local y1 = tonumber(v[3] or v["3"]) or 0
            local y2 = tonumber(v[4] or v["4"]) or 0
            return UDim2.new(x1, x2, y1, y2)
        end
        if v.__t == "v2" then
            local x = tonumber(v[1] or v["1"]) or 0
            local y = tonumber(v[2] or v["2"]) or 0
            return Vector2.new(x, y)
        end
        local t = {}
        for k, sub in pairs(v) do
            t[k] = deserialize(sub)
        end
        return t
    end
    return v
end

-- Регистрация пользовательской функции или геттера/сеттера в систему конфигов
function Library:RegisterFunction(name, getter, setter)
    if not name or name == "" then return end
    local entry
    if type(getter) == "table" and (getter.Get or getter.Set) then
        entry = getter
    elseif type(getter) == "function" and type(setter) == "function" then
        entry = { Get = getter, Set = setter }
    elseif type(getter) == "function" and setter == nil then
        -- Единая функция: fn() -> get, fn(v) -> set
        entry = {
            Get = function() return getter() end,
            Set = function(v) return getter(v) end,
        }
    end
    if entry then
        entry.Name = name
        Library.ConfigRegistry[name] = entry
        Library.Flags[name] = entry
    end
    return entry
end
Library.RegisterConfig = Library.RegisterFunction

-- Получить все настройки в виде таблицы Lua
function Library:GetConfig()
    local out = {}
    local source = next(Library.ConfigRegistry) ~= nil and Library.ConfigRegistry or Library.Flags
    for key, obj in pairs(source) do
        if obj.Get then
            local ok, val = pcall(obj.Get)
            if ok and val ~= nil then
                out[key] = serialize(val)
            end
        end
    end
    return out
end

-- Применить настройки из таблицы Lua
function Library:ApplyConfig(data)
    if type(data) ~= "table" then return false end
    for key, val in pairs(data) do
        local obj = Library.ConfigRegistry[key] or Library.Flags[key]
        if obj and obj.Set then
            pcall(obj.Set, deserialize(val))
        end
    end
    return true
end

function Library:SaveConfig(name)
    if not hasFS or not name or name == "" then return false end
    local out = Library:GetConfig()
    return pcall(writefile, CFG_DIR.."/"..name..".json", HttpService:JSONEncode(out))
end

function Library:LoadConfig(name)
    if not hasFS or not name or name == "" then return false end
    local path = CFG_DIR.."/"..name..".json"
    if isfile and not isfile(path) then return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if ok and type(data) == "table" then
        return Library:ApplyConfig(data)
    end
    return false
end

function Library:DeleteConfig(name)
    if hasFS and delfile then pcall(delfile, CFG_DIR.."/"..name..".json") end
end

function Library:GetConfigs()
    local list = {}
    if hasFS then
        local ok, files = pcall(listfiles, CFG_DIR)
        if ok then
            for _, p in ipairs(files) do
                local n = p:match("([^/\\]+)%.json$")
                if n and not n:match("^_") then table.insert(list, n) end
            end
        end
    end
    return list
end

-- Автозагрузка: сохранить имя конфига для автозагрузки
function Library:SetAutoLoad(name)
    if not hasFS then return false end
    return pcall(writefile, AUTO_FILE, name)
end

function Library:GetAutoLoad()
    if not hasFS then return nil end
    if isfile(AUTO_FILE) then
        local ok, n = pcall(readfile, AUTO_FILE)
        if ok and n and n ~= "" then return n end
    end
    return nil
end

function Library:ClearAutoLoad()
    if hasFS and delfile and isfile(AUTO_FILE) then
        pcall(delfile, AUTO_FILE)
    end
end

--===================================================================================--
--                              CREATE WINDOW                                          --
--===================================================================================--
function Library:CreateWindow(cfg)
    cfg = cfg or {}
    local Window = {}
    Window._tabs = {}

    -- Default menu toggle key: RightShift (R Shift)
    local rawToggleKey = cfg.ToggleKey or cfg.Key or Enum.KeyCode.RightShift
    if type(rawToggleKey) == "string" then
        rawToggleKey = Enum.KeyCode[rawToggleKey] or Enum.UserInputType[rawToggleKey] or Enum.KeyCode.RightShift
    end
    Window._toggleKey = rawToggleKey

    function Window:SetToggleKey(key)
        if type(key) == "string" then
            key = Enum.KeyCode[key] or Enum.UserInputType[key]
        end
        if typeof(key) == "EnumItem" and (key.EnumType == Enum.KeyCode or key.EnumType == Enum.UserInputType) then
            Window._toggleKey = key
        end
    end

    function Window:GetToggleKey()
        return Window._toggleKey
    end

    -- Teleport / Execution state
    Window._executeOnTeleport = cfg.ExecuteOnTeleport == true
    Window._teleportDelay = math.max(0, tonumber(cfg.TeleportDelay) or 5)
    Window._teleportFile = tostring(cfg.TeleportFile or "Doors.lua")
    Window._teleportScript = cfg.TeleportScript or nil
    Window._teleportUrl = tostring(cfg.TeleportUrl or cfg.ScriptUrl or "")

    function Window:SetExecuteOnTeleport(enabled)
        Window._executeOnTeleport = (enabled == true)
        if Window._tpToggle and Window._tpToggle.Set then
            Window._tpToggle.Set(Window._executeOnTeleport)
        end
    end

    function Window:GetExecuteOnTeleport()
        return Window._executeOnTeleport
    end

    function Window:SetTeleportDelay(delay)
        Window._teleportDelay = math.max(0, tonumber(delay) or 0)
        if Window._tpDelaySlider and Window._tpDelaySlider.Set then
            Window._tpDelaySlider.Set(Window._teleportDelay)
        end
    end

    function Window:GetTeleportDelay()
        return Window._teleportDelay
    end

    function Window:SetTeleportFile(fileName)
        Window._teleportFile = tostring(fileName or "Doors.lua")
    end

    function Window:GetTeleportFile()
        return Window._teleportFile
    end

    function Window:SetTeleportUrl(url)
        Window._teleportUrl = tostring(url or "")
    end

    function Window:GetTeleportUrl()
        return Window._teleportUrl
    end

    function Window:SetTeleportScript(scriptStr)
        Window._teleportScript = scriptStr
    end

    function Window:GetTeleportScript()
        return Window._teleportScript
    end

    local queueTeleport = (syn and syn.queue_on_teleport) or queue_on_teleport or (fluxus and fluxus.queue_on_teleport) or (getgenv and getgenv().queue_on_teleport)
    local queuedThisTeleport = false

    local function buildTeleportPayload()
        local delaySec = math.max(0, tonumber(Window._teleportDelay) or 5)
        local fileName = Window._teleportFile or "Doors.lua"
        local lowerFile = fileName:lower()

        local scriptCode
        if Window._teleportScript and Window._teleportScript ~= "" then
            scriptCode = string.format([[
pcall(function()
    local fn, err = loadstring(%q)
    if fn then
        task.spawn(fn)
    else
        warn("[MoroLumina] Teleport compile error: " .. tostring(err))
    end
end)
]], Window._teleportScript)
        elseif Window._teleportUrl and Window._teleportUrl ~= "" then
            scriptCode = string.format([[
pcall(function()
    local src = game:HttpGet(%q)
    if src and src ~= "" then
        local fn, err = loadstring(src)
        if fn then
            task.spawn(fn)
        else
            warn("[MoroLumina] Teleport compile error: " .. tostring(err))
        end
    end
end)
]], Window._teleportUrl)
        else
            -- Default: automatically load local script from exploit folder (Doors.lua / doors.lua)
            scriptCode = string.format([[
pcall(function()
    local targetFile = %q
    local altFile = %q
    if isfile and isfile(targetFile) then
        if loadfile then
            local fn, err = loadfile(targetFile)
            if fn then return task.spawn(fn) end
        end
        if readfile then
            local src = readfile(targetFile)
            local fn, err = loadstring(src)
            if fn then return task.spawn(fn) end
        end
    elseif isfile and isfile(altFile) then
        if loadfile then
            local fn, err = loadfile(altFile)
            if fn then return task.spawn(fn) end
        end
        if readfile then
            local src = readfile(altFile)
            local fn, err = loadstring(src)
            if fn then return task.spawn(fn) end
        end
    elseif loadfile then
        local fn = loadfile(targetFile) or loadfile(altFile)
        if fn then return task.spawn(fn) end
    end
    warn("[MoroLumina] Teleport: could not find " .. targetFile .. " to execute")
end)
]], fileName, lowerFile)
        end

        local payload = string.format([[
repeat task.wait() until game:IsLoaded()
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
while not lp do
    task.wait()
    lp = Players.LocalPlayer
end
if %d > 0 then
    task.wait(%d)
end
%s
]], delaySec, delaySec, scriptCode)

        return payload
    end

    local function queueTeleportExecution()
        if not Window._executeOnTeleport or not queueTeleport then return end
        local payload = buildTeleportPayload()
        if payload then
            queuedThisTeleport = true
            pcall(function()
                queueTeleport(payload)
            end)
        end
    end
    Window._queueTeleportExecution = queueTeleportExecution

    local function attachTeleportListener(player)
        if not player then return end
        player.OnTeleport:Connect(function(state)
            if not state or state == Enum.TeleportState.Started or state == Enum.TeleportState.InProgress then
                if not queuedThisTeleport then
                    queueTeleportExecution()
                end
            elseif state == Enum.TeleportState.Failed then
                queuedThisTeleport = false
            end
        end)
    end

    if LocalPlayer then
        attachTeleportListener(LocalPlayer)
    else
        task.spawn(function()
            LocalPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait() or Players.LocalPlayer
            if LocalPlayer then
                attachTeleportListener(LocalPlayer)
            end
        end)
    end

    -- root gui
    local gui = create("ScreenGui", {
        Name = "MoroLumina",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })
    pcall(function() gui.Parent = (gethui and gethui()) or CoreGui end)
    if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
    Window.Gui = gui

    -- canvas group (for fade/scale animations)
    local canvas = create("CanvasGroup", {
        Name = "Window",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(600, 340),
        BackgroundColor3 = Theme.Bg,
        GroupTransparency = 0,
        Parent = gui,
    })
    corner(canvas, 14)
    local winScale = create("UIScale", { Scale = 1, Parent = canvas })
    local userScale = 1
    Window._setUserScale = function(s)
        userScale = s
        winScale.Scale = s
    end
    Window._getUserScale = function() return userScale end

    -- Контейнер для эффектов позади окна (НЕ внутри CanvasGroup!)
    local fxHolder = create("Frame", {
        Name = "FXHolder",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = canvas.Position,
        Size = canvas.Size,
        ZIndex = canvas.ZIndex - 1,
        Parent = gui,
    })
    local fxScale = create("UIScale", { Scale = winScale.Scale, Parent = fxHolder })

    -- серая обводка окна (как отдельный эффект, гаснет синхронно)
    local borderFrame = create("Frame", {
        Name = "Border",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = fxHolder,
    })
    corner(borderFrame, 14)
    stroke(borderFrame, Theme.Stroke, 1.5, 0)

    -- держим fxHolder под canvas по позиции/размеру
    local function syncFX()
        fxHolder.Position = canvas.Position
        fxHolder.Size = canvas.Size
        fxScale.Scale = winScale.Scale   -- ← синхроним масштаб эффектов
    end
    canvas:GetPropertyChangedSignal("Position"):Connect(syncFX)
    canvas:GetPropertyChangedSignal("Size"):Connect(syncFX)
    -- следим за масштабом окна, чтобы эффекты тоже масштабировались
    winScale:GetPropertyChangedSignal("Scale"):Connect(syncFX)

    -- тень (чёрная)
    create("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.7,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49,49,450,450),
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0, -30, 0, -30),
        Parent = fxHolder,
    })

    -- свечение (зелёное, под тенью)
    local glow = create("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Theme.Accent,
        ImageTransparency = 0.6,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49,49,450,450),
        Size = UDim2.new(1, 50, 1, 50),
        Position = UDim2.new(0, -25, 0, -25),
        Parent = fxHolder,
    })
    registerAccent(glow, "ImageColor3")

    -- мягкая пульсация свечения (только когда меню открыто)
    local pulseActive = true   -- управляется из Window:Toggle
    Window._setPulse = function(v) pulseActive = v end
    task.spawn(function()
        while glow.Parent do
            if pulseActive then
                tween(glow, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { ImageTransparency = 0.45 })
                task.wait(1.8)
                if not pulseActive then continue end
                tween(glow, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { ImageTransparency = 0.7 })
                task.wait(1.8)
            else
                task.wait(0.1)
            end
        end
    end)

    --========================= TOP BAR =========================--
    local topbar = create("Frame", {
        BackgroundColor3 = Theme.Bg2,
        Size = UDim2.new(1, 0, 0, 54),
        Parent = canvas,
    })
    corner(topbar, 14)
    create("Frame", { -- mask bottom corners
        BackgroundColor3 = Theme.Bg2, BorderSizePixel = 0,
        Position = UDim2.new(0,0,1,-14), Size = UDim2.new(1,0,0,14), Parent = topbar,
    })

    -- logo
    local logo = create("ImageLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(26, 26),
        Position = UDim2.fromOffset(16, 14),
        ImageColor3 = Theme.Accent,
        Parent = topbar,
    })
    applyIcon(logo, "crown")
    registerAccent(logo, "ImageColor3")

    local titleText = create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Text = cfg.Title or "MOROLUMINA.lua",
        Font = Theme.FontBold, TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar,
    })
    registerAccent(titleText, "TextColor3")

    -- topbar icon buttons
    local iconHolder = create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -12, 0.5, 0),
        Size = UDim2.new(0, 160, 0, 32),
        Parent = topbar,
    })
    create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = iconHolder,
    })

    local function makeIconBtn(iconName, order, callback)
        local b = create("TextButton", {
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(32, 32),
            Text = "", AutoButtonColor = false, LayoutOrder = order,
            Parent = iconHolder,
        })
        corner(b, 8)
        local ic = create("ImageLabel", {
            BackgroundTransparency = 1,
            ImageColor3 = Theme.SubText,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(18, 18), Parent = b,
        })
        applyIcon(ic, iconName)
        b.MouseEnter:Connect(function()
            tween(b, TW.Fast, { BackgroundTransparency = 0 })
            tween(ic, TW.Fast, { ImageColor3 = Theme.Text })
        end)
        b.MouseLeave:Connect(function()
            tween(b, TW.Fast, { BackgroundTransparency = 1 })
            tween(ic, TW.Fast, { ImageColor3 = Theme.SubText })
        end)
        addClickEffect(b)
        if callback then b.MouseButton1Click:Connect(callback) end
        return b, ic
    end

    -- сохраняем кнопки, чтобы можно было назначить им действия снаружи
    Window._topButtons = {}
    Window._topButtons.bell     = makeIconBtn("bell", 1)
    Window._topButtons.key      = makeIconBtn("key", 2)
    local gearBtn               = makeIconBtn("settings", 3)
    Window._topButtons.settings = gearBtn
    Window._topButtons.user     = makeIconBtn("user", 4)

    -- API для назначения действий кнопкам топбара
    function Window:SetTopButton(name, callback)
        local b = Window._topButtons[name]
        if b and callback then
            b.MouseButton1Click:Connect(callback)
        end
    end

    --========================= BODY =========================--
    local body = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(0, 54),
        Size = UDim2.new(1, 0, 1, -54),
        Parent = canvas,
    })

    -- sidebar (tab buttons)
    local sidebar = create("Frame", {
        BackgroundColor3 = Theme.Bg2,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 92, 1, 0),
        Parent = body,
    })
    local sideScroll = create("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0,0,0,0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebar,
    })
    padding(sideScroll, nil, 12, 12, 10, 10)
    create("UIListLayout", {
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = sideScroll,
    })

    -- pages container
    local pagesHolder = create("Frame", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 92, 0, 0),
        Size = UDim2.new(1, -92, 1, 0),
        Parent = body,
    })
    padding(pagesHolder, nil, 8, 12, 4, 12)

    --========================= DRAGGING =========================--
    do
        local dragging, dragStart, startPos
        topbar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = Vector2.new(i.Position.X, i.Position.Y)
                startPos = canvas.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local dx = i.Position.X - dragStart.X
                local dy = i.Position.Y - dragStart.Y
                canvas.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + dx, startPos.Y.Scale, startPos.Y.Offset + dy)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end
  
    --========================= RESIZING =========================--
    do
        local EDGE = 8
        local MIN_X, MIN_Y = 480, 300
        local MAX_X, MAX_Y = 1200, 800
        local TOP_SAFE = 54     -- высота topbar — тут НЕ ресайзим (это перетаскивание)

        local resizing = false
        local dirX, dirY = 0, 0
        local mouseStart, startSize, startPos

        local function getEdge(px, py)
            local ap = canvas.AbsolutePosition
            local as = canvas.AbsoluteSize
            local sc = winScale.Scale
            if not sc or sc <= 0 then sc = 1 end
            local e = EDGE
            local lx = px - ap.X
            local ly = py - ap.Y
            local dx, dy = 0, 0

            if lx <= e then dx = -1
            elseif lx >= as.X - e then dx = 1 end

            -- верх НЕ трогаем (там topbar для перетаскивания)
            if ly >= as.Y - e then dy = 1 end

            -- если курсор в зоне topbar — запрещаем горизонтальный ресайз тоже
            if ly < TOP_SAFE * sc and dy == 0 then
                dx = 0
            end
            return dx, dy
        end

        canvas.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                local dx, dy = getEdge(i.Position.X, i.Position.Y)
                if dx ~= 0 or dy ~= 0 then
                    resizing = true
                    dirX, dirY = dx, dy
                    mouseStart = Vector2.new(i.Position.X, i.Position.Y)
                    startSize = canvas.Size
                    startPos = canvas.Position
                end
            end
        end)

        UserInputService.InputChanged:Connect(function(i)
            if not resizing then return end
            if i.UserInputType ~= Enum.UserInputType.MouseMovement
            and i.UserInputType ~= Enum.UserInputType.Touch then return end

            local sc = winScale.Scale
            if not sc or sc <= 0 then sc = 1 end

            local rawDX = i.Position.X - mouseStart.X
            local rawDY = i.Position.Y - mouseStart.Y
            if rawDX ~= rawDX then rawDX = 0 end
            if rawDY ~= rawDY then rawDY = 0 end

            local dX = rawDX / sc
            local dY = rawDY / sc

            local newW  = startSize.X.Offset
            local newH  = startSize.Y.Offset
            local newPX = startPos.X.Offset
            local newPY = startPos.Y.Offset

            -- AnchorPoint (0.5,0.5): сдвигаем центр на половину прироста
            if dirX == 1 then
                newW = math.clamp(startSize.X.Offset + dX, MIN_X, MAX_X)
                newPX = startPos.X.Offset + (newW - startSize.X.Offset) * sc / 2
            elseif dirX == -1 then
                newW = math.clamp(startSize.X.Offset - dX, MIN_X, MAX_X)
                newPX = startPos.X.Offset - (newW - startSize.X.Offset) * sc / 2
            end

            if dirY == 1 then
                newH = math.clamp(startSize.Y.Offset + dY, MIN_Y, MAX_Y)
                newPY = startPos.Y.Offset + (newH - startSize.Y.Offset) * sc / 2
            end

            canvas.Size     = UDim2.new(startSize.X.Scale, newW, startSize.Y.Scale, newH)
            canvas.Position = UDim2.new(startPos.X.Scale, newPX, startPos.Y.Scale, newPY)
        end)

        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                resizing = false
                dirX, dirY = 0, 0
            end
        end)

        canvas.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement and not resizing then
                local dx, dy = getEdge(i.Position.X, i.Position.Y)
                if dx ~= 0 and dy ~= 0 then
                    UserInputService.MouseIcon = (dx == dy)
                        and "rbxasset://SystemCursors/SizeNWSE"
                        or  "rbxasset://SystemCursors/SizeNESW"
                elseif dx ~= 0 then
                    UserInputService.MouseIcon = "rbxasset://SystemCursors/SizeEW"
                elseif dy ~= 0 then
                    UserInputService.MouseIcon = "rbxasset://SystemCursors/SizeNS"
                else
                    UserInputService.MouseIcon = ""
                end
            end
        end)
        canvas.MouseLeave:Connect(function()
            if not resizing then UserInputService.MouseIcon = "" end
        end)
    end

    --========================= WINDOW SIZE =========================--
    local function parseSize(w, h)
        local width, height
        if typeof(w) == "UDim2" then
            width = w.X.Offset
            height = w.Y.Offset
        elseif typeof(w) == "Vector2" then
            width = w.X
            height = w.Y
        elseif type(w) == "table" then
            if w.__t == "u2" then
                width = tonumber(w[2] or w["2"])
                height = tonumber(w[4] or w["4"])
            elseif w.__t == "v2" or (#w == 2 and not w.width and not w.X) then
                width = tonumber(w[1] or w["1"])
                height = tonumber(w[2] or w["2"])
            elseif #w == 4 then
                width = tonumber(w[2] or w["2"])
                height = tonumber(w[4] or w["4"])
            else
                if type(w.X) == "table" then
                    width = tonumber(w.X.Offset)
                elseif w.X then
                    width = tonumber(w.X)
                elseif w.width then
                    width = tonumber(w.width)
                elseif w.W then
                    width = tonumber(w.W)
                end

                if type(w.Y) == "table" then
                    height = tonumber(w.Y.Offset)
                elseif w.Y then
                    height = tonumber(w.Y)
                elseif w.height then
                    height = tonumber(w.height)
                elseif w.H then
                    height = tonumber(w.H)
                end
            end
        else
            width = tonumber(w)
            height = tonumber(h)
        end
        return width, height
    end

    function Window:SetSize(w, h, animate)
        local width, height = parseSize(w, h)
        if width and height then
            width = math.clamp(math.floor(width + 0.5), 480, 1200)
            height = math.clamp(math.floor(height + 0.5), 300, 800)
            local targetSize = UDim2.fromOffset(width, height)
            if animate then
                tween(canvas, TW.Normal, { Size = targetSize })
            else
                canvas.Size = targetSize
            end
        end
    end

    function Window:GetSize()
        return canvas.Size
    end

    Library:RegisterFunction("_WindowSize", function()
        return Window:GetSize()
    end, function(v)
        Window:SetSize(v)
    end)
  
    --========================= TOGGLE / OPEN-CLOSE =========================--
    local isOpen = true

    function Window:IsOpen()
        return isOpen
    end

    -- Invisible modal button inside canvas: forces Roblox camera script to release mouse lock and disable camera pan/zoom
    local modalBtn = create("TextButton", {
        Name = "CursorModal",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 0, 0, 0),
        Text = "",
        Modal = true,
        Visible = true,
        Active = true,
        Selectable = false,
        Parent = canvas,
    })

    -- Force unlock mouse cursor (for first-person/mouse-locked games like Doors)
    local updatingMouse = false
    local function forceMouseUnlock()
        if not isOpen or updatingMouse then return end
        updatingMouse = true
        pcall(function()
            if UserInputService.MouseBehavior ~= Enum.MouseBehavior.Default then
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            end
            if not UserInputService.MouseIconEnabled then
                UserInputService.MouseIconEnabled = true
            end
            if Enum.OverrideMouseIconBehavior and Enum.OverrideMouseIconBehavior.ForceShow then
                UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.ForceShow
            end
        end)
        updatingMouse = false
    end

    local mouseSteppedConn = RunService.RenderStepped:Connect(function()
        if isOpen then
            forceMouseUnlock()
        end
    end)

    local mouseBehaviorConn = UserInputService:GetPropertyChangedSignal("MouseBehavior"):Connect(function()
        if isOpen then
            forceMouseUnlock()
        end
    end)

    local mouseIconConn = UserInputService:GetPropertyChangedSignal("MouseIconEnabled"):Connect(function()
        if isOpen then
            forceMouseUnlock()
        end
    end)

    function Window:Toggle(state)
        if state == nil then state = not isOpen end
        isOpen = state

        local borderStroke = borderFrame:FindFirstChildOfClass("UIStroke")

        if isOpen then
            modalBtn.Modal = true
            modalBtn.Visible = true
            forceMouseUnlock()

            if Window._setPulse then Window._setPulse(true) end
            canvas.Visible = true
            fxHolder.Visible = true
            -- стартуем чуть меньше пользовательского масштаба и анимируем до него
            winScale.Scale = userScale * 0.95
            tween(winScale, TW.Slow, { Scale = userScale })
            tween(canvas, TW.Normal, { GroupTransparency = 0 })
            for _, ch in ipairs(fxHolder:GetChildren()) do
                if ch:IsA("ImageLabel") then
                    tween(ch, TW.Normal, { ImageTransparency = ch.ImageColor3 == Color3.new(0,0,0) and 0.4 or 0.6 })
                end
            end
            if borderStroke then tween(borderStroke, TW.Normal, { Transparency = 0 }) end
        else
            modalBtn.Modal = false
            modalBtn.Visible = false
            pcall(function()
                if Enum.OverrideMouseIconBehavior and Enum.OverrideMouseIconBehavior.None then
                    UserInputService.OverrideMouseIconBehavior = Enum.OverrideMouseIconBehavior.None
                end
            end)

            if Window._setPulse then Window._setPulse(false) end
            tween(winScale, TW.Normal, { Scale = userScale * 0.95 })
            for _, ch in ipairs(fxHolder:GetChildren()) do
                if ch:IsA("ImageLabel") then
                    tween(ch, TW.Normal, { ImageTransparency = 1 })
                end
            end
            if borderStroke then tween(borderStroke, TW.Normal, { Transparency = 1 }) end
            local t = tween(canvas, TW.Normal, { GroupTransparency = 1 })
            t.Completed:Connect(function()
                if not isOpen then
                    canvas.Visible = false
                    fxHolder.Visible = false
                end
            end)
        end
    end

    -- Initial unlock on creation
    task.spawn(function()
        task.wait()
        if isOpen then
            forceMouseUnlock()
        end
    end)

    -- Toggle key listener (PC / keyboard / mouse keybind)
    local toggleInputConn = UserInputService.InputBegan:Connect(function(input, gpe)
        if UserInputService:GetFocusedTextBox() then return end
        if Library._isListeningKeybind then return end

        local targetKey = Window._toggleKey
        if not targetKey then return end

        local matched = false
        if input.UserInputType == Enum.UserInputType.Keyboard then
            matched = (input.KeyCode == targetKey)
        else
            matched = (input.UserInputType == targetKey)
        end

        if matched then
            Window:Toggle()
        end
    end)

    gui.AncestryChanged:Connect(function(_, parent)
        if not parent then
            isOpen = false
            if mouseSteppedConn then mouseSteppedConn:Disconnect() end
            if mouseBehaviorConn then mouseBehaviorConn:Disconnect() end
            if mouseIconConn then mouseIconConn:Disconnect() end
            if toggleInputConn then toggleInputConn:Disconnect() end
        end
    end)

    --========================= MOBILE FLOAT BUTTON =========================--
    do
        local fab = create("TextButton", {
            Name = "OpenButton",
            BackgroundColor3 = Theme.Bg,            -- чёрный фон как у меню
            Position = UDim2.new(0, 20, 0, 120),
            Size = UDim2.fromOffset(90, 36),        -- прямоугольная
            Text = "OPEN",
            TextColor3 = Theme.Accent,              -- зелёный текст
            Font = Theme.FontBold,
            TextSize = 14,
            AutoButtonColor = false,
            ZIndex = 50,
            Parent = Window.Gui,
        })
        corner(fab, 8)
        local fabStroke = stroke(fab, Theme.Accent, 1.5, 0)   -- зелёная обводка
        registerAccent(fabStroke, "Color")
        registerAccent(fab, "TextColor3")

        fab.Visible = true

        fab.MouseEnter:Connect(function()
            tween(fab, TW.Fast, { BackgroundColor3 = Theme.Bg2 })
        end)
        fab.MouseLeave:Connect(function()
            tween(fab, TW.Fast, { BackgroundColor3 = Theme.Bg })
        end)
        addClickEffect(fab, 0.95)

        local fdrag, fStart, fStartPos, fMoved = false, nil, nil, false

        fab.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                fdrag = true; fMoved = false
                fStart = i.Position; fStartPos = fab.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(i)
            if fdrag and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - fStart
                if d.Magnitude > 4 then fMoved = true end
                fab.Position = UDim2.new(0, fStartPos.X.Offset + d.X, 0, fStartPos.Y.Offset + d.Y)
            end
        end)

        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                if fdrag and not fMoved then Window:Toggle() end
                fdrag = false
            end
        end)
    end

    --===============================================================================--
    --                              NOTIFICATIONS                                    --
    --===============================================================================--
    local notifyHolder = create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -16, 0, 16),
        Size = UDim2.new(0, 280, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = gui,
    })
    create("UIListLayout", {
        VerticalAlignment = Enum.VerticalAlignment.Top,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = notifyHolder,
    })

    local function notifyColor(typ)
        if typ == "Success" then return Color3.fromRGB(0, 225, 134) end
        if typ == "Warning" then return Color3.fromRGB(255, 180, 40) end
        if typ == "Error"   then return Color3.fromRGB(255, 70, 80)  end
        return Theme.Accent
    end

    local _notifyOrder = 0

    function Window:Notify(n)
        n = n or {}
        local col = notifyColor(n.Type)
        local dur = n.Duration or 4

        _notifyOrder = _notifyOrder + 1

        -- карточка фиксированной высоты (НЕ AutomaticSize)
        local hasContent = n.Content and n.Content ~= ""
        local cardHeight = hasContent and 56 or 34

        local card = create("Frame", {
            BackgroundColor3 = Theme.Bg2,
            Size = UDim2.new(1, 0, 0, cardHeight),
            BackgroundTransparency = 1,
            LayoutOrder = _notifyOrder,
            ClipsDescendants = true,
            Parent = notifyHolder,
        })
        corner(card, 10)
        stroke(card, Theme.StrokeLight, 1, 0.4)
        local cardScale = create("UIScale", { Scale = 0.8, Parent = card })

        -- accent-полоса слева
        local accentBar = create("Frame", {
            BackgroundColor3 = col, BorderSizePixel = 0,
            Size = UDim2.new(0, 4, 1, -16),
            Position = UDim2.new(0, 7, 0, 8),
            ZIndex = 2, Parent = card,
        })
        corner(accentBar, 2)

        -- заголовок
        create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(14, hasContent and 8 or 0),
            Size = UDim2.new(1, -22, 0, hasContent and 16 or cardHeight),
            Text = n.Title or "Notification",
            TextColor3 = col, Font = Theme.FontBold, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = hasContent and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
            Parent = card,
        })

        -- текст (только если есть)
        if hasContent then
            create("TextLabel", {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(14, 26),
                Size = UDim2.new(1, -22, 0, 24),
                Text = n.Content,
                TextColor3 = Theme.SubText, Font = Theme.Font, TextSize = 12,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextWrapped = true,
                Parent = card,
            })
        end

        tween(card, TW.Normal, { BackgroundTransparency = 0 })
        tween(cardScale, TW.Spring, { Scale = 1 })

        task.delay(dur, function()
            tween(card, TW.Normal, { BackgroundTransparency = 1 })
            tween(cardScale, TW.Fast, { Scale = 0.8 })
            for _, ch in ipairs(card:GetDescendants()) do
                pcall(function()
                    if ch:IsA("TextLabel") then tween(ch, TW.Normal, { TextTransparency = 1 }) end
                    if ch:IsA("Frame") then tween(ch, TW.Normal, { BackgroundTransparency = 1 }) end
                    if ch:IsA("UIStroke") then tween(ch, TW.Normal, { Transparency = 1 }) end
                end)
            end
            task.delay(0.3, function() card:Destroy() end)
        end)
    end

    --===============================================================================--
    --                              FAST MENU HUD                                    --
    --===============================================================================--
    Window._toggles = {}
    Window._toggleOrder = {}
    Window._fastMenuSelectedToggles = {}
    Window._fastMenuScale = 1
    Window._fastMenuLocked = false
    Window._fastMenuVisible = false

    Window._registerToggle = function(key, data)
        if not Window._toggles[key] then
            table.insert(Window._toggleOrder, key)
        end
        Window._toggles[key] = data
        if Window._fastMultiDropdown then
            Window._fastMultiDropdown.Refresh(Window._getToggleNames(), true)
        end
        if Window._refreshFastMenu and Window._fastMenuVisible then
            Window._refreshFastMenu()
        end
    end

    Window._getToggleNames = function()
        local list = {}
        for _, k in ipairs(Window._toggleOrder) do
            local t = Window._toggles[k]
            if t then table.insert(list, t.Name or k) end
        end
        return list
    end

    Window._findToggleByName = function(name)
        for _, t in pairs(Window._toggles) do
            if t.Name == name or t.Key == name then
                return t
            end
        end
        return nil
    end

    Window._buttons = {}
    Window._buttonOrder = {}
    Window._fastMenuSelectedButtons = {}

    Window._registerButton = function(key, data)
        if not Window._buttons[key] then
            table.insert(Window._buttonOrder, key)
        end
        Window._buttons[key] = data
        if Window._fastButtonMultiDropdown then
            Window._fastButtonMultiDropdown.Refresh(Window._getButtonNames(), true)
        end
        if Window._refreshFastMenu and Window._fastMenuVisible then
            Window._refreshFastMenu()
        end
    end

    Window._getButtonNames = function()
        local list = {}
        for _, k in ipairs(Window._buttonOrder) do
            local b = Window._buttons[k]
            if b then table.insert(list, b.Name or k) end
        end
        return list
    end

    Window._findButtonByName = function(name)
        for _, b in pairs(Window._buttons) do
            if b.Name == name or b.Key == name then
                return b
            end
        end
        return nil
    end

    Window._setFastMenuButtons = function(list)
        Window._fastMenuSelectedButtons = list or {}
        if Window._fastMenuVisible then
            Window._refreshFastMenu()
        end
    end

    local fastFrame = create("Frame", {
        Name = "FastMenu",
        BackgroundColor3 = Theme.Bg,
        BackgroundTransparency = 0.05,
        Position = UDim2.new(0, 30, 0.35, 0),
        Size = UDim2.fromOffset(210, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 100,
        Parent = gui,
    })
    corner(fastFrame, 10)
    local fastStroke = stroke(fastFrame, Theme.StrokeLight, 1, 0.3)
    local fastScale = create("UIScale", { Scale = 1, Parent = fastFrame })

    local fastHeader = create("Frame", {
        Name = "Header",
        BackgroundColor3 = Theme.Header,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = fastFrame,
    })
    corner(fastHeader, 10)
    create("Frame", {
        Name = "HeaderFill",
        BackgroundColor3 = Theme.Header,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -6),
        Size = UDim2.new(1, 0, 0, 6),
        Parent = fastHeader,
    })

    local fastIcon = create("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Accent,
        Position = UDim2.fromOffset(8, 7),
        Size = UDim2.fromOffset(16, 16),
        Parent = fastHeader,
    })
    applyIcon(fastIcon, "zap")
    registerAccent(fastIcon, "ImageColor3")

    create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Text = "Fast Menu",
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = fastHeader,
    })

    local fastLockBadge = create("TextLabel", {
        Name = "LockBadge",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        Text = "",
        TextColor3 = Theme.SubText,
        Font = Theme.Font,
        TextSize = 12,
        Visible = false,
        Parent = fastHeader,
    })

    local fastContent = create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = fastFrame,
    })
    padding(fastContent, nil, 6, 6, 8, 8)
    create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = fastContent,
    })

    local fastEmptyLbl = create("TextLabel", {
        Name = "EmptyLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        Text = "No functions selected",
        TextColor3 = Theme.SubText,
        Font = Theme.Font,
        TextSize = 12,
        Visible = true,
        Parent = fastContent,
    })

    -- Dragging logic
    do
        local dragging = false
        local dragStart, startPos

        fastHeader.InputBegan:Connect(function(i)
            if Window._fastMenuLocked then return end
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = Vector2.new(i.Position.X, i.Position.Y)
                startPos = fastFrame.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(i)
            if dragging and not Window._fastMenuLocked and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local dx = i.Position.X - dragStart.X
                local dy = i.Position.Y - dragStart.Y
                fastFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + dx, startPos.Y.Scale, startPos.Y.Offset + dy)
            end
        end)

        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    local activeRows = {}

    Window._refreshFastMenu = function()
        for _, rowObj in ipairs(activeRows) do
            if rowObj.Frame and rowObj.Frame.Parent then
                rowObj.Frame:Destroy()
            end
        end
        activeRows = {}

        local selected = Window._fastMenuSelectedToggles or {}
        local count = 0

        for _, item in ipairs(selected) do
            local toggleObj = Window._findToggleByName(item)
            if toggleObj then
                count = count + 1
                local row = create("Frame", {
                    Name = "Row_" .. (toggleObj.Key or count),
                    BackgroundColor3 = Theme.Element,
                    BackgroundTransparency = 0.4,
                    Size = UDim2.new(1, 0, 0, 30),
                    LayoutOrder = count,
                    Parent = fastContent,
                })
                corner(row, 6)
                stroke(row, Theme.StrokeLight, 1, 0.3)

                local iconOffset = 8
                if toggleObj.Icon then
                    local ic = create("ImageLabel", {
                        BackgroundTransparency = 1,
                        ImageColor3 = Theme.SubText,
                        Position = UDim2.fromOffset(8, 7),
                        Size = UDim2.fromOffset(16, 16),
                        Parent = row,
                    })
                    applyIcon(ic, toggleObj.Icon)
                    iconOffset = 28
                end

                create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(iconOffset, 0),
                    Size = UDim2.new(1, -(iconOffset + 44), 1, 0),
                    Text = toggleObj.Name,
                    TextColor3 = Theme.Text,
                    Font = Theme.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = row,
                })

                local curState = toggleObj.Get()
                local miniTrack = create("Frame", {
                    BackgroundColor3 = curState and Theme.Accent or Theme.ToggleOff,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -6, 0.5, 0),
                    Size = UDim2.fromOffset(34, 18),
                    Parent = row,
                })
                corner(miniTrack, 9)
                local miniKnob = create("Frame", {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = curState and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                    Size = UDim2.fromOffset(14, 14),
                    Parent = miniTrack,
                })
                corner(miniKnob, 7)

                if curState then registerAccent(miniTrack, "BackgroundColor3") end

                local function updateMiniUI(v)
                    curState = v
                    tween(miniTrack, TW.Fast, { BackgroundColor3 = v and Theme.Accent or Theme.ToggleOff })
                    tween(miniKnob, TW.Spring, { Position = v and UDim2.new(1, -16, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) })
                    if v then registerAccent(miniTrack, "BackgroundColor3") end
                end

                toggleObj.AddListener(updateMiniUI)

                local clickBtn = create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = row,
                })

                clickBtn.MouseEnter:Connect(function()
                    tween(row, TW.Fast, { BackgroundTransparency = 0.2 })
                end)
                clickBtn.MouseLeave:Connect(function()
                    tween(row, TW.Fast, { BackgroundTransparency = 0.4 })
                end)
                clickBtn.MouseButton1Click:Connect(function()
                    toggleObj.Set(not toggleObj.Get())
                end)

                table.insert(activeRows, { Frame = row, Update = updateMiniUI })
            end
        end

        local selectedButtons = Window._fastMenuSelectedButtons or {}
        for _, item in ipairs(selectedButtons) do
            local buttonObj = Window._findButtonByName(item)
            if buttonObj then
                count = count + 1
                local isPrimary = buttonObj.Primary == true
                local row = create("Frame", {
                    Name = "BtnRow_" .. (buttonObj.Key or count),
                    BackgroundColor3 = isPrimary and Theme.Accent or Theme.Element,
                    BackgroundTransparency = isPrimary and 0.15 or 0.35,
                    Size = UDim2.new(1, 0, 0, 28),
                    LayoutOrder = count,
                    Parent = fastContent,
                })
                corner(row, 6)
                local rowStrk = stroke(row, isPrimary and Theme.Accent or Theme.StrokeLight, 1, isPrimary and 0.1 or 0.3)
                if isPrimary then registerAccent(row, "BackgroundColor3") end

                local iconOffset = 8
                if buttonObj.Icon then
                    local ic = create("ImageLabel", {
                        BackgroundTransparency = 1,
                        ImageColor3 = isPrimary and Theme.Bg or Theme.SubText,
                        Position = UDim2.fromOffset(8, 6),
                        Size = UDim2.fromOffset(16, 16),
                        Parent = row,
                    })
                    applyIcon(ic, buttonObj.Icon)
                    iconOffset = 28
                end

                local titleLbl = create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(iconOffset, 0),
                    Size = UDim2.new(1, -(iconOffset + 26), 1, 0),
                    Text = buttonObj.Name,
                    TextColor3 = isPrimary and Theme.Bg or Theme.Text,
                    Font = Theme.FontMed,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = row,
                })

                local actionIcon = create("ImageLabel", {
                    Name = "ActionIcon",
                    BackgroundTransparency = 1,
                    ImageColor3 = isPrimary and Theme.Bg or Theme.SubText,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.fromOffset(12, 12),
                    Parent = row,
                })
                applyIcon(actionIcon, "play")

                local clickBtn = create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = row,
                })
                addClickEffect(clickBtn, 0.96)
                ripple(clickBtn)

                clickBtn.MouseEnter:Connect(function()
                    tween(row, TW.Fast, { BackgroundTransparency = isPrimary and 0.05 or 0.15 })
                    if not isPrimary then
                        tween(titleLbl, TW.Fast, { TextColor3 = Theme.Accent })
                        tween(actionIcon, TW.Fast, { ImageColor3 = Theme.Accent })
                    end
                end)
                clickBtn.MouseLeave:Connect(function()
                    tween(row, TW.Fast, { BackgroundTransparency = isPrimary and 0.15 or 0.35 })
                    if not isPrimary then
                        tween(titleLbl, TW.Fast, { TextColor3 = Theme.Text })
                        tween(actionIcon, TW.Fast, { ImageColor3 = Theme.SubText })
                    end
                end)
                clickBtn.MouseButton1Click:Connect(function()
                    if buttonObj.Callback then
                        task.spawn(buttonObj.Callback)
                    end
                end)

                table.insert(activeRows, { Frame = row })
            end
        end

        fastEmptyLbl.Visible = (count == 0)
    end

    Window._setFastMenuVisible = function(v)
        Window._fastMenuVisible = v
        if v then
            Window._refreshFastMenu()
            fastFrame.Visible = true
        else
            fastFrame.Visible = false
        end
    end

    Window._setFastMenuScale = function(s)
        Window._fastMenuScale = s
        fastScale.Scale = s
    end

    Window._setFastMenuLocked = function(v)
        Window._fastMenuLocked = v
        fastLockBadge.Text = v and "🔒" or ""
        fastLockBadge.Visible = v
    end

    Window._setFastMenuToggles = function(list)
        Window._fastMenuSelectedToggles = list or {}
        if Window._fastMenuVisible then
            Window._refreshFastMenu()
        end
    end

    local function parsePosition(pos)
        if typeof(pos) == "UDim2" then
            return pos
        elseif typeof(pos) == "Vector2" then
            return UDim2.fromOffset(pos.X, pos.Y)
        elseif type(pos) == "table" then
            if pos.__t == "u2" then
                local xs = tonumber(pos[1] or pos["1"]) or 0
                local xo = tonumber(pos[2] or pos["2"]) or 0
                local ys = tonumber(pos[3] or pos["3"]) or 0
                local yo = tonumber(pos[4] or pos["4"]) or 0
                return UDim2.new(xs, xo, ys, yo)
            elseif pos.__t == "v2" then
                local x = tonumber(pos[1] or pos["1"]) or 0
                local y = tonumber(pos[2] or pos["2"]) or 0
                return UDim2.fromOffset(x, y)
            elseif #pos == 4 then
                local xs = tonumber(pos[1] or pos["1"]) or 0
                local xo = tonumber(pos[2] or pos["2"]) or 0
                local ys = tonumber(pos[3] or pos["3"]) or 0
                local yo = tonumber(pos[4] or pos["4"]) or 0
                return UDim2.new(xs, xo, ys, yo)
            elseif #pos == 2 then
                local x = tonumber(pos[1] or pos["1"]) or 0
                local y = tonumber(pos[2] or pos["2"]) or 0
                return UDim2.fromOffset(x, y)
            elseif pos.X and pos.Y then
                local xs = type(pos.X) == "table" and (pos.X.Scale or pos.X[1] or 0) or 0
                local xo = type(pos.X) == "table" and (pos.X.Offset or pos.X[2] or 0) or tonumber(pos.X) or 0
                local ys = type(pos.Y) == "table" and (pos.Y.Scale or pos.Y[1] or 0) or 0
                local yo = type(pos.Y) == "table" and (pos.Y.Offset or pos.Y[2] or 0) or tonumber(pos.Y) or 0
                return UDim2.new(xs, xo, ys, yo)
            end
        end
        return nil
    end

    Window._setFastMenuPosition = function(pos)
        local u2 = parsePosition(pos)
        if u2 then
            fastFrame.Position = u2
        end
    end

    Window._getFastMenuPosition = function()
        return fastFrame.Position
    end

    Library:RegisterFunction("_FastMenuPosition", function()
        return Window._getFastMenuPosition()
    end, function(v)
        Window._setFastMenuPosition(v)
    end)

    Library:RegisterFunction("_FastMenuButtons", function()
        return Window._fastMenuSelectedButtons
    end, function(v)
        if type(v) == "table" then
            Window._setFastMenuButtons(v)
            if Window._fastButtonMultiDropdown then
                Window._fastButtonMultiDropdown.Set(v)
            end
        end
    end)

    function Window:GetFastMenu()
        return {
            Gui = fastFrame,
            SetVisible = Window._setFastMenuVisible,
            SetScale = Window._setFastMenuScale,
            SetLocked = Window._setFastMenuLocked,
            SetPosition = Window._setFastMenuPosition,
            GetPosition = Window._getFastMenuPosition,
            SetToggles = Window._setFastMenuToggles,
            SetButtons = Window._setFastMenuButtons,
            Refresh = Window._refreshFastMenu,
        }
    end

    --===============================================================================--
    --                            KEYBIND LIST HUD                                   --
    --===============================================================================--
    Window._keybinds = {}
    Window._keybindListScale = 1
    Window._keybindListLocked = false
    Window._keybindListVisible = false

    Window._notifyKeybindMode = function(name, mode)
        Window:Notify({
            Title = "Keybind Mode",
            Content = (name or "Keybind") .. ": " .. mode,
            Type = "Info",
            Duration = 1.5,
        })
    end

    Window._registerKeybind = function(data)
        table.insert(Window._keybinds, data)
        if Window._refreshKeybindList and Window._keybindListVisible then
            Window._refreshKeybindList()
        end
    end

    local kbFrame = create("Frame", {
        Name = "KeybindList",
        BackgroundColor3 = Theme.Bg,
        BackgroundTransparency = 0.05,
        Position = UDim2.new(0, 30, 0.62, 0),
        Size = UDim2.fromOffset(210, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Visible = false,
        ZIndex = 100,
        Parent = gui,
    })
    corner(kbFrame, 10)
    local kbStroke = stroke(kbFrame, Theme.StrokeLight, 1, 0.3)
    local kbScale = create("UIScale", { Scale = 1, Parent = kbFrame })

    local kbHeader = create("Frame", {
        Name = "Header",
        BackgroundColor3 = Theme.Header,
        BackgroundTransparency = 0.2,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = kbFrame,
    })
    corner(kbHeader, 10)
    create("Frame", {
        Name = "HeaderFill",
        BackgroundColor3 = Theme.Header,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -6),
        Size = UDim2.new(1, 0, 0, 6),
        Parent = kbHeader,
    })

    local kbIcon = create("ImageLabel", {
        Name = "Icon",
        BackgroundTransparency = 1,
        ImageColor3 = Theme.Accent,
        Position = UDim2.fromOffset(8, 7),
        Size = UDim2.fromOffset(16, 16),
        Parent = kbHeader,
    })
    applyIcon(kbIcon, "keyboard")
    registerAccent(kbIcon, "ImageColor3")

    create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(28, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Text = "Keybinds",
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = kbHeader,
    })

    local kbLockBadge = create("TextLabel", {
        Name = "LockBadge",
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        Text = "",
        TextColor3 = Theme.SubText,
        Font = Theme.Font,
        TextSize = 12,
        Visible = false,
        Parent = kbHeader,
    })

    local kbContent = create("Frame", {
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 0, 0, 30),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = kbFrame,
    })
    padding(kbContent, nil, 6, 6, 8, 8)
    create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = kbContent,
    })

    local kbEmptyLbl = create("TextLabel", {
        Name = "EmptyLabel",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 24),
        Text = "No active keybinds",
        TextColor3 = Theme.SubText,
        Font = Theme.Font,
        TextSize = 12,
        Visible = true,
        Parent = kbContent,
    })

    -- Dragging logic
    do
        local dragging = false
        local dragStart, startPos

        kbHeader.InputBegan:Connect(function(i)
            if Window._keybindListLocked then return end
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = Vector2.new(i.Position.X, i.Position.Y)
                startPos = kbFrame.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(i)
            if dragging and not Window._keybindListLocked and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local dx = i.Position.X - dragStart.X
                local dy = i.Position.Y - dragStart.Y
                kbFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + dx, startPos.Y.Scale, startPos.Y.Offset + dy)
            end
        end)

        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    local activeKbRows = {}

    Window._refreshKeybindList = function()
        for _, rowObj in ipairs(activeKbRows) do
            if rowObj and rowObj.Parent then
                rowObj:Destroy()
            end
        end
        activeKbRows = {}

        local count = 0
        for _, kb in ipairs(Window._keybinds) do
            local key = kb.GetKey and kb.GetKey()
            if key then
                count = count + 1
                local mode = kb.GetMode and kb.GetMode() or "Toggle"
                local isActive = kb.GetActive and kb.GetActive() or false

                local row = create("Frame", {
                    Name = "Row_" .. count,
                    BackgroundColor3 = Theme.Element,
                    BackgroundTransparency = 0.4,
                    Size = UDim2.new(1, 0, 0, 26),
                    LayoutOrder = count,
                    Parent = kbContent,
                })
                corner(row, 6)
                local rowStroke = stroke(row, isActive and Theme.Accent or Theme.StrokeLight, 1, isActive and 0 or 0.3)
                if isActive then registerAccent(rowStroke, "Color") end

                create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(8, 0),
                    Size = UDim2.new(1, -95, 1, 0),
                    Text = kb.Name or "Keybind",
                    TextColor3 = isActive and Theme.Text or Theme.SubText,
                    Font = Theme.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = row,
                })

                local keyName = key.Name or tostring(key)
                if #keyName > 6 then keyName = keyName:sub(1, 5) .. ".." end

                local modeShort = (mode == "Toggle" and "T") or (mode == "Hold" and "H") or "A"
                local badgeText = string.format("[%s] [%s]", keyName, modeShort)

                local badgeLbl = create("TextLabel", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -8, 0.5, 0),
                    Size = UDim2.fromOffset(85, 20),
                    Text = badgeText,
                    TextColor3 = isActive and Theme.Accent or Theme.SubText,
                    Font = Theme.FontMed,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = row,
                })
                if isActive then registerAccent(badgeLbl, "TextColor3") end

                table.insert(activeKbRows, row)
            end
        end

        kbEmptyLbl.Visible = (count == 0)
    end

    Window._setKeybindListVisible = function(v)
        Window._keybindListVisible = v
        if v then
            Window._refreshKeybindList()
            kbFrame.Visible = true
        else
            kbFrame.Visible = false
        end
    end

    Window._setKeybindListScale = function(s)
        Window._keybindListScale = s
        kbScale.Scale = s
    end

    Window._setKeybindListLocked = function(v)
        Window._keybindListLocked = v
        kbLockBadge.Text = v and "🔒" or ""
        kbLockBadge.Visible = v
    end

    Window._setKeybindListPosition = function(pos)
        local u2 = parsePosition(pos)
        if u2 then
            kbFrame.Position = u2
        end
    end

    Window._getKeybindListPosition = function()
        return kbFrame.Position
    end

    Library:RegisterFunction("_KeybindListPosition", function()
        return Window._getKeybindListPosition()
    end, function(v)
        Window._setKeybindListPosition(v)
    end)

    function Window:GetKeybindList()
        return {
            Gui = kbFrame,
            SetVisible = Window._setKeybindListVisible,
            SetScale = Window._setKeybindListScale,
            SetLocked = Window._setKeybindListLocked,
            SetPosition = Window._setKeybindListPosition,
            GetPosition = Window._getKeybindListPosition,
            Refresh = Window._refreshKeybindList,
        }
    end

    --===============================================================================--
    --                              CREATE TAB                                         --
    --===============================================================================--
    function Window:CreateTab(tabCfg)
        tabCfg = tabCfg or {}
        local Tab = {}
        local tabName = tabCfg.Name or "Tab"

        -- tab button in sidebar
        local tabBtn = create("TextButton", {
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 64),
            Text = "", AutoButtonColor = false,
            LayoutOrder = #Window._tabs + 1,
            Parent = sideScroll,
        })
        corner(tabBtn, 12)
        local tabStroke = stroke(tabBtn, Theme.Accent, 1.2, 1)
        registerAccent(tabStroke, "Color")

        local tabIcon = create("ImageLabel", {
            BackgroundTransparency = 1,
            ImageColor3 = Theme.SubText,
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 12),
            Size = UDim2.fromOffset(24, 24),
            Parent = tabBtn,
        })
        applyIcon(tabIcon, tabCfg.Icon or "menu")
    
        local tabLabel = create("TextLabel", {
            BackgroundTransparency = 1,
            AnchorPoint = Vector2.new(0.5, 1),
            Position = UDim2.new(0.5, 0, 1, -8),
            Size = UDim2.new(1, 0, 0, 14),
            Text = string.upper(tabName),
            TextColor3 = Theme.SubText, Font = Theme.FontMed, TextSize = 11,
            Parent = tabBtn,
        })

        -- the page (scrolling content) — split into 2 columns
        local page = create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            Parent = pagesHolder,
        })

        -- two-column layout: left & right
        local leftCol = create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0, 0, 0, 0),
            Size = UDim2.new(0.52, -6, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.StrokeLight,
            CanvasSize = UDim2.new(0,0,0,0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = page,
        })
        padding(leftCol, nil, 4, 8, 4, 8)
        create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = leftCol })

        local rightCol = create("ScrollingFrame", {
            BackgroundTransparency = 1,
            Position = UDim2.new(0.52, 6, 0, 0),
            Size = UDim2.new(0.48, -6, 1, 0),
            ScrollBarThickness = 3,
            ScrollBarImageColor3 = Theme.StrokeLight,
            CanvasSize = UDim2.new(0,0,0,0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Parent = page,
        })
        padding(rightCol, nil, 4, 8, 4, 8)
        create("UIListLayout", { Padding = UDim.new(0, 12), SortOrder = Enum.SortOrder.LayoutOrder, Parent = rightCol })

        Tab._page = page
        Tab._left = leftCol
        Tab._right = rightCol
        Tab._side = "left"  -- current target column

        -- column selector helper
        function Tab:Column(side)
            Tab._side = (side == "right") and "right" or "left"
            return Tab
        end
        local function getParent()
            return (Tab._side == "right") and Tab._right or Tab._left
        end

        -- tab activation
        local function activate()
        Window._activeTab = Tab
            for _, t in ipairs(Window._tabs) do
                t._page.Visible = false
                tween(t._btn, TW.Fast, { BackgroundTransparency = 1 })
                tween(t._stroke, TW.Fast, { Transparency = 1 })
                tween(t._icon, TW.Fast, { ImageColor3 = Theme.SubText })
                tween(t._label, TW.Fast, { TextColor3 = Theme.SubText })
            end
            page.Visible = true
            tween(tabBtn, TW.Fast, { BackgroundTransparency = 0.85 })
            tween(tabStroke, TW.Fast, { Transparency = 0 })
            tween(tabIcon, TW.Fast, { ImageColor3 = Theme.Accent })
            tween(tabLabel, TW.Fast, { TextColor3 = Theme.Text })
        end
        tabBtn.MouseButton1Click:Connect(activate)
        onAccentChange(function(col)
            if page.Visible then
                tween(tabIcon, TW.Fast, { ImageColor3 = col })
            end
        end)
        tabBtn.MouseEnter:Connect(function()
            if not page.Visible then tween(tabBtn, TW.Fast, { BackgroundTransparency = 0.93 }) end
        end)
        tabBtn.MouseLeave:Connect(function()
            if not page.Visible then tween(tabBtn, TW.Fast, { BackgroundTransparency = 1 }) end
        end)
        addClickEffect(tabBtn, 0.95)

        Tab._btn = tabBtn
        Tab._stroke = tabStroke
        Tab._icon = tabIcon
        Tab._label = tabLabel
        Tab._activate = activate
        table.insert(Window._tabs, Tab)
        if #Window._tabs == 1 then activate() end

        --=========================================================================--
        --                            SECTION                                        --
        --=========================================================================--
        function Tab:CreateSection(secCfg)
            secCfg = secCfg or {}
            local Section = {}
            local parent = getParent()
            local collapsible = secCfg.Collapsible ~= false
            local collapsed = secCfg.Collapsed == true

            local header = create("Frame", {
                Name = "SectionHeader",
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                LayoutOrder = #parent:GetChildren(),
                Parent = parent,
            })

            local titleLbl = create("TextLabel", {
                Name = "Title",
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 0, 0),
                Size = UDim2.new(1, collapsible and -24 or 0, 1, 0),
                Text = string.upper(secCfg.Name or "SECTION"),
                TextColor3 = Theme.Text, Font = Theme.FontBold, TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = header,
            })

            local chevron
            if collapsible then
                chevron = create("ImageLabel", {
                    Name = "Chevron",
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(16, 16),
                    ImageColor3 = Theme.SubText,
                    Rotation = collapsed and -90 or 0,
                    Parent = header,
                })
                applyIcon(chevron, "chevron-down")

                local headerBtn = create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    Parent = header,
                })

                headerBtn.MouseEnter:Connect(function()
                    tween(titleLbl, TW.Fast, { TextColor3 = Theme.Accent })
                    tween(chevron, TW.Fast, { ImageColor3 = Theme.Text })
                end)
                headerBtn.MouseLeave:Connect(function()
                    tween(titleLbl, TW.Fast, { TextColor3 = Theme.Text })
                    tween(chevron, TW.Fast, { ImageColor3 = Theme.SubText })
                end)
                headerBtn.MouseButton1Click:Connect(function()
                    Section:SetCollapsed(not collapsed)
                end)
            end

            local box = create("Frame", {
                BackgroundColor3 = Theme.Section,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                Visible = not collapsed,
                LayoutOrder = header.LayoutOrder + 1,
                Parent = parent,
            })
            corner(box, 12)
            local boxStroke = stroke(box, Theme.Accent, 1, 0.5)
            registerAccent(boxStroke, "Color")
            padding(box, nil, 10, 10, 12, 12)
            create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = box })

            Section._box = box
            Section._header = header

            function Section:SetCollapsed(val, fireCallback)
                if not collapsible then return end
                collapsed = val == true
                if chevron then
                    tween(chevron, TW.Fast, { Rotation = collapsed and -90 or 0 })
                end
                box.Visible = not collapsed
                if fireCallback ~= false and secCfg.Callback then
                    task.spawn(secCfg.Callback, collapsed)
                end
            end

            function Section:IsCollapsed()
                return collapsed
            end

            local function nextOrder() return #box:GetChildren() end

            -- base row builder
            local function row(height)
                local f = create("Frame", {
                    BackgroundColor3 = Theme.Element,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, height or 34),
                    LayoutOrder = nextOrder(),
                    Parent = box,
                })
                return f
            end

            -- label with optional icon + sublabel
            local function labelBlock(parent, text, icon, sub, widthOffset)
                if icon then
                    local ic = create("ImageLabel", {
                        BackgroundTransparency = 1,
                        ImageColor3 = Theme.SubText,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        Size = UDim2.fromOffset(16, 16),
                        Parent = parent,
                    })
                    applyIcon(ic, icon)
                end
                local off = icon and 24 or 0
                local lbl = create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(off, sub and 4 or 0),
                    Size = UDim2.new(1, -(off + (widthOffset or 60)), sub and 0 or 1, sub and 16 or 0),
                    Text = text,
                    TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextYAlignment = sub and Enum.TextYAlignment.Top or Enum.TextYAlignment.Center,
                    Parent = parent,
                })
                if sub then
                    create("TextLabel", {
                        BackgroundTransparency = 1,
                        Position = UDim2.fromOffset(off, 20),
                        Size = UDim2.new(1, -(off + (widthOffset or 60)), 0, 12),
                        Text = sub,
                        TextColor3 = Theme.SubText, Font = Theme.Font, TextSize = 11,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        Parent = parent,
                    })
                end
                return lbl
            end

            local function bindConfig(o, getter, setter)
                local opts = type(o) == "table" and o or { Flag = o }
                if opts.NoConfig or opts.IgnoreConfig or opts.Save == false then return end

                local key = opts.Flag or opts.Name
                if not key or key == "" then
                    key = (secCfg.Name or "Section") .. "_Elem_" .. tostring(#box:GetChildren())
                end

                if Library.ConfigRegistry[key] and not opts.Flag then
                    key = (secCfg.Name or "Section") .. "/" .. key
                end

                local entry = {
                    Get = getter,
                    Set = setter,
                    Name = opts.Name,
                    Flag = opts.Flag,
                    Section = secCfg.Name,
                }

                Library.ConfigRegistry[key] = entry
                Library.Flags[key] = entry

                if opts.Flag and not Library.Flags[opts.Flag] then
                    Library.Flags[opts.Flag] = entry
                end
                if opts.Name and not Library.Flags[opts.Name] then
                    Library.Flags[opts.Name] = entry
                end

                return entry
            end

            -- Сохраняем bindFlag для совместимости со старыми вызовами
            local function bindFlag(flag, getter, setter)
                return bindConfig(flag, getter, setter)
            end

            if secCfg.Flag then
                bindConfig({ Flag = secCfg.Flag, Name = secCfg.Name }, function() return Section:IsCollapsed() end, function(v) Section:SetCollapsed(v, false) end)
            end

            --=====================================================================--
            --                            LABEL                                      --
            --=====================================================================--
            function Section:AddLabel(text)
                local f = row(28)
                f.BackgroundColor3 = Theme.Element
                f.BackgroundTransparency = 0.4
                corner(f, 6)
                stroke(f, Theme.StrokeLight, 1, 0.4)   -- лёгкая обводка
                local lbl = create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1,-16,1,0),
                    Position = UDim2.fromOffset(8, 0),
                    Text = text, TextColor3 = Theme.SubText,
                    Font = Theme.Font, TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = f,
                })
                return { Set = function(t) lbl.Text = t end }
            end

            --=====================================================================--
            --                            BUTTON                                     --
            --=====================================================================--
            function Section:AddButton(o)
                o = o or {}
                local f = row(36)
                f.BackgroundTransparency = 0
                f.BackgroundColor3 = o.Primary and Theme.Accent or Theme.Element
                corner(f, 8)
                if not o.Primary then stroke(f, Theme.StrokeLight, 1, 0.3) end

                local btn = create("TextButton", {
                    BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0),
                    Text = o.Name or "Button",
                    TextColor3 = o.Primary and Theme.Bg or Theme.Text,
                    Font = Theme.FontMed, TextSize = 14,
                    AutoButtonColor = false, Parent = f,
                })
                if o.Primary then registerAccent(f, "BackgroundColor3") end
                ripple(btn); addClickEffect(btn, 0.97)
                btn.MouseEnter:Connect(function()
                    tween(f, TW.Fast, { BackgroundTransparency = o.Primary and 0.1 or 0.0 })
                    if not o.Primary then tween(f, TW.Fast, { BackgroundColor3 = Theme.Stroke }) end
                end)
                btn.MouseLeave:Connect(function()
                    tween(f, TW.Fast, { BackgroundTransparency = 0 })
                    if not o.Primary then tween(f, TW.Fast, { BackgroundColor3 = Theme.Element }) end
                end)
                btn.MouseButton1Click:Connect(function()
                    if o.Callback then task.spawn(o.Callback) end
                end)

                local btnName = o.Name or "Button"
                local btnKey = o.Flag or ((secCfg and secCfg.Name or "Section") .. "/" .. btnName)
                if not o.NoFastMenu and Window._registerButton then
                    Window._registerButton(btnKey, {
                        Name = btnName,
                        Key = btnKey,
                        Icon = o.Icon,
                        Primary = o.Primary,
                        Callback = o.Callback,
                    })
                end

                return {
                    SetText = function(t)
                        btn.Text = t
                        if Window._buttons and Window._buttons[btnKey] then
                            Window._buttons[btnKey].Name = t
                            if Window._fastButtonMultiDropdown then
                                Window._fastButtonMultiDropdown.Refresh(Window._getButtonNames(), true)
                            end
                            if Window._refreshFastMenu and Window._fastMenuVisible then
                                Window._refreshFastMenu()
                            end
                        end
                    end
                }
            end

            --=====================================================================--
            --                            TOGGLE                                     --
            --=====================================================================--
            function Section:AddToggle(o)
                o = o or {}
                local state = o.Default or false
                local f = row(34)
                labelBlock(f, o.Name or "Toggle", o.Icon, nil, 130)

                local controls = create("Frame", {
                    Name = "Controls",
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.new(0, 0, 1, 0),
                    AutomaticSize = Enum.AutomaticSize.X,
                    ZIndex = 3,
                    Parent = f,
                })
                create("UIListLayout", {
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Right,
                    VerticalAlignment = Enum.VerticalAlignment.Center,
                    Padding = UDim.new(0, 6),
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Parent = controls,
                })

                local track = create("Frame", {
                    Name = "Track",
                    BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff,
                    Size = UDim2.fromOffset(44, 22),
                    LayoutOrder = 10,
                    ZIndex = 4,
                    Parent = controls,
                })
                corner(track, 11)
                local knob = create("Frame", {
                    BackgroundColor3 = Color3.new(1,1,1),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                    Size = UDim2.fromOffset(18, 18),
                    ZIndex = 5,
                    Parent = track,
                })
                corner(knob, 9)

                local btn = create("TextButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    Text = "",
                    ZIndex = 2,
                    Parent = f,
                })

                local listeners = {}
                local function apply(v, fire)
                    state = v
                    tween(track, TW.Fast, { BackgroundColor3 = v and Theme.Accent or Theme.ToggleOff })
                    tween(knob, TW.Spring, { Position = v and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) })
                    if v then registerAccent(track, "BackgroundColor3") end
                    for _, fn in ipairs(listeners) do pcall(fn, v) end
                    if fire and o.Callback then task.spawn(o.Callback, v) end
                    if Window._refreshKeybindList then Window._refreshKeybindList() end
                end
                btn.MouseButton1Click:Connect(function() apply(not state, true) end)
                local cfgEntry = bindConfig(o, function() return state end, function(v) apply(v, true) end)
                if state then apply(true, false) end

                local toggleName = o.Name or (cfgEntry and cfgEntry.Name) or "Toggle"
                local toggleKey = (cfgEntry and cfgEntry.Flag) or (cfgEntry and cfgEntry.Name) or toggleName
                if not o.NoFastMenu and Window._registerToggle then
                    Window._registerToggle(toggleKey, {
                        Name = toggleName,
                        Key = toggleKey,
                        Icon = o.Icon,
                        Get = function() return state end,
                        Set = function(v) apply(v, true) end,
                        AddListener = function(fn) table.insert(listeners, fn) end,
                    })
                end

                local toggleApi = {
                    Set = function(v) apply(v, true) end,
                    Get = function() return state end,
                    AddListener = function(fn) table.insert(listeners, fn) end,
                }

                --=========================================--
                -- SUB-ELEMENT: Color Picker on Toggle     --
                --=========================================--
                function toggleApi:AddColorPicker(cpCfg)
                    cpCfg = cpCfg or {}
                    local cpColor = cpCfg.Default or Theme.Accent
                    local cpOpen = false
                    local cpH, cpS, cpV = cpColor:ToHSV()

                    local swatch = create("TextButton", {
                        Name = "ColorSwatch",
                        BackgroundColor3 = cpColor,
                        Size = UDim2.fromOffset(26, 18),
                        LayoutOrder = 5,
                        ZIndex = 6,
                        Text = "",
                        AutoButtonColor = false,
                        Parent = controls,
                    })
                    corner(swatch, 4)
                    stroke(swatch, Theme.StrokeLight, 1, 0.2)

                    -- Popup picker inside the section box directly below this row
                    local pop = create("Frame", {
                        Name = "ColorPickerPopup",
                        BackgroundColor3 = Theme.Bg,
                        Size = UDim2.new(1, 0, 0, 0),
                        AutomaticSize = Enum.AutomaticSize.None,
                        Visible = false,
                        ClipsDescendants = true,
                        LayoutOrder = f.LayoutOrder + 1,
                        Parent = box,
                    })
                    corner(pop, 8)
                    stroke(pop, Theme.StrokeLight, 1, 0.2)
                    padding(pop, 10)

                    local satval = create("ImageLabel", {
                        Image = "rbxassetid://4155801252",
                        BackgroundColor3 = Color3.fromHSV(cpH, 1, 1),
                        Size = UDim2.new(1, -28, 0, 100),
                        Parent = pop,
                    })
                    corner(satval, 6)
                    local svCursor = create("Frame", {
                        BackgroundColor3 = Color3.new(1,1,1),
                        Size = UDim2.fromOffset(8,8),
                        AnchorPoint = Vector2.new(0.5,0.5),
                        Parent = satval,
                    })
                    corner(svCursor, 4)
                    stroke(svCursor, Color3.new(0,0,0), 1)

                    local hueBar = create("Frame", {
                        Position = UDim2.new(1, -20, 0, 0),
                        Size = UDim2.new(0, 20, 0, 100),
                        Parent = pop,
                    })
                    corner(hueBar, 6)
                    create("UIGradient", {
                        Rotation = 90,
                        Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
                            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
                            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
                            ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
                            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
                            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
                            ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0)),
                        }),
                        Parent = hueBar,
                    })
                    local hueCursor = create("Frame", {
                        BackgroundColor3 = Color3.new(1,1,1),
                        Size = UDim2.new(1, 4, 0, 3),
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Position = UDim2.new(0.5, 0, cpH, 0),
                        Parent = hueBar,
                    })

                    local function refresh(fire)
                        cpColor = Color3.fromHSV(cpH, cpS, cpV)
                        swatch.BackgroundColor3 = cpColor
                        satval.BackgroundColor3 = Color3.fromHSV(cpH, 1, 1)
                        svCursor.Position = UDim2.new(cpS, 0, 1 - cpV, 0)
                        hueCursor.Position = UDim2.new(0.5, 0, cpH, 0)
                        if fire and cpCfg.Callback then task.spawn(cpCfg.Callback, cpColor) end
                    end
                    refresh(false)

                    local svDrag, hueDrag = false, false
                    satval.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then svDrag = true end
                    end)
                    hueBar.InputBegan:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then hueDrag = true end
                    end)
                    UserInputService.InputChanged:Connect(function(i)
                        if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
                        if svDrag then
                            cpS = math.clamp((i.Position.X - satval.AbsolutePosition.X)/satval.AbsoluteSize.X, 0, 1)
                            cpV = 1 - math.clamp((i.Position.Y - satval.AbsolutePosition.Y)/satval.AbsoluteSize.Y, 0, 1)
                            refresh(true)
                        elseif hueDrag then
                            cpH = math.clamp((i.Position.Y - hueBar.AbsolutePosition.Y)/hueBar.AbsoluteSize.Y, 0, 1)
                            refresh(true)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(i)
                        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                            svDrag, hueDrag = false, false
                        end
                    end)

                    swatch.MouseButton1Click:Connect(function()
                        cpOpen = not cpOpen
                        pop.Visible = true
                        tween(pop, TW.Normal, { Size = UDim2.new(1, 0, 0, cpOpen and 120 or 0) })
                        if not cpOpen then task.delay(0.25, function() if not cpOpen then pop.Visible = false end end) end
                    end)

                    local function setColor(c, fire)
                        if typeof(c) == "Color3" then
                            cpH, cpS, cpV = c:ToHSV()
                            refresh(fire ~= false)
                        end
                    end

                    local cpName = cpCfg.Name or (toggleName .. " Color")
                    bindConfig({ Flag = cpCfg.Flag, Name = cpName, NoConfig = cpCfg.NoConfig }, function() return cpColor end, function(c) setColor(c, true) end)
                    return { Set = function(c) setColor(c, true) end, Get = function() return cpColor end }
                end

                --=========================================--
                -- SUB-ELEMENT: Keybind on Toggle          --
                --=========================================--
                function toggleApi:AddKeybind(kbCfg)
                    kbCfg = kbCfg or {}
                    local current = kbCfg.Default
                    if type(current) == "string" then
                        current = Enum.KeyCode[current] or Enum.UserInputType[current] or nil
                    end
                    local mode = kbCfg.Mode or "Toggle" -- "Toggle" | "Hold" | "Always"
                    local listening = false

                    local function formatKeyText(k)
                        if not k then return "None" end
                        local n = k.Name or tostring(k)
                        if #n > 6 then n = n:sub(1, 5) .. ".." end
                        return n
                    end

                    local kbBtn = create("TextButton", {
                        Name = "InlineKeybind",
                        BackgroundColor3 = Theme.Bg,
                        Size = UDim2.fromOffset(48, 20),
                        LayoutOrder = 1,
                        ZIndex = 6,
                        Text = formatKeyText(current),
                        TextColor3 = Theme.Text,
                        Font = Theme.FontMed,
                        TextSize = 11,
                        AutoButtonColor = false,
                        Parent = controls,
                    })
                    corner(kbBtn, 4)
                    local kbs = stroke(kbBtn, Theme.StrokeLight, 1, 0.2)

                    local function cycleMode()
                        if mode == "Toggle" then mode = "Hold"
                        elseif mode == "Hold" then mode = "Always"
                        else mode = "Toggle" end

                        if mode == "Always" then
                            apply(true, true)
                        elseif mode == "Hold" then
                            apply(false, true)
                        else
                            apply(false, true)
                        end

                        if Window._notifyKeybindMode then
                            Window._notifyKeybindMode(toggleName, mode)
                        end
                        if Window._refreshKeybindList then Window._refreshKeybindList() end
                        if kbCfg.ModeCallback then task.spawn(kbCfg.ModeCallback, mode) end
                    end

                    kbBtn.MouseButton1Click:Connect(function()
                        listening = true
                        Library._isListeningKeybind = true
                        kbBtn.Text = "..."
                        tween(kbs, TW.Fast, { Color = Theme.Accent, Transparency = 0 })
                    end)

                    kbBtn.MouseButton2Click:Connect(cycleMode)

                    UserInputService.InputBegan:Connect(function(i, gpe)
                        if listening then
                            listening = false
                            Library._isListeningKeybind = false
                            tween(kbs, TW.Fast, { Color = Theme.StrokeLight, Transparency = 0.2 })
                            if i.UserInputType == Enum.UserInputType.Keyboard then
                                current = i.KeyCode
                            elseif i.UserInputType == Enum.UserInputType.MouseButton1 then
                                current = Enum.UserInputType.MouseButton1
                            elseif i.UserInputType == Enum.UserInputType.MouseButton2 then
                                current = Enum.UserInputType.MouseButton2
                            elseif i.UserInputType == Enum.UserInputType.MouseButton3 then
                                current = Enum.UserInputType.MouseButton3
                            end
                            kbBtn.Text = formatKeyText(current)
                            if Window._refreshKeybindList then Window._refreshKeybindList() end
                            if kbCfg.ChangedCallback then task.spawn(kbCfg.ChangedCallback, current) end
                        elseif not gpe and current then
                            if (i.KeyCode == current) or (i.UserInputType == current) then
                                if mode == "Toggle" then
                                    apply(not state, true)
                                elseif mode == "Hold" then
                                    apply(true, true)
                                elseif mode == "Always" then
                                    apply(true, true)
                                end
                                if Window._refreshKeybindList then Window._refreshKeybindList() end
                            end
                        end
                    end)

                    UserInputService.InputEnded:Connect(function(i)
                        if current and (i.KeyCode == current or i.UserInputType == current) then
                            if mode == "Hold" then
                                apply(false, true)
                                if Window._refreshKeybindList then Window._refreshKeybindList() end
                            end
                        end
                    end)

                    local function setKey(v, fire)
                        current = v
                        kbBtn.Text = formatKeyText(v)
                        if Window._refreshKeybindList then Window._refreshKeybindList() end
                        if fire and kbCfg.ChangedCallback then task.spawn(kbCfg.ChangedCallback, current) end
                    end

                    local function setMode(m)
                        mode = m or "Toggle"
                        if Window._refreshKeybindList then Window._refreshKeybindList() end
                    end

                    local kbName = kbCfg.Name or (toggleName .. " Keybind")
                    bindConfig({ Flag = kbCfg.Flag, Name = kbName, NoConfig = kbCfg.NoConfig },
                        function()
                            return {
                                Key = current and current.Name or nil,
                                Mode = mode,
                            }
                        end,
                        function(saved)
                            if type(saved) == "table" then
                                if saved.Key then
                                    local kc = Enum.KeyCode[saved.Key] or Enum.UserInputType[saved.Key]
                                    setKey(kc, true)
                                end
                                if saved.Mode then setMode(saved.Mode) end
                            elseif type(saved) == "string" then
                                local kc = Enum.KeyCode[saved] or Enum.UserInputType[saved]
                                setKey(kc, true)
                            end
                        end
                    )

                    if Window._registerKeybind then
                        Window._registerKeybind({
                            Name = toggleName,
                            GetKey = function() return current end,
                            GetMode = function() return mode end,
                            GetActive = function() return state end,
                        })
                    end

                    return {
                        Set = function(v) setKey(v, true) end,
                        Get = function() return current end,
                        SetMode = setMode,
                        GetMode = function() return mode end,
                    }
                end

                return toggleApi
            end

            --=====================================================================--
            --                            SLIDER                                     --
            --=====================================================================--
            function Section:AddSlider(o)
                o = o or {}
                local min, max = o.Min or 0, o.Max or 100
                local val = math.clamp(o.Default or min, min, max)
                local decimals = o.Decimals or 0
                local function fmt(v) return decimals > 0 and string.format("%."..decimals.."f", v) or tostring(math.floor(v)) end

                local f = row(44)
                local title = create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(o.Icon and 24 or 0, 0),
                    Size = UDim2.new(1, o.Icon and -24 or 0, 0, 20),
                    Text = (o.Name or "Slider")..": "..fmt(val)..(o.Suffix or ""),
                    TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left, Parent = f,
                })
                if o.Icon then
                    local ic = create("ImageLabel", { BackgroundTransparency = 1,
                        ImageColor3 = Theme.SubText, Position = UDim2.fromOffset(0, 2),
                        Size = UDim2.fromOffset(16,16), Parent = f })
                    applyIcon(ic, o.Icon)
                end

                local track = create("Frame", {
                    BackgroundColor3 = Theme.ToggleOff,
                    Position = UDim2.new(0, 0, 0, 28),
                    Size = UDim2.new(1, 0, 0, 8), Parent = f,
                })
                corner(track, 4)
                local fill = create("Frame", {
                    BackgroundColor3 = Theme.Accent,
                    Size = UDim2.new((val-min)/(max-min), 0, 1, 0), Parent = track,
                })
                corner(fill, 4)
                registerAccent(fill, "BackgroundColor3")

                local btn = create("TextButton", { BackgroundTransparency = 1, Size = UDim2.new(1,0,1,2),
                    Position = UDim2.fromOffset(0,-1), Text = "", Parent = track })

                local dragging = false
                local function setFromX(px)
                    local rel = math.clamp((px - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    val = min + (max - min) * rel
                    if decimals == 0 then val = math.floor(val + 0.5) end
                    tween(fill, TW.Fast, { Size = UDim2.new((val-min)/(max-min), 0, 1, 0) })
                    title.Text = (o.Name or "Slider")..": "..fmt(val)..(o.Suffix or "")
                    if o.Callback then task.spawn(o.Callback, val) end
                end
                btn.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        dragging = true; setFromX(i.Position.X)
                    end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                        setFromX(i.Position.X)
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
                end)
                local function setVal(v)
                    val = math.clamp(v, min, max)
                    fill.Size = UDim2.new((val-min)/(max-min), 0, 1, 0)
                    title.Text = (o.Name or "Slider")..": "..fmt(val)..(o.Suffix or "")
                    if o.Callback then task.spawn(o.Callback, val) end
                end
                bindConfig(o, function() return val end, setVal)
                return { Set = setVal, Get = function() return val end }
            end

            --=====================================================================--
            --                            DROPDOWN                                 --
            --=====================================================================--
            function Section:AddDropdown(o)
                o = o or {}
                local options = o.Options or {}
                local selected = o.Default or options[1]
                local open = false

                local f = row(o.Sub and 44 or 36)
                labelBlock(f, o.Name or "Dropdown", o.Icon, o.Sub, 150)

                local boxSel = create("TextButton", {
                    BackgroundColor3 = Theme.Bg,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(90, 28),
                    Text = "", AutoButtonColor = false, Parent = f,
                })
                corner(boxSel, 6); stroke(boxSel, Theme.StrokeLight, 1, 0.2)
                local selLbl = create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(8, 0), Size = UDim2.new(1, -28, 1, 0),
                    Text = tostring(selected or "..."),
                    TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = boxSel,
                })
                local arrow = create("ImageLabel", {
                    BackgroundTransparency = 1,
                    ImageColor3 = Theme.SubText,
                    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0),
                    Size = UDim2.fromOffset(16,16), Parent = boxSel,
                })
                applyIcon(arrow, "chevron-down")

                -- контейнер-обёртка (он толкает остальные элементы секции)
                local listFrame = create("Frame", {
                    BackgroundColor3 = Theme.Bg,
                    Size = UDim2.new(1, 0, 0, 0),
                    ClipsDescendants = true, Visible = false,
                    LayoutOrder = nextOrder(), Parent = box,
                })
                corner(listFrame, 6); stroke(listFrame, Theme.StrokeLight, 1, 0.2)

                -- ВНУТРИ — прокручиваемая область
                local scroll = create("ScrollingFrame", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, 0),
                    ScrollBarThickness = 3,
                    ScrollBarImageColor3 = Theme.StrokeLight,
                    CanvasSize = UDim2.new(0,0,0,0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    Parent = listFrame,
                })
                create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll })

                local function rebuild()
                    for _, c in ipairs(scroll:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                    for i, opt in ipairs(options) do
                        local ob = create("TextButton", {
                            BackgroundColor3 = Theme.Bg, BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 26), Text = "  "..tostring(opt),
                            TextColor3 = (opt == selected) and Theme.Accent or Theme.Text,
                            Font = Theme.Font, TextSize = 13, AutoButtonColor = false,
                            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 51,
                            LayoutOrder = i, Parent = scroll,
                        })
                        ob.MouseEnter:Connect(function() tween(ob, TW.Fast, { BackgroundTransparency = 0.6 }) end)
                        ob.MouseLeave:Connect(function() tween(ob, TW.Fast, { BackgroundTransparency = 1 }) end)
                        ob.MouseButton1Click:Connect(function()
                            selected = opt; selLbl.Text = tostring(opt)
                            for _, c in ipairs(scroll:GetChildren()) do
                                if c:IsA("TextButton") then c.TextColor3 = (c.Text == "  "..tostring(opt)) and Theme.Accent or Theme.Text end
                            end
                            open = false
                            tween(arrow, TW.Fast, { Rotation = 0 })
                            tween(listFrame, TW.Fast, { Size = UDim2.new(1, 0, 0, 0) })
                            task.delay(0.15, function() if not open then listFrame.Visible = false end end)
                            if o.Callback then task.spawn(o.Callback, opt) end
                        end)
                    end
                end
                rebuild()
        
                -- обновлять цвет выделенного пункта при смене акцента
                onAccentChange(function(col)
                    for _, c in ipairs(scroll:GetChildren()) do
                        if c:IsA("TextButton") then
                            c.TextColor3 = (c.Text == "  "..tostring(selected)) and col or Theme.Text
                        end
                    end
                end)

                boxSel.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        listFrame.Visible = true
                        local h = math.min(#options * 26, 160)   -- макс 160px, дальше скролл
                        tween(arrow, TW.Fast, { Rotation = 180 })
                        tween(listFrame, TW.Normal, { Size = UDim2.new(1, 0, 0, h) })
                    else
                        tween(arrow, TW.Fast, { Rotation = 0 })
                        tween(listFrame, TW.Fast, { Size = UDim2.new(1, 0, 0, 0) })
                        task.delay(0.15, function() if not open then listFrame.Visible = false end end)
                    end
                end)

                local api = {}
                function api.Set(v) selected = v; selLbl.Text = tostring(v); rebuild(); if o.Callback then task.spawn(o.Callback, v) end end
                function api.Get() return selected end
                function api.Refresh(newOpts, keep)
                    options = newOpts
                    if not keep then selected = options[1]; selLbl.Text = tostring(selected or "...") end
                    rebuild()
                end
                bindConfig(o, api.Get, api.Set)
                return api
            end
    
    
            --=====================================================================--
            --                       MULTI DROPDOWN                                  --
            --=====================================================================--
            function Section:AddMultiDropdown(o)
                o = o or {}
                local options  = o.Options or {}
                local selected = {}                       -- set: { [option] = true }
                local order    = {}                       -- preserve selection order
                local maxSel   = o.Max or math.huge       -- limit selections
                local open     = false
    
                -- init defaults
                for _, d in ipairs(o.Default or {}) do
                    selected[d] = true
                    table.insert(order, d)
                end
    
                local f = row(o.Sub and 44 or 36)
                labelBlock(f, o.Name or "Multi", o.Icon, o.Sub, 150)
    
                -- selection display button
                local boxSel = create("TextButton", {
                    BackgroundColor3 = Theme.Bg,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(90, 28),
                    Text = "", AutoButtonColor = false, Parent = f,
                })
                corner(boxSel, 6); stroke(boxSel, Theme.StrokeLight, 1, 0.2)
    
                local selLbl = create("TextLabel", {
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(8, 0),
                    Size = UDim2.new(1, -28, 1, 0),
                    TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    Parent = boxSel,
                })
    
                local arrow = create("ImageLabel", {
                    BackgroundTransparency = 1,
                    ImageColor3 = Theme.SubText,
                    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0),
                    Size = UDim2.fromOffset(16,16), Parent = boxSel,
                })
                applyIcon(arrow, "chevron-down")
    
                -- count badge (e.g. "3")
                local badge = create("Frame", {
                    BackgroundColor3 = Theme.Accent,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -26, 0.5, 0),
                    Size = UDim2.fromOffset(18, 18),
                    Visible = false, Parent = boxSel,
                })
                corner(badge, 9)
                registerAccent(badge, "BackgroundColor3")
                local badgeTxt = create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0),
                    Text = "0", TextColor3 = Theme.Bg, Font = Theme.FontBold, TextSize = 11,
                    Parent = badge,
                })
    
                -- expandable list container
                local listFrame = create("Frame", {
                    BackgroundColor3 = Theme.Bg,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.None,
                    Visible = false, ClipsDescendants = true,
                    LayoutOrder = nextOrder(), Parent = box,
                })
                corner(listFrame, 8); stroke(listFrame, Theme.StrokeLight, 1, 0.2)
    
                local scroll = create("ScrollingFrame", {
                    BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0),
                    ScrollBarThickness = 3, ScrollBarImageColor3 = Theme.StrokeLight,
                    CanvasSize = UDim2.new(0,0,0,0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y, Parent = listFrame,
                })
                padding(scroll, nil, 6, 6, 6, 6)
                create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = scroll })
    
                -- update top button label + badge
                local function updateDisplay()
                    local n = #order
                    badge.Visible = n > 0
                    badgeTxt.Text = tostring(n)
                    if n == 0 then
                        selLbl.Text = o.Placeholder or "None"
                        selLbl.TextColor3 = Theme.SubText
                        selLbl.Size = UDim2.new(1, -28, 1, 0)
                    else
                        selLbl.TextColor3 = Theme.Text
                        selLbl.Size = UDim2.new(1, -50, 1, 0)
                        selLbl.Text = table.concat(order, ", ")
                    end
                end
    
                local rowRefs = {}
    
                local function setOption(opt, state, fire)
                    local ref = rowRefs[opt]
                    if state and not selected[opt] then
                        if #order >= maxSel then return end
                        selected[opt] = true
                        table.insert(order, opt)
                    elseif (not state) and selected[opt] then
                        selected[opt] = nil
                        for i, v in ipairs(order) do if v == opt then table.remove(order, i) break end end
                    end
                    if ref then
                        tween(ref.check, TW.Fast, {
                            BackgroundColor3 = selected[opt] and Theme.Accent or Theme.Element,
                            BackgroundTransparency = 0,
                        })
                        ref.tick.Visible = selected[opt] == true
                        tween(ref.lbl, TW.Fast, { TextColor3 = selected[opt] and Theme.Text or Theme.SubText })
                    end
                    updateDisplay()
                    if fire and o.Callback then
                        task.spawn(o.Callback, table.clone(order), opt, state)
                    end
                end
    
                local function rebuild()
                    rowRefs = {}
                    for _, c in ipairs(scroll:GetChildren()) do
                        if c:IsA("TextButton") then c:Destroy() end
                    end
                    for i, opt in ipairs(options) do
                        local ob = create("TextButton", {
                            BackgroundColor3 = Theme.Element,
                            BackgroundTransparency = 0.5,
                            Size = UDim2.new(1, 0, 0, 28),
                            Text = "", AutoButtonColor = false,
                            LayoutOrder = i, Parent = scroll,
                        })
                        corner(ob, 6)
    
                        -- checkbox
                        local check = create("Frame", {
                            BackgroundColor3 = selected[opt] and Theme.Accent or Theme.Element,
                            AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.new(0, 8, 0.5, 0),
                            Size = UDim2.fromOffset(16, 16), Parent = ob,
                        })
                        corner(check, 4); stroke(check, Theme.StrokeLight, 1, 0.3)
                        local tick = create("ImageLabel", {
                            BackgroundTransparency = 1,
                            Image = "rbxassetid://3926305904",
                            ImageRectOffset = Vector2.new(312, 4), ImageRectSize = Vector2.new(24, 24),
                            ImageColor3 = Theme.Bg,
                            AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromOffset(14, 14),
                            Visible = selected[opt] == true, Parent = check,
                        })
    
                        local lbl = create("TextLabel", {
                            BackgroundTransparency = 1,
                            Position = UDim2.fromOffset(32, 0),
                            Size = UDim2.new(1, -36, 1, 0),
                            Text = tostring(opt),
                            TextColor3 = selected[opt] and Theme.Text or Theme.SubText,
                            Font = Theme.Font, TextSize = 13,
                            TextXAlignment = Enum.TextXAlignment.Left, Parent = ob,
                        })
    
                        rowRefs[opt] = { btn = ob, check = check, tick = tick, lbl = lbl }
    
                        ob.MouseEnter:Connect(function() tween(ob, TW.Fast, { BackgroundTransparency = 0.2 }) end)
                        ob.MouseLeave:Connect(function() tween(ob, TW.Fast, { BackgroundTransparency = 0.5 }) end)
                        ob.MouseButton1Click:Connect(function()
                            setOption(opt, not selected[opt], true)
                        end)
                    end
                    updateDisplay()
                end
                rebuild()

                -- обновлять цвета чекбоксов/текста при смене акцента
                onAccentChange(function(col)
                    for opt, ref in pairs(rowRefs) do
                        if selected[opt] then
                            ref.check.BackgroundColor3 = col
                        end
                    end
                end)
    
                boxSel.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        listFrame.Visible = true
                        local h = math.min(#options * 32 + 12, 180)
                        tween(arrow, TW.Fast, { Rotation = 180 })
                        tween(listFrame, TW.Normal, { Size = UDim2.new(1, 0, 0, h) })
                    else
                        tween(arrow, TW.Fast, { Rotation = 0 })
                        tween(listFrame, TW.Fast, { Size = UDim2.new(1, 0, 0, 0) })
                        task.delay(0.2, function() if not open then listFrame.Visible = false end end)
                    end
                end)
    
                -- public API
                local api = {}
                function api.Get() return table.clone(order) end
                function api.GetSet() return table.clone(selected) end
                function api.Set(list)
                    for opt in pairs(table.clone(selected)) do setOption(opt, false, false) end
                    for _, opt in ipairs(list or {}) do setOption(opt, true, false) end
                    if o.Callback then task.spawn(o.Callback, table.clone(order)) end
                end
                function api.SelectAll()
                    for _, opt in ipairs(options) do setOption(opt, true, false) end
                    if o.Callback then task.spawn(o.Callback, table.clone(order)) end
                end
                function api.ClearAll()
                    for opt in pairs(table.clone(selected)) do setOption(opt, false, false) end
                    if o.Callback then task.spawn(o.Callback, {}) end
                end
                function api.IsSelected(opt) return selected[opt] == true end
                function api.Refresh(newOpts, keep)
                    options = newOpts
                    if not keep then
                        selected = {}; order = {}
                    else
                        -- drop selections no longer valid
                        local valid = {}
                        for _, o2 in ipairs(newOpts) do valid[o2] = true end
                        local newOrder = {}
                        for _, opt in ipairs(order) do
                            if valid[opt] then table.insert(newOrder, opt) else selected[opt] = nil end
                        end
                        order = newOrder
                    end
                    rebuild()
                end
    
                -- config: store/restore the list of selected options
                bindConfig(o, api.Get, api.Set)
                return api
            end


            --=====================================================================--
            --                            TEXTBOX                                    --
            --=====================================================================--
            function Section:AddTextbox(o)
                o = o or {}
                local boxW = o.Width or 70
                local f = row(o.Sub and 44 or 36)
                labelBlock(f, o.Name or "Textbox", o.Icon, o.Sub, math.max(150, boxW + 14))

                local boxBg = create("Frame", {
                    BackgroundColor3 = Theme.Bg,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(boxW, 28), Parent = f,
                })
                corner(boxBg, 6); local bs = stroke(boxBg, Theme.StrokeLight, 1, 0.2)
                padding(boxBg, nil, 0, 0, 8, 8)
                local input = create("TextBox", {
                    BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0),
                    Text = tostring(o.Default or ""),
                    PlaceholderText = o.Placeholder or "...",
                    PlaceholderColor3 = Theme.SubText,
                    TextColor3 = Theme.Text, Font = Theme.Font, TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false, Parent = boxBg,
                })
                input.Focused:Connect(function() tween(bs, TW.Fast, { Color = Theme.Accent, Transparency = 0 }) end)
                input.FocusLost:Connect(function(enter)
                    tween(bs, TW.Fast, { Color = Theme.StrokeLight, Transparency = 0.2 })
                    local v = input.Text
                    if o.Numeric then v = tonumber(v) or 0; input.Text = tostring(v) end
                    if o.Callback then task.spawn(o.Callback, v, enter) end
                end)
                local function setText(v, fire)
                    input.Text = tostring(v)
                    if fire and o.Callback then task.spawn(o.Callback, input.Text, false) end
                end
                bindConfig(o, function() return input.Text end, function(v) setText(v, true) end)
                return { Set = function(v) setText(v, true) end, Get = function() return input.Text end }
            end

            --=====================================================================--
            --                            KEYBIND                                    --
            --=====================================================================--
            function Section:AddKeybind(o)
                o = o or {}
                local current = o.Default
                if type(current) == "string" then
                    current = Enum.KeyCode[current] or Enum.UserInputType[current] or nil
                end
                local mode = o.Mode or "Toggle" -- "Toggle" | "Hold" | "Always"
                local active = (mode == "Always")
                local listening = false
                local f = row(34)
                labelBlock(f, o.Name or "Keybind", o.Icon, nil, 90)

                local function formatKeyText(k)
                    if not k then return "None" end
                    local n = k.Name or tostring(k)
                    if #n > 8 then n = n:sub(1, 7) .. ".." end
                    return n
                end

                local keyBtn = create("TextButton", {
                    BackgroundColor3 = Theme.Bg,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(70, 26),
                    Text = formatKeyText(current),
                    TextColor3 = Theme.Text, Font = Theme.FontMed, TextSize = 12,
                    AutoButtonColor = false, Parent = f,
                })
                corner(keyBtn, 6); local ks = stroke(keyBtn, Theme.StrokeLight, 1, 0.2)

                local function cycleMode()
                    if mode == "Toggle" then mode = "Hold"
                    elseif mode == "Hold" then mode = "Always"
                    else mode = "Toggle" end

                    if mode == "Always" then
                        active = true
                        if o.Callback then task.spawn(o.Callback, true) end
                    elseif mode == "Hold" then
                        active = false
                        if o.Callback then task.spawn(o.Callback, false) end
                    else
                        active = false
                        if o.Callback then task.spawn(o.Callback, false) end
                    end

                    if Window._notifyKeybindMode then
                        Window._notifyKeybindMode(o.Name or "Keybind", mode)
                    end
                    if Window._refreshKeybindList then Window._refreshKeybindList() end
                    if o.ModeCallback then task.spawn(o.ModeCallback, mode) end
                end

                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    Library._isListeningKeybind = true
                    keyBtn.Text = "..."
                    tween(ks, TW.Fast, { Color = Theme.Accent, Transparency = 0 })
                end)

                keyBtn.MouseButton2Click:Connect(cycleMode)

                UserInputService.InputBegan:Connect(function(i, gpe)
                    if listening then
                        listening = false
                        Library._isListeningKeybind = false
                        tween(ks, TW.Fast, { Color = Theme.StrokeLight, Transparency = 0.2 })
                        if i.UserInputType == Enum.UserInputType.Keyboard then
                            current = i.KeyCode
                        elseif i.UserInputType == Enum.UserInputType.MouseButton1 then current = Enum.UserInputType.MouseButton1
                        elseif i.UserInputType == Enum.UserInputType.MouseButton2 then current = Enum.UserInputType.MouseButton2
                        elseif i.UserInputType == Enum.UserInputType.MouseButton3 then current = Enum.UserInputType.MouseButton3
                        end
                        keyBtn.Text = formatKeyText(current)
                        if Window._refreshKeybindList then Window._refreshKeybindList() end
                        if o.ChangedCallback then task.spawn(o.ChangedCallback, current) end
                    elseif not gpe and current then
                        if (i.KeyCode == current) or (i.UserInputType == current) then
                            if mode == "Toggle" then
                                active = not active
                                if o.Callback then task.spawn(o.Callback, active) end
                            elseif mode == "Hold" then
                                active = true
                                if o.Callback then task.spawn(o.Callback, true) end
                            elseif mode == "Always" then
                                active = true
                                if o.Callback then task.spawn(o.Callback, true) end
                            end
                            if Window._refreshKeybindList then Window._refreshKeybindList() end
                        end
                    end
                end)

                UserInputService.InputEnded:Connect(function(i)
                    if current and (i.KeyCode == current or i.UserInputType == current) then
                        if mode == "Hold" then
                            active = false
                            if o.Callback then task.spawn(o.Callback, false) end
                            if Window._refreshKeybindList then Window._refreshKeybindList() end
                        end
                    end
                end)

                local function setKey(v, fire)
                    current = v
                    keyBtn.Text = formatKeyText(v)
                    if Window._refreshKeybindList then Window._refreshKeybindList() end
                    if fire and o.ChangedCallback then task.spawn(o.ChangedCallback, current) end
                end

                local function setMode(m)
                    mode = m or "Toggle"
                    if Window._refreshKeybindList then Window._refreshKeybindList() end
                end

                bindConfig(o,
                    function()
                        return {
                            Key = current and current.Name or nil,
                            Mode = mode,
                        }
                    end,
                    function(saved)
                        if type(saved) == "table" then
                            if saved.Key then
                                local kc = Enum.KeyCode[saved.Key] or Enum.UserInputType[saved.Key]
                                setKey(kc, true)
                            end
                            if saved.Mode then setMode(saved.Mode) end
                        elseif type(saved) == "string" then
                            local kc = Enum.KeyCode[saved] or Enum.UserInputType[saved]
                            setKey(kc, true)
                        end
                    end
                )

                if Window._registerKeybind then
                    Window._registerKeybind({
                        Name = o.Name or "Keybind",
                        GetKey = function() return current end,
                        GetMode = function() return mode end,
                        GetActive = function() return active end,
                    })
                end

                return {
                    Set = function(v) setKey(v, true) end,
                    Get = function() return current end,
                    SetMode = setMode,
                    GetMode = function() return mode end,
                    GetActive = function() return active end,
                }
            end

            --=====================================================================--
            --                            COLOR PICKER                               --
            --=====================================================================--
            function Section:AddColorPicker(o)
                o = o or {}
                local color = o.Default or Theme.Accent
                local open = false
                local h, s, v = color:ToHSV()

                local f = row(34)
                labelBlock(f, o.Name or "Color", o.Icon, nil, 110)

                local hexLbl = create("TextLabel", {
                    BackgroundTransparency = 1,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -42, 0.5, 0),
                    Size = UDim2.fromOffset(70, 20),
                    Text = "#"..color:ToHex():upper(),
                    TextColor3 = Theme.SubText, Font = Theme.Font, TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right, Parent = f,
                })
                local swatch = create("TextButton", {
                    BackgroundColor3 = color,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(34, 26),
                    Text = "", AutoButtonColor = false, Parent = f,
                })
                corner(swatch, 6); stroke(swatch, Theme.StrokeLight, 1, 0.2)

                -- popup picker
                local pop = create("Frame", {
                    BackgroundColor3 = Theme.Bg,
                    Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.None,
                    Visible = false, ClipsDescendants = true,
                    LayoutOrder = nextOrder(), Parent = box,
                })
                corner(pop, 8); stroke(pop, Theme.StrokeLight, 1, 0.2)
                padding(pop, 10)

                local satval = create("ImageLabel", {
                    Image = "rbxassetid://4155801252",
                    BackgroundColor3 = Color3.fromHSV(h, 1, 1),
                    Size = UDim2.new(1, -28, 0, 100), Parent = pop,
                })
                corner(satval, 6)
                local svCursor = create("Frame", {
                    BackgroundColor3 = Color3.new(1,1,1), Size = UDim2.fromOffset(8,8),
                    AnchorPoint = Vector2.new(0.5,0.5), Parent = satval,
                })
                corner(svCursor, 4); stroke(svCursor, Color3.new(0,0,0), 1)

                local hueBar = create("Frame", {
                    Position = UDim2.new(1, -20, 0, 0), Size = UDim2.new(0, 20, 0, 100), Parent = pop,
                })
                corner(hueBar, 6)
                create("UIGradient", {
                    Rotation = 90,
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255,0,0)),
                        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255,255,0)),
                        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0,255,0)),
                        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0,255,255)),
                        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0,0,255)),
                        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255,0,255)),
                        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255,0,0)),
                    }), Parent = hueBar,
                })
                local hueCursor = create("Frame", {
                    BackgroundColor3 = Color3.new(1,1,1), Size = UDim2.new(1, 4, 0, 3),
                    AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, h, 0), Parent = hueBar,
                })

                local function refresh(fire)
                    color = Color3.fromHSV(h, s, v)
                    swatch.BackgroundColor3 = color
                    hexLbl.Text = "#"..color:ToHex():upper()
                    satval.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    svCursor.Position = UDim2.new(s, 0, 1 - v, 0)
                    hueCursor.Position = UDim2.new(0.5, 0, h, 0)
                    if fire and o.Callback then task.spawn(o.Callback, color) end
                end
                refresh(false)

                local svDrag, hueDrag = false, false
                satval.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then svDrag = true end
                end)
                hueBar.InputBegan:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then hueDrag = true end
                end)
                UserInputService.InputChanged:Connect(function(i)
                    if i.UserInputType ~= Enum.UserInputType.MouseMovement and i.UserInputType ~= Enum.UserInputType.Touch then return end
                    if svDrag then
                        s = math.clamp((i.Position.X - satval.AbsolutePosition.X)/satval.AbsoluteSize.X, 0, 1)
                        v = 1 - math.clamp((i.Position.Y - satval.AbsolutePosition.Y)/satval.AbsoluteSize.Y, 0, 1)
                        refresh(true)
                    elseif hueDrag then
                        h = math.clamp((i.Position.Y - hueBar.AbsolutePosition.Y)/hueBar.AbsoluteSize.Y, 0, 1)
                        refresh(true)
                    end
                end)
                UserInputService.InputEnded:Connect(function(i)
                    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                        svDrag, hueDrag = false, false
                    end
                end)

                swatch.MouseButton1Click:Connect(function()
                    open = not open
                    pop.Visible = true
                    tween(pop, TW.Normal, { Size = UDim2.new(1, 0, 0, open and 120 or 0) })
                    if not open then task.delay(0.25, function() if not open then pop.Visible = false end end) end
                end)

                local function setColor(c, fire)
                    if typeof(c) == "Color3" then
                        h,s,v = c:ToHSV()
                        refresh(fire ~= false)
                    end
                end
                bindConfig(o, function() return color end, function(c) setColor(c, true) end)
                return { Set = function(c) setColor(c, true) end, Get = function() return color end }
            end

            return Section
        end -- CreateSection

        return Tab
    end -- CreateTab

    --===============================================================================--
    --                       SETTINGS TAB (built-in)                                   --
    --===============================================================================--
    function Window:AddSettingsTab()
        local cfgDrop, autoLabel
        local tab = Window:CreateTab({ Name = "Settings", Icon = "settings" })

        --========================= INTERFACE =========================--
        local theme = tab:CreateSection({ Name = "Interface" })

        -- Масштаб ВСЕХ элементов (через winScale, дропдаун 50-150%, по умолч. 75)
        theme:AddDropdown({
            Name = "UI Scale",
            Default = "75%",
            Options = {"50%","75%","100%","125%","150%"},
            Flag = "_UIScale",
            Callback = function(v)
                local num = tonumber((tostring(v):gsub("%%", ""))) or 75
                Window._setUserScale(num / 100)
            end,
        })

        -- Клавиша открытия/закрытия меню
        theme:AddKeybind({
            Name = "Menu Toggle",
            Default = Window._toggleKey or Enum.KeyCode.RightShift,
            Flag = "_MenuKey",
            ChangedCallback = function(key)
                if type(key) == "string" then
                    key = Enum.KeyCode[key] or Enum.UserInputType[key]
                end
                if typeof(key) == "EnumItem" and (key.EnumType == Enum.KeyCode or key.EnumType == Enum.UserInputType) then
                    Window._toggleKey = key
                end
            end,
        })

        -- Цвет акцента (премиальные цвета)
        theme:AddDropdown({
            Name = "Accent Color",
            Default = "Emerald",
            Options = {
                "Emerald","Cyan","Purple","Crimson","Ocean","Gold",
                "Orange","Pink","Magenta","Lime","Teal","Rose",
                "Indigo","Sky","Ruby","Mint","Lavender","Coral",
                "Snow","Violet"
            },
            Flag = "_Accent",
            Callback = function(v)
                if PRESET_ACCENTS[v] then setAccent(PRESET_ACCENTS[v]) end
            end,
        })

        theme:AddButton({
            Name = "Reset Window Size",
            NoFastMenu = true,
            Callback = function()
                Window:SetSize(600, 340, true)
                Window:Notify({ Title = "Window", Content = "Size reset to 600x340.", Type = "Info", Duration = 1.5 })
            end,
        })

        --========================= ACTIONS =========================--
        local actions = tab:CreateSection({ Name = "Actions" })
        actions:AddButton({ Name = "Unload Menu", NoFastMenu = true, Callback = function()
            Window.Gui:Destroy()
        end })
        actions:AddButton({ Name = "Rejoin Server", NoFastMenu = true, Callback = function()
            if Window._queueTeleportExecution then Window._queueTeleportExecution() end
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end })
        actions:AddButton({ Name = "Server Hop", Primary = true, NoFastMenu = true, Callback = function()
            Window:Notify({ Title = "Server Hop", Content = "Searching for a server...", Type = "Info" })
            local ok, servers = pcall(function()
                local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
                return HttpService:JSONDecode(game:HttpGet(url))
            end)
            if ok and servers and servers.data then
                for _, s in ipairs(servers.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        pcall(function()
                            if Window._queueTeleportExecution then Window._queueTeleportExecution() end
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                        end)
                        return
                    end
                end
            end
            Window:Notify({ Title = "Server Hop", Content = "No servers found.", Type = "Error" })
        end })

        --========================= TELEPORT =========================--
        local tpSec = tab:CreateSection({ Name = "Teleport" })

        local tpToggle = tpSec:AddToggle({
            Name = "Execute on Teleport",
            Default = Window._executeOnTeleport,
            Flag = "_ExecuteOnTeleport",
            Callback = function(v)
                Window._executeOnTeleport = v
                if v and not queueTeleport then
                    Window:Notify({ Title = "Teleport", Content = "Executor does not support queue_on_teleport!", Type = "Warning", Duration = 4 })
                elseif v then
                    Window:Notify({ Title = "Teleport", Content = "Execute on Teleport enabled ("..tostring(Window._teleportDelay).."s delay)", Type = "Success", Duration = 2.5 })
                end
            end,
        })
        Window._tpToggle = tpToggle

        local tpDelaySlider = tpSec:AddSlider({
            Name = "Execution Delay",
            Min = 0,
            Max = 30,
            Default = Window._teleportDelay,
            Suffix = "s",
            Flag = "_TeleportDelay",
            Callback = function(v)
                Window._teleportDelay = v
            end,
        })
        Window._tpDelaySlider = tpDelaySlider

        --========================= FAST MENU =========================--
        local fastSec = tab:CreateSection({ Name = "Fast Menu" })

        fastSec:AddToggle({
            Name = "Enable Fast Menu",
            Default = Window._fastMenuVisible,
            NoFastMenu = true,
            Flag = "_FastMenuEnabled",
            Callback = function(v)
                Window._setFastMenuVisible(v)
            end,
        })

        local multiDrop = fastSec:AddMultiDropdown({
            Name = "Select Functions",
            Options = Window._getToggleNames(),
            Default = Window._fastMenuSelectedToggles,
            Placeholder = "Choose toggles...",
            Flag = "_FastMenuToggles",
            Callback = function(list)
                Window._setFastMenuToggles(list)
            end,
        })
        Window._fastMultiDropdown = multiDrop

        local btnMultiDrop = fastSec:AddMultiDropdown({
            Name = "Select Buttons",
            Options = Window._getButtonNames(),
            Default = Window._fastMenuSelectedButtons,
            Placeholder = "Choose buttons...",
            Flag = "_FastMenuButtons",
            Callback = function(list)
                Window._setFastMenuButtons(list)
            end,
        })
        Window._fastButtonMultiDropdown = btnMultiDrop

        fastSec:AddSlider({
            Name = "Menu Scale",
            Min = 50,
            Max = 150,
            Default = math.floor(Window._fastMenuScale * 100 + 0.5),
            Suffix = "%",
            Flag = "_FastMenuScale",
            Callback = function(v)
                Window._setFastMenuScale(v / 100)
            end,
        })

        fastSec:AddToggle({
            Name = "Lock Position",
            Default = Window._fastMenuLocked,
            NoFastMenu = true,
            Flag = "_FastMenuLocked",
            Callback = function(v)
                Window._setFastMenuLocked(v)
            end,
        })

        fastSec:AddButton({
            Name = "Reset Position",
            NoFastMenu = true,
            Callback = function()
                Window._setFastMenuPosition(UDim2.new(0, 30, 0.35, 0))
                Window:Notify({ Title = "Fast Menu", Content = "Position reset to default.", Type = "Info", Duration = 1.5 })
            end,
        })

        --========================= KEYBIND LIST =========================--
        local kbSec = tab:CreateSection({ Name = "Keybind List" })

        kbSec:AddToggle({
            Name = "Enable Keybind List",
            Default = Window._keybindListVisible,
            NoFastMenu = true,
            Flag = "_KeybindListEnabled",
            Callback = function(v)
                Window._setKeybindListVisible(v)
            end,
        })

        kbSec:AddSlider({
            Name = "HUD Scale",
            Min = 50,
            Max = 150,
            Default = math.floor(Window._keybindListScale * 100 + 0.5),
            Suffix = "%",
            Flag = "_KeybindListScale",
            Callback = function(v)
                Window._setKeybindListScale(v / 100)
            end,
        })

        kbSec:AddToggle({
            Name = "Lock Position",
            Default = Window._keybindListLocked,
            NoFastMenu = true,
            Flag = "_KeybindListLocked",
            Callback = function(v)
                Window._setKeybindListLocked(v)
            end,
        })

        kbSec:AddButton({
            Name = "Reset Position",
            NoFastMenu = true,
            Callback = function()
                Window._setKeybindListPosition(UDim2.new(0, 30, 0.62, 0))
                Window:Notify({ Title = "Keybind List", Content = "Position reset to default.", Type = "Info", Duration = 1.5 })
            end,
        })

        --========================= CONFIGURATION =========================--
        tab:Column("right")
        local cfgSec = tab:CreateSection({ Name = "Configuration" })

        local nameBox = cfgSec:AddTextbox({ Name = "Config Name", Placeholder = "my_config", NoConfig = true })

        cfgSec:AddButton({ Name = "Create Config", Primary = true, NoFastMenu = true, Callback = function()
            local n = nameBox.Get()
            n = (n or ""):gsub("[^%w_%- ]", ""):gsub("^%s+", ""):gsub("%s+$", "")
            if n == "" then
                Window:Notify({ Title = "Config", Content = "Enter a name first.", Type = "Warning" })
                return
            end
            if Library:SaveConfig(n) then
                cfgDrop.Refresh(Library:GetConfigs(), true)
                cfgDrop.Set(n)
                Window:Notify({ Title = "Config", Content = "Created '"..n.."'", Type = "Success" })
            else
                Window:Notify({ Title = "Config", Content = "Failed to create.", Type = "Error" })
            end
        end })

        -- объявляем cfgDrop через локал, чтобы кнопки выше его видели
        cfgDrop = cfgSec:AddDropdown({
            Name = "Select Config",
            Options = Library:GetConfigs(),
            Default = (Library:GetConfigs())[1] or "",
            NoConfig = true,
        })

        cfgSec:AddButton({ Name = "Load", NoFastMenu = true, Callback = function()
            local n = cfgDrop.Get()
            if n and n ~= "" then
                if Library:LoadConfig(n) then
                    Window:Notify({ Title = "Config", Content = "Loaded '"..n.."'", Type = "Success" })
                else
                    Window:Notify({ Title = "Config", Content = "Failed to load.", Type = "Error" })
                end
            else
                Window:Notify({ Title = "Config", Content = "Select a config first.", Type = "Warning" })
            end
        end })

        cfgSec:AddButton({ Name = "Overwrite", NoFastMenu = true, Callback = function()
            local n = cfgDrop.Get()
            if n and n ~= "" then
                Library:SaveConfig(n)
                Window:Notify({ Title = "Config", Content = "Overwritten '"..n.."'", Type = "Success" })
            else
                Window:Notify({ Title = "Config", Content = "Select a config first.", Type = "Warning" })
            end
        end })

        cfgSec:AddButton({ Name = "Delete", NoFastMenu = true, Callback = function()
            local n = cfgDrop.Get()
            if n and n ~= "" then
                Library:DeleteConfig(n)
                if Library:GetAutoLoad() == n then Library:ClearAutoLoad() end
                cfgDrop.Refresh(Library:GetConfigs())
                Window:Notify({ Title = "Config", Content = "Deleted '"..n.."'", Type = "Info" })
            else
                Window:Notify({ Title = "Config", Content = "Select a config first.", Type = "Warning" })
            end
        end })

        cfgSec:AddButton({ Name = "Set Auto-Load", NoFastMenu = true, Callback = function()
            local n = cfgDrop.Get()
            if n and n ~= "" then
                Library:SetAutoLoad(n)
                autoLabel.Set("Auto-Load: "..n)
                Window:Notify({ Title = "Config", Content = "Auto-load set to '"..n.."'", Type = "Success" })
            else
                Window:Notify({ Title = "Config", Content = "Select a config first.", Type = "Warning" })
            end
        end })

        cfgSec:AddButton({ Name = "Clear Auto-Load", NoFastMenu = true, Callback = function()
            Library:ClearAutoLoad()
            autoLabel.Set("Auto-Load: none")
            Window:Notify({ Title = "Config", Content = "Auto-load cleared.", Type = "Info" })
        end })

        cfgSec:AddButton({ Name = "Refresh List", NoFastMenu = true, Callback = function()
            cfgDrop.Refresh(Library:GetConfigs())
            Window:Notify({ Title = "Config", Content = "List refreshed.", Type = "Info" })
        end })

        -- статус автозагрузки
        autoLabel = cfgSec:AddLabel("Auto-Load: " .. (Library:GetAutoLoad() or "none"))

        -- автозагрузка при старте (срабатывает один раз)
        task.spawn(function()
            task.wait(0.5)
            local auto = Library:GetAutoLoad()
            if auto and auto ~= "" then
                if Library:LoadConfig(auto) then
                    Window:Notify({ Title = "Auto-Load", Content = "Loaded config '"..auto.."'", Type = "Success", Duration = 4 })
                end
            end
        end)

        return tab
    end

    gearBtn.MouseButton1Click:Connect(function()
        -- jump to last tab (settings) if exists
        local last = Window._tabs[#Window._tabs]
        if last then last._activate() end
    end)

    -- entrance animation
    winScale.Scale = userScale * 0.9
    canvas.GroupTransparency = 1
    tween(winScale, TW.Slow, { Scale = userScale })
    tween(canvas, TW.Normal, { GroupTransparency = 0 })

    return Window
end -- CreateWindow

return Library
