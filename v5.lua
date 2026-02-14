local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomFling_Orbit"
ScreenGui.Parent = lp:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 380)
Frame.Position = UDim2.new(0.5, -125, 0.5, -190)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.08, 0)
Title.Text = "FLING CONTROL"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(0.9, 0, 0.35, 0)
ScrollingFrame.Position = UDim2.new(0.05, 0, 0.1, 0)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0.06, 0)
StatusLabel.Position = UDim2.new(0.05, 0, 0.47, 0)
StatusLabel.Text = "Target: NONE"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = Frame

local function createBtn(text, pos, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0.1, 0)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.Parent = Frame
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    return btn
end

local SpinBtn = createBtn("SPIN: OFF", UDim2.new(0.05, 0, 0.55, 0), Color3.fromRGB(150, 0, 0))
local OrbitBtn = createBtn("ORBIT: OFF", UDim2.new(0.05, 0, 0.67, 0), Color3.fromRGB(150, 0, 0))
local ToggleBtn = createBtn("FLING: OFF", UDim2.new(0.05, 0, 0.79, 0), Color3.fromRGB(150, 0, 0))

local flicking = false
local spinning = false
local orbiting = false
local targetPlayer = nil
local flingPower = 150000
local spinSpeed = 200
local orbitSpeed = 25
local orbitDistance = 3.5
local angle = 0

local function updateList()
    for _, child in pairs(ScrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    local AllBtn = Instance.new("TextButton")
    AllBtn.Size = UDim2.new(1, 0, 0, 30)
    AllBtn.Text = "[ ALL PLAYERS ]"
    AllBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    AllBtn.TextColor3 = Color3.new(1, 1, 1)
    AllBtn.BorderSizePixel = 0
    AllBtn.Parent = ScrollingFrame
    AllBtn.MouseButton1Click:Connect(function()
        targetPlayer = "ALL"
        StatusLabel.Text = "Target: ALL PLAYERS"
    end)

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= lp then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 30)
            btn.Text = p.DisplayName .. " (@" .. p.Name .. ")"
            btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            btn.TextColor3 = Color3.new(1, 1, 1)
            btn.BorderSizePixel = 0
            btn.Parent = ScrollingFrame
            
            btn.MouseButton1Click:Connect(function()
                targetPlayer = p
                StatusLabel.Text = "Target: " .. p.Name
            end)
        end
    end
end

updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

SpinBtn.MouseButton1Click:Connect(function()
    spinning = not spinning
    SpinBtn.Text = spinning and "SPIN: ON" or "SPIN: OFF"
    SpinBtn.BackgroundColor3 = spinning and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

OrbitBtn.MouseButton1Click:Connect(function()
    orbiting = not orbiting
    OrbitBtn.Text = orbiting and "ORBIT: ON" or "ORBIT: OFF"
    OrbitBtn.BackgroundColor3 = orbiting and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

ToggleBtn.MouseButton1Click:Connect(function()
    flicking = not flicking
    ToggleBtn.Text = flicking and "FLING: ON" or "FLING: OFF"
    ToggleBtn.BackgroundColor3 = flicking and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

RunService.Heartbeat:Connect(function(dt)
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if spinning then
        hrp.RotVelocity = Vector3.new(0, spinSpeed, 0)
    end

    if not targetPlayer then return end

    local function applyFling(targetHrp)
        if orbiting then
            angle = angle + orbitSpeed * dt
            local offset = Vector3.new(math.cos(angle) * orbitDistance, 0.5, math.sin(angle) * orbitDistance)
            hrp.CFrame = CFrame.new(targetHrp.Position + offset)
        else
            hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 0.01)
        end

        if flicking then
            hrp.Velocity = Vector3.new(flingPower, flingPower, flingPower)
        end
    end

    if targetPlayer == "ALL" then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                applyFling(v.Character.HumanoidRootPart)
            end
        end
    elseif targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        applyFling(targetPlayer.Character.HumanoidRootPart)
    end
end)

RunService.Stepped:Connect(function()
    if (flicking or orbiting or spinning) and lp.Character then
        for _, part in pairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)
