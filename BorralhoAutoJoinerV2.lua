--[[
    BORRALHO AUTO JOINER V2
    Compact UI (170px wide)
    Tabs: Main | Logs | Settings
    Features: Auto Join, Auto Spam Join, Min%, Spam Duration, API Key ready

    Loadstring:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ideBob/Borralho-Auto-Joiner-V2/main/BorralhoAutoJoinerV2.lua"))()
]]

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local PLACE_ID = 109983668079237
local API_KEY = "brj_sk_client_un2kr85nr75122ti"

-- State
local isUIVisible = true
local isAutoJoinEnabled = false
local isSpamJoinEnabled = false
local serverHopConnection = nil
local spamConnection = nil
local currentTab = "Main"
local logs = {}
local maxLogs = 60

local minPercent = 10          -- default Min%
local spamDuration = 0.1      -- default spam join delay

--// UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BorralhoAutoJoiner"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 170, 0, 320)
mainFrame.Position = UDim2.new(0.5, -85, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(55, 55, 65)
mainStroke.Thickness = 1.2
mainStroke.Parent = mainFrame

-- Logo / Title area
local logoFrame = Instance.new("Frame")
logoFrame.Size = UDim2.new(1, 0, 0, 38)
logoFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
logoFrame.BorderSizePixel = 0
logoFrame.Parent = mainFrame

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0, 10)
logoCorner.Parent = logoFrame

local logoFix = Instance.new("Frame")
logoFix.Size = UDim2.new(1, 0, 0, 12)
logoFix.Position = UDim2.new(0, 0, 1, -12)
logoFix.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
logoFix.BorderSizePixel = 0
logoFix.Parent = logoFrame

local logoLabel = Instance.new("TextLabel")
logoLabel.Size = UDim2.new(1, 0, 1, 0)
logoLabel.BackgroundTransparency = 1
logoLabel.Text = "⚡ BORRALHO"
logoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
logoLabel.TextSize = 15
logoLabel.Font = Enum.Font.GothamBold
logoLabel.Parent = logoFrame

-- Tabs
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -10, 0, 26)
tabContainer.Position = UDim2.new(0, 5, 0, 42)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local function createTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Tab"
    btn.Size = UDim2.new(1/3, -3, 1, 0)
    btn.Position = UDim2.new(order * (1/3), order * 1.5, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(170, 170, 180)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamMedium
    btn.AutoButtonColor = false
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn
    btn.Parent = tabContainer
    return btn
end

local mainTabBtn = createTab("Main", 0)
local logsTabBtn = createTab("Logs", 1)
local settingsTabBtn = createTab("Settings", 2)

-- Content
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -10, 1, -80)
contentFrame.Position = UDim2.new(0, 5, 0, 72)
contentFrame.BackgroundTransparency = 1
contentFrame.Parent = mainFrame

local mainContent = Instance.new("Frame")
mainContent.Size = UDim2.new(1, 0, 1, 0)
mainContent.BackgroundTransparency = 1
mainContent.Parent = contentFrame

local logsContent = Instance.new("Frame")
logsContent.Size = UDim2.new(1, 0, 1, 0)
logsContent.BackgroundTransparency = 1
logsContent.Visible = false
logsContent.Parent = contentFrame

local settingsContent = Instance.new("Frame")
settingsContent.Size = UDim2.new(1, 0, 1, 0)
settingsContent.BackgroundTransparency = 1
settingsContent.Visible = false
settingsContent.Parent = contentFrame

-- ===== MAIN TAB =====
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 18)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(150, 150, 160)
statusLabel.TextSize = 11
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainContent

local autoJoinBtn = Instance.new("TextButton")
autoJoinBtn.Size = UDim2.new(1, 0, 0, 36)
autoJoinBtn.Position = UDim2.new(0, 0, 0, 28)
autoJoinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
autoJoinBtn.Text = "Auto Join"
autoJoinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoJoinBtn.TextSize = 13
autoJoinBtn.Font = Enum.Font.GothamBold
autoJoinBtn.AutoButtonColor = false
local ajc = Instance.new("UICorner")
ajc.CornerRadius = UDim.new(0, 7)
ajc.Parent = autoJoinBtn
autoJoinBtn.Parent = mainContent

