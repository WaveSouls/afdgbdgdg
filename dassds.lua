--[[
    PacMan Menu v6 — Shooter Quiet
    RightShift = меню
    RightCtrl  = panic
    ESP: только Drawing (без Highlight)
    Aim: soft + prediction + triggerbot (тише)
]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TeleportService  = game:GetService("TeleportService")
local Lighting         = game:GetService("Lighting")
local Workspace        = game:GetService("Workspace")
local CoreGui          = game:GetService("CoreGui")
local StarterGui       = game:GetService("StarterGui")
local GuiService       = game:GetService("GuiService")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse  = LP:GetMouse()

local function R() return tostring(math.random(10000,99999)) end
local function safe(fn, ...) local ok, a = pcall(fn, ...) return ok, a end

-- ===== STATE =====
local S = {
    Visible     = true,
    MenuKey     = Enum.KeyCode.RightShift,
    PanicKey    = Enum.KeyCode.RightControl,

    -- visuals
    ESP         = false,
    HealthESP   = false,
    Tracers     = false,
    FOVCircle   = false,
    Crosshair   = false,
    ESPColor    = Color3.fromRGB(0, 255, 180),

    -- combat
    SoftAim     = false,
    PredAim     = false,
    Triggerbot  = false,
    SilentAim   = false,
    SilentPart  = "Head",
    FOV         = 130,
    Smooth      = 0.12,          -- чем меньше — тем плавнее и тише

    -- movement
    Fly         = false,
    Noclip      = false,
    Invis       = false,
    God         = false,
    Speed       = 16,
    Jump        = 50,
    ClickTP     = false,
    AirWalk     = false,
    AntiFling   = true,
    InfJump     = false,
    AntiAFK     = true,

    -- farm
    AutoFarm    = false,
    NPCFarm     = false,

    Streamer    = false,
}

local Conns = {}
local DrawObjs = {}
local ESPCache = {}
local hasDrawing = pcall(function() return Drawing.new end)
local StartTime = tick()
local FlyBV, FlyBG, AirPart

-- ===== NOTIFY =====
local function notify(t, d)
    d = d or 2.3
    safe(function()
        StarterGui:SetCore("SendNotification", {
            Title = "PacMan Menu",
            Text = t,
            Duration = d
        })
    end)
end

-- ===== HELPERS =====
local function char() return LP.Character end
local function hum()  local c = char() return c and c:FindFirstChildOfClass("Humanoid") end
local function root() local c = char() return c and c:FindFirstChild("HumanoidRootPart") end

local function getDevice()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then return "Mobile"
    elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then return "Console"
    else return "PC" end
end

-- ===== DRAWING ONLY ESP (тихо) =====
local function clearAllDraw()
    for _, o in pairs(DrawObjs) do
        if o and o.Remove then pcall(function() o:Remove() end) end
    end
    table.clear(DrawObjs)
    for plr, _ in pairs(ESPCache) do
        ESPCache[plr] = nil
    end
end

local function make(typ)
    if not hasDrawing then return nil end
    local o = Drawing.new(typ)
    table.insert(DrawObjs, o)
    return o
end

local FOVDraw = make("Circle")
if FOVDraw then
    FOVDraw.Thickness = 1.2
    FOVDraw.NumSides = 64
    FOVDraw.Filled = false
    FOVDraw.Visible = false
    FOVDraw.Transparency = 0.55
end

local CrossDraw = make("Line")
if CrossDraw then
    CrossDraw.Thickness = 1.4
    CrossDraw.Visible = false
end

local function removeESP(plr)
    local t = ESPCache[plr]
    if not t then return end
    for _, o in pairs(t) do
        if o and o.Remove then pcall(function() o:Remove() end) end
    end
    ESPCache[plr] = nil
end

local function ensureESP(plr)
    if plr == LP or ESPCache[plr] then return end
    local box = make("Square")
    local txt = make("Text")
    local hp  = make("Line")
    local tr  = make("Line")

    if box then box.Thickness = 1.1 box.Filled = false box.Visible = false end
    if txt then txt.Size = 13 txt.Center = true txt.Outline = true txt.Visible = false end
    if hp  then hp.Thickness = 2 hp.Visible = false end
    if tr  then tr.Thickness = 1.0 tr.Transparency = 0.45 tr.Visible = false end

    ESPCache[plr] = {box = box, txt = txt, hp = hp, tr = tr}
end

local function updateESP()
    if not (S.ESP or S.HealthESP or S.Tracers) then
        for plr, _ in pairs(ESPCache) do
            local t = ESPCache[plr]
            if t then
                if t.box then t.box.Visible = false end
                if t.txt then t.txt.Visible = false end
                if t.hp  then t.hp.Visible  = false end
                if t.tr  then t.tr.Visible  = false end
            end
        end
        return
    end

    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LP then continue end
        ensureESP(plr)
        local t = ESPCache[plr]
        if not t then continue end

        local c = plr.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local head = c and c:FindFirstChild("Head")
        local human = c and c:FindFirstChildOfClass("Humanoid")

        if not hrp or not head or not human or human.Health <= 0 then
            if t.box then t.box.Visible = false end
            if t.txt then t.txt.Visible = false end
            if t.hp  then t.hp.Visible  = false end
            if t.tr  then t.tr.Visible  = false end
            continue
        end

        local pos, on = Camera:WorldToViewportPoint(hrp.Position)
        local headP = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 0.35, 0))
        local footP = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 2.6, 0))

        local col = S.ESPColor
        local h = math.abs(headP.Y - footP.Y)
        local w = h / 1.85

        if on and S.ESP then
            if t.box then
                t.box.Size = Vector2.new(w, h)
                t.box.Position = Vector2.new(pos.X - w/2, headP.Y)
                t.box.Color = col
                t.box.Visible = true
            end
            if t.txt then
                t.txt.Text = S.Streamer and "Player" or plr.Name
                t.txt.Position = Vector2.new(pos.X, headP.Y - 15)
                t.txt.Color = col
                t.txt.Visible = true
            end
        else
            if t.box then t.box.Visible = false end
            if t.txt then t.txt.Visible = false end
        end

        if S.HealthESP and on and t.hp then
            local pct = math.clamp(human.Health / math.max(human.MaxHealth, 1), 0, 1)
            t.hp.From = Vector2.new(pos.X - w/2 - 5, footP.Y)
            t.hp.To   = Vector2.new(pos.X - w/2 - 5, footP.Y - h * pct)
            t.hp.Color = Color3.fromRGB(255 * (1 - pct), 255 * pct, 50)
            t.hp.Visible = true
        elseif t.hp then
            t.hp.Visible = false
        end

        if S.Tracers and on and t.tr and root() then
            local my = Camera:WorldToViewportPoint(root().Position)
            t.tr.From = Vector2.new(my.X, my.Y)
            t.tr.To   = Vector2.new(pos.X, pos.Y)
            t.tr.Color = col
            t.tr.Visible = true
        elseif t.tr then
            t.tr.Visible = false
        end
    end
