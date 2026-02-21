-- Nez0x UI - ПОЛНАЯ ВЕРСИЯ (ФИНАЛ)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local Stats = game:GetService("Stats")
local Workspace = game:GetService("Workspace")
local NetworkClient = game:GetService("NetworkClient")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

-- Пытаемся использовать CoreGui для самого высокого приоритета
local success, gui = pcall(function()
    return Instance.new("ScreenGui")
end)

if not success then
    gui = Instance.new("ScreenGui")
end

gui.Name = "Nez0xUI"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 999999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parentSuccess, parentError = pcall(function()
    gui.Parent = CoreGui
end)

if not parentSuccess then
    gui.Parent = player:WaitForChild("PlayerGui")
end

local blur = Instance.new("BlurEffect")
blur.Size = 0
blur.Parent = Lighting

local main = Instance.new("Frame")
main.Name = "Main"
main.BackgroundTransparency = 1
main.Size = UDim2.new(1, 0, 1, 0)
main.ZIndex = 1000
main.Parent = gui

local bgDim = Instance.new("Frame")
bgDim.Name = "BackgroundDim"
bgDim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
bgDim.BackgroundTransparency = 0.5
bgDim.Size = UDim2.new(1, 0, 1, 0)
bgDim.ZIndex = 1000
bgDim.Parent = main

local uiContainer = Instance.new("Frame")
uiContainer.Name = "UIContainer"
uiContainer.BackgroundTransparency = 1
uiContainer.Size = UDim2.new(0, 1650, 0, 700)
uiContainer.Position = UDim2.new(0.5, -825, 0.5, -350)
uiContainer.ZIndex = 1001
uiContainer.Parent = main

local function createColumn(name, xPos, yPos, width)
    width = width or 200
    
    local col = Instance.new("Frame")
    col.Name = name .. "Column"
    col.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    col.BackgroundTransparency = 0.1
    col.BorderSizePixel = 0
    col.Position = UDim2.new(0, xPos, 0, yPos)
    col.Size = UDim2.new(0, width, 0, 550)
    col.ZIndex = 1002
    col.Parent = uiContainer
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = col
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(60, 60, 70)
    stroke.Thickness = 1
    stroke.Parent = col
    
    local colTitle = Instance.new("TextLabel")
    colTitle.Name = "Title"
    colTitle.BackgroundTransparency = 1
    colTitle.Font = Enum.Font.Gotham
    colTitle.Text = name
    colTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    colTitle.TextSize = 18
    colTitle.Position = UDim2.new(0, 15, 0, 10)
    colTitle.Size = UDim2.new(1, -30, 0, 25)
    colTitle.ZIndex = 1003
    colTitle.Parent = col
    
    local scrollingContainer = Instance.new("ScrollingFrame")
    scrollingContainer.Name = name .. "Scrolling"
    scrollingContainer.BackgroundTransparency = 1
    scrollingContainer.BorderSizePixel = 0
    scrollingContainer.Position = UDim2.new(0, 0, 0, 40)
    scrollingContainer.Size = UDim2.new(1, 0, 1, -45)
    scrollingContainer.CanvasSize = UDim2.new(0, 0, 2, 0)
    scrollingContainer.ScrollBarThickness = 6
    scrollingContainer.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
    scrollingContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scrollingContainer.ZIndex = 1003
    scrollingContainer.Parent = col
    
    local layout = Instance.new("UIListLayout")
    layout.Parent = scrollingContainer
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 4)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    
    return {frame = col, scrolling = scrollingContainer, layout = layout}
end

local startX = 30
local gap = 215
local colY = 30

local cols = {
    Combat = createColumn("COMBAT", startX, colY, 210),
    Movement = createColumn("MOVEMENT", startX + gap, colY, 210),
    Visuals = createColumn("VISUALS", startX + gap*2, colY, 210),
    Player = createColumn("PLAYER", startX + gap*3, colY, 210),
    ESP = createColumn("ESP", startX + gap*4, colY, 220),
    Misc = createColumn("MISC", startX + gap*5, colY, 230),
    Theme = createColumn("THEME", startX + gap*6 + 10, colY, 250),
}

local features = {
    aimbot = false,
    teamCheck = true, -- По умолчанию включено (не наводится на друзей)
    fly = false,
    noclip = false,
    infJump = false,
    fullbright = false,
    blur = false,
    clickTp = false,
    
    aimbotSpeed = 0.5,
    aimbotFOV = 90,
    aimbotShowFOV = false,
    
    flySpeed = 50,
    
    espEnabled = false,
    espMode = "Обводка",
    espShowName = true,
    espShowHealth = true,
    espShowDistance = false,
    espShowTrails = false,
    espColor = Color3.fromRGB(255, 80, 80),
    espTracerColor = Color3.fromRGB(80, 140, 255),
    espTeamColor = Color3.fromRGB(80, 255, 80),
    espTrailColor = Color3.fromRGB(100, 200, 255),
    espTrailTime = 5,
}

local defaultBrightness = Lighting.Brightness
local defaultClock = Lighting.ClockTime
local defaultShadows = Lighting.GlobalShadows

