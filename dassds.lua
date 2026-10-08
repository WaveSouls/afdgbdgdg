--[[
    PacMan Menu v4
    - полностью на русском
    - плавное открытие/закрытие
    - ребинд клавиши
    - HUD сверху слева (FPS / игра / время)
    - soft aim + prediction + silent (голова/тело)
    - hitbox expander, vehicle fly, airwalk, tracers, color ESP
    - автофарм + NPC/крипы (Blox Fruits и универсальный)
    - оптимизация под PC / Mobile
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
local TextChatService  = game:GetService("TextChatService")
local ReplicatedStorage= game:GetService("ReplicatedStorage")
local HttpService      = game:GetService("HttpService")
local GuiService       = game:GetService("GuiService")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse  = LP:GetMouse()

-- ===== anti-detect =====
local function R(n) return tostring(math.random(10000,99999))..(n or "") end
local function safe(fn,...) local ok,a=pcall(fn,...) return ok,a end
local function jitter(t) return t + math.random()*0.12 end

-- ===== state =====
local S = {
    Visible      = true,
    MenuKey      = Enum.KeyCode.LeftShift,
    Fly          = false,
    Noclip       = false,
    Invis        = false,
    God          = false,
    ESP          = false,
    RoleESP      = false,
    Tracers      = false,
    Aimbot       = false,
    SoftAim      = false,
    PredAim      = false,
    SilentAim    = false,
    SilentPart   = "Head",          -- Head / HumanoidRootPart
    AutoFarm     = false,
    NPCFarm      = false,
    ClickTP      = false,
    AirWalk      = false,
    AntiFling    = false,
    InfJump      = false,
    AntiAFK      = true,
    FOVCircle    = false,
    Crosshair    = false,
    Hitbox       = false,
    HitboxSize   = 8,
    VehicleFly   = false,
    Speed        = 16,
    Jump         = 50,
    FOV          = 140,
    Smooth       = 0.18,            -- soft aim
    ESPColor     = Color3.fromRGB(0,255,180),
    TracerColor  = Color3.fromRGB(0,255,180),
}

local Conns = {}
local ESPFolder = Instance.new("Folder")
ESPFolder.Name = "pm"..R()
ESPFolder.Parent = CoreGui

local StartTime = tick()
local FlyBV, FlyBG, AirPart, VehBV
local DrawingObjs = {}
local hasDrawing = (Drawing ~= nil)

-- ===== notify =====
local function notify(txt, dur)
    dur = dur or 2.5
    safe(function()
        StarterGui:SetCore("SendNotification", {
            Title = "PacMan Menu",
            Text = txt,
            Duration = dur
        })
    end)
end

-- ===== helpers =====
local function char() return LP.Character end
local function hum()  local c=char() return c and c:FindFirstChildOfClass("Humanoid") end
local function root() local c=char() return c and c:FindFirstChild("HumanoidRootPart") end

local function getDevice()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then return "Mobile"
    elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then return "Console"
    else return "PC" end
end

local function getGameName()
    return game.Name or "Unknown"
end

-- MM2 role
local function getRole(plr)
    local c = plr.Character
    if not c then return "Невинный" end
    local bp = plr:FindFirstChild("Backpack")
    if c:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife")) then return "Убийца" end
    if c:FindFirstChild("Gun")   or (bp and bp:FindFirstChild("Gun"))   then return "Шериф" end
    return "Невинный"
end

local RoleColor = {
    ["Убийца"]  = Color3.fromRGB(255,70,70),
    ["Шериф"]   = Color3.fromRGB(70,140,255),
    ["Невинный"]= Color3.fromRGB(70,255,120),
}

-- ===== Drawing =====
local function clearDraw()
    for _,d in pairs(DrawingObjs) do if d and d.Remove then d:Remove() end end
    table.clear(DrawingObjs)
end

local FOVDraw, CrossDraw
if hasDrawing then
    FOVDraw = Drawing.new("Circle")
    FOVDraw.Thickness = 1.4
    FOVDraw.NumSides = 64
    FOVDraw.Filled = false
    FOVDraw.Visible = false
    FOVDraw.Color = Color3.fromRGB(0,255,180)
    FOVDraw.Transparency = 0.55
    table.insert(DrawingObjs, FOVDraw)

    CrossDraw = Drawing.new("Line")
    CrossDraw.Thickness = 1.5
    CrossDraw.Color = Color3.fromRGB(0,255,180)
    CrossDraw.Visible = false
    table.insert(DrawingObjs, CrossDraw)
end

local TracerLines = {}

-- ===== ESP =====
local function clearESP()
    for _,v in pairs(ESPFolder:GetChildren()) do v:Destroy() end
    for _,t in pairs(TracerLines) do if t.Remove then t:Remove() end end
    table.clear(TracerLines)
end

local function createESP(plr)
    if plr == LP then return end
    local c = plr.Character
    if not c or not c:FindFirstChild("HumanoidRootPart") then return end

    local hl = Instance.new("Highlight")
    hl.Name = "h"..R()
    hl.Adornee = c
    hl.FillTransparency = 0.62
    hl.OutlineTransparency = 0.12
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = ESPFolder

    local bill = Instance.new("BillboardGui")
    bill.Name = "b"..R()
    bill.Adornee = c:FindFirstChild("Head") or c.HumanoidRootPart
    bill.Size = UDim2.new(0, 200, 0, 40)
    bill.StudsOffset = Vector3.new(0, 2.7, 0)
    bill.AlwaysOnTop = true
    bill.Parent = ESPFolder

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1,0,1,0)
    bg.BackgroundColor3 = Color3.fromRGB(10,10,16)
    bg.BackgroundTransparency = 0.35
    bg.Parent = bill
    Instance.new("UICorner", bg).CornerRadius = UDim.new(0,6)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1,-8,1,0)
    label.Position = UDim2.new(0,4,0,0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.TextStrokeTransparency = 0.6
    label.Parent = bill

    local tracer
    if hasDrawing and S.Tracers then
        tracer = Drawing.new("Line")
        tracer.Thickness = 1.3
        tracer.Transparency = 0.35
        tracer.Visible = true
        table.insert(TracerLines, tracer)
    end

    local conn = RunService.RenderStepped:Connect(function()
        if not (S.ESP or S.RoleESP) then return end
        if not c or not c.Parent then return end
        local role = getRole(plr)
        local col = S.RoleESP and (RoleColor[role] or S.ESPColor) or S.ESPColor
        hl.FillColor = col
        hl.OutlineColor = col
        label.TextColor3 = col
        label.Text = S.RoleESP and (plr.Name.."  ["..role.."]") or plr.Name

        if tracer and S.Tracers and c:FindFirstChild("HumanoidRootPart") and root() then
            local pos, on = Camera:WorldToViewportPoint(c.HumanoidRootPart.Position)
            local sp = Camera:WorldToViewportPoint(root().Position)
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
    for _,p in pairs(Players:GetPlayers()) do
        task.spawn(function() task.wait(jitter(0.05)) createESP(p) end)
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(jitter(0.6))
        if S.ESP or S.RoleESP or S.Tracers then createESP(p) end
    end)
end)

