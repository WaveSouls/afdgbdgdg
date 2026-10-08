-- PacMan Menu v3 | modern | LeftShift toggle | advanced anti-detect
-- name randomized every inject

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local TeleportService   = game:GetService("TeleportService")
local Lighting          = game:GetService("Lighting")
local Workspace         = game:GetService("Workspace")
local CoreGui           = game:GetService("CoreGui")
local StarterGui        = game:GetService("StarterGui")
local TextChatService   = game:GetService("TextChatService")
local HttpService       = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse  = LP:GetMouse()

-- ===== anti-detect helpers =====
local function rnd(n) return math.random(1000, 9999) .. (n or "") end
local function safe(fn, ...) local ok, a = pcall(fn, ...) return ok, a end
local function delay(t, fn) task.delay(t + math.random() * 0.15, fn) end

-- ===== state =====
local S = {
    Visible     = true,
    Fly         = false,
    Noclip      = false,
    Invis       = false,
    God         = false,
    ESP         = false,
    RoleESP     = false,
    Aimbot      = false,
    SilentAim   = false,
    AutoFarm    = false,
    ClickTP     = false,
    AirWalk     = false,
    AntiFling   = false,
    Spectate    = false,
    ChatSpy     = false,
    InfJump     = false,
    AntiAFK     = true,
    Tracers     = false,
    FOVCircle   = false,
    Crosshair   = false,
    Speed       = 16,
    Jump        = 50,
    FOV         = 140,
}

local Conns = {}
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "pm_" .. rnd()
ESPFolder.Parent = CoreGui

local StartTime = tick()
local FlyBV, FlyBG, AirPart
local SpectateTarget = nil
local DrawingObjects = {}

-- ===== notify =====
local function notify(txt, dur)
    dur = dur or 2.4
    safe(function()
        StarterGui:SetCore("SendNotification", {
            Title = "PacMan Menu",
            Text  = txt,
            Duration = dur
        })
    end)
end

-- ===== character helpers =====
local function char() return LP.Character end
local function hum()  local c = char() return c and c:FindFirstChildOfClass("Humanoid") end
local function root() local c = char() return c and c:FindFirstChild("HumanoidRootPart") end

local function getDevice()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then return "Mobile"
    elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then return "Console"
    else return "PC" end
end

-- ===== MM2 role =====
local function getRole(plr)
    local c = plr.Character
    if not c then return "Innocent" end
    local bp = plr:FindFirstChild("Backpack")
    if c:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife")) then return "Murderer" end
    if c:FindFirstChild("Gun")   or (bp and bp:FindFirstChild("Gun"))   then return "Sheriff"  end
    return "Innocent"
end

local RoleColor = {
    Murderer = Color3.fromRGB(255, 70, 70),
    Sheriff  = Color3.fromRGB(70, 140, 255),
    Innocent = Color3.fromRGB(70, 255, 120),
}

-- ===== Drawing (crosshair / FOV / tracers) =====
local function hasDrawing()
    return Drawing ~= nil
end

local function clearDrawings()
    for _, d in pairs(DrawingObjects) do
        if d and d.Remove then d:Remove() end
    end
    table.clear(DrawingObjects)
end

local function makeCircle()
    if not hasDrawing() then return end
    local c = Drawing.new("Circle")
    c.Thickness = 1.5
    c.NumSides = 64
    c.Radius = S.FOV
    c.Filled = false
    c.Visible = false
    c.Color = Color3.fromRGB(0, 255, 180)
    c.Transparency = 0.6
    table.insert(DrawingObjects, c)
    return c
end

local FOVDraw = makeCircle()
local CrossDraw = hasDrawing() and Drawing.new("Line") or nil
if CrossDraw then
    CrossDraw.Thickness = 1.5
    CrossDraw.Color = Color3.fromRGB(0, 255, 180)
    CrossDraw.Visible = false
    table.insert(DrawingObjects, CrossDraw)
end

-- tracers storage
local TracerLines = {}

-- ===== ESP =====
local function clearESP()
    for _, v in pairs(ESPFolder:GetChildren()) do v:Destroy() end
    for _, t in pairs(TracerLines) do if t.Remove then t:Remove() end end
    table.clear(TracerLines)
end

