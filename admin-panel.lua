---@diagnostic disable
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local extendGrabLine = ReplicatedStorage:FindFirstChild("GrabEvents")
extendGrabLine = extendGrabLine and extendGrabLine:FindFirstChild("ExtendGrabLine")

if getgenv().RAPUnload then pcall(getgenv().RAPUnload) end

local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local selectedPlayer, selectedCommand, commandArguments
local resonanceUsers, connections = {}, {}

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

local function notify(description, title)
    Library:Notify({
        Title = title or "Admin Panel",
        Description = description,
        Time = 5,
        SoundId = 97643101798871
    })
end

if not extendGrabLine then
    notify("Failed to find ExtendGrabLine; the admin panel cannot start.")
    return
end

Library.ForceCheckbox = true
local window = Library:CreateWindow({
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

local mainTab = window:AddTab("Main", "home")
local settingsTab = window:AddTab("Settings", "settings")
local commandSection = mainTab:AddLeftGroupbox("Admin Commands")
local statusLabel = commandSection:AddLabel("No active Resonance users")
local userDropdown

local function formatPlayer(player)
    if typeof(player) ~= "Instance" then return tostring(player) end
    return player.DisplayName == player.Name and player.Name or player.DisplayName .. " (@" .. player.Name .. ")"
end

local function refreshUsers()
    local users = {}
    for player in pairs(resonanceUsers) do
        if player.Parent == Players then users[#users + 1] = player end
    end
    table.sort(users, function(a, b) return a.Name:lower() < b.Name:lower() end)
    userDropdown:SetValues(users)
    if selectedPlayer and not resonanceUsers[selectedPlayer] then
        selectedPlayer = nil
        userDropdown:SetValue(nil)
    end
    statusLabel:SetText(("Active Resonance users: %d"):format(#users))
end

commandSection:AddDivider("Target")
userDropdown = commandSection:AddDropdown("ResonanceUsers", {
    Values = {},
    Default = nil,
    Multi = false,
    Searchable = true,
    Text = "Resonance User",
    FormatListValue = formatPlayer,
    FormatDisplayValue = formatPlayer,
    EnablePlayerImages = true,
    Callback = function(value) selectedPlayer = value end
})

local commandNames = {}
for name in pairs(Commands) do commandNames[#commandNames + 1] = name end
table.sort(commandNames)

commandSection:AddDivider("Command")
commandSection:AddDropdown("AdminCommand", {
    Values = commandNames,
    Default = nil,
    Multi = false,
    Searchable = true,
    Text = "Command",
    Callback = function(value) selectedCommand = Commands[value] end
})
commandSection:AddInput("CommandArguments", {
    Text = "Arguments",
    Default = "",
    Placeholder = "Optional command arguments",
    Callback = function(value) commandArguments = tostring(value or "") end
})
commandSection:AddButton({
    Text = "Run Command",
    Func = function()
        if not selectedPlayer or not resonanceUsers[selectedPlayer] then
            return notify("Select an active Resonance user.")
        end
        if not selectedCommand then return notify("Select a command.") end
        local payload = selectedCommand .. " " .. selectedPlayer.Name
        if commandArguments and commandArguments ~= "" then payload ..= " " .. commandArguments end
        extendGrabLine:FireServer(payload)
    end
})

local menuSection = settingsTab:AddLeftGroupbox("Menu")
Library.ToggleKeybind = menuSection:AddLabel("Menu Keybind"):AddKeyPicker("AdminMenuKeybind", {
    Text = "Menu Keybind",
    Mode = "Toggle",
    Default = "RightShift",
    NoUI = false
})
menuSection:AddButton({Text = "Unload Admin Panel", Func = function() Library:Unload() end})

connections[#connections + 1] = extendGrabLine.OnClientEvent:Connect(function(player, message)
    if type(message) ~= "string" or message:sub(1, 11) ~= "r.presence " then return end
    local state = string.split(message, " ")[2]
    if state == "online" then
        resonanceUsers[player] = true
    elseif state == "offline" then
        resonanceUsers[player] = nil
    end
    refreshUsers()
end)
connections[#connections + 1] = Players.PlayerRemoving:Connect(function(player)
    resonanceUsers[player] = nil
    refreshUsers()
end)

local unloadPanel
unloadPanel = function() Library:Unload() end
getgenv().RAPUnload = unloadPanel
Library:OnUnload(function()
    for _, connection in ipairs(connections) do connection:Disconnect() end
    table.clear(resonanceUsers)
    if getgenv().RAPUnload == unloadPanel then getgenv().RAPUnload = nil end
end)

extendGrabLine:FireServer("r.presence query " .. tostring(math.random(100000, 999999)))