-- ===== FLY =====
local function setFly(on)
    S.Fly = on
    local r,h = root(),hum()
    if not r then return end
    if on then
        FlyBV = Instance.new("BodyVelocity")
        FlyBV.Name = "v"..R()
        FlyBV.MaxForce = Vector3.new(9e9,9e9,9e9)
        FlyBV.Velocity = Vector3.zero
        FlyBV.Parent = r
        FlyBG = Instance.new("BodyGyro")
        FlyBG.Name = "g"..R()
        FlyBG.MaxTorque = Vector3.new(9e9,9e9,9e9)
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
        notify("Полёт ВКЛ")
    else
        if FlyBV then FlyBV:Destroy() end
        if FlyBG then FlyBG:Destroy() end
        if h then h.PlatformStand = false end
        notify("Полёт ВЫКЛ")
    end
end

-- ===== NOCLIP =====
local function setNoclip(on)
    S.Noclip = on
    if on then
        local c = RunService.Stepped:Connect(function()
            if not S.Noclip then return end
            local ch = char()
            if ch then for _,p in pairs(ch:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
        end)
        table.insert(Conns, c)
        notify("Ноуклип ВКЛ")
    else notify("Ноуклип ВЫКЛ") end
end

-- ===== INVIS =====
local function setInvis(on)
    S.Invis = on
    local ch = char()
    if not ch then return end
    for _,v in pairs(ch:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then
            v.LocalTransparencyModifier = on and 1 or 0
        end
    end
    notify(on and "Невидимость ВКЛ" or "Невидимость ВЫКЛ")
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
        notify("Годмод ВКЛ")
    else notify("Годмод ВЫКЛ") end
end

-- ===== CLICK TP =====
Mouse.Button1Down:Connect(function()
    if not S.ClickTP then return end
    local r = root()
    if r and Mouse.Hit then
        r.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,3,0))
    end
end)