local function createESP(plr)
    if plr == LP then return end
    local c = plr.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return end

    local hl = Instance.new("Highlight")
    hl.Name = "h" .. rnd()
    hl.Adornee = c
    hl.FillTransparency = 0.65
    hl.OutlineTransparency = 0.15
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = ESPFolder

    local bill = Instance.new("BillboardGui")
    bill.Name = "b" .. rnd()
    bill.Adornee = c:FindFirstChild("Head") or c.HumanoidRootPart
    bill.Size = UDim2.new(0, 180, 0, 34)
    bill.StudsOffset = Vector3.new(0, 2.5, 0)
    bill.AlwaysOnTop = true
    bill.Parent = ESPFolder

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextStrokeTransparency = 0.5
    label.Parent = bill

    local tracer
    if hasDrawing() and S.Tracers then
        tracer = Drawing.new("Line")
        tracer.Thickness = 1.2
        tracer.Color = Color3.fromRGB(0, 255, 180)
        tracer.Transparency = 0.4
        tracer.Visible = true
        table.insert(TracerLines, tracer)
    end

    local conn = RunService.RenderStepped:Connect(function()
        if not (S.ESP or S.RoleESP) then return end
        if not c or not c.Parent then return end
        local role = getRole(plr)
        local col  = RoleColor[role] or Color3.fromRGB(200, 200, 200)
        hl.FillColor = col
        hl.OutlineColor = col
        label.TextColor3 = col
        label.Text = S.RoleESP and (plr.Name .. " [" .. role .. "]") or plr.Name

        if tracer and S.Tracers and c:FindFirstChild("HumanoidRootPart") then
            local pos, on = Camera:WorldToViewportPoint(c.HumanoidRootPart.Position)
            local sp = Camera:WorldToViewportPoint(root() and root().Position or Vector3.zero)
            if on then
                tracer.From = Vector2.new(sp.X, sp.Y)
                tracer.To   = Vector2.new(pos.X, pos.Y)
                tracer.Color = col
                tracer.Visible = true
            else
                tracer.Visible = false
            end
        end
    end)
    table.insert(Conns, conn)
end

local function refreshESP()
    clearESP()
    if not (S.ESP or S.RoleESP or S.Tracers) then return end
    for _, p in pairs(Players:GetPlayers()) do
        task.spawn(createESP, p)
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        delay(0.7, function()
            if S.ESP or S.RoleESP or S.Tracers then createESP(p) end
        end)
    end)
end)

-- ===== FLY =====
local function setFly(on)
    S.Fly = on
    local r = root()
    local h = hum()
    if not r then return end
    if on then
        FlyBV = Instance.new("BodyVelocity")
        FlyBV.Name = "v" .. rnd()
        FlyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyBV.Velocity = Vector3.zero
        FlyBV.Parent = r
        FlyBG = Instance.new("BodyGyro")
        FlyBG.Name = "g" .. rnd()
        FlyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyBG.P = 9e4
        FlyBG.Parent = r
        if h then h.PlatformStand = true end
        local c = RunService.RenderStepped:Connect(function()
            if not S.Fly or not FlyBV or not FlyBV.Parent then return end
            local m = Vector3.zero
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then m += Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then m -= Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then m -= Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then m += Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then m += Vector3.yAxis end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then m -= Vector3.yAxis end
            FlyBV.Velocity = m.Magnitude > 0 and m.Unit * 58 or Vector3.zero
            if FlyBG then FlyBG.CFrame = Camera.CFrame end
        end)
        table.insert(Conns, c)
        notify("Fly ON")
    else
        if FlyBV then FlyBV:Destroy() end
        if FlyBG then FlyBG:Destroy() end
        if h then h.PlatformStand = false end
        notify("Fly OFF")
    end
end

