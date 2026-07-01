-- =====================================================
-- Jinoxx V3 - النسخة النهائية المتكاملة
-- جميع الحقوق محفوظة للمستخدم الأعلى
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
    textSize = 14,
}

local function getPlayerColor(otherPlayer, healthPercent)
    if currentTarget == otherPlayer then
        return Color3.fromRGB(255, 255, 0) -- أصفر للهدف
    elseif healthPercent > 0.7 then
        return Color3.fromRGB(0, 255, 0) -- أخضر للصديق
    elseif healthPercent > 0.3 then
        return Color3.fromRGB(255, 255, 0) -- أصفر للصحة المتوسطة
    else
        return Color3.fromRGB(255, 0, 0) -- أحمر للعدو
    end
end

local function createESP(playerObj)
    if playerObj == player then return end
    local character = playerObj.Character
    if not character then return end
    
    local root = character:FindFirstChild("HumanoidRootPart")
    local humanoid = character:FindFirstChild("Humanoid")
    if not root or not humanoid then return end
    
    -- تنظيف العناصر القديمة
    if espObjects[playerObj] then
        for _, obj in ipairs(espObjects[playerObj]) do
            pcall(function() obj:Destroy() end)
        end
    end
    espObjects[playerObj] = {}
    
    local healthPercent = humanoid.Health / humanoid.MaxHealth
    local espColor = getPlayerColor(playerObj, healthPercent)
    
    -- 1. Box
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
    
    -- 2. Line
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
    
    -- 3. Information Billboard
    if espSystem.showName or espSystem.showDistance or espSystem.showHealth or espSystem.showArmor or espSystem.showWeapon then
        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0, 300, 0, 100)
        billboard.Adornee = root
        billboard.AlwaysOnTop = true
        billboard.Parent = coreGui
        
        -- الاسم والمسافة
        local mainLabel = Instance.new("TextLabel")
        mainLabel.Size = UDim2.new(1, 0, 0.4, 0)
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
        
        -- معلومات إضافية (الصحة، الدرع، السلاح)
        local extraLabel = Instance.new("TextLabel")
        extraLabel.Size = UDim2.new(1, 0, 0.3, 0)
        extraLabel.Position = UDim2.new(0, 0, 0.4, 0)
        extraLabel.BackgroundTransparency = 1
        extraLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        extraLabel.TextScaled = true
        extraLabel.Font = Enum.Font.Gotham
        extraLabel.TextXAlignment = Enum.TextXAlignment.Center
        extraLabel.Parent = billboard
        
        local extraText = ""
        if espSystem.showHealth then
            extraText = extraText .. "❤️ " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
        end
        if espSystem.showArmor then
            local armor = 0
            for _, item in ipairs(character:GetChildren()) do
                if item:IsA("Accessory") or item:IsA("Tool") then
                    armor = armor + 10
                end
            end
            extraText = extraText .. (extraText ~= "" and " | " or "") .. "🛡️ " .. armor
        end
        if espSystem.showWeapon then
            local weapon = "None"
            for _, tool in ipairs(character:GetChildren()) do
                if tool:IsA("Tool") then
                    weapon = tool.Name
                    break
                end
            end
            extraText = extraText .. (extraText ~= "" and " | " or "") .. "🔫 " .. weapon
        end
        extraLabel.Text = extraText
        
        -- شريط الصحة
        local healthBarBg = Instance.new("Frame")
        healthBarBg.Size = UDim2.new(0.8, 0, 0.08, 0)
        healthBarBg.Position = UDim2.new(0.1, 0, 0.75, 0)
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
    -- تنظيف جميع عناصر ESP
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

-- دورة تحديث ESP
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

-- تحديث عند إضافة/مغادرة لاعب
players.PlayerAdded:Connect(function() wait(0.5) if espSystem.enabled then updateESP() end end)
players.PlayerRemoving:Connect(function() wait(0.5) if espSystem.enabled then updateESP() end end)

-- =====================================================
-- إنشاء الواجهة الأسطورية
-- =====================================================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JinoxxV3"
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

-- الإطار الرئيسي (تصميم Glassmorphism)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 400, 0, 520)
frame.Position = UDim2.new(0.5, -200, 0.5, -260)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 25)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0
frame.ClipsDescendants = true
frame.Parent = screenGui