-- ===== AIRWALK =====
local function setAirWalk(on)
    S.AirWalk = on
    if on then
        AirPart = Instance.new("Part")
        AirPart.Name = "aw"..R()
        AirPart.Size = Vector3.new(7,0.2,7)
        AirPart.Transparency = 1
        AirPart.Anchored = true
        AirPart.CanCollide = true
        AirPart.Parent = Workspace
        local c = RunService.Heartbeat:Connect(function()
            if not S.AirWalk or not AirPart then return end
            local r = root()
            if r then AirPart.CFrame = CFrame.new(r.Position.X, r.Position.Y-3.15, r.Position.Z) end
        end)
        table.insert(Conns, c)
        notify("AirWalk ВКЛ")
    else
        if AirPart then AirPart:Destroy() AirPart=nil end
        notify("AirWalk ВЫКЛ")
    end
end

-- ===== ANTI FLING =====
local function setAntiFling(on)
    S.AntiFling = on
    if on then
        local c = RunService.Heartbeat:Connect(function()
            if not S.AntiFling then return end
            local r = root()
            if r and r.AssemblyLinearVelocity.Magnitude > 90 then
                r.AssemblyLinearVelocity = Vector3.zero
                r.AssemblyAngularVelocity = Vector3.zero
            end
        end)
        table.insert(Conns, c)
        notify("Anti-Fling ВКЛ")
    else notify("Anti-Fling ВЫКЛ") end
end

-- ===== INF JUMP =====
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
        notify("Беск. прыжок ВКЛ")
    else notify("Беск. прыжок ВЫКЛ") end
end

-- ===== ANTI AFK =====
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
    end
end
setAntiAFK(true)

-- ===== HITBOX =====
local function setHitbox(on)
    S.Hitbox = on
    if on then
        local c = RunService.Heartbeat:Connect(function()
            if not S.Hitbox then return end
            for _,p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(S.HitboxSize, S.HitboxSize, S.HitboxSize)
                        hrp.Transparency = 0.7
                        hrp.CanCollide = false
                    end
                end
            end
        end)
        table.insert(Conns, c)
        notify("Hitbox ВКЛ")
    else
        for _,p in pairs(Players:GetPlayers()) do
            if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                p.Character.HumanoidRootPart.Size = Vector3.new(2,2,1)
                p.Character.HumanoidRootPart.Transparency = 1
            end
        end
        notify("Hitbox ВЫКЛ")
    end
end

-- ===== VEHICLE FLY =====
local function setVehicleFly(on)
    S.VehicleFly = on
    if on then
        local c = RunService.RenderStepped:Connect(function()
            if not S.VehicleFly then return end
            local seat = char() and char():FindFirstChildOfClass("Humanoid") and char().Humanoid.SeatPart
            if seat and seat.Parent then
                local veh = seat.Parent
                if not VehBV or VehBV.Parent ~= veh.PrimaryPart then
                    if VehBV then VehBV:Destroy() end
                    local pp = veh.PrimaryPart or veh:FindFirstChildWhichIsA("BasePart")
                    if pp then
                        VehBV = Instance.new("BodyVelocity")
                        VehBV.MaxForce = Vector3.new(9e9,9e9,9e9)
                        VehBV.Parent = pp
                    end
                end
                if VehBV then
                    local m = Vector3.zero
                    if UserInputService:IsKeyDown(Enum.KeyCode.W) then m += Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.S) then m -= Camera.CFrame.LookVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.A) then m -= Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.D) then m += Camera.CFrame.RightVector end
                    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then m += Vector3.yAxis end
                    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then m -= Vector3.yAxis end
                    VehBV.Velocity = m.Magnitude > 0 and m.Unit * 90 or Vector3.zero
                end
            end
        end)
        table.insert(Conns, c)
        notify("Vehicle Fly ВКЛ")
    else
        if VehBV then VehBV:Destroy() VehBV=nil end
        notify("Vehicle Fly ВЫКЛ")
    end
end

