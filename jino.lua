-- Jinoxx Roblox V1
-- ضع هذا في LocalScript داخل StarterGui أو ScreenGui

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local camera = game.Workspace.CurrentCamera
local runService = game:GetService("RunService")
local userInput = game:GetService("UserInputService")
local players = game:GetService("Players")

-- ===== الإعدادات =====
local aimbotEnabled = false
local espEnabled = false
local infiniteJumpEnabled = false
local speedEnabled = false
local speedValue = 50
local aimbotRadius = 200
local espColorFriend = Color3.fromRGB(0, 255, 0)   -- أخضر
local espColorEnemy = Color3.fromRGB(255, 0, 0)   -- أحمر
local espColorTarget = Color3.fromRGB(255, 255, 0) -- أصفر

local currentTarget = nil

-- ===== إنشاء الواجهة =====
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "JinoxxGUI"
screenGui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 320)
frame.Position = UDim2.new(0.5, -125, 0.5, -160)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
frame.BorderSizePixel = 0
frame.BackgroundTransparency = 0.1
frame.Parent = screenGui

-- عنوان
local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.Text = "Jinoxx Roblox V1"
title.TextColor3 = Color3.fromRGB(255, 0, 120)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = frame

-- زر Aimbot
local aimbotBtn = Instance.new("TextButton")
aimbotBtn.Size = UDim2.new(0.9, 0, 0, 35)
aimbotBtn.Position = UDim2.new(0.05, 0, 0.12, 0)
aimbotBtn.Text = "Aimbot: OFF"
aimbotBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
aimbotBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
aimbotBtn.Font = Enum.Font.Gotham
aimbotBtn.TextSize = 14
aimbotBtn.Parent = frame
aimbotBtn.MouseButton1Click:Connect(function()
    aimbotEnabled = not aimbotEnabled
    aimbotBtn.Text = aimbotEnabled and "Aimbot: ON" or "Aimbot: OFF"
    aimbotBtn.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 50)
end)

-- زر ESP
local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(0.9, 0, 0, 35)
espBtn.Position = UDim2.new(0.05, 0, 0.24, 0)
espBtn.Text = "ESP: OFF"
espBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espBtn.Font = Enum.Font.Gotham
espBtn.TextSize = 14
espBtn.Parent = frame
espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled
    espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 50)
    if espEnabled then
        spawnESP()
    else
        clearESP()
    end
end)

-- زر Infinite Jump
local jumpBtn = Instance.new("TextButton")
jumpBtn.Size = UDim2.new(0.9, 0, 0, 35)
jumpBtn.Position = UDim2.new(0.05, 0, 0.36, 0)
jumpBtn.Text = "Infinite Jump: OFF"
jumpBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
jumpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
jumpBtn.Font = Enum.Font.Gotham
jumpBtn.TextSize = 14
jumpBtn.Parent = frame
jumpBtn.MouseButton1Click:Connect(function()
    infiniteJumpEnabled = not infiniteJumpEnabled
    jumpBtn.Text = infiniteJumpEnabled and "Infinite Jump: ON" or "Infinite Jump: OFF"
    jumpBtn.BackgroundColor3 = infiniteJumpEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 50)
end)

-- زر Speed
local speedBtn = Instance.new("TextButton")
speedBtn.Size = UDim2.new(0.9, 0, 0, 35)
speedBtn.Position = UDim2.new(0.05, 0, 0.48, 0)
speedBtn.Text = "Speed: OFF"
speedBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
speedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
speedBtn.Font = Enum.Font.Gotham
speedBtn.TextSize = 14
speedBtn.Parent = frame
speedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    speedBtn.Text = speedEnabled and "Speed: ON" or "Speed: OFF"
    speedBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(40, 40, 50)
    if speedEnabled then
        player.Character.Humanoid.WalkSpeed = speedValue
    else
        player.Character.Humanoid.WalkSpeed = 16
    end
end)

-- شريط التحكم بالسرعة
local speedSlider = Instance.new("TextButton")
speedSlider.Size = UDim2.new(0.9, 0, 0, 25)
speedSlider.Position = UDim2.new(0.05, 0, 0.59, 0)
speedSlider.Text = "Speed: " .. speedValue
speedSlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
speedSlider.TextColor3 = Color3.fromRGB(255, 255, 255)
speedSlider.Font = Enum.Font.Gotham
speedSlider.TextSize = 12
speedSlider.Parent = frame
speedSlider.MouseButton1Click:Connect(function()
    local newSpeed = tonumber(game:GetService("TextService"):GetTextSize("", 0, Enum.Font.Gotham, Vector2.new(100, 100)).X)
    -- ببساطة نزيد السرعة تدريجياً
    if speedValue < 200 then
        speedValue = speedValue + 10
    else
        speedValue = 10
    end
    speedSlider.Text = "Speed: " .. speedValue
    if speedEnabled then
        player.Character.Humanoid.WalkSpeed = speedValue
    end
end)

