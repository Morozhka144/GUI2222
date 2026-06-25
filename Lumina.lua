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
    ["Emerald"] = Color3.fromRGB(0, 225, 134),
    ["Cyan"]    = Color3.fromRGB(0, 200, 255),
    ["Purple"]  = Color3.fromRGB(170, 90, 255),
    ["Crimson"] = Color3.fromRGB(255, 60, 80),
}

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
Library.Flags = {}           -- central state table

local function registerAccent(obj, prop)
    table.insert(Library.AccentObjects, { obj = obj, prop = prop })
    obj[prop] = Theme.Accent
end

local function setAccent(color)
    Theme.Accent = color
    for _, data in ipairs(Library.AccentObjects) do
        if data.obj and data.obj.Parent then
            tween(data.obj, TW.Fast, { [data.prop] = color })
        end
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
        Size = UDim2.fromOffset(820, 540),
        BackgroundColor3 = Theme.Bg,
        GroupTransparency = 0,
        Parent = gui,
    })
    corner(canvas, 14)
    stroke(canvas, Theme.Stroke, 1.5)
    local winScale = create("UIScale", { Scale = 1, Parent = canvas })

    -- shadow
    create("ImageLabel", {
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = Color3.new(0,0,0),
        ImageTransparency = 0.4,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49,49,450,450),
        Size = UDim2.new(1, 60, 1, 60),
        Position = UDim2.new(0, -30, 0, -30),
        ZIndex = 0,
        Parent = canvas,
    })

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
        Image = "rbxassetid://7733955511",
        Size = UDim2.fromOffset(26, 26),
        Position = UDim2.fromOffset(16, 14),
        Parent = topbar,
    })
    registerAccent(logo, "ImageColor3")

    create("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.fromOffset(52, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Text = cfg.Title or "MOROLUMINA.lua",
        TextColor3 = Theme.Text, Font = Theme.FontBold, TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = topbar,
    })

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

    local function makeIconBtn(img, order, callback)
        local b = create("TextButton", {
            BackgroundColor3 = Theme.Element,
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(32, 32),
            Text = "", AutoButtonColor = false, LayoutOrder = order,
            Parent = iconHolder,
        })
        corner(b, 8)
        local ic = create("ImageLabel", {
            BackgroundTransparency = 1, Image = img,
            ImageColor3 = Theme.SubText,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(18, 18), Parent = b,
        })
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

    makeIconBtn("rbxassetid://3926305904", 1) -- bell (notify)
    makeIconBtn("rbxassetid://3926307971", 2) -- key
    local gearBtn = makeIconBtn("rbxassetid://3926307971", 3) -- gear
    makeIconBtn("rbxassetid://3926305904", 4) -- profile

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
                dragging = true; dragStart = i.Position; startPos = canvas.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - dragStart
                canvas.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
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
        local grip = create("TextButton", {
            Text = "", BackgroundTransparency = 1, AutoButtonColor = false,
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, 0, 1, 0),
            Size = UDim2.fromOffset(20, 20),
            Parent = canvas,
        })
        local resizing, resStart, startSize
        grip.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                resizing = true; resStart = i.Position; startSize = canvas.Size
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if resizing and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - resStart
                local nx = math.clamp(startSize.X.Offset + d.X, 640, 1200)
                local ny = math.clamp(startSize.Y.Offset + d.Y, 420, 800)
                canvas.Size = UDim2.fromOffset(nx, ny)
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                resizing = false
            end
        end)
    end

    --========================= TOGGLE / OPEN-CLOSE =========================--
    local isOpen = true
    function Window:Toggle(state)
        if state == nil then state = not isOpen end
        isOpen = state
        if isOpen then
            canvas.Visible = true
            winScale.Scale = 0.95
            tween(winScale, TW.Slow, { Scale = 1 })
            tween(canvas, TW.Normal, { GroupTransparency = 0 })
        else
            tween(winScale, TW.Normal, { Scale = 0.95 })
            local t = tween(canvas, TW.Normal, { GroupTransparency = 1 })
            t.Completed:Connect(function()
                if not isOpen then canvas.Visible = false end
            end)
        end
    end

    local toggleKey = cfg.ToggleKey or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        if i.KeyCode == toggleKey then Window:Toggle() end
    end)

    --========================= MOBILE FLOAT BUTTON =========================--
    do
        -- 1) СНАЧАЛА создаём кнопку
        local fab = create("TextButton", {
            Name = "MobileFAB",
            BackgroundColor3 = Theme.Accent,
            Position = UDim2.new(0, 20, 0, 120),
            Size = UDim2.fromOffset(48, 48),
            Text = "",
            AutoButtonColor = false,
            ZIndex = 50,
            Parent = Window.Gui,   -- родитель ScreenGui, а НЕ canvas (чтобы не пропал при сворачивании)
        })
        corner(fab, 24)
        stroke(fab, Theme.StrokeLight, 1, 0.3)
        if registerAccent then registerAccent(fab, "BackgroundColor3") end

        local icon = create("ImageLabel", {
            BackgroundTransparency = 1,
            Image = "rbxassetid://3926305904",
            ImageRectOffset = Vector2.new(764, 244),
            ImageRectSize = Vector2.new(36, 36),
            ImageColor3 = Theme.Bg,
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(26, 26),
            ZIndex = 51,
            Parent = fab,
        })

        -- показываем только на мобильных (по желанию)
        fab.Visible = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

        -- 2) ТЕПЕРЬ вешаем события (fab гарантированно существует)
        local fdrag, fStart, fStartPos, fMoved = false, nil, nil, false

        fab.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                fdrag = true
                fMoved = false
                fStart = i.Position
                fStartPos = fab.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(i)
            if fdrag and (i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch) then
                local d = i.Position - fStart
                if d.Magnitude > 4 then fMoved = true end
                fab.Position = UDim2.new(
                    0, fStartPos.X.Offset + d.X,
                    0, fStartPos.Y.Offset + d.Y
                )
            end
        end)

        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
                if fdrag and not fMoved then
                    Window:Toggle()   -- тап без движения = открыть/закрыть меню
                end
                fdrag = false
            end
        end)
    end

    --===============================================================================--
    --                              NOTIFICATIONS                                      --
    --===============================================================================--
    local notifyHolder = create("Frame", {
        BackgroundTransparency = 1,
        AnchorPoint = Vector2.new(1, 1),
        Position = UDim2.new(1, -16, 1, -16),
        Size = UDim2.new(0, 300, 1, -32),
        Parent = gui,
    })
    create("UIListLayout", {
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
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
    local NOTIFY_ICONS = {
        Info    = "rbxassetid://3926305904",
        Success = "rbxassetid://3926305904",
        Warning = "rbxassetid://3926305904",
        Error   = "rbxassetid://3926305904",
    }

    function Window:Notify(n)
        n = n or {}
        local col = NOTIFY_COLORS[n.Type] or Theme.Accent
        local dur = n.Duration or 4

        local card = create("Frame", {
            BackgroundColor3 = Theme.Bg2,
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Parent = notifyHolder,
        })
        corner(card, 10)
        stroke(card, Theme.StrokeLight, 1, 0.4)
        local cardScale = create("UIScale", { Scale = 0.8, Parent = card })
        padding(card, nil, 10, 10, 12, 12)

        create("Frame", { -- accent bar
            BackgroundColor3 = col, BorderSizePixel = 0,
            Size = UDim2.new(0, 3, 1, -8), Position = UDim2.new(0, -8, 0, 4),
            Parent = card,
        }).Parent = card

        local title = create("TextLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -10, 0, 18),
            Text = n.Title or "Notification",
            TextColor3 = col, Font = Theme.FontBold, TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = card,
        })
        local content = create("TextLabel", {
            BackgroundTransparency = 1,
            Position = UDim2.fromOffset(0, 20),
            Size = UDim2.new(1, -10, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Text = n.Content or "",
            TextColor3 = Theme.SubText, Font = Theme.Font, TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Parent = card,
        })
        create("UIListLayout", { Padding = UDim.new(0, 2), Parent = card })
        title.LayoutOrder = 1; content.LayoutOrder = 2

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

        local tabIcon = create("ImageLabel", {
            BackgroundTransparency = 1,
            Image = tabCfg.Icon or "rbxassetid://3926305904",
            ImageColor3 = Theme.SubText,
            AnchorPoint = Vector2.new(0.5, 0),
            Position = UDim2.new(0.5, 0, 0, 12),
            Size = UDim2.fromOffset(24, 24),
            Parent = tabBtn,
        })
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
            stroke(box, Theme.Stroke, 1)
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
                    create("ImageLabel", {
                        BackgroundTransparency = 1, Image = icon,
                        ImageColor3 = Theme.SubText,
                        AnchorPoint = Vector2.new(0, 0.5),
                        Position = UDim2.new(0, 0, 0.5, 0),
                        Size = UDim2.fromOffset(16, 16),
                        Parent = parent,
                    })
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
                local f = row(20)
                local lbl = create("TextLabel", {
                    BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0),
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
                    create("ImageLabel", { BackgroundTransparency = 1, Image = o.Icon,
                        ImageColor3 = Theme.SubText, Position = UDim2.fromOffset(0, 2),
                        Size = UDim2.fromOffset(16,16), Parent = f })
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
            --                            DROPDOWN                                   --
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
                    Size = UDim2.fromOffset(140, 28),
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
                    BackgroundTransparency = 1, Image = "rbxassetid://3926305904",
                    ImageRectOffset = Vector2.new(364, 364), ImageRectSize = Vector2.new(36,36),
                    ImageColor3 = Theme.SubText,
                    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0),
                    Size = UDim2.fromOffset(16,16), Parent = boxSel,
                })

                local listFrame = create("Frame", {
                    BackgroundColor3 = Theme.Bg,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0.5, 18),
                    Size = UDim2.fromOffset(140, 0),
                    ClipsDescendants = true, Visible = false,
                    ZIndex = 50, Parent = f,
                })
                corner(listFrame, 6); stroke(listFrame, Theme.StrokeLight, 1, 0.2)
                local listLayout = create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Parent = listFrame })

                local function rebuild()
                    for _, c in ipairs(listFrame:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
                    for i, opt in ipairs(options) do
                        local ob = create("TextButton", {
                            BackgroundColor3 = Theme.Bg, BackgroundTransparency = 1,
                            Size = UDim2.new(1, 0, 0, 26), Text = "  "..tostring(opt),
                            TextColor3 = (opt == selected) and Theme.Accent or Theme.Text,
                            Font = Theme.Font, TextSize = 13, AutoButtonColor = false,
                            TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 51,
                            LayoutOrder = i, Parent = listFrame,
                        })
                        ob.MouseEnter:Connect(function() tween(ob, TW.Fast, { BackgroundTransparency = 0.6 }) end)
                        ob.MouseLeave:Connect(function() tween(ob, TW.Fast, { BackgroundTransparency = 1 }) end)
                        ob.MouseButton1Click:Connect(function()
                            selected = opt; selLbl.Text = tostring(opt)
                            for _, c in ipairs(listFrame:GetChildren()) do
                                if c:IsA("TextButton") then c.TextColor3 = (c.Text == "  "..tostring(opt)) and Theme.Accent or Theme.Text end
                            end
                            open = false
                            tween(arrow, TW.Fast, { Rotation = 0 })
                            tween(listFrame, TW.Fast, { Size = UDim2.fromOffset(140, 0) })
                            task.delay(0.15, function() if not open then listFrame.Visible = false end end)
                            if o.Callback then task.spawn(o.Callback, opt) end
                        end)
                    end
                end
                rebuild()

                boxSel.MouseButton1Click:Connect(function()
                    open = not open
                    if open then
                        listFrame.Visible = true
                        local h = math.min(#options * 26, 160)
                        tween(arrow, TW.Fast, { Rotation = 180 })
                        tween(listFrame, TW.Normal, { Size = UDim2.fromOffset(140, h) })
                    else
                        tween(arrow, TW.Fast, { Rotation = 0 })
                        tween(listFrame, TW.Fast, { Size = UDim2.fromOffset(140, 0) })
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
                    Size = UDim2.fromOffset(140, 28),
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
                    BackgroundTransparency = 1, Image = "rbxassetid://3926305904",
                    ImageRectOffset = Vector2.new(364, 364), ImageRectSize = Vector2.new(36, 36),
                    ImageColor3 = Theme.SubText,
                    AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -6, 0.5, 0),
                    Size = UDim2.fromOffset(16, 16), Parent = boxSel,
                })

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

                local rowRefs = {}  -- option -> {btn, check, lbl}

                local function setOption(opt, state, fire)
                    local ref = rowRefs[opt]
                    if state and not selected[opt] then
                        if #order >= maxSel then return end  -- limit reached
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
                    Size = UDim2.fromOffset(140, 28), Parent = f,
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
        local tab = Window:CreateTab({ Name = "Settings", Icon = "rbxassetid://3926307971" })

        local theme = tab:CreateSection({ Name = "Interface" })
        theme:AddDropdown({
            Name = "Accent Color", Default = "Emerald",
            Options = {"Emerald","Cyan","Purple","Crimson"},
            Callback = function(v) setAccent(PRESET_ACCENTS[v]) end,
        })
        theme:AddSlider({ Name = "UI Scale", Min = 80, Max = 120, Default = 100, Suffix = "%",
            Callback = function(v) winScale.Scale = v/100 end })

        tab:Column("right")
        local cfgSec = tab:CreateSection({ Name = "Configuration" })
        local nameBox = cfgSec:AddTextbox({ Name = "Config Name", Placeholder = "my_config" })
        local cfgDrop = cfgSec:AddDropdown({ Name = "Saved", Options = Library:GetConfigs(), Default = "" })

        cfgSec:AddButton({ Name = "Save Config", Primary = true, Callback = function()
            local n = nameBox.Get()
            if n ~= "" then
                Library:SaveConfig(n)
                cfgDrop.Refresh(Library:GetConfigs(), true)
                Window:Notify({ Title = "Config", Content = "Saved '"..n.."'", Type = "Success" })
            end
        end })
        cfgSec:AddButton({ Name = "Load Config", Callback = function()
            local n = cfgDrop.Get()
            if n and n ~= "" then
                Library:LoadConfig(n)
                Window:Notify({ Title = "Config", Content = "Loaded '"..n.."'", Type = "Info" })
            end
        end })
        cfgSec:AddButton({ Name = "Refresh List", Callback = function()
            cfgDrop.Refresh(Library:GetConfigs())
        end })
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

