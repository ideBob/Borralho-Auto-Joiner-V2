--[[
    BORRALHO AUTO JOINER V2 (Upgraded)
    Features:
    - Refined dark UI with tabs (Main / Logs)
    - Fully draggable main frame + floating RGB button
    - AutoJoin server hop
    - Logs tab with hop history
    - Priority high-value Brainrots list (Secrets/Gods/OGs)
    - Scan button (placeholder for private API)
    - Keybinds: RightShift = toggle UI | J = toggle AutoJoin

    Loadstring example:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ideBob/Borralho-Auto-Joiner-V2/main/BorralhoAutoJoinerV2.lua"))()
]]

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local AUTOJOIN_DELAY = 1.2
local PLACE_ID = 109983668079237

-- Priority high-value brainrots (Secrets / Gods / OGs from wiki - expand via API later)
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

--// UI Creation
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BorralhoAutoJoiner"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 380, 0, 320)
mainFrame.Position = UDim2.new(0.5, -190, 0.5, -160)
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
titleLabel.Size = UDim2.new(1, -50, 1, 0)
titleLabel.Position = UDim2.new(0, 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "BORRALHO JOINER V2"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 16
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = titleBar

-- Tabs
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(1, -20, 0, 32)
tabContainer.Position = UDim2.new(0, 10, 0, 50)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = mainFrame

local function createTabButton(name, order)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "Tab"
    btn.Size = UDim2.new(0.5, -4, 1, 0)
    btn.Position = UDim2.new(order * 0.5, order * 4, 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(180, 180, 190)
    btn.TextSize = 14
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

-- Main tab content
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 22)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Idle"
statusLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.Gotham
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = mainContent

local infoLabel = Instance.new("TextLabel")
infoLabel.Size = UDim2.new(1, 0, 0, 40)
infoLabel.Position = UDim2.new(0, 0, 0, 28)
infoLabel.BackgroundTransparency = 1
infoLabel.Text = "Priority Brainrots loaded: " .. #PRIORITY_BRAINROTS .. "\nReal server Brainrot data requires private API"
infoLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
infoLabel.TextSize = 12
infoLabel.Font = Enum.Font.Gotham
infoLabel.TextXAlignment = Enum.TextXAlignment.Left
infoLabel.TextYAlignment = Enum.TextYAlignment.Top
infoLabel.Parent = mainContent

local autoJoinButton = Instance.new("TextButton")
autoJoinButton.Size = UDim2.new(1, 0, 0, 42)
autoJoinButton.Position = UDim2.new(0, 0, 0, 80)
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
scanButton.Position = UDim2.new(0, 0, 0, 132)
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

-- Logs tab content
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

-- Floating toggle button
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
    if tab == "Main" then
        mainContent.Visible = true
        logsContent.Visible = false
        mainTabBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
        mainTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        logsTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        logsTabBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
    else
        mainContent.Visible = false
        logsContent.Visible = true
        logsTabBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 70)
        logsTabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        mainTabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
        mainTabBtn.TextColor3 = Color3.fromRGB(180, 180, 190)
    end
end

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
        statusLabel.Text = "Status: HTTP Error"
        return
    end

    if #servers > 0 then
        local chosen = servers[math.random(1, #servers)]
        addLog(string.format("Hopping → %s (%d/%d)", string.sub(chosen.id, 1, 8) .. "...", chosen.playing, chosen.max), Color3.fromRGB(120, 200, 255))
        statusLabel.Text = "Status: Teleporting..."
        TeleportService:TeleportToPlaceInstance(PLACE_ID, chosen.id, LocalPlayer)
    else
        addLog("No free servers found", Color3.fromRGB(255, 180, 80))
        statusLabel.Text = "Status: No free servers"
    end
end

local function toggleAutoJoin()
    isAutoJoinEnabled = not isAutoJoinEnabled

    if isAutoJoinEnabled then
        autoJoinButton.Text = "AUTOJOIN: ON"
        autoJoinButton.BackgroundColor3 = Color3.fromRGB(30, 120, 60)
        statusLabel.Text = "Status: AutoJoin Active"
        addLog("AutoJoin ENABLED", Color3.fromRGB(80, 220, 120))

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
        statusLabel.Text = "Status: Idle"
        addLog("AutoJoin DISABLED", Color3.fromRGB(220, 140, 80))

        if serverHopConnection then
            serverHopConnection:Disconnect()
            serverHopConnection = nil
        end
    end
end

-- Scan placeholder (real scan needs private API)
scanButton.MouseButton1Click:Connect(function()
    addLog("Scan pressed — private API required for live Brainrot data", Color3.fromRGB(255, 200, 100))
    statusLabel.Text = "Status: Scan needs backend"
    -- Future: HttpGet your private API that returns JobIds with rare brainrots
    -- Example:
    -- local data = HttpService:JSONDecode(game:HttpGet("https://your-api.com/rares"))
    -- then teleport to matching JobId
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
autoJoinButton.MouseButton1Click:Connect(toggleAutoJoin)
toggleButton.MouseButton1Click:Connect(toggleUIVisibility)

-- Dragging main frame
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

-- Dragging toggle button
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

-- Keybinds
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        toggleUIVisibility()
    elseif input.KeyCode == Enum.KeyCode.J then
        toggleAutoJoin()
    end
end)

-- RGB animation
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
addLog("Borralho Auto Joiner V2 loaded", Color3.fromRGB(100, 220, 160))
addLog("Priority list: " .. #PRIORITY_BRAINROTS .. " high-value brainrots", Color3.fromRGB(140, 180, 255))
print("[Borralho] Loaded successfully")
