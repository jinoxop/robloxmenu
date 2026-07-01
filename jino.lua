-- =====================================================
-- Jinoxx V5.2 - القائمة الأفقية (نظام سحب مثالي)
-- =====================================================

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = game.Workspace.CurrentCamera
local runService = game:GetService("RunService")
local userInput = game:GetService("UserInputService")
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")
local coreGui = game:GetService("CoreGui")

-- ===== إعدادات عامة =====
local settings = {
    aimbot = { enabled = false, radius = 200, smoothness = 0.3, part = "Head" },
    esp = { enabled = false },
    speed = { enabled = false, value = 50 },
    fly = { enabled = false },
    noclip = { enabled = false },
    reach = { enabled = false, value = 10 },
    infiniteJump = { enabled = false },
}

local currentTarget = nil
local espObjects = {}
local guiVisible = true
local isDragging = false
local dragStart = nil
local dragStartPos = nil
local dragConnection = nil

-- =====================================================
-- نظام ESP المتطور
-- =====================================================
local espSystem = {
    enabled = false,
    showBox = true,
    showLine = true,
    showName = true,
    showDistance = true,
    showHealth = true,
    showArmor = true,
    showWeapon = true,
    boxTransparency = 0.3,
    lineThickness = 2,
}

local function getPlayerColor(otherPlayer, healthPercent)
    if currentTarget == otherPlayer then
        return Color3.fromRGB(255, 255, 0)
    elseif healthPercent > 0.7 then
        return Color3.fromRGB(0, 255, 0)
    elseif healthPercent > 0.3 then
        return Color3.fromRGB(255, 255, 0)
    else
        return Color3.fromRGB(255, 0, 0)
    end
end

local function createESP(playerObj)
    if playerObj == player then return end
    local character = playerObj.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not root or not humanoid then return end
    
    if espObjects[playerObj] then
        for _, obj in ipairs(espObjects[playerObj]) do
            pcall(function() obj:Destroy() end)
        end
    end
    espObjects[playerObj] = {}
    
    local healthPercent = humanoid.Health / humanoid.MaxHealth
    local espColor = getPlayerColor(playerObj, healthPercent)
    
    -- Box
    if espSystem.showBox then
        local box = Instance.new("BoxHandleAdornment")
        box.Size = Vector3.new(3, 5.5, 2)
        box.Color3 = espColor
        box.Transparency = espSystem.boxTransparency
        box.AlwaysOnTop = true
        box.ZIndex = 10
        box.Adornee = root
        box.Parent = coreGui
        table.insert(espObjects[playerObj], box)
    end
    
    -- Line
    if espSystem.showLine then
        local line = Instance.new("LineHandleAdornment")
        line.Length = 1
        line.Color3 = espColor
        line.Thickness = espSystem.lineThickness
        line.Transparency = 0.5
        line.AlwaysOnTop = true
        line.ZIndex = 10
        line.Adornee = root
        line.Parent = coreGui
        table.insert(espObjects[playerObj], line)
    end
    
    -- Billboard Info
    if espSystem.showName or espSystem.showDistance or espSystem.showHealth then
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 300, 0, 80)
        billboard.Adornee = root
        billboard.AlwaysOnTop = true
        billboard.Parent = coreGui
        
        local mainLabel = Instance.new("TextLabel")
        mainLabel.Size = UDim2.new(1, 0, 0.5, 0)
        mainLabel.BackgroundTransparency = 1
        mainLabel.TextColor3 = espColor
        mainLabel.TextScaled = true
        mainLabel.Font = Enum.Font.GothamBold
        mainLabel.TextXAlignment = Enum.TextXAlignment.Center
        mainLabel.Parent = billboard
        
        local infoText = ""
        if espSystem.showName then
            infoText = playerObj.Name
        end
        if espSystem.showDistance then
            local dist = (player.Character and player.Character:FindFirstChild("HumanoidRootPart")) and
                math.floor((player.Character.HumanoidRootPart.Position - root.Position).Magnitude) or 0
            infoText = infoText .. (infoText ~= "" and " | " or "") .. dist .. "m"
        end
        mainLabel.Text = infoText
        
        local healthLabel = Instance.new("TextLabel")
        healthLabel.Size = UDim2.new(1, 0, 0.3, 0)
        healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
        healthLabel.BackgroundTransparency = 1
        healthLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        healthLabel.TextScaled = true
        healthLabel.Font = Enum.Font.Gotham
        healthLabel.TextXAlignment = Enum.TextXAlignment.Center
        healthLabel.Parent = billboard
        
        if espSystem.showHealth then
            healthLabel.Text = "❤️ " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
        end
        
        -- Health Bar
        local healthBarBg = Instance.new("Frame")
        healthBarBg.Size = UDim2.new(0.8, 0, 0.08, 0)
        healthBarBg.Position = UDim2.new(0.1, 0, 0.78, 0)
        healthBarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        healthBarBg.BackgroundTransparency = 0.5
        healthBarBg.BorderSizePixel = 0
        healthBarBg.Parent = billboard
        
        local healthBar = Instance.new("Frame")
        healthBar.Size = UDim2.new(math.clamp(healthPercent, 0, 1), 0, 1, 0)
        healthBar.BackgroundColor3 = espColor
        healthBar.BackgroundTransparency = 0
        healthBar.BorderSizePixel = 0
        healthBar.Parent = healthBarBg
        
        table.insert(espObjects[playerObj], billboard)
    end