-- ===== SPEED / JUMP =====
local function applySpeed() local h=hum() if h then h.WalkSpeed = S.Speed end end
local function applyJump()  local h=hum() if h then h.UseJumpPower=true h.JumpPower=S.Jump end end
LP.CharacterAdded:Connect(function()
    task.wait(jitter(0.7))
    applySpeed() applyJump()
    if S.Invis then setInvis(true) end
end)

-- ===== AIM =====
local function getClosest(filter)
    local closest, dist = nil, S.FOV
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
            if filter and getRole(p) ~= filter then continue end
            local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                local m = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if m < dist then dist = m closest = p end
            end
        end
    end
    return closest
end

local function getPredPos(plr)
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local vel = hrp.AssemblyLinearVelocity
    return hrp.Position + vel * 0.12
end

table.insert(Conns, RunService.RenderStepped:Connect(function()
    -- soft / pred / classic aim
    if S.Aimbot or S.SoftAim or S.PredAim then
        local t = getClosest()
        if t and t.Character and t.Character:FindFirstChild("Head") then
            local targetPos = t.Character.Head.Position
            if S.PredAim then
                local pred = getPredPos(t)
                if pred then targetPos = pred end
            end
            if S.SoftAim then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, targetPos), S.Smooth)
            else
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
            end
        end
    end

    -- FOV + crosshair
    if FOVDraw then
        FOVDraw.Visible = S.FOVCircle
        FOVDraw.Position = Vector2.new(Mouse.X, Mouse.Y + 36)
        FOVDraw.Radius = S.FOV
        FOVDraw.Color = S.ESPColor
    end
    if CrossDraw then
        CrossDraw.Visible = S.Crosshair
        local cx,cy = Mouse.X, Mouse.Y+36
        CrossDraw.From = Vector2.new(cx-9, cy)
        CrossDraw.To   = Vector2.new(cx+9, cy)
        CrossDraw.Color = S.ESPColor
    end
end))

-- silent aim (head / body)
safe(function()
    if hookmetamethod then
        local old
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local method = getnamecallmethod()
            if S.SilentAim and (method == "FindPartOnRayWithIgnoreList" or method == "FindPartOnRay") and not checkcaller() then
                local t = getClosest()
                if t and t.Character then
                    local part = t.Character:FindFirstChild(S.SilentPart) or t.Character:FindFirstChild("Head")
                    if part then
                        return part, part.Position
                    end
                end
            end
            return old(self, ...)
        end)
    end
end)

-- ===== AUTO FARM + NPC =====
local function setFarm(on)
    S.AutoFarm = on
    if on then
        local c = RunService.Heartbeat:Connect(function()
            if not S.AutoFarm then return end
            local r = root()
            if not r then return end
            for _,v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("chest") or v.Name:lower():find("fruit")) then
                    r.CFrame = v.CFrame + Vector3.new(0,3,0)
                    break
                end
            end
        end)
        table.insert(Conns, c)
        notify("Автофарм ВКЛ")
    else notify("Автофарм ВЫКЛ") end
end

local function setNPCFarm(on)
    S.NPCFarm = on
    if on then
        local c = RunService.Heartbeat:Connect(function()
            if not S.NPCFarm then return end
            local r = root()
            local h = hum()
            if not r or not h then return end
            for _,v in pairs(Workspace:GetDescendants()) do
                if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                    local nh = v:FindFirstChildOfClass("Humanoid")
                    if nh and nh.Health > 0 and not Players:GetPlayerFromCharacter(v) then
                        r.CFrame = v.HumanoidRootPart.CFrame + Vector3.new(0,0,-4)
                        -- простая атака
                        safe(function()
                            local tool = char() and char():FindFirstChildOfClass("Tool")
                            if tool then tool:Activate() end
                        end)
                        break
                    end
                end
            end
        end)
        table.insert(Conns, c)
        notify("Фарм NPC/Крипов ВКЛ")
    else notify("Фарм NPC ВЫКЛ") end
end

-- ===== TP / BRING / FLING =====
local function tpTo(plr)
    local r = root()
    local t = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if r and t then r.CFrame = t.CFrame + Vector3.new(0,3,0) notify("ТП → "..plr.Name) end
end
local function bring(plr)
    local r = root()
    local t = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if r and t then t.CFrame = r.CFrame + Vector3.new(0,0,-4) notify("Притянуть → "..plr.Name) end
