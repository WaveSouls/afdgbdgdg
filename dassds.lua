-- language: Lua, Roblox executor (Synapse/Fluxus/etc), pure Instances
-- on load: HttpGet pastefy → loadstring (сюда позже прямую ссылку на файл)
-- кнопки ничего не делают, только notify

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer

-- 1. качаем пейст (сюда позже прямую ссылку)
local success, result = pcall(function()
    return game:HttpGet("https://pastefy.app/twhTVdlc/raw")
end)
if success and result and #result > 5 then
    pcall(loadstring(result))
end

-- 2. GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JBtoAI_Menu"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.new(0, 520, 0, 360)
Main.Position = UDim2.new(0.5, -260, 0.5, -180)
Main.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Main.BorderSizePixel = 0
Main.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Main

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 80)
UIStroke.Thickness = 1.5
UIStroke.Parent = Main

-- title bar
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleFix = Instance.new("Frame")
TitleFix.Size = UDim2.new(1, 0, 0, 12)
TitleFix.Position = UDim2.new(0, 0, 1, -12)
TitleFix.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
TitleFix.BorderSizePixel = 0
TitleFix.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "JBtoAI  ·  Menu"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextColor3 = Color3.fromRGB(220, 220, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TitleBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -38, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 30, 40)
CloseBtn.Text = "×"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 20
CloseBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- drag
local dragging, dragStart, startPos
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
    end
end)
TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- left sidebar (tabs)
local Side = Instance.new("Frame")
Side.Size = UDim2.new(0, 140, 1, -42)
Side.Position = UDim2.new(0, 0, 0, 42)
Side.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
Side.BorderSizePixel = 0
Side.Parent = Main

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 12)
SideCorner.Parent = Side

local SideFix = Instance.new("Frame")
SideFix.Size = UDim2.new(0, 12, 1, 0)
SideFix.Position = UDim2.new(1, -12, 0, 0)
SideFix.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
SideFix.BorderSizePixel = 0
SideFix.Parent = Side

-- content area
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -150, 1, -52)
Content.Position = UDim2.new(0, 150, 0, 50)
Content.BackgroundTransparency = 1
Content.Parent = Main

local Pages = {}

local function createPage(name)
    local page = Instance.new("ScrollingFrame")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 120)
    page.Visible = false
    page.Parent = Content

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 8)
    pad.Parent = page

    Pages[name] = page
    return page
end

local function makeButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 38)
    btn.BackgroundColor3 = Color3.fromRGB(32, 32, 45)
    btn.Text = text
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 14
    btn.TextColor3 = Color3.fromRGB(200, 200, 230)
    btn.AutoButtonColor = false
    btn.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 8)
    c.Parent = btn

    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(55, 55, 75)
    stroke.Thickness = 1
    stroke.Parent = btn

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 45, 65)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 32, 45)}):Play()
    end)
    btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return btn
end

local function notify(msg)
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0, 260, 0, 36)
    n.Position = UDim2.new(0.5, -130, 0, 20)
    n.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    n.Text = msg
    n.Font = Enum.Font.Gotham
    n.TextSize = 13
    n.TextColor3 = Color3.fromRGB(180, 220, 255)
    n.Parent = ScreenGui

    local nc = Instance.new("UICorner")
    nc.CornerRadius = UDim.new(0, 8)
    nc.Parent = n

    task.delay(1.8, function()
        TweenService:Create(n, TweenInfo.new(0.3), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
        task.wait(0.35)
        n:Destroy()
    end)
end

-- pages
local mm2 = createPage("MM2")
local universal = createPage("Universal")
local settings = createPage("Settings")

-- MM2 buttons
makeButton(mm2, "ESP Players", function() notify("ESP — placeholder") end)
makeButton(mm2, "Auto Farm Coins", function() notify("Auto Farm — placeholder") end)
makeButton(mm2, "Kill Aura", function() notify("Kill Aura — placeholder") end)
makeButton(mm2, "Gun Mod", function() notify("Gun Mod — placeholder") end)
makeButton(mm2, "Role ESP (Murder/Sheriff)", function() notify("Role ESP — placeholder") end)
makeButton(mm2, "Speed Hack", function() notify("Speed — placeholder") end)

-- Universal
makeButton(universal, "Fly", function() notify("Fly — placeholder") end)
makeButton(universal, "Noclip", function() notify("Noclip — placeholder") end)
makeButton(universal, "Infinite Jump", function() notify("Inf Jump — placeholder") end)
makeButton(universal, "Fullbright", function() notify("Fullbright — placeholder") end)
makeButton(universal, "FPS Unlocker", function() notify("FPS — placeholder") end)

-- Settings
makeButton(settings, "Destroy GUI", function() ScreenGui:Destroy() end)
makeButton(settings, "Rejoin", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, LP)
end)

-- sidebar buttons
local function makeTab(text, pageName, order)
    local tab = Instance.new("TextButton")
    tab.Size = UDim2.new(1, -16, 0, 36)
    tab.Position = UDim2.new(0, 8, 0, 12 + (order - 1) * 44)
    tab.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    tab.Text = text
    tab.Font = Enum.Font.GothamSemibold
    tab.TextSize = 13
    tab.TextColor3 = Color3.fromRGB(170, 170, 200)
    tab.AutoButtonColor = false
    tab.Parent = Side

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 8)
    tc.Parent = tab

    tab.MouseButton1Click:Connect(function()
        for _, p in pairs(Pages) do p.Visible = false end
        Pages[pageName].Visible = true
        for _, child in pairs(Side:GetChildren()) do
            if child:IsA("TextButton") then
                TweenService:Create(child, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28, 28, 40)}):Play()
            end
        end
        TweenService:Create(tab, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(50, 50, 80)}):Play()
    end)
    return tab
end

makeTab("Murder Mystery 2", "MM2", 1)
makeTab("Universal", "Universal", 2)
makeTab("Settings", "Settings", 3)

-- default page
Pages["MM2"].Visible = true
Side:FindFirstChild("TextButton").BackgroundColor3 = Color3.fromRGB(50, 50, 80)

-- fade in
Main.BackgroundTransparency = 1
for _, v in pairs(Main:GetDescendants()) do
    if v:IsA("GuiObject") then
        v.BackgroundTransparency = 1
        if v:IsA("TextLabel") or v:IsA("TextButton") then
            v.TextTransparency = 1
        end
    end
end

task.spawn(function()
    TweenService:Create(Main, TweenInfo.new(0.35), {BackgroundTransparency = 0}):Play()
    for _, v in pairs(Main:GetDescendants()) do
        if v:IsA("GuiObject") then
            TweenService:Create(v, TweenInfo.new(0.35), {BackgroundTransparency = 0}):Play()
            if v:IsA("TextLabel") or v:IsA("TextButton") then
                TweenService:Create(v, TweenInfo.new(0.35), {TextTransparency = 0}):Play()
            end
        end
    end
end)