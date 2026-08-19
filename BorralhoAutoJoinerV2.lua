--[[
    BORRALHO AUTO JOINER V2 (Upgraded)
    Features:
    - Refined dark UI with tabs (Main / Logs / Min$)
    - Fully draggable main frame + floating RGB button
    - AutoJoin server hop
    - Logs tab with hop history
    - Min$ tab: set minimum value filter (10M, 20M ... 1B+)
    - Priority high-value Brainrots list
    - Scan button (placeholder for private API)
    - Keybinds: RightShift = toggle UI | J = toggle AutoJoin

    Loadstring:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ideBob/Borralho-Auto-Joiner-V2/main/BorralhoAutoJoinerV2.lua"))()
]]

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local AUTOJOIN_DELAY = 1.2
local PLACE_ID = 109983668079237

local PRIORITY_BRAINROTS = {
    "Strawberry Elephant", "Meowl", "Headless Horseman", "John Pork", "Spyder Elephant", "Skibidi Toilet",
    "La Vacca Saturno Saturnita", "Bisonte Giuppitere", "Karkerkar Kurkur", "Los Matteos",
    "Trenostruzzo Turbo 4000", "Jackorilla", "Sammyni Spyderini", "Blackhole Goat",
    "Los Spyderinis", "La Cucaracha", "Los Tralaleritos", "Los Tortus", "Vulturino Skeletono",
    "Nooo My Hotspot", "Los Jobcitos", "La Sahur Combinasion", "Chicleteira Bicicleteira",
    "Los Quesadillas", "Los Chicleteiras", "Los Burritos", "Swag Soda", "Las Sis"
}

-- State
local isUIVisible = true
local isAutoJoinEnabled = false
local serverHopConnection = nil
local currentTab = "Main"
local logs = {}
local maxLogs = 80
local minValue = 10000000 -- default 10M
local minValueLabel = "10M"

local MIN_OPTIONS = {
    {label = "10M", value = 10000000},
    {label = "20M", value = 20000000},
    {label = "30M", value = 30000000},
    {label = "40M", value = 40000000},
    {label = "50M", value = 50000000},
    {label = "60M", value = 60000000},
    {label = "70M", value = 70000000},
    {label = "80M", value = 80000000},
    {label = "90M", value = 90000000},
    {label = "100M", value = 100000000},
    {label = "150M", value = 150000000},
    {label = "200M", value = 200000000},
    {label = "300M", value = 300000000},
    {label = "500M", value = 500000000},
    {label = "750M", value = 750000000},
    {label = "1B", value = 1000000000},
}

--// UI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BorralhoAutoJoiner"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 400, 0, 360)
mainFrame.Position = UDim2.new(0.5, -200, 0.5, -180)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
mainFrame.BorderSizePixel = 0
mainFrame.ClipsDescendants = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(60, 60, 70)
mainStroke.Thickness = 1.5
mainStroke.Parent = mainFrame

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 42)
titleBar.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
titleBar.BorderSizePixel = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 14)
titleCorner.Parent = titleBar

local titleFix = Instance.new("Frame")
titleFix.Size = UDim2.new(1, 0, 0, 20)
titleFix.Position = UDim2.new(0, 0, 1, -20)
titleFix.BackgroundColor3 = Color3.fromRGB(28, 28, 34)
titleFix.BorderSizePixel = 0
titleFix.Parent = titleBar

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "BORRALHO JOINER V2"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Tabs (3 tabs)
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 32)
tabContainer.Position = UDim2.new(0, 10, 0, 50)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local function createTabButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Tab"
    btn.Size = UDim2.new(1/3, -4, 1, 0)
    btn.Position = UDim2.new(order * (1/3), order * 2, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 190)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.AutoButtonColor = false
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn
    btn.Parent = tabContainer
    return btn
end

local mainTabBtn = createTabButton("Main", 0)
local logsTabBtn = createTabButton("Logs", 1)
local minTabBtn = createTabButton("Min$", 2)