end

Players.PlayerRemoving:Connect(removeESP)

-- ===== AIM (тихий) =====
local function getClosest()
    local closest, dist = nil, S.FOV
    for _, plr in pairs(Players:GetPlayers()) do
        if plr == LP then continue end
        local c = plr.Character
        local head = c and c:FindFirstChild("Head")
        local human = c and c:FindFirstChildOfClass("Humanoid")
        if not head or not human or human.Health <= 0 then continue end

        local pos, on = Camera:WorldToViewportPoint(head.Position)
        if on then
            local m = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
            if m < dist then
                dist = m
                closest = plr
            end
        end
    end
    return closest
end

local function getTargetPos(plr)
    local head = plr.Character and plr.Character:FindFirstChild("Head")
    local hrp  = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not head then return nil end
    if S.PredAim and hrp then
        return head.Position + hrp.AssemblyLinearVelocity * 0.11
    end
    return head.Position
end

-- soft aim loop (очень плавно)
table.insert(Conns, RunService.RenderStepped:Connect(function()
    updateESP()

    if S.SoftAim or S.PredAim then
        local t = getClosest()
        if t then
            local target = getTargetPos(t)
            if target then
                local cf = CFrame.lookAt(Camera.CFrame.Position, target)
                Camera.CFrame = Camera.CFrame:Lerp(cf, S.Smooth)
            end
        end
    end

    -- triggerbot (только клик, без движения камеры)
    if S.Triggerbot then
        local t = getClosest()
        if t then
            local head = t.Character and t.Character:FindFirstChild("Head")
            if head then
                local pos, on = Camera:WorldToViewportPoint(head.Position)
                if on and (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude < 22 then
                    pcall(mouse1click)
                end
            end
        end
    end

    if FOVDraw then
        FOVDraw.Visible = S.FOVCircle
        FOVDraw.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
        FOVDraw.Radius = S.FOV
        FOVDraw.Color = S.ESPColor
    end
    if CrossDraw then
        CrossDraw.Visible = S.Crosshair
        local cx, cy = Mouse.X, Mouse.Y + 36
        CrossDraw.From = Vector2.new(cx - 7, cy)
        CrossDraw.To   = Vector2.new(cx + 7, cy)
        CrossDraw.Color = S.ESPColor
    end
end))

-- silent aim (попытка универсального хука)
safe(function()
    if not hookmetamethod then return end
    local old
    old = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if S.SilentAim and not checkcaller() then
            if method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay" or method == "Raycast" then
                local t = getClosest()
                if t and t.Character then
                    local part = t.Character:FindFirstChild(S.SilentPart) or t.Character:FindFirstChild("Head")
                    if part then
                        return part, part.Position
                    end
                end
            end
        end
        return old(self, ...)
    end)
end)