-- زر إغلاق
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.3, 0, 0, 25)
closeBtn.Position = UDim2.new(0.35, 0, 0.75, 0)
closeBtn.Text = "Close"
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.Gotham
closeBtn.TextSize = 12
closeBtn.Parent = frame
closeBtn.MouseButton1Click:Connect(function()
    screenGui.Enabled = not screenGui.Enabled
end)

-- زر إعادة تعيين السرعة
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(0.3, 0, 0, 25)
resetBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
resetBtn.Text = "Reset Speed"
resetBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.Font = Enum.Font.Gotham
resetBtn.TextSize = 12
resetBtn.Parent = frame
resetBtn.MouseButton1Click:Connect(function()
    player.Character.Humanoid.WalkSpeed = 16
    speedValue = 16
    speedSlider.Text = "Speed: " .. speedValue
end)

-- ===== وظيفة Infinite Jump =====
userInput.JumpRequest:Connect(function()
    if infiniteJumpEnabled and player.Character and player.Character.Humanoid then
        player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- ===== وظيفة Aimbot =====
runService.RenderStepped:Connect(function()
    if not aimbotEnabled or not player.Character or not player.Character:FindFirstChild("Humanoid") then
        return
    end
    
    local closestPlayer = nil
    local closestDistance = math.huge
    
    for _, otherPlayer in ipairs(players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character and otherPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local otherRoot = otherPlayer.Character.HumanoidRootPart
            local screenPos, onScreen = camera:WorldToViewportPoint(otherRoot.Position)
            local distance = (player.Character.HumanoidRootPart.Position - otherRoot.Position).Magnitude
            
            if onScreen and distance < aimbotRadius and distance < closestDistance then
                closestPlayer = otherPlayer
                closestDistance = distance
                currentTarget = otherPlayer
            end
        end
    end
    
    if closestPlayer and closestPlayer.Character and closestPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local targetPos = closestPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 1.5, 0)
        camera.CFrame = CFrame.new(camera.CFrame.Position, targetPos)
    end
end)

-- ===== وظيفة ESP =====
local espObjects = {}

function spawnESP()
    clearESP()
    for _, otherPlayer in ipairs(players:GetPlayers()) do
        if otherPlayer ~= player then
            local character = otherPlayer.Character
            if character then
                local root = character:FindFirstChild("HumanoidRootPart")
                if root then
                    -- Box
                    local box = Instance.new("BoxHandleAdornment")
                    box.Size = Vector3.new(3, 5, 2)
                    box.Color3 = espColorEnemy
                    box.Transparency = 0.5
                    box.AlwaysOnTop = true
                    box.ZIndex = 10
                    box.Adornee = root
                    box.Parent = screenGui
                    table.insert(espObjects, box)
                    
                    -- Line (من الهدف إلى الكاميرا)
                    local line = Instance.new("LineHandleAdornment")
                    line.Length = 1
                    line.Color3 = espColorEnemy
                    line.Thickness = 1
                    line.Transparency = 0.7
                    line.AlwaysOnTop = true
                    line.ZIndex = 10
                    line.Adornee = root
                    line.Parent = screenGui
                    table.insert(espObjects, line)
                    
                    -- Name + Distance (باستخدام BillboardGui)
                    local billboard = Instance.new("BillboardGui")
                    billboard.Size = UDim2.new(0, 200, 0, 30)
                    billboard.Adornee = root
                    billboard.AlwaysOnTop = true
                    billboard.Parent = screenGui
                    
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 1, 0)
                    label.BackgroundTransparency = 1
                    label.Text = otherPlayer.Name .. " | " .. math.floor((player.Character.HumanoidRootPart.Position - root.Position).Magnitude) .. "m"
                    label.TextColor3 = espColorEnemy
                    label.TextScaled = true
                    label.Font = Enum.Font.GothamBold
                    label.Parent = billboard
                    
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

-- تحديث ESP كل 0.5 ثانية
while true do
    wait(0.5)
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
end)

-- تحذير: هذا السكريبت لأغراض تعليمية فقط