-- Content frames
local contentFrame = Instance.new("Frame")
contentFrame.Size = UDim2.new(1, -20, 1, -100)
contentFrame.Position = UDim2.new(0, 10, 0, 90)
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

local minContent = Instance.new("Frame")
minContent.Size = UDim2.new(1, 0, 1, 0)
minContent.BackgroundTransparency = 1
minContent.Visible = false
minContent.Parent = contentFrame

-- Main tab
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 22)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle | Min$: 10M"
statusLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainContent

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 40)
infoLabel.Position = UDim2.new(0, 0, 0, 26)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Priority Brainrots: " .. #PRIORITY_BRAINROTS .. "\nReal rare scanning needs private API"
infoLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
infoLabel.TextSize = 12
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = mainContent

local autoJoinButton = Instance.new("TextButton")
autoJoinButton.Size = UDim2.new(1, 0, 0, 42)
autoJoinButton.Position = UDim2.new(0, 0, 0, 78)
autoJoinButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
autoJoinButton.Text = "AUTOJOIN: OFF"
autoJoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoJoinButton.TextSize = 15
autoJoinButton.Font = Enum.Font.GothamBold
autoJoinButton.AutoButtonColor = false
local ajCorner = Instance.new("UICorner")
ajCorner.CornerRadius = UDim.new(0, 9)
ajCorner.Parent = autoJoinButton
autoJoinButton.Parent = mainContent

local scanButton = Instance.new("TextButton")
scanButton.Size = UDim2.new(1, 0, 0, 42)
scanButton.Position = UDim2.new(0, 0, 0, 130)
scanButton.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
scanButton.Text = "SCAN SERVERS (needs API)"
scanButton.TextColor3 = Color3.fromRGB(180, 200, 255)
scanButton.TextSize = 14
scanButton.Font = Enum.Font.GothamMedium
scanButton.AutoButtonColor = false
local scCorner = Instance.new("UICorner")
scCorner.CornerRadius = UDim.new(0, 9)
scCorner.Parent = scanButton
scanButton.Parent = mainContent

local tipLabel = Instance.new("TextLabel")
tipLabel.Size = UDim2.new(1, 0, 0, 50)
tipLabel.Position = UDim2.new(0, 0, 0, 185)
tipLabel.BackgroundTransparency = 1
tipLabel.Text = "RightShift = Toggle UI\nJ = Toggle AutoJoin\nDrag title bar to move"
tipLabel.TextColor3 = Color3.fromRGB(100, 100, 110)
tipLabel.TextSize = 12
tipLabel.Font = Enum.Font.Gotham
tipLabel.TextXAlignment = Enum.TextXAlignment.Left
tipLabel.TextYAlignment = Enum.TextYAlignment.Top
tipLabel.Parent = mainContent

-- Logs tab
local logsScroll = Instance.new("ScrollingFrame")
logsScroll.Size = UDim2.new(1, 0, 1, -36)
logsScroll.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
logsScroll.BorderSizePixel = 0
logsScroll.ScrollBarThickness = 4
logsScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
logsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
logsScroll.Parent = logsContent

local logsCorner = Instance.new("UICorner")
logsCorner.CornerRadius = UDim.new(0, 8)
logsCorner.Parent = logsScroll

local logsLayout = Instance.new("UIListLayout")
logsLayout.SortOrder = Enum.SortOrder.LayoutOrder
logsLayout.Padding = UDim.new(0, 4)
logsLayout.Parent = logsScroll

local clearLogsBtn = Instance.new("TextButton")
clearLogsBtn.Size = UDim2.new(1, 0, 0, 28)
clearLogsBtn.Position = UDim2.new(0, 0, 1, -28)
clearLogsBtn.BackgroundColor3 = Color3.fromRGB(50, 40, 40)
clearLogsBtn.Text = "Clear Logs"
clearLogsBtn.TextColor3 = Color3.fromRGB(220, 160, 160)
clearLogsBtn.TextSize = 13
clearLogsBtn.Font = Enum.Font.GothamMedium
local clCorner = Instance.new("UICorner")
clCorner.CornerRadius = UDim.new(0, 7)
clCorner.Parent = clearLogsBtn
clearLogsBtn.Parent = logsContent

