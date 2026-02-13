local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomFling_List_" .. lp.Name
ScreenGui.Parent = lp:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 250, 0, 300)
Frame.Position = UDim2.new(0.5, -125, 0.5, -150)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.1, 0)
Title.Text = "FLING CONTROL (shiun4545)"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.SourceSansBold
Title.Parent = Frame

local ScrollingFrame = Instance.new("ScrollingFrame")
ScrollingFrame.Size = UDim2.new(0.9, 0, 0.45, 0)
ScrollingFrame.Position = UDim2.new(0.05, 0, 0.12, 0)
ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollingFrame.ScrollBarThickness = 4
ScrollingFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
ScrollingFrame.BorderSizePixel = 0
ScrollingFrame.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollingFrame
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0.08, 0)
StatusLabel.Position = UDim2.new(0.05, 0, 0.58, 0)
StatusLabel.Text = "Target: NONE"
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Parent = Frame

local SpinBtn = Instance.new("TextButton")
SpinBtn.Size = UDim2.new(0.9, 0, 0.12, 0)
SpinBtn.Position = UDim2.new(0.05, 0, 0.68, 0)
SpinBtn.Text = "SPIN: OFF"
SpinBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
SpinBtn.TextColor3 = Color3.new(1, 1, 1)
SpinBtn.Parent = Frame

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0.12, 0)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.82, 0)
ToggleBtn.Text = "FLING: OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Parent = Frame

local flicking = false
local spinning = false
local targetPlayer = nil
local flingPower = 50000 
local spinSpeed = 150

local function updateList()
    for _, child in pairs(ScrollingFrame:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    
    local AllBtn = Instance.new("TextButton")
    AllBtn.Size = UDim2.new(1, 0, 0, 30)
    AllBtn.Text = "[ ALL PLAYERS ]"
    AllBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    AllBtn.TextColor3 = Color3.new(1, 1, 1)
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
            btn.Parent = ScrollingFrame
            
            btn.MouseButton1Click:Connect(function()
                targetPlayer = p
                StatusLabel.Text = "Target: " .. p.Name
            end)
        end
    end
    ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, UIListLayout.AbsoluteContentSize.Y)
end

updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

SpinBtn.MouseButton1Click:Connect(function()
    spinning = not spinning
    SpinBtn.Text = spinning and "SPIN: ON" or "SPIN: OFF"
    SpinBtn.BackgroundColor3 = spinning and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

ToggleBtn.MouseButton1Click:Connect(function()
    flicking = not flicking
    ToggleBtn.Text = flicking and "FLING: ON" or "FLING: OFF"
    ToggleBtn.BackgroundColor3 = flicking and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

task.spawn(function()
    while true do
        task.wait()
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        if spinning then
            hrp.RotVelocity = Vector3.new(0, spinSpeed, 0)
        end

        if not flicking or not targetPlayer then continue end

        if targetPlayer == "ALL" then
            for _, v in pairs(Players:GetPlayers()) do
                if not flicking or targetPlayer ~= "ALL" then break end
                if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHrp = v.Character.HumanoidRootPart
                    hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 0.1)
                    hrp.Velocity = Vector3.new(flingPower, flingPower, flingPower)
                    RunService.Heartbeat:Wait()
                end
            end
        else

            if targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = targetPlayer.Character.HumanoidRootPart
                hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 0.1)
                hrp.Velocity = Vector3.new(flingPower, flingPower, flingPower)
            end
        end
    end
end)


RunService.Stepped:Connect(function()
    if flicking and lp.Character then
        for _, part in pairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)