-- ===== MOVEMENT =====
local function setFly(on)
    S.Fly = on
    local r, h = root(), hum()
    if not r then return end
    if on then
        FlyBV = Instance.new("BodyVelocity")
        FlyBV.Name = "v"..R()
        FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyBV.Velocity = Vector3.zero
        FlyBV.Parent = r
        FlyBG = Instance.new("BodyGyro")
        FlyBG.Name = "g"..R()
        FlyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyBG.P = 9e4
        FlyBG.Parent = r
        if h then h.PlatformStand = true end
        notify("Полёт ВКЛ")
    else
        if FlyBV then FlyBV:Destroy() end
        if FlyBG then FlyBG:Destroy() end
        if h then h.PlatformStand = false end
        notify("Полёт ВЫКЛ")
    end
end

table.insert(Conns, RunService.RenderStepped:Connect(function()
    if not S.Fly or not FlyBV or not FlyBV.Parent then return end
    local m = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then m += Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then m -= Camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then m -= Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then m += Camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then m += Vector3.yAxis end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then m -= Vector3.yAxis end
    FlyBV.Velocity = m.Magnitude > 0 and m.Unit * 52 or Vector3.zero
    if FlyBG then FlyBG.CFrame = Camera.CFrame end
end))

table.insert(Conns, RunService.Stepped:Connect(function()
    if not S.Noclip then return end
    local c = char()
    if c then
        for _, p in pairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end))

table.insert(Conns, RunService.Heartbeat:Connect(function()
    -- speed anti-reset
    if S.Speed ~= 16 then
        local h = hum()
        if h then h.WalkSpeed = S.Speed end
    end
    -- god
    if S.God then
        local h = hum()
        if h then h.Health = h.MaxHealth end
    end
    -- anti fling
    if S.AntiFling then
        local r = root()
        if r and r.AssemblyLinearVelocity.Magnitude > 100 then
            r.AssemblyLinearVelocity = Vector3.zero
            r.AssemblyAngularVelocity = Vector3.zero
        end
    end
    -- airwalk
    if S.AirWalk and AirPart and root() then
        AirPart.CFrame = CFrame.new(root().Position.X, root().Position.Y - 3.15, root().Position.Z)
    end
end))

UserInputService.JumpRequest:Connect(function()
    if S.InfJump then
        local h = hum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- anti afk
table.insert(Conns, RunService.Heartbeat:Connect(function()
    if not S.AntiAFK then return end
    safe(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end))

Mouse.Button1Down:Connect(function()
    if S.ClickTP and root() and Mouse.Hit then
        root().CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
    end
end)

-- ===== FARM =====
table.insert(Conns, RunService.Heartbeat:Connect(function()
    if not S.AutoFarm then return end
    local r = root()
    if not r then return end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("chest") or v.Name:lower():find("cash")) then
            r.CFrame = v.CFrame + Vector3.new(0, 3, 0)
            break
        end
    end
end))

table.insert(Conns, RunService.Heartbeat:Connect(function()
    if not S.NPCFarm then return end
    local r = root()
    if not r then return end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local nh = v:FindFirstChildOfClass("Humanoid")
            if nh and nh.Health > 0 and not Players:GetPlayerFromCharacter(v) then
                r.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0, 0, -5)
                local tool = char() and char():FindFirstChildOfClass("Tool")
                if tool then pcall(function() tool:Activate() end) end
                break
            end
        end
    end
end))

