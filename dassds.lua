--[[
    PacMan Menu v5
    RightShift = меню
    Drawing ESP (меньше киков в шутерах)
    скорость / год / аим переписаны
    + большой пакет новых функций
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
local Stats            = game:GetService("Stats")

local LP     = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse  = LP:GetMouse()

local function R() return tostring(math.random(10000,99999)) end
local function safe(fn,...) local ok,a = pcall(fn,...) return ok,a end
local function jitter(t) return t + math.random()*0.1 end

-- ===== STATE =====
local S = {
    Visible     = true,
    MenuKey     = Enum.KeyCode.RightShift,
    PanicKey    = Enum.KeyCode.RightControl,
    Fly         = false,
    Noclip      = false,
    Invis       = false,
    God         = false,
    ESP         = false,
    RoleESP     = false,
    Tracers     = false,
    HealthESP   = false,
    Aimbot      = false,
    SoftAim     = false,
    PredAim     = false,
    SilentAim   = false,
    SilentPart  = "Head",
    Triggerbot  = false,
    SoftRecoil  = false,
    AutoReload  = false,
    MeleeReach  = false,
    Hitbox      = false,
    HitboxSize  = 10,
    AutoFarm    = false,
    NPCFarm     = false,
    ClickTP     = false,
    AirWalk     = false,
    AntiFling   = false,
    InfJump     = false,
    AntiAFK     = true,
    FOVCircle   = false,
    Crosshair   = false,
    VehicleFly  = false,
    VehSpeed    = false,
    WalkWater   = false,
    ClimbAny    = false,
    Gravity     = false,
    FogRemove   = false,
    Streamer    = false,
    Speed       = 16,
    Jump        = 50,
    FOV         = 140,
    Smooth      = 0.16,
    Reach       = 15,
    ESPColor    = Color3.fromRGB(0,255,180),
    BoxColor    = Color3.fromRGB(0,255,180),
    GuiScale    = 1,
}

local Conns = {}
local DrawObjs = {}
local hasDrawing = (type(Drawing) == "table" or type(Drawing) == "userdata")
local StartTime = tick()
local FlyBV, FlyBG, AirPart, VehBV
local originalGravity = Workspace.Gravity

-- ===== NOTIFY =====
local function notify(t, d)
    d = d or 2.4
    safe(function()
        StarterGui:SetCore("SendNotification", {Title="PacMan Menu", Text=t, Duration=d})
    end)
end

-- ===== HELPERS =====
local function char() return LP.Character end
local function hum()  local c=char() return c and c:FindFirstChildOfClass("Humanoid") end
local function root() local c=char() return c and c:FindFirstChild("HumanoidRootPart") end

local function getDevice()
    if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled then return "Mobile"
    elseif UserInputService.GamepadEnabled and not UserInputService.KeyboardEnabled then return "Console"
    else return "PC" end
end

local function getRole(plr)
    local c = plr.Character
    if not c then return "Невинный" end
    local bp = plr:FindFirstChild("Backpack")
    if c:FindFirstChild("Knife") or (bp and bp:FindFirstChild("Knife")) then return "Убийца" end
    if c:FindFirstChild("Gun") or (bp and bp:FindFirstChild("Gun")) then return "Шериф" end
    return "Невинный"
end

local RoleColor = {
    ["Убийца"] = Color3.fromRGB(255,70,70),
    ["Шериф"]  = Color3.fromRGB(70,140,255),
    ["Невинный"]= Color3.fromRGB(80,255,120),
}

-- ===== DRAWING ESP (безопаснее для шутеров) =====
local function clearDraw()
    for _,d in pairs(DrawObjs) do
        if d and d.Remove then pcall(function() d:Remove() end) end
    end
    table.clear(DrawObjs)
end

local function makeDraw(typ)
    if not hasDrawing then return nil end
    local o = Drawing.new(typ)
    table.insert(DrawObjs, o)
    return o
end

local FOVDraw = makeDraw("Circle")
if FOVDraw then
    FOVDraw.Thickness = 1.3
    FOVDraw.NumSides = 64
    FOVDraw.Filled = false
    FOVDraw.Visible = false
    FOVDraw.Transparency = 0.5
end

local CrossDraw = makeDraw("Line")
if CrossDraw then
    CrossDraw.Thickness = 1.5
    CrossDraw.Visible = false
end

local ESPCache = {} -- [player] = {box, name, hp, tracer}

local function removePlayerESP(plr)
    local t = ESPCache[plr]
    if not t then return end
    for _,o in pairs(t) do
        if o and o.Remove then pcall(function() o:Remove() end) end
    end
    ESPCache[plr] = nil
end

local function createPlayerESP(plr)
    if plr == LP or not hasDrawing then return end
    removePlayerESP(plr)

    local box = makeDraw("Square")
    local name = makeDraw("Text")
    local hp = makeDraw("Line")
    local tracer = makeDraw("Line")

    if box then
        box.Thickness = 1.2
        box.Filled = false
        box.Visible = false
    end
    if name then
        name.Size = 14
        name.Center = true
        name.Outline = true
        name.Visible = false
    end
    if hp then
        hp.Thickness = 2
        hp.Visible = false
    end
    if tracer then
        tracer.Thickness = 1.1
        tracer.Transparency = 0.4
        tracer.Visible = false
    end

    ESPCache[plr] = {box=box, name=name, hp=hp, tracer=tracer}
end

local function updateESP()
    if not (S.ESP or S.RoleESP or S.Tracers or S.HealthESP) then
        for plr,_ in pairs(ESPCache) do removePlayerESP(plr) end
        return
    end

    for _,plr in pairs(Players:GetPlayers()) do
        if plr == LP then continue end
        if not ESPCache[plr] then createPlayerESP(plr) end
        local cache = ESPCache[plr]
        local c = plr.Character
        local hrp = c and c:FindFirstChild("HumanoidRootPart")
        local head = c and c:FindFirstChild("Head")
        local human = c and c:FindFirstChildOfClass("Humanoid")

        if not hrp or not head then
            if cache.box then cache.box.Visible = false end
            if cache.name then cache.name.Visible = false end
            if cache.hp then cache.hp.Visible = false end
            if cache.tracer then cache.tracer.Visible = false end
            continue
        end

        local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0,0.4,0))
        local footPos = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0,2.5,0))

        local role = getRole(plr)
        local col = S.RoleESP and (RoleColor[role] or S.ESPColor) or S.ESPColor

        if onScreen and (S.ESP or S.RoleESP) then
            local h = math.abs(headPos.Y - footPos.Y)
            local w = h / 1.8
            if cache.box then
                cache.box.Size = Vector2.new(w, h)
                cache.box.Position = Vector2.new(pos.X - w/2, headPos.Y)
                cache.box.Color = col
                cache.box.Visible = true
            end
            if cache.name then
                cache.name.Text = S.RoleESP and (plr.Name.." ["..role.."]") or plr.Name
                if S.Streamer then cache.name.Text = "Player" end
                cache.name.Position = Vector2.new(pos.X, headPos.Y - 16)
                cache.name.Color = col
                cache.name.Visible = true
            end
        else
            if cache.box then cache.box.Visible = false end
            if cache.name then cache.name.Visible = false end
        end

        -- health bar
        if S.HealthESP and human and onScreen and cache.hp then
            local pct = math.clamp(human.Health / human.MaxHealth, 0, 1)
            local h = math.abs(headPos.Y - footPos.Y)
            cache.hp.From = Vector2.new(pos.X - (h/1.8)/2 - 5, footPos.Y)
            cache.hp.To   = Vector2.new(pos.X - (h/1.8)/2 - 5, footPos.Y - h * pct)
            cache.hp.Color = Color3.fromRGB(255*(1-pct), 255*pct, 40)
            cache.hp.Visible = true
        elseif cache.hp then
            cache.hp.Visible = false
        end

        -- tracer
        if S.Tracers and onScreen and cache.tracer and root() then
            local my = Camera:WorldToViewportPoint(root().Position)
            cache.tracer.From = Vector2.new(my.X, my.Y)
            cache.tracer.To   = Vector2.new(pos.X, pos.Y)
            cache.tracer.Color = col
            cache.tracer.Visible = true
        elseif cache.tracer then
            cache.tracer.Visible = false
        end
    end