-- ===== NOCLIP =====
local function setNoclip(on)
    S.Noclip = on
    if on then
        local c = RunService.Stepped:Connect(function()
            if not S.Noclip then return end
            local ch = char()
            if ch then
                for _, p in pairs(ch:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
        table.insert(Conns, c)
        notify("Noclip ON")
    else notify("Noclip OFF") end
end

-- ===== INVIS =====
local function setInvis(on)
    S.Invis = on
    local ch = char()
    if not ch then return end
    for _, v in pairs(ch:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then
            v.LocalTransparencyModifier = on and 1 or 0
        end
    end
    notify(on and "Invis ON" or "Invis OFF")
end

-- ===== GOD =====
local function setGod(on)
    S.God = on
    if on then
        local c = RunService.Heartbeat:Connect(function()
            if not S.God then return end
            local h = hum()
            if h and h.Health < h.MaxHealth then h.Health = h.MaxHealth end
        end)
        table.insert(Conns, c)
        notify("GodMode ON")
    else notify("GodMode OFF") end
end

-- ===== CLICK TP =====
local function setClickTP(on)
    S.ClickTP = on
    notify(on and "Click-TP ON (click to tp)" or "Click-TP OFF")
end
Mouse.Button1Down:Connect(function()
    if not S.ClickTP then return end
    local r = root()
    if r and Mouse.Hit then
        r.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
    end
end)

-- ===== AIRWALK =====
local function setAirWalk(on)
    S.AirWalk = on
    if on then
        AirPart = Instance.new("Part")
        AirPart.Name = "aw" .. rnd()
        AirPart.Size = Vector3.new(6, 0.3, 6)
        AirPart.Transparency = 1
        AirPart.Anchored = true
        AirPart.CanCollide = true
        AirPart.Parent = Workspace
        local c = RunService.Heartbeat:Connect(function()
            if not S.AirWalk or not AirPart then return end
            local r = root()
            if r then
                AirPart.CFrame = CFrame.new(r.Position.X, r.Position.Y - 3.2, r.Position.Z)
            end
        end)
        table.insert(Conns, c)
        notify("AirWalk ON")
    else
        if AirPart then AirPart:Destroy() AirPart = nil end
        notify("AirWalk OFF")
    end
end

-- ===== ANTI-FLING =====
local function setAntiFling(on)
    S.AntiFling = on
    if on then
        local c = RunService.Heartbeat:Connect(function()
            if not S.AntiFling then return end
            local r = root()
            if r and r.AssemblyLinearVelocity.Magnitude > 80 then
                r.AssemblyLinearVelocity = Vector3.zero
                r.AssemblyAngularVelocity = Vector3.zero
            end
        end)
        table.insert(Conns, c)
        notify("Anti-Fling ON")
    else notify("Anti-Fling OFF") end
end

-- ===== SPECTATE =====
local function setSpectate(plr)
    if plr then
        S.Spectate = true
        SpectateTarget = plr
        Camera.CameraSubject = plr.Character and plr.Character:FindFirstChildOfClass("Humanoid") or Camera.CameraSubject
        notify("Spectate → " .. plr.Name)
    else
        S.Spectate = false
        SpectateTarget = nil
        Camera.CameraSubject = hum()
        notify("Spectate OFF")
    end
end

-- ===== ANIMATION CHANGER =====
local Anims = {
    ["Zombie"]   = "http://www.roblox.com/asset/?id=616158929",
    ["Ninja"]    = "http://www.roblox.com/asset/?id=656117400",
    ["Robot"]    = "http://www.roblox.com/asset/?id=616122287",
    ["Stylish"]  = "http://www.roblox.com/asset/?id=616136790",
    ["SuperHero"]= "http://www.roblox.com/asset/?id=616111295",
}
local function playAnim(id)
    local h = hum()
    if not h then return end
    local a = Instance.new("Animation")
    a.AnimationId = id
    local t = h:LoadAnimation(a)
    t:Play()
    notify("Animation applied")
end

-- ===== CHAT SPY =====
local function setChatSpy(on)
    S.ChatSpy = on
    if on then
        safe(function()
            local old = hookmetamethod and hookmetamethod(game, "__namecall", function(self, ...)
                local method = getnamecallmethod()
                if S.ChatSpy and method == "FireServer" and tostring(self):lower():find("chat") then
                    local args = {...}
                    if args[1] then
                        notify("[Spy] " .. tostring(args[1]), 4)
                    end
                end
                return old(self, ...)
            end) or nil
        end)
        -- TextChatService fallback
        safe(function()
            TextChatService.MessageReceived:Connect(function(msg)
                if S.ChatSpy and msg.TextSource and msg.TextSource.UserId ~= LP.UserId then
                    notify("[Spy] " .. msg.TextSource.Name .. ": " .. msg.Text, 3)
                end
            end)
        end)
        notify("Chat Spy ON")
    else notify("Chat Spy OFF") end
end

-- ===== SERVER HOP + AUTO REJOIN =====
local function serverHop()
    notify("Server hopping...")
    safe(function()
        local list = game:GetService("TeleportService"):GetPlayerPlaceInstanceAsync(LP.UserId)
        TeleportService:Teleport(game.PlaceId, LP)
    end)
end

LP.OnTeleport:Connect(function() end) -- silence
game:GetService("Players").PlayerRemoving:Connect(function(p)
    if p == LP then
        -- auto rejoin on kick/leave
        delay(1.5, function()
            TeleportService:Teleport(game.PlaceId)
        end)
    end
end)

-- ===== INFINITE JUMP =====
local function setInfJump(on)
    S.InfJump = on
    if on then
        local c = UserInputService.JumpRequest:Connect(function()
            if S.InfJump then
                local h = hum()
                if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end
        end)
        table.insert(Conns, c)
        notify("Infinite Jump ON")
    else notify("Infinite Jump OFF") end
end

-- ===== ANTI-AFK =====
local function setAntiAFK(on)
    S.AntiAFK = on
    if on then
        local c = RunService.Heartbeat:Connect(function()
            if not S.AntiAFK then return end
            safe(function()
                local vu = game:GetService("VirtualUser")
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end)
        end)
        table.insert(Conns, c)
        notify("Anti-AFK ON")
    else notify("Anti-AFK OFF") end
end
setAntiAFK(true) -- default on

-- ===== SPEED / JUMP =====
local function applySpeed()
    local h = hum()
    if h then h.WalkSpeed = S.Speed end
end
local function applyJump()
    local h = hum()
    if h then
        h.UseJumpPower = true
        h.JumpPower = S.Jump
    end
end
LP.CharacterAdded:Connect(function()
    delay(0.8, function()
        applySpeed()
        applyJump()
        if S.Invis then setInvis(true) end
    end)
end)

-- ===== AIMBOT / SILENT =====
local function getClosest(roleFilter)
    local closest, dist = nil, S.FOV
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
            if roleFilter and getRole(p) ~= roleFilter then continue end
            local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                local m = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if m < dist then dist = m closest = p end
            end
        end
    end
    return closest
end

table.insert(Conns, RunService.RenderStepped:Connect(function()
    if S.Aimbot then
        local t = getClosest()
        if t and t.Character and t.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, t.Character.Head.Position)
        end
    end
    -- FOV circle
    if FOVDraw then
        FOVDraw.Visible = S.FOVCircle
        FOVDraw.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
        FOVDraw.Radius = S.FOV
    end
    -- crosshair
    if CrossDraw then
        CrossDraw.Visible = S.Crosshair
        local cx, cy = Mouse.X, Mouse.Y + 36
        CrossDraw.From = Vector2.new(cx - 8, cy)
        CrossDraw.To   = Vector2.new(cx + 8, cy)
    end
end))

safe(function()
    if hookmetamethod then
        local old
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if S.SilentAim and method == "FindPartOnRayWithIgnoreList" and not checkcaller() then
                local t = getClosest("Murderer") or getClosest()
                if t and t.Character and t.Character:FindFirstChild("Head") then
                    return t.Character.Head, t.Character.Head.Position
                end
            end
            return old(self, ...)
        end)
    end
end)

-- ===== AUTO FARM =====
local function setFarm(on)
    S.AutoFarm = on
    if on then
        local c = RunService.Heartbeat:Connect(function()
            if not S.AutoFarm then return end
            local r = root()
            if not r then return end
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and v.Name:lower():find("coin") then
                    r.CFrame = v.CFrame + Vector3.new(0, 2.5, 0)
                    break
                end
            end
        end)
        table.insert(Conns, c)
        notify("AutoFarm ON")
    else notify("AutoFarm OFF") end
end

-- ===== TP =====
local function tpTo(plr)
    local r = root()
    local t = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if r and t then
        r.CFrame = t.CFrame + Vector3.new(0, 3, 0)
        notify("TP → " .. plr.Name)
    end
end

-- ===== BRING / FLING =====
local function bring(plr)
    local r = root()
    local t = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if r and t then
        t.CFrame = r.CFrame + Vector3.new(0, 0, -4)
        notify("Bring → " .. plr.Name)
    end
end
local function fling(plr)
    local t = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if t then
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.new(0, 999, 0)
        bv.Parent = t
        delay(0.3, function() bv:Destroy() end)
        notify("Fling → " .. plr.Name)
    end
end

-- ===== ADMIN ATTEMPT =====
local function tryAdmin()
    notify("Scanning remotes for admin...")
    local found = 0
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n = v.Name:lower()
            if n:find("admin") or n:find("cmd") or n:find("command") or n:find("ban") or n:find("kick") or n:find("give") then
                found += 1
                safe(function()
                    v:FireServer("admin")
                    v:FireServer(LP.Name, "admin")
                    v:FireServer("give", "admin")
                end)
            end
        end
    end
    notify(found > 0 and ("Tried " .. found .. " remotes") or "No admin remotes found (normal)")
end

-- ===== GUI =====
local Gui = Instance.new("ScreenGui")
Gui.Name = "pm_" .. rnd()
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 560, 0, 440)
Main.Position = UDim2.new(0.5, -280, 0.5, -220)
Main.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
Main.BorderSizePixel = 0
Main.Visible = true
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)
local st = Instance.new("UIStroke", Main)
st.Color = Color3.fromRGB(55, 55, 85)
st.Thickness = 1.2

