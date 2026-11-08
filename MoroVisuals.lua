--[[
    MoroVisuals — общая визуальная библиотека Moro (ESP / Chams / X-Ray / Post FX)

    local V = loadstring(game:HttpGet(".../MoroVisuals.lua"))()
    V.ESP      — движок ESP (боксы, хамсы, скелет, трейсеры, стрелки), API: AddESP / RemoveESP / Set* / TrackPlayers
    V.PostFX   — цветокор / bloom / rays / DoF / blur / атмосфера + 11 пресетов
    V.XRay     — полупрозрачные стены (LocalTransparencyModifier)
    V.Unload() — убрать всё
--]]

local env = (getgenv and getgenv()) or _G
if env.__MoroVisuals and env.__MoroVisuals.Unload then pcall(env.__MoroVisuals.Unload) end

local players = game:GetService("Players")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local lighting = game:GetService("Lighting")
local coreGui = game:GetService("CoreGui")
local localPlayer = players.LocalPlayer

local M = {}

-- ===================================================================== ESP
local function createESPEngine()
    local Lib = {
        MaxDistance = 250,
        ShowESPText = true,
        Tracers = false,
        TracersEnabled = {},
        ObjectMaxDistance = {},
        ColorTable = {},
    }

    -- настройки отображения (меню пишет сюда через Lib.Settings или Set*)
    local S = {
        box = "Rounded Glow", boxThick = 1.6, boxFill = 0.88,
        chams = "Flat", chamLimit = 31,
        nameStyle = "Pill", textSize = 15, font = Enum.Font.GothamBold, showDist = true,
        hpBar = true, hpText = true, skeleton = true, headDot = true, lookLine = true,
        rainbow = false, distFade = true,
        fillT = 0.6, outlineT = 0, textT = 0, textOutlineT = 0.4,
        matchColors = true, outlineColor = Color3.new(1, 1, 1),
        fadeTime = 0,
        tracerFrom = "Bottom", tracerThick = 0.75,
        arrows = false, arrowRadius = 250,
        -- Dual-хамсы (MM2): яркий слой там, где видно, тёмный сквозь стены
        chamsMode = "Highlight",   -- "Highlight" | "Dual"
        chamMode = "Object",       -- "Object" (цвет объекта) | "Custom" (chamVisible / chamHidden)
        chamVisible = Color3.fromRGB(255, 70, 90), chamHidden = Color3.fromRGB(110, 60, 255), chamAlpha = 0.6,
        visCheck = false,          -- затемнять объекты за стенами
        skelThick = 1.4,
    }
    Lib.Settings = S
    Lib.Enabled = true

    local entries = {}
    local alive = true
    local cam = workspace.CurrentCamera
    local WHITE, BLACK = Color3.new(1, 1, 1), Color3.new(0, 0, 0)

    -- ---------------------------------------------------------------- GUI
    local parent = (gethui and gethui()) or coreGui
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local gui = Instance.new("ScreenGui")
    gui.Name = "MoroESP"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.DisplayOrder = 20
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    pcall(function() if syn and syn.protect_gui then syn.protect_gui(gui) end end)
    gui.Parent = parent

    local layer = Instance.new("Frame")
    layer.Name = "Layer"
    layer.BackgroundTransparency = 1
    layer.Size = UDim2.fromScale(1, 1)
    layer.Parent = gui

    local chamFolder = Instance.new("Folder")
    chamFolder.Name = "MoroESPChams"
    chamFolder.Parent = parent

    -- --------------------------------------------------------- UI helpers
    local function newFrame(par, props)
        local f = Instance.new("Frame")
        f.BorderSizePixel = 0
        f.BackgroundColor3 = WHITE
        f.Visible = false
        for k, v in pairs(props or {}) do f[k] = v end
        f.Parent = par
        return f
    end
    local function newLine(par) return newFrame(par, { AnchorPoint = Vector2.new(0.5, 0.5) }) end
    local function setLine(f, a, b, thick, col, transp)
        local d = b - a
        f.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
        f.Size = UDim2.fromOffset(d.Magnitude, thick)
        f.Rotation = math.deg(math.atan2(d.Y, d.X))
        f.BackgroundColor3 = col
        f.BackgroundTransparency = transp
        f.Visible = true
    end
    local function addStroke(f, thick, col, transp)
        local s = Instance.new("UIStroke")
        s.Thickness, s.Color, s.Transparency = thick, col, transp or 0
        s.Parent = f
        return s
    end
    local function addCorner(f, r)
        local c = Instance.new("UICorner")
        c.CornerRadius = r
        c.Parent = f
        return c
    end
    local function newText(par, size)
        local t = Instance.new("TextLabel")
        t.BackgroundTransparency = 1
        t.Font = S.font
        t.TextSize = size or 13
        t.RichText = true
        t.TextColor3 = WHITE
        t.Visible = false
        t.Parent = par
        t.TextStrokeTransparency = 1
        local st = addStroke(t, 1, BLACK, 0.4)
        return t, st
    end
    local function esc(s)
        return (tostring(s):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
    end
    local function hex(c)
        return string.format("#%02x%02x%02x", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
    end
    local function rainbowAt(t, off) return Color3.fromHSV((t * 0.3 + off) % 1, 0.8, 1) end

    local CUBE_EDGES = { { 1, 2 }, { 2, 4 }, { 4, 3 }, { 3, 1 }, { 5, 6 }, { 6, 8 }, { 8, 7 }, { 7, 5 }, { 1, 5 }, { 2, 6 }, { 3, 7 }, { 4, 8 } }
    local BONES_R15 = {
        { "Head", "UpperTorso" }, { "UpperTorso", "LowerTorso" },
        { "UpperTorso", "LeftUpperArm" }, { "LeftUpperArm", "LeftLowerArm" }, { "LeftLowerArm", "LeftHand" },
        { "UpperTorso", "RightUpperArm" }, { "RightUpperArm", "RightLowerArm" }, { "RightLowerArm", "RightHand" },
        { "LowerTorso", "LeftUpperLeg" }, { "LeftUpperLeg", "LeftLowerLeg" }, { "LeftLowerLeg", "LeftFoot" },
        { "LowerTorso", "RightUpperLeg" }, { "RightUpperLeg", "RightLowerLeg" }, { "RightLowerLeg", "RightFoot" },
    }
    local BONES_R6 = { { "Head", "Torso" }, { "Torso", "Left Arm" }, { "Torso", "Right Arm" }, { "Torso", "Left Leg" }, { "Torso", "Right Leg" } }

    -- ------------------------------------------------------------ entries
    local function buildUI(e)
        local u = {}
        u.root = newFrame(layer, { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Visible = true })
        u.glow = newFrame(u.root, { BackgroundTransparency = 1 })
        addCorner(u.glow, UDim.new(0, 12))
        u.glowStroke = addStroke(u.glow, 5, WHITE, 0.8)
        u.boxFull = newFrame(u.root, {})
        u.boxCorner = addCorner(u.boxFull, UDim.new(0, 0))
        u.boxStroke = addStroke(u.boxFull, 1.5, WHITE, 0)
        u.fillGrad = Instance.new("UIGradient")
        u.fillGrad.Rotation = 90
        u.fillGrad.Parent = u.boxFull
        u.corners = {}
        for i = 1, 8 do u.corners[i] = newFrame(u.root, {}) end
        u.cube, u.bones = {}, {}
        u.hpBg = newFrame(u.root, { BackgroundColor3 = BLACK, BackgroundTransparency = 0.45 })
        u.hpFill = newFrame(u.hpBg, { AnchorPoint = Vector2.new(0, 1), Position = UDim2.fromScale(0, 1), Visible = true })
        u.pill = newFrame(u.root, { BackgroundColor3 = Color3.fromRGB(14, 14, 20), BackgroundTransparency = 0.15 })
        addCorner(u.pill, UDim.new(0, 7))
        u.pillStroke = addStroke(u.pill, 1, WHITE, 0.35)
        u.accent = newFrame(u.pill, { Position = UDim2.new(0, 4, 0, 4), Size = UDim2.new(0, 3, 1, -8), Visible = true })
        addCorner(u.accent, UDim.new(1, 0))
        u.nameT, u.nameS = newText(u.pill, 13)
        u.nameT.Visible = true
        u.nameT.TextXAlignment = Enum.TextXAlignment.Left
        u.nameT.Position = UDim2.fromOffset(13, 0)
        u.nameT.Size = UDim2.new(1, -16, 1, 0)
        u.plainT, u.plainS = newText(u.root, 13)
        u.plainT.AnchorPoint = Vector2.new(0.5, 1)
        u.plainT.Size = UDim2.fromOffset(260, 18)
        u.infoT, u.infoS = newText(u.root, 12)
        u.infoT.AnchorPoint = Vector2.new(0.5, 0)
        u.infoT.Size = UDim2.fromOffset(260, 16)
        u.tracer = newLine(u.root)
        u.lookLine = newLine(u.root)
        u.dot = newFrame(u.root, { AnchorPoint = Vector2.new(0.5, 0.5) })
        addCorner(u.dot, UDim.new(1, 0))
        addStroke(u.dot, 1, BLACK, 0.2)
        u.arrow = newText(layer, 20)
        u.arrow.Text = "▲"
        u.arrow.AnchorPoint = Vector2.new(0.5, 0.5)
        u.arrow.Size = UDim2.fromOffset(26, 26)
        e.ui = u
    end

    local function destroyUI(e)
        local u = e.ui
        if u then
            pcall(function() u.root:Destroy() end)
            pcall(function() u.arrow:Destroy() end)
            e.ui = nil
        end
        if e.hl then
            pcall(function() e.hl:Destroy() end)
            e.hl = nil
        end
        if e.dual then
            for _, l in ipairs(e.dual.layers) do pcall(function() l.a:Destroy() end) end
            e.dual = nil
        end
    end

    local function hideAll(e)
        local u = e.ui
        if u then
            u.root.Visible = false
            u.arrow.Visible = false
        end
        if e.hl then e.hl.Enabled = false end
        if e.dual then
            for _, l in ipairs(e.dual.layers) do l.a.Visible = false end
        end
    end

    local function newEntry(obj)
        local e = {
            obj = obj, text = "", color = WHITE, alpha = 0, target = 1,
            hue = math.random(), nextBB = 0, wantHL = true,
            isPart = obj:IsA("BasePart"), isModel = obj:IsA("Model"),
        }
        -- HP, скелет, точка на голове и линия взгляда рисуются только у игроков
        if e.isModel and players:GetPlayerFromCharacter(obj) then
            e.isPlayer = true
            e.hum = obj:FindFirstChildOfClass("Humanoid")
        end
        return e
    end

    -- Бокс игрока: по голове и ногам, а не по GetBoundingBox (иначе нож в руке раздувает рамку)
    local function refreshPlayerBox(e)
        local o = e.obj
        local hrp, head = o:FindFirstChild("HumanoidRootPart"), o:FindFirstChild("Head")
        if not (hrp and head and hrp:IsA("BasePart") and head:IsA("BasePart")) then return false end
        if not e.hum or not e.hum.Parent then e.hum = o:FindFirstChildOfClass("Humanoid") end
        local hip = e.hum and e.hum.HipHeight or 0
        local foot = (hip > 0 and hip or 2) + hrp.Size.Y / 2
        local top = head.Position.Y + head.Size.Y / 2 + 0.2
        local bot = hrp.Position.Y - foot
        e.size = Vector3.new(3, math.max(top - bot, 1), 2)
        e.off = CFrame.new(0, (top + bot) / 2 - hrp.Position.Y, 0)
        e.root, e.head = hrp, head
        return true
    end

    -- Предметы, монеты и ключи в Doors содержат невидимые хитбоксы (для промпта): рамка и подсветка по ним
    -- получались огромными и не по размеру предмета. Считаем габариты только по видимым деталям.
    local function isHiddenPart(p)
        return p.Transparency >= 0.9 or string.find(string.lower(p.Name), "hitbox", 1, true) ~= nil
    end

    local function fitVisibleParts(e, model)
        local descendants = model:GetDescendants()
        if #descendants > 150 then return false end
        local visible, hiddenCount = {}, 0
        for _, d in ipairs(descendants) do
            if d:IsA("BasePart") then
                if isHiddenPart(d) then hiddenCount = hiddenCount + 1 else visible[#visible + 1] = d end
            end
        end
        if hiddenCount == 0 or #visible == 0 then return false end

        local pivot = model:GetPivot()
        local lo, hi = Vector3.new(math.huge, math.huge, math.huge), Vector3.new(-math.huge, -math.huge, -math.huge)
        local biggest, biggestVolume = visible[1], -1
        for _, p in ipairs(visible) do
            local h = p.Size / 2
            for sx = -1, 1, 2 do
                for sy = -1, 1, 2 do
                    for sz = -1, 1, 2 do
                        local q = pivot:PointToObjectSpace(p.CFrame:PointToWorldSpace(Vector3.new(h.X * sx, h.Y * sy, h.Z * sz)))
                        lo = Vector3.new(math.min(lo.X, q.X), math.min(lo.Y, q.Y), math.min(lo.Z, q.Z))
                        hi = Vector3.new(math.max(hi.X, q.X), math.max(hi.Y, q.Y), math.max(hi.Z, q.Z))
                    end
                end
            end
            local volume = p.Size.X * p.Size.Y * p.Size.Z
            if volume > biggestVolume then biggest, biggestVolume = p, volume end
        end
        local size = hi - lo
        e.size = Vector3.new(math.max(size.X, 0.5), math.max(size.Y, 0.5), math.max(size.Z, 0.5))
        e.off = CFrame.new((lo + hi) / 2)

        -- Подсветка: общий предок видимых деталей, если под ним нет хитбоксов; иначе самая крупная видимая деталь
        local ancestor = visible[1]
        for i = 2, #visible do
            while ancestor and not visible[i]:IsDescendantOf(ancestor) do ancestor = ancestor.Parent end
        end
        local clean = ancestor and ancestor ~= model
        if clean then
            for _, d in ipairs(ancestor:GetDescendants()) do
                if d:IsA("BasePart") and isHiddenPart(d) then clean = false break end
            end
        end
        e.adornee = clean and ancestor or biggest
        return true
    end

    local function refreshBox(e)
        local o = e.obj
        if e.isPart then
            e.size = o.Size
            return true
        elseif e.isModel then
            if e.isPlayer and refreshPlayerBox(e) then return true end
            if not e.isPlayer and fitVisibleParts(e, o) then return true end
            e.adornee = nil
            local success, result, result3 = pcall(o.GetBoundingBox, o)
            if success and result3 then
                e.size = Vector3.new(math.max(result3.X, 0.5), math.max(result3.Y, 0.5), math.max(result3.Z, 0.5))
                e.off = o:GetPivot():ToObjectSpace(result)
                return true
            end
        end
        return false
    end

    local function worldCF(e)
        if e.isPart then return e.obj.CFrame end
        if e.root and e.root.Parent then return e.root.CFrame * e.off end
        return e.obj:GetPivot() * e.off
    end

    -- Dual-хамсы: две оболочки на каждую часть тела (яркая «видно» + тёмная «сквозь стены»)
    local CHAM_PARTS = {
        "Head", "UpperTorso", "LowerTorso", "LeftUpperArm", "LeftLowerArm", "LeftHand", "RightUpperArm", "RightLowerArm", "RightHand",
        "LeftUpperLeg", "LeftLowerLeg", "LeftFoot", "RightUpperLeg", "RightLowerLeg", "RightFoot",
        "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg",
    }
    local function clearDual(e)
        if not e.dual then return end
        for _, l in ipairs(e.dual.layers) do pcall(function() l.a:Destroy() end) end
        e.dual = nil
    end
    local function buildDual(e, glow)
        local d = { glow = glow, layers = {} }
        local kinds = glow and { "hidden", "visible", "glow" } or { "hidden", "visible" }
        for _, n in ipairs(CHAM_PARTS) do
            local part = e.obj:FindFirstChild(n)
            if part and part:IsA("BasePart") then
                for _, kind in ipairs(kinds) do
                    local a
                    local grow = kind == "glow" and 0.2 or 0.05
                    if n == "Head" then
                        a = Instance.new("SphereHandleAdornment")
                        a.Radius = math.max(part.Size.X, part.Size.Y, part.Size.Z) / 2 + grow / 2
                    else
                        a = Instance.new("BoxHandleAdornment")
                        a.Size = part.Size + Vector3.new(grow, grow, grow)
                    end
                    a.Adornee = part
                    a.AlwaysOnTop = kind ~= "visible"
                    a.ZIndex = kind == "glow" and 1 or (kind == "hidden" and 2 or 3)
                    a.Parent = chamFolder
                    d.layers[#d.layers + 1] = { a = a, kind = kind }
                end
            end
        end
        e.dual = d
    end
    local function applyDual(e, col, t)
        local style = S.chams
        local glow = style == "Glow"
        if e.dual and (e.dual.glow ~= glow or e.dual.char ~= e.obj) then clearDual(e) end
        if not e.dual then buildDual(e, glow) e.dual.char = e.obj end
        local visC, hidC
        if S.chamMode == "Custom" then
            visC, hidC = S.chamVisible, S.chamHidden
        else
            visC, hidC = col, col:Lerp(BLACK, 0.4)
        end
        if style == "Rainbow" then visC, hidC = rainbowAt(t, e.hue), rainbowAt(t, e.hue + 0.5) end
        local alpha = S.chamAlpha
        if style == "Pulse" then alpha = math.clamp(alpha + math.sin(t * 3 + e.hue * 6) * 0.2, 0, 0.95) end
        local visibleOnly = style == "Visible Only"
        for _, l in ipairs(e.dual.layers) do
            local a = l.a
            if a.Parent then
                a.Visible = not (visibleOnly and l.kind == "hidden")
                if l.kind == "hidden" then
                    a.Color3, a.Transparency = hidC, math.clamp(alpha + 0.2, 0, 1)
                elseif l.kind == "visible" then
                    a.Color3, a.Transparency = visC, alpha
                else
                    a.Color3, a.Transparency = visC, math.clamp(alpha + 0.42, 0, 1)
                end
            end
        end
    end

    -- Highlight (хамсы) ---------------------------------------------------
    local function applyChams(e, col, t, tr)
        local style = S.chams
        local dualOk = S.chamsMode == "Dual" and e.isPlayer   -- у адорнментов нет лимита в 31
        local want = style ~= "Off" and (e.wantHL or dualOk) and not e.noChams
        if not want then
            if e.hl then e.hl:Destroy() e.hl = nil end
            clearDual(e)
            return
        end
        if dualOk then
            if e.hl then e.hl:Destroy() e.hl = nil end
            applyDual(e, col, t)
            return
        end
        clearDual(e)
        if not e.hl then
            local hl = Instance.new("Highlight")
            hl.Adornee = e.obj
            hl.Parent = chamFolder
            e.hl = hl
        end
        local hl = e.hl
        local adornee = e.adornee or e.obj
        if hl.Adornee ~= adornee then hl.Adornee = adornee end
        hl.Enabled = true
        hl.DepthMode = style == "Visible Only" and Enum.HighlightDepthMode.Occluded or Enum.HighlightDepthMode.AlwaysOnTop
        local fill, out = col, (S.matchColors and col or S.outlineColor)
        local fillT = S.fillT
        if style == "Glow" then
            fillT = math.clamp(S.fillT - 0.3, 0.1, 1)
            out = col:Lerp(WHITE, 0.5)
        elseif style == "Pulse" then
            fillT = math.clamp(S.fillT + math.sin(t * 3 + e.hue * 6) * 0.2, 0, 1)
        elseif style == "Rainbow" then
            fill = rainbowAt(t, e.hue)
            out = S.matchColors and fill or S.outlineColor
        elseif style == "Outline" then
            fillT = 1
        end
        hl.FillColor, hl.OutlineColor = fill, out
        hl.FillTransparency = tr(fillT)
        hl.OutlineTransparency = tr(S.outlineT)
    end

    -- рендер одного объекта -------------------------------------------------
    local function renderEntry(e, t, dt, camPos, vs, center)
        local o = e.obj
        if not o.Parent then e.dead = true return end
        if not e.size or t >= e.nextBB then
            if not refreshBox(e) then hideAll(e) return end
            e.nextBB = t + 0.25 + (e.hue * 0.1)
        end
        local cf = worldCF(e)
        local dist = (cf.Position - camPos).Magnitude
        local maxD = Lib.ObjectMaxDistance[o] or Lib.MaxDistance
        e.dist = dist

        -- fade in / out
        if S.fadeTime > 0 then
            local step = dt / S.fadeTime
            if e.alpha < e.target then e.alpha = math.min(e.alpha + step, e.target)
            elseif e.alpha > e.target then e.alpha = math.max(e.alpha - step, e.target) end
        else
            e.alpha = e.target
        end
        if e.target == 0 and e.alpha <= 0 then e.dead = true return end

        e.hidden = dist > maxD
            or (e.isPlayer and e.hum ~= nil and e.hum.Health <= 0)
            or (e.filter ~= nil and not e.filter())
        if e.hidden then e.wantHL = false hideAll(e) return end
        if not e.ui then buildUI(e) end
        local u = e.ui

        local col = e.color
        if e.colorFn then
            local ok, c = pcall(e.colorFn, t, o)
            if ok and c then col = c end
        end
        if S.rainbow then col = rainbowAt(t, e.hue) end
        if S.visCheck then
            if t - (e.visT or 0) > 0.12 then
                e.visT = t
                local target = e.head or e.root or (e.isPart and o) or (e.isModel and o.PrimaryPart)
                if target then
                    local origin = cam.CFrame.Position
                    rayParams.FilterDescendantsInstances = { localPlayer.Character, o }
                    e.vis = workspace:Raycast(origin, target.Position - origin, rayParams) == nil
                else
                    e.vis = true
                end
            end
            if e.vis == false then col = col:Lerp(BLACK, 0.45) end
        end
        local df = S.distFade and math.clamp(dist / maxD, 0, 1) * 0.55 or 0
        local function tr(base) return 1 - (1 - base) * e.alpha * (1 - df) end

        applyChams(e, col, t, tr)

        -- проекция 8 углов
        local half = e.size / 2
        local pts, allIn, minX, minY, maxX, maxY, any = {}, true, math.huge, math.huge, -math.huge, -math.huge, false
        local i = 0
        for sx = -1, 1, 2 do
            for sy = -1, 1, 2 do
                for sz = -1, 1, 2 do
                    i = i + 1
                    local sp = cam:WorldToViewportPoint(cf * Vector3.new(half.X * sx, half.Y * sy, half.Z * sz))
                    pts[i] = Vector2.new(sp.X, sp.Y)
                    if sp.Z > 0 then
                        any = true
                        minX, maxX = math.min(minX, sp.X), math.max(maxX, sp.X)
                        minY, maxY = math.min(minY, sp.Y), math.max(maxY, sp.Y)
                    else
                        allIn = false
                    end
                end
            end
        end
        local cp = cam:WorldToViewportPoint(cf.Position)
        local onScreen = any and cp.Z > 0 and maxX > -50 and minX < vs.X + 50 and maxY > -50 and minY < vs.Y + 50

        if not onScreen then
            u.root.Visible = false
            if S.arrows and e.alpha > 0 and not e.noArrow then
                local dir = Vector2.new(cp.X, cp.Y) - center
                if cp.Z < 0 then dir = -dir end
                if dir.Magnitude < 1 then dir = Vector2.new(0, 1) end
                local d = dir.Unit
                local rad = math.min(S.arrowRadius, math.min(vs.X, vs.Y) / 2 - 20)
                u.arrow.Position = UDim2.fromOffset(center.X + d.X * rad, center.Y + d.Y * rad)
                u.arrow.Rotation = math.deg(math.atan2(d.Y, d.X)) + 90
                u.arrow.TextColor3 = col
                u.arrow.TextTransparency = tr(S.textT)
                u.arrow.TextSize = 16 + (1 - math.clamp(dist / maxD, 0, 1)) * 10
                u.arrow.Visible = true
            else
                u.arrow.Visible = false
            end
            return
        end
        u.arrow.Visible = false
        u.root.Visible = true

        -- у игрока рамка узкая и не зависит от поворота: ширина = половина высоты
        if e.isPlayer and e.root then
            local half = e.size.Y / 2
            local mid = cf.Position
            local tp = cam:WorldToViewportPoint(mid + Vector3.new(0, half, 0))
            local bp = cam:WorldToViewportPoint(mid - Vector3.new(0, half, 0))
            if tp.Z > 0 and bp.Z > 0 then
                local hh = math.abs(bp.Y - tp.Y)
                local cx = (tp.X + bp.X) / 2
                minX, maxX = cx - hh * 0.25, cx + hh * 0.25
                minY, maxY = math.min(tp.Y, bp.Y), math.max(tp.Y, bp.Y)
            end
        end

        local x, y = minX, minY
        local w, h = math.max(maxX - minX, 4), math.max(maxY - minY, 4)
        local th = S.boxThick

        -- бокс
        u.boxFull.Visible, u.glow.Visible = false, false
        for _, f in ipairs(u.corners) do f.Visible = false end
        for _, f in ipairs(u.cube) do f.Visible = false end
        local style = S.box
        if style == "Full" or style == "Rounded Glow" then
            u.boxFull.Visible = true
            u.boxFull.Position, u.boxFull.Size = UDim2.fromOffset(x, y), UDim2.fromOffset(w, h)
            u.boxFull.BackgroundTransparency = tr(S.boxFill)
            u.fillGrad.Color = ColorSequence.new(col, col:Lerp(BLACK, 0.6))
            u.boxStroke.Thickness, u.boxStroke.Color, u.boxStroke.Transparency = th, col, tr(0)
            u.boxCorner.CornerRadius = UDim.new(0, style == "Rounded Glow" and 10 or 0)
            if style == "Rounded Glow" then
                u.glow.Visible = true
                u.glow.Position, u.glow.Size = UDim2.fromOffset(x - 2, y - 2), UDim2.fromOffset(w + 4, h + 4)
                u.glowStroke.Color, u.glowStroke.Transparency = col, tr(0.72)
            end
        elseif style == "Corners" then
            local L = math.max(math.min(w, h) * 0.28, 6)
            local defs = {
                { x, y, L, th }, { x, y, th, L }, { x + w - L, y, L, th }, { x + w - th, y, th, L },
                { x, y + h - th, L, th }, { x, y + h - L, th, L }, { x + w - L, y + h - th, L, th }, { x + w - th, y + h - L, th, L },
            }
            for k, d in ipairs(defs) do
                local f = u.corners[k]
                f.Position, f.Size = UDim2.fromOffset(d[1], d[2]), UDim2.fromOffset(d[3], d[4])
                f.BackgroundColor3, f.BackgroundTransparency, f.Visible = col, tr(0), true
            end
        elseif style == "3D Box" and allIn then
            for k, ed in ipairs(CUBE_EDGES) do
                local f = u.cube[k]
                if not f then f = newLine(u.root) u.cube[k] = f end
                setLine(f, pts[ed[1]], pts[ed[2]], th, col, tr(0))
            end
        end

        -- полоска HP
        local hum = e.hum
        if hum and not hum.Parent then hum = nil e.hum = nil end
        if S.hpBar and hum and hum.MaxHealth > 0 then
            local ratio = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
            u.hpBg.Visible = true
            u.hpBg.Position, u.hpBg.Size = UDim2.fromOffset(x - 6, y), UDim2.fromOffset(3, h)
            u.hpBg.BackgroundTransparency = tr(0.45)
            u.hpFill.Size = UDim2.fromScale(1, ratio)
            u.hpFill.BackgroundColor3 = Color3.fromRGB(255, 70, 70):Lerp(Color3.fromRGB(80, 235, 130), ratio)
            u.hpFill.BackgroundTransparency = tr(0)
        else
            u.hpBg.Visible = false
        end

        -- подписи
        u.pill.Visible, u.plainT.Visible, u.infoT.Visible = false, false, false
        local label = e.text
        if e.textFn then
            local ok, v = pcall(e.textFn, o)
            if ok and v then label = v end
        end
        local tag = ""
        if e.tagFn then
            local ok, v = pcall(e.tagFn, o)
            if ok and v and v ~= "" then tag = '  <font color="' .. hex(col) .. '">' .. esc(v) .. "</font>" end
        end
        if Lib.ShowESPText ~= false and (label ~= "" or S.showDist) then
            local distTxt = S.showDist and string.format("%dm", math.floor(dist)) or nil
            local ts = S.textSize
            if S.nameStyle == "Pill" then
                local main = esc(label) .. tag
                if distTxt then main = main .. (main ~= "" and '  <font color="#9aa0b4">' or '<font color="#9aa0b4">') .. distTxt .. "</font>" end
                u.nameT.Font = S.font
                u.nameT.TextSize = ts
                u.nameT.Text = main
                u.nameT.TextTransparency = tr(S.textT)
                u.nameS.Transparency = tr(S.textOutlineT)
                local pw = u.nameT.TextBounds.X + 22
                local ph = ts + 10
                u.pill.Size = UDim2.fromOffset(pw, ph)
                u.pill.Position = UDim2.fromOffset(x + w / 2 - pw / 2, y - ph - 5)
                u.pill.BackgroundTransparency = tr(0.15)
                u.pill.Visible = true
                u.accent.BackgroundColor3 = col
                u.accent.BackgroundTransparency = tr(0)
                u.pillStroke.Color, u.pillStroke.Transparency = col, tr(0.35)
            else
                local main = '<font color="' .. hex(col) .. '">' .. esc(label) .. "</font>" .. tag
                if distTxt then main = main .. '  <font color="#c8ccda">' .. distTxt .. "</font>" end
                u.plainT.Font = S.font
                u.plainT.TextSize = ts
                u.plainT.Text = main
                u.plainT.TextTransparency = tr(S.textT)
                u.plainS.Transparency = tr(S.textOutlineT)
                u.plainT.Position = UDim2.fromOffset(x + w / 2, y - 3)
                u.plainT.Visible = true
            end
            local extra
            if e.infoFn then
                local ok, v = pcall(e.infoFn, o)
                if ok and v and v ~= "" then extra = '<font color="' .. hex(col) .. '">' .. esc(v) .. "</font>" end
            end
            local hpTxt = (S.hpText and hum and hum.MaxHealth > 0 and hum.Health > 0) and (math.floor(hum.Health) .. " hp") or nil
            if hpTxt or extra then
                u.infoT.Font = S.font
                u.infoT.TextSize = math.max(ts - 2, 9)
                u.infoT.Text = (hpTxt or "") .. ((hpTxt and extra) and "  ·  " or "") .. (extra or "")
                u.infoT.TextTransparency = tr(S.textT)
                u.infoS.Transparency = tr(S.textOutlineT)
                u.infoT.Position = UDim2.fromOffset(x + w / 2, y + h + 3)
                u.infoT.Visible = true
            end
        end

        -- скелет / точка на голове / линия взгляда (только персонажи)
        local char = e.isModel and hum and o or nil
        if S.skeleton and char then
            local bones = char:FindFirstChild("UpperTorso") and BONES_R15 or BONES_R6
            for k, b in ipairs(bones) do
                local f = u.bones[k]
                if not f then f = newLine(u.root) u.bones[k] = f end
                local child, child2 = char:FindFirstChild(b[1]), char:FindFirstChild(b[2])
                if child and child2 then
                    local screenPoint, screenPoint2 = cam:WorldToViewportPoint(child.Position), cam:WorldToViewportPoint(child2.Position)
                    if screenPoint.Z > 0 and screenPoint2.Z > 0 then
                        setLine(f, Vector2.new(screenPoint.X, screenPoint.Y), Vector2.new(screenPoint2.X, screenPoint2.Y), S.skelThick, col, tr(0))
                    else
                        f.Visible = false
                    end
                else
                    f.Visible = false
                end
            end
        else
            for _, f in ipairs(u.bones) do f.Visible = false end
        end
        local head = char and char:FindFirstChild("Head")
        if S.headDot and head then
            local sp = cam:WorldToViewportPoint(head.Position)
            local d = math.clamp(h * 0.13, 5, 16)
            u.dot.Size = UDim2.fromOffset(d, d)
            u.dot.Position = UDim2.fromOffset(sp.X, sp.Y)
            u.dot.BackgroundColor3, u.dot.BackgroundTransparency = col, tr(0)
            u.dot.Visible = sp.Z > 0
        else
            u.dot.Visible = false
        end
        if S.lookLine and head then
            local a = cam:WorldToViewportPoint(head.Position)
            local b = cam:WorldToViewportPoint(head.Position + head.CFrame.LookVector * 7)
            if a.Z > 0 and b.Z > 0 then
                setLine(u.lookLine, Vector2.new(a.X, a.Y), Vector2.new(b.X, b.Y), 1.6, col, tr(0.15))
            else
                u.lookLine.Visible = false
            end
        else
            u.lookLine.Visible = false
        end

        -- трейсер
        if (Lib.Tracers == true or Lib.TracersEnabled[o]) and cp.Z > 0 and not e.noTracer then
            local from
            if S.tracerFrom == "Center" then from = center
            elseif S.tracerFrom == "Top" then from = Vector2.new(vs.X / 2, 0)
            elseif S.tracerFrom == "Mouse" then from = userInputService:GetMouseLocation()
            else from = Vector2.new(vs.X / 2, vs.Y) end
            setLine(u.tracer, from, Vector2.new(cp.X, cp.Y), math.max(S.tracerThick, 0.5) + 0.5, col, tr(0.2))
        else
            u.tracer.Visible = false
        end
    end

    -- ближайшим N объектам даём Highlight (Roblox рисует не больше ~31)
    local lastRank = 0
    local function rankChams(camPos)
        local list = {}
        for _, e in pairs(entries) do
            if e.size and not e.hidden then list[#list + 1] = e end
        end
        table.sort(list, function(a, b) return (a.dist or 1e9) < (b.dist or 1e9) end)
        local limit = math.min(S.chamLimit, 31)
        for rank, e in ipairs(list) do e.wantHL = rank <= limit end
    end

    local conn
    conn = runService.RenderStepped:Connect(function(dt)
        cam = workspace.CurrentCamera
        if not cam or not alive then return end
        if not Lib.Enabled then
            if not Lib._wasOff then
                Lib._wasOff = true
                for _, e in pairs(entries) do hideAll(e) end
            end
            return
        end
        Lib._wasOff = nil
        local t = os.clock()
        local vs = cam.ViewportSize
        local center = vs / 2
        local camPos = cam.CFrame.Position
        if t - lastRank > 0.2 then
            lastRank = t
            pcall(rankChams, camPos)
        end
        local dead
        for obj, e in pairs(entries) do
            local ok = pcall(renderEntry, e, t, dt, camPos, vs, center)
            if not ok then hideAll(e) end
            if e.dead then
                dead = dead or {}
                dead[#dead + 1] = obj
            end
        end
        if dead then
            for _, obj in ipairs(dead) do
                local e = entries[obj]
                if e then destroyUI(e) end
                entries[obj] = nil
                Lib.ColorTable[obj] = nil
                Lib.TracersEnabled[obj] = nil
            end
        end
    end)

    -- ---------------------------------------------------------------- API
    function Lib:AddESP(data)
        local obj = data and data.Object
        if typeof(obj) ~= "Instance" then return end
        local e = entries[obj]
        if not e then
            e = newEntry(obj)
            entries[obj] = e
        end
        e.dead, e.target = nil, 1
        e.text = data.Text or ""
        e.color = data.Color or WHITE
        -- необязательные хуки (вызываются каждый кадр, ошибки гасятся):
        e.textFn, e.tagFn, e.infoFn = data.TextFn, data.TagFn, data.InfoFn   -- (obj) -> string
        e.colorFn = data.ColorFn                                              -- (t, obj) -> Color3
        e.filter = data.Filter                                                -- () -> bool, false = скрыть
        e.noChams, e.noTracer, e.noArrow = data.NoChams, data.NoTracer, data.NoArrow
        Lib.ColorTable[obj] = e.color
        return e
    end

    function Lib:SetEnabled(v) Lib.Enabled = v and true or false end

    -- ---- слежение за игроками: Lib:TrackPlayers{ Text, Tag, Info, Color, Filter } (все — функции от Player) ----
    local tracker, trackerConns, trackerOwned = nil, {}, {}
    local function trackSync()
        if not tracker then return end
        local seen = {}
        for _, p in ipairs(players:GetPlayers()) do
            local c = p.Character
            if p ~= localPlayer and c and c:FindFirstChildOfClass("Humanoid") then
                seen[c] = true
                if not trackerOwned[c] or not entries[c] then
                    local opts = tracker
                    Lib:AddESP({
                        Object = c,
                        Text = p.DisplayName,
                        TextFn = opts.Text and function() return opts.Text(p) end or function() return p.DisplayName end,
                        TagFn = opts.Tag and function() return opts.Tag(p) end or nil,
                        InfoFn = opts.Info and function() return opts.Info(p) end or nil,
                        ColorFn = opts.Color and function(t) return opts.Color(p, t) end or nil,
                        Filter = opts.Filter and function() return opts.Filter(p) end or nil,
                        Color = Color3.new(1, 1, 1),
                    })
                    trackerOwned[c] = true
                end
            end
        end
        for c in pairs(trackerOwned) do
            if not seen[c] then
                trackerOwned[c] = nil
                if entries[c] then Lib:RemoveESP(c) end
            end
        end
    end
    function Lib:TrackPlayers(opts)
        Lib:StopTrackingPlayers()
        tracker = opts or {}
        trackerConns[#trackerConns + 1] = players.PlayerAdded:Connect(function(p)
            trackerConns[#trackerConns + 1] = p.CharacterAdded:Connect(function() task.wait(0.3) pcall(trackSync) end)
        end)
        for _, p in ipairs(players:GetPlayers()) do
            trackerConns[#trackerConns + 1] = p.CharacterAdded:Connect(function() task.wait(0.3) pcall(trackSync) end)
        end
        local acc = 0
        trackerConns[#trackerConns + 1] = runService.Heartbeat:Connect(function(dt)
            acc = acc + dt
            if acc >= 0.5 then acc = 0 pcall(trackSync) end
        end)
        pcall(trackSync)
    end
    function Lib:StopTrackingPlayers()
        tracker = nil
        for _, c in ipairs(trackerConns) do pcall(function() c:Disconnect() end) end
        trackerConns = {}
        for c in pairs(trackerOwned) do
            if entries[c] then Lib:RemoveESP(c) end
        end
        trackerOwned = {}
    end

    function Lib:RemoveESP(obj)
        local e = entries[obj]
        if not e then return end
        if S.fadeTime > 0 and e.ui then
            e.target = 0
        else
            destroyUI(e)
            entries[obj] = nil
            Lib.ColorTable[obj] = nil
        end
    end

    function Lib:UpdateObjectColor(obj, col)
        local e = entries[obj]
        if e then e.color = col end
        if e or Lib.ColorTable[obj] then Lib.ColorTable[obj] = col end
    end

    function Lib:SetTracersEnabled(obj, value)
        Lib.TracersEnabled[obj] = value and true or nil
    end

    function Lib:UpdateObjectText(obj, text)
        local e = entries[obj]
        if e then e.text = text or "" end
    end

    function Lib:SetSetting(key, value) S[key] = value end
    function Lib:SetRainbow(v) S.rainbow = v and true or false end
    function Lib:SetTracerOrigin(v) S.tracerFrom = v or "Bottom" end
    function Lib:SetShowDistance(v) S.showDist = v and true or false end
    function Lib:SetTextSize(v) S.textSize = v end
    function Lib:SetFont(v) S.font = v or Enum.Font.GothamBold end
    function Lib:SetRenderLimit(v) S.chamLimit = v end
    function Lib:SetFillTransparency(v) S.fillT = v end
    function Lib:SetOutlineTransparency(v) S.outlineT = v end
    function Lib:SetTextTransparency(v) S.textT = v end
    function Lib:SetTextOutlineTransparency(v) S.textOutlineT = v end
    function Lib:SetFadeTime(v) S.fadeTime = v or 0 end
    function Lib:SetArrows(v) S.arrows = v and true or false end
    function Lib:SetArrowRadius(v) S.arrowRadius = v end
    function Lib:SetTracerSize(v) S.tracerThick = v end
    function Lib:SetMatchColors(v) S.matchColors = v and true or false end
    function Lib:SetOutlineColor(v) S.outlineColor = v or WHITE end

    function Lib:Unload()
        if not alive then return end
        alive = false
        Lib:StopTrackingPlayers()
        if conn then conn:Disconnect() end
        for _, e in pairs(entries) do destroyUI(e) end
        table.clear(entries)
        pcall(function() gui:Destroy() end)
        pcall(function() chamFolder:Destroy() end)
    end

    return Lib
end

do
    local ok, result = pcall(createESPEngine)
    if ok and result then
        M.ESP = result
    else
        warn("[MoroVisuals] ESP engine failed: " .. tostring(result))
        M.ESP = setmetatable({ ObjectMaxDistance = {}, TracersEnabled = {}, ColorTable = {}, Settings = {}, Unload = function() end },
            { __index = function() return function() end end })
    end
end

-- ================================================================== POST FX
-- Цветокор + bloom + sun rays + DoF + blur + атмосфера. Пресеты и параметры как в меню Moro:
--   b/c/s/tint — яркость/контраст/насыщенность/оттенок, bi/bs/bt — bloom, ri/rs — лучи,
--   dof/df/dr/dfar/dnear — глубина резкости, blur, ad/ao/ac/adc/ag/ah — Atmosphere, clock/amb/expo — освещение.
local PF = { On = false, fx = {} }
M.PostFX = PF

PF.Defaults = {
    b = 0, c = 0, s = 0, tint = Color3.new(1, 1, 1),
    bi = 0, bs = 24, bt = 2, ri = 0, rs = 0.5,
    dof = false, df = 50, dr = 30, dfar = 0, dnear = 0, blur = 0,
    ad = 0.3, ao = 0, ac = Color3.fromRGB(199, 199, 199), adc = Color3.fromRGB(106, 112, 125), ag = 0, ah = 0,
    clock = nil, amb = nil, expo = 0,
}
PF.Values = {}
for k, v in pairs(PF.Defaults) do PF.Values[k] = v end

PF.Presets = {
    ["Cinematic"] = { b = 0.02, c = 0.22, s = 0.08, tint = Color3.fromRGB(255, 243, 228), bi = 0.7, bs = 32, bt = 0.95, ri = 0.12, rs = 0.7, dof = true, df = 38, dr = 14, dfar = 0.12,
        ad = 0.3, ac = Color3.fromRGB(200, 205, 215), adc = Color3.fromRGB(120, 100, 90), ah = 1, clock = 17.2 },
    ["Neon Night"] = { c = 0.35, s = 0.55, tint = Color3.fromRGB(200, 170, 255), bi = 1.6, bs = 42, bt = 0.75, ad = 0.35, ac = Color3.fromRGB(60, 40, 110), adc = Color3.fromRGB(180, 60, 255), ah = 2,
        clock = 0, amb = Color3.fromRGB(70, 50, 120), expo = 0.1 },
    ["Halloween"] = { c = 0.25, s = 0.35, tint = Color3.fromRGB(255, 170, 90), bi = 0.9, bs = 36, bt = 0.85, ad = 0.5, ac = Color3.fromRGB(255, 120, 40), adc = Color3.fromRGB(120, 30, 150), ah = 2.4,
        clock = 0, amb = Color3.fromRGB(90, 40, 20), expo = 0.15 },
    ["Blood Moon"] = { c = 0.3, s = 0.2, tint = Color3.fromRGB(255, 120, 120), bi = 1.0, bs = 40, bt = 0.8, ad = 0.45, ac = Color3.fromRGB(170, 20, 20), adc = Color3.fromRGB(60, 0, 0), ah = 2,
        clock = 0, amb = Color3.fromRGB(80, 15, 15) },
    ["Vaporwave"] = { c = 0.25, s = 0.6, tint = Color3.fromRGB(255, 190, 245), bi = 1.2, bs = 38, bt = 0.8, ad = 0.3, ac = Color3.fromRGB(255, 130, 220), adc = Color3.fromRGB(90, 200, 255), ah = 1.2,
        clock = 18.2, amb = Color3.fromRGB(120, 80, 150) },
    ["Noir"] = { b = -0.03, c = 0.45, s = -1, tint = Color3.fromRGB(235, 235, 235), bi = 0.3, ad = 0.25, ac = Color3.fromRGB(120, 120, 120), adc = Color3.fromRGB(60, 60, 60), ah = 1.5 },
    ["Frozen"] = { b = 0.04, c = 0.15, s = -0.1, tint = Color3.fromRGB(190, 225, 255), bi = 0.8, bs = 34, bt = 0.9, ri = 0.1, ad = 0.38, ac = Color3.fromRGB(215, 235, 255), adc = Color3.fromRGB(170, 205, 235), ah = 1.4,
        clock = 12 },
    ["Matrix"] = { c = 0.3, s = -0.2, tint = Color3.fromRGB(150, 255, 170), bi = 0.9, bs = 30, bt = 0.85, ad = 0.34, ac = Color3.fromRGB(20, 90, 40), adc = Color3.fromRGB(0, 70, 20), ah = 1.8,
        clock = 0, amb = Color3.fromRGB(10, 70, 25) },
    ["Golden Hour"] = { b = 0.02, c = 0.2, s = 0.2, tint = Color3.fromRGB(255, 220, 170), bi = 0.8, bs = 36, bt = 0.9, ri = 0.3, rs = 0.9, ad = 0.32, ac = Color3.fromRGB(255, 200, 150), adc = Color3.fromRGB(255, 140, 80), ah = 1.2,
        clock = 17.6 },
    ["Dreamy"] = { b = 0.05, c = -0.05, s = 0.25, tint = Color3.fromRGB(255, 235, 250), bi = 1.4, bs = 52, bt = 0.7, dof = true, df = 30, dr = 10, dfar = 0.35, dnear = 0.1, ad = 0.3,
        ac = Color3.fromRGB(240, 220, 255), adc = Color3.fromRGB(255, 200, 230), ah = 1 },
    ["Toxic"] = { c = 0.3, s = 0.5, tint = Color3.fromRGB(190, 255, 120), bi = 1.1, bs = 36, bt = 0.8, ad = 0.45, ac = Color3.fromRGB(110, 190, 20), adc = Color3.fromRGB(40, 90, 0), ah = 2.2,
        clock = 0, amb = Color3.fromRGB(40, 90, 15) },
}

PF.Names = { "Cinematic", "Neon Night", "Halloween", "Blood Moon", "Vaporwave", "Noir", "Frozen", "Matrix", "Golden Hour", "Dreamy", "Toxic" }

local function pfTween(inst, t, props)
    local tw = tweenService:Create(inst, TweenInfo.new(t, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props)
    tw:Play()
    return tw
end

local function pfEnsure()
    if PF.fx.cc then return end
    local function make(class, name)
        local e = Instance.new(class)
        e.Name = "MoroFX_" .. name
        e.Parent = lighting
        return e
    end
    PF.fx.cc = make("ColorCorrectionEffect", "CC")
    PF.fx.bloom = make("BloomEffect", "Bloom")
    PF.fx.rays = make("SunRaysEffect", "Rays")
    PF.fx.dof = make("DepthOfFieldEffect", "DOF")
    PF.fx.blur = make("BlurEffect", "Blur")
    local existing = lighting:FindFirstChildOfClass("Atmosphere")
    if existing then
        PF.fx.atmo = existing
        PF.atmoBackup = { Density = existing.Density, Offset = existing.Offset, Color = existing.Color, Decay = existing.Decay, Glare = existing.Glare, Haze = existing.Haze }
    else
        PF.fx.atmo = make("Atmosphere", "Atmo")
        PF.atmoOwn = true
    end
    PF.backup = { ClockTime = lighting.ClockTime, Ambient = lighting.Ambient, OutdoorAmbient = lighting.OutdoorAmbient, ExposureCompensation = lighting.ExposureCompensation }
end

-- применить текущие PF.Values (smooth = плавный переход ~1.2 с)
function PF.Apply(smooth)
    if not PF.On then return end
    pfEnsure()
    local v, fx = PF.Values, PF.fx
    local t = smooth and 1.2 or 0.05
    local function to(inst, props) pfTween(inst, t, props) end
    to(fx.cc, { Brightness = v.b, Contrast = v.c, Saturation = v.s, TintColor = v.tint })
    to(fx.bloom, { Intensity = v.bi, Size = v.bs, Threshold = v.bt })
    to(fx.rays, { Intensity = v.ri, Spread = v.rs })
    fx.dof.Enabled = v.dof
    to(fx.dof, { FocusDistance = v.df, InFocusRadius = v.dr, FarIntensity = v.dfar, NearIntensity = v.dnear })
    to(fx.blur, { Size = v.blur })
    to(fx.atmo, { Density = v.ad, Offset = v.ao, Color = v.ac, Decay = v.adc, Glare = v.ag, Haze = v.ah })
    if v.clock then lighting.ClockTime = v.clock end
    if v.amb then
        lighting.Ambient = v.amb
        lighting.OutdoorAmbient = v.amb
    end
    lighting.ExposureCompensation = v.expo
end

function PF.Enable(on)
    on = on and true or false
    if on == PF.On then return end
    PF.On = on
    if on then
        pfEnsure()
        PF.Apply(true)
    else
        for key, effect in pairs(PF.fx) do
            if key == "atmo" and not PF.atmoOwn then
                for prop, value in pairs(PF.atmoBackup or {}) do pcall(function() effect[prop] = value end) end
            else
                pcall(function() effect:Destroy() end)
            end
        end
        if PF.backup then
            for key, value in pairs(PF.backup) do pcall(function() lighting[key] = value end) end
        end
        PF.fx, PF.backup, PF.atmoBackup, PF.atmoOwn = {}, nil, nil, nil
    end
end

-- один параметр (ключи — как в PF.Defaults); применяется сразу
function PF.Set(key, value)
    PF.Values[key] = value
    PF.Apply(false)
end

function PF.Reset()
    for k in pairs(PF.Values) do PF.Values[k] = nil end
    for k, v in pairs(PF.Defaults) do PF.Values[k] = v end
    PF.Apply(true)
end

-- пресет: возвращает true, если он есть. Включает PostFX, если он был выключен.
-- Меню потом может перечитать PF.Values и обновить свои ползунки.
function PF.Preset(name)
    local preset = PF.Presets[name]
    if not preset then return false end
    for k, v in pairs(PF.Defaults) do PF.Values[k] = v end
    for k, v in pairs(preset) do PF.Values[k] = v end
    PF.Values.clock = preset.clock
    PF.Values.amb = preset.amb
    if not PF.On then PF.Enable(true) else PF.Apply(true) end
    return true
end

-- ==================================================================== X-RAY
-- Полупрозрачные стены только у вас на экране (LocalTransparencyModifier), без изменения самих деталей.
--   XRay.Start{ Roots = function() return { instance, ... } end, Amount = 0.65, Interval = 3, Filter = function(part) return bool end }
--   XRay.SetAmount(0.5) / XRay.Stop()
local XR = { On = false, parts = {}, amount = 0.65, opts = nil }
M.XRay = XR

local function xrayScan()
    local opts = XR.opts
    if not opts then return end
    local ok, roots = pcall(opts.Roots)
    if not ok or type(roots) ~= "table" then return end
    for _, root in ipairs(roots) do
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("BasePart") and d.Transparency < 0.5 and not XR.parts[d] and (not opts.Filter or opts.Filter(d)) then
                XR.parts[d] = true
                d.LocalTransparencyModifier = XR.amount
            end
        end
    end
end

function XR.Stop()
    XR.On = false
    XR.opts = nil
    XR.gen = nil
    for d in pairs(XR.parts) do
        if d.Parent then pcall(function() d.LocalTransparencyModifier = 0 end) end
    end
    XR.parts = {}
end

function XR.Start(opts)
    XR.Stop()
    XR.On = true
    XR.opts = opts or {}
    XR.amount = XR.opts.Amount or 0.65
    if not XR.opts.Roots then XR.opts.Roots = function() return { workspace } end end
    local gen = {}
    XR.gen = gen
    task.spawn(function()
        while XR.On and XR.gen == gen do
            xrayScan()
            task.wait(XR.opts and XR.opts.Interval or 3)
        end
    end)
end

function XR.SetAmount(a)
    XR.amount = a
    for d in pairs(XR.parts) do
        if d.Parent then pcall(function() d.LocalTransparencyModifier = a end) end
    end
end

-- ================================================================== UNLOAD
function M.Unload()
    pcall(XR.Stop)
    pcall(PF.Enable, false)
    if M.ESP and M.ESP.Unload then pcall(M.ESP.Unload, M.ESP) end
    if env.__MoroVisuals == M then env.__MoroVisuals = nil end
end

env.__MoroVisuals = M
return M
