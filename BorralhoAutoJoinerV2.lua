local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local AUTOJOIN_DELAY = 1
local PLACE_ID = 109983668079237

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BorralhoAutoJoiner"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 350, 0, 250)
mainFrame.Position = UDim2.new(0.5, -175, 0.5, -125)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
mainFrame.BorderSizePixel = 0

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = mainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(255, 255, 255)
UIStroke.Thickness = 2
UIStroke.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "BORRALHO AUTO JOINER"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

local toggleButton = Instance.new("ImageButton")
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(1, -60, 0, 10)
toggleButton.AnchorPoint = Vector2.new(1, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.AutoButtonColor = false

local rgbCorner = Instance.new("UICorner")
rgbCorner.CornerRadius = UDim.new(1, 0)
rgbCorner.Parent = toggleButton

local rgbGradient = Instance.new("UIGradient")
rgbGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
    ColorSequenceKeypoint.new(0.66, Color3.fromRGB(0, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
})
rgbGradient.Rotation = 45
rgbGradient.Parent = toggleButton

local toggleIcon = Instance.new("TextLabel")
toggleIcon.Name = "ToggleIcon"
toggleIcon.Size = UDim2.new(1, 0, 1, 0)
toggleIcon.Position = UDim2.new(0, 0, 0, 0)
toggleIcon.BackgroundTransparency = 1
toggleIcon.Text = "≡"
toggleIcon.TextColor3 = Color3.fromRGB(0, 0, 0)
toggleIcon.TextSize = 30
toggleIcon.Font = Enum.Font.GothamBold
toggleIcon.Parent = toggleButton

toggleButton.Parent = screenGui

local toggleShadow = Instance.new("UIStroke")
toggleShadow.Color = Color3.fromRGB(0, 0, 0)
toggleShadow.Thickness = 3
toggleShadow.Parent = toggleButton

local textBoxFrame = Instance.new("Frame")
textBoxFrame.Name = "TextBoxFrame"
textBoxFrame.Size = UDim2.new(0.8, 0, 0, 40)
textBoxFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
textBoxFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
textBoxFrame.BorderSizePixel = 0

local textBoxCorner = Instance.new("UICorner")
textBoxCorner.CornerRadius = UDim.new(0, 8)
textBoxCorner.Parent = textBoxFrame

local textBoxLabel = Instance.new("TextLabel")
textBoxLabel.Name = "TextBox"
textBoxLabel.Size = UDim2.new(1, 0, 1, 0)
textBoxLabel.Position = UDim2.new(0, 0, 0, 0)
textBoxLabel.BackgroundTransparency = 1
textBoxLabel.Text = "120M"
textBoxLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
textBoxLabel.TextSize = 18
textBoxLabel.Font = Enum.Font.Gotham
textBoxLabel.Parent = textBoxFrame

textBoxFrame.Parent = mainFrame

local autoJoinButton = Instance.new("TextButton")
autoJoinButton.Name = "AutoJoinButton"
autoJoinButton.Size = UDim2.new(0.6, 0, 0, 50)
autoJoinButton.Position = UDim2.new(0.2, 0, 0.6, 0)
autoJoinButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
autoJoinButton.Text = "AUTOJOIN: OFF"
autoJoinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
autoJoinButton.TextSize = 18
autoJoinButton.Font = Enum.Font.GothamBold
autoJoinButton.AutoButtonColor = true

local autoJoinCorner = Instance.new("UICorner")
autoJoinCorner.CornerRadius = UDim.new(0, 8)
autoJoinCorner.Parent = autoJoinButton

local autoJoinStroke = Instance.new("UIStroke")
autoJoinStroke.Color = Color3.fromRGB(100, 100, 100)
autoJoinStroke.Thickness = 2
autoJoinStroke.Parent = autoJoinButton

autoJoinButton.Parent = mainFrame

mainFrame.Parent = screenGui
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local isUIVisible = true
local isAutoJoinEnabled = false
local serverHopConnection = nil

local function animateRGBGradient()
    while true do
        rgbGradient.Offset = Vector2.new(0, 0)
        for i = 0, 1, 0.01 do
            rgbGradient.Offset = Vector2.new(i, 0)
            task.wait(0.02)
        end
    end
end

task.spawn(animateRGBGradient)

local function toggleUIVisibility()
    isUIVisible = not isUIVisible
    
    if isUIVisible then
        toggleIcon.Text = "≡"
        mainFrame.Visible = true
        print("UI visível")
    else
        toggleIcon.Text = "≡"
        mainFrame.Visible = false
        print("UI escondida")
    end
end

local function forceServerHop()
    local servers = {}
    
    pcall(function()
        local url = "https://games.roblox.com/v1/games/"..PLACE_ID.."/servers/Public?sortOrder=Asc&limit=100"
        local response = game:HttpGet(url)
        local data = HttpService:JSONDecode(response)
        
        if data and data.data then
            for _, v in pairs(data.data) do
                if v.playing < v.maxPlayers then
                    table.insert(servers, v.id)
                end
            end
        end
    end)
    
    if #servers > 0 then
        local randomServer = servers[math.random(1, #servers)]
        TeleportService:TeleportToPlaceInstance(PLACE_ID, randomServer, LocalPlayer)
    else
        warn("Keine freien Server gefunden!")
    end
end

local function toggleAutoJoin()
    isAutoJoinEnabled = not isAutoJoinEnabled
    
    if isAutoJoinEnabled then
        autoJoinButton.Text = "AUTOJOIN: ON"
        autoJoinButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        
        if serverHopConnection then
            serverHopConnection:Disconnect()
        end
        
        serverHopConnection = RunService.Heartbeat:Connect(function()
            forceServerHop()
            task.wait(AUTOJOIN_DELAY)
        end)
        
        print("Auto Join ATIVADO - Fazendo server hop a cada " .. AUTOJOIN_DELAY .. " segundo(s)")
    else
        autoJoinButton.Text = "AUTOJOIN: OFF"
        autoJoinButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        
        if serverHopConnection then
            serverHopConnection:Disconnect()
            serverHopConnection = nil
        end
        
        print("Auto Join DESATIVADO")
    end
end

toggleButton.MouseButton1Click:Connect(toggleUIVisibility)
autoJoinButton.MouseButton1Click:Connect(toggleAutoJoin)

local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(
        startPos.X.Scale, 
        startPos.X.Offset + delta.X, 
        startPos.Y.Scale, 
        startPos.Y.Offset + delta.Y
    )
end

titleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
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

titleLabel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input == dragInput then
        update(input)
    end
end)

local toggleDragging = false
local toggleDragInput, toggleDragStart, toggleStartPos

local function updateToggle(input)
    local delta = input.Position - toggleDragStart
    toggleButton.Position = UDim2.new(
        toggleStartPos.X.Scale, 
        toggleStartPos.X.Offset + delta.X, 
        toggleStartPos.Y.Scale, 
        toggleStartPos.Y.Offset + delta.Y
    )
end

toggleButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        toggleDragging = true
        toggleDragStart = input.Position
        toggleStartPos = toggleButton.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                toggleDragging = false
            end
        end)
    end
end)

toggleButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        toggleDragInput = input
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if toggleDragging and input == toggleDragInput then
        updateToggle(input)
    end
end)

local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed then
        if input.KeyCode == Enum.KeyCode.RightShift then
            toggleUIVisibility()
        elseif input.KeyCode == Enum.KeyCode.J then
            toggleAutoJoin()
        end
    end
end)

local tooltip = Instance.new("TextLabel")
tooltip.Name = "Tooltip"
tooltip.Size = UDim2.new(0, 150, 0, 30)
tooltip.Position = UDim2.new(0, 0, -1, -5)
tooltip.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
tooltip.TextColor3 = Color3.fromRGB(255, 255, 255)
tooltip.Text = "Mostrar/Esconder UI"
tooltip.TextSize = 14
tooltip.Visible = false
tooltip.Font = Enum.Font.Gotham
tooltip.Parent = toggleButton

local tooltipCorner = Instance.new("UICorner")
tooltipCorner.CornerRadius = UDim.new(0, 6)
tooltipCorner.Parent = tooltip

local tooltipStroke = Instance.new("UIStroke")
tooltipStroke.Color = Color3.fromRGB(100, 100, 100)
tooltipStroke.Thickness = 1
tooltipStroke.Parent = tooltip

toggleButton.MouseEnter:Connect(function()
    tooltip.Visible = true
end)

toggleButton.MouseLeave:Connect(function()
    tooltip.Visible = false
end)

print("╔═══════════════════════════════════════╗")
print("║   BORRALHO AUTO JOINER CARREGADO!     ║")
print("╠═══════════════════════════════════════╣")
print("║ • Botão RGB: Mostrar/Esconder UI      ║")
print("║ • AUTOJOIN: Server hop automático     ║")
print("║ • Atalhos: RightShift (UI) | J (Auto) ║")
print("╚═══════════════════════════════════════╝")
