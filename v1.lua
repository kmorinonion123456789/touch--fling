-- Universal TP Touch Fling (All Players)
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

-- GUIの作成 (既存のものを流用・拡張)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FlingGui_shiun"
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
StatusLabel.Text = "Targeting: All Players"
StatusLabel.BackgroundTransparency = 1
StatusLabel.TextColor3 = Color3.new(1, 1, 1)
StatusLabel.Parent = Frame

-- メインロジック
local flicking = false
local flingPower = 50000 -- 相手を飛ばすパワー

ToggleBtn.MouseButton1Click:Connect(function()
    flicking = not flicking
    if flicking then
        ToggleBtn.Text = "TP FLING: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        ToggleBtn.Text = "TP FLING: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)

-- Fling実行ループ
RunService.Stepped:Connect(function()
    if not flicking then return end
    
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    
    if not hrp then return end

    -- 椅子に座っている場合の対策（一瞬だけ立ち上がる、または溶接を無視する）
    if hum and hum.Sit then
        hum.Sit = false 
    end

    -- 全プレイヤーをループ
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= lp and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            local targetHrp = v.Character.HumanoidRootPart
            
            -- 1. 相手の場所にテレポート
            -- 相手の少し上や横に重なるように移動
            hrp.CFrame = targetHrp.CFrame * CFrame.new(0, 0, 0.5) 
            
            -- 2. 超高速回転と速度を付与して「飛ばす」判定を作る
            hrp.Velocity = Vector3.new(flingPower, flingPower, flingPower)
            hrp.RotVelocity = Vector3.new(flingPower, flingPower, flingPower)
            
            -- 3. 物理演算の「重なり」を強制（これがないと飛ばない）
            task.wait(0.01)
        end
    end
end)

-- 自分が飛ばされないための対策（アンチ・セルフフリング）
RunService.RenderStepped:Connect(function()
    if flicking then
        local char = lp.Character
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false -- 自分自身の衝突判定を消してバグを防ぐ
            end
        end
    end
end)