end
local function fling(plr)
    local t = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if t then
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        bv.Velocity = Vector3.new(0,1200,0)
        bv.Parent = t
        task.delay(0.25, function() bv:Destroy() end)
        notify("Флинг → "..plr.Name)
    end
end

-- ===== SERVER HOP =====
local function serverHop()
    notify("Смена сервера...")
    TeleportService:Teleport(game.PlaceId, LP)
end

-- ===== GUI =====
local Gui = Instance.new("ScreenGui")
Gui.Name = "pm"..R()
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset = true
Gui.Parent = CoreGui

-- HUD сверху слева
local HUD = Instance.new("TextLabel")
HUD.Size = UDim2.new(0, 420, 0, 22)
HUD.Position = UDim2.new(0, 12, 0, 8)
HUD.BackgroundTransparency = 1
HUD.Font = Enum.Font.GothamMedium
HUD.TextSize = 13
HUD.TextColor3 = Color3.fromRGB(0,255,180)
HUD.TextXAlignment = Enum.TextXAlignment.Left
HUD.TextStrokeTransparency = 0.6
HUD.Parent = Gui

RunService.RenderStepped:Connect(function()
    local fps = math.floor(1/RunService.RenderStepped:Wait())
    local t = math.floor(tick()-StartTime)
    HUD.Text = string.format("PacMan Menu  |  FPS: %d  |  %s  |  %02d:%02d  |  %s", fps, getGameName(), math.floor(t/60), t%60, getDevice())
end)

-- Main window
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 580, 0, 460)
Main.Position = UDim2.new(0.5, -290, 0.5, -230)
Main.BackgroundColor3 = Color3.fromRGB(14,14,20)
Main.BorderSizePixel = 0
Main.Visible = true
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)
local stroke = Instance.new("UIStroke", Main)
stroke.Color = Color3.fromRGB(50,50,80)
stroke.Thickness = 1.1

-- title
local Top = Instance.new("Frame")
Top.Size = UDim2.new(1,0,0,48)
Top.BackgroundColor3 = Color3.fromRGB(20,20,30)
Top.BorderSizePixel = 0
Top.Parent = Main
Instance.new("UICorner", Top).CornerRadius = UDim.new(0,16)
local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1,0,0,18)
TopFix.Position = UDim2.new(0,0,1,-18)
TopFix.BackgroundColor3 = Color3.fromRGB(20,20,30)
TopFix.BorderSizePixel = 0
TopFix.Parent = Top

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1,-50,1,0)
Title.Position = UDim2.new(0,16,0,0)
Title.BackgroundTransparency = 1
Title.Text = "🟡 PacMan Menu"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255,220,70)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Top

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0,34,0,34)
Close.Position = UDim2.new(1,-42,0,7)
Close.BackgroundColor3 = Color3.fromRGB(40,28,32)
Close.Text = "×"
Close.Font = Enum.Font.GothamBold
Close.TextSize = 20
Close.TextColor3 = Color3.fromRGB(255,110,110)
Close.Parent = Top
Instance.new("UICorner", Close).CornerRadius = UDim.new(0,9)

-- smooth show/hide
local function setVisible(state)
    S.Visible = state
    if state then
        Main.Visible = true
        Main.BackgroundTransparency = 1
        TweenService:Create(Main, TweenInfo.new(0.28, Enum.EasingStyle.Quint), {BackgroundTransparency = 0}):Play()
        for _,v in pairs(Main:GetDescendants()) do
            if v:IsA("GuiObject") and v ~= Main then
                v.BackgroundTransparency = 1
                if v:IsA("TextLabel") or v:IsA("TextButton") then v.TextTransparency = 1 end
                TweenService:Create(v, TweenInfo.new(0.28), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
            end
        end
    else
        local tw = TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {BackgroundTransparency = 1})
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
    if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)

-- rebind + toggle
UserInputService.InputBegan:Connect(function(i,gp)
    if gp then return end
    if i.KeyCode == S.MenuKey then
        setVisible(not S.Visible)
    end
end)

-- responsive size
local function adaptSize()
    local cam = Workspace.CurrentCamera
    if not cam then return end
    local vs = cam.ViewportSize
    local w = math.clamp(vs.X * 0.55, 420, 620)
    local h = math.clamp(vs.Y * 0.65, 380, 500)
    Main.Size = UDim2.new(0, w, 0, h)
    Main.Position = UDim2.new(0.5, -w/2, 0.5, -h/2)
