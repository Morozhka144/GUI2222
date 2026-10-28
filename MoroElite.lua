--[[
    MoroElite UI Library  v2.0
    Executor UI library for Roblox (Luau).
    local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Morozhka144/GUI2222/main/MoroElite.lua"))()
]]

local cloneref = cloneref or function(x) return x end
local function S(n) return cloneref(game:GetService(n)) end

local Players = S("Players")
local UIS = S("UserInputService")
local RunService = S("RunService")
local TweenService = S("TweenService")
local HttpService = S("HttpService")
local TeleportService = S("TeleportService")
local GuiService = S("GuiService")
local Lighting = S("Lighting")
local Stats = S("Stats")
local LocalPlayer = Players.LocalPlayer

local genv = (getgenv and getgenv()) or _G
if genv.MoroLumina and genv.MoroLumina.Unload then
    pcall(function() genv.MoroLumina:Unload() end)
end

----------------------------------------------------------------------
-- Library state
----------------------------------------------------------------------
local Library = {
    Version = "2.0.0",
    Folder = "MoroLumina",
    SoundBaseUrl = "https://raw.githubusercontent.com/Morozhka144/GUI2222/main/Sounds/",
    SoundNames = { "Soft", "Payment", "Tuntun", "Voiced", "Litvin", "Vibe", "Loader", "Warn", "Error" },
    SoundFiles = {
        Soft = "soft.mp3", Payment = "payment.mp3", Tuntun = "tuntun.mp3", Voiced = "voiced.mp3", Litvin = "Litvin.mp3",
        Vibe = "vibe.mp3", Loader = "Loader.mp3", Warn = "Warn.mp3", Error = "Error.mp3",
    },
    -- character art slots: upload artN.png to the repo's Art/ folder (or drop it into MoroLumina/Art) and it replaces the placeholder
    ArtBaseUrl = "https://raw.githubusercontent.com/Morozhka144/GUI2222/main/Art/",
    Art = {
        { Name = "Art 1", Image = "art1.png" },
        { Name = "Art 2", Image = "art2.png" },
        { Name = "Art 3", Image = "art3.png" },
        { Name = "Art 4", Image = "art4.png" },
    },
    LucideUrls = {
        "https://raw.githubusercontent.com/Morozhka144/GUI2222/refs/heads/main/lucide-roblox.luau",
        "https://github.com/latte-soft/lucide-roblox/releases/latest/download/lucide-roblox.luau",
    },
}

local FONT = "rbxasset://fonts/families/BuilderSans.json"
local IMG_GLOW = "rbxassetid://8992230677"

local rgb = Color3.fromRGB
local Theme = {
    Bg = rgb(10, 10, 14),
    Side = rgb(14, 14, 19),
    Card = rgb(19, 19, 26),
    Field = rgb(26, 26, 35),
    FieldHover = rgb(34, 34, 46),
    Popup = rgb(21, 21, 29),
    Off = rgb(46, 46, 60),
    Text = rgb(242, 242, 250),
    Sub = rgb(156, 156, 178),
    Dim = rgb(100, 100, 122),
    Accent = rgb(140, 100, 255),
    Good = rgb(60, 220, 130),
    Warn = rgb(255, 186, 60),
    Bad = rgb(255, 77, 95),
    Info = rgb(70, 160, 255),
}
Library.Theme = Theme
local WHITE, BLACK = Color3.new(1, 1, 1), Color3.new(0, 0, 0)

Library.Accents = {
    { "Emerald", rgb(46, 204, 113) }, { "Cyan", rgb(0, 210, 230) }, { "Purple", rgb(140, 100, 255) },
    { "Crimson", rgb(225, 35, 70) }, { "Ocean", rgb(40, 120, 255) }, { "Gold", rgb(255, 196, 50) },
    { "Orange", rgb(255, 140, 40) }, { "Pink", rgb(255, 110, 185) }, { "Magenta", rgb(240, 40, 210) },
    { "Lime", rgb(160, 240, 50) }, { "Teal", rgb(20, 190, 170) }, { "Rose", rgb(255, 90, 125) },
    { "Indigo", rgb(95, 90, 240) }, { "Sky", rgb(90, 190, 255) }, { "Ruby", rgb(224, 17, 95) },
    { "Mint", rgb(110, 240, 190) }, { "Lavender", rgb(185, 160, 255) }, { "Coral", rgb(255, 115, 90) },
    { "Snow", rgb(236, 240, 250) }, { "Violet", rgb(150, 60, 240) },
}

local function initState()
    Library.Flags = {}
    Library.Window = nil
    Library._Binds = {}
    Library._Conns = {}
    Library._AccentObjs = {}
    Library._AccentGrads = {}
    Library._AccentFns = {}
    Library._FlagTaken = {}
    Library._FastToggles, Library._FastToggleOrder = {}, {}
    Library._FastButtons, Library._FastButtonOrder = {}, {}
    Library._FastChanged = {}
    Library._OnUnload = {}
    Library._History = {}
    Library._Scale = 1
    Library._Listening = nil
    Library._soundCache = {}
    Library._queued = false
    Library._antiAfk, Library._antiLag = nil, nil
    Library._artMissing = {}
end
initState()

----------------------------------------------------------------------
-- Utilities
----------------------------------------------------------------------
local function connect(sig, fn)
    local c = sig:Connect(fn)
    table.insert(Library._Conns, c)
    return c
end

local function call(f, ...)
    if f then
        local ok, e = pcall(f, ...)
        if not ok then warn("[MoroElite] callback error: " .. tostring(e)) end
    end
end

local EASE = Enum.EasingStyle.Quint
local function tween(o, props, t, style, dir)
    local tw = TweenService:Create(o, TweenInfo.new(t or 0.2, style or EASE, dir or Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function F(w) return Font.new(FONT, Enum.FontWeight[w or "Medium"]) end

local function new(class, props, kids)
    local o = Instance.new(class)
    if o:IsA("GuiObject") then o.BorderSizePixel = 0 end
    if o:IsA("GuiButton") then o.AutoButtonColor = false end
    if class == "TextLabel" or class == "TextButton" or class == "TextBox" then
        o.FontFace = F("Medium")
        o.TextSize = 14
        o.TextColor3 = Theme.Text
        if class ~= "TextBox" then o.BackgroundTransparency = 1 end
    elseif class == "ImageLabel" or class == "ImageButton" then
        o.BackgroundTransparency = 1
    elseif class == "ScrollingFrame" then
        o.BackgroundTransparency = 1
        o.ScrollBarThickness = 2
        o.ScrollBarImageColor3 = Theme.Accent
        o.ScrollBarImageTransparency = 0.3
        o.CanvasSize = UDim2.new()
        o.ScrollingDirection = Enum.ScrollingDirection.Y
    elseif class == "UIListLayout" then
        o.SortOrder = Enum.SortOrder.LayoutOrder
    end
    local parent
    for k, v in pairs(props or {}) do
        if k == "Parent" then parent = v
        elseif k == "W" then o.FontFace = F(v)
        else o[k] = v end
    end
    -- text objects default to transparent, but a given background color means "show it"
    if (class == "TextButton" or class == "TextLabel") and props and props.BackgroundColor3 and props.BackgroundTransparency == nil then
        o.BackgroundTransparency = 0
    end
    for _, c in ipairs(kids or {}) do c.Parent = o end
    if parent then o.Parent = parent end
    return o
end

local function corner(r) return new("UICorner", { CornerRadius = r == "full" and UDim.new(1, 0) or UDim.new(0, r) }) end
local function stroke(c, tr, th) return new("UIStroke", { Color = c or WHITE, Transparency = tr or 0.92, Thickness = th or 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }) end
local function pad(l, t, r, b) return new("UIPadding", { PaddingLeft = UDim.new(0, l or 0), PaddingTop = UDim.new(0, t or 0), PaddingRight = UDim.new(0, r or 0), PaddingBottom = UDim.new(0, b or 0) }) end
local function vlist(p) return new("UIListLayout", { Padding = UDim.new(0, p or 0) }) end
local function hlist(p, halign)
    return new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, p or 0), VerticalAlignment = Enum.VerticalAlignment.Center, HorizontalAlignment = halign or Enum.HorizontalAlignment.Left })
end

local function accent2()
    local h, s, v = Theme.Accent:ToHSV()
    return Color3.fromHSV((h + 0.07) % 1, math.min(s * 1.05, 1), v * 0.82)
end
local function trackAccent(o, prop)
    table.insert(Library._AccentObjs, { o, prop })
    o[prop] = Theme.Accent
    return o
end
local function trackGrad(g)
    table.insert(Library._AccentGrads, g)
    g.Color = ColorSequence.new(Theme.Accent, accent2())
    return g
end
local function onAccent(fn)
    table.insert(Library._AccentFns, fn)
    fn()
end
local function contrast(c)
    return (0.299 * c.R + 0.587 * c.G + 0.114 * c.B) > 0.62 and rgb(16, 16, 22) or WHITE
end

function Library:SetAccent(c)
    Theme.Accent = c
    local objs = self._AccentObjs
    for i = #objs, 1, -1 do
        local e = objs[i]
        if e[1].Parent == nil then table.remove(objs, i) else e[1][e[2]] = c end
    end
    local seq = ColorSequence.new(c, accent2())
    local gs = self._AccentGrads
    for i = #gs, 1, -1 do
        if gs[i].Parent == nil then table.remove(gs, i) else gs[i].Color = seq end
    end
    for _, f in ipairs(self._AccentFns) do pcall(f) end
end

-- functions callable both as obj.Fn(x) and obj:Fn(x)
local function API(obj, fns)
    for k, f in pairs(fns) do
        obj[k] = function(a, ...)
            if a == obj then return f(...) end
            return f(a, ...)
        end
    end
    return obj
end

local function effScale()
    local w = Library.Window
    if w and w.AnimScale then return Library._Scale * w.AnimScale.Scale end
    return Library._Scale
end

local function ptr(i)
    if i.UserInputType == Enum.UserInputType.Touch then
        return Vector2.new(i.Position.X, i.Position.Y) + GuiService:GetGuiInset()
    end
    return UIS:GetMouseLocation()
end
local function isPress(i)
    return i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch
end
local function isMove(i)
    return i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch
end
local function inside(g, p)
    local ap, as = g.AbsolutePosition, g.AbsoluteSize
    return p.X >= ap.X and p.X <= ap.X + as.X and p.Y >= ap.Y and p.Y <= ap.Y + as.Y
end

local function dragRegion(gui, fn, onStart, onEnd)
    local dragging = false
    connect(gui.InputBegan, function(i)
        if isPress(i) then
            dragging = true
            if onStart then onStart() end
            fn(ptr(i))
        end
    end)
    connect(UIS.InputChanged, function(i)
        if dragging and isMove(i) then fn(ptr(i)) end
    end)
    connect(UIS.InputEnded, function(i)
        if dragging and isPress(i) then
            dragging = false
            if onEnd then onEnd() end
        end
    end)
end

-- smooth drag of target by handle
local function dragify(handle, target, canDrag, onStart)
    local dragging, sp, st
    connect(handle.InputBegan, function(i)
        if isPress(i) and (not canDrag or canDrag()) then
            dragging, sp, st = true, ptr(i), target.Position
            if onStart then onStart() end
        end
    end)
    connect(UIS.InputChanged, function(i)
        if dragging and isMove(i) then
            local d = ptr(i) - sp
            tween(target, { Position = UDim2.new(st.X.Scale, st.X.Offset + d.X, st.Y.Scale, st.Y.Offset + d.Y) }, 0.12, Enum.EasingStyle.Quad)
        end
    end)
    connect(UIS.InputEnded, function(i)
        if dragging and isPress(i) then dragging = false end
    end)
end

local function ripple(btn, pos, color)
    local s = effScale()
    local rel = (pos - btn.AbsolutePosition) / s
    local c = new("Frame", {
        Parent = btn, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(rel.X, rel.Y),
        Size = UDim2.fromOffset(0, 0), BackgroundColor3 = color or WHITE, BackgroundTransparency = 0.82, ZIndex = 8,
    }, { corner("full") })
    local d = math.max(btn.AbsoluteSize.X, btn.AbsoluteSize.Y) / s * 2.2
    tween(c, { Size = UDim2.fromOffset(d, d), BackgroundTransparency = 1 }, 0.6, Enum.EasingStyle.Quart)
    task.delay(0.62, function() c:Destroy() end)
end

local function glow(parent, color, spread, transparency, z)
    return new("ImageLabel", {
        Parent = parent, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, spread, 1, spread),
        Image = IMG_GLOW, ImageColor3 = color or Theme.Accent, ImageTransparency = transparency or 1, ZIndex = z or 0,
    })
end
local function shadow(parent, spread, transparency)
    return new("ImageLabel", {
        Parent = parent, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, spread, 1, spread),
        Image = IMG_GLOW, ImageColor3 = BLACK, ImageTransparency = transparency or 0.4, ZIndex = 0,
    })
end

-- Base64
local B64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
local function b64enc(data)
    return ((data:gsub(".", function(x)
        local r, b = "", x:byte()
        for i = 8, 1, -1 do r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0") end
        return r
    end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
        if #x < 6 then return "" end
        local c = 0
        for i = 1, 6 do c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0) end
        return B64:sub(c + 1, c + 1)
    end) .. ({ "", "==", "=" })[#data % 3 + 1])
end
local function b64dec(data)
    data = data:gsub("[^" .. B64 .. "=]", "")
    return (data:gsub(".", function(x)
        if x == "=" then return "" end
        local r, f = "", (B64:find(x, 1, true) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0") end
        return r
    end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
        if #x ~= 8 then return "" end
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i, i) == "1" and 2 ^ (8 - i) or 0) end
        return string.char(c)
    end))
end

-- File system
local FS = {}
function FS.isfile(p) local ok, r = pcall(isfile, p) return ok and r == true end
function FS.isfolder(p) local ok, r = pcall(isfolder, p) return ok and r == true end
function FS.read(p) local ok, r = pcall(readfile, p) if ok then return r end return nil end
function FS.write(p, c) return (pcall(writefile, p, c)) end
function FS.del(p) return (pcall(delfile, p)) end
function FS.list(p) local ok, r = pcall(listfiles, p) if ok and type(r) == "table" then return r end return {} end
function FS.mkdirs(path)
    local cur = ""
    for part in path:gmatch("[^/]+") do
        cur = cur == "" and part or (cur .. "/" .. part)
        if not FS.isfolder(cur) then pcall(makefolder, cur) end
    end
end

local function httpGet(url)
    local ok, r = pcall(function() return game:HttpGet(url) end)
    if ok and type(r) == "string" then return r end
    local req = request or http_request or (syn and syn.request)
    if req then
        local ok2, res = pcall(req, { Url = url, Method = "GET" })
        if ok2 and res and (res.StatusCode == 200 or res.Success) then return res.Body end
    end
    return nil
end

----------------------------------------------------------------------
-- Lucide icons
----------------------------------------------------------------------
local Icons = { Lib = nil, Tried = false }
local ICON_ALIAS = { home = "house", ["alert-triangle"] = "triangle-alert", ["check-circle"] = "circle-check", ["x-circle"] = "circle-x" }

function Icons.Load()
    if Icons.Tried then return end
    Icons.Tried = true
    local path = Library.Folder .. "/lucide-roblox.luau"
    local src = FS.read(path)
    if not src or #src < 100 then
        src = nil
        for _, url in ipairs(Library.LucideUrls) do
            local body = httpGet(url)
            if body and #body > 100 then
                src = body
                FS.mkdirs(Library.Folder)
                FS.write(path, body)
                break
            end
        end
    end
    if src then
        local f = loadstring(src)
        if f then
            local ok, lib = pcall(f)
            if ok and type(lib) == "table" then Icons.Lib = lib end
        end
    end
end

function Icons.Get(name)
    if not Icons.Lib or not Icons.Lib.GetAsset then return nil end
    name = ICON_ALIAS[name] or name
    for _, n in ipairs({ name, "lucide-" .. name }) do
        local ok, a, b, c = pcall(Icons.Lib.GetAsset, n, 48)
        if ok and a then
            if type(a) == "table" then
                return { Image = a.Url or a.Image, RectSize = a.ImageRectSize or Vector2.zero, RectOffset = a.ImageRectOffset or Vector2.zero }
            elseif type(a) == "string" then
                return { Image = a, RectSize = b or Vector2.zero, RectOffset = c or Vector2.zero }
            end
        end
    end
    return nil
end

local function setIcon(img, name)
    if not name or name == "" then img.Visible = false return false end
    local n = tostring(name)
    if n:find("rbxasset") or tonumber(n) then
        img.Image = tonumber(n) and ("rbxassetid://" .. n) or n
        img.ImageRectSize, img.ImageRectOffset = Vector2.zero, Vector2.zero
        img.Visible = true
        return true
    end
    local info = Icons.Get(n)
    if info then
        img.Image = info.Image
        img.ImageRectSize, img.ImageRectOffset = info.RectSize, info.RectOffset
        img.Visible = true
        return true
    end
    img.Visible = false
    return false
end

-- icon image (or text fallback) centered in a holder; returns holder, image (or label)
local function makeIcon(parent, name, size, color, fallback, pos, anchor)
    local holder = new("Frame", {
        Parent = parent, BackgroundTransparency = 1, Size = UDim2.fromOffset(size, size),
        AnchorPoint = anchor or Vector2.new(0.5, 0.5), Position = pos or UDim2.fromScale(0.5, 0.5),
    })
    local img = new("ImageLabel", { Parent = holder, Size = UDim2.fromScale(1, 1), ImageColor3 = color or Theme.Text })
    if not setIcon(img, name) and fallback then
        local t = new("TextLabel", { Parent = holder, Size = UDim2.fromScale(1, 1), Text = fallback, TextSize = size, W = "Bold", TextColor3 = color or Theme.Text })
        return holder, t, true
    end
    return holder, img, false
end
local function tintIcon(obj, isText, color, t)
    tween(obj, isText and { TextColor3 = color } or { ImageColor3 = color }, t or 0.2)
end

----------------------------------------------------------------------
-- Keys
----------------------------------------------------------------------
local KEYSHORT = {
    LeftControl = "LCtrl", RightControl = "RCtrl", LeftShift = "LShift", RightShift = "RShift", LeftAlt = "LAlt", RightAlt = "RAlt",
    Return = "Enter", Backspace = "Bksp", Escape = "Esc", Delete = "Del", Insert = "Ins", PageUp = "PgUp", PageDown = "PgDn",
    CapsLock = "Caps", Zero = "0", One = "1", Two = "2", Three = "3", Four = "4", Five = "5", Six = "6", Seven = "7", Eight = "8", Nine = "9",
    MouseButton1 = "M1", MouseButton2 = "M2", MouseButton3 = "M3",
}
local MODE_LETTER = { Toggle = "T", Hold = "H", Always = "A" }
local MODE_NEXT = { Toggle = "Hold", Hold = "Always", Always = "Toggle" }

local function resolveKey(k)
    if k == nil or k == "None" or k == "" then return nil end
    if typeof(k) == "EnumItem" then return k end
    if type(k) == "string" then
        local ok, e = pcall(function() return Enum.KeyCode[k] end)
        if ok and e then return e end
        ok, e = pcall(function() return Enum.UserInputType[k] end)
        if ok and e then return e end
    end
    return nil
end
local function keyName(k)
    if not k then return "None" end
    return KEYSHORT[k.Name] or k.Name
end
local function keyMatches(input, key)
    if not key then return false end
    if key.EnumType == Enum.KeyCode then return input.KeyCode == key end
    return input.UserInputType == key
end

----------------------------------------------------------------------
-- Serializer & configs
----------------------------------------------------------------------
local function encode(v)
    local t = typeof(v)
    if t == "Color3" then return { __t = "Color3", r = v.R, g = v.G, b = v.B }
    elseif t == "EnumItem" then return { __t = "Enum", e = tostring(v.EnumType), n = v.Name }
    elseif t == "UDim2" then return { __t = "UDim2", xs = v.X.Scale, xo = v.X.Offset, ys = v.Y.Scale, yo = v.Y.Offset }
    elseif t == "Vector2" then return { __t = "Vector2", x = v.X, y = v.Y }
    elseif t == "table" then
        local out = {}
        if #v > 0 or next(v) == nil then
            for i, x in ipairs(v) do out[i] = encode(x) end
        else
            for k, x in pairs(v) do out[tostring(k)] = encode(x) end
        end
        return out
    end
    return v
end
local function decode(v)
    if type(v) ~= "table" then return v end
    local t = v.__t
    if t == "Color3" then return Color3.new(v.r, v.g, v.b)
    elseif t == "Enum" then
        local ok, e = pcall(function() return Enum[v.e][v.n] end)
        return ok and e or nil
    elseif t == "UDim2" then return UDim2.new(v.xs, v.xo, v.ys, v.yo)
    elseif t == "Vector2" then return Vector2.new(v.x, v.y) end
    local out = {}
    for k, x in pairs(v) do out[k] = decode(x) end
    return out
end
Library.Encode, Library.Decode = encode, decode

local function sanitize(n)
    n = tostring(n or ""):gsub("[^%w%-%_ ]", "")
    return (n:gsub("^%s+", ""):gsub("%s+$", ""))
end

function Library:_Register(flag, getter, setter)
    self.Flags[flag] = { Get = getter, Set = setter }
end
local function uniqueFlag(base)
    local f, i = base, 2
    while Library._FlagTaken[f] do f = base .. "_" .. i; i += 1 end
    Library._FlagTaken[f] = true
    return f
end

function Library:RegisterFunction(name, getter, setter) self:_Register(name, getter, setter) end
Library.RegisterConfig = Library.RegisterFunction

function Library:GetConfig()
    local out = {}
    for flag, e in pairs(self.Flags) do
        local ok, v = pcall(e.Get)
        if ok and v ~= nil then out[flag] = v end
    end
    return out
end

function Library:ApplyConfig(data)
    if type(data) ~= "table" then return false end
    for flag, v in pairs(data) do
        local e = self.Flags[flag]
        if e then
            local ok, err = pcall(e.Set, decode(v))
            if not ok then warn("[MoroElite] config '" .. flag .. "': " .. tostring(err)) end
        end
    end
    return true
end

function Library:_CfgDir() return self.Folder .. "/Configs/" .. tostring(game.PlaceId) end

function Library:SaveConfig(name)
    name = sanitize(name)
    if name == "" then return false, "Empty name" end
    FS.mkdirs(self:_CfgDir())
    local ok, json = pcall(HttpService.JSONEncode, HttpService, encode(self:GetConfig()))
    if not ok then return false, tostring(json) end
    if not FS.write(self:_CfgDir() .. "/" .. name .. ".json", json) then return false, "writefile failed" end
    return true
end

function Library:LoadConfig(name)
    name = sanitize(name)
    local raw = FS.read(self:_CfgDir() .. "/" .. name .. ".json")
    if not raw then return false, "Config not found" end
    local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok then return false, "Invalid JSON" end
    return self:ApplyConfig(data)
end

function Library:DeleteConfig(name)
    name = sanitize(name)
    local p = self:_CfgDir() .. "/" .. name .. ".json"
    if not FS.isfile(p) then return false end
    FS.del(p)
    if self:GetAutoLoad() == nil then self:ClearAutoLoad() end
    return true
end

function Library:GetConfigs()
    local out = {}
    for _, p in ipairs(FS.list(self:_CfgDir())) do
        local n = tostring(p):match("([^/\\]+)%.json$")
        if n then table.insert(out, n) end
    end
    table.sort(out)
    return out
end

function Library:SetAutoLoad(name)
    name = sanitize(name)
    if name == "" then return false end
    FS.mkdirs(self:_CfgDir())
    return FS.write(self:_CfgDir() .. "/_autoload.txt", name)
end
function Library:GetAutoLoad()
    local n = FS.read(self:_CfgDir() .. "/_autoload.txt")
    if n and n ~= "" and FS.isfile(self:_CfgDir() .. "/" .. n .. ".json") then return n end
    return nil
end
function Library:ClearAutoLoad()
    if FS.isfile(self:_CfgDir() .. "/_autoload.txt") then FS.del(self:_CfgDir() .. "/_autoload.txt") end
end
function Library:LoadAutoLoad()
    local n = self:GetAutoLoad()
    if n then return self:LoadConfig(n) end
    return false
end

function Library:ExportConfig()
    return "MLUMINA1:" .. b64enc(HttpService:JSONEncode(encode(self:GetConfig())))
end
function Library:ImportConfig(str)
    str = tostring(str or ""):gsub("%s", ""):gsub("^MLUMINA1:", "")
    local ok, data = pcall(function() return HttpService:JSONDecode(b64dec(str)) end)
    if not ok or type(data) ~= "table" then return false, "Invalid config string" end
    return self:ApplyConfig(data)
end

function Library:OnUnload(fn) table.insert(self._OnUnload, fn) end

----------------------------------------------------------------------
-- Sounds
----------------------------------------------------------------------
function Library:_SoundAsset(name)
    if self._soundCache[name] then return self._soundCache[name] end
    local file = self.SoundFiles[name] or (name .. ".mp3")
    local path = self.Folder .. "/Sounds/" .. file
    local ca = getcustomasset or getsynasset
    if ca then
        if not FS.isfile(path) then
            local body = httpGet(self.SoundBaseUrl .. file)
            if body and #body > 1000 then
                FS.mkdirs(self.Folder .. "/Sounds")
                FS.write(path, body)
            end
        end
        if FS.isfile(path) then
            local ok, id = pcall(ca, path)
            if ok and id then self._soundCache[name] = id return id end
        end
    end
    return "rbxasset://sounds/electronicpingshort.wav"
end

-- volume is 0..1 (the 0-100% slider); 100% plays at SOUND_GAIN x the default Roblox loudness
local SOUND_GAIN = 2

function Library:PlaySound(name, volume)
    local win = self.Window
    task.spawn(function()
        local id = self:_SoundAsset(name)
        if not win or not win.Gui or not win.Gui.Parent then return end
        local s = new("Sound", { SoundId = id, Volume = (volume or win.NotifySoundVolume or 0.5) * SOUND_GAIN, Parent = win.Gui })
        s:Play()
        s.Ended:Once(function() s:Destroy() end)
        task.delay(10, function() if s.Parent then s:Destroy() end end)
    end)
end

----------------------------------------------------------------------
-- Teleport / server tools
----------------------------------------------------------------------
function Library:_QueueTeleport()
    local q = queue_on_teleport or (syn and syn.queue_on_teleport) or queueonteleport
    if not q then return false end
    local w = self.Window
    local src
    if w.TeleportScript and #w.TeleportScript > 0 then
        src = w.TeleportScript
    elseif w.TeleportUrl and #w.TeleportUrl > 0 then
        src = ("loadstring(game:HttpGet(%q))()"):format(w.TeleportUrl)
    else
        src = ("loadstring(readfile(%q))()"):format(w.TeleportFile)
    end
    local code = ("if not game:IsLoaded() then game.Loaded:Wait() end\ntask.wait(%s)\n%s"):format(tostring(w.TeleportDelay), src)
    return (pcall(q, code))
end

function Library:Rejoin()
    if #Players:GetPlayers() <= 1 then
        LocalPlayer:Kick("\nRejoining...")
        task.wait()
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
end

-- Anti-AFK: answer Roblox's idle kick timer with a virtual right click
function Library:SetAntiAFK(enabled)
    if self._antiAfk then self._antiAfk:Disconnect() self._antiAfk = nil end
    if not enabled then return end
    self._antiAfk = connect(LocalPlayer.Idled, function()
        pcall(function()
            local vu = game:GetService("VirtualUser")
            vu:Button2Down(Vector2.zero, workspace.CurrentCamera.CFrame)
            task.wait(1)
            vu:Button2Up(Vector2.zero, workspace.CurrentCamera.CFrame)
        end)
    end)
end

-- Anti-Lag: strip heavy rendering from the world, and keep doing it for objects spawned later.
-- Turning it off stops processing new objects; what was already simplified stays until rejoin.
local function lightenObject(obj)
    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.Plastic
        obj.Reflectance = 0
        obj.CastShadow = false
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 1
    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
        obj.Enabled = false
    elseif obj:IsA("Explosion") then
        obj.Visible = false
    end
end

function Library:SetAntiLag(enabled)
    if self._antiLag then self._antiLag:Disconnect() self._antiLag = nil end
    if not enabled then return end
    local ownBlur = self.Window and self.Window.Blur
    pcall(function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize, terrain.WaterWaveSpeed = 0, 0
            terrain.WaterReflectance, terrain.WaterTransparency = 0, 0
        end
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.Brightness = 1
        for _, fx in ipairs(Lighting:GetChildren()) do
            if fx:IsA("PostEffect") and fx ~= ownBlur then fx.Enabled = false end
        end
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    end)
    self._antiLag = connect(workspace.DescendantAdded, function(obj) pcall(lightenObject, obj) end)
    -- existing objects in chunks so a big map does not freeze the client for a second
    task.spawn(function()
        for i, obj in ipairs(workspace:GetDescendants()) do
            if not self._antiLag then return end
            pcall(lightenObject, obj)
            if i % 4000 == 0 then task.wait() end
        end
    end)
end

function Library:ServerHop()
    local w = self.Window
    local body = httpGet(("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100"):format(game.PlaceId))
    if not body then
        if w then w:Notify({ Title = "Server Hop", Text = "Failed to fetch server list", Type = "error" }) end
        return
    end
    local ok, data = pcall(HttpService.JSONDecode, HttpService, body)
    local pick
    if ok and data and data.data then
        for _, s in ipairs(data.data) do
            if s.id ~= game.JobId and s.playing and s.maxPlayers and s.playing < s.maxPlayers then pick = s break end
        end
    end
    if not pick then
        if w then w:Notify({ Title = "Server Hop", Text = "No suitable server found", Type = "warning" }) end
        return
    end
    if w then w:Notify({ Title = "Server Hop", Text = ("Joining server with %d/%d players"):format(pick.playing, pick.maxPlayers), Type = "success" }) end
    TeleportService:TeleportToPlaceInstance(game.PlaceId, pick.id, LocalPlayer)
end

----------------------------------------------------------------------
-- Keybind core
----------------------------------------------------------------------
local function createBind(spec)
    local B = { Name = spec.Name, Key = resolveKey(spec.Key), Mode = MODE_LETTER[spec.Mode] and spec.Mode or "Toggle", Active = false, NoHUD = spec.NoBind }
    local chip = new("TextButton", {
        Parent = spec.Parent, LayoutOrder = spec.Order or 1, Size = UDim2.fromOffset(0, 24), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Theme.Field, Text = "", TextSize = 12, RichText = true, TextColor3 = Theme.Sub, W = "SemiBold", ZIndex = spec.ZIndex or 1,
    }, { corner(6), pad(9, 0, 9, 0) })
    local cst = stroke(WHITE, 0.92)
    cst.Parent = chip
    B.Chip = chip

    local function label()
        if B.Listening then
            chip.Text = "..."
            chip.TextColor3 = Theme.Accent
            return
        end
        local t = keyName(B.Key)
        if not spec.NoBind then
            t = t .. ('  <font color="#%s" size="10">%s</font>'):format(Theme.Accent:ToHex(), MODE_LETTER[B.Mode])
        end
        chip.Text = t
        chip.TextColor3 = B.Key and Theme.Text or Theme.Dim
    end
    B.Label = label
    function B:_fire(v)
        if self.Active == v then return end
        self.Active = v
        if spec.OnActive then call(spec.OnActive, v) end
        Library:_HudRefresh()
    end
    function B:SetKey(k, silent)
        self.Key = resolveKey(k)
        label()
        if not silent and spec.OnKey then call(spec.OnKey, self.Key) end
        if not self.Key and self.Mode == "Hold" then self:_fire(false) end
        Library:_HudRefresh()
    end
    function B:SetMode(m, silent)
        if not MODE_LETTER[m] then return end
        local old = self.Mode
        self.Mode = m
        label()
        if old == "Always" and m ~= "Always" then self:_fire(false) end
        if m == "Always" then self:_fire(true) elseif m == "Hold" then self:_fire(false) end
        if not silent and spec.OnMode then call(spec.OnMode, m) end
        Library:_HudRefresh()
    end
    function B:StopListen()
        self.Listening = false
        if Library._Listening == self then Library._Listening = nil end
        tween(cst, { Color = WHITE, Transparency = 0.92 }, 0.2)
        label()
    end

    chip.MouseEnter:Connect(function() tween(chip, { BackgroundColor3 = Theme.FieldHover }, 0.15) end)
    chip.MouseLeave:Connect(function() tween(chip, { BackgroundColor3 = Theme.Field }, 0.15) end)
    connect(chip.MouseButton1Click, function()
        if B.Listening then return end
        if Library._Listening then Library._Listening:StopListen() end
        B.Listening = true
        Library._Listening = B
        label()
        task.spawn(function()
            local on = true
            while B.Listening and chip.Parent do
                tween(cst, { Color = Theme.Accent, Transparency = on and 0 or 0.6 }, 0.45, Enum.EasingStyle.Sine)
                on = not on
                task.wait(0.45)
            end
        end)
    end)
    connect(chip.MouseButton2Click, function()
        if B.Listening or spec.NoBind then return end
        B:SetMode(MODE_NEXT[B.Mode])
    end)
    onAccent(label)
    if not spec.NoBind then
        table.insert(Library._Binds, B)
        task.defer(function() Library:_HudRefresh() end)
        if B.Mode == "Always" then task.defer(function() B:_fire(true) end) end
    end
    return B
end

function Library:_HudRefresh()
    local w = self.Window
    if w and w.KeybindList then w.KeybindList:Refresh() end
end

----------------------------------------------------------------------
-- Color picker body (used inside popups)
----------------------------------------------------------------------
local PRESETS = { rgb(255, 255, 255), rgb(255, 77, 95), rgb(255, 150, 50), rgb(255, 214, 60), rgb(70, 220, 120), rgb(40, 200, 230), rgb(70, 130, 255), rgb(160, 100, 255), rgb(255, 100, 190) }

local function buildPicker(parent, init, onChange)
    local h, s, v = init:ToHSV()
    local frame = new("Frame", { Parent = parent, Size = UDim2.new(1, 0, 0, 236), BackgroundTransparency = 1 })
    local sv = new("Frame", { Parent = frame, Size = UDim2.new(1, 0, 0, 132), BackgroundColor3 = Color3.fromHSV(h, 1, 1) }, { corner(8) })
    new("Frame", { Parent = sv, Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE }, { corner(8), new("UIGradient", { Transparency = NumberSequence.new(0, 1) }) })
    new("Frame", { Parent = sv, Size = UDim2.fromScale(1, 1), BackgroundColor3 = BLACK }, { corner(8), new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0) }) })
    local svMark = new("Frame", { Parent = sv, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = init, ZIndex = 3 }, {
        corner("full"), new("UIStroke", { Color = WHITE, Thickness = 2 }),
    })
    local hue = new("Frame", { Parent = frame, Position = UDim2.fromOffset(0, 144), Size = UDim2.new(1, 0, 0, 10), BackgroundColor3 = WHITE }, {
        corner("full"),
        new("UIGradient", { Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(0, 1, 1)), ColorSequenceKeypoint.new(1 / 6, Color3.fromHSV(1 / 6, 1, 1)),
            ColorSequenceKeypoint.new(2 / 6, Color3.fromHSV(2 / 6, 1, 1)), ColorSequenceKeypoint.new(3 / 6, Color3.fromHSV(3 / 6, 1, 1)),
            ColorSequenceKeypoint.new(4 / 6, Color3.fromHSV(4 / 6, 1, 1)), ColorSequenceKeypoint.new(5 / 6, Color3.fromHSV(5 / 6, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV(0, 1, 1)),
        }) }),
    })
    local hueMark = new("Frame", { Parent = hue, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = Color3.fromHSV(h, 1, 1), ZIndex = 3 }, {
        corner("full"), new("UIStroke", { Color = WHITE, Thickness = 2 }),
    })
    local preview = new("Frame", { Parent = frame, Position = UDim2.fromOffset(0, 166), Size = UDim2.fromOffset(28, 28), BackgroundColor3 = init }, { corner(8), stroke(WHITE, 0.85) })
    local hex = new("TextBox", {
        Parent = frame, Position = UDim2.fromOffset(36, 166), Size = UDim2.new(1, -36, 0, 28), BackgroundColor3 = Theme.Field,
        Text = "#" .. init:ToHex():upper(), ClearTextOnFocus = false, TextSize = 13, W = "SemiBold", PlaceholderText = "#RRGGBB / R,G,B",
        PlaceholderColor3 = Theme.Dim, TextXAlignment = Enum.TextXAlignment.Left,
    }, { corner(7), stroke(WHITE, 0.92), pad(10, 0, 10, 0) })
    local presets = new("Frame", { Parent = frame, Position = UDim2.fromOffset(0, 206), Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1 }, {
        new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Center, Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }),
    })

    local function color() return Color3.fromHSV(h, s, v) end
    local function render()
        sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        svMark.Position = UDim2.fromScale(s, 1 - v)
        svMark.BackgroundColor3 = color()
        hueMark.Position = UDim2.fromScale(h, 0.5)
        hueMark.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
        preview.BackgroundColor3 = color()
        if not hex:IsFocused() then hex.Text = "#" .. color():ToHex():upper() end
    end
    local function emit() render() onChange(color()) end
    dragRegion(sv, function(p)
        s = math.clamp((p.X - sv.AbsolutePosition.X) / math.max(sv.AbsoluteSize.X, 1), 0, 1)
        v = 1 - math.clamp((p.Y - sv.AbsolutePosition.Y) / math.max(sv.AbsoluteSize.Y, 1), 0, 1)
        emit()
    end, function() tween(svMark, { Size = UDim2.fromOffset(18, 18) }, 0.15) end, function() tween(svMark, { Size = UDim2.fromOffset(14, 14) }, 0.2) end)
    dragRegion(hue, function(p)
        h = math.clamp((p.X - hue.AbsolutePosition.X) / math.max(hue.AbsoluteSize.X, 1), 0, 0.999)
        emit()
    end, function() tween(hueMark, { Size = UDim2.fromOffset(18, 18) }, 0.15) end, function() tween(hueMark, { Size = UDim2.fromOffset(14, 14) }, 0.2) end)
    connect(hex.FocusLost, function()
        local t = hex.Text:gsub("%s", "")
        local c
        local r, g, b = t:match("^(%d+),(%d+),(%d+)$")
        if r then
            c = rgb(math.clamp(tonumber(r), 0, 255), math.clamp(tonumber(g), 0, 255), math.clamp(tonumber(b), 0, 255))
        else
            local hx = t:gsub("#", "")
            if #hx == 6 and tonumber(hx, 16) then
                local n = tonumber(hx, 16)
                c = rgb(math.floor(n / 65536) % 256, math.floor(n / 256) % 256, n % 256)
            end
        end
        if c then h, s, v = c:ToHSV() emit() else render() end
    end)
    for i, pc in ipairs(PRESETS) do
        local b = new("TextButton", { Parent = presets, LayoutOrder = i, Size = UDim2.fromOffset(20, 20), BackgroundColor3 = pc, Text = "" }, { corner(6), stroke(WHITE, 0.85) })
        b.MouseEnter:Connect(function() tween(b, { Size = UDim2.fromOffset(22, 22) }, 0.15) end)
        b.MouseLeave:Connect(function() tween(b, { Size = UDim2.fromOffset(20, 20) }, 0.15) end)
        b.MouseButton1Click:Connect(function() h, s, v = pc:ToHSV() emit() end)
    end
    render()
    return { Frame = frame, Refresh = function(c) h, s, v = c:ToHSV() render() end }
