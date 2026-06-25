--[[ 
    MoroLumina UI Framework — Emerald Edition
    Professional, modern, rich-featured UI Library styled like izen.lol bypass page.
    Pure Luau, TweenService, and standard GuiObjects.
]]

local Library = {}
Library.__index = Library

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui          = game:GetService("CoreGui")
local Players          = game:GetService("Players")

local Theme = {
    Background    = Color3.fromRGB(8, 8, 8),
    BackgroundAlt = Color3.fromRGB(12, 12, 12),
    Element       = Color3.fromRGB(18, 18, 18),
    ElementHover  = Color3.fromRGB(24, 24, 24),
    Stroke        = Color3.fromRGB(30, 35, 32),
    StrokeAccent  = Color3.fromRGB(0, 225, 134),
    Accent        = Color3.fromRGB(0, 225, 134),
    Text          = Color3.fromRGB(235, 235, 235),
    TextDim       = Color3.fromRGB(140, 145, 145),
    Glow          = Color3.fromRGB(0, 225, 134),
    Font          = Enum.Font.Gotham,
    FontBold      = Enum.Font.GothamBold,
}

local TW = {
    Fast   = TweenInfo.new(0.15, Enum.EasingStyle.Quad,  Enum.EasingDirection.Out),
    Normal = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    Slow   = TweenInfo.new(0.4,  Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
}

local function create(class, props, children)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do if k ~= "Parent" then inst[k] = v end end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    if props and props.Parent then inst.Parent = props.Parent end
    return inst
end

local function corner(p, r) return create("UICorner", {CornerRadius=UDim.new(0,r or 12), Parent=p}) end
local function stroke(p, c, t, tr) return create("UIStroke", {Color=c or Theme.Stroke, Thickness=t or 1, Transparency=tr or 0, ApplyStrokeMode=Enum.ApplyStrokeMode.Border, Parent=p}) end
local function padding(p, a) return create("UIPadding", {PaddingTop=UDim.new(0,a),PaddingBottom=UDim.new(0,a),PaddingLeft=UDim.new(0,a),PaddingRight=UDim.new(0,a), Parent=p}) end

local function addGlow(parent)
    return create("ImageLabel", {
        Name="Glow", BackgroundTransparency=1,
        Image="rbxassetid://5028857084", ImageColor3=Theme.Glow, ImageTransparency=0.9,
        ScaleType=Enum.ScaleType.Slice, SliceCenter=Rect.new(24,24,276,276),
        Size=UDim2.new(1,60,1,60), Position=UDim2.new(0,-30,0,-30), ZIndex=0, Parent=parent,
    })
end

local function ripple(button)
    button.MouseEnter:Connect(function()
        TweenService:Create(button, TW.Fast, {BackgroundColor3=Theme.ElementHover}):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TW.Fast, {BackgroundColor3=Theme.Element}):Play()
    end)
end

----------------------------------------------------------------------
-- NOTIFICATIONS
----------------------------------------------------------------------
local NotifyGui
local function getNotifyContainer()
    if NotifyGui and NotifyGui.Parent then return NotifyGui end
    NotifyGui = create("ScreenGui", {
        Name="MoroLumina_Notify", DisplayOrder=2147483647,
        ResetOnSpawn=false, IgnoreGuiInset=true,
        ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    })
    pcall(function() NotifyGui.Parent = CoreGui end)
    if not NotifyGui.Parent then NotifyGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
    local holder = create("Frame", {
        Name="Holder", BackgroundTransparency=1,
        AnchorPoint=Vector2.new(1,1), Position=UDim2.new(1,-16,1,-16),
        Size=UDim2.new(0,320,1,-32), Parent=NotifyGui,
    })
    create("UIListLayout", {
        VerticalAlignment=Enum.VerticalAlignment.Bottom,
        HorizontalAlignment=Enum.HorizontalAlignment.Right,
        SortOrder=Enum.SortOrder.LayoutOrder, Padding=UDim.new(0,10), Parent=holder,
    })
    return NotifyGui
end

local TYPE_COLORS = {
    Success = Color3.fromRGB(0, 225, 134),
    Info    = Color3.fromRGB(70, 170, 255),
    Warning = Color3.fromRGB(255, 190, 60),
    Error   = Color3.fromRGB(255, 80, 90),
}