end
adaptSize()
Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(adaptSize)

-- tabs
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1,-16,0,36)
TabFrame.Position = UDim2.new(0,8,0,56)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = Main

local Pages, TabBtns = {}, {}
local tabNames = {"Профиль","MM2","Универсал","Бой","Игроки","Фарм","Админ"}

local function makePage(name)
    local sc = Instance.new("ScrollingFrame")
    sc.Size = UDim2.new(1,-16,1,-104)
    sc.Position = UDim2.new(0,8,0,100)
    sc.BackgroundTransparency = 1
    sc.BorderSizePixel = 0
    sc.ScrollBarThickness = 3
    sc.ScrollBarImageColor3 = Color3.fromRGB(90,90,140)
    sc.Visible = false
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.Parent = Main
    local lay = Instance.new("UIListLayout", sc)
    lay.Padding = UDim.new(0,7)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    Pages[name] = sc
    return sc
end

local function switch(name)
    for n,p in pairs(Pages) do p.Visible = (n==name) end
    for n,b in pairs(TabBtns) do
        b.BackgroundColor3 = (n==name) and Color3.fromRGB(65,85,190) or Color3.fromRGB(28,28,40)
        b.TextColor3 = (n==name) and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,180)
    end
end

for i,name in ipairs(tabNames) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,78,1,0)
    b.Position = UDim2.new(0,(i-1)*82,0,0)
    b.BackgroundColor3 = Color3.fromRGB(28,28,40)
    b.Text = name
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.TextColor3 = Color3.fromRGB(150,150,180)
    b.Parent = TabFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    TabBtns[name] = b
    b.MouseButton1Click:Connect(function() switch(name) end)
    makePage(name)
end

-- UI helpers
local function addToggle(parent, text, def, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,38)
    f.BackgroundColor3 = Color3.fromRGB(22,22,32)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-70,1,0)
    lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextColor3 = Color3.fromRGB(210,210,230)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0,50,0,24)
    btn.Position = UDim2.new(1,-58,0.5,-12)
    btn.BackgroundColor3 = def and Color3.fromRGB(50,140,90) or Color3.fromRGB(50,50,65)
    btn.Text = def and "ВКЛ" or "ВЫКЛ"
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.TextColor3 = Color3.fromRGB(255,255,255)
    btn.Parent = f
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,7)
    local on = def
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = on and "ВКЛ" or "ВЫКЛ"
        btn.BackgroundColor3 = on and Color3.fromRGB(50,140,90) or Color3.fromRGB(50,50,65)
        cb(on)
    end)
end

local function addBtn(parent, text, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,36)
    b.BackgroundColor3 = Color3.fromRGB(28,28,42)
    b.Text = text
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.TextColor3 = Color3.fromRGB(170,190,255)
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
    b.MouseButton1Click:Connect(cb)
end

local function addSlider(parent, text, min, max, def, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,52)
    f.BackgroundColor3 = Color3.fromRGB(22,22,32)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,10)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,20)
    lbl.Position = UDim2.new(0,10,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Text = text..": "..def
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextColor3 = Color3.fromRGB(200,200,220)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1,-20,0,8)
    bar.Position = UDim2.new(0,10,0,30)
    bar.BackgroundColor3 = Color3.fromRGB(40,40,55)
    bar.Parent = f
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,4)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((def-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(70,120,220)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,4)
    local sliding = false
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
            fill.Size = UDim2.new(rel,0,1,0)
            local val = math.floor(min + (max-min)*rel)
            lbl.Text = text..": "..val
            cb(val)
        end
    end)
end

-- ===== ПРОФИЛЬ =====
local profile = Pages["Профиль"]
local avFrame = Instance.new("Frame")
avFrame.Size = UDim2.new(0,96,0,96)
avFrame.Position = UDim2.new(0.5,-48,0,8)
avFrame.BackgroundColor3 = Color3.fromRGB(35,35,55)
avFrame.Parent = profile
Instance.new("UICorner", avFrame).CornerRadius = UDim.new(1,0)
local ring = Instance.new("UIStroke", avFrame)
ring.Color = Color3.fromRGB(0,220,160)
ring.Thickness = 2.5