local themeSettings = {
    bgDimTransparency = 0.5,
    bgDimColor = Color3.fromRGB(0, 0, 0),
    columnsTransparency = 0.1,
    columnsColor = Color3.fromRGB(30, 30, 35),
    buttonsTransparency = 0.2,
    buttonsColor = Color3.fromRGB(40, 40, 45),
    accentColor = Color3.fromRGB(60, 70, 120),
    textColor = Color3.fromRGB(255, 255, 255),
    secondaryTextColor = Color3.fromRGB(200, 200, 200),
    brightness = 1,
    miniBarEnabled = true,
    miniBarShowFPS = true,
    miniBarShowTime = true,
    miniBarShowPing = true,
}

local fps = 60
local ping = 0
local currentTime = "00:00"
local lastFPSUpdate = tick()
local frameCount = 0

RunService.RenderStepped:Connect(function()
    frameCount = frameCount + 1
    local now = tick()
    if now - lastFPSUpdate >= 1 then
        fps = frameCount
        frameCount = 0
        lastFPSUpdate = now
    end
end)

local function getPing()
    local success, result = pcall(function()
        local stats = Stats
        if stats then
            local network = stats:FindFirstChild("Network")
            if network then
                local pingValue = network:FindFirstChild("Ping")
                if pingValue then
                    return math.floor(pingValue.Value * 1000)
                end
            end
        end
        return 0
    end)
    return success and result or 0
end

spawn(function()
    while true do
        local dateTime = os.date("*t")
        currentTime = string.format("%02d:%02d", dateTime.hour, dateTime.min)
        ping = getPing()
        wait(0.5)
    end
end)

local fovCircle = Drawing.new("Circle")
fovCircle.Visible = false
fovCircle.Radius = features.aimbotFOV
fovCircle.Color = Color3.fromRGB(255, 255, 255)
fovCircle.Thickness = 2
fovCircle.NumSides = 60
fovCircle.Filled = false
fovCircle.ZIndex = 999999

-- Aimbot с правильной проверкой на друзей
RunService.RenderStepped:Connect(function()
    if not features.aimbot then return end
    
    if features.aimbotShowFOV then
        fovCircle.Visible = true
        fovCircle.Radius = features.aimbotFOV
        fovCircle.Position = UIS:GetMouseLocation()
    else
        fovCircle.Visible = false
    end
    
    if not UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then return end
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then return end
    
    local closest = nil
    local shortest = math.huge
    local mousePos = UIS:GetMouseLocation()
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("Head") then
            -- Проверка на друзей (если teamCheck включен)
            if features.teamCheck then
                -- Проверяем, есть ли у игрока Team и совпадает ли он с нашей командой
                local playerTeam = p.Team
                local myTeam = player.Team
                
                -- Если у обоих есть команды и они совпадают - пропускаем
                if playerTeam and myTeam and playerTeam == myTeam then
                    continue
                end
                
                -- Дополнительная проверка на друзей через FriendService (если доступно)
                local success, isFriend = pcall(function()
                    return player:IsFriendsWith(p.UserId)
                end)
                if success and isFriend then
                    continue
                end
            end
            
            if features.aimbotShowFOV then
                local headPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(p.Character.Head.Position)
                if onScreen then
                    local screenPos = Vector2.new(headPos.X, headPos.Y)
                    local dist = (screenPos - mousePos).Magnitude
                    if dist > features.aimbotFOV then continue end
                end
            end
            
            local dist = (player.Character.HumanoidRootPart.Position - p.Character.Head.Position).Magnitude
            if dist < shortest then
                shortest = dist
                closest = p.Character.Head
            end
        end
    end
    
    if closest then
        local lookAt = CFrame.new(workspace.CurrentCamera.CFrame.Position, closest.Position)
        workspace.CurrentCamera.CFrame = workspace.CurrentCamera.CFrame:Lerp(lookAt, features.aimbotSpeed)
    end
end)

RunService.Heartbeat:Connect(function()
    if not features.fly or not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local dir = Vector3.new()
    local cam = workspace.CurrentCamera.CFrame
    
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.RightVector end
    
    hrp.Velocity = dir * features.flySpeed
end)

RunService.Stepped:Connect(function()
    if not features.noclip or not player.Character then return end
    for _, p in ipairs(player.Character:GetDescendants()) do
        if p:IsA("BasePart") then
            p.CanCollide = false
        end
    end
end)

UIS.JumpRequest:Connect(function()
    if not features.infJump or not player.Character then return end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    local hum = player.Character:FindFirstChildOfClass("Humanoid")
    if hrp and hum then
        hrp.Velocity = Vector3.new(hrp.Velocity.X, hum.JumpPower, hrp.Velocity.Z)
    end
end)

UIS.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not features.clickTp then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 and UIS:IsKeyDown(Enum.KeyCode.F) then
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local mouse = player:GetMouse()
            player.Character:MoveTo(mouse.Hit.Position)
        end
    end
end)

-- ESP система с трейлами
local espObjects = {}
local trailObjects = {}
local playerPositions = {}