-- ===== PANIC =====
local function panic()
    S.Fly = false
    S.Noclip = false
    S.Invis = false
    S.God = false
    S.ESP = false
    S.HealthESP = false
    S.Tracers = false
    S.SoftAim = false
    S.PredAim = false
    S.Triggerbot = false
    S.SilentAim = false
    S.AutoFarm = false
    S.NPCFarm = false
    S.ClickTP = false
    S.AirWalk = false
    if FlyBV then FlyBV:Destroy() end
    if FlyBG then FlyBG:Destroy() end
    if AirPart then AirPart:Destroy() AirPart = nil end
    clearAllDraw()
    setVisible(false)
    notify("PANIC — всё выключено", 3)
end

-- ===== GUI =====
local Gui = Instance.new("ScreenGui")
Gui.Name = "pm"..R()
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset = true
Gui.Parent = CoreGui

-- HUD
local HUD = Instance.new("TextLabel")
HUD.Size = UDim2.new(0, 460, 0, 18)
HUD.Position = UDim2.new(0, 10, 0, 6)
HUD.BackgroundTransparency = 1
HUD.Font = Enum.Font.GothamMedium
HUD.TextSize = 13
HUD.TextColor3 = Color3.fromRGB(0, 255, 180)
HUD.TextXAlignment = Enum.TextXAlignment.Left
HUD.TextStrokeTransparency = 0.5
HUD.Parent = Gui

table.insert(Conns, RunService.RenderStepped:Connect(function()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local t = math.floor(tick() - StartTime)
    local name = S.Streamer and "Streamer" or LP.Name
    HUD.Text = string.format("PacMan | FPS:%d | %s | %02d:%02d | %s", fps, game.Name, math.floor(t/60), t%60, name)
end))

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 560, 0, 440)
Main.Position = UDim2.new(0.5, -280, 0.5, -220)
Main.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
Main.BorderSizePixel = 0
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(45, 45, 70)

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 46)
Top.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
Top.BorderSizePixel = 0
Top.Parent = Main
Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 14)
local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0, 16)
TopFix.Position = UDim2.new(0, 0, 1, -16)
TopFix.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
TopFix.BorderSizePixel = 0
TopFix.Parent = Top

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 14, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🟡 PacMan Menu  ·  Shooter Quiet"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(255, 220, 70)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 32, 0, 32)
Close.Position = UDim2.new(1, -40, 0, 7)
Close.BackgroundColor3 = Color3.fromRGB(40, 28, 32)
Close.Text = "×"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 18
Close.TextColor3 = Color3.fromRGB(255, 110, 110)
Close.Parent = Top
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

local function setVisible(state)
    S.Visible = state
    if state then
        Main.Visible = true
        Main.BackgroundTransparency = 1
        TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
    else
        local tw = TweenService:Create(Main, TweenInfo.new(0.18), {BackgroundTransparency = 1})
        tw:Play()
        tw.Completed:Connect(function() Main.Visible = false end)
    end
end
Close.MouseButton1Click:Connect(function() setVisible(false) end)

-- drag
local dragging, dragStart, startPos
Top.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = i.Position
        startPos = Main.Position
    end
end)
Top.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == S.MenuKey then setVisible(not S.Visible) end
    if i.KeyCode == S.PanicKey then panic() end
end)

-- tabs
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -12, 0, 34)
TabFrame.Position = UDim2.new(0, 6, 0, 54)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = Main

local Pages, TabBtns = {}, {}
local tabs = {"Профиль", "Визуалы", "Бой", "Движение", "Фарм", "Игроки"}