local autoSpamBtn = Instance.new("TextButton")
autoSpamBtn.Size = UDim2.new(1, 0, 0, 36)
autoSpamBtn.Position = UDim2.new(0, 0, 0, 72)
autoSpamBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
autoSpamBtn.Text = "Auto Spam Join"
autoSpamBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
autoSpamBtn.TextSize = 13
autoSpamBtn.Font = Enum.Font.GothamBold
autoSpamBtn.AutoButtonColor = false
local asjc = Instance.new("UICorner")
asjc.CornerRadius = UDim.new(0, 7)
asjc.Parent = autoSpamBtn
autoSpamBtn.Parent = mainContent

local tipLabel = Instance.new("TextLabel")
tipLabel.Size = UDim2.new(1, 0, 0, 50)
tipLabel.Position = UDim2.new(0, 0, 0, 120)
tipLabel.BackgroundTransparency = 1
tipLabel.Text = "RightShift = Toggle UI\nJ = Auto Join\nDrag top to move"
tipLabel.TextColor3 = Color3.fromRGB(100, 100, 110)
tipLabel.TextSize = 10
tipLabel.Font = Enum.Font.Gotham
tipLabel.TextXAlignment = Enum.TextXAlignment.Left
tipLabel.TextYAlignment = Enum.TextYAlignment.Top
tipLabel.Parent = mainContent

-- ===== LOGS TAB =====
local logsScroll = Instance.new("ScrollingFrame")
logsScroll.Size = UDim2.new(1, 0, 1, -30)
logsScroll.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
logsScroll.BorderSizePixel = 0
logsScroll.ScrollBarThickness = 3
logsScroll.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 80)
logsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
logsScroll.Parent = logsContent

local logsCorner = Instance.new("UICorner")
logsCorner.CornerRadius = UDim.new(0, 6)
logsCorner.Parent = logsScroll

local logsLayout = Instance.new("UIListLayout")
logsLayout.SortOrder = Enum.SortOrder.LayoutOrder
logsLayout.Padding = UDim.new(0, 2)
logsLayout.Parent = logsScroll

local clearLogsBtn = Instance.new("TextButton")
clearLogsBtn.Size = UDim2.new(1, 0, 0, 24)
clearLogsBtn.Position = UDim2.new(0, 0, 1, -24)
clearLogsBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 35)
clearLogsBtn.Text = "Clear Logs"
clearLogsBtn.TextColor3 = Color3.fromRGB(210, 150, 150)
clearLogsBtn.TextSize = 11
clearLogsBtn.Font = Enum.Font.GothamMedium
local clc = Instance.new("UICorner")
clc.CornerRadius = UDim.new(0, 6)
clc.Parent = clearLogsBtn
clearLogsBtn.Parent = logsContent

-- ===== SETTINGS TAB =====
local minLabel = Instance.new("TextLabel")
minLabel.Size = UDim2.new(1, 0, 0, 16)
minLabel.BackgroundTransparency = 1
minLabel.Text = "Min%"
minLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
minLabel.TextSize = 11
minLabel.Font = Enum.Font.GothamMedium
minLabel.TextXAlignment = Enum.TextXAlignment.Left
minLabel.Parent = settingsContent

local minBox = Instance.new("TextBox")
minBox.Size = UDim2.new(1, 0, 0, 28)
minBox.Position = UDim2.new(0, 0, 0, 18)
minBox.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
minBox.Text = ""
minBox.PlaceholderText = "Enter Min%"
minBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
minBox.TextColor3 = Color3.fromRGB(240, 240, 245)
minBox.TextSize = 13
minBox.Font = Enum.Font.Gotham
minBox.ClearTextOnFocus = false
local mbc = Instance.new("UICorner")
mbc.CornerRadius = UDim.new(0, 6)
mbc.Parent = minBox
minBox.Parent = settingsContent

