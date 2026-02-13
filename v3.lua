-- Universal TP Touch Fling (Custom Target Mode + Spin)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- GUIの作成
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomFling_" .. lp.Name
ScreenGui.Parent = lp:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 220, 0, 220) -- 高さを少し広げました
Frame.Position = UDim2.new(0.5, -110, 0.5, -110)
Frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
Frame.Active = true
Frame.Draggable = true
Frame.Parent = ScreenGui

-- タイトル
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0.15, 0)
Title.Text = "FLING CONTROL (shiun4545)"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.BackgroundTransparency = 1
Title.Parent = Frame

-- モード切替ボタン
local ModeBtn = Instance.new("TextButton")
ModeBtn.Size = UDim2.new(0.9, 0, 0.15, 0)
ModeBtn.Position = UDim2.new(0.05, 0, 0.18, 0)
ModeBtn.Text = "MODE: ALL PLAYERS"
ModeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ModeBtn.TextColor3 = Color3.new(1, 1, 1)
ModeBtn.Parent = Frame

-- ターゲット入力欄
local TargetInput = Instance.new("TextBox")
TargetInput.Size = UDim2.new(0.9, 0, 0.15, 0)
TargetInput.Position = UDim2.new(0.05, 0, 0.35, 0)
TargetInput.PlaceholderText = "Target Name (Partial)"
TargetInput.Text = ""
TargetInput.Visible = false
TargetInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TargetInput.TextColor3 = Color3.new(1, 1, 1)
TargetInput.Parent = Frame

-- Spin ON/OFFボタン (追加)
local SpinBtn = Instance.new("TextButton")
SpinBtn.Size = UDim2.new(0.9, 0, 0.15, 0)
SpinBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
SpinBtn.Text = "SPIN: OFF"
SpinBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
SpinBtn.TextColor3 = Color3.new(1, 1, 1)
SpinBtn.Parent = Frame

-- メインON/OFFボタン
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0.15, 0)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
ToggleBtn.Text = "FLING: OFF"
ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
ToggleBtn.TextColor3 = Color3.new(1, 1, 1)
ToggleBtn.Parent = Frame

--- 設定変数 ---
local flicking = false
local spinning = false
local mode = "ALL"
local flingPower = 50000 
local spinSpeed = 70 -- ご指定の速度
local targetWaitTime = 0.5 

-- モード切替処理
ModeBtn.MouseButton1Click:Connect(function()
    if mode == "ALL" then
        mode = "SINGLE"
        ModeBtn.Text = "MODE: SINGLE TARGET"
        TargetInput.Visible = true
    else
        mode = "ALL"
        ModeBtn.Text = "MODE: ALL PLAYERS"
        TargetInput.Visible = false
    end
end)

-- Spin切替 (追加)
SpinBtn.MouseButton1Click:Connect(function()
    spinning = not spinning
    SpinBtn.Text = spinning and "SPIN: ON" or "SPIN: OFF"
    SpinBtn.BackgroundColor3 = spinning and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

-- ON/OFF切替
ToggleBtn.MouseButton1Click:Connect(function()
    flicking = not flicking
    ToggleBtn.Text = flicking and "FLING: ON" or "FLING: OFF"
    ToggleBtn.BackgroundColor3 = flicking and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

-- ターゲット検索関数
local function getTarget()
    local text = TargetInput.Text:lower()
    if text == "" then return nil end
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and (v.Name:lower():find(text) or v.DisplayName:lower():find(text)) then
            return v
        end
    end
    return nil
end

-- メインループ
task.spawn(function()
    while true do
        task.wait()
        
        local char = lp.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then continue end

        -- Spin処理 (追加)
        if spinning then
            hrp.RotVelocity = Vector3.new(0, spinSpeed, 0)
        end

        if not flicking then continue end

        if mode == "ALL" then
            for _, v in pairs(Players:GetPlayers()) do
                if not flicking or mode ~= "ALL" then break end
                if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHrp = v.Character.HumanoidRootPart
                    local start = tick()
                    while tick() - start < targetWaitTime and flicking do
                        hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 0.1)
                        hrp.Velocity = Vector3.new(flingPower, flingPower, flingPower)
                        RunService.Heartbeat:Wait()
                    end
                end
            end
        elseif mode == "SINGLE" then
            local target = getTarget()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = target.Character.HumanoidRootPart
                hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 0.1)
                hrp.Velocity = Vector3.new(flingPower, flingPower, flingPower)
            end
        end
    end
end)

-- 衝突判定の無効化
RunService.Stepped:Connect(function()
    if flicking and lp.Character then
        for _, part in pairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)