local function updateTrails()
    for _, trail in ipairs(trailObjects) do
        pcall(function() trail:Destroy() end)
    end
    trailObjects = {}
    
    if not features.espEnabled or not features.espShowTrails then return end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        if not p.Character then continue end
        
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local trail = Instance.new("Trail")
            trail.Parent = hrp
            trail.Color = ColorSequence.new(features.espTrailColor)
            trail.Lifetime = features.espTrailTime
            trail.Transparency = NumberSequence.new(0.5)
            trail.Width = 0.5
            trail.FaceCamera = true
            trail.Attachment0 = Instance.new("Attachment")
            trail.Attachment0.Parent = hrp
            trail.Attachment0.Position = Vector3.new(0, 2, 0)
            trail.Attachment1 = Instance.new("Attachment")
            trail.Attachment1.Parent = hrp
            trail.Attachment1.Position = Vector3.new(0, -2, 0)
            
            table.insert(trailObjects, trail)
            table.insert(trailObjects, trail.Attachment0)
            table.insert(trailObjects, trail.Attachment1)
        end
    end
end

local function createESPText(p, text, color, offset)
    local billboard = Instance.new("BillboardGui")
    billboard.Parent = p.Character:FindFirstChild("Head") or p.Character:FindFirstChild("HumanoidRootPart")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, offset, 0)
    billboard.AlwaysOnTop = true
    billboard.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    billboard.Name = "ESP_" .. HttpService:GenerateGUID(false)
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Parent = billboard
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.Font = Enum.Font.Gotham
    textLabel.TextSize = 14
    textLabel.TextScaled = true
    
    return billboard
end

local function updateESP()
    for _, obj in ipairs(espObjects) do
        pcall(function() obj:Destroy() end)
    end
    espObjects = {}
    
    updateTrails()
    
    if not features.espEnabled then return end
    
    for _, p in ipairs(Players:GetPlayers()) do
        if p == player then continue end
        if not p.Character then continue end
        
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        local head = p.Character:FindFirstChild("Head")
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        
        if hrp and head and hum then
            local espColor = features.espColor
            if features.teamCheck then
                -- Проверка на друзей для ESP
                local playerTeam = p.Team
                local myTeam = player.Team
                
                if playerTeam and myTeam and playerTeam == myTeam then
                    espColor = features.espTeamColor
                end
                
                local success, isFriend = pcall(function()
                    return player:IsFriendsWith(p.UserId)
                end)
                if success and isFriend then
                    espColor = features.espTeamColor
                end
            end
            
            if features.espMode == "Обводка" then
                local highlight = Instance.new("Highlight")
                highlight.Parent = p.Character
                highlight.FillColor = espColor
                highlight.FillTransparency = 0.5
                highlight.OutlineColor = espColor
                highlight.OutlineTransparency = 0
                highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                table.insert(espObjects, highlight)
                
            elseif features.espMode == "Хитбокс" then
                local parts = {hrp, head}
                for _, part in ipairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        local box = Instance.new("SelectionBox")
                        box.Parent = part
                        box.Adornee = part
                        box.Color3 = espColor
                        box.LineThickness = 0.1
                        box.Transparency = 0.5
                        box.SurfaceTransparency = 0.7
                        table.insert(espObjects, box)
                    end
                end
                
            elseif features.espMode == "Палочки" then
                local box = Instance.new("SelectionBox")
                box.Parent = hrp
                box.Adornee = hrp
                box.Color3 = espColor
                box.LineThickness = 0.05
                box.Transparency = 0
                box.SurfaceTransparency = 1
                table.insert(espObjects, box)
                
                local line = Instance.new("SelectionBox")
                line.Parent = head
                line.Adornee = head
                line.Color3 = espColor
                line.LineThickness = 0.05
                line.Transparency = 0
                line.SurfaceTransparency = 1
                table.insert(espObjects, line)
            end
            
            -- Текстовая информация
            local yOffset = 3
            if features.espShowName then
                local nameText = createESPText(p, p.Name, Color3.fromRGB(255, 255, 255), yOffset)
                table.insert(espObjects, nameText)
                yOffset = yOffset + 2
            end
            
            if features.espShowHealth then
                local healthText = createESPText(p, tostring(math.floor(hum.Health)) .. " HP", 
                    hum.Health > 50 and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0), yOffset)
                table.insert(espObjects, healthText)
                yOffset = yOffset + 2
            end
            
            if features.espShowDistance and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local dist = math.floor((player.Character.HumanoidRootPart.Position - hrp.Position).Magnitude)
                local distText = createESPText(p, tostring(dist) .. " studs", Color3.fromRGB(200, 200, 200), yOffset)
                table.insert(espObjects, distText)
            end
        end
    end
end

-- Particles система - рандомные частицы в прогруженной территории
local particles = {}
local particleFeatures = {
    enabled = false,
    particleType = "Шары 3D",
    count = 20,
    size = 0.5,
    speed = 10,
    spread = 50,
    lifetime = 3,
    color = Color3.fromRGB(100, 200, 255)
}