end

Players.PlayerRemoving:Connect(removePlayerESP)

-- ===== SPEED (анти-сброс) =====
local function applySpeed()
    local h = hum()
    if h then
        h.WalkSpeed = S.Speed
    end
end

-- постоянно держим скорость
table.insert(Conns, RunService.Heartbeat:Connect(function()
    if S.Speed ~= 16 then
        applySpeed()
    end
end))

-- ===== GOD (сильнее) =====
local function setGod(on)
    S.God = on
    if on then
        notify("Годмод ВКЛ")
    else
        notify("Годмод ВЫКЛ")
    end
end

table.insert(Conns, RunService.Heartbeat:Connect(function()
    if not S.God then return end
    local h = hum()
    if h then
        h.Health = h.MaxHealth
        h:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
        h:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
    end
end))

-- ===== FLY =====
local function setFly(on)
    S.Fly = on
    local r, h = root(), hum()
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
    FlyBV.Velocity = m.Magnitude > 0 and m.Unit * 56 or Vector3.zero
    if FlyBG then FlyBG.CFrame = Camera.CFrame end
end))

-- ===== NOCLIP =====
local function setNoclip(on)
    S.Noclip = on
    notify(on and "Ноуклип ВКЛ" or "Ноуклип ВЫКЛ")
end
table.insert(Conns, RunService.Stepped:Connect(function()
    if not S.Noclip then return end
    local c = char()
    if c then
        for _,p in pairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end
end))