local spamLabel = Instance.new("TextLabel")
spamLabel.Size = UDim2.new(1, 0, 0, 16)
spamLabel.Position = UDim2.new(0, 0, 0, 56)
spamLabel.BackgroundTransparency = 1
spamLabel.Text = "Spam Join Duration"
spamLabel.TextColor3 = Color3.fromRGB(180, 180, 190)
spamLabel.TextSize = 11
spamLabel.Font = Enum.Font.GothamMedium
spamLabel.TextXAlignment = Enum.TextXAlignment.Left
spamLabel.Parent = settingsContent

local spamBox = Instance.new("TextBox")
spamBox.Size = UDim2.new(1, 0, 0, 28)
spamBox.Position = UDim2.new(0, 0, 0, 74)
spamBox.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
spamBox.Text = "0.1"
spamBox.PlaceholderText = "0.1"
spamBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 110)
spamBox.TextColor3 = Color3.fromRGB(240, 240, 245)
spamBox.TextSize = 13
spamBox.Font = Enum.Font.Gotham
spamBox.ClearTextOnFocus = false
local sbc = Instance.new("UICorner")
sbc.CornerRadius = UDim.new(0, 6)
sbc.Parent = spamBox
spamBox.Parent = settingsContent

local saveBtn = Instance.new("TextButton")
saveBtn.Size = UDim2.new(1, 0, 0, 30)
saveBtn.Position = UDim2.new(0, 0, 0, 115)
saveBtn.BackgroundColor3 = Color3.fromRGB(35, 70, 50)
saveBtn.Text = "Save Settings"
saveBtn.TextColor3 = Color3.fromRGB(200, 255, 210)
saveBtn.TextSize = 12
saveBtn.Font = Enum.Font.GothamBold
saveBtn.AutoButtonColor = false
local svc = Instance.new("UICorner")
svc.CornerRadius = UDim.new(0, 7)
svc.Parent = saveBtn
saveBtn.Parent = settingsContent

local apiLabel = Instance.new("TextLabel")
apiLabel.Size = UDim2.new(1, 0, 0, 30)
apiLabel.Position = UDim2.new(0, 0, 0, 155)
apiLabel.BackgroundTransparency = 1
apiLabel.Text = "API Key loaded\n(ready for WebSocket)"
apiLabel.TextColor3 = Color3.fromRGB(100, 140, 100)
apiLabel.TextSize = 10
apiLabel.Font = Enum.Font.Gotham
apiLabel.TextXAlignment = Enum.TextXAlignment.Left
apiLabel.TextYAlignment = Enum.TextYAlignment.Top
apiLabel.Parent = settingsContent

-- Floating toggle button
local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 38, 0, 38)
toggleButton.Position = UDim2.new(1, -50, 0, 18)
toggleButton.AnchorPoint = Vector2.new(1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.AutoButtonColor = false
toggleButton.Parent = screenGui

local rgbCorner = Instance.new("UICorner")
rgbCorner.CornerRadius = UDim.new(1, 0)
rgbCorner.Parent = toggleButton

local rgbGradient = Instance.new("UIGradient")
rgbGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 50, 50)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(50, 255, 100)),
    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(70, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 50, 50))
})
rgbGradient.Rotation = 45
rgbGradient.Parent = toggleButton

local toggleIcon = Instance.new("TextLabel")
toggleIcon.Size = UDim2.new(1, 0, 1, 0)
toggleIcon.BackgroundTransparency = 1
toggleIcon.Text = "≡"
toggleIcon.TextColor3 = Color3.fromRGB(15, 15, 20)
toggleIcon.TextSize = 20
toggleIcon.Font = Enum.Font.GothamBold
toggleIcon.Parent = toggleButton