local function createRandomParticle()
    if not player.Character then return nil end
    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    -- Случайная позиция в радиусе от игрока
    local angle = math.random() * 2 * math.pi
    local radius = math.random(10, particleFeatures.spread)
    local height = math.random(-10, 20)
    
    local pos = hrp.Position + Vector3.new(
        math.cos(angle) * radius,
        height,
        math.sin(angle) * radius
    )
    
    -- Случайное направление
    local dir = Vector3.new(
        math.random(-100, 100) / 100,
        math.random(-50, 100) / 100,
        math.random(-100, 100) / 100
    ).Unit
    
    -- Цвет в зависимости от типа
    local color = particleFeatures.color
    if particleFeatures.particleType == "Огненные" then
        color = Color3.fromRGB(255, math.random(50, 150), 0)
    elseif particleFeatures.particleType == "Ледяные" then
        color = Color3.fromRGB(150, math.random(200, 255), 255)
    elseif particleFeatures.particleType == "Радужные" then
        color = Color3.fromHSV(math.random(), 1, 1)
    elseif particleFeatures.particleType == "Шары 3D" then
        color = Color3.fromRGB(100, math.random(150, 255), 255)
    end
    
    -- Создание частицы (шар)
    local ball = Instance.new("Part")
    ball.Parent = workspace
    ball.Size = Vector3.new(particleFeatures.size, particleFeatures.size, particleFeatures.size)
    ball.Position = pos
    ball.Anchored = false
    ball.CanCollide = false
    ball.Transparency = 0.2
    ball.BrickColor = BrickColor.new(color)
    ball.Material = Enum.Material.Neon
    ball.Shape = Enum.PartType.Ball
    ball.TopSurface = Enum.SurfaceType.Smooth
    ball.BottomSurface = Enum.SurfaceType.Smooth
    
    -- Свечение
    local glow = Instance.new("Part")
    glow.Parent = workspace
    glow.Size = Vector3.new(particleFeatures.size * 2, particleFeatures.size * 2, particleFeatures.size * 2)
    glow.Position = pos
    glow.Anchored = false
    glow.CanCollide = false
    glow.Transparency = 0.6
    glow.BrickColor = BrickColor.new(color)
    glow.Material = Enum.Material.Neon
    glow.Shape = Enum.PartType.Ball
    glow.TopSurface = Enum.SurfaceType.Smooth
    glow.BottomSurface = Enum.SurfaceType.Smooth
    
    -- Точечный свет
    local light = Instance.new("PointLight")
    light.Parent = ball
    light.Color = color
    light.Range = particleFeatures.size * 15
    light.Brightness = 2
    light.Shadows = false
    
    -- Установка скорости
    ball.Velocity = dir * particleFeatures.speed
    glow.Velocity = dir * particleFeatures.speed
    
    -- Удаление через время
    game:GetService("Debris"):AddItem(ball, particleFeatures.lifetime)
    game:GetService("Debris"):AddItem(glow, particleFeatures.lifetime)
    game:GetService("Debris"):AddItem(light, particleFeatures.lifetime)
    
    return {ball, glow, light}
end

local function updateParticles()
    -- Очистка старых частиц (они сами удаляются через Debris)
    particles = {}
end

-- Запуск генерации частиц
spawn(function()
    while true do
        if particleFeatures.enabled and player.Character then
            -- Создаем несколько частиц за раз
            for i = 1, math.floor(particleFeatures.count / 2) do
                createRandomParticle()
                wait(0.1)
            end
        end
        wait(particleFeatures.lifetime / 2)
    end
end)

-- Функция создания кнопки
local function createButton(col, text, isPremium, callback)
    local btn = Instance.new("TextButton")
    btn.Name = text .. "Btn"
    btn.AutoButtonColor = false
    btn.BackgroundColor3 = themeSettings.buttonsColor
    btn.BackgroundTransparency = themeSettings.buttonsTransparency
    btn.BorderSizePixel = 0
    btn.Size = UDim2.new(1, -20, 0, 28)
    btn.Text = ""
    btn.ZIndex = 1004
    btn.Parent = col.scrolling

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local txt = Instance.new("TextLabel")
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.Gotham
    txt.Text = text
    txt.TextColor3 = isPremium and Color3.fromRGB(255, 200, 100) or themeSettings.textColor
    txt.TextSize = 14
    txt.Position = UDim2.new(0, 10, 0, 0)
    txt.Size = UDim2.new(1, -50, 1, 0)
    txt.TextXAlignment = Enum.TextXAlignment.Left
    txt.ZIndex = 1005
    txt.Parent = btn

    local status = Instance.new("TextLabel")
    status.BackgroundTransparency = 1
    status.Font = Enum.Font.Gotham
    status.Text = isPremium and "PREM" or "OFF"
    status.TextColor3 = isPremium and Color3.fromRGB(255, 200, 100) or Color3.fromRGB(150, 150, 150)
    status.TextSize = isPremium and 10 or 12
    status.Position = UDim2.new(1, -45, 0, 0)
    status.Size = UDim2.new(0, 40, 1, 0)
    status.TextXAlignment = Enum.TextXAlignment.Right
    status.ZIndex = 1005
    status.Parent = btn

    local enabled = false
    
    btn.MouseButton1Click:Connect(function()
        if isPremium then return end
        
        enabled = not enabled
        if enabled then
            btn.BackgroundColor3 = themeSettings.accentColor
            status.Text = "ON"
            status.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            btn.BackgroundColor3 = themeSettings.buttonsColor
            status.Text = "OFF"
            status.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        
        if callback then
            callback(enabled)
        end
    end)

    return {btn = btn, txt = txt, status = status, enabled = enabled}