-- Min$ tab
local minHeader = Instance.new("TextLabel")
minHeader.Size = UDim2.new(1, 0, 0, 24)
minHeader.BackgroundTransparency = 1
minHeader.Text = "Current Min$: 10M"
minHeader.TextColor3 = Color3.fromRGB(220, 220, 230)
minHeader.TextSize = 15
minHeader.Font = Enum.Font.GothamBold
minHeader.TextXAlignment = Enum.TextXAlignment.Left
minHeader.Parent = minContent

local minDesc = Instance.new("TextLabel")
minDesc.Size = UDim2.new(1, 0, 0, 36)
minDesc.Position = UDim2.new(0, 0, 0, 28)
minDesc.BackgroundTransparency = 1
minDesc.Text = "Only care about Brainrots worth at least this much.\nUsed when scanning via private API."
minDesc.TextColor3 = Color3.fromRGB(130, 130, 140)
minDesc.TextSize = 12
minDesc.Font = Enum.Font.Gotham
minDesc.TextXAlignment = Enum.TextXAlignment.Left
minDesc.TextYAlignment = Enum.TextYAlignment.Top
minDesc.Parent = minContent

local minScroll = Instance.new("ScrollingFrame")
minScroll.Size = UDim2.new(1, 0, 1, -75)
minScroll.Position = UDim2.new(0, 0, 0, 70)
minScroll.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
minScroll.BorderSizePixel = 0
minScroll.ScrollBarThickness = 4
minScroll.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
minScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
minScroll.Parent = minContent

local minScrollCorner = Instance.new("UICorner")
minScrollCorner.CornerRadius = UDim.new(0, 8)
minScrollCorner.Parent = minScroll

local minLayout = Instance.new("UIGridLayout")
minLayout.CellSize = UDim2.new(0, 85, 0, 34)
minLayout.CellPadding = UDim2.new(0, 6, 0, 6)
minLayout.SortOrder = Enum.SortOrder.LayoutOrder
minLayout.Parent = minScroll

local minPadding = Instance.new("UIPadding")
minPadding.PaddingTop = UDim.new(0, 8)
minPadding.PaddingLeft = UDim.new(0, 8)
minPadding.Parent = minScroll

-- Floating toggle
local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 46, 0, 46)
toggleButton.Position = UDim2.new(1, -60, 0, 20)
toggleButton.AnchorPoint = Vector2.new(1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.AutoButtonColor = false
toggleButton.Parent = screenGui

local rgbCorner = Instance.new("UICorner")
rgbCorner.CornerRadius = UDim.new(1, 0)
rgbCorner.Parent = toggleButton

local rgbGradient = Instance.new("UIGradient")
rgbGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 60, 60)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(60, 255, 120)),
    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(80, 120, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 60, 60))
})
rgbGradient.Rotation = 45
rgbGradient.Parent = toggleButton

local toggleIcon = Instance.new("TextLabel")
toggleIcon.Size = UDim2.new(1, 0, 1, 0)
toggleIcon.BackgroundTransparency = 1
toggleIcon.Text = "≡"
toggleIcon.TextColor3 = Color3.fromRGB(20, 20, 25)
toggleIcon.TextSize = 26
toggleIcon.Font = Enum.Font.GothamBold
toggleIcon.Parent = toggleButton

local toggleShadow = Instance.new("UIStroke")
toggleShadow.Color = Color3.fromRGB(0, 0, 0)
toggleShadow.Thickness = 2
toggleShadow.Parent = toggleButton