end

local function updateESP()
    for _, objects in pairs(espObjects) do
        for _, obj in ipairs(objects) do
            pcall(function() obj:Destroy() end)
        end
    end
    espObjects = {}
    
    if not espSystem.enabled then return end
    
    for _, otherPlayer in ipairs(players:GetPlayers()) do
        if otherPlayer ~= player then
            createESP(otherPlayer)
        end
    end
end

local espLoop
local function startESP()
    espSystem.enabled = true
    updateESP()
    espLoop = runService.RenderStepped:Connect(function()
        if espSystem.enabled then
            updateESP()
        end
    end)
end

local function stopESP()
    espSystem.enabled = false
    if espLoop then espLoop:Disconnect() end
    for _, objects in pairs(espObjects) do
        for _, obj in ipairs(objects) do
            pcall(function() obj:Destroy() end)
        end
    end
    espObjects = {}
end

players.PlayerAdded:Connect(function() wait(0.5) if espSystem.enabled then updateESP() end end)
players.PlayerRemoving:Connect(function() wait(0.5) if espSystem.enabled then updateESP() end end)

-- =====================================================
-- إنشاء القائمة الأفقية (Horizontal Panel)
-- =====================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JinoxxV5"
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

-- الإطار الرئيسي (عرضي)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 700, 0, 160)
frame.Position = UDim2.new(0.5, -350, 0.85, -80)
frame.BackgroundColor3 = Color3.fromRGB(8, 8, 20)
frame.BackgroundTransparency = 0.05
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = screenGui

-- زوايا مستديرة
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 20)
mainCorner.Parent = frame

-- تأثير الزجاج
local glassEffect = Instance.new("Frame")
glassEffect.Size = UDim2.new(1, 0, 1, 0)
glassEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
glassEffect.BackgroundTransparency = 0.03
glassEffect.BorderSizePixel = 0
glassEffect.Parent = frame
local glassCorner = Instance.new("UICorner")
glassCorner.CornerRadius = UDim.new(0, 20)
glassCorner.Parent = glassEffect

-- حدود نيون متحركة
local neonBorder = Instance.new("Frame")
neonBorder.Size = UDim2.new(1, 0, 1, 0)
neonBorder.BackgroundTransparency = 1
neonBorder.BorderSizePixel = 2
neonBorder.BorderColor3 = Color3.fromRGB(0, 200, 255)
neonBorder.Parent = frame
local borderCorner = Instance.new("UICorner")
borderCorner.CornerRadius = UDim.new(0, 20)
borderCorner.Parent = neonBorder

-- ===== شريط العنوان (قابل للسحب) =====
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 50)
titleBar.BackgroundTransparency = 0.3
titleBar.BorderSizePixel = 0
titleBar.Parent = frame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 20)
titleCorner.Parent = titleBar