-- ===== INVIS =====
local function setInvis(on)
    S.Invis = on
    local c = char()
    if not c then return end
    for _,v in pairs(c:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then
            v.LocalTransparencyModifier = on and 1 or 0
        end
    end
    notify(on and "Невидимость ВКЛ" or "Невидимость ВЫКЛ")
end

-- ===== AIRWALK / WATER / CLIMB =====
local function setAirWalk(on)
    S.AirWalk = on
    if on then
        AirPart = Instance.new("Part")
        AirPart.Name = "aw"..R()
        AirPart.Size = Vector3.new(8,0.2,8)
        AirPart.Transparency = 1
        AirPart.Anchored = true
        AirPart.CanCollide = true
        AirPart.Parent = Workspace
        notify("AirWalk ВКЛ")
    else
        if AirPart then AirPart:Destroy() AirPart = nil end
        notify("AirWalk ВЫКЛ")
    end
end
table.insert(Conns, RunService.Heartbeat:Connect(function()
    if S.AirWalk and AirPart and root() then
        AirPart.CFrame = CFrame.new(root().Position.X, root().Position.Y - 3.2, root().Position.Z)
    end
    if S.WalkWater and root() then
        local ray = Ray.new(root().Position, Vector3.new(0,-5,0))
        local hit = Workspace:FindPartOnRay(ray, char())
        if hit and hit.Material == Enum.Material.Water then
            root().Velocity = Vector3.new(root().Velocity.X, 2, root().Velocity.Z)
        end
    end
end))

-- ===== ANTI FLING =====
table.insert(Conns, RunService.Heartbeat:Connect(function()
    if not S.AntiFling then return end
    local r = root()
    if r and r.AssemblyLinearVelocity.Magnitude > 95 then
        r.AssemblyLinearVelocity = Vector3.zero
        r.AssemblyAngularVelocity = Vector3.zero
    end
end))

-- ===== INF JUMP =====
UserInputService.JumpRequest:Connect(function()
    if S.InfJump then
        local h = hum()
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

-- ===== ANTI AFK =====
table.insert(Conns, RunService.Heartbeat:Connect(function()
    if not S.AntiAFK then return end
    safe(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end))

-- ===== HITBOX =====
table.insert(Conns, RunService.Heartbeat:Connect(function()
    if not S.Hitbox then return end
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                hrp.Size = Vector3.new(S.HitboxSize, S.HitboxSize, S.HitboxSize)
                hrp.Transparency = 0.65
                hrp.CanCollide = false
            end
        end
    end
end))

-- ===== MELEE REACH =====
table.insert(Conns, RunService.Heartbeat:Connect(function()
    if not S.MeleeReach then return end
    local tool = char() and char():FindFirstChildOfClass("Tool")
    if tool then
        for _,p in pairs(tool:GetDescendants()) do
            if p:IsA("BasePart") then
                p.Size = Vector3.new(S.Reach/3, S.Reach/3, S.Reach)
            end
        end
    end
end))

-- ===== VEHICLE =====
table.insert(Conns, RunService.RenderStepped:Connect(function()
    local seat = hum() and hum().SeatPart
    if not seat then return end
    local veh = seat.Parent
    if not veh then return end

    if S.VehicleFly then
        if not VehBV or VehBV.Parent ~= (veh.PrimaryPart or seat) then
            if VehBV then VehBV:Destroy() end
            local pp = veh.PrimaryPart or seat
            VehBV = Instance.new("BodyVelocity")
            VehBV.MaxForce = Vector3.new(9e9,9e9,9e9)
            VehBV.Parent = pp
        end
        local m = Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then m += Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then m -= Camera.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then m -= Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then m += Camera.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then m += Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then m -= Vector3.yAxis end
        if VehBV then VehBV.Velocity = m.Magnitude > 0 and m.Unit * 95 or Vector3.zero end
    end

    if S.VehSpeed and veh.PrimaryPart then
        local v = veh.PrimaryPart
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            v.AssemblyLinearVelocity = Camera.CFrame.LookVector * 120
        end
    end
end))

-- ===== AIM =====
local function getClosest()
    local closest, dist = nil, S.FOV
    for _,p in pairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and p.Character:FindFirstChild("Head") then
            local pos, vis = Camera:WorldToViewportPoint(p.Character.Head.Position)
            if vis then
                local m = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(pos.X, pos.Y)).Magnitude
                if m < dist then dist = m closest = p end
            end
        end
    end
    return closest
end

local function getPred(plr)
    local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    return hrp.Position + hrp.AssemblyLinearVelocity * 0.13
end

table.insert(Conns, RunService.RenderStepped:Connect(function()
    updateESP()

    if S.Aimbot or S.SoftAim or S.PredAim then
        local t = getClosest()
        if t and t.Character and t.Character:FindFirstChild("Head") then
            local target = t.Character.Head.Position
            if S.PredAim then
                local p = getPred(t)
                if p then target = p end
            end
            if S.SoftAim then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, target), S.Smooth)
            else
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, target)
            end
        end
    end

    -- triggerbot
    if S.Triggerbot then
        local t = getClosest()
        if t and t.Character and t.Character:FindFirstChild("Head") then
            local pos, on = Camera:WorldToViewportPoint(t.Character.Head.Position)
            if on and (Vector2.new(Mouse.X,Mouse.Y)-Vector2.new(pos.X,pos.Y)).Magnitude < 25 then
                mouse1click()
            end
        end
    end

    if FOVDraw then
        FOVDraw.Visible = S.FOVCircle
        FOVDraw.Position = Vector2.new(Mouse.X, Mouse.Y+36)
        FOVDraw.Radius = S.FOV
        FOVDraw.Color = S.ESPColor
    end
    if CrossDraw then
        CrossDraw.Visible = S.Crosshair
        local cx,cy = Mouse.X, Mouse.Y+36
        CrossDraw.From = Vector2.new(cx-8,cy)
        CrossDraw.To = Vector2.new(cx+8,cy)
        CrossDraw.Color = S.ESPColor
    end
end))