end

local function createSlider(col, text, min, max, default, callback, suffix)
    suffix = suffix or ""
    local container = Instance.new("Frame")
    container.Name = text .. "Slider"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -20, 0, 45)
    container.ZIndex = 1004
    container.Parent = col.scrolling

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = themeSettings.secondaryTextColor
    label.TextSize = 14
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(1, -50, 0, 20)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 1005
    label.Parent = container

    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.Text = tostring(default) .. suffix
    valueLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
    valueLabel.TextSize = 14
    valueLabel.Position = UDim2.new(1, -50, 0, 0)
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.ZIndex = 1005
    valueLabel.Parent = container

    local sliderBg = Instance.new("Frame")
    sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    sliderBg.Position = UDim2.new(0, 0, 0, 25)
    sliderBg.Size = UDim2.new(1, 0, 0, 8)
    sliderBg.ZIndex = 1004
    sliderBg.Parent = container

    local bgCorner = Instance.new("UICorner")
    bgCorner.CornerRadius = UDim.new(0, 4)
    bgCorner.Parent = sliderBg

    local slider = Instance.new("Frame")
    slider.BackgroundColor3 = themeSettings.accentColor
    slider.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    slider.ZIndex = 1005
    slider.Parent = sliderBg

    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(0, 4)
    sliderCorner.Parent = slider

    local dragButton = Instance.new("TextButton")
    dragButton.BackgroundTransparency = 1
    dragButton.Size = UDim2.new(1, 0, 1, 0)
    dragButton.Text = ""
    dragButton.ZIndex = 1006
    dragButton.Parent = sliderBg

    local value = default
    local dragging = false

    dragButton.MouseButton1Down:Connect(function()
        dragging = true
    end)

    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mousePos = UIS:GetMouseLocation()
            local absPos = sliderBg.AbsolutePosition
            local size = sliderBg.AbsoluteSize.X
            
            local relative = math.clamp((mousePos.X - absPos.X) / size, 0, 1)
            slider.Size = UDim2.new(relative, 0, 1, 0)
            
            value = min + (max - min) * relative
            value = math.floor(value * 100) / 100
            valueLabel.Text = tostring(value) .. suffix
            
            if callback then
                callback(value)
            end
        end
    end)

    return container
end

local function createToggle(col, text, default, callback)
    local container = Instance.new("Frame")
    container.Name = text .. "Toggle"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -20, 0, 25)
    container.ZIndex = 1004
    container.Parent = col.scrolling

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = themeSettings.secondaryTextColor
    label.TextSize = 14
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(1, -40, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 1005
    label.Parent = container

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.BackgroundColor3 = default and themeSettings.accentColor or Color3.fromRGB(50, 50, 55)
    toggleBtn.Position = UDim2.new(1, -30, 0, 2)
    toggleBtn.Size = UDim2.new(0, 25, 0, 20)
    toggleBtn.Text = default and "ON" or "OFF"
    toggleBtn.TextColor3 = default and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(150, 150, 150)
    toggleBtn.TextSize = 10
    toggleBtn.ZIndex = 1006
    toggleBtn.Parent = container

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = toggleBtn

    local state = default

    toggleBtn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            toggleBtn.BackgroundColor3 = themeSettings.accentColor
            toggleBtn.Text = "ON"
            toggleBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            toggleBtn.Text = "OFF"
            toggleBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        end
        if callback then
            callback(state)
        end
    end)

    return container
end

local function createDropdown(col, text, options, default, callback)
    local container = Instance.new("Frame")
    container.Name = text .. "Dropdown"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -20, 0, 45)
    container.ZIndex = 1004
    container.Parent = col.scrolling

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = themeSettings.secondaryTextColor
    label.TextSize = 14
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(1, -60, 0, 20)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 1005
    label.Parent = container

    local selectBtn = Instance.new("TextButton")
    selectBtn.BackgroundColor3 = themeSettings.buttonsColor
    selectBtn.BackgroundTransparency = themeSettings.buttonsTransparency
    selectBtn.Position = UDim2.new(0, 0, 0, 25)
    selectBtn.Size = UDim2.new(1, 0, 0, 20)
    selectBtn.Text = default or options[1]
    selectBtn.TextColor3 = themeSettings.textColor
    selectBtn.TextSize = 12
    selectBtn.ZIndex = 1006
    selectBtn.Parent = container

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = selectBtn

    local currentIndex = 1
    for i, opt in ipairs(options) do
        if opt == default then
            currentIndex = i
            break
        end
    end

    selectBtn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex % #options + 1
        selectBtn.Text = options[currentIndex]
        if callback then
            callback(options[currentIndex])
            if text == "ESP Mode" then
                features.espMode = options[currentIndex]
                updateESP()
            elseif text == "Particle Type" then
                particleFeatures.particleType = options[currentIndex]
            end
        end
    end)

    return selectBtn
end