local avImg = Instance.new("ImageLabel")
avImg.Size = UDim2.new(1,-8,1,-8)
avImg.Position = UDim2.new(0,4,0,4)
avImg.BackgroundTransparency = 1
avImg.Parent = avFrame
Instance.new("UICorner", avImg).CornerRadius = UDim.new(1,0)
task.spawn(function()
    local ok, content = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if ok then avImg.Image = content end
end)

local nameL = Instance.new("TextLabel")
nameL.Size = UDim2.new(1,0,0,26)
nameL.Position = UDim2.new(0,0,0,112)
nameL.BackgroundTransparency = 1
nameL.Text = LP.DisplayName.."  (@"..LP.Name..")"
nameL.Font = Enum.Font.GothamBold
nameL.TextSize = 16
nameL.TextColor3 = Color3.fromRGB(230,230,255)
nameL.Parent = profile

local infoL = Instance.new("TextLabel")
infoL.Size = UDim2.new(1,0,0,90)
infoL.Position = UDim2.new(0,0,0,142)
infoL.BackgroundTransparency = 1
infoL.Font = Enum.Font.Gotham
infoL.TextSize = 13
infoL.TextColor3 = Color3.fromRGB(150,160,190)
infoL.TextXAlignment = Enum.TextXAlignment.Left
infoL.Parent = profile
RunService.RenderStepped:Connect(function()
    local t = math.floor(tick()-StartTime)
    infoL.Text = string.format("Устройство: %s\nИгра: %s\nUserId: %d\nВремя в игре: %02d:%02d", getDevice(), getGameName(), LP.UserId, math.floor(t/60), t%60)
end)

addBtn(profile, "Сменить клавишу меню (нажми любую)", function()
    notify("Нажми любую клавишу...")
    local conn
    conn = UserInputService.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode ~= Enum.KeyCode.Unknown then
            S.MenuKey = i.KeyCode
            notify("Клавиша меню: "..tostring(i.KeyCode))
            conn:Disconnect()
        end
    end)
end)

-- ===== MM2 =====
addToggle(Pages["MM2"], "ESP ролей (Убийца/Шериф)", false, function(v) S.RoleESP=v if v then S.ESP=true end refreshESP() end)
addToggle(Pages["MM2"], "ESP игроков", false, function(v) S.ESP=v refreshESP() end)
addToggle(Pages["MM2"], "Трасеры", false, function(v) S.Tracers=v refreshESP() end)
addToggle(Pages["MM2"], "Годмод", false, setGod)
addBtn(Pages["MM2"], "ТП к Убийце", function()
    for _,p in pairs(Players:GetPlayers()) do if getRole(p)=="Убийца" then tpTo(p) return end end
    notify("Убийца не найден")
end)
addBtn(Pages["MM2"], "ТП к Шерифу", function()
    for _,p in pairs(Players:GetPlayers()) do if getRole(p)=="Шериф" then tpTo(p) return end end
    notify("Шериф не найден")
end)

-- ===== УНИВЕРСАЛ =====
addToggle(Pages["Универсал"], "Полёт", false, setFly)
addToggle(Pages["Универсал"], "Ноуклип", false, setNoclip)
addToggle(Pages["Универсал"], "Невидимость", false, setInvis)
addToggle(Pages["Универсал"], "Годмод", false, setGod)
addToggle(Pages["Универсал"], "Клик-ТП", false, function(v) S.ClickTP=v notify(v and "Клик-ТП ВКЛ" or "Клик-ТП ВЫКЛ") end)
addToggle(Pages["Универсал"], "AirWalk", false, setAirWalk)
addToggle(Pages["Универсал"], "Anti-Fling", false, setAntiFling)
addToggle(Pages["Универсал"], "Бесконечный прыжок", false, setInfJump)
addToggle(Pages["Универсал"], "Anti-AFK", true, setAntiAFK)
addToggle(Pages["Универсал"], "Vehicle Fly", false, setVehicleFly)
addSlider(Pages["Универсал"], "Скорость", 16, 250, 16, function(v) S.Speed=v applySpeed() end)
addSlider(Pages["Универсал"], "Прыжок", 50, 250, 50, function(v) S.Jump=v applyJump() end)
addBtn(Pages["Универсал"], "Fullbright", function()
    Lighting.Brightness=2 Lighting.ClockTime=14 Lighting.FogEnd=9e9
    notify("Fullbright")
end)
addBtn(Pages["Универсал"], "Смена сервера", serverHop)
addBtn(Pages["Универсал"], "Реджойн", function() TeleportService:Teleport(game.PlaceId, LP) end)