-- silent aim
safe(function()
    if hookmetamethod then
        local old
        old = hookmetamethod(game, "__namecall", function(self, ...)
            local m = getnamecallmethod()
            if S.SilentAim and (m == "FindPartOnRayWithIgnoreList" or m == "FindPartOnRay" or m == "ScreenPointToRay") and not checkcaller() then
                local t = getClosest()
                if t and t.Character then
                    local part = t.Character:FindFirstChild(S.SilentPart) or t.Character:FindFirstChild("Head")
                    if part then return part, part.Position end
                end
            end
            return old(self, ...)
        end)
    end
end)

-- soft recoil (простое)
table.insert(Conns, RunService.RenderStepped:Connect(function()
    if not S.SoftRecoil then return end
    Camera.CFrame = Camera.CFrame * CFrame.Angles(-0.001, 0, 0)
end))

-- auto reload
table.insert(Conns, RunService.Heartbeat:Connect(function()
    if not S.AutoReload then return end
    local tool = char() and char():FindFirstChildOfClass("Tool")
    if tool and tool:FindFirstChild("Ammo") and tool.Ammo.Value <= 0 then
        safe(function() tool:Activate() end)
    end
end))

-- ===== FARM =====
local function setFarm(on)
    S.AutoFarm = on
    notify(on and "Автофарм ВКЛ" or "Автофарм ВЫКЛ")
end
table.insert(Conns, RunService.Heartbeat:Connect(function()
    if not S.AutoFarm then return end
    local r = root()
    if not r then return end
    for _,v in pairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") and (v.Name:lower():find("coin") or v.Name:lower():find("chest") or v.Name:lower():find("fruit") or v.Name:lower():find("cash")) then
            r.CFrame = v.CFrame + Vector3.new(0,3,0)
            break
        end
    end
end))

local function setNPCFarm(on)
    S.NPCFarm = on
    notify(on and "Фарм NPC ВКЛ" or "Фарм NPC ВЫКЛ")