local function makePage(n)
    local sc = Instance.new("ScrollingFrame")
    sc.Size = UDim2.new(1, -12, 1, -98)
    sc.Position = UDim2.new(0, 6, 0, 94)
    sc.BackgroundTransparency = 1
    sc.ScrollBarThickness = 3
    sc.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
    sc.Visible = false
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.Parent = Main
    Instance.new("UIListLayout", sc).Padding = UDim.new(0, 6)
    Pages[n] = sc
end

local function switch(n)
    for k, p in pairs(Pages) do p.Visible = (k == n) end
    for k, b in pairs(TabBtns) do
        b.BackgroundColor3 = (k == n) and Color3.fromRGB(55, 75, 170) or Color3.fromRGB(24, 24, 36)
        b.TextColor3 = (k == n) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 175)
    end
end

for i, n in ipairs(tabs) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 88, 1, 0)
    b.Position = UDim2.new(0, (i-1)*92, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(24, 24, 36)
    b.Text = n
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.TextColor3 = Color3.fromRGB(150, 150, 175)
    b.Parent = TabFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    TabBtns[n] = b
    b.MouseButton1Click:Connect(function() switch(n) end)
    makePage(n)
end

local function addToggle(parent, text, def, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 34)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -68, 1, 0)
    lbl.Position = UDim2.new(0, 10, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(210, 210, 230)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 48, 0, 22)
    btn.Position = UDim2.new(1, -56, 0.5, -11)
    btn.BackgroundColor3 = def and Color3.fromRGB(40, 130, 85) or Color3.fromRGB(45, 45, 58)
    btn.Text = def and "ВКЛ" or "ВЫКЛ"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = f
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local on = def
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = on and "ВКЛ" or "ВЫКЛ"
        btn.BackgroundColor3 = on and Color3.fromRGB(40, 130, 85) or Color3.fromRGB(45, 45, 58)
        cb(on)
    end)
end

local function addBtn(parent, text, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(24, 24, 38)
    b.Text = text
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.TextColor3 = Color3.fromRGB(170, 190, 255)
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(cb)
end

local function addSlider(parent, text, min, max, def, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 48)
    f.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, 16)
    lbl.Position = UDim2.new(0, 8, 0, 3)
    lbl.BackgroundTransparency = 1
    lbl.Text = text..": "..def
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -16, 0, 7)
    bar.Position = UDim2.new(0, 8, 0, 28)
    bar.BackgroundColor3 = Color3.fromRGB(36, 36, 50)
    bar.Parent = f
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 3)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((def-min)/(max-min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(60, 110, 200)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 3)
    local sliding = false
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            local val = math.floor(min + (max - min) * rel)
            lbl.Text = text..": "..val
            cb(val)
        end
    end)
end

-- ===== ПРОФИЛЬ =====
addToggle(Pages["Профиль"], "Streamer Mode", false, function(v) S.Streamer = v end)
addBtn(Pages["Профиль"], "PANIC (RightCtrl)", panic)
addBtn(Pages["Профиль"], "Сменить клавишу меню", function()
    notify("Нажми любую клавишу...")
    local c
    c = UserInputService.InputBegan:Connect(function(i, gp)
        if gp or i.KeyCode == Enum.KeyCode.Unknown then return end
        S.MenuKey = i.KeyCode
        notify("Клавиша: "..tostring(i.KeyCode))
        c:Disconnect()
    end)
end)

-- ===== ВИЗУАЛЫ =====
addToggle(Pages["Визуалы"], "ESP (только Drawing)", false, function(v) S.ESP = v end)
addToggle(Pages["Визуалы"], "Полоска HP", false, function(v) S.HealthESP = v end)
addToggle(Pages["Визуалы"], "Трасеры", false, function(v) S.Tracers = v end)
addToggle(Pages["Визуалы"], "FOV круг", false, function(v) S.FOVCircle = v end)
addToggle(Pages["Визуалы"], "Прицел", false, function(v) S.Crosshair = v end)
addSlider(Pages["Визуалы"], "FOV", 40, 350, 130, function(v) S.FOV = v end)

