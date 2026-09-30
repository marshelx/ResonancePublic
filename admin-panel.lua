---@diagnostic disable
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local ExtendGrabLine = ReplicatedStorage:FindFirstChild("GrabEvents")
ExtendGrabLine = ExtendGrabLine and ExtendGrabLine:FindFirstChild("ExtendGrabLine")

if getgenv().RAPUnload then pcall(getgenv().RAPUnload) end

local Repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(Repo .. "Library.lua"))()
local SelectedPlayer, SelectedCommand, CommandArguments
local ResonanceUsers = {}
local Connections = {}

local Commands = {
    ["Bring"] = "r.bring",
    ["Kill"] = "r.kill",
    ["FTAP Kick"] = "r.ftapkick",
    ["Kick"] = "r.kick",
    ["Crash"] = "r.crash",
    ["Freeze"] = "r.freeze",
    ["Unfreeze"] = "r.thaw",
    ["Rejoin"] = "r.rejoin",
    ["Unload Script"] = "r.unload",
    ["Immunity On"] = "r.immunity on",
    ["Immunity Off"] = "r.immunity off",
    ["Notification"] = "r.notify",
    ["Set FPS"] = "r.setfps",
    ["Set Toggle"] = "r.toggle",
    ["Disable Toggle"] = "r.disable",
    ["Ear Destroy"] = "r.earsdestroy",
    ["Stop Ear Destroy"] = "r.unearsdestroy"
}

local function Notify(Description, Title)
    Library:Notify({
        Title = Title or "Admin Panel",
        Description = Description,
        Time = 5,
        SoundId = 97643101798871
    })
end

if not ExtendGrabLine then
    Notify("Failed to find ExtendGrabLine; the admin panel cannot start.")
    return
end

Library.ForceCheckbox = true

local Window = Library:CreateWindow({
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

local MainTab = Window:AddTab("Main", "layout-grid")
local SettingsTab = Window:AddTab("Settings", "settings")
local CommandSection = MainTab:AddLeftGroupbox("Admin Commands")
local StatusLabel = CommandSection:AddLabel("No active Resonance users")
local UserDropdown

local function FormatPlayer(Player)
    if typeof(Player) ~= "Instance" then return tostring(Player) end

    return if Player.DisplayName == Player.Name then Player.Name else Player.DisplayName .. " (@" .. Player.Name .. ")"
end

local function RefreshUsers()
    local Users = {}

    for Player in pairs(ResonanceUsers) do
        if Player.Parent == Players then
            Users[#Users + 1] = Player
        end
    end

    table.sort(Users, function(A, B)
        return A.Name:lower() < B.Name:lower()
    end)

    UserDropdown:SetValues(Users)

    if SelectedPlayer and not ResonanceUsers[SelectedPlayer] then
        SelectedPlayer = nil
        UserDropdown:SetValue(nil)
    end

    StatusLabel:SetText(("Active Resonance users: %d"):format(#Users))
end

CommandSection:AddDivider("Target")
UserDropdown = CommandSection:AddDropdown("ResonanceUsers", {
    Values = {},
    Default = nil,
    Multi = false,
    Searchable = true,
    Text = "Resonance User",
    FormatListValue = FormatPlayer,
    FormatDisplayValue = FormatPlayer,
    EnablePlayerImages = true,
    Callback = function(Value) SelectedPlayer = Value end
})

local CommandNames = {}

for Name in pairs(Commands) do
    CommandNames[#CommandNames + 1] = Name
end

table.sort(CommandNames)

CommandSection:AddDivider("Command")
CommandSection:AddDropdown("AdminCommand", {
    Values = CommandNames,
    Default = nil,
    Multi = false,
    Searchable = true,
    Text = "Command",
    Callback = function(Value) SelectedCommand = Commands[Value] end
})

CommandSection:AddInput("CommandArguments", {
    Text = "Arguments",
    Default = "",
    Placeholder = "Optional command arguments",
    Callback = function(Value) CommandArguments = tostring(Value or "") end
})

CommandSection:AddButton({
    Text = "Run Command",
    Func = function()
        if not SelectedPlayer or not ResonanceUsers[SelectedPlayer] then
            return Notify("Select an active Resonance user.")
        end

        if not SelectedCommand then return Notify("Select a command.") end

        local Payload = SelectedCommand .. " " .. SelectedPlayer.Name
        if CommandArguments and CommandArguments ~= "" then
            Payload ..= " " .. CommandArguments
        end

        ExtendGrabLine:FireServer(Payload)
    end
})

local MenuSection = SettingsTab:AddLeftGroupbox("Menu")

MenuSection:AddLabel("Menu Keybind"):AddKeyPicker("AMenuKeybind", {
    Text = "Menu Keybind",
    Mode = "Toggle",
    Default = "RightShift",
    NoUI = false
})
Library.ToggleKeybind = Library.Options.AMenuKeybind

MenuSection:AddButton({
    Text = "Unload Admin Panel",
    Func = function()
        Library:Unload()
    end
})

Connections[#Connections + 1] = ExtendGrabLine.OnClientEvent:Connect(function(Player, Message)
    if type(Message) ~= "string" or Message:sub(1, 11) ~= "r.presence " then return end

    local State = string.split(Message, " ")[2]
    if State == "online" then
        ResonanceUsers[Player] = true
    elseif State == "offline" then
        ResonanceUsers[Player] = nil
    end

    RefreshUsers()
end)

Connections[#Connections + 1] = Players.PlayerRemoving:Connect(function(Player)
    ResonanceUsers[Player] = nil
    RefreshUsers()
end)

local PresenceT

local function UnloadPanel()
    Library:Unload()
end

getgenv().RAPUnload = UnloadPanel

Library:OnUnload(function()
    if PresenceT then task.cancel(PresenceT) end

    for _, Connection in ipairs(Connections) do
        Connection:Disconnect()
    end

    table.clear(ResonanceUsers)

    if getgenv().RAPUnload == UnloadPanel then
        getgenv().RAPUnload = nil
    end
end)

PresenceT = task.spawn(function()
    while not Library.Unloaded do
        ExtendGrabLine:FireServer("r.presence query " .. tostring(math.random(100000, 999999)))
        task.wait(2)
    end
end)