end
table.insert(Conns, RunService.Heartbeat:Connect(function()
    if not S.NPCFarm then return end
    local r = root()
    if not r then return end
    for _,v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Model") and v:FindFirstChildOfClass("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
            local nh = v:FindFirstChildOfClass("Humanoid")
            if nh and nh.Health > 0 and not Players:GetPlayerFromCharacter(v) then
                r.CFrame = v.HumanoidRootPart.CFrame * CFrame.new(0,0,-5)
                local tool = char() and char():FindFirstChildOfClass("Tool")
                if tool then safe(function() tool:Activate() end) end
                break
            end
        end
    end
end))

-- ===== WORLD =====
local function setGravity(on)
    S.Gravity = on
    Workspace.Gravity = on and 20 or originalGravity
    notify(on and "Гравитация ↓" or "Гравитация норма")
end

local function setFog(on)
    S.FogRemove = on
    if on then
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
    else
        Lighting.FogEnd = 1000
    end
    notify(on and "Туман убран" or "Туман вернули")
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
    if r and t then t.CFrame = r.CFrame * CFrame.new(0,0,-4) notify("Притянуть → "..plr.Name) end
end
local function fling(plr)
    local t = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
    if t then
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        bv.Velocity = Vector3.new(0,1400,0)
        bv.Parent = t
        task.delay(0.2, function() bv:Destroy() end)
        notify("Флинг → "..plr.Name)
    end
end

-- ===== PANIC =====
local function panic()
    S.Fly=false S.Noclip=false S.Invis=false S.God=false
    S.ESP=false S.RoleESP=false S.Tracers=false S.HealthESP=false
    S.Aimbot=false S.SoftAim=false S.PredAim=false S.SilentAim=false
    S.Triggerbot=false S.Hitbox=false S.AutoFarm=false S.NPCFarm=false
    S.ClickTP=false S.AirWalk=false S.VehicleFly=false
    if FlyBV then FlyBV:Destroy() end
    if FlyBG then FlyBG:Destroy() end
    if AirPart then AirPart:Destroy() end
    clearDraw()
    for plr,_ in pairs(ESPCache) do removePlayerESP(plr) end
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
HUD.Size = UDim2.new(0,480,0,20)
HUD.Position = UDim2.new(0,10,0,6)
HUD.BackgroundTransparency = 1
HUD.Font = Enum.Font.GothamMedium
HUD.TextSize = 13
HUD.TextColor3 = Color3.fromRGB(0,255,180)
HUD.TextXAlignment = Enum.TextXAlignment.Left
HUD.TextStrokeTransparency = 0.55
HUD.Parent = Gui

table.insert(Conns, RunService.RenderStepped:Connect(function()
    local fps = math.floor(1 / RunService.RenderStepped:Wait())
    local t = math.floor(tick() - StartTime)
    local name = S.Streamer and "Streamer" or LP.Name
    HUD.Text = string.format("PacMan Menu | FPS:%d | %s | %02d:%02d | %s | %s", fps, game.Name, math.floor(t/60), t%60, getDevice(), name)
end))

-- Main
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 600, 0, 470)
Main.Position = UDim2.new(0.5, -300, 0.5, -235)
Main.BackgroundColor3 = Color3.fromRGB(13,13,19)
Main.BorderSizePixel = 0
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,16)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(45,45,75)

local Top = Instance.new("Frame")
Top.Size = UDim2.new(1,0,0,48)
Top.BackgroundColor3 = Color3.fromRGB(18,18,28)
Top.BorderSizePixel = 0
Top.Parent = Main
Instance.new("UICorner", Top).CornerRadius = UDim.new(0,16)
local TopFix = Instance.new("Frame")
TopFix.Size = UDim2.new(1,0,0,18)
TopFix.Position = UDim2.new(0,0,1,-18)
TopFix.BackgroundColor3 = Color3.fromRGB(18,18,28)
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

local function setVisible(state)
    S.Visible = state
    if state then
        Main.Visible = true
        Main.BackgroundTransparency = 1
        TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundTransparency=0}):Play()
    else
        local tw = TweenService:Create(Main, TweenInfo.new(0.2), {BackgroundTransparency=1})
        tw:Play()
        tw.Completed:Connect(function() Main.Visible = false end)
    end
end
Close.MouseButton1Click:Connect(function() setVisible(false) end)

-- drag
local dragging, dragStart, startPos
Top.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        dragging=true dragStart=i.Position startPos=Main.Position
    end
end)
Top.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging=false end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X, startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)

-- keys
UserInputService.InputBegan:Connect(function(i, gp)
    if gp then return end
    if i.KeyCode == S.MenuKey then setVisible(not S.Visible) end
    if i.KeyCode == S.PanicKey then panic() end
end)