-- اسم البرنامج
local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.3, 0, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.Text = "🔥 JINoxx V5"
titleText.TextColor3 = Color3.fromRGB(255, 0, 150)
titleText.BackgroundTransparency = 1
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 18
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- إشارة السحب
local dragHandle = Instance.new("TextLabel")
dragHandle.Size = UDim2.new(0, 40, 0, 20)
dragHandle.Position = UDim2.new(0.35, 0, 0, 10)
dragHandle.Text = "⠿"
dragHandle.TextColor3 = Color3.fromRGB(150, 150, 200)
dragHandle.BackgroundTransparency = 1
dragHandle.Font = Enum.Font.Gotham
dragHandle.TextSize = 20
dragHandle.Parent = titleBar

-- زر الإغلاق
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -42, 0, 2)
closeBtn.Text = "✕"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 10)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    guiVisible = false
    frame.Visible = false
    showMenuBtn.Visible = true
end)

-- ===== نظام السحب المحسّن (يعمل على أي جزء من القائمة) =====
local function startDrag(input)
    isDragging = true
    dragStart = Vector2.new(input.Position.X, input.Position.Y)
    dragStartPos = frame.Position
    
    -- ربط تحديث السحب
    dragConnection = mouse.Move:Connect(function()
        if not isDragging then return end
        local delta = Vector2.new(mouse.X, mouse.Y) - dragStart
        local newPos = UDim2.new(
            dragStartPos.X.Scale,
            dragStartPos.X.Offset + delta.X,
            dragStartPos.Y.Scale,
            dragStartPos.Y.Offset + delta.Y
        )
        frame.Position = newPos
    end)
end

local function stopDrag()
    isDragging = false
    if dragConnection then
        dragConnection:Disconnect()
        dragConnection = nil
    end
end

-- تطبيق السحب على شريط العنوان
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        startDrag(input)
    end
end)

titleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        stopDrag()
    end
end)

-- أيضاً على الإطار نفسه (بحيث يمكن السحب من أي مكان)
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not input.Target:IsA("TextButton") then
        startDrag(input)
    end
end)

frame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        stopDrag()
    end
end)

-- زر إظهار القائمة
local showMenuBtn = Instance.new("TextButton")
showMenuBtn.Size = UDim2.new(0, 130, 0, 35)
showMenuBtn.Position = UDim2.new(0.5, -65, 0, 10)
showMenuBtn.Text = "⚡ Open"
showMenuBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 50)
showMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
showMenuBtn.Font = Enum.Font.GothamBold
showMenuBtn.TextSize = 14
showMenuBtn.BorderSizePixel = 0
showMenuBtn.Visible = false
showMenuBtn.Parent = screenGui
local showCorner = Instance.new("UICorner")
showCorner.CornerRadius = UDim.new(0, 10)
showCorner.Parent = showMenuBtn

showMenuBtn.MouseButton1Click:Connect(function()
    guiVisible = true
    frame.Visible = true
    showMenuBtn.Visible = false
end)

-- =====================================================
-- إنشاء الأزرار (ترتيب أفقي)
-- =====================================================
local function createButton(text, xPos, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 80, 0, 80)
    btn.Position = UDim2.new(0, xPos, 0, 45)
    btn.Text = icon .. "\n" .. text
    btn.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 11
    btn.BorderSizePixel = 0
    btn.Parent = frame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 12)
    btnCorner.Parent = btn
    return btn
end

-- أزرار الميزات (مرتبة أفقياً)
local btnWidth = 80
local startX = 85
local gap = 15

local aimbotBtn = createButton("Aimbot", startX + (btnWidth + gap) * 0, "🎯")
local espBtn = createButton("ESP", startX + (btnWidth + gap) * 1, "👁️")
local jumpBtn = createButton("Jump", startX + (btnWidth + gap) * 2, "⬆️")
local speedBtn = createButton("Speed", startX + (btnWidth + gap) * 3, "💨")
local flyBtn = createButton("Fly", startX + (btnWidth + gap) * 4, "🕊️")
local noclipBtn = createButton("Noclip", startX + (btnWidth + gap) * 5, "🚪")
local reachBtn = createButton("Reach", startX + (btnWidth + gap) * 6, "⚔️")

