local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Morozhka144/GUI2222/main/MoroElite.lua"))()

local Window = Library:CreateWindow({
    Title = "Moro Hub",
    Subtitle = "Doors · Premium",
    ToggleKey = Enum.KeyCode.RightShift,
    TeleportFile = "Doors.lua",
})

Window:AddTabLabel("Main")
local Main = Window:CreateTab({ Name = "Player", Icon = "user" })
local Visuals = Window:CreateTab({ Name = "Visuals", Icon = "eye" })
local Left, Right = Main:Column("left"), Main:Column("right")

local Movement = Left:CreateSection({ Name = "Movement", Icon = "footprints", Collapsible = true })
local speed = Movement:AddToggle({ Name = "Speed Hack", Description = "Faster walking", Tooltip = "Bypasses the speed check", Callback = function(v) print("speed", v) end })
speed:AddKeybind({ Default = Enum.KeyCode.X, Mode = "Toggle" })
speed:AddColorPicker({ Default = Color3.fromRGB(0, 255, 140) })
Movement:AddSlider({ Name = "Walk Speed", Min = 16, Max = 100, Default = 32, Suffix = " st", Callback = print })
Movement:AddToggle({ Name = "Infinite Jump", Icon = "arrow-up", Default = true })
Movement:AddDropdown({ Name = "Mode", Options = { "Legit", "Blatant", "Rage" }, Default = "Legit", Callback = print })
Movement:AddMultiDropdown({ Name = "Targets", Options = { "Rush", "Ambush", "Figure", "Seek", "Halt", "Screech", "Eyes", "Dupe", "Snare" }, Max = 4, Callback = print })

local Misc = Right:CreateSection({ Name = "Utility", Icon = "wrench" })
Misc:AddTextbox({ Name = "Player Name", Placeholder = "type...", Callback = print })
Misc:AddKeybind({ Name = "Panic", Default = Enum.KeyCode.P, Mode = "Hold", Callback = print })
Misc:AddColorPicker({ Name = "ESP Color", Default = Color3.fromRGB(255, 80, 100) })
Misc:AddLabel("Tip: right-click a keybind to change its mode.")
Misc:AddButton({ Name = "Say hi", Icon = "sparkles", Primary = true, Callback = function()
    Window:Notify({ Title = "Hello", Text = "MoroElite is up and running. Everything is smooth now.", Type = "success" })
end })
Misc:AddButton({ Name = "Warn me", Callback = function() Window:Notify({ Title = "Careful", Text = "Entity incoming", Type = "warning" }) end })

local esp = Visuals:CreateSection({ Name = "ESP", Icon = "scan-eye" })
esp:AddToggle({ Name = "Doors ESP" })
esp:AddToggle({ Name = "Item ESP" })

Window:AddSettingsTab()