--// Functions
local function updateStatus()
    local joinState = isAutoJoinEnabled and "AutoJoin Active" or "Idle"
    statusLabel.Text = "Status: " .. joinState .. " | Min$: " .. minValueLabel
    minHeader.Text = "Current Min$: " .. minValueLabel
end

local function addLog(text, color)
    color = color or Color3.fromRGB(200, 200, 210)
    local timeStr = os.date("%H:%M:%S")
    local entry = Instance.new("TextLabel")
    entry.Size = UDim2.new(1, -8, 0, 18)
    entry.BackgroundTransparency = 1
    entry.Text = "[" .. timeStr .. "] " .. text
    entry.TextColor3 = color
    entry.TextSize = 12
    entry.Font = Enum.Font.Gotham
    entry.TextXAlignment = Enum.TextXAlignment.Left
    entry.TextTruncate = Enum.TextTruncate.AtEnd
    entry.Parent = logsScroll

    table.insert(logs, entry)
    if #logs > maxLogs then
        local old = table.remove(logs, 1)
        if old then old:Destroy() end
    end

    logsScroll.CanvasSize = UDim2.new(0, 0, 0, logsLayout.AbsoluteContentSize.Y + 8)
    logsScroll.CanvasPosition = Vector2.new(0, logsScroll.CanvasSize.Y.Offset)
end

local function setTab(tab)
    currentTab = tab
    mainContent.Visible = (tab == "Main")
    logsContent.Visible = (tab == "Logs")
    minContent.Visible = (tab == "Min$")

    mainTabBtn.BackgroundColor3 = tab == "Main" and Color3.fromRGB(55, 55, 70) or Color3.fromRGB(35, 35, 42)
    mainTabBtn.TextColor3 = tab == "Main" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)

    logsTabBtn.BackgroundColor3 = tab == "Logs" and Color3.fromRGB(55, 55, 70) or Color3.fromRGB(35, 35, 42)
    logsTabBtn.TextColor3 = tab == "Logs" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)

    minTabBtn.BackgroundColor3 = tab == "Min$" and Color3.fromRGB(55, 55, 70) or Color3.fromRGB(35, 35, 42)
    minTabBtn.TextColor3 = tab == "Min$" and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(180, 180, 190)
end

local function setMinValue(opt)
    minValue = opt.value
    minValueLabel = opt.label
    updateStatus()
    addLog("Min$ set to " .. opt.label, Color3.fromRGB(180, 220, 120))
end

-- Create min$ buttons
for i, opt in ipairs(MIN_OPTIONS) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 85, 0, 34)
    btn.BackgroundColor3 = Color3.fromRGB(40, 42, 52)
    btn.Text = opt.label
    btn.TextColor3 = Color3.fromRGB(220, 220, 230)
    btn.TextSize = 13
    btn.Font = Enum.Font.GothamMedium
    btn.AutoButtonColor = false
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = btn
    btn.LayoutOrder = i
    btn.Parent = minScroll

    btn.MouseButton1Click:Connect(function()
        setMinValue(opt)
        -- highlight selected
        for _, child in ipairs(minScroll:GetChildren()) do
            if child:IsA("TextButton") then
                child.BackgroundColor3 = Color3.fromRGB(40, 42, 52)
            end
        end
        btn.BackgroundColor3 = Color3.fromRGB(50, 90, 60)
    end)
end

-- default highlight first
task.defer(function()
    local first = minScroll:FindFirstChildOfClass("TextButton")
    if first then first.BackgroundColor3 = Color3.fromRGB(50, 90, 60) end
end)