-- =====================================================
-- وظائف الأزرار
-- =====================================================
local function toggleButton(btn, setting, text)
    setting = not setting
    btn.BackgroundColor3 = setting and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(30, 30, 55)
    btn.TextColor3 = setting and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(220, 220, 220)
    return setting
end

aimbotBtn.MouseButton1Click:Connect(function()
    settings.aimbot.enabled = toggleButton(aimbotBtn, settings.aimbot.enabled, "Aimbot")
    aimbotBtn.Text = settings.aimbot.enabled and "🎯\nON" or "🎯\nAimbot"
end)

espBtn.MouseButton1Click:Connect(function()
    if espSystem.enabled then
        stopESP()
        espBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 55)
        espBtn.Text = "👁️\nESP"
    else
        startESP()
        espBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
        espBtn.Text = "👁️\nON"
    end
end)

jumpBtn.MouseButton1Click:Connect(function()
    settings.infiniteJump.enabled = toggleButton(jumpBtn, settings.infiniteJump.enabled, "Jump")
    jumpBtn.Text = settings.infiniteJump.enabled and "⬆️\nON" or "⬆️\nJump"
end)

speedBtn.MouseButton1Click:Connect(function()
    settings.speed.enabled = toggleButton(speedBtn, settings.speed.enabled, "Speed")
    speedBtn.Text = settings.speed.enabled and "💨\nON" or "💨\nSpeed"
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = settings.speed.enabled and settings.speed.value or 16
    end
end)

flyBtn.MouseButton1Click:Connect(function()
    settings.fly.enabled = toggleButton(flyBtn, settings.fly.enabled, "Fly")
    flyBtn.Text = settings.fly.enabled and "🕊️\nON" or "🕊️\nFly"
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.PlatformStand = settings.fly.enabled
    end
end)

noclipBtn.MouseButton1Click:Connect(function()
    settings.noclip.enabled = toggleButton(noclipBtn, settings.noclip.enabled, "Noclip")
    noclipBtn.Text = settings.noclip.enabled and "🚪\nON" or "🚪\nNoclip"
end)

reachBtn.MouseButton1Click:Connect(function()
    settings.reach.enabled = toggleButton(reachBtn, settings.reach.enabled, "Reach")
    reachBtn.Text = settings.reach.enabled and "⚔️\nON" or "⚔️\nReach"
end)

-- =====================================================
-- أزرار التحكم الإضافية
-- =====================================================
-- زر ضبط السرعة (+)
local speedUpBtn = Instance.new("TextButton")
speedUpBtn.Size = UDim2.new(0, 30, 0, 30)
speedUpBtn.Position = UDim2.new(0, startX + (btnWidth + gap) * 7 + 10, 0, 45)
speedUpBtn.Text = "+"
speedUpBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
speedUpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedUpBtn.Font = Enum.Font.GothamBold
speedUpBtn.TextSize = 18
speedUpBtn.BorderSizePixel = 0
speedUpBtn.Parent = frame
local speedUpCorner = Instance.new("UICorner")
speedUpCorner.CornerRadius = UDim.new(0, 8)
speedUpCorner.Parent = speedUpBtn

speedUpBtn.MouseButton1Click:Connect(function()
    if settings.speed.value < 200 then
        settings.speed.value = settings.speed.value + 10
    else
        settings.speed.value = 10
    end
    if settings.speed.enabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = settings.speed.value
    end
end)

-- زر ضبط السرعة (-)
local speedDownBtn = Instance.new("TextButton")
speedDownBtn.Size = UDim2.new(0, 30, 0, 30)
speedDownBtn.Position = UDim2.new(0, startX + (btnWidth + gap) * 7 + 45, 0, 45)
speedDownBtn.Text = "-"
speedDownBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
speedDownBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedDownBtn.Font = Enum.Font.GothamBold
speedDownBtn.TextSize = 18
speedDownBtn.BorderSizePixel = 0
speedDownBtn.Parent = frame
local speedDownCorner = Instance.new("UICorner")
speedDownCorner.CornerRadius = UDim.new(0, 8)
speedDownCorner.Parent = speedDownBtn

