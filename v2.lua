-- Universal TP Touch Fling (Slow Version)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- GUIの作成
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlingGui_" .. lp.Name -- 保存されたID (shiun4545) を意識した名称
ScreenGui.Parent = lp:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 200, 0, 100)
Frame.Position = UDim2.new(0.5, -100, 0.5, -50)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0.4, 0)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleBtn.Text = "TP FLING: OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Parent = Frame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0.9, 0, 0.3, 0)
StatusLabel.Position = UDim2.new(0.05, 0, 0.6, 0)
StatusLabel.Text = "Status: Idle"
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.Parent = Frame

-- メイン設定
local flicking = false
local flingPower = 30000 -- 少しパワーを抑えめに設定
local targetWaitTime = 0.8 -- 次のターゲットに移るまでの時間（ここを増やすとさらに遅くなります）

ToggleBtn.MouseButton1Click:Connect(function()
    flicking = not flicking
    if flicking then
        ToggleBtn.Text = "TP FLING: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        ToggleBtn.Text = "TP FLING: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
        StatusLabel.Text = "Status: Idle"
    end
end)

-- メインループ
task.spawn(function()
    while true do
        task.wait()
        if flicking then
            local char = lp.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end

            for _, v in pairs(Players:GetPlayers()) do
                if not flicking then break end -- 途中でOFFにされたら中断
                
                if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHrp = v.Character.HumanoidRootPart
                    StatusLabel.Text = "Target: " .. v.DisplayName
                    
                    -- ターゲットの場所に移動して少し留まる
                    local startTime = tick()
                    while tick() - startTime < targetWaitTime and flicking do
                        -- 物理演算の「衝突」を誘発させるための微細な動き
                        hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 0.2)
                        hrp.Velocity = Vector3.new(flingPower, flingPower, flingPower)
                        hrp.RotVelocity = Vector3.new(flingPower, flingPower, flingPower)
                        RunService.Heartbeat:Wait()
                    end
                end
            end
        end
    end
end)

-- 衝突判定の無効化（自分のキャラが壊れないようにする）
RunService.Stepped:Connect(function()
    if flicking and lp.Character then
        for _, part in pairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)