-- responsive
local function adapt()
    local vs = Camera.ViewportSize
    local w = math.clamp(vs.X*0.55, 440, 640)
    local h = math.clamp(vs.Y*0.68, 400, 520)
    Main.Size = UDim2.new(0,w,0,h)
    Main.Position = UDim2.new(0.5,-w/2,0.5,-h/2)
end
adapt()
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(adapt)

-- tabs
local TabFrame = Instance.new("Frame")
TabFrame.Size = UDim2.new(1,-16,0,36)
TabFrame.Position = UDim2.new(0,8,0,56)
TabFrame.BackgroundTransparency = 1
TabFrame.Parent = Main

local Pages, TabBtns = {}, {}
local tabs = {"Профиль","Визуалы","Бой","Движение","Фарм","Игроки","Мир","Система"}

local function makePage(n)
    local sc = Instance.new("ScrollingFrame")
    sc.Size = UDim2.new(1,-16,1,-104)
    sc.Position = UDim2.new(0,8,0,100)
    sc.BackgroundTransparency = 1
    sc.ScrollBarThickness = 3
    sc.ScrollBarImageColor3 = Color3.fromRGB(80,80,130)
    sc.Visible = false
    sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sc.Parent = Main
    Instance.new("UIListLayout", sc).Padding = UDim.new(0,6)
    Pages[n] = sc
    return sc
end

local function switch(n)
    for k,p in pairs(Pages) do p.Visible = (k==n) end
    for k,b in pairs(TabBtns) do
        b.BackgroundColor3 = (k==n) and Color3.fromRGB(60,80,180) or Color3.fromRGB(26,26,38)
        b.TextColor3 = (k==n) and Color3.fromRGB(255,255,255) or Color3.fromRGB(150,150,180)
    end
end

for i,n in ipairs(tabs) do
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0,72,1,0)
    b.Position = UDim2.new(0,(i-1)*76,0,0)
    b.BackgroundColor3 = Color3.fromRGB(26,26,38)
    b.Text = n
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.TextColor3 = Color3.fromRGB(150,150,180)
    b.Parent = TabFrame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
    TabBtns[n] = b
    b.MouseButton1Click:Connect(function() switch(n) end)
    makePage(n)
end

local function addToggle(parent, text, def, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,36)
    f.BackgroundColor3 = Color3.fromRGB(20,20,30)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,9)
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
    btn.BackgroundColor3 = def and Color3.fromRGB(45,140,90) or Color3.fromRGB(48,48,62)
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
        btn.BackgroundColor3 = on and Color3.fromRGB(45,140,90) or Color3.fromRGB(48,48,62)
        cb(on)
    end)
end

local function addBtn(parent, text, cb)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,0,0,34)
    b.BackgroundColor3 = Color3.fromRGB(26,26,40)
    b.Text = text
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.TextColor3 = Color3.fromRGB(170,190,255)
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,9)
    b.MouseButton1Click:Connect(cb)
end