--// Functions
local function addLog(text, color)
    color = color or Color3.fromRGB(190, 190, 200)
    local timeStr = os.date("%H:%M:%S")
    local entry = Instance.new("TextLabel")
    entry.Size = UDim2.new(1, -6, 0, 15)
    entry.BackgroundTransparency = 1
    entry.Text = "[" .. timeStr .. "] " .. text
    entry.TextColor3 = color
    entry.TextSize = 10
    entry.Font = Enum.Font.Gotham
    entry.TextXAlignment = Enum.TextXAlignment.Left
    entry.TextTruncate = Enum.TextTruncate.AtEnd
    entry.Parent = logsScroll

    table.insert(logs, entry)
    if #logs > maxLogs then
        local old = table.remove(logs, 1)
        if old then old:Destroy() end
    end

    logsScroll.CanvasSize = UDim2.new(0, 0, 0, logsLayout.AbsoluteContentSize.Y + 6)
    logsScroll.CanvasPosition = Vector2.new(0, logsScroll.CanvasSize.Y.Offset)
end

local function setTab(tab)
    currentTab = tab
    mainContent.Visible = (tab == "Main")
    logsContent.Visible = (tab == "Logs")
    settingsContent.Visible = (tab == "Settings")

    mainTabBtn.BackgroundColor3 = tab == "Main" and Color3.fromRGB(50, 50, 65) or Color3.fromRGB(32, 32, 40)
    mainTabBtn.TextColor3 = tab == "Main" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 180)

    logsTabBtn.BackgroundColor3 = tab == "Logs" and Color3.fromRGB(50, 50, 65) or Color3.fromRGB(32, 32, 40)
    logsTabBtn.TextColor3 = tab == "Logs" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 180)

    settingsTabBtn.BackgroundColor3 = tab == "Settings" and Color3.fromRGB(50, 50, 65) or Color3.fromRGB(32, 32, 40)
    settingsTabBtn.TextColor3 = tab == "Settings" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(170, 170, 180)
end

local function updateStatus()
    if isSpamJoinEnabled then
        statusLabel.Text = "Status: Spam Join ON"
    elseif isAutoJoinEnabled then
        statusLabel.Text = "Status: Auto Join ON"
    else
        statusLabel.Text = "Status: Idle"
    end
end

