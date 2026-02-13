-- 粉々バージョンのtouch flingこっちのほうがパワーが高くて荒らしやすい
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlingGui_Destruction"
ScreenGui.Parent = lp:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.5, -100, 0.5, -50)
Frame.BackgroundColor3 = Color3.fromRGB(40, 10, 10) -- 色を攻撃的に変更
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0.4, 0)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleBtn.Text = "DESTRUCTION: OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Parent = Frame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0.3, 0)
StatusLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
StatusLabel.Text = "Targeting Joints..."
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.new(1, 0.5, 0.5)
StatusLabel.Parent = Frame

local flicking = false

local flingPower = 500000 
local rotPower = 1000000 

ToggleBtn.MouseButton1Click:Connect(function()
    flicking = not flicking
    if flicking then
        ToggleBtn.Text = "DESTRUCTION: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    else
        ToggleBtn.Text = "DESTRUCTION: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then 
            hrp.Velocity = Vector3.new(0,0,0)
            hrp.RotVelocity = Vector3.new(0,0,0)
        end
    end
end)

RunService.Stepped:Connect(function()
    if not flicking then return end
    
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not hrp or not hum then return end
    if hum.Sit then hum.Sit = false end

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character then
            local targetHum = v.Character:FindFirstChildOfClass("Humanoid")
            local targetHrp = v.Character:FindFirstChild("HumanoidRootPart")
            
            if targetHrp and targetHum and not targetHum.Sit then
                -- 粉々ポイント1: 相手の重心(HRP)に完全にめり込む
                hrp.CFrame = targetHrp.CFrame 
                hrp.Velocity = Vector3.new(flingPower, flingPower, flingPower)
                hrp.RotVelocity = Vector3.new(rotPower, rotPower, rotPower)
                
                task.wait(0.01)
            end
        end
    end
end)

RunService.Stepped:Connect(function()
    if flicking and lp.Character then
        for _, part in pairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
                part.Velocity = Vector3.new(flingPower, flingPower, flingPower)
            end
        end
    end
end)