local function addSlider(parent, text, min, max, def, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1,0,0,50)
    f.BackgroundColor3 = Color3.fromRGB(20,20,30)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0,9)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1,-20,0,18)
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
    bar.Position = UDim2.new(0,10,0,28)
    bar.BackgroundColor3 = Color3.fromRGB(38,38,52)
    bar.Parent = f
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0,4)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((def-min)/(max-min),0,1,0)
    fill.BackgroundColor3 = Color3.fromRGB(65,115,210)
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0,4)
    local sliding = false
    bar.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding=true end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then sliding=false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if sliding then
            local rel = math.clamp((i.Position.X-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            fill.Size = UDim2.new(rel,0,1,0)
            local val = math.floor(min+(max-min)*rel)
            lbl.Text = text..": "..val
            cb(val)
        end
    end)
end

-- ===== ПРОФИЛЬ =====
local profile = Pages["Профиль"]
local av = Instance.new("Frame")
av.Size = UDim2.new(0,90,0,90)
av.Position = UDim2.new(0.5,-45,0,6)
av.BackgroundColor3 = Color3.fromRGB(30,30,50)
av.Parent = profile
Instance.new("UICorner", av).CornerRadius = UDim.new(1,0)
Instance.new("UIStroke", av).Color = Color3.fromRGB(0,220,160)

local avImg = Instance.new("ImageLabel")
avImg.Size = UDim2.new(1,-6,1,-6)
avImg.Position = UDim2.new(0,3,0,3)
avImg.BackgroundTransparency = 1
avImg.Parent = av
Instance.new("UICorner", avImg).CornerRadius = UDim.new(1,0)
task.spawn(function()
    local ok, content = pcall(function()
        return Players:GetUserThumbnailAsync(LP.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
    end)
    if ok then avImg.Image = content end
end)

local nameL = Instance.new("TextLabel")
nameL.Size = UDim2.new(1,0,0,24)
nameL.Position = UDim2.new(0,0,0,102)
nameL.BackgroundTransparency = 1
nameL.Text = LP.DisplayName.." (@"..LP.Name..")"
nameL.Font = Enum.Font.GothamBold
nameL.TextSize = 15
nameL.TextColor3 = Color3.fromRGB(230,230,255)
nameL.Parent = profile

local infoL = Instance.new("TextLabel")
infoL.Size = UDim2.new(1,0,0,80)
infoL.Position = UDim2.new(0,0,0,130)
infoL.BackgroundTransparency = 1
infoL.Font = Enum.Font.Gotham
infoL.TextSize = 13
infoL.TextColor3 = Color3.fromRGB(150,160,190)
infoL.TextXAlignment = Enum.TextXAlignment.Left
infoL.Parent = profile
table.insert(Conns, RunService.RenderStepped:Connect(function()
    local t = math.floor(tick()-StartTime)
    infoL.Text = string.format("Устройство: %s\nИгра: %s\nUserId: %d\nВремя: %02d:%02d", getDevice(), game.Name, LP.UserId, math.floor(t/60), t%60)
end))

addToggle(profile, "Streamer Mode (скрывает ник)", false, function(v) S.Streamer=v notify(v and "Streamer ON" or "Streamer OFF") end)
addBtn(profile, "Сменить клавишу меню", function()
    notify("Нажми любую клавишу...")
    local c
    c = UserInputService.InputBegan:Connect(function(i,gp)
        if gp or i.KeyCode==Enum.KeyCode.Unknown then return end
        S.MenuKey = i.KeyCode
        notify("Клавиша меню: "..tostring(i.KeyCode))
        c:Disconnect()
    end)
end)
addBtn(profile, "PANIC (выключить всё)", panic)

-- ===== ВИЗУАЛЫ =====
addToggle(Pages["Визуалы"], "ESP (Drawing — безопаснее)", false, function(v) S.ESP=v end)
addToggle(Pages["Визуалы"], "ESP ролей (MM2)", false, function(v) S.RoleESP=v if v then S.ESP=true end end)
addToggle(Pages["Визуалы"], "Трасеры", false, function(v) S.Tracers=v end)
addToggle(Pages["Визуалы"], "Полоска HP", false, function(v) S.HealthESP=v end)
addToggle(Pages["Визуалы"], "FOV круг", false, function(v) S.FOVCircle=v end)
addToggle(Pages["Визуалы"], "Прицел", false, function(v) S.Crosshair=v end)
addSlider(Pages["Визуалы"], "FOV размер", 40, 400, 140, function(v) S.FOV=v end)

-- ===== БОЙ =====
addToggle(Pages["Бой"], "Аимбот", false, function(v) S.Aimbot=v notify(v and "Аимбот ВКЛ" or "Аимбот ВЫКЛ") end)
addToggle(Pages["Бой"], "Soft Aim", false, function(v) S.SoftAim=v end)
addToggle(Pages["Бой"], "Prediction Aim", false, function(v) S.PredAim=v end)
addToggle(Pages["Бой"], "Silent Aim", false, function(v) S.SilentAim=v notify(v and "Silent ВКЛ" or "Silent ВЫКЛ") end)
addBtn(Pages["Бой"], "Silent → Голова", function() S.SilentPart="Head" notify("Silent: Голова") end)
addBtn(Pages["Бой"], "Silent → Тело", function() S.SilentPart="HumanoidRootPart" notify("Silent: Тело") end)
addToggle(Pages["Бой"], "Triggerbot", false, function(v) S.Triggerbot=v notify(v and "Triggerbot ВКЛ" or "Triggerbot ВЫКЛ") end)
addToggle(Pages["Бой"], "Soft Recoil", false, function(v) S.SoftRecoil=v end)
addToggle(Pages["Бой"], "Auto Reload", false, function(v) S.AutoReload=v end)
addToggle(Pages["Бой"], "Melee Reach", false, function(v) S.MeleeReach=v end)
addToggle(Pages["Бой"], "Hitbox Expander", false, function(v) S.Hitbox=v notify(v and "Hitbox ВКЛ" or "Hitbox ВЫКЛ") end)
addSlider(Pages["Бой"], "Размер Hitbox", 2, 30, 10, function(v) S.HitboxSize=v end)
addSlider(Pages["Бой"], "Плавность Soft", 5, 40, 16, function(v) S.Smooth=v/100 end)
addSlider(Pages["Бой"], "Melee Reach", 5, 40, 15, function(v) S.Reach=v end)

-- ===== ДВИЖЕНИЕ =====
addToggle(Pages["Движение"], "Полёт", false, setFly)
addToggle(Pages["Движение"], "Ноуклип", false, setNoclip)
addToggle(Pages["Движение"], "Невидимость", false, setInvis)
addToggle(Pages["Движение"], "Годмод", false, setGod)
addToggle(Pages["Движение"], "Клик-ТП", false, function(v) S.ClickTP=v notify(v and "Клик-ТП ВКЛ" or "Клик-ТП ВЫКЛ") end)
addToggle(Pages["Движение"], "AirWalk", false, setAirWalk)
addToggle(Pages["Движение"], "Anti-Fling", false, function(v) S.AntiFling=v end)
addToggle(Pages["Движение"], "Беск. прыжок", false, function(v) S.InfJump=v end)
addToggle(Pages["Движение"], "Anti-AFK", true, function(v) S.AntiAFK=v end)
addToggle(Pages["Движение"], "Vehicle Fly", false, function(v) S.VehicleFly=v notify(v and "Veh Fly ВКЛ" or "Veh Fly ВЫКЛ") end)
addToggle(Pages["Движение"], "Vehicle Speed", false, function(v) S.VehSpeed=v end)
addToggle(Pages["Движение"], "Ходьба по воде", false, function(v) S.WalkWater=v end)
addSlider(Pages["Движение"], "Скорость", 16, 300, 16, function(v) S.Speed=v applySpeed() end)
addSlider(Pages["Движение"], "Прыжок", 50, 300, 50, function(v) S.Jump=v local h=hum() if h then h.UseJumpPower=true h.JumpPower=v end end)

Mouse.Button1Down:Connect(function()
    if S.ClickTP and root() and Mouse.Hit then
        root().CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0,3,0))
    end
end)