-- title bar
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1, 0, 0, 46)
Top.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
Top.BorderSizePixel = 0
Top.Parent = Main
Instance.new("UICorner", Top).CornerRadius = UDim.new(0, 14)
local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1, 0, 0, 16)
TopFix.Position = UDim2.new(0, 0, 1, -16)
TopFix.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
TopFix.BorderSizePixel = 0
TopFix.Parent = Top

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "🟡 PacMan Menu"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255, 220, 80)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 32, 0, 32)
Close.Position = UDim2.new(1, -40, 0, 7)
Close.BackgroundColor3 = Color3.fromRGB(45, 30, 35)
Close.Text = "×"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 20
Close.TextColor3 = Color3.fromRGB(255, 110, 110)
Close.Parent = Top
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)
Close.MouseButton1Click:Connect(function()
    Main.Visible = false
    S.Visible = false
end)

-- drag
local dragging, dragStart, startPos
Top.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = i.Position
        startPos = Main.Position
    end
end)
Top.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
    end
end)

-- LeftShift toggle
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == Enum.KeyCode.LeftShift then
        S.Visible = not S.Visible
        Main.Visible = S.Visible
    end
end)

-- tabs
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1, -16, 0, 34)
TabFrame.Position = UDim2.new(0, 8, 0, 54)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = Main