speedDownBtn.MouseButton1Click:Connect(function()
    if settings.speed.value > 10 then
        settings.speed.value = settings.speed.value - 10
    else
        settings.speed.value = 200
    end
    if settings.speed.enabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = settings.speed.value
    end
end)

-- عرض السرعة الحالية
local speedDisplay = Instance.new("TextLabel")
speedDisplay.Size = UDim2.new(0, 50, 0, 20)
speedDisplay.Position = UDim2.new(0, startX + (btnWidth + gap) * 7 + 20, 0, 80)
speedDisplay.Text = settings.speed.value
speedDisplay.TextColor3 = Color3.fromRGB(200, 200, 255)
speedDisplay.BackgroundTransparency = 1
speedDisplay.Font = Enum.Font.GothamBold
speedDisplay.TextSize = 14
speedDisplay.Parent = frame

-- زر إعادة التعيين
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0, 50, 0, 25)
resetBtn.Position = UDim2.new(0, startX + (btnWidth + gap) * 7 + 10, 0, 105)
resetBtn.Text = "↺"
resetBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.TextSize = 16
resetBtn.BorderSizePixel = 0
resetBtn.Parent = frame
local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 8)
resetCorner.Parent = resetBtn

resetBtn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16
        settings.speed.value = 16
        speedDisplay.Text = "16"
    end
end)

-- =====================================================
-- تنفيذ الميزات في الخلفية
-- =====================================================

-- Aimbot
runService.RenderStepped:Connect(function()
    if not settings.aimbot.enabled or not player.Character or not player.Character:FindFirstChild("Humanoid") then
        return
    end
    
    local closest = nil
    local closestDist = math.huge
    
    for _, other in ipairs(players:GetPlayers()) do
        if other ~= player and other.Character then
            local targetPart = other.Character:FindFirstChild(settings.aimbot.part) or other.Character:FindFirstChild("HumanoidRootPart")
            if targetPart then
                local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
                local dist = (player.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude
                if onScreen and dist < settings.aimbot.radius and dist < closestDist then
                    closest = other
                    closestDist = dist
                    currentTarget = other
                end
            end
        end
    end
    
    if closest and closest.Character then
        local targetPart = closest.Character:FindFirstChild(settings.aimbot.part) or closest.Character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            local newCF = CFrame.new(camera.CFrame.Position, targetPart.Position)
            camera.CFrame = camera.CFrame:Lerp(newCF, settings.aimbot.smoothness)
        end
    end
end)

-- Infinite Jump
userInput.JumpRequest:Connect(function()
    if settings.infiniteJump.enabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Noclip
runService.RenderStepped:Connect(function()
    if settings.noclip.enabled and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Character Added
player.CharacterAdded:Connect(function(char)
    wait(0.5)
    if settings.speed.enabled and char:FindFirstChild("Humanoid") then
        char.Humanoid.WalkSpeed = settings.speed.value
    end
    if settings.fly.enabled and char:FindFirstChild("Humanoid") then
        char.Humanoid.PlatformStand = true
    end
end)

-- =====================================================
-- اختصار لوحة المفاتيح (Tab)
-- =====================================================
userInput.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Tab then
        if guiVisible then
            guiVisible = false
            frame.Visible = false
            showMenuBtn.Visible = true
        else
            guiVisible = true
            frame.Visible = true
            showMenuBtn.Visible = false
        end
    end
end)

-- =====================================================
-- رسالة التحميل
-- =====================================================
print("✅ Jinoxx V5.2 - Horizontal Panel Loaded Successfully!")
print("🔥 قائمة أفقية احترافية - اسحبها من أي مكان")
print("🔄 اضغط Tab لإظهار/إخفاء القائمة")

-- =====================================================
-- نهاية السكريبت
-- =====================================================
