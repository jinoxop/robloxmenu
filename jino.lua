-- Jinoxx Roblox V2 - النسخة المتطورة
-- ضع هذا في LocalScript داخل StarterGui

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = game.Workspace.CurrentCamera
local runService = game:GetService("RunService")
local userInput = game:GetService("UserInputService")
local players = game:GetService("Players")
local tweenService = game:GetService("TweenService")

-- ===== الإعدادات العامة =====
local aimbotEnabled = false
local espEnabled = false
local infiniteJumpEnabled = false
local speedEnabled = false
local flyEnabled = false
local noclipEnabled = false
local reachEnabled = false
local speedValue = 50
local reachValue = 10
local aimbotRadius = 200
local aimbotSmoothness = 0.3
local aimbotPart = "Head" -- "Head", "Chest", "HumanoidRootPart"

local espColorFriend = Color3.fromRGB(0, 255, 0)
local espColorEnemy = Color3.fromRGB(255, 0, 0)
local espColorTarget = Color3.fromRGB(255, 255, 0)

local currentTarget = nil
local espObjects = {}
local guiVisible = true

-- ===== إنشاء الواجهة الرئيسية =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JinoxxGUI_V2"
screenGui.Parent = player.PlayerGui

-- الإطار الرئيسي (مصمم بشكل احترافي)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 420)
frame.Position = UDim2.new(0.5, -160, 0.5, -210)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.15
frame.ClipsDescendants = true
frame.Parent = screenGui

-- زوايا مستديرة (باستخدام Corner)
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- شريط العنوان
local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 40)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
titleBar.BorderSizePixel = 0
titleBar.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 12)
titleCorner.Parent = titleBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -60, 1, 0)
title.Position = UDim2.new(0, 10, 0, 0)
title.Text = "Jinoxx V2"
title.TextColor3 = Color3.fromRGB(255, 0, 120)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = titleBar

-- زر إغلاق القائمة (يخفيها)
local closeMenuBtn = Instance.new("TextButton")
closeMenuBtn.Size = UDim2.new(0, 30, 0, 30)
closeMenuBtn.Position = UDim2.new(1, -35, 0, 5)
closeMenuBtn.Text = "✕"
closeMenuBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeMenuBtn.Font = Enum.Font.GothamBold
closeMenuBtn.TextSize = 16
closeMenuBtn.BorderSizePixel = 0
closeMenuBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeMenuBtn

closeMenuBtn.MouseButton1Click:Connect(function()
    guiVisible = false
    frame.Visible = false
end)

-- زر إظهار القائمة (يظهر عند الإغلاق، يطفو فوق الشاشة)
local showMenuBtn = Instance.new("TextButton")
showMenuBtn.Size = UDim2.new(0, 120, 0, 35)
showMenuBtn.Position = UDim2.new(0.5, -60, 0, 10)
showMenuBtn.Text = "☰ Show Menu"
showMenuBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
showMenuBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
showMenuBtn.Font = Enum.Font.GothamBold
showMenuBtn.TextSize = 14
showMenuBtn.BorderSizePixel = 0
showMenuBtn.Visible = false
showMenuBtn.Parent = screenGui

local showCorner = Instance.new("UICorner")
showCorner.CornerRadius = UDim.new(0, 8)
showCorner.Parent = showMenuBtn

showMenuBtn.MouseButton1Click:Connect(function()
    guiVisible = true
    frame.Visible = true
    showMenuBtn.Visible = false
end)

-- ===== إنشاء الأزرار والمكونات =====
local function createButton(text, yPos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.85, 0, 0, 35)
    btn.Position = UDim2.new(0.075, 0, yPos, 0)
    btn.Text = text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.BorderSizePixel = 0
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    return btn
end

-- أزرار الميزات الرئيسية
local aimbotBtn = createButton("Aimbot", 0.12)
local espBtn = createButton("ESP", 0.21)
local jumpBtn = createButton("Infinite Jump", 0.30)
local speedBtn = createButton("Speed", 0.39)
local flyBtn = createButton("Fly", 0.48)
local noclipBtn = createButton("Noclip", 0.57)
local reachBtn = createButton("Reach", 0.66)