-- ===== ФАРМ =====
addToggle(Pages["Фарм"], "Автофарм монет/сундуков", false, setFarm)
addToggle(Pages["Фарм"], "Фарм NPC / Крипов", false, setNPCFarm)
addBtn(Pages["Фарм"], "Смена сервера", function() TeleportService:Teleport(game.PlaceId, LP) end)
addBtn(Pages["Фарм"], "Реджойн", function() TeleportService:Teleport(game.PlaceId, LP) end)

-- ===== ИГРОКИ =====
local function refreshPlayers()
    for _,c in pairs(Pages["Игроки"]:GetChildren()) do
        if c:IsA("TextButton") then c:Destroy() end
    end
    addBtn(Pages["Игроки"], "↻ Обновить", refreshPlayers)
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

-- ===== МИР =====
addToggle(Pages["Мир"], "Убрать туман", false, setFog)
addToggle(Pages["Мир"], "Низкая гравитация", false, setGravity)
addBtn(Pages["Мир"], "Fullbright", function()
    Lighting.Brightness=2 Lighting.ClockTime=14 Lighting.FogEnd=9e9
    notify("Fullbright")
end)
addBtn(Pages["Мир"], "Ночь", function() Lighting.ClockTime=0 notify("Ночь") end)
addBtn(Pages["Мир"], "День", function() Lighting.ClockTime=14 notify("День") end)

-- ===== СИСТЕМА =====
addBtn(Pages["Система"], "PANIC KEY (RightCtrl)", panic)
addBtn(Pages["Система"], "Очистить Drawing", function() clearDraw() for p,_ in pairs(ESPCache) do removePlayerESP(p) end notify("Очищено") end)
addBtn(Pages["Система"], "Попытка админки (remote scan)", function()
    local found=0
    for _,v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") or v:IsA("RemoteFunction") then
            local n=v.Name:lower()
            if n:find("admin") or n:find("cmd") or n:find("rank") then
                found+=1
                safe(function() v:FireServer("admin") end)
            end
        end
    end
    notify(found>0 and ("Попробовал "..found.." remote") or "Remote не найдены")
end)

-- start
switch("Профиль")
setVisible(true)
notify("PacMan Menu заинжекчен | RightShift = меню | RightCtrl = PANIC", 4)