end

----------------------------------------------------------------------
-- 3D character view (ViewportFrame with a copy of the character)
----------------------------------------------------------------------
-- copy of a player's character that can live in a ViewportFrame: scripts, sounds, name tags and tools
-- removed, every part anchored so the pose stays as it was at the moment of copying
local function cloneCharacter(plr)
    local char = plr and plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local ok, copy = pcall(function()
        local archivable = char.Archivable
        char.Archivable = true
        local c = char:Clone()
        char.Archivable = archivable
        return c
    end)
    if not ok or not copy then return nil end
    for _, d in ipairs(copy:GetDescendants()) do
        if d:IsA("LuaSourceContainer") or d:IsA("Sound") or d:IsA("BillboardGui") or d:IsA("ForceField")
            or d:IsA("ParticleEmitter") or d:IsA("Trail") or d:IsA("Beam") or d:IsA("Tool") then
            d:Destroy()
        elseif d:IsA("BasePart") then
            d.Anchored = true
        end
    end
    -- the copy is frozen mid-animation; rebuild the rest pose by putting every part where its joint
    -- says (C0/C1 without the animation Transform), walking outwards from the root
    local root = copy:FindFirstChild("HumanoidRootPart")
    local joints = {}
    for _, j in ipairs(copy:GetDescendants()) do
        if j:IsA("JointInstance") and j.Part0 and j.Part1 then table.insert(joints, j) end
    end
    local placed = { [root] = true }
    for _ = 1, 32 do
        local progress = false
        for _, j in ipairs(joints) do
            if placed[j.Part0] and not placed[j.Part1] then
                j.Part1.CFrame = j.Part0.CFrame * j.C0 * j.C1:Inverse()
                placed[j.Part1], progress = true, true
            elseif placed[j.Part1] and not placed[j.Part0] then
                j.Part0.CFrame = j.Part1.CFrame * j.C1 * j.C0:Inverse()
                placed[j.Part0], progress = true, true
            end
        end
        if not progress then break end
    end
    local hum = copy:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        hum.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
    end
    copy:PivotTo(CFrame.new(0, 3, 0))
    return copy
end

-- loading ring: an accent circle whose bright arc keeps turning; returns a function that fades it out
local function spinner(parent, size, z)
    local ring = new("Frame", {
        Parent = parent, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(size, size),
        BackgroundTransparency = 1, ZIndex = z,
    }, { corner("full") })
    local st = new("UIStroke", { Parent = ring, Thickness = math.max(2, size / 14), Color = Theme.Accent })
    trackAccent(st, "Color")
    local grad = new("UIGradient", { Parent = st, Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.45, 0.15), NumberSequenceKeypoint.new(0.55, 1), NumberSequenceKeypoint.new(1, 1),
    }) })
    local t = 0
    local conn = RunService.RenderStepped:Connect(function(dt)
        t += dt
        grad.Rotation = (t * 360) % 360
        st.Transparency = 0.15 + math.sin(t * 4) * 0.15
    end)
    table.insert(Library._Conns, conn)
    return function()
        tween(st, { Transparency = 1 }, 0.25)
        task.delay(0.26, function() conn:Disconnect() ring:Destroy() end)
    end
end

-- opts: Player (default LocalPlayer), HeadOnly (close-up of the head, no rotation), Yaw (starting angle),
-- OnFail (called when no character shows up within 10 s). A loading ring spins until the model is in.
-- drag turns the model; a flick keeps spinning and eases out, left alone it slowly turns by itself
local function characterView(parent, opts)
    opts = opts or {}
    local vp = new("ViewportFrame", {
        Parent = parent, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, LightColor = WHITE,
        Ambient = rgb(150, 150, 165), LightDirection = Vector3.new(-0.6, -1, -0.8), ZIndex = opts.ZIndex or 1,
    })
    local world = Instance.new("WorldModel")
    world.Parent = vp
    local cam = Instance.new("Camera")
    cam.FieldOfView = opts.HeadOnly and 22 or 30
    cam.Parent = vp
    vp.CurrentCamera = cam

    local model, centre, height
    -- the copy faces -Z, so the camera starts on that side (a bit to the right) to see the face, not the back
    local yaw, spin, idle, dragging = opts.Yaw or (math.pi - 0.35), 0, 2, false
    local function load()
        if model then model:Destroy() end
        model = cloneCharacter(opts.Player or LocalPlayer)
        if not model then return end
        model.Parent = world
        local head = model:FindFirstChild("Head")
        local root = model:FindFirstChild("HumanoidRootPart")
        if opts.HeadOnly and head then
            centre, height = head.Position, 2
        else
            -- frame the body itself: only parts sitting directly in the model (accessories live inside
            -- Accessory instances), so held weapons, wings or hats do not shrink or shift the figure
            local top, bottom = -math.huge, math.huge
            for _, p in ipairs(model:GetChildren()) do
                if p:IsA("BasePart") and p ~= root then
                    local half = p.Size.Y / 2
                    top = math.max(top, p.Position.Y + half)
                    bottom = math.min(bottom, p.Position.Y - half)
                end
            end
            if top == -math.huge then
                local cf, size = model:GetBoundingBox()
                top, bottom = cf.Position.Y + size.Y / 2, cf.Position.Y - size.Y / 2
            end
            local base = root and root.Position or Vector3.new(0, (top + bottom) / 2, 0)
            centre = Vector3.new(base.X, (top + bottom) / 2, base.Z)
            height = math.max(top - bottom, 3) * 1.12
        end
    end
    -- wait (up to 10 s) for the character and its full appearance, so the copy is not missing clothes/hats
    vp.ImageTransparency = 1
    -- (AbsoluteSize is still 0 while the window is being built, so the head ring sizes from the offset)
    local headSize = parent.Size.X.Offset > 0 and parent.Size.X.Offset or 32
    local stopSpin = spinner(parent, opts.HeadOnly and math.floor(headSize * 0.55 + 0.5) or 34, (opts.ZIndex or 1) + 1)
    task.spawn(function()
        local plr = opts.Player or LocalPlayer
        local t0 = os.clock()
        repeat
            local char = plr.Character
            local ready = char and char:FindFirstChild("HumanoidRootPart") and plr:HasAppearanceLoaded()
            if ready then break end
            task.wait(0.2)
        until not vp.Parent or os.clock() - t0 > 10
        if not vp.Parent then return end
        load()
        stopSpin()
        if model then
            tween(vp, { ImageTransparency = 0 }, 0.4)
        elseif opts.OnFail then
            call(opts.OnFail)
        end
    end)

    local hint
    if not opts.HeadOnly then
        hint = new("TextLabel", {
            Parent = parent, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -8), Size = UDim2.fromOffset(0, 14),
            AutomaticSize = Enum.AutomaticSize.X, Text = "drag to rotate", TextSize = 11, W = "Regular", TextColor3 = Theme.Dim, ZIndex = (opts.ZIndex or 1) + 1,
        })
        local grab = new("TextButton", { Parent = parent, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = (opts.ZIndex or 1) + 2 })
        local lastX, lastT
        dragRegion(grab, function(p)
            local now = os.clock()
            if lastX then
                local dx = p.X - lastX
                yaw -= dx * 0.012
                spin = -dx * 0.012 / math.max(now - lastT, 1 / 240)
            end
            lastX, lastT = p.X, now
        end, function()
            dragging, lastX, idle = true, nil, 0
            if hint then hint.Visible = false end
        end, function()
            dragging, idle = false, 0
        end)
    end

    local conn
    conn = RunService.RenderStepped:Connect(function(dt)
        if not vp.Parent then conn:Disconnect() return end
        if not centre or vp.AbsoluteSize.X < 2 then return end
        if opts.Active and not opts.Active() then return end -- page not shown: skip the camera work
        if not opts.HeadOnly and not dragging then
            spin *= math.exp(-dt * 3.2)
            idle += dt
            yaw += spin * dt + (idle > 1.4 and 0.38 * dt or 0)
        end
        local dist = (height * 0.5) / math.tan(math.rad(cam.FieldOfView) * 0.5) * (opts.HeadOnly and 1.25 or 1.18)
        local eye = centre + (CFrame.Angles(0, yaw, 0) * CFrame.new(0, opts.HeadOnly and 0.1 or 0.6, dist)).Position
        cam.CFrame = CFrame.lookAt(eye, centre)
    end)
    table.insert(Library._Conns, conn)

    local charConn = (opts.Player or LocalPlayer).CharacterAppearanceLoaded:Connect(function()
        task.wait(0.5)
        if vp.Parent then load() end
    end)
    table.insert(Library._Conns, charConn)
    vp.Destroying:Connect(function() conn:Disconnect() charConn:Disconnect() end)

    return { Viewport = vp, Refresh = load, HasModel = function() return model ~= nil end }
end

-- fills a round frame with the player's avatar: a live 3D head (loading ring meanwhile);
-- the first letter of the name only if no character turns up
local function fillAvatar(parent, textSize, z)
    local letter = new("TextLabel", { Parent = parent, Size = UDim2.fromScale(1, 1), Text = LocalPlayer.DisplayName:sub(1, 1):upper(), W = "Bold", TextSize = textSize or 15, ZIndex = z, Visible = false })
    trackAccent(letter, "TextColor3")
    local head = characterView(parent, { HeadOnly = true, ZIndex = z, OnFail = function() letter.Visible = true end })
    corner("full").Parent = head.Viewport
end