local function showNotify(opts)
    opts = opts or {}
    local title    = opts.Title or "Notification"
    local content  = opts.Content or ""
    local duration = opts.Duration or 4
    local nType    = opts.Type or "Success"
    local accent   = TYPE_COLORS[nType] or Theme.Accent
    local holder = getNotifyContainer().Holder
    
    local card = create("Frame", {
        Name="Notify", BackgroundColor3=Theme.BackgroundAlt, BackgroundTransparency=0,
        Size=UDim2.new(1,0,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        ClipsDescendants=true, Parent=holder,
    })
    corner(card, 14)
    stroke(card, Theme.Stroke, 1, 0)
    
    local inner = create("Frame", {
        BackgroundTransparency=1, Size=UDim2.new(1,0,0,0),
        AutomaticSize=Enum.AutomaticSize.Y, Parent=card,
    })
    padding(inner, 14)
    
    local badge = create("Frame", {
        BackgroundColor3=Color3.fromRGB(14,22,18),
        Size=UDim2.new(0,36,0,36), Parent=inner,
    })
    corner(badge, 10)
    stroke(badge, accent, 1, 0.5)
    create("TextLabel", {
        BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
        Text="✓", TextColor3=accent,
        Font=Theme.FontBold, TextSize=20, Parent=badge,
    })
    
    create("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,48,0,2),
        Size=UDim2.new(1,-56,0,20), Text=title, TextColor3=Theme.Text,
        Font=Theme.FontBold, TextSize=15,
        TextXAlignment=Enum.TextXAlignment.Left, Parent=inner,
    })
    create("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,48,0,22),
        Size=UDim2.new(1,-56,0,0), AutomaticSize=Enum.AutomaticSize.Y,
        Text=content, TextColor3=Theme.TextDim, Font=Theme.Font, TextSize=13,
        TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, Parent=inner,
    })
    
    local closeBtn = create("TextButton", {
        BackgroundColor3=Theme.Element, Size=UDim2.new(0,60,0,28),
        Position=UDim2.new(1,-74,0,8),
        Text="Close", TextColor3=Theme.TextDim, Font=Theme.Font, TextSize=12,
        AutoButtonColor=false, Parent=inner,
    })
    corner(closeBtn, 8)
    stroke(closeBtn, Theme.Stroke, 1, 0)
    ripple(closeBtn)
    closeBtn.MouseButton1Click:Connect(function()
        local out = TweenService:Create(card, TW.Normal, {Position=UDim2.new(1,30,0,0), BackgroundTransparency=1})
        out:Play(); out.Completed:Connect(function() card:Destroy() end)
    end)
    
    card.Position = UDim2.new(1,20,0,0)
    card.BackgroundTransparency = 1
    TweenService:Create(card, TW.Slow, {Position=UDim2.new(0,0,0,0), BackgroundTransparency=0}):Play()
    
    task.delay(duration, function()
        if card.Parent then
            local out = TweenService:Create(card, TW.Normal, {Position=UDim2.new(1,30,0,0), BackgroundTransparency=1})
            out:Play(); out.Completed:Connect(function() card:Destroy() end)
        end
    end)
end