-- زوايا مستديرة
local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = frame

-- تأثير الزجاج
local glassEffect = Instance.new("Frame")
glassEffect.Size = UDim2.new(1, 0, 1, 0)
glassEffect.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
glassEffect.BackgroundTransparency = 0.05
glassEffect.BorderSizePixel = 0
glassEffect.Parent = frame
local glassCorner = Instance.new("UICorner")
glassCorner.CornerRadius = UDim.new(0, 16)
glassCorner.Parent = glassEffect

-- حدود نيون
local neonBorder = Instance.new("Frame")
neonBorder.Size = UDim2.new(1, 0, 1, 0)
neonBorder.BackgroundTransparency = 1
neonBorder.BorderSizePixel = 2
neonBorder.BorderColor3 = Color3.fromRGB(0, 255, 255)
neonBorder.Parent = frame
local borderCorner = Instance.new("UICorner")
borderCorner.CornerRadius = UDim.new(0, 16)
borderCorner.Parent = neonBorder

-- عنوان الشريط
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
titleBar.BackgroundTransparency = 0.3
titleBar.BorderSizePixel = 0
titleBar.Parent = frame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 16)
titleCorner.Parent = titleBar

-- اسم البرنامج
local titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(1, -60, 1, 0)
titleText.Position = UDim2.new(0, 15, 0, 0)
titleText.Text = "🔥 JINoxx V3"
titleText.TextColor3 = Color3.fromRGB(255, 0, 150)
titleText.BackgroundTransparency = 1
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 22
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

-- زر الإغلاق
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 35, 0, 35)
closeBtn.Position = UDim2.new(1, -42, 0, 7)
closeBtn.Text = "✕"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.BorderSizePixel = 0
closeBtn.Parent = titleBar
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function()
    guiVisible = false
    frame.Visible = false
    showMenuBtn.Visible = true
end)

-- زر إظهار القائمة
local showMenuBtn = Instance.new("TextButton")
showMenuBtn.Size = UDim2.new(0, 140, 0, 40)
showMenuBtn.Position = UDim2.new(0.5, -70, 0, 15)
showMenuBtn.Text = "⚡ Show Menu"
showMenuBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 45)
showMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
showMenuBtn.Font = Enum.Font.GothamBold
showMenuBtn.TextSize = 16
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
-- إنشاء الأزرار والمكونات
-- =====================================================
local function createButton(text, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 38)
    btn.Position = UDim2.new(0.075, 0, yPos, 0)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = color or Color3.fromRGB(35, 35, 55)
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.Parent = frame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    return btn
end

-- صف الأزرار (العمود الأول)
local aimbotBtn = createButton("🎯 Aimbot", 0.13)
local espBtn = createButton("👁️ ESP", 0.22)
local jumpBtn = createButton("⬆️ Infinite Jump", 0.31)
local speedBtn = createButton("💨 Speed", 0.40)
local flyBtn = createButton("🕊️ Fly", 0.49)
local noclipBtn = createButton("🚪 Noclip", 0.58)
local reachBtn = createButton("⚔️ Reach", 0.67)

-- أزرار التحكم الإضافية
local resetSpeedBtn = Instance.new("TextButton")
resetSpeedBtn.Size = UDim2.new(0.25, 0, 0, 28)
resetSpeedBtn.Position = UDim2.new(0.05, 0, 0.78, 0)
resetSpeedBtn.Text = "↺ Reset"
resetSpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
resetSpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetSpeedBtn.Font = Enum.Font.Gotham
resetSpeedBtn.TextSize = 12
resetSpeedBtn.BorderSizePixel = 0
resetSpeedBtn.Parent = frame
local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = resetSpeedBtn

resetSpeedBtn.MouseButton1Click:Connect(function()
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 16
        settings.speed.value = 16
    end
end)

-- زر التحكم بالسرعة
local speedSliderBtn = Instance.new("TextButton")
speedSliderBtn.Size = UDim2.new(0.3, 0, 0, 28)
speedSliderBtn.Position = UDim2.new(0.35, 0, 0.78, 0)
speedSliderBtn.Text = "Speed: " .. settings.speed.value
speedSliderBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
speedSliderBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedSliderBtn.Font = Enum.Font.Gotham
speedSliderBtn.TextSize = 12
speedSliderBtn.BorderSizePixel = 0
speedSliderBtn.Parent = frame
local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 6)
sliderCorner.Parent = speedSliderBtn