----------------------------------------------------------------------
-- Floating HUD panels (Fast Menu / Keybinds)
----------------------------------------------------------------------
local function makePanel(win, title, icon, defaultPos)
    local P = { Locked = false, Scale = 1, Shown = false }
    P.Frame = new("CanvasGroup", {
        Parent = win.Gui, Name = title, Position = defaultPos, Size = UDim2.fromOffset(200, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Side, Visible = false, GroupTransparency = 1, Active = true,
    }, { corner(10), stroke(WHITE, 0.9), vlist(0) })
    P.UIScale = new("UIScale", { Parent = P.Frame })
    local header = new("Frame", { Parent = P.Frame, LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 34), BackgroundTransparency = 1 })
    local _, ic, isText = makeIcon(header, icon, 14, Theme.Accent, "•", UDim2.fromOffset(12, 17), Vector2.new(0, 0.5))
    onAccent(function() if isText then ic.TextColor3 = Theme.Accent else ic.ImageColor3 = Theme.Accent end end)
    new("TextLabel", { Parent = header, Position = UDim2.fromOffset(32, 0), Size = UDim2.new(1, -40, 1, 0), Text = title, W = "Bold", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left })
    local line = new("Frame", { Parent = header, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = WHITE })
    new("UIGradient", { Parent = line, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.5, 0.85), NumberSequenceKeypoint.new(1, 1) }) })
    P.List = new("Frame", { Parent = P.Frame, LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, { vlist(4), pad(8, 8, 8, 8) })
    dragify(header, P.Frame, function() return not P.Locked end)

    function P:SetVisible(b)
        b = b and true or false
        self.Shown = b
        if b then
            self.Frame.Visible = true
            tween(self.Frame, { GroupTransparency = 0 }, 0.3)
        else
            tween(self.Frame, { GroupTransparency = 1 }, 0.2)
            task.delay(0.21, function() if not self.Shown then self.Frame.Visible = false end end)
        end
    end
    function P:IsVisible() return self.Shown end
    function P:SetScale(n) self.Scale = math.clamp(tonumber(n) or 1, 0.5, 1.5) tween(self.UIScale, { Scale = self.Scale }, 0.2) end
    function P:GetScale() return self.Scale end
    function P:SetLocked(b) self.Locked = b and true or false end
    function P:SetPosition(p) if typeof(p) == "UDim2" then tween(self.Frame, { Position = p }, 0.3) end end
    function P:GetPosition() return self.Frame.Position end
    return P
end

local function clearList(list)
    for _, c in ipairs(list:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
end

local function miniSwitch(parent)
    local track = new("Frame", { Parent = parent, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(28, 16), BackgroundColor3 = Theme.Off }, { corner("full") })
    local on = new("Frame", { Parent = track, Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 1 }, { corner("full") })
    trackGrad(new("UIGradient", { Parent = on }))
    local knob = new("Frame", { Parent = track, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = rgb(200, 200, 215), ZIndex = 2 }, { corner("full") })
    return function(val, instant)
        local t = instant and 0 or 0.25
        tween(on, { BackgroundTransparency = val and 0 or 1 }, t)
        tween(knob, { Position = val and UDim2.new(0, 15, 0.5, 0) or UDim2.new(0, 3, 0.5, 0), BackgroundColor3 = val and WHITE or rgb(200, 200, 215) }, t)
    end
end

local function buildFastMenu(win)
    local P = makePanel(win, "Fast Menu", "zap", UDim2.new(0, 20, 0.3, 0))
    P.SelToggles, P.SelButtons, P.Rows = {}, {}, {}

    function P:Refresh()
        clearList(self.List)
        self.Rows = {}
        local shown = 0
        for _, name in ipairs(Library._FastToggleOrder) do
            if table.find(self.SelToggles, name) then
                shown += 1
                local obj = Library._FastToggles[name]
                local row = new("TextButton", { Parent = self.List, LayoutOrder = shown, Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = Theme.Field, Text = "" }, { corner(7) })
                local lbl = new("TextLabel", { Parent = row, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -50, 1, 0), Text = name, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
                local upd = miniSwitch(row)
                local function set(v, instant)
                    upd(v, instant)
                    tween(lbl, { TextColor3 = v and Theme.Text or Theme.Sub }, instant and 0 or 0.2)
                end
                set(obj.Get(), true)
                self.Rows[name] = set
                row.MouseEnter:Connect(function() tween(row, { BackgroundColor3 = Theme.FieldHover }, 0.15) end)
                row.MouseLeave:Connect(function() tween(row, { BackgroundColor3 = Theme.Field }, 0.15) end)
                connect(row.MouseButton1Click, function() obj.Set(not obj.Get()) end)
            end
        end
        for _, name in ipairs(Library._FastButtonOrder) do
            if table.find(self.SelButtons, name) then
                shown += 1
                local entry = Library._FastButtons[name]
                local row = new("TextButton", { Parent = self.List, LayoutOrder = shown, Size = UDim2.new(1, 0, 0, 28), BackgroundColor3 = Theme.Field, Text = name, TextSize = 13, ClipsDescendants = true }, { corner(7), stroke(WHITE, 0.93) })
                row.MouseEnter:Connect(function() tween(row, { BackgroundColor3 = Theme.FieldHover }, 0.15) end)
                row.MouseLeave:Connect(function() tween(row, { BackgroundColor3 = Theme.Field }, 0.15) end)
                connect(row.MouseButton1Click, function()
                    ripple(row, UIS:GetMouseLocation(), Theme.Accent)
                    entry.Fire()
                end)
            end
        end
        if shown == 0 then
            new("TextLabel", { Parent = self.List, Size = UDim2.new(1, 0, 0, 24), Text = "Select functions in Settings", TextColor3 = Theme.Dim, TextSize = 12 })
        end
    end
    local function norm(t)
        local out = {}
        for k, v in pairs(t or {}) do
            if type(k) == "number" then table.insert(out, tostring(v)) elseif v then table.insert(out, tostring(k)) end
        end
        return out
    end
    function P:SetToggles(t) self.SelToggles = norm(t) self:Refresh() if self.OnSel then self.OnSel() end end
    function P:SetButtons(t) self.SelButtons = norm(t) self:Refresh() if self.OnSel then self.OnSel() end end
    P:Refresh()
    return P
end

local function buildKeybindList(win)
    local P = makePanel(win, "Keybinds", "keyboard", UDim2.new(1, -230, 0.3, 0))
    P.Cache = {}
    local empty = new("TextLabel", { Parent = P.List, LayoutOrder = 9999, Size = UDim2.new(1, 0, 0, 22), Text = "No keybinds", TextColor3 = Theme.Dim, TextSize = 12 })
    function P:Refresh()
        local any = false
        for i, b in ipairs(Library._Binds) do
            local show = b.Key ~= nil or b.Mode == "Always"
            local c = self.Cache[b]
            if show and not c then
                local row = new("Frame", { Parent = self.List, Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1 })
                local dotGlow = new("ImageLabel", { Parent = row, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 6, 0.5, 0), Size = UDim2.fromOffset(22, 22), Image = IMG_GLOW, ImageTransparency = 1 })
                local dot = new("Frame", { Parent = row, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0, 6, 0.5, 0), Size = UDim2.fromOffset(6, 6), BackgroundColor3 = Theme.Off }, { corner("full") })
                local nm = new("TextLabel", { Parent = row, Position = UDim2.fromOffset(18, 0), Size = UDim2.new(1, -86, 1, 0), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
                local kb = new("TextLabel", {
                    Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, 0, 0.5, 0), Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X,
                    BackgroundColor3 = Theme.Field, BackgroundTransparency = 0, TextSize = 11, W = "SemiBold", TextColor3 = Theme.Sub, RichText = true,
                }, { corner(5), pad(7, 0, 7, 0) })
                c = { Row = row, Dot = dot, Glow = dotGlow, Name = nm, Key = kb }
                self.Cache[b] = c
            end
            if c then
                any = any or show
                c.Row.Visible = show
                c.Row.LayoutOrder = i
                c.Name.Text = b.Name
                c.Key.Text = keyName(b.Key) .. ('  <font color="#%s">%s</font>'):format(Theme.Accent:ToHex(), MODE_LETTER[b.Mode])
                tween(c.Dot, { BackgroundColor3 = b.Active and Theme.Accent or Theme.Off }, 0.2)
                c.Glow.ImageColor3 = Theme.Accent
                tween(c.Glow, { ImageTransparency = b.Active and 0.3 or 1 }, 0.25)
                tween(c.Name, { TextColor3 = b.Active and Theme.Text or Theme.Dim }, 0.2)
            end
        end
        empty.Visible = not any
    end
    onAccent(function() P:Refresh() end)
    P:Refresh()
    return P
end

----------------------------------------------------------------------
-- Classes
----------------------------------------------------------------------
local Window, Tab, Column, Section = {}, {}, {}, {}
Window.__index, Tab.__index, Column.__index, Section.__index = Window, Tab, Column, Section

local function nextOrder(sec) sec._n = (sec._n or 0) + 1 return sec._n end

-- flat row with hover highlight; returns row, name label
local function mkRow(sec, h, name, desc)
    if desc then h = h + 14 end
    local row = new("Frame", { Parent = sec.Content, LayoutOrder = nextOrder(sec), Size = UDim2.new(1, 0, 0, h), BackgroundColor3 = WHITE, BackgroundTransparency = 1 }, { corner(8) })
    local lbl = new("TextLabel", {
        Parent = row, Position = UDim2.fromOffset(10, desc and 8 or 0), Size = UDim2.new(1, -20, 0, desc and 18 or h), Text = name,
        TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd,
    })
    if desc then
        new("TextLabel", { Parent = row, Position = UDim2.fromOffset(10, 26), Size = UDim2.new(1, -20, 0, 14), Text = desc, TextSize = 12, W = "Regular", TextColor3 = Theme.Dim, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
    end
    row.MouseEnter:Connect(function() tween(row, { BackgroundTransparency = 0.965 }, 0.18) end)
    row.MouseLeave:Connect(function() tween(row, { BackgroundTransparency = 1 }, 0.25) end)
    return row, lbl
end

-- right-aligned controls; when label is given, the label stretches up to the controls (re-fits when chips/swatches are added)
local function rightBox(row, label, labelX)
    local box = new("Frame", {
        Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1, ZIndex = 3,
    }, { new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }) })
    if label then
        local function fit()
            local w = box.AbsoluteSize.X / effScale()
            label.Size = UDim2.new(1, -(labelX or 10) - w - 18, 0, label.Size.Y.Offset)
        end
        box:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
        fit()
    end
    return box
end

local function attachTip(obj, text)
    if not text or text == "" then return end
    obj.MouseEnter:Connect(function()
        Library._tipTarget = obj
        task.delay(0.45, function()
            if Library._tipTarget == obj and Library.Window then Library.Window:_ShowTip(text) end
        end)
    end)
    obj.MouseLeave:Connect(function()
        if Library._tipTarget == obj then
            Library._tipTarget = nil
            if Library.Window then Library.Window:_HideTip() end
        end
    end)
end

local function finish(sec, row, name, cfg)
    sec.Window:_AddSearch(name, row, sec)
    attachTip(row, cfg.Tooltip)
end

local function flagFor(cfg, name)
    if cfg.NoConfig then return nil end
    return uniqueFlag(cfg.Flag or name)
end

local function parseColor(c)
    if typeof(c) == "Color3" then return c end
    if type(c) == "table" and c.r then return Color3.new(c.r, c.g, c.b) end
    return nil
end

-- field box (dropdown / textbox style)
local function field(parent, widthScale, minW)
    local f = new("TextButton", {
        Parent = parent, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(widthScale or 0.5, -8, 0, 28),
        BackgroundColor3 = Theme.Field, Text = "", ZIndex = 3,
    }, { corner(7), new("UISizeConstraint", { MinSize = Vector2.new(minW or 110, 28) }) })
    local st = stroke(WHITE, 0.92)
    st.Parent = f
    f.MouseEnter:Connect(function() tween(f, { BackgroundColor3 = Theme.FieldHover }, 0.15) end)
    f.MouseLeave:Connect(function() tween(f, { BackgroundColor3 = Theme.Field }, 0.15) end)
    return f, st
end

----------------------------------------------------------------------
-- Section
----------------------------------------------------------------------
local function createSection(tab, colFrame, cfg)
    cfg = cfg or {}
    -- every section collapses unless explicitly disabled with Collapsible = false
    local sec = setmetatable({ Tab = tab, Window = tab.Window, Name = cfg.Name or "Section", Collapsible = cfg.Collapsible ~= false, Collapsed = false, Callback = cfg.Callback }, Section)
    local HEAD = 44
    -- explicit height (not AutomaticSize): AutomaticSize also counts the clipped content, so a collapsed card would keep its full height
    local frame = new("Frame", { Parent = colFrame, LayoutOrder = #tab.Sections + 1, Size = UDim2.new(1, 0, 0, HEAD), BackgroundColor3 = Theme.Card, ClipsDescendants = true }, { corner(12), stroke(WHITE, 0.93) })
    new("UIGradient", { Parent = frame, Rotation = 90, Color = ColorSequence.new(rgb(255, 255, 255), rgb(205, 205, 215)) })
    sec.Frame = frame
    local header = new("TextButton", { Parent = frame, Size = UDim2.new(1, 0, 0, 44), BackgroundTransparency = 1, Text = "" })
    local tx = 16
    if cfg.Icon then
        local _, ic, isText = makeIcon(header, cfg.Icon, 16, Theme.Accent, nil, UDim2.fromOffset(16, 22), Vector2.new(0, 0.5))
        onAccent(function() if isText then ic.TextColor3 = Theme.Accent else ic.ImageColor3 = Theme.Accent end end)
        tx = 40
    else
        local dot = new("Frame", { Parent = header, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 16, 0.5, 0), Size = UDim2.fromOffset(6, 6), BackgroundColor3 = Theme.Accent }, { corner("full") })
        trackAccent(dot, "BackgroundColor3")
        local g = glow(dot, Theme.Accent, 16, 0.4)
        trackAccent(g, "ImageColor3")
        tx = 30
    end
    new("TextLabel", { Parent = header, Position = UDim2.fromOffset(tx, 0), Size = UDim2.new(1, -tx - 40, 1, 0), Text = sec.Name, W = "Bold", TextSize = 15, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
    local chevObj, chevText
    if sec.Collapsible then
        local _, ic, isText = makeIcon(header, "chevron-down", 16, Theme.Sub, "v", UDim2.new(1, -16, 0.5, 0), Vector2.new(1, 0.5))
        chevObj, chevText = ic, isText
        header.MouseEnter:Connect(function() tintIcon(chevObj, chevText, Theme.Text) end)
        header.MouseLeave:Connect(function() tintIcon(chevObj, chevText, Theme.Sub) end)
    end
    local sep = new("Frame", { Parent = frame, Position = UDim2.new(0, 14, 0, 43), Size = UDim2.new(1, -28, 0, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 0.94 })
    local holder = new("Frame", { Parent = frame, Position = UDim2.fromOffset(0, 44), Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, ClipsDescendants = true })
    local content = new("Frame", { Parent = holder, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
    local layout = vlist(2)
    layout.Parent = content
    pad(6, 6, 6, 0).Parent = content
    sec.Content, sec.Holder = content, holder

    local function target() return layout.AbsoluteContentSize.Y / effScale() + 14 end
    local function sync()
        if sec.Collapsed or sec._anim then return end
        local h = target()
        holder.Size = UDim2.new(1, 0, 0, h)
        frame.Size = UDim2.new(1, 0, 0, HEAD + h)
    end
    sec.Sync = sync
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(sync)

    function sec:SetCollapsed(v, animate)
        v = v and true or false
        if v == self.Collapsed then return end
        self.Collapsed = v
        if chevObj then tween(chevObj, { Rotation = v and -90 or 0 }, 0.3) end
        tween(sep, { BackgroundTransparency = v and 1 or 0.94 }, 0.2)
        local goal = v and 0 or target()
        if animate == false then
            holder.Size = UDim2.new(1, 0, 0, goal)
            frame.Size = UDim2.new(1, 0, 0, HEAD + goal)
        else
            self._anim = true
            -- holder keeps its full height while closing so content slides under the card edge
            if not v then holder.Size = UDim2.new(1, 0, 0, goal) end
            local tw = tween(frame, { Size = UDim2.new(1, 0, 0, HEAD + goal) }, 0.35)
            tw.Completed:Once(function()
                self._anim = false
                if self.Collapsed then holder.Size = UDim2.new(1, 0, 0, 0) end
                sync()
            end)
        end
        call(self.Callback, v)
    end
    function sec:IsCollapsed() return self.Collapsed end

    if sec.Collapsible then
        connect(header.MouseButton1Click, function() sec:SetCollapsed(not sec.Collapsed, true) end)
        if cfg.Collapsed then sec:SetCollapsed(true, false) end
        if cfg.Flag then
            Library:_Register(uniqueFlag(cfg.Flag), function() return sec.Collapsed end, function(v) sec:SetCollapsed(v, false) end)
        end
    end
    table.insert(tab.Sections, sec)
    return sec
end

function Column:CreateSection(cfg) return createSection(self.Tab, self.Frame, cfg) end

----------------------------------------------------------------------
-- Elements
----------------------------------------------------------------------
function Section:AddLabel(text)
    local lbl = new("TextLabel", {
        Parent = self.Content, LayoutOrder = nextOrder(self), Size = UDim2.new(1, 0, 0, 20), AutomaticSize = Enum.AutomaticSize.Y,
        Text = tostring(text or ""), TextColor3 = Theme.Sub, TextSize = 13, W = "Regular", TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, RichText = true,
    }, { pad(10, 2, 10, 2) })
    return API({}, { Set = function(t) lbl.Text = tostring(t) end })
end

function Section:AddDivider()
    local f = new("Frame", { Parent = self.Content, LayoutOrder = nextOrder(self), Size = UDim2.new(1, 0, 0, 9), BackgroundTransparency = 1 })
    new("Frame", { Parent = f, Position = UDim2.new(0, 10, 0.5, 0), Size = UDim2.new(1, -20, 0, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 0.93 })
end

function Section:AddButton(cfg)
    cfg = cfg or {}
    local name = cfg.Name or "Button"
    local primary = cfg.Primary
    local wrap = new("Frame", { Parent = self.Content, LayoutOrder = nextOrder(self), Size = UDim2.new(1, 0, 0, 38), BackgroundTransparency = 1 })
    local gl
    if primary then gl = glow(wrap, Theme.Accent, 30, 0.75) trackAccent(gl, "ImageColor3") end
    local row = new("TextButton", {
        Parent = wrap, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, -8, 0, 32),
        BackgroundColor3 = primary and WHITE or Theme.Field, Text = "", ClipsDescendants = true, ZIndex = 2,
    }, { corner(8) })
    local scale = new("UIScale", { Parent = row })
    local st = stroke(WHITE, primary and 0.8 or 0.92)
    st.Parent = row
    if primary then trackGrad(new("UIGradient", { Parent = row, Rotation = 15 })) end
    local inner = new("Frame", { Parent = row, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 3 }, { hlist(8, Enum.HorizontalAlignment.Center) })
    local iconObj, iconText
    if cfg.Icon then
        local h
        h, iconObj, iconText = makeIcon(inner, cfg.Icon, 15, Theme.Text, nil)
        h.LayoutOrder = 1
    end
    local lbl = new("TextLabel", { Parent = inner, LayoutOrder = 2, Size = UDim2.fromOffset(0, 32), AutomaticSize = Enum.AutomaticSize.X, Text = name, W = primary and "Bold" or "SemiBold", ZIndex = 3 })
    onAccent(function()
        if primary then
            local c = contrast(Theme.Accent)
            lbl.TextColor3 = c
            if iconObj then if iconText then iconObj.TextColor3 = c else iconObj.ImageColor3 = c end end
        end
    end)
    row.MouseEnter:Connect(function()
        if primary then tween(gl, { ImageTransparency = 0.5 }, 0.2) tween(st, { Transparency = 0.6 }, 0.2)
        else tween(row, { BackgroundColor3 = Theme.FieldHover }, 0.15) tween(st, { Transparency = 0.85 }, 0.15) end
    end)
    row.MouseLeave:Connect(function()
        tween(scale, { Scale = 1 }, 0.3, Enum.EasingStyle.Back)
        if primary then tween(gl, { ImageTransparency = 0.75 }, 0.25) tween(st, { Transparency = 0.8 }, 0.25)
        else tween(row, { BackgroundColor3 = Theme.Field }, 0.2) tween(st, { Transparency = 0.92 }, 0.2) end
    end)
    connect(row.MouseButton1Down, function()
        ripple(row, UIS:GetMouseLocation(), primary and WHITE or Theme.Accent)
        tween(scale, { Scale = 0.97 }, 0.1, Enum.EasingStyle.Quad)
    end)
    connect(row.MouseButton1Up, function() tween(scale, { Scale = 1 }, 0.35, Enum.EasingStyle.Back) end)
    local function fire() call(cfg.Callback) end
    connect(row.MouseButton1Click, fire)
    self.Window:_AddSearch(name, wrap, self)
    attachTip(row, cfg.Tooltip)
    if not cfg.NoFastMenu then Library:_RegFastButton(name, fire) end
    return API({}, { SetText = function(t) lbl.Text = tostring(t) end, Fire = fire })
end

function Library:_RegFastButton(name, fire)
    if not self._FastButtons[name] then table.insert(self._FastButtonOrder, name) end
    self._FastButtons[name] = { Fire = fire }
    for _, f in ipairs(self._FastChanged) do pcall(f) end
end
function Library:_RegFastToggle(name, obj)
    if not self._FastToggles[name] then table.insert(self._FastToggleOrder, name) end
    self._FastToggles[name] = obj
    for _, f in ipairs(self._FastChanged) do pcall(f) end
end

function Section:AddToggle(cfg)
    cfg = cfg or {}
    local win = self.Window
    local name = cfg.Name or "Toggle"
    local row, label = mkRow(self, 36, name, cfg.Description)
    local xo = 10
    local iconObj, iconText
    if cfg.Icon then
        local _
        _, iconObj, iconText = makeIcon(row, cfg.Icon, 16, Theme.Sub, nil, UDim2.new(0, 10, 0, cfg.Description and 17 or 18), Vector2.new(0, 0.5))
        xo = 34
        label.Position = UDim2.new(0, xo, 0, label.Position.Y.Offset)
    end
    label.TextColor3 = Theme.Sub
    local click = new("TextButton", { Parent = row, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 1 })
    local right = rightBox(row, label, xo)

    local sw = new("Frame", { Parent = right, LayoutOrder = 10, Size = UDim2.fromOffset(40, 22), BackgroundTransparency = 1, ZIndex = 3 })
    local gl = glow(sw, Theme.Accent, 34, 1, 3)
    trackAccent(gl, "ImageColor3")
    local track = new("Frame", { Parent = sw, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Off, ZIndex = 3 }, { corner("full"), stroke(WHITE, 0.92) })
    local on = new("Frame", { Parent = track, Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 1, ZIndex = 3 }, { corner("full") })
    trackGrad(new("UIGradient", { Parent = on }))
    local knob = new("Frame", { Parent = track, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 3, 0.5, 0), Size = UDim2.fromOffset(16, 16), BackgroundColor3 = rgb(190, 190, 205), ZIndex = 4 }, { corner("full") })

    local obj = { Value = false }
    local listeners = {}
    local function knobPos() return obj.Value and UDim2.new(0, 40 - 3 - 16, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) end
    local function render(anim)
        local t = anim and 0.16 or 0
        tween(on, { BackgroundTransparency = obj.Value and 0 or 1 }, t, Enum.EasingStyle.Quad)
        tween(gl, { ImageTransparency = obj.Value and 0.55 or 1 }, anim and 0.25 or 0, Enum.EasingStyle.Quad)
        tween(knob, { Position = knobPos(), BackgroundColor3 = obj.Value and WHITE or rgb(190, 190, 205) }, anim and 0.2 or 0, Enum.EasingStyle.Quart)
        tween(label, { TextColor3 = obj.Value and Theme.Text or Theme.Sub }, t, Enum.EasingStyle.Quad)
        if iconObj then tintIcon(iconObj, iconText, obj.Value and Theme.Accent or Theme.Sub, t) end
    end
    local function set(v, silent)
        v = v and true or false
        if v == obj.Value then return end
        obj.Value = v
        render(true)
        for _, f in ipairs(listeners) do call(f, v) end
        if not silent then call(cfg.Callback, v) end
    end
    onAccent(function() if iconObj and obj.Value then tintIcon(iconObj, iconText, Theme.Accent, 0) end end)
    if cfg.Default then
        obj.Value = true
        render(false)
        task.defer(function()
            for _, f in ipairs(listeners) do call(f, true) end
            call(cfg.Callback, true)
        end)
    else
        render(false)
    end
    -- react on press for mouse (no release wait); on release for touch so scrolling does not toggle
    local touchStart
    connect(click.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            set(not obj.Value)
        elseif i.UserInputType == Enum.UserInputType.Touch then
            touchStart = i.Position
        end
    end)
    connect(click.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.Touch and touchStart and (i.Position - touchStart).Magnitude < 10 then
            set(not obj.Value)
        end
        touchStart = nil
    end)
    local flag = flagFor(cfg, name)
    if flag then Library:_Register(flag, function() return obj.Value end, function(v) set(v) end) end

    API(obj, {
        Set = set,
        Get = function() return obj.Value end,
        AddListener = function(fn) table.insert(listeners, fn) end,
    })
    if not cfg.NoFastMenu then
        Library:_RegFastToggle(name, obj)
        table.insert(listeners, function(v)
            local fm = win.FastMenu
            if fm and fm.Rows[name] then fm.Rows[name](v) end
        end)
    end

    function obj.AddColorPicker(a, b)
        local c2 = (a == obj) and b or a
        c2 = c2 or {}
        local color = parseColor(c2.Default) or WHITE
        local swatch = new("TextButton", { Parent = right, LayoutOrder = 2, Size = UDim2.fromOffset(24, 18), BackgroundColor3 = color, Text = "", ZIndex = 4 }, { corner(6), stroke(WHITE, 0.8) })
        local ref = {}
        local function cset(c, silent)
            c = parseColor(c)
            if not c then return end
            color = c
            swatch.BackgroundColor3 = c
            if win._popup and win._popup.Anchor == swatch and win._popup.Picker then win._popup.Picker.Refresh(c) end
            if not silent then call(c2.Callback, c) end
        end
        connect(swatch.MouseButton1Click, function()
            win:_OpenColorPopup(swatch, function() return color end, function(c) color = c swatch.BackgroundColor3 = c call(c2.Callback, c) end)
        end)
        local f2 = (not c2.NoConfig) and uniqueFlag(c2.Flag or ((flag or name) .. "_Color")) or nil
        if f2 then Library:_Register(f2, function() return color end, function(v) cset(v) end) end
        return API(ref, { Set = cset, Get = function() return color end })
    end

    function obj.AddKeybind(a, b)
        local c2 = (a == obj) and b or a
        c2 = c2 or {}
        local ref = {}
        local bind = createBind({
            Name = name, Key = c2.Default, Mode = c2.Mode, Parent = right, Order = 1, ZIndex = 4,
            OnActive = function(v) set(v) end,
        })
        bind.Active = obj.Value
        table.insert(listeners, function(v) bind.Active = v Library:_HudRefresh() end)
        local f2 = (not c2.NoConfig) and uniqueFlag((flag or name) .. "_Key") or nil
        if f2 then
            Library:_Register(f2, function() return { Key = bind.Key or "None", Mode = bind.Mode } end, function(v)
                if type(v) == "table" then
                    bind:SetKey(v.Key, true)
                    if v.Mode then bind:SetMode(v.Mode, true) end
                end
            end)
        end
        return API(ref, {
            Set = function(k) bind:SetKey(k) end, Get = function() return bind.Key end,
            SetMode = function(m) bind:SetMode(m) end, GetMode = function() return bind.Mode end,
        })
    end

    finish(self, row, name, cfg)
    return obj
end

function Section:AddSlider(cfg)
    cfg = cfg or {}
    local name = cfg.Name or "Slider"
    local min, max = cfg.Min or 0, cfg.Max or 100
    local dec = cfg.Decimals or 0
    local suffix = cfg.Suffix or ""
    local row, label = mkRow(self, 54, name, nil)
    label.Size = UDim2.new(1, -100, 0, 30)
    label.Position = UDim2.fromOffset(10, 2)
    local pill = new("Frame", {
        Parent = row, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 6), Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Theme.Field, ZIndex = 3,
    }, { corner(6), stroke(WHITE, 0.93), new("UISizeConstraint", { MinSize = Vector2.new(42, 22) }) })
    local box = new("TextBox", {
        Parent = pill, Size = UDim2.fromScale(0, 1), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, Text = "",
        TextColor3 = Theme.Text, TextSize = 13, W = "SemiBold", ClearTextOnFocus = true, ZIndex = 4,
    }, { pad(8, 0, 8, 0) })
    local bar = new("Frame", { Parent = row, Position = UDim2.fromOffset(12, 38), Size = UDim2.new(1, -24, 0, 6), BackgroundColor3 = Theme.Off }, { corner("full") })
    local fill = new("Frame", { Parent = bar, Size = UDim2.fromScale(0, 1), BackgroundColor3 = WHITE }, { corner("full") })
    trackGrad(new("UIGradient", { Parent = fill }))
    local kglow = new("ImageLabel", { Parent = fill, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(40, 40), Image = IMG_GLOW, ImageTransparency = 1, ZIndex = 2 })
    trackAccent(kglow, "ImageColor3")
    local knob = new("Frame", { Parent = fill, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(1, 0.5), Size = UDim2.fromOffset(14, 14), BackgroundColor3 = WHITE, ZIndex = 3 }, { corner("full") })
    local kst = new("UIStroke", { Parent = knob, Thickness = 2, Color = Theme.Accent })
    trackAccent(kst, "Color")
    local hit = new("TextButton", { Parent = row, Position = UDim2.fromOffset(4, 28), Size = UDim2.new(1, -8, 0, 24), BackgroundTransparency = 1, Text = "", ZIndex = 5 })

    local value = min
    local dragging, hovering = false, false
    local function round(x) local m = 10 ^ dec return math.floor(x * m + 0.5) / m end
    local function fmt(x) return tostring(round(x)) .. suffix end
    local function render(anim)
        local r = (max > min) and (value - min) / (max - min) or 0
        tween(fill, { Size = UDim2.fromScale(r, 1) }, anim and 0.18 or 0)
        if not box:IsFocused() then box.Text = fmt(value) end
    end
    local function knobState()
        local sz = dragging and 18 or (hovering and 16 or 14)
        tween(knob, { Size = UDim2.fromOffset(sz, sz) }, 0.2, Enum.EasingStyle.Back)
        tween(kglow, { ImageTransparency = dragging and 0.35 or (hovering and 0.7 or 1) }, 0.2)
    end
    local function set(v, silent)
        v = tonumber(v)
        if not v then return end
        v = math.clamp(round(v), min, max)
        local changed = v ~= value
        value = v
        render(true)
        if changed and not silent then call(cfg.Callback, value) end
    end
    value = cfg.Default and math.clamp(round(cfg.Default), min, max) or min
    render(false)
    hit.MouseEnter:Connect(function() hovering = true knobState() end)
    hit.MouseLeave:Connect(function() hovering = false knobState() end)
    dragRegion(hit, function(p)
        local r = math.clamp((p.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
        set(min + (max - min) * r)
    end, function() dragging = true knobState() end, function() dragging = false knobState() end)
    connect(box.Focused, function()
        box.Text = tostring(value)
        tween(pill, { BackgroundColor3 = Theme.FieldHover }, 0.15)
        box.TextColor3 = Theme.Accent
    end)
    connect(box.FocusLost, function()
        box.TextColor3 = Theme.Text
        tween(pill, { BackgroundColor3 = Theme.Field }, 0.15)
        local n = tonumber((box.Text:gsub("[^%d%.%-]", "")))
        if n then set(n) end
        box.Text = fmt(value)
    end)
    local flag = flagFor(cfg, name)
    if flag then Library:_Register(flag, function() return value end, function(v) set(v) end) end
    finish(self, row, name, cfg)
    return API({}, { Set = set, Get = function() return value end })
end

local function dropdownCore(self, cfg, multi)
    local win = self.Window
    local name = cfg.Name or (multi and "Multi Dropdown" or "Dropdown")
    local options = cfg.Options or {}
    local row, label = mkRow(self, 38, name, cfg.Description)
    label.Size = UDim2.new(0.5, -14, 0, label.Size.Y.Offset)
    local fld = field(row, 0.5, 120)
    local valLbl = new("TextLabel", {
        Parent = fld, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -34, 1, 0), TextXAlignment = Enum.TextXAlignment.Left,
        TextColor3 = Theme.Sub, TextSize = 13, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4,
    })
    local _, chev, chevText = makeIcon(fld, "chevron-down", 14, Theme.Sub, "v", UDim2.new(1, -10, 0.5, 0), Vector2.new(1, 0.5))
    chev.Parent.ZIndex = 4
    chev.ZIndex = 4

    local selected = {}
    local single = nil
    local max = cfg.Max
    local popupApi

    local function selectedArray()
        local out = {}
        for _, o in ipairs(options) do if selected[o] then table.insert(out, o) end end
        return out
    end
    local function count() local n = 0 for _ in pairs(selected) do n += 1 end return n end
    local function render()
        if multi then
            local arr = selectedArray()
            valLbl.Text = #arr == 0 and (cfg.Placeholder or "None") or (#arr <= 2 and table.concat(arr, ", ") or (#arr .. " selected"))
            valLbl.TextColor3 = #arr > 0 and Theme.Text or Theme.Dim
        else
            valLbl.Text = single ~= nil and tostring(single) or (cfg.Placeholder or "Select...")
            valLbl.TextColor3 = single ~= nil and Theme.Text or Theme.Dim
        end
        if popupApi then popupApi.Render() end
    end
    local function isOn(o) if multi then return selected[o] == true end return single == o end
    local function choose(o)
        if multi then
            if selected[o] then selected[o] = nil
            else
                if max and count() >= max then
                    win:Notify({ Title = name, Text = ("Maximum %d options"):format(max), Type = "warning", Sound = false, Duration = 2 })
                    return
                end
                selected[o] = true
            end
            render()
            call(cfg.Callback, selectedArray())
        else
            single = o
            render()
            call(cfg.Callback, o)
            win:_ClosePopup()
        end
    end

    connect(fld.MouseButton1Click, function()
        if win._popup and win._popup.Anchor == fld then win:_ClosePopup() return end
        local ITEM = 30
        local hasSearch = #options > 7
        local listH = math.min(#options, 7) * (ITEM + 2) + 8
        local H = listH + (hasSearch and 38 or 0)
        win:_OpenPopup(fld, math.max(fld.AbsoluteSize.X / effScale(), 180), H, function(body)
            local query = ""
            local search
            if hasSearch then
                search = new("TextBox", {
                    Parent = body, Position = UDim2.fromOffset(6, 6), Size = UDim2.new(1, -12, 0, 28), BackgroundColor3 = Theme.Field, Text = "",
                    PlaceholderText = "Search...", PlaceholderColor3 = Theme.Dim, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false,
                }, { corner(7), pad(10, 0, 10, 0), stroke(WHITE, 0.93) })
            end
            local list = new("ScrollingFrame", {
                Parent = body, Position = UDim2.fromOffset(0, hasSearch and 38 or 0), Size = UDim2.new(1, 0, 1, hasSearch and -38 or 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 2,
            }, { vlist(2), pad(4, 4, 4, 4) })
            trackAccent(list, "ScrollBarImageColor3")
            local items = {}
            for i, o in ipairs(options) do
                local b = new("TextButton", { Parent = list, LayoutOrder = i, Size = UDim2.new(1, 0, 0, ITEM), BackgroundColor3 = WHITE, BackgroundTransparency = 1, Text = "" }, { corner(6) })
                local t = new("TextLabel", { Parent = b, Position = UDim2.fromOffset(multi and 32 or 10, 0), Size = UDim2.new(1, -44, 1, 0), Text = tostring(o), TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
                local mark, markIcon, markText
                if multi then
                    mark = new("Frame", { Parent = b, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 9, 0.5, 0), Size = UDim2.fromOffset(16, 16), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1 }, { corner(5) })
                    local mst = stroke(WHITE, 0.75)
                    mst.Parent = mark
                    local _
                    _, markIcon, markText = makeIcon(mark, "check", 12, WHITE, "✓")
                    items[o] = { Btn = b, Text = t, Mark = mark, Stroke = mst, Icon = markIcon, IconText = markText }
                else
                    local _
                    _, markIcon, markText = makeIcon(b, "check", 14, Theme.Accent, "•", UDim2.new(1, -10, 0.5, 0), Vector2.new(1, 0.5))
                    items[o] = { Btn = b, Text = t, Icon = markIcon, IconText = markText }
                end
                b.MouseEnter:Connect(function() tween(b, { BackgroundTransparency = 0.95 }, 0.12) end)
                b.MouseLeave:Connect(function() tween(b, { BackgroundTransparency = 1 }, 0.15) end)
                b.MouseButton1Click:Connect(function() choose(o) end)
            end
            local function renderItems(instant)
                local t = instant and 0 or 0.18
                for o, it in pairs(items) do
                    local sel = isOn(o)
                    it.Btn.Visible = query == "" or tostring(o):lower():find(query, 1, true) ~= nil
                    tween(it.Text, { TextColor3 = sel and Theme.Text or Theme.Sub }, t)
                    it.Text.FontFace = F(sel and "SemiBold" or "Medium")
                    if multi then
                        tween(it.Mark, { BackgroundTransparency = sel and 0 or 1, BackgroundColor3 = Theme.Accent }, t)
                        tween(it.Stroke, { Transparency = sel and 1 or 0.75 }, t)
                        if it.IconText then it.Icon.TextTransparency = sel and 0 or 1 else tween(it.Icon, { ImageTransparency = sel and 0 or 1 }, t) end
                    else
                        if it.IconText then it.Icon.TextTransparency = sel and 0 or 1 else
                            it.Icon.ImageColor3 = Theme.Accent
                            tween(it.Icon, { ImageTransparency = sel and 0 or 1 }, t)
                        end
                    end
                end
            end
            if search then
                search:GetPropertyChangedSignal("Text"):Connect(function()
                    query = search.Text:lower()
                    renderItems(true)
                end)
            end
            renderItems(true)
            popupApi = { Render = function() renderItems(false) end }
        end, function()
            popupApi = nil
            tween(chev, { Rotation = 0 }, 0.25)
        end, nil, math.min(H, (hasSearch and 38 or 0) + 3 * (ITEM + 2) + 8))
        tween(chev, { Rotation = 180 }, 0.25)
    end)

    if multi then
        for _, o in ipairs(cfg.Default or {}) do if table.find(options, o) then selected[o] = true end end
    elseif cfg.Default ~= nil and table.find(options, cfg.Default) then
        single = cfg.Default
    end
    render()

    local api = {}
    local function set(v, silent)
        if multi then
            selected = {}
            for _, o in ipairs(type(v) == "table" and v or {}) do
                if table.find(options, o) and (not max or count() < max) then selected[o] = true end
            end
            render()
            if not silent then call(cfg.Callback, selectedArray()) end
        elseif v == nil or table.find(options, v) then
            single = v
            render()
            if not silent then call(cfg.Callback, single) end
        end
    end
    local function refresh(newOptions, keep)
        options = newOptions or {}
        if multi then
            if keep then
                for o in pairs(selected) do if not table.find(options, o) then selected[o] = nil end end
            else
                selected = {}
            end
        elseif not keep or (single ~= nil and not table.find(options, single)) then
            single = nil
        end
        if win._popup and win._popup.Anchor == fld then win:_ClosePopup() end
        render()
    end
    local fns = { Set = set, Refresh = refresh, Get = function() if multi then return selectedArray() end return single end }
    if multi then
        fns.SelectAll = function()
            selected = {}
            for _, o in ipairs(options) do if not max or count() < max then selected[o] = true end end
            render()
            call(cfg.Callback, selectedArray())
        end
        fns.ClearAll = function() selected = {} render() call(cfg.Callback, selectedArray()) end
        fns.IsSelected = function(o) return selected[o] == true end
    end
    API(api, fns)
    local flag = flagFor(cfg, name)
    if flag then Library:_Register(flag, fns.Get, function(v) set(v) end) end
    finish(self, row, name, cfg)
    return api
end

function Section:AddDropdown(cfg) return dropdownCore(self, cfg or {}, false) end
function Section:AddMultiDropdown(cfg) return dropdownCore(self, cfg or {}, true) end

function Section:AddTextbox(cfg)
    cfg = cfg or {}
    local name = cfg.Name or "Textbox"
    local row, label = mkRow(self, 38, name, cfg.Description)
    label.Size = UDim2.new(0.45, -14, 0, label.Size.Y.Offset)
    local fld, st = field(row, 0.55, 120)
    local box = new("TextBox", {
        Parent = fld, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = tostring(cfg.Default or ""),
        PlaceholderText = cfg.Placeholder or "", PlaceholderColor3 = Theme.Dim, TextSize = 13,
        ClearTextOnFocus = cfg.ClearOnFocus and true or false, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4,
    }, { pad(10, 0, 10, 0) })
    connect(box.Focused, function() tween(st, { Color = Theme.Accent, Transparency = 0.2 }, 0.2) end)
    if cfg.Numeric then
        connect(box:GetPropertyChangedSignal("Text"), function()
            local t = box.Text:gsub("[^%d%.%-]", "")
            if t ~= box.Text then box.Text = t end
        end)
    end
    connect(box.FocusLost, function()
        tween(st, { Color = WHITE, Transparency = 0.92 }, 0.2)
        call(cfg.Callback, box.Text)
    end)
    local function set(t, silent)
        box.Text = tostring(t or "")
        if not silent then call(cfg.Callback, box.Text) end
    end
    local flag = flagFor(cfg, name)
    if flag then Library:_Register(flag, function() return box.Text end, function(v) set(v) end) end
    finish(self, row, name, cfg)
    return API({}, { Set = set, Get = function() return box.Text end })
end

function Section:AddKeybind(cfg)
    cfg = cfg or {}
    local name = cfg.Name or "Keybind"
    local row, label = mkRow(self, 36, name, cfg.Description)
    local right = rightBox(row, label)
    local bind = createBind({
        Name = name, Key = cfg.Default, Mode = cfg.Mode, Parent = right, NoBind = cfg.NoBind, ZIndex = 4,
        OnActive = function(v) call(cfg.Callback, v) end,
        OnKey = function(k) call(cfg.ChangedCallback, k) end,
        OnMode = function(m) call(cfg.ModeCallback, m) end,
    })
    local fns = {
        Set = function(k, silent) bind:SetKey(k, silent) end,
        Get = function() return bind.Key end,
        SetMode = function(m) bind:SetMode(m) end,
        GetMode = function() return bind.Mode end,
        GetActive = function() return bind.Active end,
    }
    local flag = flagFor(cfg, name)
    if flag then
        Library:_Register(flag, function() return { Key = bind.Key or "None", Mode = bind.Mode } end, function(v)
            if type(v) == "table" then
                bind:SetKey(v.Key)
                if v.Mode and not cfg.NoBind then bind:SetMode(v.Mode) end
            end
        end)
    end
    attachTip(bind.Chip, cfg.NoBind and "LMB: rebind" or "LMB: rebind  ·  RMB: mode")
    finish(self, row, name, cfg)
    return API({}, fns)
end

-- "name ............ value" row; cfg: Name, Value (fixed text) or Get (function, re-read every
-- Interval seconds, default 1), Copy = true adds a copy button. Returns { Set(text), Refresh() }
function Section:AddStat(cfg)
    cfg = cfg or {}
    local name = cfg.Name or "Stat"
    local row, label = mkRow(self, 34, name, cfg.Description)
    label.TextColor3 = Theme.Sub
    local right = rightBox(row, label)
    local value = new("TextLabel", {
        Parent = right, LayoutOrder = 1, Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X, Text = tostring(cfg.Value or "-"),
        W = "SemiBold", TextSize = 13, RichText = true, ZIndex = 4,
    })
    if cfg.Copy then
        local cb = new("TextButton", { Parent = right, LayoutOrder = 2, Size = UDim2.fromOffset(22, 22), BackgroundColor3 = Theme.Field, Text = "", ZIndex = 4 }, { corner(6) })
        local _, ic, it = makeIcon(cb, "copy", 12, Theme.Dim, "c")
        ic.ZIndex = 5
        cb.MouseEnter:Connect(function() tintIcon(ic, it, Theme.Text) end)
        cb.MouseLeave:Connect(function() tintIcon(ic, it, Theme.Dim) end)
        cb.MouseButton1Click:Connect(function()
            local sc = setclipboard or toclipboard
            if sc then pcall(sc, (value.Text:gsub("<[^>]+>", ""))) end
            self.Window:Notify({ Title = name, Text = "Copied to clipboard", Type = "success", Sound = false, Duration = 2 })
        end)
    end
    local tab = self.Tab
    local function refresh()
        if not cfg.Get then return end
        local ok, v = pcall(cfg.Get)
        value.Text = ok and tostring(v) or "-"
    end
    if cfg.Get then
        refresh()
        task.spawn(function()
            while row.Parent do
                -- only while its page is on screen; values are re-read the moment it shows up again
                if tab.Window.Open and tab.Window.CurrentTab == tab then refresh() end
                task.wait(cfg.Interval or 1)
            end
        end)
    end
    self.Window:_AddSearch(name, row, self)
    return API({}, { Set = function(t) value.Text = tostring(t) end, Refresh = refresh })
end

-- 3D model of a player's character; cfg: Name, Height (default 240), Player (default LocalPlayer)
-- returns { Refresh(), Overlay } - Overlay is a frame above the model for your own drawings (ESP sample etc.)
function Section:AddCharacterPreview(cfg)
    cfg = cfg or {}
    local stage = new("Frame", {
        Parent = self.Content, LayoutOrder = nextOrder(self), Size = UDim2.new(1, 0, 0, cfg.Height or 240), BackgroundColor3 = WHITE,
        BackgroundTransparency = 0.97, ClipsDescendants = true,
    }, { corner(10), stroke(WHITE, 0.93) })
    new("UIGradient", { Parent = stage, Rotation = 90, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.6, 0.6), NumberSequenceKeypoint.new(1, 0) }) })
    local floorGlow = glow(stage, Theme.Accent, 0, 0.82, 1)
    floorGlow.AnchorPoint = Vector2.new(0.5, 1)
    floorGlow.Position = UDim2.fromScale(0.5, 1.15)
    floorGlow.Size = UDim2.new(0.8, 0, 0.35, 0)
    trackAccent(floorGlow, "ImageColor3")
    local tab = self.Tab
    local view = characterView(stage, {
        Player = cfg.Player, ZIndex = 2, Active = function() return tab.Window.CurrentTab == tab and tab.Window.Open end,
        OnFail = function()
            new("TextLabel", { Parent = stage, Size = UDim2.fromScale(1, 1), Text = "Character not loaded", TextColor3 = Theme.Dim, TextSize = 13, ZIndex = 3 })
        end,
    })
    local overlay = new("Frame", { Parent = stage, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 3 })
    self.Window:_AddSearch(cfg.Name or "Character Preview", stage, self)
    return API({ Overlay = overlay }, { Refresh = view.Refresh })
end

function Section:AddColorPicker(cfg)
    cfg = cfg or {}
    local win = self.Window
    local name = cfg.Name or "Color"
    local color = parseColor(cfg.Default) or WHITE
    local row, label = mkRow(self, 36, name, cfg.Description)
    local right = rightBox(row, label)
    local hexLbl = new("TextLabel", { Parent = right, LayoutOrder = 1, Size = UDim2.fromOffset(0, 22), AutomaticSize = Enum.AutomaticSize.X, Text = "#" .. color:ToHex():upper(), TextSize = 12, TextColor3 = Theme.Dim, ZIndex = 4 })
    local swatch = new("TextButton", { Parent = right, LayoutOrder = 2, Size = UDim2.fromOffset(34, 20), BackgroundColor3 = color, Text = "", ZIndex = 4 }, { corner(6), stroke(WHITE, 0.8) })
    local function apply(c)
        color = c
        swatch.BackgroundColor3 = c
        hexLbl.Text = "#" .. c:ToHex():upper()
    end
    local function set(c, silent)
        c = parseColor(c)
        if not c then return end
        apply(c)
        if win._popup and win._popup.Anchor == swatch and win._popup.Picker then win._popup.Picker.Refresh(c) end
        if not silent then call(cfg.Callback, c) end
    end
    connect(swatch.MouseButton1Click, function()
        win:_OpenColorPopup(swatch, function() return color end, function(c) apply(c) call(cfg.Callback, c) end)
    end)
    local flag = flagFor(cfg, name)
    if flag then Library:_Register(flag, function() return color end, function(v) set(v) end) end
    finish(self, row, name, cfg)
    return API({}, { Set = set, Get = function() return color end })
end

----------------------------------------------------------------------
-- Tab
----------------------------------------------------------------------
-- Column() returns the column and also makes it current, so Lumina-style
-- `Tab:Column("left")` followed by `Tab:CreateSection(...)` keeps working
function Tab:Column(side)
    self._col = (side == "right") and self.RightCol or self.LeftCol
    return self._col
end
function Tab:CreateSection(cfg)
    if self._col then return self._col:CreateSection(cfg) end
    self._alt = (self._alt or 0) + 1
    local col = (self._alt % 2 == 1) and self.LeftCol or self.RightCol
    return col:CreateSection(cfg)
end
function Tab:Select() self.Window:SelectTab(self) end

----------------------------------------------------------------------
-- Background effects: particles behind the window content (or the whole screen)
----------------------------------------------------------------------
local rnd = Random.new()
local function rr(a, b) return rnd:NextNumber(a, b) end
local function pick(t) return t[rnd:NextInteger(1, #t)] end

local SAKURA = { rgb(255, 183, 213), rgb(255, 160, 200), rgb(255, 208, 226), rgb(248, 140, 186) }
local EMBER = { rgb(255, 150, 60), rgb(255, 110, 40), rgb(255, 196, 90) }
local RAIN_ANGLE = math.rad(14)
local SHOOT_ANGLE = math.rad(25)

-- n: particles at 100% density; make(layer, i) -> object; spawn(p, W, H, first); step(p, dt, t, W, H) -> dead.
-- step writes the draw position to p.dx / p.dy (layer pixels) and optionally p.r (rotation).
local Effects = {}
Effects.Sakura = {
    n = 28,
    make = function(layer)
        return new("Frame", { Parent = layer, AnchorPoint = Vector2.new(0.5, 0.5), BackgroundColor3 = pick(SAKURA), BackgroundTransparency = rr(0.1, 0.35) }, { corner("full") })
    end,
    spawn = function(p, W, H, first)
        p.x, p.y = rr(-0.15, 1) * W, first and rr(0, H) or rr(-40, -12)
        p.vx, p.vy = rr(10, 28), rr(26, 52)
        p.amp, p.f, p.ph = rr(12, 32), rr(0.6, 1.4), rr(0, 6.28)
        p.r, p.vr = rr(0, 360), rr(-100, 100)
        p.w, p.h, p.flip = rr(8, 13), rr(5, 8), rr(1.5, 3.5)
    end,
    step = function(p, dt, t, W, H)
        p.x += p.vx * dt
        p.y += p.vy * dt
        p.r += p.vr * dt
        p.dx, p.dy = p.x + math.sin(t * p.f + p.ph) * p.amp, p.y
        -- the petal "flips" in 3D: its width breathes
        p.obj.Size = UDim2.fromOffset(p.w * (0.35 + 0.65 * math.abs(math.sin(t * p.flip + p.ph))), p.h)
        return p.y > H + 20 or p.dx > W + 30
    end,
}
Effects.Snow = {
    n = 50,
    make = function(layer)
        local s = rr(2, 5)
        return new("Frame", { Parent = layer, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(s, s), BackgroundColor3 = WHITE, BackgroundTransparency = rr(0.15, 0.6) }, { corner("full") })
    end,
    spawn = function(p, W, H, first)
        local s = p.obj.Size.X.Offset
        p.x, p.y = rr(0, 1) * W, first and rr(0, H) or rr(-20, -6)
        p.vx, p.vy = rr(-6, 10), 10 + s * 7 + rr(0, 10) -- big flakes are closer, so faster
        p.amp, p.f, p.ph = rr(4, 14), rr(0.5, 1.2), rr(0, 6.28)
    end,
    step = function(p, dt, t, W, H)
        p.x += p.vx * dt
        p.y += p.vy * dt
        p.dx, p.dy = p.x + math.sin(t * p.f + p.ph) * p.amp, p.y
        return p.y > H + 10
    end,
}
Effects.Rain = {
    n = 60,
    make = function(layer)
        local f = new("Frame", { Parent = layer, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(1, rr(10, 22)), BackgroundColor3 = rgb(170, 200, 255), BackgroundTransparency = rr(0.4, 0.7), Rotation = -math.deg(RAIN_ANGLE) })
        new("UIGradient", { Parent = f, Rotation = 90, Transparency = NumberSequence.new(1, 0) })
        return f
    end,
    spawn = function(p, W, H, first)
        p.x, p.y = rr(-0.3, 1) * W, first and rr(0, H) or rr(-60, -20)
        p.vy = rr(420, 620)
        p.vx = p.vy * math.tan(RAIN_ANGLE)
    end,
    step = function(p, dt, t, W, H)
        p.x += p.vx * dt
        p.y += p.vy * dt
        p.dx, p.dy = p.x, p.y
        return p.y > H + 30
    end,
}
Effects.Stars = {
    n = 55,
    make = function(layer, i)
        if i == 1 then -- the shooting star; bright head on the left, tail fading to the right
            local f = new("Frame", { Parent = layer, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(80, 2), BackgroundColor3 = WHITE, BackgroundTransparency = 1, Rotation = -math.deg(SHOOT_ANGLE) }, { corner("full") })
            new("UIGradient", { Parent = f, Transparency = NumberSequence.new(0, 1) })
            return f
        end
        local s = rr(1.5, 3.2)
        local f = new("Frame", { Parent = layer, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(s, s), BackgroundColor3 = pick({ WHITE, rgb(200, 215, 255), rgb(255, 240, 210) }) }, { corner("full") })
        if s > 2.7 then glow(f, WHITE, 12, 0.65) end
        return f
    end,
    spawn = function(p, W, H, first)
        if p.i == 1 then
            p.wait, p.life = rr(first and 1 or 2.5, first and 3 or 7), 0
            p.x, p.y = rr(0.35, 1.1) * W, rr(-0.05, 0.35) * H
            return
        end
        p.x, p.y = rr(0, 1) * W, rr(0, 1) * H
        p.base, p.f, p.ph = rr(0.05, 0.4), rr(0.8, 2.5), rr(0, 6.28)
    end,
    step = function(p, dt, t, W, H)
        p.dx, p.dy = p.x, p.y
        if p.i == 1 then
            if p.wait > 0 then
                p.wait -= dt
                return false
            end
            p.life += dt
            p.x -= math.cos(SHOOT_ANGLE) * 700 * dt
            p.y += math.sin(SHOOT_ANGLE) * 700 * dt
            p.obj.BackgroundTransparency = math.clamp(math.max(1 - p.life / 0.12, (p.life - 0.45) / 0.35), 0, 1)
            if p.life > 0.8 then p.obj.BackgroundTransparency = 1 return true end
            return false
        end
        p.obj.BackgroundTransparency = p.base + (0.5 + 0.5 * math.sin(t * p.f + p.ph)) * 0.55
        return false
    end,
}
Effects.Fireflies = {
    n = 22,
    make = function(layer)
        local s = rr(14, 26)
        local g = new("ImageLabel", { Parent = layer, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(s, s), Image = IMG_GLOW, ImageColor3 = Theme.Accent, ImageTransparency = 0.5 })
        new("Frame", { Parent = g, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(3, 3), BackgroundColor3 = WHITE, BackgroundTransparency = 0.2 }, { corner("full") })
        return g
    end,
    spawn = function(p, W, H)
        p.x, p.y = rr(0, 1) * W, rr(0, 1) * H
        p.a, p.sp, p.f, p.ph = rr(0, 6.28), rr(10, 26), rr(0.4, 1.1), rr(0, 6.28)
    end,
    step = function(p, dt, t, W, H)
        p.a += math.sin(t * p.f + p.ph) * dt * 1.6
        p.x = (p.x + math.cos(p.a) * p.sp * dt) % W
        p.y = (p.y + math.sin(p.a) * p.sp * dt) % H
        p.dx, p.dy = p.x, p.y
        p.obj.ImageColor3 = Theme.Accent
        p.obj.ImageTransparency = 0.3 + 0.55 * (0.5 + 0.5 * math.sin(t * p.f * 3 + p.ph))
        return false
    end,
}
Effects.Embers = {
    n = 30,
    make = function(layer)
        local c = pick(EMBER)
        local s = rr(8, 16)
        local g = new("ImageLabel", { Parent = layer, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(s, s), Image = IMG_GLOW, ImageColor3 = c })
        new("Frame", { Parent = g, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(2, 2), BackgroundColor3 = c:Lerp(WHITE, 0.5) }, { corner("full") })
        return g
    end,
    spawn = function(p, W, H, first)
        p.x, p.y = rr(0, 1) * W, first and rr(0, H) or H + rr(5, 30)
        p.vy, p.amp, p.f, p.ph = rr(30, 70), rr(6, 20), rr(0.8, 2), rr(0, 6.28)
    end,
    step = function(p, dt, t, W, H)
        p.y -= p.vy * dt
        p.dx, p.dy = p.x + math.sin(t * p.f + p.ph) * p.amp, p.y
        -- bright near the bottom, burning out on the way up
        local k = math.clamp(p.y / H, 0, 1)
        p.obj.ImageTransparency = 1 - 0.8 * k
        p.obj:FindFirstChildOfClass("Frame").BackgroundTransparency = 1 - k
        return p.y < -20
    end,
}
Effects.Bubbles = {
    n = 18,
    make = function(layer)
        local s = rr(6, 20)
        local f = new("Frame", { Parent = layer, AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(s, s), BackgroundColor3 = WHITE, BackgroundTransparency = 0.93 }, {
            corner("full"), new("UIStroke", { Color = WHITE, Transparency = 0.55, Thickness = 1 }),
        })
        new("Frame", { Parent = f, Position = UDim2.fromScale(0.22, 0.2), Size = UDim2.fromScale(0.22, 0.22), BackgroundColor3 = WHITE, BackgroundTransparency = 0.35 }, { corner("full") })
        return f
    end,
    spawn = function(p, W, H, first)
        p.x, p.y = rr(0, 1) * W, first and rr(0, H) or H + rr(10, 40)
        p.vy, p.amp, p.f, p.ph = rr(18, 40), rr(5, 15), rr(0.6, 1.4), rr(0, 6.28)
    end,
    step = function(p, dt, t, W, H)
        p.y -= p.vy * dt
        p.dx, p.dy = p.x + math.sin(t * p.f + p.ph) * p.amp, p.y
        return p.y < -30
    end,
}
Library.EffectNames = { "Off", "Sakura", "Snow", "Rain", "Stars", "Fireflies", "Embers", "Bubbles" }

local function buildEffects(win)
    local E = { Name = "Off", Density = 1, Fullscreen = false, parts = {} }
    -- window layer: over the content (not Active, so clicks pass through), under popups; screen layer: behind the whole window
    local winLayer = new("Frame", { Parent = win.Canvas, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 45 })
    local screenLayer = new("Frame", { Parent = win.Gui, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false, ZIndex = 0 })
    local function layer() return E.Fullscreen and screenLayer or winLayer end
    local function dims()
        local sz = layer().AbsoluteSize
        return math.max(sz.X, 50), math.max(sz.Y, 50)
    end
    local function rebuild()
        for _, p in ipairs(E.parts) do p.obj:Destroy() end
        table.clear(E.parts)
        local def = Effects[E.Name]
        if not def then return end
        local L = layer()
        local W, H = dims()
        for i = 1, math.max(2, math.floor(def.n * E.Density + 0.5)) do
            local p = { i = i }
            p.obj = def.make(L, i)
            def.spawn(p, W, H, true)
            table.insert(E.parts, p)
        end
    end
    -- slider drags fire every frame: rebuild once they settle
    local queued = false
    local function queue()
        if queued then return end
        queued = true
        task.delay(0.08, function() queued = false rebuild() end)
    end

    local t = 0
    connect(RunService.RenderStepped, function(dt)
        if #E.parts == 0 or not win.Open then return end
        dt = math.min(dt, 0.1)
        t += dt
        local def = Effects[E.Name]
        local W, H = dims()
        for _, p in ipairs(E.parts) do
            if def.step(p, dt, t, W, H) then def.spawn(p, W, H, false) end
            local o = p.obj
            o.Position = UDim2.fromScale(p.dx / W, p.dy / H)
            if p.r then o.Rotation = p.r end
        end
    end)

    function E.Set(name)
        E.Name = Effects[name] and name or "Off"
        rebuild()
    end
    function E.SetDensity(d)
        E.Density = math.clamp(tonumber(d) or 1, 0.2, 3)
        queue()
    end
    function E.SetFullscreen(b)
        E.Fullscreen = b and true or false
        screenLayer.Visible = E.Fullscreen and win.Open
        rebuild()
    end
    function E.OnToggle(open)
        if open then screenLayer.Visible = E.Fullscreen
        else task.delay(0.2, function() if not win.Open then screenLayer.Visible = false end end) end
    end
    return E
end

----------------------------------------------------------------------
-- Character art: a PNG standing next to the window. Slots without a picture show a placeholder.
----------------------------------------------------------------------
local function isImage(body)
    return type(body) == "string" and #body > 200 and (body:sub(1, 4) == "\137PNG" or body:sub(1, 3) == "\255\216\255")
end

-- entry.Image: "rbxassetid://..", an asset id, an http(s) url or a file name (looked up in <Folder>/Art, then ArtBaseUrl)
function Library:_ArtAsset(entry)
    local img = tostring(entry.Image or entry.File or "")
    if img == "" then return nil end
    if img:find("^rbxasset") or img:find("^rbxthumb") or img:find("^rbxgameasset") then return img end
    if tonumber(img) then return "rbxassetid://" .. img end
    local ca = getcustomasset or getsynasset
    if not ca then return nil end
    local url, file
    if img:find("^https?://") then
        url = img
        file = (img:gsub("[?#].*$", "")):match("[^/]+$") or "art.png"
    else
        url, file = self.ArtBaseUrl .. img, img
    end
    local path = self.Folder .. "/Art/" .. file
    if not FS.isfile(path) and not self._artMissing[url] then
        local body = httpGet(url)
        if isImage(body) then
            FS.mkdirs(self.Folder .. "/Art")
            FS.write(path, body)
        else
            self._artMissing[url] = true
        end
    end
    if FS.isfile(path) then
        local ok, id = pcall(ca, path)
        if ok and id then return id end
    end
    return nil
end

local function artPlaceholder(parent, name)
    local f = new("Frame", { Parent = parent, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Card, BackgroundTransparency = 0.08, ClipsDescendants = true }, { corner(22) })
    local st = new("UIStroke", { Parent = f, Color = Theme.Accent, Transparency = 0.45, Thickness = 1.5 })
    trackAccent(st, "Color")
    local haze = new("Frame", { Parent = f, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Accent }, { corner(22), new("UIGradient", { Rotation = 90, Transparency = NumberSequence.new(1, 0.72) }) })
    trackAccent(haze, "BackgroundColor3")
    -- bust silhouette: head and shoulders
    local head = new("Frame", { Parent = f, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(0.36, 0.36), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.72 }, {
        corner("full"), new("UIAspectRatioConstraint", { AspectRatio = 1 }),
    })
    trackAccent(head, "BackgroundColor3")
    local body = new("Frame", { Parent = f, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0.67), Size = UDim2.fromScale(0.8, 0.45), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.72 }, {
        new("UICorner", { CornerRadius = UDim.new(0.45, 0) }),
    })
    trackAccent(body, "BackgroundColor3")
    local _, ic = makeIcon(f, "image", 20, Theme.Accent, nil, UDim2.new(0.5, 0, 0, 34), Vector2.new(0.5, 0.5))
    if ic then onAccent(function() if ic:IsA("ImageLabel") then ic.ImageColor3 = Theme.Accent else ic.TextColor3 = Theme.Accent end end) end
    new("TextLabel", { Parent = f, Position = UDim2.fromOffset(0, 52), Size = UDim2.new(1, 0, 0, 20), Text = string.upper(name or "Art"), W = "Bold", TextSize = 16 })
    new("TextLabel", { Parent = f, Position = UDim2.fromOffset(0, 72), Size = UDim2.new(1, 0, 0, 14), Text = "PNG coming soon", W = "Regular", TextSize = 11, TextColor3 = Theme.Dim })
    return f
end

local function buildArt(win, cfg)
    local A = { List = {}, Name = "Off", Side = "Right", Front = false, Size = 1.1, Opacity = 1 }
    if cfg.Art ~= false then A.List = type(cfg.Art) == "table" and cfg.Art or Library.Art end
    local ratio = new("UIAspectRatioConstraint", { AspectRatio = 0.62, DominantAxis = Enum.DominantAxis.Height })
    local holder = new("CanvasGroup", {
        Parent = win.Root, AnchorPoint = Vector2.new(0.3, 1), Position = UDim2.fromScale(1, 1), Size = UDim2.fromScale(5, A.Size), -- the aspect constraint shrinks the width
        BackgroundTransparency = 1, GroupTransparency = 1, Visible = false, ZIndex = 1,
    }, { ratio })
    local stage = new("Frame", { Parent = holder, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 })
    A.Holder = holder

    local function home() return UDim2.fromScale(A.Side == "Left" and 0 or 1, 1) end
    local token = 0
    local function render()
        token += 1
        local my = token
        stage:ClearAllChildren()
        local entry = A.Current
        holder.Visible = entry ~= nil
        if not entry then return end
        ratio.AspectRatio = entry.Ratio or 0.62
        local ph = artPlaceholder(stage, entry.Name)
        task.spawn(function()
            local id = Library:_ArtAsset(entry)
            if my ~= token or not id then return end
            local img = new("ImageLabel", { Parent = stage, Size = UDim2.fromScale(1, 1), ScaleType = Enum.ScaleType.Fit, Image = id, ImageTransparency = 1 })
            tween(img, { ImageTransparency = 0 }, 0.3)
            tween(ph, { BackgroundTransparency = 1 }, 0.2)
            task.delay(0.21, function() ph:Destroy() end)
        end)
    end
    function A.Place()
        -- behind the window: 30% tucked under its edge; in front: overlapping the corner a bit more
        local right = A.Side ~= "Left"
        local k = A.Front and 0.42 or 0.3
        holder.ZIndex = A.Front and 3 or 1
        holder.AnchorPoint = Vector2.new(right and k or 1 - k, 1)
        holder.Position = home()
        holder.Size = UDim2.fromScale(5, A.Size)
        if win.Open and A.Current then tween(holder, { GroupTransparency = 1 - A.Opacity }, 0.25) end
    end
    function A.Set(name)
        A.Name, A.Current = tostring(name), nil
        if A.Name == "Random" and #A.List > 0 then
            A.Current = A.List[rnd:NextInteger(1, #A.List)]
        else
            for _, e in ipairs(A.List) do if e.Name == A.Name then A.Current = e end end
        end
        render()
        A.Place()
    end
    function A.Names()
        local t = { "Off", "Random" }
        for _, e in ipairs(A.List) do table.insert(t, e.Name) end
        return t
    end
    function A.OnToggle(open)
        if not A.Current then return end
        if open then
            -- slides in from outside the window a moment after it opens
            holder.Position = home() + UDim2.fromOffset(A.Side == "Left" and -30 or 30, 0)
            holder.GroupTransparency = 1
            task.delay(0.1, function()
                if win.Open then tween(holder, { GroupTransparency = 1 - A.Opacity, Position = home() }, 0.55, Enum.EasingStyle.Quint) end
            end)
        else
            tween(holder, { GroupTransparency = 1 }, 0.18)
        end
    end
    -- idle float
    local t = 0
    connect(RunService.RenderStepped, function(dt)
        if not (win.Open and holder.Visible) then return end
        t += dt
        stage.Position = UDim2.fromOffset(0, -(0.5 + 0.5 * math.sin(t * 1.3)) * 6)
    end)
    return A
end

----------------------------------------------------------------------
-- Library:CreateWindow
----------------------------------------------------------------------
local function getGuiParent()
    local okH, h = pcall(function() return gethui and gethui() end)
    if okH and h then return h end
    local ok = pcall(function()
        local f = Instance.new("Folder")
        f.Parent = cloneref(game:GetService("CoreGui"))
        f:Destroy()
    end)
    if ok then return cloneref(game:GetService("CoreGui")) end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local MIN_W, MIN_H, MAX_W, MAX_H = 480, 300, 1200, 800
local DEF_W, DEF_H = 780, 500
local SIDE_W, HEAD_H = 196, 58

function Library:CreateWindow(cfg)
    cfg = cfg or {}
    if self.Window then self:Unload() end
    Icons.Load()

    local win = setmetatable({}, Window)
    self.Window = win
    win.Title = cfg.Title or "MoroElite"
    win.Subtitle = cfg.Subtitle or ("v" .. Library.Version)
    win.ToggleKey = resolveKey(cfg.ToggleKey or cfg.Key) or Enum.KeyCode.RightShift
    win.TeleportFile = cfg.TeleportFile or "Doors.lua"
    win.TeleportDelay = cfg.TeleportDelay or 5
    win.ExecuteOnTeleport = cfg.ExecuteOnTeleport and true or false
    win.TeleportUrl = cfg.TeleportUrl
    win.TeleportScript = cfg.TeleportScript
    win.NotifySound = cfg.NotifySound ~= false
    win.LoaderSound = cfg.LoaderSound ~= false
    win.NotifySoundName = cfg.NotifySoundName or "Soft"
    win.NotifySoundVolume = cfg.NotifySoundVolume or 0.5
    win.BlurEnabled = cfg.Blur ~= false
    win.Tabs, win.Open = {}, false
    win._search, win._ui, win._top = {}, {}, {}
    win._unread = 0
    win.Size = Vector2.new(DEF_W, DEF_H)

    -- Gui
    local Gui = new("ScreenGui", { Name = "ME_" .. HttpService:GenerateGUID(false):sub(1, 8), ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling, IgnoreGuiInset = true, DisplayOrder = 2147483647 })
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(Gui) end end)
    Gui.Parent = getGuiParent()
    win.Gui = Gui

    -- Background blur
    win.Blur = new("BlurEffect", { Name = "MoroEliteBlur", Size = 0, Parent = Lighting })

    local vp = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
    local Root = new("Frame", { Name = "Root", Parent = Gui, BackgroundTransparency = 1, Visible = false, Size = UDim2.fromOffset(DEF_W, DEF_H), Position = UDim2.fromOffset(vp.X / 2 - DEF_W / 2, vp.Y / 2 - DEF_H / 2) })
    win.Root = Root
    win.RootScale = new("UIScale", { Parent = Root })
    local Shadow = shadow(Root, 160, 1)
    local AccentGlow = new("ImageLabel", {
        Parent = Root, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.new(1, 140, 1, 140),
        Image = IMG_GLOW, ImageTransparency = 1, ZIndex = 0,
    })
    trackAccent(AccentGlow, "ImageColor3")
    win._Shadow, win._AccentGlow = Shadow, AccentGlow

    local Canvas = new("CanvasGroup", {
        Parent = Root, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromScale(1, 1), GroupTransparency = 1,
        BackgroundColor3 = Theme.Bg, ZIndex = 2, Active = true, -- clicks on the menu never reach game UI / world behind it
    }, { corner(14) })
    stroke(WHITE, 0.9).Parent = Canvas
    win.Canvas = Canvas
    win.AnimScale = new("UIScale", { Parent = Canvas, Scale = 0.94 })

    -- ambient accent light in the top-right corner of the content
    local ambient = new("ImageLabel", { Parent = Canvas, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(1, -60, 0, 0), Size = UDim2.fromOffset(520, 340), Image = IMG_GLOW, ImageTransparency = 0.9 })
    trackAccent(ambient, "ImageColor3")

    win.Effects = buildEffects(win)
    win.Art = buildArt(win, cfg)

    -- Cursor-lock bypass
    new("TextButton", { Parent = Canvas, Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1, Text = "", Modal = true })
    pcall(function() RunService:UnbindFromRenderStep("MoroLumina_Cursor") end)
    RunService:BindToRenderStep("MoroLumina_Cursor", Enum.RenderPriority.Last.Value + 10, function()
        if win.Open then
            UIS.MouseBehavior = Enum.MouseBehavior.Default
            UIS.MouseIconEnabled = true
        end
    end)

    ------------------------------------------------------------------
    -- Sidebar
    ------------------------------------------------------------------
    local Side = new("Frame", { Parent = Canvas, Size = UDim2.new(0, SIDE_W, 1, 0), BackgroundColor3 = Theme.Side, ZIndex = 2 })
    new("Frame", { Parent = Side, AnchorPoint = Vector2.new(1, 0), Position = UDim2.fromScale(1, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = WHITE, BackgroundTransparency = 0.93, ZIndex = 3 })

    local brand = new("Frame", { Parent = Side, Size = UDim2.new(1, 0, 0, HEAD_H + 8), BackgroundTransparency = 1, ZIndex = 3 })
    local logoWrap = new("Frame", { Parent = brand, Position = UDim2.fromOffset(16, 15), Size = UDim2.fromOffset(36, 36), BackgroundTransparency = 1, ZIndex = 3 })
    local logoGlow = glow(logoWrap, Theme.Accent, 40, 0.45, 3)
    trackAccent(logoGlow, "ImageColor3")
    local logo = new("Frame", { Parent = logoWrap, Size = UDim2.fromScale(1, 1), BackgroundColor3 = WHITE, ZIndex = 4 }, { corner(10) })
    trackGrad(new("UIGradient", { Parent = logo, Rotation = 45 }))
    stroke(WHITE, 0.75).Parent = logo
    local logoContent
    if cfg.Icon then
        local _, ic, isText = makeIcon(logo, cfg.Icon, 18, WHITE, win.Title:sub(1, 1):upper())
        ic.ZIndex = 5
        logoContent = { ic, isText }
    else
        local t = new("TextLabel", { Parent = logo, Size = UDim2.fromScale(1, 1), Text = win.Title:sub(1, 1):upper(), W = "Heavy", TextSize = 18, ZIndex = 5 })
        logoContent = { t, true }
    end
    onAccent(function()
        local c = contrast(Theme.Accent)
        if logoContent[2] then logoContent[1].TextColor3 = c else logoContent[1].ImageColor3 = c end
    end)
    new("TextLabel", { Parent = brand, Position = UDim2.fromOffset(62, 15), Size = UDim2.new(1, -72, 0, 20), Text = win.Title, W = "Bold", TextSize = 17, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3 })
    new("TextLabel", { Parent = brand, Position = UDim2.fromOffset(62, 35), Size = UDim2.new(1, -72, 0, 14), Text = win.Subtitle, W = "Regular", TextSize = 12, TextColor3 = Theme.Dim, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 3 })
    dragify(brand, Root, nil, function() win:_ClosePopup() end)

    local tabScroll = new("ScrollingFrame", { Parent = Side, Position = UDim2.fromOffset(0, HEAD_H + 12), Size = UDim2.new(1, 0, 1, -(HEAD_H + 12) - 70), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 0, ZIndex = 3 })
    local tabHolder = new("Frame", { Parent = tabScroll, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 3 })
    local pill = new("Frame", { Parent = tabHolder, Position = UDim2.fromOffset(10, 0), Size = UDim2.new(1, -20, 0, 38), BackgroundColor3 = Theme.Accent, Visible = false, ZIndex = 3 }, { corner(9) })
    trackAccent(pill, "BackgroundColor3")
    new("UIGradient", { Parent = pill, Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.78), NumberSequenceKeypoint.new(1, 0.96) }) })
    local pillBar = new("Frame", { Parent = pill, AnchorPoint = Vector2.new(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(3, 18), BackgroundColor3 = Theme.Accent, ZIndex = 4 }, { corner("full") })
    trackAccent(pillBar, "BackgroundColor3")
    local pillGlow = glow(pillBar, Theme.Accent, 26, 0.3, 4)
    trackAccent(pillGlow, "ImageColor3")
    win.TabList = new("Frame", { Parent = tabHolder, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, ZIndex = 4 }, { vlist(4), pad(10, 0, 10, 8) })
    win._pill, win._tabScroll = pill, tabScroll

    local card = new("Frame", { Parent = Side, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 10, 1, -10), Size = UDim2.new(1, -20, 0, 52), BackgroundColor3 = Theme.Card, ZIndex = 3 }, { corner(10), stroke(WHITE, 0.93) })
    local avWrap = new("Frame", { Parent = card, Position = UDim2.fromOffset(9, 9), Size = UDim2.fromOffset(34, 34), BackgroundColor3 = Theme.Field, ZIndex = 4 }, { corner("full") })
    local avStroke = new("UIStroke", { Parent = avWrap, Thickness = 1.5, Color = Theme.Accent })
    trackAccent(avStroke, "Color")
    fillAvatar(avWrap, 15, 4)
    new("Frame", { Parent = avWrap, AnchorPoint = Vector2.new(1, 1), Position = UDim2.fromScale(1.05, 1.05), Size = UDim2.fromOffset(10, 10), BackgroundColor3 = Theme.Good, ZIndex = 6 }, { corner("full"), new("UIStroke", { Thickness = 2, Color = Theme.Card }) })
    new("TextLabel", { Parent = card, Position = UDim2.fromOffset(51, 9), Size = UDim2.new(1, -80, 0, 17), Text = LocalPlayer.DisplayName, TextSize = 14, W = "SemiBold", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4 })
    new("TextLabel", { Parent = card, Position = UDim2.fromOffset(51, 27), Size = UDim2.new(1, -80, 0, 14), Text = "@" .. LocalPlayer.Name, TextSize = 12, W = "Regular", TextColor3 = Theme.Dim, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4 })
    local _, moreIc, moreIt = makeIcon(card, "ellipsis", 16, Theme.Dim, "...", UDim2.new(1, -12, 0.5, 0), Vector2.new(1, 0.5))
    moreIc.ZIndex = 5
    -- the whole card opens the profile
    local cardBtn = new("TextButton", { Parent = card, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = "", ZIndex = 6 })
    cardBtn.MouseEnter:Connect(function() tween(card, { BackgroundColor3 = Theme.FieldHover }, 0.15) tintIcon(moreIc, moreIt, Theme.Text) end)
    cardBtn.MouseLeave:Connect(function() tween(card, { BackgroundColor3 = Theme.Card }, 0.2) tintIcon(moreIc, moreIt, Theme.Dim) end)
    cardBtn.MouseButton1Click:Connect(function() win:OpenProfile() end)
    -- the card is the profile tab's "button": light it up while the profile is open
    local cardStroke = card:FindFirstChildOfClass("UIStroke")
    win._onTabChanged = function(tab)
        local on = tab == win.ProfileTab
        tween(cardStroke, { Color = on and Theme.Accent or WHITE, Transparency = on and 0.35 or 0.93 }, 0.25)
    end
    win._sessionStart = os.clock()

    ------------------------------------------------------------------
    -- Header
    ------------------------------------------------------------------
    local Head = new("Frame", { Parent = Canvas, Position = UDim2.fromOffset(SIDE_W, 0), Size = UDim2.new(1, -SIDE_W, 0, HEAD_H), BackgroundTransparency = 1, ZIndex = 3 })
    new("Frame", { Parent = Head, AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 0.93, ZIndex = 3 })
    win._pageTitle = new("TextLabel", { Parent = Head, Position = UDim2.fromOffset(22, 10), Size = UDim2.new(0, 220, 0, 22), Text = "", W = "Bold", TextSize = 19, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4 })
    win._pageSub = new("TextLabel", { Parent = Head, Position = UDim2.fromOffset(22, 32), Size = UDim2.new(0, 220, 0, 14), Text = "", W = "Regular", TextSize = 12, TextColor3 = Theme.Dim, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 4 })
    dragify(Head, Root, nil, function() win:_ClosePopup() end)

    local buttonsFrame = new("Frame", { Parent = Head, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -14, 0.5, 0), Size = UDim2.new(0, 0, 0, 32), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1, ZIndex = 5 },
        { new("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Center }) })
    local function topBtn(key, icon, fb, order)
        local b = new("TextButton", { Parent = buttonsFrame, LayoutOrder = order, Size = UDim2.fromOffset(32, 32), BackgroundColor3 = WHITE, BackgroundTransparency = 1, Text = "", ZIndex = 5 }, { corner(8) })
        local _, ic, isText = makeIcon(b, icon, 17, Theme.Sub, fb)
        ic.ZIndex = 6
        b.MouseEnter:Connect(function() tween(b, { BackgroundTransparency = 0.94 }, 0.15) tintIcon(ic, isText, Theme.Text) end)
        b.MouseLeave:Connect(function() tween(b, { BackgroundTransparency = 1 }, 0.2) tintIcon(ic, isText, Theme.Sub) end)
        b.MouseButton1Click:Connect(function()
            local h = win._top[key]
            if h then call(h) else win:_DefaultTop(key, b) end
        end)
        return b
    end
    -- only minimize + close by default; script buttons (bell, key, settings, user, ...) come from SetTopButton / cfg.TopButtons
    win._topBtns, win._topOrder, win._makeTopBtn = {}, 0, topBtn
    win._topDivider = new("Frame", { Parent = buttonsFrame, LayoutOrder = 90, Size = UDim2.fromOffset(9, 18), BackgroundTransparency = 1, Visible = false }, {
        new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromScale(0.5, 0), Size = UDim2.new(0, 1, 1, 0), BackgroundColor3 = WHITE, BackgroundTransparency = 0.88 }),
    })
    topBtn("minimize", "minus", "-", 98)
    win._top.minimize = function() win:Minimize() end
    local closeBtn = topBtn("close", "x", "x", 99)
    win._top.close = function() win:Toggle(false) end
    closeBtn.MouseEnter:Connect(function() tween(closeBtn, { BackgroundColor3 = Theme.Bad, BackgroundTransparency = 0.8 }, 0.15) end)
    closeBtn.MouseLeave:Connect(function() tween(closeBtn, { BackgroundColor3 = WHITE, BackgroundTransparency = 1 }, 0.2) end)

    -- Search box
    local searchBox = new("Frame", {
        Parent = Head, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -205, 0.5, 0), Size = UDim2.new(0.55, -150, 0, 34), BackgroundColor3 = Theme.Field, ZIndex = 4,
    }, { corner(9), new("UISizeConstraint", { MinSize = Vector2.new(150, 34), MaxSize = Vector2.new(260, 34) }) })
    local sStroke = stroke(WHITE, 0.92)
    sStroke.Parent = searchBox
    local _, sIcon, sIconText = makeIcon(searchBox, "search", 15, Theme.Dim, "?", UDim2.new(0, 11, 0.5, 0), Vector2.new(0, 0.5))
    local sInput = new("TextBox", {
        Parent = searchBox, Position = UDim2.fromOffset(34, 0), Size = UDim2.new(1, -78, 1, 0), BackgroundTransparency = 1, Text = "",
        PlaceholderText = "Search...", PlaceholderColor3 = Theme.Dim, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, ClearTextOnFocus = false, ZIndex = 5,
    })
    local kbd = new("TextLabel", {
        Parent = searchBox, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.fromOffset(0, 20), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Theme.Bg, BackgroundTransparency = 0, Text = "Ctrl F", TextSize = 11, W = "SemiBold", TextColor3 = Theme.Dim, ZIndex = 5,
    }, { corner(5), pad(6, 0, 6, 0), stroke(WHITE, 0.92) })
    win._searchInput = sInput
    -- the search box sits just left of the buttons, however many the script added
    local function placeSearch()
        local w = buttonsFrame.AbsoluteSize.X / effScale()
        searchBox.Position = UDim2.new(1, -(14 + w + 10), 0.5, 0)
    end
    buttonsFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(placeSearch)
    placeSearch()

    ------------------------------------------------------------------
    -- Pages & popups
    ------------------------------------------------------------------
    win.Pages = new("Frame", { Parent = Canvas, Position = UDim2.fromOffset(SIDE_W, HEAD_H), Size = UDim2.new(1, -SIDE_W, 1, -HEAD_H), BackgroundTransparency = 1, ClipsDescendants = true, ZIndex = 2 })
    win.PopupLayer = new("Frame", { Parent = Canvas, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 50 })

    -- Search results (persistent popup)
    local results = new("CanvasGroup", { Parent = win.PopupLayer, Size = UDim2.fromOffset(280, 0), BackgroundColor3 = Theme.Popup, Visible = false, GroupTransparency = 1, ZIndex = 60, Active = true }, { corner(10), stroke(WHITE, 0.88) })
    local resList = new("ScrollingFrame", { Parent = results, Size = UDim2.fromScale(1, 1), AutomaticCanvasSize = Enum.AutomaticSize.Y, ZIndex = 61 }, { vlist(2), pad(5, 5, 5, 5) })
    local resultsShown = false
    local function hideResults()
        if not resultsShown then return end
        resultsShown = false
        tween(results, { GroupTransparency = 1 }, 0.15)
        task.delay(0.16, function() if not resultsShown then results.Visible = false end end)
    end
    win._hideSearch = hideResults

    -- Resize handles
    local function resizer(handle, mode)
        local dragging, sp, ss
        connect(handle.InputBegan, function(i) if isPress(i) then dragging, sp, ss = true, ptr(i), win.Size win:_ClosePopup() end end)
        connect(UIS.InputChanged, function(i)
            if dragging and isMove(i) then
                local d = (ptr(i) - sp) / Library._Scale
                local w, h = ss.X, ss.Y
                if mode == "r" then w = ss.X + d.X
                elseif mode == "b" then h = ss.Y + d.Y
                else
                    local k = math.max(d.X / ss.X, d.Y / ss.Y)
                    w, h = ss.X * (1 + k), ss.Y * (1 + k)
                end
                win:_ApplySize(w, h, false, false)
            end
        end)
        connect(UIS.InputEnded, function(i) if dragging and isPress(i) then dragging = false end end)
    end
    local rH = new("Frame", { Parent = Root, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, 4, 0, 16), Size = UDim2.new(0, 8, 1, -36), BackgroundTransparency = 1, Active = true, ZIndex = 10 })
    local bH = new("Frame", { Parent = Root, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 16, 1, 4), Size = UDim2.new(1, -36, 0, 8), BackgroundTransparency = 1, Active = true, ZIndex = 10 })
    local cH = new("Frame", { Parent = Root, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, 4, 1, 4), Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 1, Active = true, ZIndex = 10 })
    local grip = {}
    for _, p in ipairs({ { 12, 12 }, { 7, 12 }, { 12, 7 } }) do
        table.insert(grip, new("Frame", { Parent = cH, Position = UDim2.fromOffset(p[1] - 6, p[2] - 6), Size = UDim2.fromOffset(2, 2), BackgroundColor3 = Theme.Dim, ZIndex = 11 }, { corner("full") }))
    end
    cH.MouseEnter:Connect(function() for _, g in ipairs(grip) do tween(g, { BackgroundColor3 = Theme.Accent }, 0.15) end end)
    cH.MouseLeave:Connect(function() for _, g in ipairs(grip) do tween(g, { BackgroundColor3 = Theme.Dim }, 0.2) end end)
    resizer(rH, "r") resizer(bH, "b") resizer(cH, "c")

    ------------------------------------------------------------------
    -- Overlay: toasts, tooltip
    ------------------------------------------------------------------
    local Overlay = new("Frame", { Parent = Gui, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 50 })
    win.Overlay = Overlay
    win.ToastHolder = new("Frame", {
        Parent = Overlay, AnchorPoint = Vector2.new(1, 1), Position = UDim2.new(1, -16, 1, -16), Size = UDim2.new(0, 310, 1, -32), BackgroundTransparency = 1,
    }, { new("UIListLayout", { VerticalAlignment = Enum.VerticalAlignment.Bottom, HorizontalAlignment = Enum.HorizontalAlignment.Right, Padding = UDim.new(0, 0), SortOrder = Enum.SortOrder.LayoutOrder }) })
    win.Tip = new("TextLabel", {
        Parent = Overlay, Visible = false, AutomaticSize = Enum.AutomaticSize.XY, BackgroundColor3 = Theme.Popup, BackgroundTransparency = 0,
        TextSize = 12, TextColor3 = Theme.Sub, ZIndex = 80, Size = UDim2.fromOffset(0, 0),
    }, { corner(7), stroke(WHITE, 0.88), pad(10, 6, 10, 6) })
    connect(RunService.Heartbeat, function()
        if win.Tip.Visible then
            local m = UIS:GetMouseLocation()
            win.Tip.Position = UDim2.fromOffset(m.X + 14, m.Y + 16)
        end
    end)

    win.FastMenu = buildFastMenu(win)
    win.KeybindList = buildKeybindList(win)

    -- Watermark
    local wm = new("Frame", {
        Parent = Gui, Position = UDim2.fromOffset(14, 14), Size = UDim2.fromOffset(0, 30), AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Theme.Side, Visible = false,
    }, { corner(8), stroke(WHITE, 0.9), pad(12, 0, 12, 0), hlist(8) })
    local wmDot = new("Frame", { Parent = wm, LayoutOrder = 1, Size = UDim2.fromOffset(7, 7), BackgroundColor3 = Theme.Accent }, { corner("full") })
    trackAccent(wmDot, "BackgroundColor3")
    local wmText = new("TextLabel", { Parent = wm, LayoutOrder = 2, Size = UDim2.fromOffset(0, 30), AutomaticSize = Enum.AutomaticSize.X, RichText = true, TextSize = 13 })
    win.Watermark = wm
    local frames, last, fps = 0, os.clock(), 60
    local pulse = 0
    connect(RunService.Heartbeat, function(dt)
        frames += 1
        if wm.Visible then
            pulse += dt
            wmDot.BackgroundTransparency = 0.25 + math.sin(pulse * 3) * 0.25
        end
        local now = os.clock()
        if now - last >= 0.5 then
            fps = math.floor(frames / (now - last) + 0.5)
            frames, last = 0, now
            win._fps = fps
            if wm.Visible then
                local ping = 0
                pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5) end)
                local dim = Theme.Dim:ToHex()
                wmText.Text = ('<b>%s</b>  <font color="#%s">|</font>  %d fps  <font color="#%s">|</font>  %d ms  <font color="#%s">|</font>  %s'):format(win.Title, dim, fps, dim, ping, dim, os.date("%H:%M"))
            end
        end
    end)

    -- Mobile OPEN button
    local mob = new("TextButton", {
        Parent = Gui, Position = UDim2.new(0.5, -40, 0, 70), Size = UDim2.fromOffset(80, 34), Text = "", BackgroundColor3 = WHITE, Visible = false,
    }, { corner("full"), stroke(WHITE, 0.7) })
    trackGrad(new("UIGradient", { Parent = mob, Rotation = 20 }))
    local mobInner = new("Frame", { Parent = mob, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, { hlist(6, Enum.HorizontalAlignment.Center) })
    local _, mobIc, mobIcT = makeIcon(mobInner, "layout-grid", 14, WHITE, nil)
    local mobTxt = new("TextLabel", { Parent = mobInner, LayoutOrder = 2, Size = UDim2.fromOffset(0, 34), AutomaticSize = Enum.AutomaticSize.X, Text = "OPEN", W = "Bold", TextSize = 13 })
    onAccent(function()
        local c = contrast(Theme.Accent)
        mobTxt.TextColor3 = c
        if mobIc then if mobIcT then mobIc.TextColor3 = c else mobIc.ImageColor3 = c end end
    end)
    win.MobileButton = mob
    do
        local dragging, moved, sp, st
        connect(mob.InputBegan, function(i) if isPress(i) then dragging, moved, sp, st = true, false, ptr(i), mob.Position end end)
        connect(UIS.InputChanged, function(i)
            if dragging and isMove(i) then
                local d = ptr(i) - sp
                if d.Magnitude > 6 then moved = true end
                if moved then mob.Position = UDim2.new(st.X.Scale, st.X.Offset + d.X, st.Y.Scale, st.Y.Offset + d.Y) end
            end
        end)
        connect(UIS.InputEnded, function(i)
            if dragging and isPress(i) then
                dragging = false
                if not moved then win:Toggle() end
            end
        end)
    end

    -- Bottom bar: a thin pill at the bottom centre of the screen (like a phone's home indicator);
    -- the default way to open the menu without a keyboard. Hit area is bigger than the line itself.
    local bar = new("TextButton", {
        Parent = Gui, AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -4), Size = UDim2.fromOffset(220, 24),
        BackgroundTransparency = 1, Text = "", Visible = false,
    })
    local barGlow = glow(bar, Theme.Accent, 30, 1)
    trackAccent(barGlow, "ImageColor3")
    local barLine = new("Frame", {
        Parent = bar, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(140, 5),
        BackgroundColor3 = WHITE, BackgroundTransparency = 0.35,
    }, { corner("full") })
    local barHover = false
    local function barLook()
        tween(barLine, {
            Size = UDim2.fromOffset(barHover and 176 or 140, barHover and 6 or 5),
            BackgroundColor3 = barHover and Theme.Accent or WHITE,
            BackgroundTransparency = barHover and 0 or (win.Open and 0.6 or 0.35),
        }, 0.25)
        tween(barGlow, { ImageTransparency = barHover and 0.45 or 1 }, 0.25)
    end
    win._barLook = barLook
    bar.MouseEnter:Connect(function() barHover = true barLook() end)
    bar.MouseLeave:Connect(function() barHover = false barLook() end)
    connect(bar.MouseButton1Click, function() win:Toggle() end)
    win.OpenBar = bar

    -- Bar (default) / Button / Off; cfg.MobileButton from older scripts still maps onto it
    win:SetOpenControl(cfg.OpenControl or (cfg.MobileButton == true and "Button") or (cfg.MobileButton == false and "Off") or "Bar")

    ------------------------------------------------------------------
    -- Input
    ------------------------------------------------------------------
    connect(UIS.InputBegan, function(input, gp)
        local lb = Library._Listening
        if lb then
            local ut = input.UserInputType
            if ut == Enum.UserInputType.Keyboard then
                if input.KeyCode == Enum.KeyCode.Escape then lb:StopListen()
                elseif input.KeyCode == Enum.KeyCode.Backspace then lb:StopListen() lb:SetKey(nil)
                else lb:StopListen() lb:SetKey(input.KeyCode) end
            elseif ut == Enum.UserInputType.MouseButton1 or ut == Enum.UserInputType.MouseButton2 or ut == Enum.UserInputType.MouseButton3 then
                lb:StopListen() lb:SetKey(ut)
            end
            return
        end
        if isPress(input) then
            local p = ptr(input)
            if win._popup and not inside(win._popup.Frame, p) and not inside(win._popup.Anchor, p) then win:_ClosePopup() end
            if resultsShown and not inside(results, p) and not inside(searchBox, p) then hideResults() end
        end
        if input.KeyCode == Enum.KeyCode.Escape and win._popup then win:_ClosePopup() end
        if win.Open and input.KeyCode == Enum.KeyCode.F and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl)) then
            task.defer(function() sInput:CaptureFocus() end)
            return
        end
        if gp or UIS:GetFocusedTextBox() then return end
        if keyMatches(input, win.ToggleKey) then win:Toggle() return end
        for _, b in ipairs(Library._Binds) do
            if b.Key and keyMatches(input, b.Key) then
                if b.Mode == "Toggle" then b:_fire(not b.Active)
                elseif b.Mode == "Hold" then b:_fire(true) end
            end
        end
    end)
    connect(UIS.InputEnded, function(input)
        for _, b in ipairs(Library._Binds) do
            if b.Mode == "Hold" and b.Key and keyMatches(input, b.Key) then b:_fire(false) end
        end
    end)

    connect(LocalPlayer.OnTeleport, function(state)
        if win.ExecuteOnTeleport and not Library._queued and (state == Enum.TeleportState.Started or state == Enum.TeleportState.RequestedFromServer) then
            Library._queued = Library:_QueueTeleport()
        elseif state == Enum.TeleportState.Failed then
            Library._queued = false
        end
    end)

    ------------------------------------------------------------------
    -- Search logic
    ------------------------------------------------------------------
    local function jump(e)
        hideResults()
        sInput.Text = ""
        sInput:ReleaseFocus()
        e.Tab:Select()
        if e.Section.Collapsed then
            e.Section:SetCollapsed(false, true)
            task.wait(0.35)
        end
        task.wait(0.08)
        local page = e.Tab.Scroll
        local y = (e.Row.AbsolutePosition.Y - page.AbsolutePosition.Y) / effScale() + page.CanvasPosition.Y - 40
        tween(page, { CanvasPosition = Vector2.new(0, math.max(0, y)) }, 0.45)
        task.wait(0.2)
        local hl = new("Frame", { Parent = e.Row, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1, ZIndex = 0 }, { corner(8) })
        local hs = new("UIStroke", { Parent = hl, Color = Theme.Accent, Transparency = 1, Thickness = 1.5 })
        tween(hl, { BackgroundTransparency = 0.85 }, 0.25)
        tween(hs, { Transparency = 0.2 }, 0.25)
        task.delay(1.1, function()
            tween(hl, { BackgroundTransparency = 1 }, 0.6)
            tween(hs, { Transparency = 1 }, 0.6)
            task.delay(0.65, function() hl:Destroy() end)
        end)
    end
    connect(sInput.Focused, function()
        tween(sStroke, { Color = Theme.Accent, Transparency = 0.3 }, 0.2)
        tween(kbd, { TextTransparency = 1, BackgroundTransparency = 1 }, 0.15)
        tintIcon(sIcon, sIconText, Theme.Accent)
    end)
    connect(sInput.FocusLost, function()
        tween(sStroke, { Color = WHITE, Transparency = 0.92 }, 0.2)
        if sInput.Text == "" then tween(kbd, { TextTransparency = 0, BackgroundTransparency = 0 }, 0.2) end
        tintIcon(sIcon, sIconText, Theme.Dim)
    end)
    connect(sInput:GetPropertyChangedSignal("Text"), function()
        local q = sInput.Text:lower()
        kbd.Visible = q == ""
        for _, c in ipairs(resList:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
        if q == "" then hideResults() return end
        local n = 0
        for _, e in ipairs(win._search) do
            if e.Name:lower():find(q, 1, true) then
                n += 1
                local b = new("TextButton", { Parent = resList, LayoutOrder = n, Size = UDim2.new(1, 0, 0, 42), BackgroundColor3 = WHITE, BackgroundTransparency = 1, Text = "", ZIndex = 62 }, { corner(7) })
                local _, ic, it = makeIcon(b, e.Tab.Icon or "corner-down-right", 15, Theme.Dim, "›", UDim2.new(0, 12, 0.5, 0), Vector2.new(0, 0.5))
                ic.ZIndex = 63
                ic.Parent.ZIndex = 63
                new("TextLabel", { Parent = b, Position = UDim2.fromOffset(36, 5), Size = UDim2.new(1, -44, 0, 17), Text = e.Name, TextSize = 13, W = "SemiBold", TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 63 })
                new("TextLabel", { Parent = b, Position = UDim2.fromOffset(36, 22), Size = UDim2.new(1, -44, 0, 14), Text = e.Tab.Name .. "  ›  " .. e.Section.Name, TextSize = 11, W = "Regular", TextColor3 = Theme.Dim, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 63 })
                b.MouseEnter:Connect(function() tween(b, { BackgroundTransparency = 0.95 }, 0.12) tintIcon(ic, it, Theme.Accent) end)
                b.MouseLeave:Connect(function() tween(b, { BackgroundTransparency = 1 }, 0.15) tintIcon(ic, it, Theme.Dim) end)
                b.MouseButton1Click:Connect(function() jump(e) end)
                if n >= 12 then break end
            end
        end
        if n == 0 then
            new("TextLabel", { Parent = resList, Size = UDim2.new(1, 0, 0, 34), Text = "Nothing found", TextColor3 = Theme.Dim, TextSize = 13, ZIndex = 63 })
        end
        local rows = math.max(n, 1)
        local H = math.min(rows, 6) * (n == 0 and 36 or 44) + 10
        local s = effScale()
        local rel = (searchBox.AbsolutePosition - Canvas.AbsolutePosition) / s
        local wR = math.max(searchBox.AbsoluteSize.X / s, 280)
        results.Position = UDim2.fromOffset(rel.X + searchBox.AbsoluteSize.X / s - wR, rel.Y + searchBox.AbsoluteSize.Y / s + 6)
        tween(results, { Size = UDim2.fromOffset(wR, H) }, resultsShown and 0.2 or 0)
        if not resultsShown then
            resultsShown = true
            results.Visible = true
            results.Size = UDim2.fromOffset(wR, H)
            tween(results, { GroupTransparency = 0 }, 0.2)
        end
    end)

    ------------------------------------------------------------------
    -- System config entries
    ------------------------------------------------------------------
    Library:RegisterFunction("_WindowSize", function() return win.Size end, function(v)
        if typeof(v) == "Vector2" then win:SetSize(v.X, v.Y, true) end
    end)
    Library:RegisterFunction("_FastMenuPosition", function() return win.FastMenu:GetPosition() end, function(v) win.FastMenu:SetPosition(v) end)
    Library:RegisterFunction("_FastMenuToggles", function() return win.FastMenu.SelToggles end, function(v) win.FastMenu:SetToggles(v) end)
    Library:RegisterFunction("_FastMenuButtons", function() return win.FastMenu.SelButtons end, function(v) win.FastMenu:SetButtons(v) end)
    Library:RegisterFunction("_KeybindListPosition", function() return win.KeybindList:GetPosition() end, function(v) win.KeybindList:SetPosition(v) end)

    genv.MoroLumina = Library

    ------------------------------------------------------------------
    -- Intro splash
    ------------------------------------------------------------------
    if win.LoaderSound then Library:PlaySound("Loader", win.NotifySoundVolume) end
    local splash = new("CanvasGroup", { Parent = Canvas, Size = UDim2.fromScale(1, 1), BackgroundColor3 = Theme.Bg, ZIndex = 200 })
    local sGlow = new("ImageLabel", { Parent = splash, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.42), Size = UDim2.fromOffset(260, 260), Image = IMG_GLOW, ImageColor3 = Theme.Accent, ImageTransparency = 1, ZIndex = 201 })
    local sLogo = new("Frame", { Parent = splash, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.42), Size = UDim2.fromOffset(60, 60), BackgroundColor3 = WHITE, ZIndex = 202 }, { corner(16), stroke(WHITE, 0.7) })
    trackGrad(new("UIGradient", { Parent = sLogo, Rotation = 45 }))
    local sLogoScale = new("UIScale", { Parent = sLogo, Scale = 0.4 })
    new("TextLabel", { Parent = sLogo, Size = UDim2.fromScale(1, 1), Text = win.Title:sub(1, 1):upper(), W = "Heavy", TextSize = 30, TextColor3 = contrast(Theme.Accent), ZIndex = 203 })
    local sTitle = new("TextLabel", { Parent = splash, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.42, 48), Size = UDim2.fromOffset(300, 26), Text = win.Title, W = "Bold", TextSize = 22, TextTransparency = 1, ZIndex = 202 })
    local sBar = new("Frame", { Parent = splash, AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.new(0.5, 0, 0.42, 88), Size = UDim2.fromOffset(150, 3), BackgroundColor3 = Theme.Off, ZIndex = 202 }, { corner("full") })
    local sFill = new("Frame", { Parent = sBar, Size = UDim2.fromScale(0, 1), BackgroundColor3 = WHITE, ZIndex = 203 }, { corner("full") })
    trackGrad(new("UIGradient", { Parent = sFill }))
    tween(sLogoScale, { Scale = 1 }, 0.7, Enum.EasingStyle.Back)
    tween(sGlow, { ImageTransparency = 0.55 }, 0.8)
    task.delay(0.15, function() tween(sTitle, { TextTransparency = 0 }, 0.5) end)
    tween(sFill, { Size = UDim2.fromScale(1, 1) }, 1.1, Enum.EasingStyle.Quart)
    task.delay(1.25, function()
        tween(splash, { GroupTransparency = 1 }, 0.4)
        task.delay(0.42, function() splash:Destroy() end)
    end)

    ------------------------------------------------------------------
    -- Minimized pill
    ------------------------------------------------------------------
    local mini = new("CanvasGroup", {
        Parent = Gui, Size = UDim2.fromOffset(0, 44), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = Theme.Side,
        Visible = false, GroupTransparency = 1, Active = true,
    }, { corner(12), stroke(WHITE, 0.88), pad(7, 0, 14, 0), hlist(10) })
    win._mini, win._miniScale = mini, new("UIScale", { Parent = mini })
    local miniLogo = new("Frame", { Parent = mini, LayoutOrder = 1, Size = UDim2.fromOffset(30, 30), BackgroundColor3 = WHITE }, { corner(8) })
    trackGrad(new("UIGradient", { Parent = miniLogo, Rotation = 45 }))
    local miniLetter = new("TextLabel", { Parent = miniLogo, Size = UDim2.fromScale(1, 1), Text = win.Title:sub(1, 1):upper(), W = "Heavy", TextSize = 15 })
    onAccent(function() miniLetter.TextColor3 = contrast(Theme.Accent) end)
    new("TextLabel", { Parent = mini, LayoutOrder = 2, Size = UDim2.fromOffset(0, 44), AutomaticSize = Enum.AutomaticSize.X, Text = win.Title, W = "Bold", TextSize = 14 })
    makeIcon(mini, "maximize-2", 14, Theme.Sub, "+").LayoutOrder = 3
    do
        local dragging, moved, sp, st
        connect(mini.InputBegan, function(i) if isPress(i) then dragging, moved, sp, st = true, false, ptr(i), mini.Position end end)
        connect(UIS.InputChanged, function(i)
            if dragging and isMove(i) then
                local d = ptr(i) - sp
                if d.Magnitude > 6 then moved = true end
                if moved then mini.Position = UDim2.new(st.X.Scale, st.X.Offset + d.X, st.Y.Scale, st.Y.Offset + d.Y) end
            end
        end)
        connect(UIS.InputEnded, function(i)
            if dragging and isPress(i) then
                dragging = false
                if not moved then win:Toggle(true) end
            end
        end)
    end

    for _, name in ipairs(cfg.TopButtons or {}) do win:SetTopButton(name) end
    win:_BuildProfileTab()
    -- start on the profile (scripts' first tab no longer auto-selects); cfg.OpenProfile = false keeps the old behaviour
    if cfg.OpenProfile ~= false then win:SelectTab(win.ProfileTab) end
    -- once the splash is gone, show for 2 s where the menu can be reopened from
    if cfg.OpenGuide ~= false then task.delay(1.7, function() if Library.Window == win then win:ShowOpenGuide(2) end end) end

    win.Effects.Set(cfg.Effect or "Sakura")
    win.Art.Set(cfg.ArtDefault or (cfg.Art == false and "Off") or "Art 1")

    win.Open = false
    win:Toggle(true)
    return win
end

----------------------------------------------------------------------
-- Window methods
----------------------------------------------------------------------
function Window:_DefaultTop(key, btn)
    if key == "bell" then
        self:_OpenHistory(btn)
    elseif key == "key" then
        if self.ConfigsTab then self:SelectTab(self.ConfigsTab) else self:Notify({ Text = "Configs tab not created", Type = "warning" }) end
    elseif key == "settings" then
        if self.SettingsTab then self:SelectTab(self.SettingsTab) else self:Notify({ Text = "Call Window:AddSettingsTab() first", Type = "warning" }) end
    elseif key == "user" then
        self:OpenProfile()
    end
end

local TOP_ICONS = { bell = { "bell", "!" }, key = { "key-round", "K" }, settings = { "settings", "*" }, user = { "user", "U" } }

-- adds a top-bar button (or rebinds an existing one). Without a callback the built-in action runs:
-- bell = notification history, key = Configs tab, settings = Settings tab, user = profile
function Window:SetTopButton(name, cb, icon)
    name = tostring(name):lower()
    self._top[name] = cb
    if self._topBtns[name] or name == "minimize" or name == "close" then return end
    local spec = TOP_ICONS[name]
    self._topOrder += 1
    local b = self._makeTopBtn(name, icon or (spec and spec[1]) or name, spec and spec[2] or name:sub(1, 1):upper(), self._topOrder)
    self._topBtns[name] = b
    if name == "bell" then
        self._badge = new("Frame", { Parent = b, AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(22, 9), Size = UDim2.fromOffset(0, 0), BackgroundColor3 = Theme.Bad, ZIndex = 7 }, { corner("full"), new("UIStroke", { Thickness = 2, Color = Theme.Bg }) })
        if self._unread > 0 then self._badge.Size = UDim2.fromOffset(8, 8) end
    end
    self._topDivider.Visible = true
end

function Window:RemoveTopButton(name)
    name = tostring(name):lower()
    local b = self._topBtns[name]
    if not b then return end
    b:Destroy()
    self._topBtns[name], self._top[name] = nil, nil
    if name == "bell" then self._badge = nil end
    self._topDivider.Visible = next(self._topBtns) ~= nil
end

-- hides the window into a small draggable pill; clicking it (or the toggle key) brings the window back
function Window:Minimize()
    if not self.Open then return end
    local mini = self._mini
    local ap = self.Root.AbsolutePosition
    mini.Position = UDim2.fromOffset(ap.X, ap.Y)
    self:Toggle(false)
    self._minimized = true
    mini.Visible = true
    mini.GroupTransparency = 1
    self._miniScale.Scale = 0.9
    tween(mini, { GroupTransparency = 0 }, 0.25)
    tween(self._miniScale, { Scale = 1 }, 0.35, Enum.EasingStyle.Back)
end

-- how the menu is opened without a keyboard: "Bar" (bottom of the screen), "Button" (draggable OPEN pill) or "Off"
function Window:SetOpenControl(mode)
    mode = tostring(mode)
    if mode ~= "Bar" and mode ~= "Button" and mode ~= "Off" then mode = "Bar" end
    self.OpenControl = mode
    self.OpenBar.Visible = mode == "Bar"
    self.MobileButton.Visible = mode == "Button"
end
function Window:GetOpenControl() return self.OpenControl end

-- briefly points at the open control: pulsing outline, an arrow and "Press here to open"
function Window:ShowOpenGuide(duration)
    local target = (self.OpenControl == "Bar" and self.OpenBar) or (self.OpenControl == "Button" and self.MobileButton) or nil
    if not target or not target.Visible then return end
    if self._guide then self._guide() end
    -- positions are relative to the overlay: its origin can sit below Roblox's top bar while the control's does not
    local ap, as = target.AbsolutePosition - self.Overlay.AbsolutePosition, target.AbsoluteSize
    local below = ap.Y < self.Overlay.AbsoluteSize.Y / 2 -- control at the top: guide goes underneath
    local parts = {}

    local outline = new("Frame", {
        Parent = self.Overlay, Position = UDim2.fromOffset(ap.X - 6, ap.Y - 6), Size = UDim2.fromOffset(as.X + 12, as.Y + 12),
        BackgroundColor3 = Theme.Accent, BackgroundTransparency = 1, ZIndex = 90,
    }, { corner("full") })
    local ost = new("UIStroke", { Parent = outline, Color = Theme.Accent, Thickness = 2, Transparency = 1 })
    local label = new("TextLabel", {
        Parent = self.Overlay, AnchorPoint = Vector2.new(0.5, below and 0 or 1), Size = UDim2.fromOffset(0, 30), AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.fromOffset(ap.X + as.X / 2, below and (ap.Y + as.Y + 40) or (ap.Y - 40)),
        Text = "Press here to open", W = "SemiBold", TextSize = 14, BackgroundColor3 = Theme.Side, BackgroundTransparency = 1, TextTransparency = 1, ZIndex = 91,
    }, { corner(8), pad(12, 0, 12, 0) })
    local lst = stroke(Theme.Accent, 1)
    lst.Parent = label
    local arrowHolder, arrow, arrowIsText = makeIcon(self.Overlay, below and "arrow-up" or "arrow-down", 20, Theme.Accent, below and "^" or "v",
        UDim2.fromOffset(ap.X + as.X / 2, below and (ap.Y + as.Y + 20) or (ap.Y - 20)), Vector2.new(0.5, 0.5))
    arrowHolder.ZIndex = 91
    arrow.ZIndex = 91
    if arrowIsText then arrow.TextTransparency = 1 else arrow.ImageTransparency = 1 end
    parts = { outline, label, arrowHolder }

    local alive = true
    local function fade(on, t)
        tween(outline, { BackgroundTransparency = on and 0.88 or 1 }, t)
        tween(ost, { Transparency = on and 0 or 1 }, t)
        tween(label, { BackgroundTransparency = on and 0.05 or 1, TextTransparency = on and 0 or 1 }, t)
        tween(lst, { Transparency = on and 0.5 or 1 }, t)
        tween(arrow, arrowIsText and { TextTransparency = on and 0 or 1 } or { ImageTransparency = on and 0 or 1 }, t)
    end
    fade(true, 0.3)
    -- the arrow bobs towards the control and the outline breathes while the guide is up
    task.spawn(function()
        local base = arrowHolder.Position
        local dir = below and -1 or 1
        while alive do
            tween(arrowHolder, { Position = base + UDim2.fromOffset(0, 6 * dir) }, 0.35, Enum.EasingStyle.Sine)
            tween(ost, { Thickness = 3 }, 0.35, Enum.EasingStyle.Sine)
            task.wait(0.35)
            if not alive then break end
            tween(arrowHolder, { Position = base }, 0.35, Enum.EasingStyle.Sine)
            tween(ost, { Thickness = 1.5 }, 0.35, Enum.EasingStyle.Sine)
            task.wait(0.35)
        end
    end)
    local function finish()
        if not alive then return end
        alive = false
        self._guide = nil
        fade(false, 0.3)
        task.delay(0.32, function() for _, p in ipairs(parts) do p:Destroy() end end)
    end
    self._guide = finish
    task.delay(duration or 2, finish)
end

function Window:IsOpen() return self.Open end

function Window:Toggle(state)
    if state == nil then state = not self.Open end
    state = state and true or false
    if state == self.Open then return end
    self.Open = state
    if self._barLook then self._barLook() end
    self.Effects.OnToggle(state)
    self.Art.OnToggle(state)
    self:_ClosePopup()
    if self._hideSearch then self._hideSearch() end
    if Library._tipTarget then Library._tipTarget = nil self:_HideTip() end
    if state then
        if self._minimized then
            self._minimized = false
            local mini = self._mini
            tween(mini, { GroupTransparency = 1 }, 0.15)
            task.delay(0.16, function() if not self._minimized then mini.Visible = false end end)
        end
        self.Root.Visible = true
        tween(self.AnimScale, { Scale = 1 }, 0.45, Enum.EasingStyle.Back)
        tween(self.Canvas, { GroupTransparency = 0 }, 0.3)
        tween(self._Shadow, { ImageTransparency = 0.2 }, 0.4)
        tween(self._AccentGlow, { ImageTransparency = 0.88 }, 0.6)
        if self.BlurEnabled then tween(self.Blur, { Size = 14 }, 0.4) end
    else
        tween(self.AnimScale, { Scale = 0.94 }, 0.22, Enum.EasingStyle.Quad)
        tween(self.Canvas, { GroupTransparency = 1 }, 0.2)
        tween(self._Shadow, { ImageTransparency = 1 }, 0.2)
        tween(self._AccentGlow, { ImageTransparency = 1 }, 0.2)
        tween(self.Blur, { Size = 0 }, 0.25)
        task.delay(0.22, function()
            if not self.Open and self.Root.Parent then self.Root.Visible = false end
        end)
    end
end

-- background particles: Library.EffectNames ("Off", "Sakura", "Snow", "Rain", "Stars", "Fireflies", "Embers", "Bubbles")
function Window:SetEffect(name) self.Effects.Set(name) end
function Window:GetEffect() return self.Effects.Name end
function Window:SetEffectDensity(d) self.Effects.SetDensity(d) end
function Window:SetEffectFullscreen(b) self.Effects.SetFullscreen(b) end

-- character art next to the window: "Off", "Random" or a slot name from Library.Art / cfg.Art
function Window:SetArt(name) self.Art.Set(name) end
function Window:GetArt() return self.Art.Name end
function Window:SetArtSide(side) self.Art.Side = side == "Left" and "Left" or "Right" self.Art.Place() end
function Window:SetArtFront(b) self.Art.Front = b and true or false self.Art.Place() end
function Window:SetArtSize(k) self.Art.Size = math.clamp(tonumber(k) or 1.1, 0.4, 2) self.Art.Place() end
function Window:SetArtOpacity(k) self.Art.Opacity = math.clamp(tonumber(k) or 1, 0, 1) self.Art.Place() end

function Window:SetBlur(b)
    self.BlurEnabled = b and true or false
    tween(self.Blur, { Size = (self.BlurEnabled and self.Open) and 14 or 0 }, 0.3)
end

local function parseSize(a, b)
    if typeof(a) == "UDim2" then
        local vp = workspace.CurrentCamera.ViewportSize
        return a.X.Scale * vp.X + a.X.Offset, a.Y.Scale * vp.Y + a.Y.Offset
    elseif typeof(a) == "Vector2" then return a.X, a.Y
    elseif type(a) == "table" then return a[1] or a.Width or a.X or a.w, a[2] or a.Height or a.Y or a.h end
    return a, b
end

function Window:_ApplySize(w, h, animate, keepCenter)
    w = math.clamp(tonumber(w) or self.Size.X, MIN_W, MAX_W)
    h = math.clamp(tonumber(h) or self.Size.Y, MIN_H, MAX_H)
    local s = Library._Scale
    local pos = self.Root.Position
    if keepCenter then
        pos = UDim2.new(pos.X.Scale, pos.X.Offset + (self.Size.X - w) * s / 2, pos.Y.Scale, pos.Y.Offset + (self.Size.Y - h) * s / 2)
    end
    self.Size = Vector2.new(w, h)
    if animate then
        tween(self.Root, { Size = UDim2.fromOffset(w, h), Position = pos }, 0.4)
    else
        self.Root.Size = UDim2.fromOffset(w, h)
        self.Root.Position = pos
    end
end
function Window:SetSize(a, b, animate)
    local w, h = parseSize(a, b)
    if type(b) == "boolean" and animate == nil then animate = b end
    self:_ApplySize(w, h, animate, true)
end
function Window:GetSize() return self.Size end

function Window:_SetUIScale(n)
    n = math.clamp(tonumber(n) or 1, 0.5, 1.5)
    local old = Library._Scale
    if n == old then return end
    local pos = self.Root.Position
    Library._Scale = n
    self:_ClosePopup()
    tween(self.Root, { Position = UDim2.new(pos.X.Scale, pos.X.Offset + self.Size.X * (old - n) / 2, pos.Y.Scale, pos.Y.Offset + self.Size.Y * (old - n) / 2) }, 0.35)
    local tw = tween(self.RootScale, { Scale = n }, 0.35)
    tw.Completed:Once(function()
        for _, t in ipairs(self.Tabs) do for _, s in ipairs(t.Sections) do s.Sync() end end
        self:_MovePill(false)
    end)
end

function Window:SetToggleKey(k)
    local key = resolveKey(k)
    if not key then return end
    self.ToggleKey = key
    local u = self._ui.MenuBind
    if u then u.Set(key, true) end
end
function Window:GetToggleKey() return self.ToggleKey end
function Window:GetFastMenu() return self.FastMenu end
function Window:GetKeybindList() return self.KeybindList end

function Window:_AddSearch(name, row, section)
    table.insert(self._search, { Name = name, Row = row, Section = section, Tab = section.Tab })
end

function Window:_ShowTip(text)
    self.Tip.Text = text
    self.Tip.Visible = true
    self.Tip.TextTransparency = 1
    self.Tip.BackgroundTransparency = 1
    tween(self.Tip, { TextTransparency = 0, BackgroundTransparency = 0 }, 0.15)
end
function Window:_HideTip() self.Tip.Visible = false end

-- generic popup inside the window (dropdowns, color pickers, history)
function Window:_ClosePopup()
    local p = self._popup
    if not p then return end
    self._popup = nil
    if p.OnClose then call(p.OnClose) end
    tween(p.Frame, { GroupTransparency = 1, Position = p.Frame.Position - UDim2.fromOffset(0, 6) }, 0.15)
    task.delay(0.16, function() p.Frame:Destroy() end)
end

-- minHeight: the popup may shrink down to this to stay below its anchor (scrollable content);
-- omit it for fixed-size content, which flips above when it does not fit
function Window:_OpenPopup(anchor, width, height, build, onClose, alignRight, minHeight)
    self:_ClosePopup()
    local s = effScale()
    local canvas = self.Canvas
    local ap = (anchor.AbsolutePosition - canvas.AbsolutePosition) / s
    local as = anchor.AbsoluteSize / s
    local cw, ch = canvas.AbsoluteSize.X / s, canvas.AbsoluteSize.Y / s
    local x = alignRight == false and ap.X or (ap.X + as.X - width)
    x = math.clamp(x, 8, cw - width - 8)
    local y = ap.Y + as.Y + 6
    local below = ch - 8 - y
    local above = ap.Y - 6 - 8
    if height > below then
        local floor = minHeight or height
        if below >= math.min(floor, height) then
            height = below
        elseif above > below then
            height = math.min(height, above)
            y = ap.Y - 6 - height
        else
            height = below
        end
    end
    local f = new("CanvasGroup", {
        Parent = self.PopupLayer, Position = UDim2.fromOffset(x, y - 6), Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = Theme.Popup, GroupTransparency = 1, ZIndex = 60, Active = true, -- swallow clicks so rows under the popup stay untouched
    }, { corner(10), stroke(WHITE, 0.88) })
    build(f)
    tween(f, { GroupTransparency = 0, Position = UDim2.fromOffset(x, y) }, 0.25)
    self._popup = { Frame = f, Anchor = anchor, OnClose = onClose }
    return self._popup
end

function Window:_OpenColorPopup(anchor, get, set)
    if self._popup and self._popup.Anchor == anchor then self:_ClosePopup() return end
    local picker
    local p = self:_OpenPopup(anchor, 240, 256, function(body)
        pad(10, 10, 10, 10).Parent = body
        picker = buildPicker(body, get(), set)
    end)
    p.Picker = picker
end

function Window:_OpenHistory(anchor)
    if self._popup and self._popup.Anchor == anchor then self:_ClosePopup() return end
    self._unread = 0
    if self._badge then tween(self._badge, { Size = UDim2.fromOffset(0, 0) }, 0.2) end
    local hist = Library._History
    local n = math.min(#hist, 6)
    local H = 44 + math.max(n, 1) * 48 + 6
    self:_OpenPopup(anchor, 300, H, function(body)
        new("TextLabel", { Parent = body, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -28, 0, 40), Text = "Notifications", W = "Bold", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left })
        new("TextLabel", { Parent = body, Position = UDim2.fromOffset(14, 0), Size = UDim2.new(1, -28, 0, 40), Text = #hist .. " total", TextSize = 12, W = "Regular", TextColor3 = Theme.Dim, TextXAlignment = Enum.TextXAlignment.Right })
        new("Frame", { Parent = body, Position = UDim2.fromOffset(0, 40), Size = UDim2.new(1, 0, 0, 1), BackgroundColor3 = WHITE, BackgroundTransparency = 0.93 })
        local list = new("Frame", { Parent = body, Position = UDim2.fromOffset(0, 44), Size = UDim2.new(1, 0, 1, -44), BackgroundTransparency = 1 }, { vlist(0), pad(6, 0, 6, 6) })
        if n == 0 then
            new("TextLabel", { Parent = list, Size = UDim2.new(1, 0, 0, 48), Text = "No notifications yet", TextColor3 = Theme.Dim, TextSize = 13 })
        end
        local colors = { info = Theme.Info, success = Theme.Good, warning = Theme.Warn, error = Theme.Bad }
        for i = #hist, #hist - n + 1, -1 do
            local e = hist[i]
            local r = new("Frame", { Parent = list, LayoutOrder = #hist - i, Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1 })
            new("Frame", { Parent = r, Position = UDim2.fromOffset(10, 13), Size = UDim2.fromOffset(8, 8), BackgroundColor3 = colors[e.Type] or Theme.Accent }, { corner("full") })
            new("TextLabel", { Parent = r, Position = UDim2.fromOffset(28, 6), Size = UDim2.new(1, -80, 0, 18), Text = e.Title, W = "SemiBold", TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
            new("TextLabel", { Parent = r, Position = UDim2.fromOffset(28, 24), Size = UDim2.new(1, -38, 0, 16), Text = e.Text, W = "Regular", TextSize = 12, TextColor3 = Theme.Sub, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
            new("TextLabel", { Parent = r, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -10, 0, 6), Size = UDim2.fromOffset(50, 18), Text = os.date("%H:%M", e.Time), W = "Regular", TextSize = 11, TextColor3 = Theme.Dim, TextXAlignment = Enum.TextXAlignment.Right })
        end
    end)
end

-- Profile page (hidden tab, opened from the user card). Left: the 3D character. Right: universal
-- Account / Session info. Scripts add their own sections through Window:GetProfileTab().
function Window:_BuildProfileTab()
    local win = self
    local tab = self:CreateTab({ Name = "Profile", Icon = "user", Hidden = true })
    self.ProfileTab = tab

    local charSec = tab:Column("left"):CreateSection({ Name = "Character", Icon = "user-round", Collapsible = false })
    local preview = charSec:AddCharacterPreview({ Name = "Profile Preview", Height = 330 })
    charSec:AddButton({ Name = "Refresh Model", Icon = "refresh-cw", NoFastMenu = true, Callback = function() preview.Refresh() end })

    -- Backpack: every Tool in the player's Backpack plus the one in hand, same names grouped with a count
    local bag = tab:Column("left"):CreateSection({ Name = "Backpack", Icon = "backpack", Collapsible = false })
    local bagCount = bag:AddLabel("Loading...")
    local bagList = new("Frame", { Parent = bag.Content, LayoutOrder = nextOrder(bag), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, { vlist(4), pad(4, 0, 4, 4) })
    local pending = false
    local function renderBag()
        pending = false
        for _, c in ipairs(bagList:GetChildren()) do if c:IsA("GuiObject") then c:Destroy() end end
        local items, order = {}, {}
        local function add(tool, equipped)
            local e = items[tool.Name]
            if not e then
                e = { Name = tool.Name, Count = 0, Equipped = false, Texture = tool.TextureId }
                items[tool.Name] = e
                table.insert(order, e)
            end
            e.Count += 1
            e.Equipped = e.Equipped or equipped
        end
        local char = LocalPlayer.Character
        if char then for _, t in ipairs(char:GetChildren()) do if t:IsA("Tool") then add(t, true) end end end
        local pack = LocalPlayer:FindFirstChildOfClass("Backpack")
        if pack then for _, t in ipairs(pack:GetChildren()) do if t:IsA("Tool") then add(t, false) end end end
        table.sort(order, function(a, b)
            if a.Equipped ~= b.Equipped then return a.Equipped end
            return a.Name:lower() < b.Name:lower()
        end)
        local total = 0
        for i, e in ipairs(order) do
            total += e.Count
            local row = new("Frame", { Parent = bagList, LayoutOrder = i, Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.Field }, { corner(8) })
            if e.Equipped then
                local st = stroke(Theme.Accent, 0.45)
                st.Parent = row
            end
            local iconBox = new("Frame", { Parent = row, Position = UDim2.fromOffset(6, 6), Size = UDim2.fromOffset(24, 24), BackgroundColor3 = Theme.Bg }, { corner(6) })
            if e.Texture and e.Texture ~= "" then
                new("ImageLabel", { Parent = iconBox, Size = UDim2.fromScale(1, 1), Image = e.Texture }, { corner(6) })
            else
                makeIcon(iconBox, "box", 13, Theme.Dim, "#")
            end
            new("TextLabel", { Parent = row, Position = UDim2.fromOffset(38, 0), Size = UDim2.new(1, -130, 1, 0), Text = e.Name, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
            local right = new("Frame", { Parent = row, AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(1, -8, 0.5, 0), Size = UDim2.new(0, 0, 1, 0), AutomaticSize = Enum.AutomaticSize.X, BackgroundTransparency = 1 },
                { hlist(6, Enum.HorizontalAlignment.Right) })
            if e.Equipped then
                local tag = new("TextLabel", { Parent = right, LayoutOrder = 1, Size = UDim2.fromOffset(0, 18), AutomaticSize = Enum.AutomaticSize.X, Text = "IN HAND", W = "SemiBold", TextSize = 10, BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.82 }, { corner(5), pad(6, 0, 6, 0) })
                tag.TextColor3 = Theme.Accent
            end
            if e.Count > 1 then
                new("TextLabel", { Parent = right, LayoutOrder = 2, Size = UDim2.fromOffset(0, 18), AutomaticSize = Enum.AutomaticSize.X, Text = "x" .. e.Count, W = "SemiBold", TextSize = 12, TextColor3 = Theme.Sub })
            end
        end
        if total == 0 then
            new("TextLabel", { Parent = bagList, Size = UDim2.new(1, 0, 0, 30), Text = "Backpack is empty", TextColor3 = Theme.Dim, TextSize = 13 })
        end
        bagCount.Set(("<b>%d</b> item%s, <b>%d</b> kind%s"):format(total, total == 1 and "" or "s", #order, #order == 1 and "" or "s"))
    end
    -- batch bursts of changes (respawn refills the whole backpack at once) into one redraw
    local function queueBag()
        if pending then return end
        pending = true
        task.defer(renderBag)
    end
    local watched = {}
    local function watch(container)
        if not container or watched[container] then return end
        watched[container] = true
        connect(container.ChildAdded, function(c) if c:IsA("Tool") then queueBag() end end)
        connect(container.ChildRemoved, function(c) if c:IsA("Tool") then queueBag() end end)
    end
    watch(LocalPlayer:FindFirstChildOfClass("Backpack"))
    watch(LocalPlayer.Character)
    connect(LocalPlayer.ChildAdded, function(c) if c:IsA("Backpack") then watch(c) queueBag() end end)
    connect(LocalPlayer.CharacterAdded, function(c) watch(c) queueBag() end)
    renderBag()

    -- identity block: avatar, display name, @username, badges
    local acc = tab:Column("right"):CreateSection({ Name = "Account", Icon = "fingerprint", Collapsible = false })
    local id = new("Frame", { Parent = acc.Content, LayoutOrder = nextOrder(acc), Size = UDim2.new(1, 0, 0, 74), BackgroundTransparency = 1 })
    local av = new("Frame", { Parent = id, Position = UDim2.fromOffset(8, 10), Size = UDim2.fromOffset(54, 54), BackgroundColor3 = Theme.Field }, { corner("full") })
    local avStroke = new("UIStroke", { Parent = av, Thickness = 2, Color = Theme.Accent })
    trackAccent(avStroke, "Color")
    local avGlow = glow(av, Theme.Accent, 30, 0.75, 0)
    trackAccent(avGlow, "ImageColor3")
    fillAvatar(av, 22, 1)
    new("TextLabel", { Parent = id, Position = UDim2.fromOffset(76, 12), Size = UDim2.new(1, -84, 0, 24), Text = LocalPlayer.DisplayName, W = "Bold", TextSize = 21, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
    new("TextLabel", { Parent = id, Position = UDim2.fromOffset(76, 36), Size = UDim2.new(1, -84, 0, 16), Text = "@" .. LocalPlayer.Name, W = "Regular", TextSize = 13, TextColor3 = Theme.Dim, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
    local badges = new("Frame", { Parent = id, Position = UDim2.fromOffset(76, 55), Size = UDim2.new(1, -84, 0, 18), BackgroundTransparency = 1 }, { hlist(5) })
    local function badge(text, color, order)
        local b = new("TextLabel", {
            Parent = badges, LayoutOrder = order, Size = UDim2.fromOffset(0, 18), AutomaticSize = Enum.AutomaticSize.X, Text = text,
            W = "SemiBold", TextSize = 10, TextColor3 = color, BackgroundColor3 = color, BackgroundTransparency = 0.85,
        }, { corner(5), pad(7, 0, 7, 0) })
        return b
    end
    local ageDays = LocalPlayer.AccountAge
    if LocalPlayer.MembershipType == Enum.MembershipType.Premium then badge("PREMIUM", Theme.Warn, 1) end
    if LocalPlayer.HasVerifiedBadge then badge("VERIFIED", Theme.Info, 2) end
    local accentBadge = badge(ageDays >= 365 and ((ageDays // 365) .. "Y ACCOUNT") or "NEW ACCOUNT", Theme.Accent, 3)
    onAccent(function() accentBadge.TextColor3 = Theme.Accent accentBadge.BackgroundColor3 = Theme.Accent end)

    local years, months = ageDays // 365, (ageDays % 365) // 30
    acc:AddStat({ Name = "User ID", Value = LocalPlayer.UserId, Copy = true })
    acc:AddStat({ Name = "Account Age", Value = (years > 0 and (years .. "y ") or "") .. months .. "mo  <font color=\"#" .. Theme.Dim:ToHex() .. "\">(" .. ageDays .. " days)</font>" })
    acc:AddStat({ Name = "Joined Roblox", Value = os.date("%d %b %Y", os.time() - ageDays * 86400) })
    acc:AddStat({ Name = "Profile Link", Value = "roblox.com/users/" .. LocalPlayer.UserId, Copy = true })

    local function clock(sec)
        sec = math.floor(sec)
        return ("%d:%02d:%02d"):format(sec // 3600, sec % 3600 // 60, sec % 60)
    end
    local sess = tab:Column("right"):CreateSection({ Name = "Session", Icon = "activity", Collapsible = false })
    local gameStat = sess:AddStat({ Name = "Game", Value = "..." })
    task.spawn(function()
        local ok, info = pcall(function() return S("MarketplaceService"):GetProductInfo(game.PlaceId) end)
        gameStat.Set(ok and info and info.Name or tostring(game.PlaceId))
    end)
    sess:AddStat({ Name = "Players", Get = function() return #Players:GetPlayers() .. " / " .. Players.MaxPlayers end })
    sess:AddStat({ Name = "Ping", Interval = 0.5, Get = function()
        local ping = 0
        pcall(function() ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5) end)
        return ping .. " ms"
    end })
    sess:AddStat({ Name = "FPS", Interval = 0.5, Get = function() return win._fps or "-" end })
    sess:AddStat({ Name = "Session Time", Get = function() return clock(os.clock() - (win._sessionStart or os.clock())) end })
    sess:AddStat({ Name = "Server Uptime", Get = function() return clock(workspace.DistributedGameTime) end })
    local okExec, exec = pcall(function() return identifyexecutor and identifyexecutor() end)
    sess:AddStat({ Name = "Executor", Value = (okExec and exec) or "Unknown" })
    sess:AddButton({ Name = "Copy Join Script", Icon = "link", NoFastMenu = true, Tooltip = "A one-line script that joins this exact server", Callback = function()
        local line = ('game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s")'):format(game.PlaceId, game.JobId)
        local sc = setclipboard or toclipboard
        if sc then pcall(sc, line) end
        win:Notify({ Title = "Session", Text = "Join script copied", Type = "success", Sound = false, Duration = 2 })
    end })

    -- sections a script adds later go left/right alternately, not into the last column used here
    tab._col = nil
    return tab
end

-- the profile tab, for scripts to add their own sections: Window:GetProfileTab():Column("right"):CreateSection{...}
function Window:GetProfileTab() return self.ProfileTab end

function Window:OpenProfile()
    if self.ProfileTab then self:SelectTab(self.ProfileTab) end
end

-- Notifications
function Window:Notify(o)
    if type(o) == "string" then o = { Text = o } end
    o = o or {}
    local typ = tostring(o.Type or "info"):lower()
    if typ == "warn" then typ = "warning" end
    local colors = { info = Theme.Info, success = Theme.Good, warning = Theme.Warn, error = Theme.Bad }
    local icons = { info = "info", success = "circle-check", warning = "triangle-alert", error = "circle-x" }
    local titles = { info = "Info", success = "Success", warning = "Warning", error = "Error" }
    local color = colors[typ] or Theme.Accent
    local title = o.Title or titles[typ] or "Notice"
    local text = tostring(o.Text or o.Content or o.Description or "")
    local duration = o.Duration or 4
    table.insert(Library._History, { Title = title, Text = text, Type = typ, Time = os.time() })
    if not self.Open or not (self._popup and self._popup.Anchor) then
        self._unread += 1
        if self._badge then tween(self._badge, { Size = UDim2.fromOffset(8, 8) }, 0.3, Enum.EasingStyle.Back) end
    end

    if o.Sound ~= false and self.NotifySound then
        local sn = typ == "warning" and "Warn" or typ == "error" and "Error" or self.NotifySoundName
        Library:PlaySound(sn, self.NotifySoundVolume)
    end

    local wrap = new("Frame", { Parent = self.ToastHolder, LayoutOrder = math.floor(os.clock() * 1000), Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1, ClipsDescendants = false })
    local card = new("CanvasGroup", {
        Parent = wrap, Position = UDim2.fromOffset(50, 0), Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Side, GroupTransparency = 1, Active = true,
    }, { corner(12), stroke(WHITE, 0.88) })
    local tint = new("Frame", { Parent = card, Size = UDim2.fromScale(1, 1), BackgroundColor3 = color, BackgroundTransparency = 0.9 })
    new("UIGradient", { Parent = tint, Transparency = NumberSequence.new(0.2, 1) })
    local content = new("Frame", { Parent = card, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, { pad(56, 12, 34, 16), vlist(3) })
    local iconBg = new("Frame", { Parent = card, Position = UDim2.fromOffset(14, 12), Size = UDim2.fromOffset(30, 30), BackgroundColor3 = color, BackgroundTransparency = 0.82 }, { corner(9) })
    makeIcon(iconBg, icons[typ] or "info", 16, color, "!")
    new("TextLabel", { Parent = content, LayoutOrder = 1, Size = UDim2.new(1, 0, 0, 18), Text = title, W = "Bold", TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd })
    if text ~= "" then
        new("TextLabel", { Parent = content, LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, Text = text, W = "Regular", TextSize = 13, TextColor3 = Theme.Sub, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left })
    end
    local closeB = new("TextButton", { Parent = card, AnchorPoint = Vector2.new(1, 0), Position = UDim2.new(1, -8, 0, 10), Size = UDim2.fromOffset(20, 20), BackgroundTransparency = 1, Text = "", ZIndex = 6 })
    local _, cIc, cIt = makeIcon(closeB, "x", 13, Theme.Dim, "x")
    closeB.MouseEnter:Connect(function() tintIcon(cIc, cIt, Theme.Text) end)
    closeB.MouseLeave:Connect(function() tintIcon(cIc, cIt, Theme.Dim) end)
    local barBg = new("Frame", { Parent = card, AnchorPoint = Vector2.new(0, 1), Position = UDim2.new(0, 0, 1, 0), Size = UDim2.new(1, 0, 0, 3), BackgroundColor3 = WHITE, BackgroundTransparency = 0.95 })
    local bar = new("Frame", { Parent = barBg, Size = UDim2.fromScale(1, 1), BackgroundColor3 = color })
    new("UIGradient", { Parent = bar, Transparency = NumberSequence.new(0.6, 0) })

    local gone = false
    local function dismiss()
        if gone then return end
        gone = true
        tween(card, { Position = UDim2.fromOffset(60, 0), GroupTransparency = 1 }, 0.3)
        task.delay(0.25, function()
            tween(wrap, { Size = UDim2.new(1, 0, 0, 0) }, 0.3)
            task.delay(0.32, function() wrap:Destroy() end)
        end)
    end
    closeB.MouseButton1Click:Connect(dismiss)
    task.spawn(function()
        RunService.Heartbeat:Wait()
        RunService.Heartbeat:Wait()
        if gone or not card.Parent then return end
        local h = card.AbsoluteSize.Y + 8
        tween(wrap, { Size = UDim2.new(1, 0, 0, h) }, 0.35)
        tween(card, { Position = UDim2.fromOffset(0, 0), GroupTransparency = 0 }, 0.5, Enum.EasingStyle.Back)
        tween(bar, { Size = UDim2.fromScale(0, 1) }, duration, Enum.EasingStyle.Linear)
        task.wait(duration)
        dismiss()
    end)
    return { Dismiss = dismiss }
end
function Library:Notify(o) if self.Window then return self.Window:Notify(o) end end

-- Tabs
function Window:AddTabLabel(text)
    new("TextLabel", { Parent = self.TabList, LayoutOrder = #self.Tabs * 2 + 1, Size = UDim2.new(1, 0, 0, 26), Text = tostring(text):upper(), W = "Bold", TextSize = 11, TextColor3 = Theme.Dim, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 4 }, { pad(12, 8, 0, 0) })
end

function Window:CreateTab(cfg)
    cfg = cfg or {}
    -- Hidden = true: a page with no sidebar button (opened from code, e.g. the profile)
    local tab = setmetatable({ Window = self, Name = cfg.Name or "Tab", Icon = cfg.Icon, Sections = {}, Hidden = cfg.Hidden }, Tab)
    local btn = new("TextButton", { Parent = self.TabList, LayoutOrder = #self.Tabs * 2 + 2, Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = WHITE, BackgroundTransparency = 1, Text = "", ZIndex = 4, Visible = not cfg.Hidden }, { corner(9) })
    local xo = 14
    local iconObj, iconText
    if cfg.Icon then
        local h
        h, iconObj, iconText = makeIcon(btn, cfg.Icon, 17, Theme.Dim, tab.Name:sub(1, 1), UDim2.new(0, 14, 0.5, 0), Vector2.new(0, 0.5))
        iconObj.ZIndex = 5
        xo = 42
    end
    local lbl = new("TextLabel", { Parent = btn, Position = UDim2.fromOffset(xo, 0), Size = UDim2.new(1, -xo - 6, 1, 0), Text = tab.Name, TextColor3 = Theme.Sub, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd, ZIndex = 5 })

    local holder = new("CanvasGroup", { Parent = self.Pages, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = false, GroupTransparency = 1 })
    local page = new("ScrollingFrame", { Parent = holder, Size = UDim2.fromScale(1, 1), AutomaticCanvasSize = Enum.AutomaticSize.Y, ScrollBarThickness = 3 })
    trackAccent(page, "ScrollBarImageColor3")
    -- UIPadding inside a ScrollingFrame shifts children but scale sizes still use the full width,
    -- so the margins live on a plain container instead
    local cols = new("Frame", { Parent = page, Position = UDim2.fromOffset(16, 16), Size = UDim2.new(1, -32, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, { pad(0, 0, 0, 16) })
    local left = new("Frame", { Parent = cols, Size = UDim2.new(0.5, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, { vlist(12) })
    local right = new("Frame", { Parent = cols, Position = UDim2.new(0.5, 6, 0, 0), Size = UDim2.new(0.5, -6, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 }, { vlist(12) })
    page:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        if self._popup then self:_ClosePopup() end
    end)
    tab.Page, tab.Scroll, tab.Button = holder, page, btn
    tab.LeftCol = setmetatable({ Tab = tab, Frame = left }, Column)
    tab.RightCol = setmetatable({ Tab = tab, Frame = right }, Column)

    function tab._setSelected(on)
        tween(lbl, { TextColor3 = on and Theme.Text or Theme.Sub }, 0.25)
        lbl.FontFace = F(on and "SemiBold" or "Medium")
        if iconObj then tintIcon(iconObj, iconText, on and Theme.Accent or Theme.Dim, 0.25) end
    end
    onAccent(function() if iconObj and self.CurrentTab == tab then tintIcon(iconObj, iconText, Theme.Accent, 0) end end)
    btn.MouseEnter:Connect(function() if self.CurrentTab ~= tab then tween(btn, { BackgroundTransparency = 0.965 }, 0.15) tween(lbl, { TextColor3 = Theme.Text }, 0.15) end end)
    btn.MouseLeave:Connect(function() tween(btn, { BackgroundTransparency = 1 }, 0.2) if self.CurrentTab ~= tab then tween(lbl, { TextColor3 = Theme.Sub }, 0.2) end end)
    btn.MouseButton1Click:Connect(function() self:SelectTab(tab) end)

    table.insert(self.Tabs, tab)
    if not self.CurrentTab and not cfg.Hidden then task.defer(function() if not self.CurrentTab then self:SelectTab(tab) end end) end
    return tab
end

function Window:_MovePill(animate)
    local tab = self.CurrentTab
    if not tab then return end
    if tab.Hidden then
        self._pill.Visible = false
        return
    end
    local s = effScale()
    local y = (tab.Button.AbsolutePosition.Y - self.TabList.AbsolutePosition.Y) / s
    local goal = UDim2.fromOffset(10, y)
    if animate and self._pill.Visible then
        tween(self._pill, { Position = goal }, 0.4)
    else
        self._pill.Position = goal
        self._pill.Visible = true
    end
end

function Window:SelectTab(tab)
    if self.CurrentTab == tab then return end
    self:_ClosePopup()
    local old = self.CurrentTab
    if old then
        old._setSelected(false)
        local oh = old.Page
        tween(oh, { GroupTransparency = 1, Position = UDim2.fromOffset(0, -8) }, 0.15)
        task.delay(0.15, function() if self.CurrentTab ~= old then oh.Visible = false end end)
    end
    self.CurrentTab = tab
    tab._setSelected(true)
    self:_MovePill(true)
    if self._onTabChanged then self._onTabChanged(tab) end
    local holder = tab.Page
    holder.Position = UDim2.fromOffset(0, 14)
    holder.GroupTransparency = 1
    holder.Visible = true
    tween(holder, { GroupTransparency = 0, Position = UDim2.fromOffset(0, 0) }, 0.4)
    -- header title swap
    local t, st = self._pageTitle, self._pageSub
    t.Text = tab.Name
    st.Text = self.Title .. "  ›  " .. tab.Name
    t.TextTransparency, st.TextTransparency = 1, 1
    t.Position = UDim2.fromOffset(22, 16)
    tween(t, { TextTransparency = 0, Position = UDim2.fromOffset(22, 10) }, 0.35)
    tween(st, { TextTransparency = 0 }, 0.45)
    task.defer(function() for _, s in ipairs(tab.Sections) do s.Sync() end end)
end

----------------------------------------------------------------------
-- Getters / setters
----------------------------------------------------------------------
local function prop(name, key, ui, coerce)
    Window["Set" .. name] = function(self, v)
        v = coerce(v)
        if v == nil or self[key] == v then return end
        self[key] = v
        local u = self._ui[ui]
        if u then u.Set(ui == "NotifySoundVolume" and v * 100 or v, true) end
    end
    Window["Get" .. name] = function(self) return self[key] end
end
local function toBool(v) return v and true or false end
prop("LoaderSound", "LoaderSound", "LoaderSound", toBool)
prop("NotifySound", "NotifySound", "NotifySound", toBool)
prop("NotifySoundName", "NotifySoundName", "NotifySoundName", function(v) return table.find(Library.SoundNames, v) and v or nil end)
prop("NotifySoundVolume", "NotifySoundVolume", "NotifySoundVolume", function(v) v = tonumber(v) if not v then return nil end if v > 1 then v = v / 100 end return math.clamp(v, 0, 1) end)
prop("ExecuteOnTeleport", "ExecuteOnTeleport", "ExecuteOnTeleport", toBool)
prop("TeleportDelay", "TeleportDelay", "TeleportDelay", function(v) v = tonumber(v) return v and math.clamp(v, 0, 30) or nil end)
prop("TeleportFile", "TeleportFile", "TeleportFile", function(v) return type(v) == "string" and v or nil end)

----------------------------------------------------------------------
-- Settings & Configs tabs
----------------------------------------------------------------------
function Window:AddConfigsTab()
    if self.ConfigsTab then return self.ConfigsTab end
    local tab = self:CreateTab({ Name = "Configs", Icon = "folder-cog" })
    self.ConfigsTab = tab
    local L, R = tab:Column("left"), tab:Column("right")
    local sec = L:CreateSection({ Name = "Configuration", Icon = "save" })
    local more = R:CreateSection({ Name = "More Actions", Icon = "list-checks" })
    local share = R:CreateSection({ Name = "Share", Icon = "share-2", Collapsible = true })
    local selected, newName

    local nameBox = sec:AddTextbox({ Name = "Config Name", Placeholder = "my config", NoConfig = true, Callback = function(t) newName = t end })
    local dropdown
    local autoLbl = more:AddLabel("Auto-Load: None")
    local function refreshAuto()
        local a = Library:GetAutoLoad()
        autoLbl.Set(("Auto-Load: %s"):format(a and ('<font color="#%s"><b>%s</b></font>'):format(Theme.Accent:ToHex(), a) or "None"))
    end
    local function refreshList(keep)
        local list = Library:GetConfigs()
        dropdown.Refresh(list, true)
        if keep and table.find(list, keep) then dropdown.Set(keep, true) selected = keep end
        refreshAuto()
    end
    local function need()
        if not selected then self:Notify({ Title = "Configs", Text = "Select a config first", Type = "warning" }) return false end
        return true
    end
    sec:AddButton({ Name = "Create Config", Icon = "plus", Primary = true, NoFastMenu = true, Callback = function()
        local n = sanitize(newName or nameBox.Get())
        if n == "" then self:Notify({ Title = "Configs", Text = "Enter a config name", Type = "warning" }) return end
        local ok, err = Library:SaveConfig(n)
        if ok then
            self:Notify({ Title = "Configs", Text = "Created '" .. n .. "'", Type = "success" })
            refreshList(n)
        else
            self:Notify({ Title = "Configs", Text = tostring(err), Type = "error" })
        end
    end })
    dropdown = sec:AddDropdown({ Name = "Select Config", Options = Library:GetConfigs(), NoConfig = true, Callback = function(v) selected = v end })
    sec:AddButton({ Name = "Load", Icon = "download", NoFastMenu = true, Callback = function()
        if not need() then return end
        local ok, err = Library:LoadConfig(selected)
        self:Notify({ Title = "Configs", Text = ok and ("Loaded '" .. selected .. "'") or tostring(err), Type = ok and "success" or "error" })
    end })
    sec:AddButton({ Name = "Delete", Icon = "trash-2", NoFastMenu = true, Callback = function()
        if not need() then return end
        local n = selected
        Library:DeleteConfig(n)
        selected = nil
        refreshList()
        self:Notify({ Title = "Configs", Text = "Deleted '" .. n .. "'", Type = "success" })
    end })

    more:AddButton({ Name = "Overwrite", Icon = "save", NoFastMenu = true, Callback = function()
        if not need() then return end
        local ok, err = Library:SaveConfig(selected)
        self:Notify({ Title = "Configs", Text = ok and ("Overwrote '" .. selected .. "'") or tostring(err), Type = ok and "success" or "error" })
    end })
    more:AddButton({ Name = "Set Auto-Load", Icon = "rocket", NoFastMenu = true, Callback = function()
        if not need() then return end
        Library:SetAutoLoad(selected)
        refreshAuto()
        self:Notify({ Title = "Configs", Text = "Auto-load: " .. selected, Type = "success" })
    end })
    more:AddButton({ Name = "Clear Auto-Load", Icon = "circle-off", NoFastMenu = true, Callback = function()
        Library:ClearAutoLoad()
        refreshAuto()
        self:Notify({ Title = "Configs", Text = "Auto-load cleared", Type = "info" })
    end })
    more:AddButton({ Name = "Refresh List", Icon = "refresh-cw", NoFastMenu = true, Callback = function() refreshList(selected) end })

    local importBox = share:AddTextbox({ Name = "Import String", Placeholder = "MLUMINA1:...", NoConfig = true })
    share:AddButton({ Name = "Export to Clipboard", Icon = "copy", NoFastMenu = true, Tooltip = "Copies the current settings as a shareable string", Callback = function()
        local s = Library:ExportConfig()
        local sc = setclipboard or toclipboard
        if sc then
            pcall(sc, s)
            self:Notify({ Title = "Configs", Text = "Config string copied to clipboard", Type = "success" })
        else
            importBox.Set(s, true)
            self:Notify({ Title = "Configs", Text = "No clipboard support - string placed in the box", Type = "warning" })
        end
    end })
    share:AddButton({ Name = "Import from Clipboard", Icon = "clipboard-paste", NoFastMenu = true, Tooltip = "Reads the clipboard (or the Import String box)", Callback = function()
        local str
        local gc = getclipboard or readclipboard
        if gc then local ok, r = pcall(gc) if ok and type(r) == "string" then str = r end end
        if not str or not str:find("MLUMINA1:", 1, true) then str = importBox.Get() end
        local ok, err = Library:ImportConfig(str)
        self:Notify({ Title = "Configs", Text = ok and "Config imported" or tostring(err), Type = ok and "success" or "error" })
    end })

    refreshAuto()
    task.delay(0.6, function()
        if Library.Window == self and not self._autoloaded then
            self._autoloaded = true
            local a = Library:GetAutoLoad()
            if a and Library:LoadConfig(a) then self:Notify({ Title = "Configs", Text = "Auto-loaded '" .. a .. "'", Type = "success" }) end
        end
    end)
    return tab
end

function Window:AddSettingsTab()
    if self.SettingsTab then return self.SettingsTab, self.ConfigsTab end
    local win = self
    self:AddTabLabel("System")
    local tab = self:CreateTab({ Name = "Settings", Icon = "settings" })
    self.SettingsTab = tab
    local L, R = tab:Column("left"), tab:Column("right")
    local ui = self._ui

    -- Interface
    local iface = L:CreateSection({ Name = "Interface", Icon = "palette" })
    iface:AddDropdown({ Name = "UI Scale", Options = { "50%", "75%", "100%", "125%", "150%" }, Default = "100%", Callback = function(v)
        win:_SetUIScale((tonumber((tostring(v):gsub("%%", ""))) or 100) / 100)
    end })
    ui.MenuBind = iface:AddKeybind({ Name = "Menu Toggle", Default = self.ToggleKey, NoBind = true, ChangedCallback = function(k)
        if k then win.ToggleKey = k end
    end })
    local accNames = {}
    for _, a in ipairs(Library.Accents) do table.insert(accNames, a[1]) end
    local rainbow = false
    local customPicker
    iface:AddDropdown({ Name = "Accent Color", Options = accNames, Default = "Purple", Callback = function(v)
        for _, a in ipairs(Library.Accents) do
            if a[1] == v then
                Library:SetAccent(a[2])
                if customPicker then customPicker.Set(a[2], true) end
            end
        end
    end })
    customPicker = iface:AddColorPicker({ Name = "Custom Accent", Default = Theme.Accent, Callback = function(c) if not rainbow then Library:SetAccent(c) end end })
    iface:AddToggle({ Name = "Rainbow Accent", NoFastMenu = true, Tooltip = "Cycles the accent color through the rainbow", Callback = function(v) rainbow = v end })
    do
        local t = 0
        local acc = 0
        connect(RunService.Heartbeat, function(dt)
            if rainbow then
                t += dt
                acc += dt
                if acc >= 1 / 30 then
                    acc = 0
                    Library:SetAccent(Color3.fromHSV((t * 0.1) % 1, 0.6, 1))
                end
            end
        end)
    end
    iface:AddToggle({ Name = "Background Blur", NoFastMenu = true, Default = self.BlurEnabled, Callback = function(v) win:SetBlur(v) end })
    iface:AddToggle({ Name = "Show Watermark", NoFastMenu = true, Callback = function(v) win.Watermark.Visible = v end })
    iface:AddDropdown({ Name = "Open Control", Options = { "Bar", "Button", "Off" }, Default = win.OpenControl, Tooltip = "How to open the menu without a keyboard", Callback = function(v)
        if v == win.OpenControl then return end
        win:SetOpenControl(v)
        win:ShowOpenGuide(2)
    end })
    iface:AddButton({ Name = "Reset Window Size", Icon = "maximize-2", NoFastMenu = true, Callback = function() win:SetSize(DEF_W, DEF_H, true) end })

    -- Atmosphere: background particles and the character art
    local atm = L:CreateSection({ Name = "Atmosphere", Icon = "sparkles", Collapsible = true })
    atm:AddDropdown({ Name = "Background Effect", Options = Library.EffectNames, Default = win.Effects.Name, Callback = function(v) win:SetEffect(v) end })
    atm:AddSlider({ Name = "Effect Density", Min = 20, Max = 300, Default = 100, Suffix = "%", Callback = function(v) win:SetEffectDensity(v / 100) end })
    atm:AddToggle({ Name = "Full Screen Effect", NoFastMenu = true, Tooltip = "Particles fill the screen behind the menu, not only the window", Callback = function(v) win:SetEffectFullscreen(v) end })
    if #win.Art.List > 0 then
        atm:AddDropdown({ Name = "Character Art", Options = win.Art.Names(), Default = win.Art.Name, Callback = function(v) win:SetArt(v) end })
        atm:AddDropdown({ Name = "Art Side", Options = { "Right", "Left" }, Default = win.Art.Side, Callback = function(v) win:SetArtSide(v) end })
        atm:AddToggle({ Name = "Art In Front", NoFastMenu = true, Tooltip = "Draw the art over the window edge instead of behind it", Callback = function(v) win:SetArtFront(v) end })
        atm:AddSlider({ Name = "Art Size", Min = 50, Max = 160, Default = win.Art.Size * 100, Suffix = "%", Callback = function(v) win:SetArtSize(v / 100) end })
        atm:AddSlider({ Name = "Art Opacity", Min = 10, Max = 100, Default = win.Art.Opacity * 100, Suffix = "%", Callback = function(v) win:SetArtOpacity(v / 100) end })
    end

    -- Fast Menu
    local fm = self.FastMenu
    local fsec = L:CreateSection({ Name = "Fast Menu", Icon = "zap", Collapsible = true })
    fsec:AddToggle({ Name = "Enable Fast Menu", NoFastMenu = true, Callback = function(v) fm:SetVisible(v) end })
    local selFunc = fsec:AddMultiDropdown({ Name = "Select Functions", Options = Library._FastToggleOrder, NoConfig = true, Placeholder = "None", Callback = function(v) fm.SelToggles = v fm:Refresh() end })
    local selBtn = fsec:AddMultiDropdown({ Name = "Select Buttons", Options = Library._FastButtonOrder, NoConfig = true, Placeholder = "None", Callback = function(v) fm.SelButtons = v fm:Refresh() end })
    local function syncSel()
        selFunc.Refresh(Library._FastToggleOrder, true)
        selFunc.Set(fm.SelToggles, true)
        selBtn.Refresh(Library._FastButtonOrder, true)
        selBtn.Set(fm.SelButtons, true)
    end
    fm.OnSel = syncSel
    table.insert(Library._FastChanged, syncSel)
    syncSel()
    fsec:AddSlider({ Name = "Menu Scale", Min = 50, Max = 150, Default = 100, Suffix = "%", Callback = function(v) fm:SetScale(v / 100) end })
    fsec:AddToggle({ Name = "Lock Position", NoFastMenu = true, Flag = "Fast Menu Lock", Callback = function(v) fm:SetLocked(v) end })
    fsec:AddButton({ Name = "Reset Position", NoFastMenu = true, Flag = "Fast Menu Reset", Callback = function() fm:SetPosition(UDim2.new(0, 20, 0.3, 0)) end })

    -- Keybind List
    local kl = self.KeybindList
    local ksec = L:CreateSection({ Name = "Keybind List", Icon = "keyboard", Collapsible = true })
    ksec:AddToggle({ Name = "Enable Keybind List", NoFastMenu = true, Callback = function(v) kl:SetVisible(v) end })
    ksec:AddSlider({ Name = "HUD Scale", Min = 50, Max = 150, Default = 100, Suffix = "%", Callback = function(v) kl:SetScale(v / 100) end })
    ksec:AddToggle({ Name = "Lock Position", NoFastMenu = true, Flag = "Keybind List Lock", Callback = function(v) kl:SetLocked(v) end })
    ksec:AddButton({ Name = "Reset Position", NoFastMenu = true, Flag = "Keybind List Reset", Callback = function() kl:SetPosition(UDim2.new(1, -230, 0.3, 0)) end })

    -- Teleport
    local tsec = R:CreateSection({ Name = "Teleport", Icon = "plane" })
    ui.ExecuteOnTeleport = tsec:AddToggle({ Name = "Execute on Teleport", Default = self.ExecuteOnTeleport, NoFastMenu = true, Tooltip = "Re-runs the script after a server change", Callback = function(v) win:SetExecuteOnTeleport(v) end })
    ui.TeleportDelay = tsec:AddSlider({ Name = "Execution Delay", Min = 0, Max = 30, Default = self.TeleportDelay, Suffix = "s", Decimals = 1, Callback = function(v) win:SetTeleportDelay(v) end })
    ui.TeleportFile = tsec:AddTextbox({ Name = "Teleport File", Default = self.TeleportFile, Callback = function(v) if v ~= "" then win:SetTeleportFile(v) end end })

    -- Actions
    local asec = R:CreateSection({ Name = "Actions", Icon = "activity" })
    asec:AddToggle({ Name = "Anti-AFK", Icon = "coffee", Default = true, NoFastMenu = true, Tooltip = "Prevents the 20-minute idle kick", Callback = function(v) Library:SetAntiAFK(v) end })
    asec:AddToggle({ Name = "Anti-Lag", Icon = "gauge", NoFastMenu = true, Tooltip = "Low graphics, no shadows/particles/decals, also for newly spawned objects. Turning off keeps what was already simplified until rejoin", Callback = function(v) Library:SetAntiLag(v) end })
    asec:AddButton({ Name = "Server Hop", Icon = "shuffle", Primary = true, NoFastMenu = true, Callback = function()
        win:Notify({ Title = "Server Hop", Text = "Searching for a server...", Type = "info" })
        task.spawn(function() Library:ServerHop() end)
    end })
    asec:AddButton({ Name = "Rejoin Server", Icon = "rotate-ccw", NoFastMenu = true, Callback = function()
        win:Notify({ Title = "Rejoin", Text = "Rejoining...", Type = "info" })
        task.spawn(function() Library:Rejoin() end)
    end })
    asec:AddButton({ Name = "Unload Menu", Icon = "power", NoFastMenu = true, Callback = function() Library:Unload() end })

    -- Notifications
    local nsec = R:CreateSection({ Name = "Notifications", Icon = "bell" })
    ui.NotifySound = nsec:AddToggle({ Name = "Notification Sound", Default = self.NotifySound, NoFastMenu = true, Callback = function(v) win:SetNotifySound(v) end })
    ui.LoaderSound = nsec:AddToggle({ Name = "Startup Sound (Loader)", Default = self.LoaderSound, NoFastMenu = true, Callback = function(v) win:SetLoaderSound(v) end })
    ui.NotifySoundName = nsec:AddDropdown({ Name = "Sound Type", Options = Library.SoundNames, Default = self.NotifySoundName, Callback = function(v)
        if v then
            win:SetNotifySoundName(v)
            Library:PlaySound(v, win.NotifySoundVolume)
        end
    end })
    ui.NotifySoundVolume = nsec:AddSlider({ Name = "Sound Volume", Min = 0, Max = 100, Default = self.NotifySoundVolume * 100, Suffix = "%", Callback = function(v) win:SetNotifySoundVolume(v) end })
    nsec:AddButton({ Name = "Test Notification", Icon = "bell-ring", NoFastMenu = true, Callback = function()
        win:Notify({ Title = "Test", Text = "Sound: " .. win.NotifySoundName, Type = "success" })
    end })
    nsec:AddButton({ Name = "Test Warning & Error", Icon = "triangle-alert", NoFastMenu = true, Callback = function()
        win:Notify({ Title = "Warning", Text = "This is a test warning", Type = "warning" })
        task.delay(0.7, function() win:Notify({ Title = "Error", Text = "This is a test error", Type = "error" }) end)
    end })

    local cfgTab = self:AddConfigsTab()
    return tab, cfgTab
end

----------------------------------------------------------------------
-- Unload
----------------------------------------------------------------------
function Library:Unload()
    for _, fn in ipairs(self._OnUnload) do pcall(fn) end
    for _, c in ipairs(self._Conns) do pcall(function() c:Disconnect() end) end
    pcall(function() RunService:UnbindFromRenderStep("MoroLumina_Cursor") end)
    local w = self.Window
    if w then
        if w.Blur then pcall(function() w.Blur:Destroy() end) end
        if w.Gui then pcall(function() w.Gui:Destroy() end) end
    end
    initState()
    if genv.MoroLumina == self then genv.MoroLumina = nil end
end

genv.MoroLumina = Library
return Library