----------------------------------------------------------------------
-- WINDOW
----------------------------------------------------------------------
function Library:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "MoroLumina"
    local toggleKey   = config.ToggleKey or Enum.KeyCode.RightControl
    
    local Window = {}
    Window._toggles = {}
    
    local screenGui = create("ScreenGui", {
        Name="MoroLumina", ResetOnSpawn=false, DisplayOrder=999,
        IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling,
    })
    pcall(function() screenGui.Parent = CoreGui end)
    if not screenGui.Parent then screenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui") end
    Window.Gui = screenGui
    
    local root = create("CanvasGroup", {
        Name="Root", AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.new(0.5,0,0.5,0), Size=UDim2.new(0,600,0,400),
        BackgroundTransparency=1, Parent=screenGui,
    })
    addGlow(root)
    
    local main = create("Frame", {
        Name="Main", BackgroundColor3=Theme.Background,
        Size=UDim2.new(1,0,1,0), Parent=root,
    })
    corner(main, 16)
    stroke(main, Theme.Stroke, 1, 0)
    
    local topBar = create("Frame", {
        Name="TopBar", BackgroundColor3=Theme.BackgroundAlt,
        Size=UDim2.new(1,0,0,50), Parent=main,
    })
    corner(topBar, 16)
    create("Frame", {BackgroundColor3=Theme.BackgroundAlt, BorderSizePixel=0,
        Size=UDim2.new(1,0,0,16), Position=UDim2.new(0,0,1,-16), Parent=topBar})
    
    create("TextLabel", {
        BackgroundTransparency=1, Position=UDim2.new(0,20,0,12),
        Size=UDim2.new(0,300,0,26), Text=windowTitle, TextColor3=Theme.Text,
        Font=Theme.FontBold, TextSize=16, TextXAlignment=Enum.TextXAlignment.Left, Parent=topBar
    })
    
    -- Dragging
    local dragging, dragStart, startPos
    topBar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=i.Position; startPos=root.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d = i.Position - dragStart
            root.Position = UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    
    -- Sidebar
    local sidebar = create("Frame", {
        Name="Sidebar", BackgroundColor3=Theme.BackgroundAlt,
        Position=UDim2.new(0,12,0,62), Size=UDim2.new(0,150,1,-74), Parent=main,
    })
    corner(sidebar, 12)
    stroke(sidebar, Theme.Stroke, 1, 0)
    
    local tabList = create("ScrollingFrame", {
        BackgroundTransparency=1, Position=UDim2.new(0,8,0,8),
        Size=UDim2.new(1,-16,1,-16), ScrollBarThickness=0,
        CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y, Parent=sidebar,
    })
    create("UIListLayout", {Padding=UDim.new(0,6), SortOrder=Enum.SortOrder.LayoutOrder, Parent=tabList})
    
    -- Content
    local content = create("Frame", {
        Name="Content", BackgroundColor3=Theme.BackgroundAlt,
        Position=UDim2.new(0,174,0,62), Size=UDim2.new(1,-186,1,-74), Parent=main,
    })
    corner(content, 12)
    stroke(content, Theme.Stroke, 1, 0)
    local pages = create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Parent=content})
    
    -- Visibility
    local isVisible = true
    local function setVisible(state)
        isVisible = state
        if state then
            root.Visible=true; root.GroupTransparency=1; root.Size=UDim2.new(0,560,0,360)
            TweenService:Create(root, TW.Normal, {GroupTransparency=0, Size=UDim2.new(0,600,0,400)}):Play()
        else
            local t=TweenService:Create(root, TW.Normal, {GroupTransparency=1, Size=UDim2.new(0,560,0,360)})
            t:Play(); t.Completed:Connect(function() if not isVisible then root.Visible=false end end)
        end
    end
    Window.SetVisible = function(_, s) setVisible(s) end
    function Window:Notify(opts) showNotify(opts) end
    
    -- Float Button
    local floatBtn = create("TextButton", {
        Name="FloatToggle", BackgroundColor3=Theme.Background,
        Size=UDim2.new(0,48,0,48), Position=UDim2.new(0,20,0,20),
        Text="", AutoButtonColor=false, Parent=screenGui,
    })
    corner(floatBtn, 24)
    stroke(floatBtn, Theme.StrokeAccent, 1.5, 0)
    addGlow(floatBtn).ImageTransparency = 0.85
    create("TextLabel", {
        BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text="M",
        TextColor3=Theme.Accent, Font=Theme.FontBold, TextSize=22, Parent=floatBtn,
    })
    
    local floatDragging, floatDragStart, floatStartPos, floatMoved
    floatBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            floatDragging=true; floatMoved=false; floatDragStart=i.Position; floatStartPos=floatBtn.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then floatDragging=false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if floatDragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-floatDragStart
            if d.Magnitude>5 then floatMoved=true end
            floatBtn.Position=UDim2.new(floatStartPos.X.Scale,floatStartPos.X.Offset+d.X,floatStartPos.Y.Scale,floatStartPos.Y.Offset+d.Y)
        end
    end)
    floatBtn.MouseButton1Click:Connect(function() if not floatMoved then setVisible(not isVisible) end end)
    
    UserInputService.InputBegan:Connect(function(i, gpe)
        if gpe then return end
        if i.KeyCode==toggleKey then setVisible(not isVisible) end
    end)
    
    local tabs = {}
    local activeTab
    
    function Window:CreateTab(name)
        local Tab = {}
        local tabBtn = create("TextButton", {
            BackgroundColor3=Theme.Element, BackgroundTransparency=1,
            Size=UDim2.new(1,0,0,34), Text="", AutoButtonColor=false, Parent=tabList,
        })
        corner(tabBtn, 8)
        local tabStroke = stroke(tabBtn, Theme.Stroke, 1, 1)
        local indicator = create("Frame", {
            BackgroundColor3=Theme.Accent, Size=UDim2.new(0,3,0,0),
            Position=UDim2.new(0,0,0.5,0), AnchorPoint=Vector2.new(0,0.5), Parent=tabBtn,
        })
        corner(indicator, 2)
        local tabLabel = create("TextLabel", {
            BackgroundTransparency=1, Position=UDim2.new(0,14,0,0),
            Size=UDim2.new(1,-20,1,0), Text=name, TextColor3=Theme.TextDim,
            Font=Theme.Font, TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, Parent=tabBtn,
        })
        
        local page = create("ScrollingFrame", {
            BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
            ScrollBarThickness=3, ScrollBarImageColor3=Theme.Accent, ScrollBarImageTransparency=0.5,
            CanvasSize=UDim2.new(0,0,0,0), AutomaticCanvasSize=Enum.AutomaticSize.Y,
            Visible=false, Parent=pages,
        })
        padding(page, 12)
        create("UIListLayout", {Padding=UDim.new(0,8), SortOrder=Enum.SortOrder.LayoutOrder, Parent=page})
        
        local function select()
            if activeTab==Tab then return end
            if activeTab then
                activeTab.Page.Visible=false
                TweenService:Create(activeTab.Btn, TW.Fast, {BackgroundTransparency=1}):Play()
                TweenService:Create(activeTab.Stroke, TW.Fast, {Transparency=1}):Play()
                TweenService:Create(activeTab.Label, TW.Fast, {TextColor3=Theme.TextDim}):Play()
                TweenService:Create(activeTab.Indicator, TW.Fast, {Size=UDim2.new(0,3,0,0)}):Play()
            end
            activeTab=Tab; page.Visible=true; page.Position=UDim2.new(0,0,0,10)
            TweenService:Create(page, TW.Normal, {Position=UDim2.new(0,0,0,0)}):Play()
            TweenService:Create(tabBtn, TW.Fast, {BackgroundTransparency=0.8}):Play()
            TweenService:Create(tabStroke, TW.Fast, {Transparency=0.5, Color=Theme.StrokeAccent}):Play()
            TweenService:Create(tabLabel, TW.Fast, {TextColor3=Theme.Text}):Play()
            TweenService:Create(indicator, TW.Normal, {Size=UDim2.new(0,3,0,18)}):Play()
        end
        tabBtn.MouseButton1Click:Connect(select)
        Tab.Btn=tabBtn; Tab.Stroke=tabStroke; Tab.Label=tabLabel; Tab.Indicator=indicator; Tab.Page=page
        table.insert(tabs, Tab)
        if #tabs==1 then select() end
        
        local function baseElement(h)
            local el = create("Frame", {BackgroundColor3=Theme.Element, Size=UDim2.new(1,0,0,h or 40), Parent=page})
            corner(el, 10)
            return el, stroke(el, Theme.Stroke, 1, 0)
        end
        
        function Tab:AddSection(text)
            local h = create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,24), Parent=page})
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Position=UDim2.new(0,4,0,0),
                Text=string.upper(text), TextColor3=Theme.Accent, Font=Theme.FontBold, TextSize=11,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=h})
            return h
        end
        
        function Tab:AddLabel(text)
            local el = baseElement(36)
            local lbl = create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-24,1,0),
                Position=UDim2.new(0,12,0,0), Text=text, TextColor3=Theme.TextDim, Font=Theme.Font,
                TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, TextWrapped=true, Parent=el})
            return {SetText=function(_,t) lbl.Text=t end, Instance=el}
        end
        
        function Tab:AddParagraph(title, text)
            local el = baseElement(60)
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-24,0,20),
                Position=UDim2.new(0,12,0,8), Text=title, TextColor3=Theme.Text, Font=Theme.FontBold,
                TextSize=14, TextXAlignment=Enum.TextXAlignment.Left, Parent=el})
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-24,0,32),
                Position=UDim2.new(0,12,0,26), Text=text, TextColor3=Theme.TextDim, Font=Theme.Font,
                TextSize=12, TextWrapped=true, TextXAlignment=Enum.TextXAlignment.Left, Parent=el})
            return {Instance=el}
        end
        
        function Tab:AddButton(cfg)
            local text, callback = cfg, function() end
            if type(cfg) == "table" then text = cfg.Text; callback = cfg.Callback or function() end end
            local el = baseElement(40)
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-24,1,0),
                Position=UDim2.new(0,12,0,0), Text=text, TextColor3=Theme.Text, Font=Theme.Font,
                TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, Parent=el})
            local btn = create("TextButton", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
                Text="", AutoButtonColor=false, Parent=el})
            btn.MouseButton1Click:Connect(function() if callback then task.spawn(callback) end end)
            ripple(el)
            return {Instance=el}
        end
        
        function Tab:AddToggle(cfg)
            local text, default, callback = cfg, false, function() end
            if type(cfg) == "table" then text = cfg.Text; default = cfg.Default; callback = cfg.Callback or function() end end
            local state = default or false
            local el = baseElement(42)
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-100,1,0),
                Position=UDim2.new(0,12,0,0), Text=text, TextColor3=Theme.Text, Font=Theme.Font,
                TextSize=13, TextXAlignment=Enum.TextXAlignment.Left, Parent=el})
            local track = create("Frame", {BackgroundColor3=state and Theme.Accent or Theme.Element,
                Size=UDim2.new(0,38,0,20), Position=UDim2.new(1,-48,0.5,0),
                AnchorPoint=Vector2.new(0,0.5), Parent=el})
            corner(track, 10)
            local knob = create("Frame", {BackgroundColor3=Color3.fromRGB(255,255,255),
                Size=UDim2.new(0,14,0,14), Position=state and UDim2.new(1,-17,0.5,0) or UDim2.new(0,3,0.5,0),
                AnchorPoint=Vector2.new(0,0.5), Parent=track})
            corner(knob, 7)
            
            local function update()
                TweenService:Create(track, TW.Fast, {BackgroundColor3=state and Theme.Accent or Theme.Element}):Play()
                TweenService:Create(knob, TW.Normal, {Position=state and UDim2.new(1,-17,0.5,0) or UDim2.new(0,3,0.5,0)}):Play()
            end
            local function toggle()
                state = not state; update()
                if callback then task.spawn(callback, state) end
            end
            local btn = create("TextButton", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
                Text="", AutoButtonColor=false, Parent=el})
            btn.MouseButton1Click:Connect(toggle)
            ripple(el)
            local api = {Set=function(_,v) state=v; update(); if callback then task.spawn(callback, state) end end, Get=function() return state end, Instance=el}
            table.insert(Window._toggles, api)
            return api
        end
        
        function Tab:AddSlider(cfg)
            local text, min, max, default, callback = cfg, 0, 100, 0, function() end
            if type(cfg) == "table" then text = cfg.Text; min = cfg.Min; max = cfg.Max; default = cfg.Default; callback = cfg.Callback or function() end end
            local value = math.clamp(default or min, min, max)
            local el = baseElement(54)
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-60,0,20), Position=UDim2.new(0,12,0,6),
                Text=text, TextColor3=Theme.Text, Font=Theme.Font, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=el})
            local valLabel = create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(0,50,0,20), Position=UDim2.new(1,-58,0,6),
                Text=tostring(value), TextColor3=Theme.Accent, Font=Theme.FontBold, TextSize=12,
                TextXAlignment=Enum.TextXAlignment.Right, Parent=el})
            local barBack = create("Frame", {BackgroundColor3=Theme.Element, Size=UDim2.new(1,-24,0,6), Position=UDim2.new(0,12,1,-14), Parent=el})
            corner(barBack, 3)
            local fill = create("Frame", {BackgroundColor3=Theme.Accent, Size=UDim2.new((value-min)/(max-min),0,1,0), Parent=barBack})
            corner(fill, 3)
            local knob = create("Frame", {BackgroundColor3=Color3.fromRGB(255,255,255), Size=UDim2.new(0,12,0,12),
                Position=UDim2.new((value-min)/(max-min),0,0.5,0), AnchorPoint=Vector2.new(0.5,0.5), Parent=barBack})
            corner(knob, 6)
            
            local dragging = false
            local function update(x)
                local rel = math.clamp((x-barBack.AbsolutePosition.X)/barBack.AbsoluteSize.X, 0, 1)
                value = math.floor(min + (max-min)*rel)
                local pct = (value-min)/(max-min)
                TweenService:Create(fill, TW.Fast, {Size=UDim2.new(pct,0,1,0)}):Play()
                TweenService:Create(knob, TW.Fast, {Position=UDim2.new(pct,0,0.5,0)}):Play()
                valLabel.Text = tostring(value)
                if callback then task.spawn(callback, value) end
            end
            barBack.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; update(i.Position.X) end end)
            UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
            UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then update(i.Position.X) end end)
            ripple(el)
            return {Set=function(_,v) value=math.clamp(v,min,max); local pct=(value-min)/(max-min); fill.Size=UDim2.new(pct,0,1,0); knob.Position=UDim2.new(pct,0,0.5,0); valLabel.Text=tostring(value); if callback then task.spawn(callback,value) end end, Get=function() return value end, Instance=el}
        end
        
        function Tab:AddDropdown(cfg)
            local text, list, default, callback = cfg, {}, nil, function() end
            if type(cfg) == "table" then text = cfg.Text; list = cfg.List; default = cfg.Default; callback = cfg.Callback or function() end end
            local selected = default or "Select..."
            local open = false
            local el = baseElement(42); el.ClipsDescendants = true
            local header = create("TextButton", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,42), Text="", AutoButtonColor=false, Parent=el})
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(0.5,0,1,0), Position=UDim2.new(0,12,0,0),
                Text=text, TextColor3=Theme.Text, Font=Theme.Font, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=header})
            local valueLbl = create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(0.5,-40,1,0), Position=UDim2.new(0.5,0,0,0),
                Text=tostring(selected), TextColor3=Theme.TextDim, Font=Theme.Font,
                TextSize=13, TextXAlignment=Enum.TextXAlignment.Right, TextTruncate=Enum.TextTruncate.AtEnd, Parent=header})
            local arrow = create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(0,24,1,0), Position=UDim2.new(1,-30,0,0),
                Text="v", TextColor3=Theme.Accent, Font=Theme.FontBold, TextSize=14, Rotation=90, Parent=header})
            local listHolder = create("Frame", {BackgroundTransparency=1, Size=UDim2.new(1,-16,0,0), Position=UDim2.new(0,8,0,44),
                AutomaticSize=Enum.AutomaticSize.Y, Parent=el})
            create("UIListLayout", {Padding=UDim.new(0,4), SortOrder=Enum.SortOrder.LayoutOrder, Parent=listHolder})
            
            local optButtons = {}
            local function buildOptions()
                for _, b in ipairs(optButtons) do b.Btn:Destroy() end
                table.clear(optButtons)
                for _, opt in ipairs(list) do
                    local oBtn = create("TextButton", {BackgroundColor3=Theme.Element, Size=UDim2.new(1,0,0,30), Text="", AutoButtonColor=false, Parent=listHolder})
                    corner(oBtn, 8)
                    local oStroke = stroke(oBtn, Theme.Stroke, 1, 0.5)
                    local oLbl = create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,10,0,0),
                        Text=tostring(opt), TextColor3=Theme.TextDim, Font=Theme.Font, TextSize=12,
                        TextXAlignment=Enum.TextXAlignment.Left, Parent=oBtn})
                    local function highlight()
                        local on = (selected == opt)
                        TweenService:Create(oStroke, TW.Fast, {Color=on and Theme.StrokeAccent or Theme.Stroke, Transparency=on and 0.2 or 0.5}):Play()
                        TweenService:Create(oLbl, TW.Fast, {TextColor3=on and Theme.Accent or Theme.TextDim}):Play()
                    end
                    highlight()
                    oBtn.MouseButton1Click:Connect(function()
                        selected = opt; valueLbl.Text = tostring(selected)
                        for _, b in ipairs(optButtons) do b.Refresh() end
                        if callback then task.spawn(callback, selected) end
                        open = false
                        TweenService:Create(el, TW.Normal, {Size=UDim2.new(1,0,0,42)}):Play()
                        TweenService:Create(arrow, TW.Fast, {Rotation=0}):Play()
                    end)
                    table.insert(optButtons, {Btn=oBtn, Refresh=highlight})
                end
            end
            buildOptions()
            header.MouseButton1Click:Connect(function()
                open = not open
                local target = open and (52 + #list * 34) or 42
                TweenService:Create(el, TW.Normal, {Size=UDim2.new(1,0,0,target)}):Play()
                TweenService:Create(arrow, TW.Fast, {Rotation=open and 180 or 0}):Play()
            end)
            ripple(el)
            return {Set=function(_,v) selected=v; valueLbl.Text=tostring(v); for _, b in ipairs(optButtons) do b.Refresh() end end, Get=function() return selected end, Refresh=function(_,newList) list=newList or {}; buildOptions() end, Instance=el}
        end
        
        function Tab:AddTextBox(cfg)
            local text, placeholder, clearOnFocus, callback = cfg, "", false, function() end
            if type(cfg) == "table" then text = cfg.Text; placeholder = cfg.Placeholder; clearOnFocus = cfg.ClearOnFocus; callback = cfg.Callback or function() end end
            local el = baseElement(42)
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(0.4,0,1,0), Position=UDim2.new(0,12,0,0),
                Text=text, TextColor3=Theme.Text, Font=Theme.Font, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=el})
            local box = create("Frame", {BackgroundColor3=Theme.Element, Size=UDim2.new(0.55,-20,0,28),
                Position=UDim2.new(0.45,0,0.5,0), AnchorPoint=Vector2.new(0,0.5), Parent=el})
            corner(box, 8); local bStroke = stroke(box, Theme.Stroke, 1, 0)
            local input = create("TextBox", {BackgroundTransparency=1, Size=UDim2.new(1,-16,1,0), Position=UDim2.new(0,8,0,0),
                Text="", PlaceholderText=placeholder or "Type...", PlaceholderColor3=Theme.TextDim,
                TextColor3=Theme.Text, Font=Theme.Font, TextSize=12, TextXAlignment=Enum.TextXAlignment.Left,
                ClearTextOnFocus=clearOnFocus or false, Parent=box})
            input.Focused:Connect(function() TweenService:Create(bStroke, TW.Fast, {Color=Theme.StrokeAccent, Transparency=0.2}):Play() end)
            input.FocusLost:Connect(function(enter)
                TweenService:Create(bStroke, TW.Fast, {Color=Theme.Stroke, Transparency=0}):Play()
                if callback then task.spawn(callback, input.Text, enter) end
            end)
            return {Set=function(_,t) input.Text=t end, Get=function() return input.Text end, Instance=el}
        end
        
        function Tab:AddKeybind(cfg)
            local text, default, callback = cfg, nil, function() end
            if type(cfg) == "table" then text = cfg.Text; default = cfg.Default; callback = cfg.Callback or function() end end
            local currentKey = default; local listening = false
            local el = baseElement(42)
            local btn = create("TextButton", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0), Text="", AutoButtonColor=false, Parent=el})
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-100,1,0), Position=UDim2.new(0,12,0,0),
                Text=text, TextColor3=Theme.Text, Font=Theme.Font, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=btn})
            local keyBox = create("Frame", {BackgroundColor3=Theme.Element, Size=UDim2.new(0,80,0,28),
                Position=UDim2.new(1,-92,0.5,0), AnchorPoint=Vector2.new(0,0.5), Parent=el})
            corner(keyBox, 8); local kStroke = stroke(keyBox, Theme.Stroke, 1, 0)
            local keyLabel = create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,0,1,0),
                Text=currentKey and currentKey.Name or "None", TextColor3=Theme.Accent, Font=Theme.FontBold, TextSize=12, Parent=keyBox})
            btn.MouseButton1Click:Connect(function()
                listening = true; keyLabel.Text = "..."
                TweenService:Create(kStroke, TW.Fast, {Color=Theme.StrokeAccent, Transparency=0.2}):Play()
            end)
            UserInputService.InputBegan:Connect(function(input, gpe)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    listening = false; currentKey = input.KeyCode; keyLabel.Text = currentKey.Name
                    TweenService:Create(kStroke, TW.Fast, {Color=Theme.Stroke, Transparency=0}):Play()
                elseif not gpe and not listening and currentKey and input.KeyCode == currentKey then
                    if callback then task.spawn(callback) end
                end
            end)
            ripple(el)
            return {Set=function(_,k) currentKey=k; keyLabel.Text=k and k.Name or "None" end, Get=function() return currentKey end, Instance=el}
        end
        
        function Tab:AddColorPicker(cfg)
            local text, default, callback = cfg, Color3.fromRGB(255,255,255), function() end
            if type(cfg) == "table" then text = cfg.Text; default = cfg.Default; callback = cfg.Callback or function() end end
            local color = default; local open = false
            local el = baseElement(42); el.ClipsDescendants = true
            local header = create("TextButton", {BackgroundTransparency=1, Size=UDim2.new(1,0,0,42), Text="", AutoButtonColor=false, Parent=el})
            create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(1,-60,1,0), Position=UDim2.new(0,12,0,0),
                Text=text, TextColor3=Theme.Text, Font=Theme.Font, TextSize=13,
                TextXAlignment=Enum.TextXAlignment.Left, Parent=header})
            local preview = create("Frame", {BackgroundColor3=color, Size=UDim2.new(0,36,0,22),
                Position=UDim2.new(1,-48,0.5,0), AnchorPoint=Vector2.new(0,0.5), Parent=el})
            corner(preview, 6); stroke(preview, Theme.Stroke, 1, 0)
            local holder = create("Frame", {BackgroundTransparency=1, Position=UDim2.new(0,12,0,48),
                Size=UDim2.new(1,-24,0,80), Parent=el})
            create("UIListLayout", {Padding=UDim.new(0,6), Parent=holder})
            local r, g, b = math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)
            local function apply()
                color = Color3.fromRGB(r,g,b); preview.BackgroundColor3 = color
                if callback then task.spawn(callback, color) end
            end
            local function makeChannel(name, getv, setv)
                local row = create("Frame", {BackgroundColor3=Theme.Element, Size=UDim2.new(1,0,0,22), Parent=holder})
                corner(row, 6)
                create("TextLabel", {BackgroundTransparency=1, Size=UDim2.new(0,20,1,0), Position=UDim2.new(0,8,0,0),
                    Text=name, TextColor3=Theme.Accent, Font=Theme.FontBold, TextSize=11, Parent=row})
                local barBack = create("Frame", {BackgroundColor3=Theme.Element, Size=UDim2.new(1,-40,0,4),
                    Position=UDim2.new(0,32,0.5,0), AnchorPoint=Vector2.new(0,0.5), Parent=row})
                corner(barBack, 2)
                local fill = create("Frame", {BackgroundColor3=Theme.Accent, Size=UDim2.new(getv()/255,0,1,0), Parent=barBack})
                corner(fill, 2)
                local dragging = false
                local function upd(x)
                    local rel = math.clamp((x-barBack.AbsolutePosition.X)/barBack.AbsoluteSize.X, 0, 1)
                    setv(math.floor(rel*255)); fill.Size=UDim2.new(rel,0,1,0); apply()
                end
                barBack.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; upd(i.Position.X) end end)
                UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
                UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position.X) end end)
            end
            makeChannel("R", function() return r end, function(v) r=v end)
            makeChannel("G", function() return g end, function(v) g=v end)
            makeChannel("B", function() return b end, function(v) b=v end)
            header.MouseButton1Click:Connect(function()
                open = not open
                TweenService:Create(el, TW.Normal, {Size=UDim2.new(1,0,0,open and 138 or 42)}):Play()
            end)
            ripple(el)
            return {Set=function(_,c) color=c; r,g,b=math.floor(c.R*255),math.floor(c.G*255),math.floor(c.B*255); preview.BackgroundColor3=c; if callback then task.spawn(callback,color) end end, Get=function() return color end, Instance=el}
        end
        
        return Tab
    end
    
    return Window
end

return Library