local Pages, TabBtns = {}, {}
local tabNames = {"Profile", "MM2", "Universal", "Combat", "Players", "Admin"}

local function makePage(name)
    local sc = Instance.new("ScrollingFrame")
    sc.Size = UDim2.new(1, -16, 1, -100)
    sc.Position = UDim2.new(0, 8, 0, 96)
    sc.BackgroundTransparency = 1
    sc.BorderSizePixel = 0
    sc.ScrollBarThickness = 3
    sc.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 160)
    sc.Visible = false
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.CanvasSize = UDim2.new(0, 0, 0, 0)
    sc.Parent = Main
    local lay = Instance.new("UIListLayout", sc)
    lay.Padding = UDim.new(0, 7)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    Pages[name] = sc
    return sc
end

local function switch(name)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    for n, b in pairs(TabBtns) do
        b.BackgroundColor3 = (n == name) and Color3.fromRGB(70, 90, 200) or Color3.fromRGB(30, 30, 42)
        b.TextColor3 = (n == name) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 180)
    end
end

for i, name in ipairs(tabNames) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 86, 1, 0)
    b.Position = UDim2.new(0, (i - 1) * 90, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 42)
    b.Text = name
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.TextColor3 = Color3.fromRGB(150, 150, 180)
    b.Parent = TabFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    TabBtns[name] = b
    b.MouseButton1Click:Connect(function() switch(name) end)
    makePage(name)
end

-- UI builders
local function addToggle(parent, text, def, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 38)
    f.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
    f.BorderSizePixel = 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(210, 210, 230)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 50, 0, 24)
    btn.Position = UDim2.new(1, -58, 0.5, -12)
    btn.BackgroundColor3 = def and Color3.fromRGB(50, 140, 90) or Color3.fromRGB(50, 50, 65)
    btn.Text = def and "ON" or "OFF"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Parent = f
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    local on = def
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = on and "ON" or "OFF"
        btn.BackgroundColor3 = on and Color3.fromRGB(50, 140, 90) or Color3.fromRGB(50, 50, 65)
        cb(on)
    end)
