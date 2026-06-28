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
Library.Flags = {}           -- central state table

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
    return v
end
local function deserialize(v)
    if type(v) == "table" and v.__t then
        if v.__t == "c" then return Color3.new(v[1], v[2], v[3]) end
        if v.__t == "e" then
            local parts = string.split(v[1], ".")
            local e = Enum
            for i = 2, #parts do e = e[parts[i]] end
            return e
        end
    end
    return v
end

function Library:SaveConfig(name)
    if not hasFS or name == "" then return false end
    local out = {}
    for flag, obj in pairs(Library.Flags) do
        if obj.Get then
            local ok, val = pcall(obj.Get)
            if ok then out[flag] = serialize(val) end
        end
    end
    return pcall(writefile, CFG_DIR.."/"..name..".json", HttpService:JSONEncode(out))
end

function Library:LoadConfig(name)
    if not hasFS then return false end
    local path = CFG_DIR.."/"..name..".json"
    if not isfile(path) then return false end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
    if ok and data then
        for flag, val in pairs(data) do
            local obj = Library.Flags[flag]
            if obj and obj.Set then pcall(obj.Set, deserialize(val)) end
        end
        return true
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
        ImageTransparency = 0.4,
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

    makeIconBtn("bell", 1)
    makeIconBtn("key", 2)
    local gearBtn = makeIconBtn("settings", 3)
    makeIconBtn("user", 4)

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

    --========================= CLAMP TO SCREEN =========================--
    local function clampToScreen()
        local cam = workspace.CurrentCamera
        local screen = cam and cam.ViewportSize or Vector2.new(1920, 1080)
        local as = canvas.AbsoluteSize           -- уже с учётом UIScale
        local ap = canvas.AbsolutePosition       -- верхний-левый угол на экране

        -- насколько надо сдвинуть, чтобы окно влезло
        local shiftX, shiftY = 0, 0
        if ap.X < 0 then shiftX = -ap.X
        elseif ap.X + as.X > screen.X then shiftX = screen.X - (ap.X + as.X) end
        if ap.Y < 0 then shiftY = -ap.Y
        elseif ap.Y + as.Y > screen.Y then shiftY = screen.Y - (ap.Y + as.Y) end

        if shiftX ~= 0 or shiftY ~= 0 then
            local p = canvas.Position
            canvas.Position = UDim2.new(p.X.Scale, p.X.Offset + shiftX, p.Y.Scale, p.Y.Offset + shiftY)
        end
    end

    --========================= DRAGGING =========================--
    do
        local dragging, dragStart, startPos
        topbar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = i.Position; startPos = canvas.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - dragStart
                canvas.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
                clampToScreen()
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

        local resizing = false
        local resStart, startSize, startPos
        local dirX, dirY = 0, 0

        local function getEdge(px, py)
            local ap = canvas.AbsolutePosition
            local as = canvas.AbsoluteSize
            local e = EDGE * winScale.Scale
            local lx = px - ap.X
            local ly = py - ap.Y
            local dx, dy = 0, 0
            if lx <= e then dx = -1
            elseif lx >= as.X - e then dx = 1 end
            if ly <= e then dy = -1
            elseif ly >= as.Y - e then dy = 1 end
            return dx, dy
        end

        canvas.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                local dx, dy = getEdge(i.Position.X, i.Position.Y)
                if dx ~= 0 or dy ~= 0 then
                    resizing = true
                    dirX, dirY = dx, dy
                    resStart = i.Position
                    startSize = canvas.Size
                    startPos = canvas.Position
                end
            end
        end)

        UserInputService.InputChanged:Connect(function(i)
            if resizing and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
                -- ДЕЛИМ НА Scale (с большой S!), и защищаемся от 0/nil
                local sc = winScale.Scale
                if not sc or sc <= 0 then sc = 1 end
                local d = (i.Position - resStart) / sc

                local newW  = startSize.X.Offset
                local newH  = startSize.Y.Offset
                local newPX = startPos.X.Offset
                local newPY = startPos.Y.Offset

                if dirX == 1 then
                    newW = math.clamp(startSize.X.Offset + d.X, MIN_X, MAX_X)
                    newPX = startPos.X.Offset + (newW - startSize.X.Offset)/2
                elseif dirX == -1 then
                    newW = math.clamp(startSize.X.Offset - d.X, MIN_X, MAX_X)
                    newPX = startPos.X.Offset - (newW - startSize.X.Offset)/2
                end

                if dirY == 1 then
                    newH = math.clamp(startSize.Y.Offset + d.Y, MIN_Y, MAX_Y)
                    newPY = startPos.Y.Offset + (newH - startSize.Y.Offset)/2
                elseif dirY == -1 then
                    newH = math.clamp(startSize.Y.Offset - d.Y, MIN_Y, MAX_Y)
                    newPY = startPos.Y.Offset - (newH - startSize.Y.Offset)/2
                end

                canvas.Size     = UDim2.new(startPos.X.Scale, newW,  startPos.Y.Scale, newH)
                canvas.Position = UDim2.new(startPos.X.Scale, newPX, startPos.Y.Scale, newPY)
            end
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
  
    --========================= TOGGLE / OPEN-CLOSE =========================--
    local isOpen = true
    function Window:Toggle(state)
        if state == nil then state = not isOpen end
        isOpen = state

        local borderStroke = borderFrame:FindFirstChildOfClass("UIStroke")

        if isOpen then
            if Window._setPulse then Window._setPulse(true) end   -- ← включаем пульсацию
            canvas.Visible = true
            fxHolder.Visible = true
            winScale.Scale = 0.95
            tween(winScale, TW.Slow, { Scale = 1 })
            tween(canvas, TW.Normal, { GroupTransparency = 0 })
            for _, ch in ipairs(fxHolder:GetChildren()) do
                if ch:IsA("ImageLabel") then
                    tween(ch, TW.Normal, { ImageTransparency = ch.ImageColor3 == Color3.new(0,0,0) and 0.4 or 0.6 })
                end
            end
            if borderStroke then tween(borderStroke, TW.Normal, { Transparency = 0 }) end
        else
            if Window._setPulse then Window._setPulse(false) end  -- ← ВЫКЛЮЧАЕМ пульсацию
            tween(winScale, TW.Normal, { Scale = 0.95 })
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
    Window._toggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        if i.KeyCode == Window._toggleKey then Window:Toggle() end
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

    local NOTIFY_COLORS = {
        Info    = Theme.Accent,
        Success = Color3.fromRGB(0, 225, 134),
        Warning = Color3.fromRGB(255, 180, 40),
        Error   = Color3.fromRGB(255, 70, 80),
    }

    local _notifyOrder = 0

    function Window:Notify(n)
        n = n or {}
        local col = NOTIFY_COLORS[n.Type] or Theme.Accent
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
        create("Frame", {
            BackgroundColor3 = col, BorderSizePixel = 0,
            Size = UDim2.new(0, 3, 1, -12), Position = UDim2.new(0, 3, 0, 6),
            ZIndex = 2, Parent = card,
        })

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

            -- header title above the box (like "PLAYER MODULE")
            local titleLbl = create("TextLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 18),
                Text = string.upper(secCfg.Name or "SECTION"),
                TextColor3 = Theme.Text, Font = Theme.FontBold, TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                LayoutOrder = #parent:GetChildren(),
                Parent = parent,
            })

            local box = create("Frame", {
                BackgroundColor3 = Theme.Section,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                LayoutOrder = titleLbl.LayoutOrder + 1,
                Parent = parent,
            })
            corner(box, 12)
            local boxStroke = stroke(box, Theme.Accent, 1, 0.5)
            registerAccent(boxStroke, "Color")
            padding(box, nil, 10, 10, 12, 12)
            create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = box })

            Section._box = box
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

            local function bindFlag(flag, getter, setter)
                if flag then Library.Flags[flag] = { Get = getter, Set = setter } end
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
                return { SetText = function(t) btn.Text = t end }
            end

            --=====================================================================--
            --                            TOGGLE                                     --
            --=====================================================================--
            function Section:AddToggle(o)
                o = o or {}
                local state = o.Default or false
                local f = row(34)
                labelBlock(f, o.Name or "Toggle", o.Icon, nil, 60)

                local track = create("Frame", {
                    BackgroundColor3 = state and Theme.Accent or Theme.ToggleOff,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(44, 22),
                    Parent = f,
                })
                corner(track, 11)
                local knob = create("Frame", {
                    BackgroundColor3 = Color3.new(1,1,1),
                    AnchorPoint = Vector2.new(0, 0.5),
                    Position = state and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                    Size = UDim2.fromOffset(18, 18),
                    Parent = track,
                })
                corner(knob, 9)

                local btn = create("TextButton", { BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = "", Parent = f })

                local function apply(v, fire)
                    state = v
                    tween(track, TW.Fast, { BackgroundColor3 = v and Theme.Accent or Theme.ToggleOff })
                    tween(knob, TW.Spring, { Position = v and UDim2.new(1, -20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) })
                    if v then registerAccent(track, "BackgroundColor3") end
                    if fire and o.Callback then task.spawn(o.Callback, v) end
                end
                btn.MouseButton1Click:Connect(function() apply(not state, true) end)
                bindFlag(o.Flag, function() return state end, function(v) apply(v, true) end)
                if state then apply(true, false) end
                return { Set = function(v) apply(v, true) end, Get = function() return state end }
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
                bindFlag(o.Flag, function() return val end, setVal)
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
                bindFlag(o.Flag, api.Get, api.Set)
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
    
                -- config flag: store/restore the list of selected options
                bindFlag(o.Flag, api.Get, api.Set)
                return api
            end


            --=====================================================================--
            --                            TEXTBOX                                    --
            --=====================================================================--
            function Section:AddTextbox(o)
                o = o or {}
                local f = row(o.Sub and 44 or 36)
                labelBlock(f, o.Name or "Textbox", o.Icon, o.Sub, 150)

                local boxBg = create("Frame", {
                    BackgroundColor3 = Theme.Bg,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(70, 28), Parent = f,
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
                bindFlag(o.Flag, function() return input.Text end, function(v) input.Text = tostring(v) end)
                return { Set = function(v) input.Text = tostring(v) end, Get = function() return input.Text end }
            end

            --=====================================================================--
            --                            KEYBIND                                    --
            --=====================================================================--
            function Section:AddKeybind(o)
                o = o or {}
                local current = o.Default
                local listening = false
                local f = row(34)
                labelBlock(f, o.Name or "Keybind", o.Icon, nil, 90)

                local keyBtn = create("TextButton", {
                    BackgroundColor3 = Theme.Bg,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, 0, 0.5, 0),
                    Size = UDim2.fromOffset(70, 26),
                    Text = current and current.Name or "None",
                    TextColor3 = Theme.Text, Font = Theme.FontMed, TextSize = 12,
                    AutoButtonColor = false, Parent = f,
                })
                corner(keyBtn, 6); local ks = stroke(keyBtn, Theme.StrokeLight, 1, 0.2)

                keyBtn.MouseButton1Click:Connect(function()
                    listening = true
                    keyBtn.Text = "..."
                    tween(ks, TW.Fast, { Color = Theme.Accent, Transparency = 0 })
                end)
                UserInputService.InputBegan:Connect(function(i, gpe)
                    if listening then
                        listening = false
                        tween(ks, TW.Fast, { Color = Theme.StrokeLight, Transparency = 0.2 })
                        if i.UserInputType == Enum.UserInputType.Keyboard then
                            current = i.KeyCode
                        elseif i.UserInputType == Enum.UserInputType.MouseButton1 then current = Enum.UserInputType.MouseButton1
                        elseif i.UserInputType == Enum.UserInputType.MouseButton2 then current = Enum.UserInputType.MouseButton2
                        end
                        keyBtn.Text = current and current.Name or "None"
                        if o.ChangedCallback then task.spawn(o.ChangedCallback, current) end
                    elseif not gpe and current then
                        if (i.KeyCode == current) or (i.UserInputType == current) then
                            if o.Callback then task.spawn(o.Callback) end
                        end
                    end
                end)
                bindFlag(o.Flag,
                    function() return current end,
                    function(v) current = v; keyBtn.Text = v and v.Name or "None" end)
                return { Set = function(v) current = v; keyBtn.Text = v and v.Name or "None" end, Get = function() return current end }
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

                bindFlag(o.Flag, function() return color end, function(c) h,s,v = c:ToHSV(); refresh(true) end)
                return { Set = function(c) h,s,v = c:ToHSV(); refresh(true) end, Get = function() return color end }
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
                winScale.Scale = num / 100
            end,
        })

        -- Клавиша открытия/закрытия меню
        theme:AddKeybind({
            Name = "Menu Toggle",
            Default = Window._toggleKey,
            Flag = "_MenuKey",
            ChangedCallback = function(key)
                if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
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

        --========================= ACTIONS =========================--
        local actions = tab:CreateSection({ Name = "Actions" })
        actions:AddButton({ Name = "Unload Menu", Callback = function()
            Window.Gui:Destroy()
        end })
        actions:AddButton({ Name = "Rejoin Server", Callback = function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end })
        actions:AddButton({ Name = "Server Hop", Primary = true, Callback = function()
            Window:Notify({ Title = "Server Hop", Content = "Searching for a server...", Type = "Info" })
            local ok, servers = pcall(function()
                local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
                return HttpService:JSONDecode(game:HttpGet(url))
            end)
            if ok and servers and servers.data then
                for _, s in ipairs(servers.data) do
                    if s.playing < s.maxPlayers and s.id ~= game.JobId then
                        pcall(function()
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                        end)
                        return
                    end
                end
            end
            Window:Notify({ Title = "Server Hop", Content = "No servers found.", Type = "Error" })
        end })

        --========================= CONFIGURATION =========================--
        tab:Column("right")
        local cfgSec = tab:CreateSection({ Name = "Configuration" })

        local nameBox = cfgSec:AddTextbox({ Name = "Config Name", Placeholder = "my_config" })

        cfgSec:AddButton({ Name = "Create Config", Primary = true, Callback = function()
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
        })

        cfgSec:AddButton({ Name = "Load", Callback = function()
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

        cfgSec:AddButton({ Name = "Overwrite", Callback = function()
            local n = cfgDrop.Get()
            if n and n ~= "" then
                Library:SaveConfig(n)
                Window:Notify({ Title = "Config", Content = "Overwritten '"..n.."'", Type = "Success" })
            else
                Window:Notify({ Title = "Config", Content = "Select a config first.", Type = "Warning" })
            end
        end })

        cfgSec:AddButton({ Name = "Delete", Callback = function()
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

        cfgSec:AddButton({ Name = "Set Auto-Load", Callback = function()
            local n = cfgDrop.Get()
            if n and n ~= "" then
                Library:SetAutoLoad(n)
                autoLabel.Set("Auto-Load: "..n)
                Window:Notify({ Title = "Config", Content = "Auto-load set to '"..n.."'", Type = "Success" })
            else
                Window:Notify({ Title = "Config", Content = "Select a config first.", Type = "Warning" })
            end
        end })

        cfgSec:AddButton({ Name = "Clear Auto-Load", Callback = function()
            Library:ClearAutoLoad()
            autoLabel.Set("Auto-Load: none")
            Window:Notify({ Title = "Config", Content = "Auto-load cleared.", Type = "Info" })
        end })

        cfgSec:AddButton({ Name = "Refresh List", Callback = function()
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
    winScale.Scale = 0.9
    canvas.GroupTransparency = 1
    tween(winScale, TW.Slow, { Scale = 1 })
    tween(canvas, TW.Normal, { GroupTransparency = 0 })

    return Window
end -- CreateWindow

return Library