local function createColorPicker(col, text, defaultColor, callback)
    local container = Instance.new("Frame")
    container.Name = text .. "Color"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, -20, 0, 25)
    container.ZIndex = 1004
    container.Parent = col.scrolling

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.Text = text
    label.TextColor3 = themeSettings.secondaryTextColor
    label.TextSize = 14
    label.Position = UDim2.new(0, 0, 0, 0)
    label.Size = UDim2.new(1, -40, 1, 0)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.ZIndex = 1005
    label.Parent = container

    local colorBtn = Instance.new("TextButton")
    colorBtn.BackgroundColor3 = defaultColor
    colorBtn.Position = UDim2.new(1, -30, 0, 2)
    colorBtn.Size = UDim2.new(0, 25, 0, 20)
    colorBtn.Text = ""
    colorBtn.ZIndex = 1006
    colorBtn.Parent = container

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = colorBtn

    local colors = {
        Color3.fromRGB(255, 80, 80),
        Color3.fromRGB(80, 140, 255),
        Color3.fromRGB(80, 255, 80),
        Color3.fromRGB(255, 255, 80),
        Color3.fromRGB(255, 80, 255),
        Color3.fromRGB(255, 255, 255),
    }
    local colorIndex = 1

    colorBtn.MouseButton1Click:Connect(function()
        colorIndex = colorIndex % #colors + 1
        colorBtn.BackgroundColor3 = colors[colorIndex]
        if callback then
            callback(colors[colorIndex])
            if text == "ESP Color" then
                features.espColor = colors[colorIndex]
                updateESP()
            elseif text == "Tracer Color" then
                features.espTracerColor = colors[colorIndex]
                updateESP()
            elseif text == "Team Color" then
                features.espTeamColor = colors[colorIndex]
                updateESP()
            elseif text == "Trail Color" then
                features.espTrailColor = colors[colorIndex]
                updateESP()
            elseif text == "Particle Color" then
                particleFeatures.color = colors[colorIndex]
            elseif text == "Акцент цвет" then
                themeSettings.accentColor = colors[colorIndex]
            end
        end
    end)

    return container
end

-- COMBAT
local aimbotBtn = createButton(cols.Combat, "Aimbot 360", false, function(on) features.aimbot = on end)
createSlider(cols.Combat, "Скорость", 0.1, 1, 0.5, function(val) features.aimbotSpeed = val end, "")
createSlider(cols.Combat, "FOV", 30, 180, 90, function(val) features.aimbotFOV = val end, "°")
createToggle(cols.Combat, "Показать FOV", false, function(on) features.aimbotShowFOV = on end)
local teamCheckBtn = createButton(cols.Combat, "Team Check (друзья)", false, function(on) 
    features.teamCheck = on 
    updateESP()
end)

-- MOVEMENT
local flyBtn = createButton(cols.Movement, "Fly", false, function(on) features.fly = on end)
createSlider(cols.Movement, "Скорость", 10, 200, 50, function(val) features.flySpeed = val end, "")
local noclipBtn = createButton(cols.Movement, "Noclip", false, function(on) features.noclip = on end)
local infJumpBtn = createButton(cols.Movement, "Inf Jump", false, function(on) features.infJump = on end)

-- VISUALS
local fullbrightBtn = createButton(cols.Visuals, "Fullbright", false, function(on) 
    features.fullbright = on
    if on then
        Lighting.Brightness = 5
        Lighting.ClockTime = 14
        Lighting.GlobalShadows = false
    else
        Lighting.Brightness = defaultBrightness
        Lighting.ClockTime = defaultClock
        Lighting.GlobalShadows = defaultShadows
    end
end)
local blurBtn = createButton(cols.Visuals, "Blur", false, function(on) 
    features.blur = on
    blur.Size = on and 16 or 0
end)

-- PLAYER
local clickTpBtn = createButton(cols.Player, "F+Click TP", false, function(on) features.clickTp = on end)
local killBtn = createButton(cols.Player, "Kill", false, function(on) 
    if on and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.Health = 0
    end
end)

-- ESP
local espBtn = createButton(cols.ESP, "ESP", false, function(on) 
    features.espEnabled = on
    updateESP()
end)
createDropdown(cols.ESP, "ESP Mode", {"Обводка", "Хитбокс", "Палочки"}, "Обводка", function(val) 
    features.espMode = val
    updateESP()
end)
createToggle(cols.ESP, "Показать имя", true, function(on) 
    features.espShowName = on
    updateESP()
end)
createToggle(cols.ESP, "Показать ХП", true, function(on) 
    features.espShowHealth = on
    updateESP()
end)
createToggle(cols.ESP, "Показать дист.", false, function(on) 
    features.espShowDistance = on
    updateESP()
end)
createToggle(cols.ESP, "Трейлы", false, function(on)
    features.espShowTrails = on
    updateESP()
end)
createSlider(cols.ESP, "Время трейла", 1, 10, 5, function(val)
    features.espTrailTime = val
    updateESP()
end, "s")
createColorPicker(cols.ESP, "ESP Color", features.espColor, function(color) 
    features.espColor = color
    updateESP()
end)
createColorPicker(cols.ESP, "Tracer Color", features.espTracerColor, function(color) 
    features.espTracerColor = color
    updateESP()
end)
createColorPicker(cols.ESP, "Team Color", features.espTeamColor, function(color) 
    features.espTeamColor = color
    updateESP()
end)
createColorPicker(cols.ESP, "Trail Color", features.espTrailColor, function(color)
    features.espTrailColor = color
    updateESP()
end)

