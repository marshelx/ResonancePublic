---@diagnostic disable
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GrabEvents = ReplicatedStorage:FindFirstChild("GrabEvents")
local EGL = GrabEvents and GrabEvents:FindFirstChild("ExtendGrabLine")

local Players = game.Players
local plr = Players.LocalPlayer

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()

local SelectedPlayer
local SelectedCommand

local Commands = {
    ["Bring"] = "r.bring",
    ["Kill"] = "r.kill",
    ["FTAP Kick"] = "r.ftapkick",
    ["Kick"] = "r.kick",
    ["Crash"] = "r.crash",
    ["Unload Script"] = "r.unload",
    ["Freeze"] = "r.freeze",
    ["Unfreeze"] = "r.thaw"
}

local function notify(desc, title, soundId)
    Library:Notify({
        Title = title or "Admin Panel",
        Description = desc,
        Time = 5,
        SoundId = soundId or 97643101798871
    })
end

if not EGL then
    notify"Failed to find remote! Couldn't start admin"
    return
end

--|------------------------GUI--------------------------|--
Library.ForceCheckbox = true

----------- Window -----------
local reson = Library:CreateWindow({
    Title = "Admin Panel",
    ToggleKeybind = Enum.KeyCode.RightShift,
    Center = true,
    AutoShow = true,
    EnableSidebarResize = true,
    Icon = 79685990879972,
    IconSize = UDim2.fromOffset(35, 35),
    CornerRadius = 10,
    Compact = true
})

local MainTab = reson:AddTab("Main")
local SelectSection = MainTab:AddLeftGroupbox("Admin Cmds")

SelectSection:AddDivider("Choose your target(s)")

SelectSection:AddDropdown("UsersDD", {
    SpecialType = "Player",
    Default = nil,
    ExcludeLocalPlayer = true,
    Multi = false,
    Searchable = true,
    Text = "Target",
    Callback = function(Value)
        SelectedPlayer = Value
    end
})

SelectSection:AddDivider("Fire your command")

local ValuesTable = {}
for i in Commands do
    table.insert(ValuesTable, i)
end

SelectSection:AddDropdown("CommandsDD", {
    Values = ValuesTable,
    Default = nil,
    ExcludeLocalPlayer = true,
    Multi = false,
    Searchable = true,
    Text = "Command",
    Callback = function(Values)
        SelectedCommand = Commands[Values]
    end
})

SelectSection:AddButton({
    Text = "Fire Command on Selected",
    Func = function()
        if not EGL then 
            notify("Remote not available")
            return 
        end
        if not SelectedPlayer or not SelectedCommand then
            notify("Please select both a player and a command")
            return
        end
        EGL:FireServer(SelectedCommand .. " " .. SelectedPlayer.Name)
    end,
})