end

local function addBtn(parent, text, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 36)
    b.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    b.Text = text
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.TextColor3 = Color3.fromRGB(170, 190, 255)
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    local s = Instance.new("UIStroke", b)
    s.Color = Color3.fromRGB(60, 70, 130)
    s.Thickness = 1
    s.Transparency = 0.5
    b.MouseButton1Click:Connect(cb)
end

local function addSlider(parent, text, min, max, def, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 50)
    f.BackgroundColor3 = Color3.fromRGB(24, 24, 34)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -20, 0, 20)
    lbl.Position = UDim2.new(0, 10, 0, 4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text .. ": " .. def
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(200, 200, 220)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 8)
    bar.Position = UDim2.new(0, 10, 0, 30)
    bar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
    bar.Parent = f
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((def - min) / (max - min), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(70, 120, 220)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)
    local sliding = false
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            local val = math.floor(min + (max - min) * rel)
            lbl.Text = text .. ": " .. val
            cb(val)
        end
    end)
end

-- ===== PROFILE =====
local profile = Pages["Profile"]
local avFrame = Instance.new("Frame")
avFrame.Size = UDim2.new(0, 88, 0, 88)
avFrame.Position = UDim2.new(0.5, -44, 0, 8)
avFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
avFrame.Parent = profile
Instance.new("UICorner", avFrame).CornerRadius = UDim.new(1, 0)
local avImg = Instance.new("ImageLabel")
avImg.Size = UDim2.new(1, -6, 1, -6)
avImg.Position = UDim2.new(0, 3, 0, 3)
avImg.BackgroundTransparency = 1
avImg.Parent = avFrame
Instance.new("UICorner", avImg).CornerRadius = UDim.new(1, 0)
task.spawn(function()
    local ok, content = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if ok then avImg.Image = content end
end)

local nameL = Instance.new("TextLabel")
nameL.Size = UDim2.new(1, 0, 0, 26)
nameL.Position = UDim2.new(0, 0, 0, 104)
nameL.BackgroundTransparency = 1
nameL.Text = LP.DisplayName .. "  (@" .. LP.Name .. ")"
nameL.Font = Enum.Font.GothamBold
nameL.TextSize = 15
nameL.TextColor3 = Color3.fromRGB(230, 230, 255)
nameL.Parent = profile

local devL = Instance.new("TextLabel")
devL.Size = UDim2.new(1, 0, 0, 20)
devL.Position = UDim2.new(0, 0, 0, 130)
devL.BackgroundTransparency = 1
devL.Text = "Device: " .. getDevice()
devL.Font = Enum.Font.Gotham
devL.TextSize = 13
devL.TextColor3 = Color3.fromRGB(140, 180, 220)
devL.Parent = profile

local infoL = Instance.new("TextLabel")
infoL.Size = UDim2.new(1, 0, 0, 70)
infoL.Position = UDim2.new(0, 0, 0, 158)
infoL.BackgroundTransparency = 1
infoL.Font = Enum.Font.Gotham
infoL.TextSize = 12
infoL.TextColor3 = Color3.fromRGB(150, 150, 180)
infoL.TextXAlignment = Enum.TextXAlignment.Left
infoL.Parent = profile
RunService.RenderStepped:Connect(function()
    local t = math.floor(tick() - StartTime)
    infoL.Text = string.format("UserId: %d\nPlace: %s\nPlaytime: %02d:%02d", LP.UserId, game.Name, math.floor(t/60), t%60)
end)

-- ===== MM2 =====
addToggle(Pages["MM2"], "Role ESP (Murder/Sheriff)", false, function(v) S.RoleESP = v if v then S.ESP = true end refreshESP() end)
addToggle(Pages["MM2"], "Player ESP", false, function(v) S.ESP = v refreshESP() end)
addToggle(Pages["MM2"], "Tracers", false, function(v) S.Tracers = v refreshESP() end)
addToggle(Pages["MM2"], "Auto Farm Coins", false, setFarm)
addToggle(Pages["MM2"], "GodMode", false, setGod)
addBtn(Pages["MM2"], "TP → Murderer", function()
    for _, p in pairs(Players:GetPlayers()) do if getRole(p) == "Murderer" then tpTo(p) return end end
    notify("Murderer not found")
end)
addBtn(Pages["MM2"], "TP → Sheriff", function()
    for _, p in pairs(Players:GetPlayers()) do if getRole(p) == "Sheriff" then tpTo(p) return end end
    notify("Sheriff not found")
end)