-- زر إعادة تعيين السرعة
local resetSpeedBtn = Instance.new("TextButton")
resetSpeedBtn.Size = UDim2.new(0.3, 0, 0, 25)
resetSpeedBtn.Position = UDim2.new(0.05, 0, 0.76, 0)
resetSpeedBtn.Text = "Reset Speed"
resetSpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
resetSpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetSpeedBtn.Font = Enum.Font.Gotham
resetSpeedBtn.TextSize = 11
resetSpeedBtn.BorderSizePixel = 0
resetSpeedBtn.Parent = frame

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = resetSpeedBtn

resetSpeedBtn.MouseButton1Click:Connect(function()
    player.Character.Humanoid.WalkSpeed = 16
    speedValue = 16
end)

-- زر ضبط السرعة
local speedSliderBtn = Instance.new("TextButton")
speedSliderBtn.Size = UDim2.new(0.3, 0, 0, 25)
speedSliderBtn.Position = UDim2.new(0.4, 0, 0.76, 0)
speedSliderBtn.Text = "Speed: " .. speedValue
speedSliderBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedSliderBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedSliderBtn.Font = Enum.Font.Gotham
speedSliderBtn.TextSize = 11
speedSliderBtn.BorderSizePixel = 0
speedSliderBtn.Parent = frame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(0, 6)
sliderCorner.Parent = speedSliderBtn

speedSliderBtn.MouseButton1Click:Connect(function()
    if speedValue < 200 then
        speedValue = speedValue + 10
    else
        speedValue = 10
    end
    speedSliderBtn.Text = "Speed: " .. speedValue
    if speedEnabled then
        player.Character.Humanoid.WalkSpeed = speedValue
    end
end)

-- ===== وظائف الميزات =====
-- 1. Aimbot
aimbotBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimbotBtn.Text = aimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
    aimbotBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 50)
end)

-- 2. ESP
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 50)
    if espEnabled then
        spawnESP()
    else
        clearESP()
    end
end)

-- 3. Infinite Jump
jumpBtn.MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled
    jumpBtn.Text = infiniteJumpEnabled and "Infinite Jump: ON" or "Infinite Jump: OFF"
    jumpBtn.BackgroundColor3 = infiniteJumpEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 50)
end)

-- 4. Speed
speedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    speedBtn.Text = speedEnabled and "Speed: ON" or "Speed: OFF"
    speedBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 50)
    if speedEnabled then
        player.Character.Humanoid.WalkSpeed = speedValue
    else
        player.Character.Humanoid.WalkSpeed = 16
    end
end)

-- 5. Fly
flyBtn.MouseButton1Click:Connect(function()
    flyEnabled = not flyEnabled
    flyBtn.Text = flyEnabled and "Fly: ON" or "Fly: OFF"
    flyBtn.BackgroundColor3 = flyEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 50)
    if flyEnabled then
        player.Character.Humanoid.PlatformStand = true
    else
        player.Character.Humanoid.PlatformStand = false
    end
end)

-- 6. Noclip
noclipBtn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled
    noclipBtn.Text = noclipEnabled and "Noclip: ON" or "Noclip: OFF"
    noclipBtn.BackgroundColor3 = noclipEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 50)
end)

-- 7. Reach
reachBtn.MouseButton1Click:Connect(function()
    reachEnabled = not reachEnabled
    reachBtn.Text = reachEnabled and "Reach: ON" or "Reach: OFF"
    reachBtn.BackgroundColor3 = reachEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(35, 35, 50)
end)

