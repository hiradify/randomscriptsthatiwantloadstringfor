local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer
local guiName = "Delta_Speed_Fixed_V6"

-- Cleanup previous versions
if CoreGui:FindFirstChild(guiName) then CoreGui[guiName]:Destroy() end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = guiName
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
screenGui.Parent = CoreGui

-- 1. THE OUTLINE (Smooth Mixed Black & White)
local outlineFrame = Instance.new("Frame")
outlineFrame.Name = "Outline"
outlineFrame.Size = UDim2.new(0, 186, 0, 61)
outlineFrame.Position = UDim2.new(0.5, -93, 0.7, 0)
outlineFrame.BackgroundColor3 = Color3.new(1, 1, 1)
outlineFrame.BorderSizePixel = 0
outlineFrame.Active = true 
outlineFrame.Parent = screenGui

local outlineCorner = Instance.new("UICorner")
outlineCorner.CornerRadius = UDim.new(0, 12)
outlineCorner.Parent = outlineFrame

local outlineGradient = Instance.new("UIGradient")
outlineGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),   -- White
    ColorSequenceKeypoint.new(0.5, Color3.new(0, 0, 0)), -- Mixed Black
    ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))    -- White
})
outlineGradient.Rotation = 90
outlineGradient.Parent = outlineFrame

-- 2. THE BUTTON (Inside)
local mainButton = Instance.new("Frame")
mainButton.Size = UDim2.new(1, -6, 1, -6) 
mainButton.Position = UDim2.new(0, 3, 0, 3) 
mainButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
mainButton.BorderSizePixel = 0
mainButton.ClipsDescendants = true
mainButton.Parent = outlineFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 10)
buttonCorner.Parent = mainButton

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = "READY"
label.TextColor3 = Color3.new(1, 1, 1)
label.Font = Enum.Font.GothamBold
label.TextSize = 18
label.Parent = mainButton

-- 3. INNER SHINE (Smooth Glass)
local shine = Instance.new("Frame")
shine.Size = UDim2.new(0, 80, 2, 0)
shine.Position = UDim2.new(-1.5, 0, -0.5, 0)
shine.BackgroundColor3 = Color3.new(1, 1, 1)
shine.BorderSizePixel = 0
shine.Rotation = 30
shine.Parent = mainButton

local shineGrad = Instance.new("UIGradient")
shineGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.5),
    NumberSequenceKeypoint.new(1, 1)
})
shineGrad.Parent = shine

-- 4. ANIMATIONS
RunService.RenderStepped:Connect(function(dt)
    outlineGradient.Rotation = (outlineGradient.Rotation + dt * 120) % 360
end)

task.spawn(function()
    while true do
        task.wait(10)
        shine.Position = UDim2.new(-1.5, 0, -0.5, 0)
        TweenService:Create(shine, TweenInfo.new(1.2, Enum.EasingStyle.Quint), {Position = UDim2.new(2.5, 0, -0.5, 0)}):Play()
    end
end)

-- 5. HOLD JUMP LOGIC (STABLE VERSION)
local isBoosting = false

RunService.Heartbeat:Connect(function()
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if hum then
        -- On mobile, 'hum.Jump' stays true as long as you hold the button down
        -- We also check if you're mid-air (Freefall) to keep the speed steady
        local isActuallyJumping = hum.Jump or hum:GetState() == Enum.HumanoidStateType.Freefall or hum:GetState() == Enum.HumanoidStateType.Jumping

        if isActuallyJumping then
            if not isBoosting then
                isBoosting = true
                hum.WalkSpeed = 100
                label.Text = "BOOSTING"
                -- Press animation (Slightly smaller)
                TweenService:Create(outlineFrame, TweenInfo.new(0.15), {Size = UDim2.new(0, 176, 0, 56)}):Play()
            end
        else
            if isBoosting then
                isBoosting = false
                hum.WalkSpeed = 16
                label.Text = "READY"
                -- Back to normal size
                TweenService:Create(outlineFrame, TweenInfo.new(0.15), {Size = UDim2.new(0, 186, 0, 61)}):Play()
            end
        end
    end
end)

-- 6. MOBILE DRAGGING
local dragging, dragStart, startPos
outlineFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = outlineFrame.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        outlineFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)