-- ===== UNIVERSAL =====
addToggle(Pages["Universal"], "Fly", false, setFly)
addToggle(Pages["Universal"], "Noclip", false, setNoclip)
addToggle(Pages["Universal"], "Invisibility", false, setInvis)
addToggle(Pages["Universal"], "GodMode", false, setGod)
addToggle(Pages["Universal"], "Click-TP", false, setClickTP)
addToggle(Pages["Universal"], "AirWalk", false, setAirWalk)
addToggle(Pages["Universal"], "Anti-Fling", false, setAntiFling)
addToggle(Pages["Universal"], "Infinite Jump", false, setInfJump)
addToggle(Pages["Universal"], "Anti-AFK", true, setAntiAFK)
addSlider(Pages["Universal"], "Speed", 16, 200, 16, function(v) S.Speed = v applySpeed() end)
addSlider(Pages["Universal"], "JumpPower", 50, 200, 50, function(v) S.Jump = v applyJump() end)
addBtn(Pages["Universal"], "Fullbright", function()
    Lighting.Brightness = 2 Lighting.ClockTime = 14 Lighting.FogEnd = 9e9
    notify("Fullbright")
end)
addBtn(Pages["Universal"], "Server Hop", serverHop)
addBtn(Pages["Universal"], "Rejoin", function() TeleportService:Teleport(game.PlaceId, LP) end)

-- ===== COMBAT =====
addToggle(Pages["Combat"], "Aimbot", false, function(v) S.Aimbot = v notify(v and "Aimbot ON" or "Aimbot OFF") end)
addToggle(Pages["Combat"], "Silent Aim", false, function(v) S.SilentAim = v notify(v and "Silent Aim ON" or "Silent Aim OFF") end)
addToggle(Pages["Combat"], "FOV Circle", false, function(v) S.FOVCircle = v end)
addToggle(Pages["Combat"], "Crosshair", false, function(v) S.Crosshair = v end)
addSlider(Pages["Combat"], "FOV Size", 50, 400, 140, function(v) S.FOV = v end)

-- ===== PLAYERS =====
local function refreshPlayers()
    for _, c in pairs(Pages["Players"]:GetChildren()) do
        if c:IsA("TextButton") or (c:IsA("Frame") and c.Name ~= "UIListLayout") then c:Destroy() end
    end
    addBtn(Pages["Players"], "↻ Refresh List", refreshPlayers)
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            addBtn(Pages["Players"], p.Name .. " [" .. getRole(p) .. "]", function() tpTo(p) end)
            addBtn(Pages["Players"], "Spectate " .. p.Name, function() setSpectate(p) end)
            addBtn(Pages["Players"], "Bring " .. p.Name, function() bring(p) end)
            addBtn(Pages["Players"], "Fling " .. p.Name, function() fling(p) end)
        end
    end
    addBtn(Pages["Players"], "Stop Spectate", function() setSpectate(nil) end)
end
refreshPlayers()
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)

-- ===== ADMIN =====
addBtn(Pages["Admin"], "Try Get Admin (scan remotes)", tryAdmin)
addBtn(Pages["Admin"], "Fire common admin remotes", function()
    local names = {"Admin", "Commands", "Cmd", "GiveAdmin", "SetAdmin", "Rank", "Ban", "Kick"}
    for _, n in pairs(names) do
        local r = ReplicatedStorage:FindFirstChild(n, true)
        if r and (r:IsA("RemoteEvent") or r:IsA("RemoteFunction")) then
            safe(function() r:FireServer("admin") end)
            safe(function() r:FireServer(LP.Name) end)
        end
    end
    notify("Fired common remotes")
end)
for name, id in pairs(Anims) do
    addBtn(Pages["Admin"], "Anim: " .. name, function() playAnim(id) end)
end
addToggle(Pages["Admin"], "Chat Spy", false, setChatSpy)

-- start
switch("Profile")
notify("PacMan Menu loaded  |  LeftShift = toggle", 3)