--===================================================================================--
--                                   EXAMPLE                                           --
--===================================================================================--
local Window = Library:CreateWindow({
    Title = "MOROLUMINA.lua v2.0 (Emerald Ed.)",
    ToggleKey = Enum.KeyCode.RightShift,
})

-- PLAYER TAB ----------------------------------------------------------------------
local player = Window:CreateTab({ Name = "Player", Icon = "rbxassetid://3926307971" })
local pm = player:CreateSection({ Name = "Player Module" })
pm:AddSlider({ Name = "WalkSpeed", Min = 16, Max = 200, Default = 35, Flag = "WalkSpeed",
    Callback = function(v)
        local c = LocalPlayer.Character
        if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v end
    end })
pm:AddSlider({ Name = "JumpPower", Min = 50, Max = 300, Default = 80, Flag = "JumpPower",
    Callback = function(v)
        local c = LocalPlayer.Character
        if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpPower = v end
    end })
pm:AddSlider({ Name = "FOV", Min = 70, Max = 120, Default = 110, Flag = "FOV",
    Callback = function(v) workspace.CurrentCamera.FieldOfView = v end })

player:Column("right")
local scripts = player:CreateSection({ Name = "Game Scripts" })
scripts:AddKeybind({ Name = "GUI Toggle", Default = Enum.KeyCode.RightShift,
    Callback = function() Window:Toggle() end })