-- ===== تنفيذ الميزات =====
-- Infinite Jump
userInput.JumpRequest:Connect(function()
    if infiniteJumpEnabled and player.Character and player.Character.Humanoid then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Noclip (يعمل عبر تغيير CanCollide)
runService.RenderStepped:Connect(function()
    if noclipEnabled and player.Character then
        for _, part in ipairs(player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- Aimbot مع Smoothing
runService.RenderStepped:Connect(function()
    if not aimbotEnabled or not player.Character or not player.Character:FindFirstChild("Humanoid") then
        return
    end
    
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, otherPlayer in ipairs(players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local targetPart = otherPlayer.Character:FindFirstChild(aimbotPart) or otherPlayer.Character.HumanoidRootPart
            local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
            local distance = (player.Character.HumanoidRootPart.Position - targetPart.Position).Magnitude
            
            if onScreen and distance < aimbotRadius and distance < closestDistance then
                closestPlayer = otherPlayer
                closestDistance = distance
                currentTarget = otherPlayer
            end
        end
    end
    
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild(aimbotPart) then
        local targetPart = closestPlayer.Character:FindFirstChild(aimbotPart) or closestPlayer.Character.HumanoidRootPart
        local targetPos = targetPart.Position
        local newCFrame = CFrame.new(camera.CFrame.Position, targetPos)
        camera.CFrame = camera.CFrame:Lerp(newCFrame, aimbotSmoothness)
    end
end)

-- ===== ESP المتطور =====
function spawnESP()
    clearESP()
    for _, otherPlayer in ipairs(players:GetPlayers()) do
        if otherPlayer ~= player then
            local character = otherPlayer.Character
            if character then
                local root = character:FindFirstChild("HumanoidRootPart")
                local humanoid = character:FindFirstChild("Humanoid")
                if root and humanoid then
                    local healthPercent = humanoid.Health / humanoid.MaxHealth
                    local espColor = espColorEnemy
                    
                    -- تغيير اللون حسب الصحة
                    if healthPercent > 0.7 then
                        espColor = Color3.fromRGB(0, 255, 0)
                    elseif healthPercent > 0.3 then
                        espColor = Color3.fromRGB(255, 255, 0)
                    else
                        espColor = Color3.fromRGB(255, 0, 0)
                    end
                    
                    if currentTarget == otherPlayer then
                        espColor = espColorTarget
                    end
                    
                    -- Box
                    local box = Instance.new("BoxHandleAdornment")
                    box.Size = Vector3.new(3, 5, 2)
                    box.Color3 = espColor
                    box.Transparency = 0.4
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Adornee = root
                    box.Parent = screenGui
                    table.insert(espObjects, box)
                    
                    -- Line
                    local line = Instance.new("LineHandleAdornment")
                    line.Length = 1
                    line.Color3 = espColor
                    line.Thickness = 1.5
                    line.Transparency = 0.6
                    line.AlwaysOnTop = true
                    line.ZIndex = 10
                    line.Adornee = root
                    line.Parent = screenGui
                    table.insert(espObjects, line)
                    
                    -- Name + Distance + Health
                    local billboard = Instance.new("BillboardGui")
                    billboard.Size = UDim2.new(0, 250, 0, 60)
                    billboard.Adornee = root
                    billboard.AlwaysOnTop = true
                    billboard.Parent = screenGui
                    
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 0.5, 0)
                    label.BackgroundTransparency = 1
                    label.Text = otherPlayer.Name .. " | " .. math.floor((player.Character.HumanoidRootPart.Position - root.Position).Magnitude) .. "m"
                    label.TextColor3 = espColor
                    label.TextScaled = true
                    label.Font = Enum.Font.GothamBold
                    label.Parent = billboard
                    
                    local healthLabel = Instance.new("TextLabel")
                    healthLabel.Size = UDim2.new(1, 0, 0.5, 0)
                    healthLabel.Position = UDim2.new(0, 0, 0.5, 0)
                    healthLabel.BackgroundTransparency = 1
                    healthLabel.Text = "❤️ " .. math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
                    healthLabel.TextColor3 = espColor
                    healthLabel.TextScaled = true
                    healthLabel.Font = Enum.Font.Gotham
                    healthLabel.Parent = billboard
                    
                    table.insert(espObjects, billboard)
                end
            end
        end
    end
end

function clearESP()
    for _, obj in ipairs(espObjects) do
        obj:Destroy()
    end
    espObjects = {}
end

-- تحديث ESP
spawnESP()
while true do
    wait(0.3)
    if espEnabled then
        spawnESP()
    end
end

-- ===== حماية عند موت اللاعب =====
player.CharacterAdded:Connect(function(char)
    wait(0.5)
    if speedEnabled then
        char.Humanoid.WalkSpeed = speedValue
    end
    if flyEnabled then
        char.Humanoid.PlatformStand = true
    end
end)

-- ===== اختصار لوحة المفاتيح (Tab لإظهار/إخفاء) =====
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

print("Jinoxx V2 Loaded Successfully!")