minScroll.CanvasSize = UDim2.new(0, 0, 0, math.ceil(#MIN_OPTIONS / 4) * 40 + 16)

local function toggleUIVisibility()
    isUIVisible = not isUIVisible
    mainFrame.Visible = isUIVisible
    addLog(isUIVisible and "UI shown" or "UI hidden", Color3.fromRGB(140, 140, 160))
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
        addLog("HTTP error: " .. tostring(err), Color3.fromRGB(255, 100, 100))
        statusLabel.Text = "Status: HTTP Error | Min$: " .. minValueLabel
        return
    end

    if #servers > 0 then
        local chosen = servers[math.random(1, #servers)]
        addLog(string.format("Hopping → %s (%d/%d)", string.sub(chosen.id, 1, 8) .. "...", chosen.playing, chosen.max), Color3.fromRGB(120, 200, 255))
        statusLabel.Text = "Status: Teleporting... | Min$: " .. minValueLabel
        TeleportService:TeleportToPlaceInstance(PLACE_ID, chosen.id, LocalPlayer)
    else
        addLog("No free servers found", Color3.fromRGB(255, 180, 80))
        statusLabel.Text = "Status: No free servers | Min$: " .. minValueLabel
    end
end

local function toggleAutoJoin()
    isAutoJoinEnabled = not isAutoJoinEnabled

    if isAutoJoinEnabled then
        autoJoinButton.Text = "AUTOJOIN: ON"
        autoJoinButton.BackgroundColor3 = Color3.fromRGB(30, 120, 60)
        addLog("AutoJoin ENABLED (Min$ " .. minValueLabel .. ")", Color3.fromRGB(80, 220, 120))

        if serverHopConnection then
            serverHopConnection:Disconnect()
        end

        serverHopConnection = RunService.Heartbeat:Connect(function()
            forceServerHop()
            task.wait(AUTOJOIN_DELAY)
        end)
    else
        autoJoinButton.Text = "AUTOJOIN: OFF"
        autoJoinButton.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        addLog("AutoJoin DISABLED", Color3.fromRGB(220, 140, 80))

        if serverHopConnection then
            serverHopConnection:Disconnect()
            serverHopConnection = nil
        end
    end
    updateStatus()
end

scanButton.MouseButton1Click:Connect(function()
    addLog("Scan pressed — will use Min$ " .. minValueLabel .. " once API is connected", Color3.fromRGB(255, 200, 100))
    statusLabel.Text = "Status: Scan needs backend | Min$: " .. minValueLabel
end)

clearLogsBtn.MouseButton1Click:Connect(function()
    for _, v in ipairs(logs) do
        v:Destroy()
    end
    logs = {}
    logsScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    addLog("Logs cleared", Color3.fromRGB(160, 160, 160))
end)

mainTabBtn.MouseButton1Click:Connect(function() setTab("Main") end)
logsTabBtn.MouseButton1Click:Connect(function() setTab("Logs") end)
minTabBtn.MouseButton1Click:Connect(function() setTab("Min$") end)
autoJoinButton.MouseButton1Click:Connect(toggleAutoJoin)
toggleButton.MouseButton1Click:Connect(toggleUIVisibility)

-- Dragging
local dragging = false
local dragStart, startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local toggleDragging = false
local tDragStart, tStartPos

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        toggleDragging = true
        tDragStart = input.Position
        tStartPos = toggleButton.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                toggleDragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if toggleDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - tDragStart
        toggleButton.Position = UDim2.new(tStartPos.X.Scale, tStartPos.X.Offset + delta.X, tStartPos.Y.Scale, tStartPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        toggleUIVisibility()
    elseif input.KeyCode == Enum.KeyCode.J then
        toggleAutoJoin()
    end
end)

task.spawn(function()
    while true do
        for i = 0, 1, 0.015 do
            rgbGradient.Offset = Vector2.new(i, 0)
            task.wait(0.03)
        end
    end
end)

-- Init
setTab("Main")
updateStatus()
addLog("Borralho Auto Joiner V2 loaded", Color3.fromRGB(100, 220, 160))
addLog("Priority list: " .. #PRIORITY_BRAINROTS .. " high-value brainrots", Color3.fromRGB(140, 180, 255))
addLog("Default Min$ = 10M (change in Min$ tab)", Color3.fromRGB(180, 200, 140))
print("[Borralho] Loaded successfully")