speedSliderBtn.MouseButton1Click:Connect(function()
    if settings.speed.value < 200 then
        settings.speed.value = settings.speed.value + 10
    else
        settings.speed.value = 10
    end
    speedSliderBtn.Text = "Speed: " .. settings.speed.value
    if settings.speed.enabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = settings.speed.value
    end
end)

-- =====================================================
-- وظائف الأزرار
-- =====================================================
aimbotBtn.MouseButton1Click:Connect(function()
    settings.aimbot.enabled = not settings.aimbot.enabled
    aimbotBtn.Text = settings.aimbot.enabled and "🎯 Aimbot: ON" or "🎯 Aimbot: OFF"
    aimbotBtn.BackgroundColor3 = settings.aimbot.enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 55)
end)

espBtn.MouseButton1Click:Connect(function()
    if espSystem.enabled then
        stopESP()
        espBtn.Text = "👁️ ESP: OFF"
        espBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
    else
        startESP()
        espBtn.Text = "👁️ ESP: ON"
        espBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    end
end)

jumpBtn.MouseButton1Click:Connect(function()
    settings.infiniteJump.enabled = not settings.infiniteJump.enabled
    jumpBtn.Text = settings.infiniteJump.enabled and "⬆️ Infinite Jump: ON" or "⬆️ Infinite Jump: OFF"
    jumpBtn.BackgroundColor3 = settings.infiniteJump.enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 55)
end)

speedBtn.MouseButton1Click:Connect(function()
    settings.speed.enabled = not settings.speed.enabled
    speedBtn.Text = settings.speed.enabled and "💨 Speed: ON" or "💨 Speed: OFF"
    speedBtn.BackgroundColor3 = settings.speed.enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 55)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = settings.speed.enabled and settings.speed.value or 16
    end
end)

flyBtn.MouseButton1Click:Connect(function()
    settings.fly.enabled = not settings.fly.enabled
    flyBtn.Text = settings.fly.enabled and "🕊️ Fly: ON" or "🕊️ Fly: OFF"
    flyBtn.BackgroundColor3 = settings.fly.enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 55)
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.PlatformStand = settings.fly.enabled
    end
end)

noclipBtn.MouseButton1Click:Connect(function()
    settings.noclip.enabled = not settings.noclip.enabled
    noclipBtn.Text = settings.noclip.enabled and "🚪 Noclip: ON" or "🚪 Noclip: OFF"
    noclipBtn.BackgroundColor3 = settings.noclip.enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 55)
end)

reachBtn.MouseButton1Click:Connect(function()
    settings.reach.enabled = not settings.reach.enabled
    reachBtn.Text = settings.reach.enabled and "⚔️ Reach: ON" or "⚔️ Reach: OFF"
    reachBtn.BackgroundColor3 = settings.reach.enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 55)
end)

-- =====================================================
-- تنفيذ الميزات في الخلفية
-- =====================================================

-- 1. Aimbot مع Smoothing
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

-- 2. Infinite Jump
userInput.JumpRequest:Connect(function()
    if settings.infiniteJump.enabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- 3. Noclip
runService.RenderStepped:Connect(function()
    if settings.noclip.enabled and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- 4. Reach (تعديل مدى الضرب)
-- ملاحظة: يعتمد على اللعبة، هذا مثال عام
local oldReach = nil
runService.RenderStepped:Connect(function()
    if settings.reach.enabled and player.Character then
        local tool = player.Character:FindFirstChildOfClass("Tool")
        if tool then
            for _, child in ipairs(tool:GetDescendants()) do
                if child:IsA("NumberValue") and child.Name == "Reach" then
                    child.Value = settings.reach.value
                end
            end
        end
    end
end)

-- 5. حماية عند الموت
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
print("✅ Jinoxx V3 Loaded Successfully!")
print("🔥 جميع الميزات جاهزة للاستخدام")
print("🔄 اضغط Tab لإظهار/إخفاء القائمة")

-- =====================================================
-- نهاية السكريبت
-- =====================================================