local function forceServerHop()
    local servers = {}
    local success, err = pcall(function()
        local url = "https://games.roblox.com/v1/games/" .. PLACE_ID .. "/servers/Public?sortOrder=Asc&limit=100"
        local response = game:HttpGet(url)
        local data = HttpService:JSONDecode(response)
        if data and data.data then
            for _, v in pairs(data.data) do
                if v.playing and v.maxPlayers and v.playing < v.maxPlayers then
                    table.insert(servers, {id = v.id, playing = v.playing, max = v.maxPlayers})
                end
            end
        end
    end)

    if not success then
        addLog("HTTP error", Color3.fromRGB(255, 90, 90))
        return
    end

    if #servers > 0 then
        local chosen = servers[math.random(1, #servers)]
        addLog("Hop → " .. string.sub(chosen.id, 1, 7) .. "..", Color3.fromRGB(110, 190, 255))
        TeleportService:TeleportToPlaceInstance(PLACE_ID, chosen.id, LocalPlayer)
    else
        addLog("No free servers", Color3.fromRGB(255, 170, 70))
    end
end

local function toggleAutoJoin()
    if isSpamJoinEnabled then return end -- prevent both at once

    isAutoJoinEnabled = not isAutoJoinEnabled

    if isAutoJoinEnabled then
        autoJoinBtn.Text = "Auto Join: ON"
        autoJoinBtn.BackgroundColor3 = Color3.fromRGB(25, 110, 55)
        addLog("Auto Join ENABLED", Color3.fromRGB(70, 210, 110))

        if serverHopConnection then serverHopConnection:Disconnect() end
        serverHopConnection = RunService.Heartbeat:Connect(function()
            forceServerHop()
            task.wait(1.2)
        end)
    else
        autoJoinBtn.Text = "Auto Join"
        autoJoinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        addLog("Auto Join DISABLED", Color3.fromRGB(210, 140, 70))
        if serverHopConnection then
            serverHopConnection:Disconnect()
            serverHopConnection = nil
        end
    end
    updateStatus()
end

local function toggleSpamJoin()
    if isAutoJoinEnabled then return end

    isSpamJoinEnabled = not isSpamJoinEnabled

    if isSpamJoinEnabled then
        autoSpamBtn.Text = "Spam Join: ON"
        autoSpamBtn.BackgroundColor3 = Color3.fromRGB(120, 50, 30)
        addLog("Spam Join ENABLED (" .. spamDuration .. "s)", Color3.fromRGB(255, 140, 80))

        if spamConnection then spamConnection:Disconnect() end
        spamConnection = RunService.Heartbeat:Connect(function()
            forceServerHop()
            task.wait(spamDuration)
        end)
    else
        autoSpamBtn.Text = "Auto Spam Join"
        autoSpamBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        addLog("Spam Join DISABLED", Color3.fromRGB(210, 140, 70))
        if spamConnection then
            spamConnection:Disconnect()
            spamConnection = nil
        end
    end
    updateStatus()
end

-- Save settings
saveBtn.MouseButton1Click:Connect(function()
    local minVal = tonumber(minBox.Text)
    if minVal and minVal > 0 then
        minPercent = minVal
        addLog("Min% set to " .. minPercent, Color3.fromRGB(160, 220, 120))
    end

    local dur = tonumber(spamBox.Text)
    if dur and dur > 0 then
        spamDuration = dur
        addLog("Spam duration set to " .. spamDuration, Color3.fromRGB(160, 220, 120))
    end

    addLog("Settings saved", Color3.fromRGB(100, 200, 140))
end)

clearLogsBtn.MouseButton1Click:Connect(function()
    for _, v in ipairs(logs) do v:Destroy() end
    logs = {}
    logsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    addLog("Logs cleared", Color3.fromRGB(150, 150, 160))
end)

mainTabBtn.MouseButton1Click:Connect(function() setTab("Main") end)
logsTabBtn.MouseButton1Click:Connect(function() setTab("Logs") end)
settingsTabBtn.MouseButton1Click:Connect(function() setTab("Settings") end)
autoJoinBtn.MouseButton1Click:Connect(toggleAutoJoin)
autoSpamBtn.MouseButton1Click:Connect(toggleSpamJoin)

-- Dragging
local dragging = false
local dragStart, startPos

logoFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Toggle button drag + click
local toggleDragging = false
local tDragStart, tStartPos

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleDragging = true
        tDragStart = input.Position
        tStartPos = toggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then toggleDragging = false end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if toggleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - tDragStart
        toggleButton.Position = UDim2.new(tStartPos.X.Scale, tStartPos.X.Offset + delta.X, tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y)
    end
end)

toggleButton.MouseButton1Click:Connect(function()
    isUIVisible = not isUIVisible
    mainFrame.Visible = isUIVisible
    addLog(isUIVisible and "UI shown" or "UI hidden", Color3.fromRGB(130, 130, 150))
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        isUIVisible = not isUIVisible
        mainFrame.Visible = isUIVisible
    elseif input.KeyCode == Enum.KeyCode.J then
        toggleAutoJoin()
    end
end)

-- RGB animation
task.spawn(function()
    while true do
        for i = 0, 1, 0.02 do
            rgbGradient.Offset = Vector2.new(i, 0)
            task.wait(0.025)
        end
    end
end)

-- Init
setTab("Main")
updateStatus()
addLog("Borralho loaded (170px)", Color3.fromRGB(90, 210, 150))
addLog("API Key ready", Color3.fromRGB(130, 180, 130))
print("[Borralho] Compact UI loaded")