-- ===== БОЙ =====
addToggle(Pages["Бой"], "Аимбот", false, function(v) S.Aimbot=v notify(v and "Аимбот ВКЛ" or "Аимбот ВЫКЛ") end)
addToggle(Pages["Бой"], "Soft Aim (плавный)", false, function(v) S.SoftAim=v notify(v and "Soft Aim ВКЛ" or "Soft Aim ВЫКЛ") end)
addToggle(Pages["Бой"], "Prediction Aim", false, function(v) S.PredAim=v notify(v and "Prediction ВКЛ" or "Prediction ВЫКЛ") end)
addToggle(Pages["Бой"], "Silent Aim", false, function(v) S.SilentAim=v notify(v and "Silent Aim ВКЛ" or "Silent Aim ВЫКЛ") end)
addBtn(Pages["Бой"], "Silent → Голова", function() S.SilentPart="Head" notify("Silent: Голова") end)
addBtn(Pages["Бой"], "Silent → Тело", function() S.SilentPart="HumanoidRootPart" notify("Silent: Тело") end)
addToggle(Pages["Бой"], "FOV круг", false, function(v) S.FOVCircle=v end)
addToggle(Pages["Бой"], "Прицел", false, function(v) S.Crosshair=v end)
addToggle(Pages["Бой"], "Hitbox Expander", false, setHitbox)
addSlider(Pages["Бой"], "Размер Hitbox", 2, 25, 8, function(v) S.HitboxSize=v end)
addSlider(Pages["Бой"], "FOV", 40, 400, 140, function(v) S.FOV=v end)
addSlider(Pages["Бой"], "Плавность Soft", 5, 40, 18, function(v) S.Smooth=v/100 end)

-- ===== ИГРОКИ =====
local function refreshPlayers()
    for _,c in pairs(Pages["Игроки"]:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    addBtn(Pages["Игроки"], "↻ Обновить список", refreshPlayers)
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP then
            addBtn(Pages["Игроки"], p.Name.." ["..getRole(p).."]", function() tpTo(p) end)
            addBtn(Pages["Игроки"], "Притянуть "..p.Name, function() bring(p) end)
            addBtn(Pages["Игроки"], "Флинг "..p.Name, function() fling(p) end)
        end
    end
end
refreshPlayers()
Players.PlayerAdded:Connect(refreshPlayers)
Players.PlayerRemoving:Connect(refreshPlayers)

-- ===== ФАРМ =====
addToggle(Pages["Фарм"], "Автофарм монет/сундуков", false, setFarm)
addToggle(Pages["Фарм"], "Фарм NPC / Крипов / Ботов", false, setNPCFarm)
addBtn(Pages["Фарм"], "ТП на ближайший коин", function()
    local r = root()
    if not r then return end
    for _,v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and v.Name:lower():find("coin") then
            r.CFrame = v.CFrame + Vector3.new(0,3,0)
            notify("ТП к монете")
            return
        end
    end
    notify("Монеты не найдены")
end)

-- ===== АДМИН =====
addBtn(Pages["Админ"], "Попытка получить админку (скан remote)", function()
    notify("Сканирую remote...")
    local found = 0
    for _,v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n = v.Name:lower()
            if n:find("admin") or n:find("cmd") or n:find("command") or n:find("rank") then
                found += 1
                safe(function() v:FireServer("admin") end)
                safe(function() v:FireServer(LP.Name, "admin") end)
            end
        end
    end
    notify(found > 0 and ("Попробовал "..found.." remote") or "Админ remote не найдены")
end)
addToggle(Pages["Админ"], "Chat Spy", false, function(v)
    S.ChatSpy = v
    if v then
        safe(function()
            TextChatService.MessageReceived:Connect(function(msg)
                if S.ChatSpy and msg.TextSource and msg.TextSource.UserId ~= LP.UserId then
                    notify("[Spy] "..msg.TextSource.Name..": "..msg.Text, 3)
                end
            end)
        end)
        notify("Chat Spy ВКЛ")
    else notify("Chat Spy ВЫКЛ") end
end)

-- start
switch("Профиль")
setVisible(true)
notify("PacMan Menu успешно заинжекчен", 3)