-- MISC
local particlesBtn = createButton(cols.Misc, "Particles 3D", false, function(on)
    particleFeatures.enabled = on
end)
createDropdown(cols.Misc, "Particle Type", {"Шары 3D", "Огненные", "Ледяные", "Радужные"}, "Шары 3D", function(val)
    particleFeatures.particleType = val
end)
createSlider(cols.Misc, "Кол-во", 5, 50, 20, function(val)
    particleFeatures.count = math.floor(val)
end, "")
createSlider(cols.Misc, "Размер", 0.2, 2, 0.5, function(val)
    particleFeatures.size = val
end, "")
createSlider(cols.Misc, "Скорость", 5, 30, 10, function(val)
    particleFeatures.speed = val
end, "")
createSlider(cols.Misc, "Радиус", 20, 100, 50, function(val)
    particleFeatures.spread = val
end, "")
createSlider(cols.Misc, "Время жизни", 1, 10, 3, function(val)
    particleFeatures.lifetime = val
end, "s")
createColorPicker(cols.Misc, "Particle Color", particleFeatures.color, function(color)
    particleFeatures.color = color
end)
createDropdown(cols.Misc, "Время", {"День", "Ночь", "Закат", "Рассвет"}, "День", function(val)
    if val == "День" then
        Lighting.ClockTime = 14
        Lighting.Brightness = 5
        Lighting.GlobalShadows = false
    elseif val == "Ночь" then
        Lighting.ClockTime = 0
        Lighting.Brightness = 1
        Lighting.GlobalShadows = true
    elseif val == "Закат" then
        Lighting.ClockTime = 18
        Lighting.Brightness = 3
        Lighting.GlobalShadows = true
    elseif val == "Рассвет" then
        Lighting.ClockTime = 6
        Lighting.Brightness = 3
        Lighting.GlobalShadows = true
    end
end)
createButton(cols.Misc, "Unhook", false, function(on)
    if on then
        gui:Destroy()
        blur:Destroy()
    end
end)

-- THEME
local resetBtn = Instance.new("TextButton")
resetBtn.Name = "ResetBtn"
resetBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
resetBtn.Size = UDim2.new(1, -20, 0, 28)
resetBtn.Text = "Сбросить тему"
resetBtn.TextColor3 = Color3.new(1, 1, 1)
resetBtn.TextSize = 14
resetBtn.ZIndex = 1004
resetBtn.Parent = cols.Theme.scrolling

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = resetBtn

-- Настройки темы
createSlider(cols.Theme, "Затемнение фона", 0, 1, 0.5, function(val)
    themeSettings.bgDimTransparency = val
    bgDim.BackgroundTransparency = val
end, "")
createSlider(cols.Theme, "Прозрачность колонок", 0, 0.5, 0.1, function(val)
    themeSettings.columnsTransparency = val
    for name, col in pairs(cols) do
        col.frame.BackgroundTransparency = val
    end
end, "")
createSlider(cols.Theme, "Прозрачность кнопок", 0, 0.5, 0.2, function(val)
    themeSettings.buttonsTransparency = val
    for name, col in pairs(cols) do
        for _, child in ipairs(col.scrolling:GetChildren()) do
            if child:IsA("TextButton") and child.Name ~= "ResetBtn" then
                child.BackgroundTransparency = val
            end
        end
    end
end, "")
createSlider(cols.Theme, "Яркость UI", 0.5, 2, 1, function(val)
    themeSettings.brightness = val
    gui.Saturation = val
end, "x")

createColorPicker(cols.Theme, "Цвет фона", themeSettings.bgDimColor, function(color)
    themeSettings.bgDimColor = color
    bgDim.BackgroundColor3 = color
end)

createColorPicker(cols.Theme, "Цвет колонок", themeSettings.columnsColor, function(color)
    themeSettings.columnsColor = color
    for name, col in pairs(cols) do
        col.frame.BackgroundColor3 = color
    end
end)

createColorPicker(cols.Theme, "Цвет кнопок", themeSettings.buttonsColor, function(color)
    themeSettings.buttonsColor = color
    for name, col in pairs(cols) do
        for _, child in ipairs(col.scrolling:GetChildren()) do
            if child:IsA("TextButton") and child.Name ~= "ResetBtn" then
                child.BackgroundColor3 = color
            end
        end
    end
end)

createColorPicker(cols.Theme, "Акцент цвет", themeSettings.accentColor, function(color)
    themeSettings.accentColor = color
    for name, col in pairs(cols) do
        for _, child in ipairs(col.scrolling:GetChildren()) do
            if child:IsA("TextButton") then
                if child:FindFirstChild("Status") and child.Status.Text == "ON" then
                    child.BackgroundColor3 = color
                end
            end
            if child:IsA("Frame") and child.Name:find("Slider") then
                for _, sliderChild in ipairs(child:GetDescendants()) do
                    if sliderChild:IsA("Frame") and sliderChild.Parent and sliderChild.Parent:IsA("Frame") and sliderChild.Parent.Parent == child then
                        sliderChild.BackgroundColor3 = color
                    end
                end
            end
        end
    end
end)