scripts:AddButton({ Name = "Unload Menu", Primary = true, Callback = function()
    Window.Gui:Destroy()
end })
scripts:AddButton({ Name = "Rejoin Server", Callback = function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end })

-- VISUALS TAB ---------------------------------------------------------------------
local visuals = Window:CreateTab({ Name = "Visuals", Icon = "rbxassetid://3926305904" })
local vis = visuals:CreateSection({ Name = "Visuals" })
vis:AddToggle({ Name = "ESP", Flag = "ESP", Callback = function(v) print("ESP:", v) end })
vis:AddToggle({ Name = "Aimbot", Flag = "Aimbot" })
vis:AddToggle({ Name = "Auto-Farm", Flag = "AutoFarm" })
vis:AddToggle({ Name = "God Mode", Flag = "GodMode" })
vis:AddDropdown({ Name = "Teleport Loc", Sub = "Choose a location", Default = "City Hall",
    Options = {"City Hall","Bank","Police HQ","Garage","Spawn"} })
vis:AddDropdown({ Name = "Vehicle Spawn", Default = "Lambor",
    Options = {"Lambor","Bugatti","Police Car","Motorcycle"} })
vis:AddSlider({ Name = "Aimbot FOV", Min = 30, Max = 360, Default = 120, Flag = "AimFOV" })
vis:AddColorPicker({ Name = "Color Picker", Default = Color3.fromRGB(0, 225, 134), Flag = "ESPColor" })

-- WORLD TAB -----------------------------------------------------------------------
local world = Window:CreateTab({ Name = "World", Icon = "rbxassetid://3926305904" })
local env = world:CreateSection({ Name = "Environment" })
env:AddSlider({ Name = "Time", Min = 0, Max = 24, Default = 14, Flag = "Time",
    Callback = function(v) game.Lighting.ClockTime = v end })
env:AddToggle({ Name = "Fullbright", Flag = "Fullbright" })

-- CREDITS + SETTINGS --------------------------------------------------------------
local credits = Window:CreateTab({ Name = "Credits", Icon = "rbxassetid://3926305904" })
local cred = credits:CreateSection({ Name = "About" })
cred:AddLabel("MoroLumina UI Framework v2.0")
cred:AddLabel("Emerald Edition")
cred:AddLabel("Built from scratch — full custom lib.")

Window:AddSettingsTab()

-- auto-load last config + welcome
Window:Notify({ Title = "MoroLumina", Content = "Loaded successfully. Press RightShift to toggle.", Type = "Success", Duration = 5 })

return Library