-- ===== БОЙ =====
addToggle(Pages["Бой"], "Soft Aim (плавный)", false, function(v) S.SoftAim = v notify(v and "Soft Aim ВКЛ" or "Soft Aim ВЫКЛ") end)
addToggle(Pages["Бой"], "Prediction", false, function(v) S.PredAim = v end)
addToggle(Pages["Бой"], "Triggerbot", false, function(v) S.Triggerbot = v notify(v and "Triggerbot ВКЛ" or "Triggerbot ВЫКЛ") end)
addToggle(Pages["Бой"], "Silent Aim", false, function(v) S.SilentAim = v notify(v and "Silent ВКЛ" or "Silent ВЫКЛ") end)
addBtn(Pages["Бой"], "Silent → Голова", function() S.SilentPart = "Head" notify("Silent: Голова") end)
addBtn(Pages["Бой"], "Silent → Тело", function() S.SilentPart = "HumanoidRootPart" notify("Silent: Тело") end)
addSlider(Pages["Бой"], "Плавность Soft", 4, 30, 12, function(v) S.Smooth = v / 100 end)

-- ===== ДВИЖЕНИЕ =====
addToggle(Pages["Движение"], "Полёт", false, setFly)
addToggle(Pages["Движение"], "Ноуклип", false, function(v) S.Noclip = v notify(v and "Ноуклип ВКЛ" or "Ноуклип ВЫКЛ") end)
addToggle(Pages["Движение"], "Невидимость", false, function(v)
    S.Invis = v
    local c = char()
    if c then
        for _, o in pairs(c:GetDescendants()) do
            if o:IsA("BasePart") or o:IsA("Decal") then
                o.LocalTransparencyModifier = v and 1 or 0
            end
        end
    end
    notify(v and "Невидимость ВКЛ" or "Невидимость ВЫКЛ")
end)
addToggle(Pages["Движение"], "Годмод", false, function(v) S.God = v notify(v and "Годмод ВКЛ" or "Годмод ВЫКЛ") end)
addToggle(Pages["Движение"], "Клик-ТП", false, function(v) S.ClickTP = v end)
addToggle(Pages["Движение"], "AirWalk", false, function(v)
    S.AirWalk = v
    if v then
        AirPart = Instance.new("Part")
        AirPart.Name = "aw"..R()
        AirPart.Size = Vector3.new(7, 0.2, 7)
        AirPart.Transparency = 1
        AirPart.Anchored = true
        AirPart.CanCollide = true
        AirPart.Parent = Workspace
    else
        if AirPart then AirPart:Destroy() AirPart = nil end
    end
    notify(v and "AirWalk ВКЛ" or "AirWalk ВЫКЛ")
end)
addToggle(Pages["Движение"], "Anti-Fling", true, function(v) S.AntiFling = v end)
addToggle(Pages["Движение"], "Беск. прыжок", false, function(v) S.InfJump = v end)
addToggle(Pages["Движение"], "Anti-AFK", true, function(v) S.AntiAFK = v end)
addSlider(Pages["Движение"], "Скорость", 16, 250, 16, function(v) S.Speed = v end)
addSlider(Pages["Движение"], "Прыжок", 50, 250, 50, function(v)
    S.Jump = v
    local h = hum()
    if h then h.UseJumpPower = true h.JumpPower = v end
end)

-- ===== ФАРМ =====
addToggle(Pages["Фарм"], "Автофарм монет", false, function(v) S.AutoFarm = v notify(v and "Фарм ВКЛ" or "Фарм ВЫКЛ") end)
addToggle(Pages["Фарм"], "Фарм NPC", false, function(v) S.NPCFarm = v notify(v and "NPC фарм ВКЛ" or "NPC фарм ВЫКЛ") end)
addBtn(Pages["Фарм"], "Смена сервера", function() TeleportService:Teleport(game.PlaceId, LP) end)

-- ===== ИГРОКИ =====
local function refresh()
    for _, c in pairs(Pages["Игроки"]:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    addBtn(Pages["Игроки"], "↻ Обновить", refresh)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            addBtn(Pages["Игроки"], p.Name, function()
                local r = root()
                local t = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                if r and t then r.CFrame = t.CFrame + Vector3.new(0, 3, 0) end
            end)
        end
    end
end
refresh()
Players.PlayerAdded:Connect(refresh)
Players.PlayerRemoving:Connect(refresh)

-- start
switch("Профиль")
setVisible(true)
notify("PacMan Quiet загружен | RightShift = меню | RightCtrl = PANIC", 4)
