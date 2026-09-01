--[[.txt
[file content begin]
--[[
    ========================================================
    XENO AIO CHIT HUB v3.5 - УЛУЧШЕННЫЙ ДИЗАЙН + SKELETON + TRIGGERBOT
    Разработан для Xeno Executor
    Стиль: Киберпанк (улучшенный)
    Ключи: Insert - Открыть/Закрыть меню
    ========================================================
]]

-- Безопасное выполнение
local success, err = pcall(function()

    -- ==================================================
    -- БЛОК 1: ИНИЦИАЛИЗАЦИЯ
    -- ==================================================

    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    local TweenService = game:GetService("TweenService")
    local Camera = workspace.CurrentCamera
    local LocalPlayer = Players.LocalPlayer
    local CoreGui = game:GetService("CoreGui")
    local HttpService = game:GetService("HttpService")
    local Debris = game:GetService("Debris")
    local Workspace = game:GetService("Workspace")

    local function clamp(val, min, max)
        return math.max(min, math.min(max, val))
    end

    -- Анти-детект (обновлён)
    local function AntiBan()
        if CoreGui:FindFirstChild("XenoHub") then
            CoreGui.XenoHub:Destroy()
        end
        local mt = getrawmetatable and getrawmetatable(game)
        if mt then
            local old = mt.__namecall
            mt.__namecall = function(...)
                local args = {...}
                local method = tostring(args[1])
                if method == "HttpGet" and args[2] and tostring(args[2]):find("games.roblox.com") then
                    return ""
                end
                return old and old(...)
            end
        end
    end
    AntiBan()

    -- ==================================================
    -- БЛОК 2: НАСТРОЙКИ
    -- ==================================================

    local Settings = {
        ESP_Enabled = false,
        Box = false,
        Name = false,
        Distance = false,
        Health = false,
        Tracer = false,
        Skeleton = false,
        HeadDot = false,
        Glow = false,
        FOV = 1000,
        Thickness = 2,
        Transparency = 0.6,
        HealthPos = "Left",
        TeamCheck = false,
        VisibleCheck = false,
        ShowWeapon = false,
        AntiAFK = false,
        UpdateRate = 5,
        Colors = {
            Box = Color3.fromRGB(0, 240, 255),
            Name = Color3.fromRGB(255, 255, 255),
            Distance = Color3.fromRGB(200, 200, 200),
            Tracer = Color3.fromRGB(255, 0, 255),
            Skeleton = Color3.fromRGB(0, 255, 255),
            Team = Color3.fromRGB(0, 255, 0),
            Enemy = Color3.fromRGB(255, 0, 0)
        }
    }

    local Features = {
        Aimbot = {
            Enabled = false,
            Smoothness = 0.3,
            MaxDistance = 200,
            FOV = 60,
            TargetPart = "Head",
            ShowFOV = false,
            VisibleCheck = false,
            -- [TRIGGERBOT] новые параметры
            Triggerbot = false,
            TriggerDelay = 0.1
        },
        Movement = {
            Fly = false,
            FlySpeed = 50,
            SpeedHack = false,
            SpeedValue = 32,
            Noclip = false
        },
        Misc = {
            GodMode = false,
            TeleportTarget = nil,
        }
    }

    -- [TRIGGERBOT] переменная для контроля времени последнего выстрела
    local lastShotTime = 0

    -- ==================================================
    -- БЛОК 3: GUI + ВОДЯНОЙ ЗНАК (УЛУЧШЕННЫЙ ДИЗАЙН)
    -- ==================================================

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "XenoHub_" .. math.random(1000, 9999)
    ScreenGui.Parent = CoreGui

    -- Водяной знак (с улучшенной стилизацией)
    local WatermarkFrame = Instance.new("Frame")
    WatermarkFrame.Name = "Watermark"
    WatermarkFrame.Size = UDim2.new(0, 210, 0, 115)
    WatermarkFrame.Position = UDim2.new(1, -225, 1, -130)
    WatermarkFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 28)
    WatermarkFrame.BackgroundTransparency = 0.15
    WatermarkFrame.BorderSizePixel = 0
    WatermarkFrame.Parent = ScreenGui

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 14)
    Corner.Parent = WatermarkFrame

    -- Неоновая рамка (толще)
    local Glow = Instance.new("Frame")
    Glow.Size = UDim2.new(1, 6, 1, 6)
    Glow.Position = UDim2.new(0, -3, 0, -3)
    Glow.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
    Glow.BackgroundTransparency = 0.6
    Glow.BorderSizePixel = 0
    Glow.Parent = WatermarkFrame

    -- Градиент для водяного знака
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 240, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 0, 170)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 240, 255))
    })
    grad.Rotation = 45
    grad.Parent = Glow

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, 0, 0, 30)
    TitleLabel.Position = UDim2.new(0, 0, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "✦ Lino ✦"
    TitleLabel.TextColor3 = Color3.fromRGB(0, 240, 255)
    TitleLabel.TextSize = 22
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
    TitleLabel.Parent = WatermarkFrame

    local NameLabel = Instance.new("TextLabel")
    NameLabel.Size = UDim2.new(1, 0, 0, 22)
    NameLabel.Position = UDim2.new(0, 0, 0, 32)
    NameLabel.BackgroundTransparency = 1
    NameLabel.Text = LocalPlayer.Name
    NameLabel.TextColor3 = Color3.fromRGB(200, 200, 255)
    NameLabel.TextSize = 16
    NameLabel.Font = Enum.Font.Gotham
    NameLabel.TextXAlignment = Enum.TextXAlignment.Center
    NameLabel.Parent = WatermarkFrame

    local DateLabel = Instance.new("TextLabel")
    DateLabel.Size = UDim2.new(1, 0, 0, 20)
    DateLabel.Position = UDim2.new(0, 0, 0, 56)
    DateLabel.BackgroundTransparency = 1
    DateLabel.Text = os.date("%d.%m.%Y %H:%M")
    DateLabel.TextColor3 = Color3.fromRGB(180, 180, 220)
    DateLabel.TextSize = 13
    DateLabel.Font = Enum.Font.Gotham
    DateLabel.TextXAlignment = Enum.TextXAlignment.Center
    DateLabel.Parent = WatermarkFrame

    local FPSLabel = Instance.new("TextLabel")
    FPSLabel.Size = UDim2.new(1, 0, 0, 20)
    FPSLabel.Position = UDim2.new(0, 0, 0, 78)
    FPSLabel.BackgroundTransparency = 1
    FPSLabel.Text = "FPS: 0"
    FPSLabel.TextColor3 = Color3.fromRGB(0, 255, 170)
    FPSLabel.TextSize = 14
    FPSLabel.Font = Enum.Font.Gotham
    FPSLabel.TextXAlignment = Enum.TextXAlignment.Center
    FPSLabel.Parent = WatermarkFrame

    local frameCount = 0
    local lastTime = tick()

    task.spawn(function()
        while true do
            task.wait(1)
            DateLabel.Text = os.date("%d.%m.%Y %H:%M")
            local currentTime = tick()
            local delta = currentTime - lastTime
            if delta > 0 then
                local fps = math.floor(frameCount / delta)
                FPSLabel.Text = "FPS: " .. fps
                frameCount = 0
                lastTime = currentTime
            end
        end
    end)

    RunService.RenderStepped:Connect(function()
        frameCount = frameCount + 1
    end)

    -- ==================================================
    -- ГЛАВНОЕ МЕНЮ (УЛУЧШЕННЫЙ ДИЗАЙН)
    -- ==================================================

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 580, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -290, 0.5, -260)
    MainFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 28)
    MainFrame.BackgroundTransparency = 0.08
    MainFrame.BorderSizePixel = 0
    MainFrame.Parent = ScreenGui
    MainFrame.Visible = false

    -- Стеклянный эффект (градиент)
    local glass = Instance.new("UIGradient")
    glass.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 10, 40)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(20, 10, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 40))
    })
    glass.Rotation = 90
    glass.Parent = MainFrame

    -- Тень
    local shadow = Instance.new("Frame")
    shadow.Size = UDim2.new(1, 10, 1, 10)
    shadow.Position = UDim2.new(0, -5, 0, -5)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.6
    shadow.BorderSizePixel = 0
    shadow.ZIndex = 0
    shadow.Parent = MainFrame
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 16)
    shadowCorner.Parent = shadow

    -- Неоновая рамка (двойная)
    local GlowBorder = Instance.new("Frame")
    GlowBorder.Size = UDim2.new(1, 6, 1, 6)
    GlowBorder.Position = UDim2.new(0, -3, 0, -3)
    GlowBorder.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
    GlowBorder.BackgroundTransparency = 0.7
    GlowBorder.BorderSizePixel = 0
    GlowBorder.ZIndex = 1
    GlowBorder.Parent = MainFrame
    local glowCorner = Instance.new("UICorner")
    glowCorner.CornerRadius = UDim.new(0, 16)
    glowCorner.Parent = GlowBorder

    local GlowBorder2 = Instance.new("Frame")
    GlowBorder2.Size = UDim2.new(1, 2, 1, 2)
    GlowBorder2.Position = UDim2.new(0, -1, 0, -1)
    GlowBorder2.BackgroundColor3 = Color3.fromRGB(255, 0, 170)
    GlowBorder2.BackgroundTransparency = 0.8
    GlowBorder2.BorderSizePixel = 0
    GlowBorder2.ZIndex = 1
    GlowBorder2.Parent = MainFrame
    local glowCorner2 = Instance.new("UICorner")
    glowCorner2.CornerRadius = UDim.new(0, 16)
    glowCorner2.Parent = GlowBorder2

    -- Заголовок
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 45)
    Title.Position = UDim2.new(0, 0, 0, 0)
    Title.BackgroundColor3 = Color3.fromRGB(20, 20, 50)
    Title.BackgroundTransparency = 0.3
    Title.Text = "⚡ XENO HUB v3.5 ⚡"
    Title.TextColor3 = Color3.fromRGB(0, 240, 255)
    Title.TextSize = 24
    Title.Font = Enum.Font.GothamBold
    Title.BorderSizePixel = 0
    Title.Parent = MainFrame

    -- Панель вкладок (с градиентом)
    local TabBar = Instance.new("Frame")
    TabBar.Size = UDim2.new(1, 0, 0, 40)
    TabBar.Position = UDim2.new(0, 0, 0, 45)
    TabBar.BackgroundColor3 = Color3.fromRGB(15, 15, 40)
    TabBar.BackgroundTransparency = 0.5
    TabBar.BorderSizePixel = 0
    TabBar.Parent = MainFrame
    local tabGrad = Instance.new("UIGradient")
    tabGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 30))
    })
    tabGrad.Rotation = 90
    tabGrad.Parent = TabBar

    local Tabs = {"ESP", "Aimbot", "Movement", "Misc"}
    local TabButtons = {}
    local CurrentTab = "ESP"

    local ContentContainer = Instance.new("ScrollingFrame")
    ContentContainer.Size = UDim2.new(1, -20, 1, -100)
    ContentContainer.Position = UDim2.new(0, 10, 0, 90)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.BorderSizePixel = 0
    ContentContainer.CanvasSize = UDim2.new(0, 0, 0, 600)
    ContentContainer.ScrollBarThickness = 4
    ContentContainer.ScrollBarImageColor3 = Color3.fromRGB(0, 240, 255)
    ContentContainer.Parent = MainFrame

    local ContentLayout = Instance.new("UIListLayout")
    ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentLayout.Padding = UDim.new(0, 6)
    ContentLayout.Parent = ContentContainer

    -- Создание кнопок вкладок с анимацией
    local function CreateTabButton(tabName, index)
        local btn = Instance.new("TextButton")
        local tabCount = #Tabs
        btn.Size = UDim2.new(1/tabCount, -4, 1, -6)
        btn.Position = UDim2.new((index-1)/tabCount, 2, 0, 3)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 55)
        btn.BackgroundTransparency = 0.3
        btn.Text = tabName
        btn.TextColor3 = Color3.fromRGB(180, 180, 255)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamSemibold
        btn.BorderSizePixel = 0
        btn.Parent = TabBar
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 8)
        btnCorner.Parent = btn

        btn.MouseEnter:Connect(function()
            if CurrentTab ~= tabName then
                TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(40, 40, 80)}):Play()
            end
        end)
        btn.MouseLeave:Connect(function()
            if CurrentTab ~= tabName then
                TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {BackgroundColor3 = Color3.fromRGB(25, 25, 55)}):Play()
            end
        end)

        btn.MouseButton1Click:Connect(function()
            CurrentTab = tabName
            for _, b in pairs(TabButtons) do
                TweenService:Create(b, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = Color3.fromRGB(25, 25, 55),
                    TextColor3 = Color3.fromRGB(180, 180, 255)
                }):Play()
            end
            TweenService:Create(btn, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                BackgroundColor3 = Color3.fromRGB(0, 240, 255),
                TextColor3 = Color3.fromRGB(0, 0, 0)
            }):Play()
            RefreshContent()
        end)

        TabButtons[tabName] = btn
        return btn
    end

    for i, name in ipairs(Tabs) do
        CreateTabButton(name, i)
    end

    -- ==================================================
    -- БЛОК 4: КОНТРОЛЛЫ (УЛУЧШЕННЫЕ)
    -- ==================================================

    local ContentElements = {}

    function ClearContent()
        for _, elem in ipairs(ContentElements) do
            pcall(function()
                if elem and elem.Parent then
                    elem:Destroy()
                end
            end)
        end
        ContentElements = {}
    end

    function AddToggle(name, state, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 38)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
        frame.BackgroundTransparency = 0.3
        frame.LayoutOrder = #ContentElements
        frame.Parent = ContentContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame
        
        table.insert(ContentElements, frame)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -70, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(220, 220, 240)
        label.TextSize = 15
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.Parent = frame
        
        local toggleBg = Instance.new("Frame")
        toggleBg.Size = UDim2.new(0, 50, 0, 26)
        toggleBg.Position = UDim2.new(1, -60, 0.5, -13)
        toggleBg.BackgroundColor3 = state and Color3.fromRGB(0, 240, 255) or Color3.fromRGB(60, 60, 80)
        toggleBg.Parent = frame
        local toggleCorner = Instance.new("UICorner")
        toggleCorner.CornerRadius = UDim.new(1, 0)
        toggleCorner.Parent = toggleBg
        
        local toggleCircle = Instance.new("Frame")
        toggleCircle.Size = UDim2.new(0, 20, 0, 20)
        toggleCircle.Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
        toggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        toggleCircle.Parent = toggleBg
        local circleCorner = Instance.new("UICorner")
        circleCorner.CornerRadius = UDim.new(1, 0)
        circleCorner.Parent = toggleCircle
        
        toggleBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                state = not state
                TweenService:Create(toggleBg, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                    BackgroundColor3 = state and Color3.fromRGB(0, 240, 255) or Color3.fromRGB(60, 60, 80)
                }):Play()
                TweenService:Create(toggleCircle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    Position = state and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
                }):Play()
                if callback then callback(state) end
            end
        end)
    end

    function AddSlider(name, min, max, default, step, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 50)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
        frame.BackgroundTransparency = 0.3
        frame.LayoutOrder = #ContentElements
        frame.Parent = ContentContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame
        
        table.insert(ContentElements, frame)
        
        local valueLabel = Instance.new("TextLabel")
        valueLabel.Size = UDim2.new(1, 0, 0, 20)
        valueLabel.BackgroundTransparency = 1
        valueLabel.Text = name .. ": " .. tostring(default)
        valueLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
        valueLabel.TextSize = 15
        valueLabel.Font = Enum.Font.GothamMedium
        valueLabel.TextXAlignment = Enum.TextXAlignment.Left
        valueLabel.Parent = frame
        
        local sliderBg = Instance.new("Frame")
        sliderBg.Size = UDim2.new(1, -20, 0, 12)
        sliderBg.Position = UDim2.new(0, 10, 1, -20)
        sliderBg.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        sliderBg.Parent = frame
        
        local sliderCorner = Instance.new("UICorner")
        sliderCorner.CornerRadius = UDim.new(0, 6)
        sliderCorner.Parent = sliderBg
        
        local sliderFill = Instance.new("Frame")
        sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        sliderFill.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
        sliderFill.Parent = sliderBg
        
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(0, 6)
        fillCorner.Parent = sliderFill
        
        local sliderKnob = Instance.new("Frame")
        sliderKnob.Size = UDim2.new(0, 16, 0, 16)
        sliderKnob.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
        sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        sliderKnob.Parent = sliderBg
        
        local knobCorner = Instance.new("UICorner")
        knobCorner.CornerRadius = UDim.new(1, 0)
        knobCorner.Parent = sliderKnob
        
        local isDragging = false
        
        sliderBg.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = true
            end
        end)
        
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isDragging = false
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local percent = clamp(
                    (input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 
                    0, 1
                )
                local val = math.floor(min + (max - min) * percent / step + 0.5) * step
                val = clamp(val, min, max)
                sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                sliderKnob.Position = UDim2.new(percent, -8, 0.5, -8)
                valueLabel.Text = name .. ": " .. tostring(val)
                if callback then callback(val) end
            end
        end)
    end

    function AddColorPicker(name, color, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 0, 40)
        frame.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
        frame.BackgroundTransparency = 0.3
        frame.LayoutOrder = #ContentElements
        frame.Parent = ContentContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = frame
        
        table.insert(ContentElements, frame)
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = name
        label.TextColor3 = Color3.fromRGB(220, 220, 240)
        label.TextSize = 15
        label.Font = Enum.Font.GothamMedium
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local colorBox = Instance.new("Frame")
        colorBox.Size = UDim2.new(0, 40, 0, 30)
        colorBox.Position = UDim2.new(1, -50, 0.5, -15)
        colorBox.BackgroundColor3 = color
        colorBox.Parent = frame
        
        local boxCorner = Instance.new("UICorner")
        boxCorner.CornerRadius = UDim.new(0, 6)
        boxCorner.Parent = colorBox
        
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 1
        stroke.Parent = colorBox
        
        local hue = 0
        colorBox.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                hue = (hue + 0.1) % 1
                local newColor = Color3.fromHSV(hue, 1, 1)
                colorBox.BackgroundColor3 = newColor
                if callback then callback(newColor) end
            end
        end)
    end

    function AddActionButton(name, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 38)
        btn.Position = UDim2.new(0.05, 0, 0, #ContentElements * 42 + 5)
        btn.BackgroundColor3 = Color3.fromRGB(0, 240, 255)
        btn.BackgroundTransparency = 0.2
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(0, 0, 0)
        btn.TextSize = 16
        btn.Font = Enum.Font.GothamBold
        btn.BorderSizePixel = 0
        btn.LayoutOrder = #ContentElements
        btn.Parent = ContentContainer
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = btn
        
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.05}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundTransparency = 0.2}):Play()
        end)
        
        table.insert(ContentElements, btn)
        btn.MouseButton1Click:Connect(callback)
    end

    -- ==================================================
    -- БЛОК 5: ЗАПОЛНЕНИЕ ВКЛАДОК
    -- ==================================================

    function RefreshContent()
        ClearContent()
        
        if CurrentTab == "ESP" then
            AddToggle("✨ ESP Enabled", Settings.ESP_Enabled, function(v) Settings.ESP_Enabled = v end)
            AddToggle("📦 Box ESP", Settings.Box, function(v) Settings.Box = v end)
            AddToggle("🏷️ Player Names", Settings.Name, function(v) Settings.Name = v end)
            AddToggle("📏 Distance", Settings.Distance, function(v) Settings.Distance = v end)
            AddToggle("🎯 Tracers", Settings.Tracer, function(v) Settings.Tracer = v end)
            AddToggle("💀 Skeleton", Settings.Skeleton, function(v) Settings.Skeleton = v end)
            AddToggle("⭕ Head Dot", Settings.HeadDot, function(v) Settings.HeadDot = v end)
            AddToggle("❤️ Health Bar", Settings.Health, function(v) Settings.Health = v end)
            AddColorPicker("Skeleton Color", Settings.Colors.Skeleton, function(c) Settings.Colors.Skeleton = c end)
            AddSlider("Line Thickness", 1, 5, Settings.Thickness, 1, function(v) Settings.Thickness = v end)
            AddSlider("FOV Range", 100, 2000, Settings.FOV, 50, function(v) Settings.FOV = v end)
            
        elseif CurrentTab == "Aimbot" then
            AddToggle("🎯 Aimbot", Features.Aimbot.Enabled, function(v) Features.Aimbot.Enabled = v end)
            -- [TRIGGERBOT] добавлены новые элементы управления
            AddToggle("🔫 Triggerbot", Features.Aimbot.Triggerbot, function(v) Features.Aimbot.Triggerbot = v end)
            AddSlider("Задержка выстрела (сек)", 0.05, 1, Features.Aimbot.TriggerDelay, 0.05, function(v) Features.Aimbot.TriggerDelay = v end)
            AddSlider("Сглаживание", 0.1, 1, Features.Aimbot.Smoothness, 0.1, function(v) Features.Aimbot.Smoothness = v end)
            AddSlider("Макс. дистанция", 50, 500, Features.Aimbot.MaxDistance, 10, function(v) Features.Aimbot.MaxDistance = v end)
            AddSlider("FOV (градусы)", 10, 180, Features.Aimbot.FOV, 5, function(v) Features.Aimbot.FOV = v end)
            AddToggle("Показывать FOV", Features.Aimbot.ShowFOV, function(v) Features.Aimbot.ShowFOV = v end)
            AddToggle("Только видимые", Features.Aimbot.VisibleCheck, function(v) Features.Aimbot.VisibleCheck = v end)
            
        elseif CurrentTab == "Movement" then
            AddToggle("🪁 Fly", Features.Movement.Fly, function(v) 
                Features.Movement.Fly = v
                ApplyFlyState(v)
            end)
            AddSlider("Скорость Fly", 10, 200, Features.Movement.FlySpeed, 5, function(v) Features.Movement.FlySpeed = v end)
            AddToggle("💨 Speed Hack", Features.Movement.SpeedHack, function(v) Features.Movement.SpeedHack = v end)
            AddSlider("Скорость бега", 16, 200, Features.Movement.SpeedValue, 1, function(v) Features.Movement.SpeedValue = v end)
            AddToggle("🧱 Noclip", Features.Movement.Noclip, function(v) 
                Features.Movement.Noclip = v
                ApplyNoclipState(v)
            end)
            
        elseif CurrentTab == "Misc" then
            AddToggle("👑 God Mode", Features.Misc.GodMode, function(v) Features.Misc.GodMode = v end)
            AddToggle("👥 Team Check", Settings.TeamCheck, function(v) Settings.TeamCheck = v end)
            AddToggle("👁️ Visible Only", Settings.VisibleCheck, function(v) Settings.VisibleCheck = v end)
            AddToggle("🛡️ Anti-AFK", Settings.AntiAFK, function(v) Settings.AntiAFK = v end)
            
            AddActionButton("🔄 Server Hop", function()
                pcall(function()
                    local ts = game:GetService("TeleportService")
                    local placeId = game.PlaceId
                    local servers = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?limit=100"))
                    if servers and servers.data then
                        local validServers = {}
                        for _, v in pairs(servers.data) do
                            if v.id ~= game.JobId and v.playing < v.maxPlayers then
                                table.insert(validServers, v.id)
                            end
                        end
                        if #validServers > 0 then
                            ts:Teleport(placeId, LocalPlayer, validServers[math.random(1, #validServers)])
                        end
                    end
                end)
            end)
            
            AddActionButton("🔄 Rejoin", function()
                pcall(function()
                    local ts = game:GetService("TeleportService")
                    ts:Teleport(game.PlaceId, LocalPlayer)
                end)
            end)
            
            AddActionButton("🔄 Сбросить всё", function()
                Features.Movement.Fly = false
                Features.Movement.SpeedHack = false
                Features.Movement.Noclip = false
                Features.Misc.GodMode = false
                Settings.ESP_Enabled = false
                Features.Aimbot.Enabled = false
                ApplyFlyState(false)
                ApplyNoclipState(false)

                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChild("Humanoid")
                    local root = char:FindFirstChild("HumanoidRootPart")
                    if hum then
                        hum.WalkSpeed = 16
                        hum.PlatformStand = false
                        hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
                    end
                    if root then
                        local bv = root:FindFirstChild("FlyVelocity")
                        if bv then bv:Destroy() end
                        local bf = root:FindFirstChild("NoclipForce")
                        if bf then bf:Destroy() end
                        root.Velocity = Vector3.new(0, 0, 0)
                    end
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
                print("✅ Все читы сброшены, персонаж восстановлен")
            end)
        end
    end

    RefreshContent()
    TabButtons["ESP"].BackgroundColor3 = Color3.fromRGB(0, 240, 255)
    TabButtons["ESP"].TextColor3 = Color3.fromRGB(0, 0, 0)

    -- ==================================================
    -- БЛОК 6: ФУНКЦИИ ПРИМЕНЕНИЯ СОСТОЯНИЙ (ИСПРАВЛЕН NOCLIP)
    -- ==================================================

    -- Применение Noclip с компенсацией гравитации (надёжная версия)
    function ApplyNoclipState(enabled)
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not root or not hum then return end

        -- Удаляем старый BodyForce, если есть
        local oldForce = root:FindFirstChild("NoclipForce")
        if oldForce then oldForce:Destroy() end

        if enabled then
            -- Отключаем коллизию у всех частей, включая HumanoidRootPart
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
            -- Если Fly выключен, добавляем компенсирующую силу (чтобы не падать)
            if not Features.Movement.Fly then
                local bf = Instance.new("BodyForce")
                bf.Name = "NoclipForce"
                bf.Force = Vector3.new(0, Workspace.Gravity * hum.Mass, 0)
                bf.Parent = root
            end
            -- PlatformStand НЕ включаем, чтобы можно было ходить
        else
            -- Включаем коллизию у всех частей
            for _, part in pairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
            -- Если Fly выключен, убеждаемся, что PlatformStand выключен
            if not Features.Movement.Fly then
                hum.PlatformStand = false
            end
            -- Удаляем BodyForce (на всякий случай)
            local bf = root:FindFirstChild("NoclipForce")
            if bf then bf:Destroy() end
        end
    end

    -- Применение Fly (используем BodyVelocity и PlatformStand)
    function ApplyFlyState(enabled)
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not root or not hum then return end

        if enabled then
            -- Создаём BodyVelocity для полёта
            local bv = root:FindFirstChild("FlyVelocity")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "FlyVelocity"
                bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bv.P = 1e5
                bv.Parent = root
            end
            hum.PlatformStand = true
            -- Если Noclip включён, убираем его BodyForce, чтобы не конфликтовали
            if Features.Movement.Noclip then
                local bf = root:FindFirstChild("NoclipForce")
                if bf then bf:Destroy() end
            end
        else
            -- Удаляем BodyVelocity
            local bv = root:FindFirstChild("FlyVelocity")
            if bv then bv:Destroy() end
            -- Если Noclip выключен, отключаем PlatformStand
            if not Features.Movement.Noclip then
                hum.PlatformStand = false
            end
            root.Velocity = Vector3.new(0, 0, 0)
            -- Если Noclip включён, восстанавливаем его BodyForce
            if Features.Movement.Noclip then
                local bf = root:FindFirstChild("NoclipForce")
                if not bf then
                    bf = Instance.new("BodyForce")
                    bf.Name = "NoclipForce"
                    bf.Force = Vector3.new(0, Workspace.Gravity * hum.Mass, 0)
                    bf.Parent = root
                end
            end
        end
    end

    -- ==================================================
    -- БЛОК 7: ESP СИСТЕМА (ДОБАВЛЕН SKELETON)
    -- ==================================================

    local ESP_Objects = {}

    local function CleanupESPObjects(player)
        local objs = ESP_Objects[player]
        if objs then
            for _, obj in pairs(objs) do
                if obj and obj.Remove then
                    pcall(function() obj:Remove() end)
                end
            end
            ESP_Objects[player] = nil
        end
    end

    Players.PlayerRemoving:Connect(function(player)
        CleanupESPObjects(player)
    end)

    local function IsValidTarget(player)
        if not player or player == LocalPlayer then return false end
        local char = player.Character
        if not char or not char.Parent then return false end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp or not hrp.Parent then return false end
        
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then return false end
        
        if Settings.VisibleCheck then
            local origin = Camera.CFrame.Position
            local target = hrp.Position
            local direction = (target - origin).Unit
            local params = RaycastParams.new()
            params.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
            params.FilterType = Enum.RaycastFilterType.Blacklist
            local result = workspace:Raycast(origin, direction * 1000, params)
            if result then
                local hit = result.Instance
                if hit and hit:IsDescendantOf(char) then return true else return false end
            else
                return false
            end
        end
        return true
    end

    local function GetColor(player)
        if Settings.TeamCheck and player.Team == LocalPlayer.Team then
            return Settings.Colors.Team
        end
        return Settings.Colors.Enemy
    end

    -- Функция для отрисовки скелета
    local function DrawSkeleton(player, color, transparency)
        local char = player.Character
        if not char then return end

        local parts = {
            Head = char:FindFirstChild("Head"),
            UpperTorso = char:FindFirstChild("UpperTorso"),
            LowerTorso = char:FindFirstChild("LowerTorso"),
            LeftHand = char:FindFirstChild("LeftHand"),
            RightHand = char:FindFirstChild("RightHand"),
            LeftFoot = char:FindFirstChild("LeftFoot"),
            RightFoot = char:FindFirstChild("RightFoot"),
        }

        -- Проверяем наличие всех частей
        for name, part in pairs(parts) do
            if not part or not part.Parent then return end
        end

        -- Создаём или обновляем линии в ESP_Objects[player].SkeletonLines
        local obj = ESP_Objects[player]
        if not obj.SkeletonLines then
            obj.SkeletonLines = {}
            for i = 1, 6 do
                local line = Drawing.new("Line")
                line.Thickness = Settings.Thickness
                line.Transparency = Settings.Transparency
                obj.SkeletonLines[i] = line
            end
        end

        -- Получаем позиции частей в координатах экрана
        local headPos, headOn = Camera:WorldToViewportPoint(parts.Head.Position)
        local upperPos, upperOn = Camera:WorldToViewportPoint(parts.UpperTorso.Position)
        local lowerPos, lowerOn = Camera:WorldToViewportPoint(parts.LowerTorso.Position)
        local lHandPos, lHandOn = Camera:WorldToViewportPoint(parts.LeftHand.Position)
        local rHandPos, rHandOn = Camera:WorldToViewportPoint(parts.RightHand.Position)
        local lFootPos, lFootOn = Camera:WorldToViewportPoint(parts.LeftFoot.Position)
        local rFootPos, rFootOn = Camera:WorldToViewportPoint(parts.RightFoot.Position)

        -- Если какая-то часть не на экране, скрываем все линии
        if not (headOn and upperOn and lowerOn and lHandOn and rHandOn and lFootOn and rFootOn) then
            for _, line in pairs(obj.SkeletonLines) do
                line.Visible = false
            end
            return
        end

        local lines = obj.SkeletonLines
        -- Голова → Верхняя часть туловища
        lines[1].From = Vector2.new(headPos.X, headPos.Y)
        lines[1].To = Vector2.new(upperPos.X, upperPos.Y)
        lines[1].Color = color
        lines[1].Visible = true

        -- Верхняя часть туловища → Нижняя часть туловища
        lines[2].From = Vector2.new(upperPos.X, upperPos.Y)
        lines[2].To = Vector2.new(lowerPos.X, lowerPos.Y)
        lines[2].Color = color
        lines[2].Visible = true

        -- Верхняя часть туловища → Левая рука
        lines[3].From = Vector2.new(upperPos.X, upperPos.Y)
        lines[3].To = Vector2.new(lHandPos.X, lHandPos.Y)
        lines[3].Color = color
        lines[3].Visible = true

        -- Верхняя часть туловища → Правая рука
        lines[4].From = Vector2.new(upperPos.X, upperPos.Y)
        lines[4].To = Vector2.new(rHandPos.X, rHandPos.Y)
        lines[4].Color = color
        lines[4].Visible = true

        -- Нижняя часть туловища → Левая нога
        lines[5].From = Vector2.new(lowerPos.X, lowerPos.Y)
        lines[5].To = Vector2.new(lFootPos.X, lFootPos.Y)
        lines[5].Color = color
        lines[5].Visible = true

        -- Нижняя часть туловища → Правая нога
        lines[6].From = Vector2.new(lowerPos.X, lowerPos.Y)
        lines[6].To = Vector2.new(rFootPos.X, rFootPos.Y)
        lines[6].Color = color
        lines[6].Visible = true
    end

    local function UpdateESP()
        if not Settings.ESP_Enabled then
            for _, objs in pairs(ESP_Objects) do
                if objs.Box then objs.Box.Visible = false end
                if objs.Name then objs.Name.Visible = false end
                if objs.Distance then objs.Distance.Visible = false end
                if objs.Tracer then objs.Tracer.Visible = false end
                if objs.HeadDot then objs.HeadDot.Visible = false end
                if objs.Skeleton then 
                    if objs.SkeletonLines then
                        for _, line in pairs(objs.SkeletonLines) do
                            line.Visible = false
                        end
                    end
                end
                if objs.Health then objs.Health.Visible = false end
            end
            return
        end

        for _, player in pairs(Players:GetPlayers()) do
            if IsValidTarget(player) then
                local char = player.Character
                if not char or not char.Parent then continue end
                local hrp = char:FindFirstChild("HumanoidRootPart")
                local head = char:FindFirstChild("Head")
                local hum = char:FindFirstChild("Humanoid")
                if hrp and hrp.Parent and head and head.Parent then
                    local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                    
                    if not ESP_Objects[player] then
                        ESP_Objects[player] = {
                            Box = Drawing.new("Square"),
                            Name = Drawing.new("Text"),
                            Distance = Drawing.new("Text"),
                            Tracer = Drawing.new("Line"),
                            HeadDot = Drawing.new("Circle"),
                            SkeletonLines = {},
                            Health = Drawing.new("Line")
                        }
                        local o = ESP_Objects[player]
                        o.Box.Filled = false
                        o.Name.Size = 14
                        o.Name.Font = Drawing.Fonts.UI
                        o.Name.Outline = true
                        o.Name.Center = true
                        o.Distance.Size = 13
                        o.Distance.Font = Drawing.Fonts.UI
                        o.Distance.Outline = true
                        o.Distance.Center = true
                        o.Tracer.Thickness = 1
                        o.HeadDot.Filled = true
                        o.HeadDot.NumSides = 16
                        o.Health.Thickness = 3
                        -- Инициализируем линии скелета
                        for i = 1, 6 do
                            local line = Drawing.new("Line")
                            line.Thickness = Settings.Thickness
                            line.Transparency = Settings.Transparency
                            line.Visible = false
                            o.SkeletonLines[i] = line
                        end
                    end
                    
                    local o = ESP_Objects[player]
                    local color = GetColor(player)
                    local dist = math.floor((hrp.Position - Camera.CFrame.Position).Magnitude)
                    local size = math.clamp(10000 / math.max(dist, 1), 10, 500)
                    local x, y = pos.X, pos.Y
                    
                    -- Box
                    if Settings.Box then
                        o.Box.Visible = onScreen
                        if onScreen then
                            o.Box.Position = Vector2.new(x - size/2, y - size/2)
                            o.Box.Size = Vector2.new(size, size * 1.5)
                            o.Box.Color = color
                            o.Box.Thickness = Settings.Thickness
                            o.Box.Transparency = Settings.Transparency
                        end
                    else o.Box.Visible = false end
                    
                    -- Name
                    if Settings.Name then
                        o.Name.Visible = onScreen
                        if onScreen then
                            o.Name.Position = Vector2.new(x, y - size/2 - 20)
                            o.Name.Text = player.Name
                            o.Name.Color = Settings.Colors.Name
                        end
                    else o.Name.Visible = false end
                    
                    -- Distance
                    if Settings.Distance then
                        o.Distance.Visible = onScreen
                        if onScreen then
                            o.Distance.Position = Vector2.new(x, y + size/2 + 10)
                            o.Distance.Text = dist .. "m"
                            o.Distance.Color = Settings.Colors.Distance
                        end
                    else o.Distance.Visible = false end
                    
                    -- Tracer
                    if Settings.Tracer then
                        o.Tracer.Visible = onScreen
                        if onScreen then
                            o.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                            o.Tracer.To = Vector2.new(x, y)
                            o.Tracer.Color = Settings.Colors.Tracer
                            o.Tracer.Transparency = Settings.Transparency
                        end
                    else o.Tracer.Visible = false end
                    
                    -- HeadDot
                    if Settings.HeadDot then
                        local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
                        o.HeadDot.Visible = headOnScreen
                        if headOnScreen then
                            o.HeadDot.Position = Vector2.new(headPos.X, headPos.Y)
                            o.HeadDot.Radius = 5
                            o.HeadDot.Color = color
                            o.HeadDot.Transparency = Settings.Transparency
                        end
                    else o.HeadDot.Visible = false end
                    
                    -- Skeleton
                    if Settings.Skeleton then
                        DrawSkeleton(player, Settings.Colors.Skeleton, Settings.Transparency)
                    else
                        if o.SkeletonLines then
                            for _, line in pairs(o.SkeletonLines) do
                                line.Visible = false
                            end
                        end
                    end
                    
                    -- Health
                    if Settings.Health and hum then
                        o.Health.Visible = onScreen
                        if onScreen then
                            local hpPercent = hum.Health / hum.MaxHealth
                            local healthHeight = size * 1.5
                            local healthX = x + size/2 + 5
                            if Settings.HealthPos == "Left" then
                                healthX = x - size/2 - 5
                            end
                            o.Health.From = Vector2.new(healthX, y - healthHeight/2)
                            o.Health.To = Vector2.new(healthX, y - healthHeight/2 + healthHeight * hpPercent)
                            o.Health.Color = Color3.fromRGB(255 * (1 - hpPercent), 255 * hpPercent, 0)
                            o.Health.Thickness = 3
                            o.Health.Transparency = Settings.Transparency
                        end
                    else if o.Health then o.Health.Visible = false end end
                end
            else
                local objs = ESP_Objects[player]
                if objs then
                    if objs.Box then objs.Box.Visible = false end
                    if objs.Name then objs.Name.Visible = false end
                    if objs.Distance then objs.Distance.Visible = false end
                    if objs.Tracer then objs.Tracer.Visible = false end
                    if objs.HeadDot then objs.HeadDot.Visible = false end
                    if objs.SkeletonLines then
                        for _, line in pairs(objs.SkeletonLines) do
                            line.Visible = false
                        end
                    end
                    if objs.Health then objs.Health.Visible = false end
                end
            end
        end
    end

    -- ==================================================
    -- БЛОК 8: FOV ИНДИКАТОР
    -- ==================================================

    local FOVCircle = nil
    local function UpdateFOV()
        if Features.Aimbot.ShowFOV and Features.Aimbot.Enabled then
            if not FOVCircle then
                FOVCircle = Drawing.new("Circle")
                FOVCircle.Filled = false
                FOVCircle.NumSides = 32
                FOVCircle.Thickness = 1
                FOVCircle.Color = Color3.fromRGB(0, 240, 255)
                FOVCircle.Transparency = 0.5
            end
            local size = Features.Aimbot.FOV * 2
            FOVCircle.Radius = size / 2
            FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            FOVCircle.Visible = true
        else
            if FOVCircle then
                FOVCircle.Visible = false
            end
        end
    end

    -- ==================================================
    -- БЛОК 9: AIMBOT + TRIGGERBOT
    -- ==================================================

    local function GetClosestPlayer()
        local closest = nil
        local closestDist = Features.Aimbot.MaxDistance
        local fovRad = math.rad(Features.Aimbot.FOV / 2)
        local camPos = Camera.CFrame.Position
        local camDir = Camera.CFrame.LookVector

        for _, player in pairs(Players:GetPlayers()) do
            if player == LocalPlayer then continue end
            if not player.Character or not player.Character:FindFirstChild("Humanoid") then continue end
            if player.Character.Humanoid.Health <= 0 then continue end

            local target = player.Character:FindFirstChild(Features.Aimbot.TargetPart) or player.Character:FindFirstChild("Head")
            if not target then continue end

            local pos = target.Position
            local distance = (camPos - pos).Magnitude
            if distance > closestDist then continue end

            if Features.Aimbot.VisibleCheck then
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Blacklist
                params.FilterDescendantsInstances = {LocalPlayer.Character}
                local ray = workspace:Raycast(camPos, (pos - camPos).Unit * distance, params)
                if ray and not ray.Instance:IsDescendantOf(player.Character) then
                    continue
                end
            end

            local direction = (pos - camPos).Unit
            local angle = math.acos(clamp(camDir:Dot(direction), -1, 1))
            if angle > fovRad then continue end

            if not closest or distance < closestDist then
                closest = player
                closestDist = distance
            end
        end
        return closest, closestDist
    end

    -- [TRIGGERBOT] функция выстрела
    local function Shoot()
        local char = LocalPlayer.Character
        if not char then return end
        local tool = char:FindFirstChildOfClass("Tool")
        if tool then
            pcall(function()
                tool:Activate()
            end)
        end
    end

    local function UpdateAimbot()
        if not Features.Aimbot.Enabled then return end
        local target = GetClosestPlayer()
        if not target then return end
        local targetPart = target.Character:FindFirstChild(Features.Aimbot.TargetPart) or target.Character:FindFirstChild("Head")
        if not targetPart then return end
        local targetPos = targetPart.Position
        local camPos = Camera.CFrame.Position
        local direction = (targetPos - camPos).Unit
        local targetCF = CFrame.lookAt(camPos, camPos + direction)
        local smooth = Features.Aimbot.Smoothness
        local currentCF = Camera.CFrame
        local newCF = currentCF:Lerp(targetCF, smooth)
        Camera.CFrame = newCF

        -- [TRIGGERBOT] автоматическая стрельба
        if Features.Aimbot.Triggerbot then
            local now = tick()
            if now - lastShotTime >= Features.Aimbot.TriggerDelay then
                Shoot()
                lastShotTime = now
            end
        end
    end

    -- ==================================================
    -- БЛОК 10: MOVEMENT (обновление Fly и SpeedHack)
    -- ==================================================

    local function UpdateMovement()
        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        local hum = char:FindFirstChild("Humanoid")
        if not root or not hum then return end

        -- Fly: обновляем скорость, если включен
        if Features.Movement.Fly then
            local bv = root:FindFirstChild("FlyVelocity")
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.Name = "FlyVelocity"
                bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                bv.P = 1e5
                bv.Parent = root
            end
            local speed = Features.Movement.FlySpeed
            local moveDir = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
            if moveDir.Magnitude > 0 then
                bv.Velocity = moveDir.Unit * speed
            else
                bv.Velocity = Vector3.new(0, 0, 0)
            end
            root.Velocity = Vector3.new(0, 0, 0)
        else
            local bv = root:FindFirstChild("FlyVelocity")
            if bv then bv:Destroy() end
        end

        -- Speed Hack
        if Features.Movement.SpeedHack then
            if hum.WalkSpeed ~= Features.Movement.SpeedValue then
                hum.WalkSpeed = Features.Movement.SpeedValue
            end
        else
            if hum.WalkSpeed ~= 16 then
                hum.WalkSpeed = 16
            end
        end
    end

    -- ==================================================
    -- БЛОК 11: MISC (GOD MODE)
    -- ==================================================

    local function UpdateMisc()
        if Features.Misc.GodMode then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                hum.Health = hum.MaxHealth
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
            end
        else
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                hum:SetStateEnabled(Enum.HumanoidStateType.Dead, true)
            end
        end
    end

    -- ==================================================
    -- БЛОК 12: ANTI-AFK
    -- ==================================================

    if Settings.AntiAFK then
        local VirtualUser = game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            if Settings.AntiAFK then
                pcall(function()
                    VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new())
                end)
            end
        end)
    end

    -- ==================================================
    -- БЛОК 13: ГЛАВНЫЙ ЦИКЛ
    -- ==================================================

    local started = false
    local function OnRenderStep()
        if not started then
            if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                return
            end
            started = true
            -- Применяем начальные состояния
            if Features.Movement.Noclip then ApplyNoclipState(true) end
            if Features.Movement.Fly then ApplyFlyState(true) end
        end
        pcall(function()
            UpdateESP()
            UpdateFOV()
            UpdateAimbot()
            UpdateMovement()
            UpdateMisc()
        end)
    end

    RunService.Heartbeat:Connect(OnRenderStep)

    -- ==================================================
    -- БЛОК 14: ОТКРЫТИЕ МЕНЮ
    -- ==================================================

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.KeyCode == Enum.KeyCode.Insert then
            MainFrame.Visible = not MainFrame.Visible
        end
    end)

    -- ==================================================
    -- БЛОК 15: ЗАВЕРШЕНИЕ
    -- ==================================================

    local function ShowNotification(text)
        local notif = Instance.new("TextLabel")
        notif.Size = UDim2.new(0, 400, 0, 40)
        notif.Position = UDim2.new(0.5, -200, 0.9, 0)
        notif.BackgroundColor3 = Color3.fromRGB(10, 10, 30)
        notif.BackgroundTransparency = 0.3
        notif.Text = text
        notif.TextColor3 = Color3.fromRGB(0, 240, 255)
        notif.TextSize = 18
        notif.Font = Enum.Font.GothamBold
        notif.BorderSizePixel = 0
        notif.Parent = ScreenGui
        Debris:AddItem(notif, 3)
    end

    ShowNotification("Xeno Hub v3.5 загружен! Нажмите Insert для открытия.")

    LocalPlayer.CharacterAdded:Connect(function()
        pcall(function()
            for _, obj in pairs(ESP_Objects) do
                for _, v in pairs(obj) do
                    if v and v.Remove then
                        pcall(function() v:Remove() end)
                    end
                end
            end
            ESP_Objects = {}
        end)
        started = false
        task.wait(0.5)
        if Features.Movement.Noclip then ApplyNoclipState(true) end
        if Features.Movement.Fly then ApplyFlyState(true) end
    end)

    print("[Xeno Hub v3.5] Добавлен Skeleton, улучшен дизайн, исправлен Noclip, добавлен Triggerbot.")

end)

if not success then
    warn("Ошибка загрузки Xeno Hub: " .. tostring(err))
end
[file content end]