createColorPicker(cols.Theme, "Цвет текста", themeSettings.textColor, function(color)
    themeSettings.textColor = color
    for name, col in pairs(cols) do
        col.frame.Title.TextColor3 = color
        for _, child in ipairs(col.scrolling:GetChildren()) do
            if child:IsA("TextButton") then
                for _, btnChild in ipairs(child:GetChildren()) do
                    if btnChild:IsA("TextLabel") and btnChild.Name ~= "Status" then
                        btnChild.TextColor3 = color
                    end
                end
            end
        end
    end
end)

-- Настройки минибара
createToggle(cols.Theme, "Минибар включен", true, function(on)
    themeSettings.miniBarEnabled = on
    if not uiContainer.Visible and on then
        miniBar.Visible = true
    elseif not on then
        miniBar.Visible = false
    end
end)

createToggle(cols.Theme, "Минибар: FPS", true, function(on)
    themeSettings.miniBarShowFPS = on
end)

createToggle(cols.Theme, "Минибар: Время", true, function(on)
    themeSettings.miniBarShowTime = on
end)

createToggle(cols.Theme, "Минибар: Пинг", true, function(on)
    themeSettings.miniBarShowPing = on
end)

resetBtn.MouseButton1Click:Connect(function()
    themeSettings.bgDimTransparency = 0.5
    themeSettings.bgDimColor = Color3.fromRGB(0, 0, 0)
    themeSettings.columnsTransparency = 0.1
    themeSettings.columnsColor = Color3.fromRGB(30, 30, 35)
    themeSettings.buttonsTransparency = 0.2
    themeSettings.buttonsColor = Color3.fromRGB(40, 40, 45)
    themeSettings.accentColor = Color3.fromRGB(60, 70, 120)
    themeSettings.textColor = Color3.fromRGB(255, 255, 255)
    themeSettings.secondaryTextColor = Color3.fromRGB(200, 200, 200)
    themeSettings.brightness = 1
    
    bgDim.BackgroundTransparency = 0.5
    bgDim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    gui.Saturation = 1
    
    for name, col in pairs(cols) do
        col.frame.BackgroundTransparency = 0.1
        col.frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        col.frame.Title.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        for _, child in ipairs(col.scrolling:GetChildren()) do
            if child:IsA("TextButton") and child.Name ~= "ResetBtn" then
                child.BackgroundTransparency = 0.2
                child.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                if child.Status and child.Status.Text == "ON" then
                    child.BackgroundColor3 = Color3.fromRGB(60, 70, 120)
                end
                for _, btnChild in ipairs(child:GetChildren()) do
                    if btnChild:IsA("TextLabel") and btnChild.Name ~= "Status" then
                        btnChild.TextColor3 = Color3.fromRGB(255, 255, 255)
                    end
                end
            end
        end
    end
end)

-- Мини-бар
local miniBar = Instance.new("Frame")
miniBar.Name = "MiniBar"
miniBar.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
miniBar.BackgroundTransparency = 0.1
miniBar.BorderSizePixel = 0
miniBar.Position = UDim2.new(0.5, -150, 0, 20)
miniBar.Size = UDim2.new(0, 300, 0, 50)
miniBar.Visible = false
miniBar.ZIndex = 2000
miniBar.Parent = main

local miniCorner = Instance.new("UICorner")
miniCorner.CornerRadius = UDim.new(0, 10)
miniCorner.Parent = miniBar

local miniText = Instance.new("TextLabel")
miniText.Name = "MiniBarText"
miniText.BackgroundTransparency = 1
miniText.Font = Enum.Font.Gotham
miniText.Text = "FPS: 60 | Time: 00:00 | Ping: 0ms"
miniText.TextColor3 = Color3.new(1, 1, 1)
miniText.TextSize = 16
miniText.Size = UDim2.new(1, -20, 1, 0)
miniText.Position = UDim2.new(0, 10, 0, 0)
miniText.TextXAlignment = Enum.TextXAlignment.Left
miniText.ZIndex = 2001
miniText.Parent = miniBar

spawn(function()
    while true do
        if miniBar.Visible and themeSettings.miniBarEnabled then
            local parts = {}
            if themeSettings.miniBarShowFPS then
                table.insert(parts, "FPS: " .. fps)
            end
            if themeSettings.miniBarShowTime then
                table.insert(parts, "Time: " .. currentTime)
            end
            if themeSettings.miniBarShowPing then
                table.insert(parts, "Ping: " .. ping .. "ms")
            end
            miniText.Text = table.concat(parts, " | ")
        end
        wait(0.1)
    end
end)

UIS.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.F8 then
            gui:Destroy()
            blur:Destroy()
        end
        
        if input.KeyCode == Enum.KeyCode.M then
            if uiContainer.Visible then
                uiContainer.Visible = false
                if themeSettings.miniBarEnabled then
                    miniBar.Visible = true
                end
                bgDim.Visible = false
                blur.Size = 0
            else
                uiContainer.Visible = true
                miniBar.Visible = false
                bgDim.Visible = true
                if features.blur then
                    blur.Size = 16
                end
            end
        end
    end
end)

print("UI загружен - Aimbot не наводится на друзей, Particles 3D, ESP с трейлами")
