local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = Workspace.CurrentCamera

-- Clean existing RYC HUB GUI if re-executed
pcall(function()
    if CoreGui:FindFirstChild("RYCHUB_VIOLENCE") then
        CoreGui.RYCHUB_VIOLENCE:Destroy()
    end
end)

-- ==================== PALETTE & THEME ====================
local C = {
    Bg = Color3.fromRGB(11, 13, 19),          -- Obsidian void background
    Top = Color3.fromRGB(13, 16, 24),         -- Top bar
    Sidebar = Color3.fromRGB(9, 11, 16),      -- Ultra-clean dark sidebar
    SidebarBtn = Color3.fromRGB(13, 16, 24),  -- Sidebar button subtle bg
    SidebarActive = Color3.fromRGB(16, 32, 54),-- Active tab glass tint
    Card = Color3.fromRGB(15, 18, 27),        -- Refined dark card
    CardHover = Color3.fromRGB(20, 26, 38),   -- Interactive card hover
    CardStroke = Color3.fromRGB(25, 33, 48),  -- Elegant subtle card stroke
    WindowStroke = Color3.fromRGB(28, 38, 56),-- Subtle sleek outer window border
    Blue = Color3.fromRGB(0, 162, 255),       -- RYC HUB Neon Cyan / Electric Blue Accent
    BlueGlow = Color3.fromRGB(30, 200, 255),  -- Bright electric aura
    Red = Color3.fromRGB(235, 60, 75),        -- Killer / Danger color
    RedGlow = Color3.fromRGB(255, 80, 95),
    Green = Color3.fromRGB(46, 204, 113),     -- Survivor / Ready / Success
    Yellow = Color3.fromRGB(241, 196, 15),    -- Objective / Generator
    Txt = Color3.fromRGB(244, 247, 255),      -- Silver-white
    Sub = Color3.fromRGB(130, 145, 170),      -- Slate subtext
    Border = Color3.fromRGB(22, 28, 42),      -- Clean subtle divider border
    Off = Color3.fromRGB(24, 30, 42),         -- Toggle track (OFF)
    OffKnob = Color3.fromRGB(140, 150, 170)   -- Knob (OFF)
}

-- ==================== UTILITY FUNCTIONS ====================
local function tw(o, p, t)
    TweenService:Create(o, TweenInfo.new(t or 0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), p):Play()
end

local function Notify(title, desc, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = desc,
            Duration = duration or 3.5
        })
    end)
end

-- ==================== SCRIPT STATE & FLAGS ====================
local IsRunning = true

local Flags = {
    -- Survivor
    AutoParry = false,
    ParryDistance = 15,
    AutoShoot = false,
    ShootDistance = 35,
    AutoHeal = false,
    AutoExitLever = false,

    -- Killer
    HitboxExpander = false,
    HitboxSize = 12,
    HitboxTransparency = 0.65,
    KillAura = false,
    KillAuraRange = 15,

    -- Generators
    AutoFixGen = false,
    AutoSkillcheck = true,

    -- Visuals / ESP
    KillerESP = false,
    SurvivorESP = false,
    GeneratorESP = false,
    ExitESP = false,
    Fullbright = false,

    -- Movement
    SpeedHack = false,
    WalkSpeedVal = 24,
    InfiniteStamina = false,
    Noclip = false,
    Fly = false,
    FlySpeed = 50
}

local ToggleUpdaters = {}

local function SetFlag(key, val)
    Flags[key] = val
    if ToggleUpdaters[key] then
        ToggleUpdaters[key](val)
    end
end

-- ==================== MAIN GUI SETUP ====================
local W, H = 530, 330

local Gui = Instance.new("ScreenGui")
Gui.Name = "RYCHUB_VIOLENCE"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 9999
Gui.Parent = CoreGui

local Main = Instance.new("Frame", Gui)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Size = UDim2.fromOffset(W, H)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = C.Bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = C.WindowStroke
MainStroke.Thickness = 1

-- Top Bar
local Top = Instance.new("Frame", Main)
Top.Size = UDim2.new(1, 0, 0, 38)
Top.BackgroundColor3 = C.Top
Top.BorderSizePixel = 0

local TopLine = Instance.new("Frame", Top)
TopLine.Size = UDim2.new(1, 0, 0, 1)
TopLine.Position = UDim2.new(0, 0, 1, -1)
TopLine.BackgroundColor3 = C.Border
TopLine.BorderSizePixel = 0

local Title = Instance.new("TextLabel", Top)
Title.Size = UDim2.fromOffset(80, 38)
Title.Position = UDim2.fromOffset(14, 0)
Title.BackgroundTransparency = 1
Title.Text = "RYC HUB"
Title.TextColor3 = C.Txt
Title.TextSize = 13.5
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left

local VerBadge = Instance.new("Frame", Top)
VerBadge.Size = UDim2.fromOffset(46, 18)
VerBadge.Position = UDim2.fromOffset(92, 10)
VerBadge.BackgroundColor3 = Color3.fromRGB(16, 26, 42)
VerBadge.BorderSizePixel = 0
Instance.new("UICorner", VerBadge).CornerRadius = UDim.new(0, 4)
local vbStroke = Instance.new("UIStroke", VerBadge)
vbStroke.Color = C.Blue
vbStroke.Transparency = 0.6
local vbText = Instance.new("TextLabel", VerBadge)
vbText.Size = UDim2.new(1, 0, 1, 0)
vbText.BackgroundTransparency = 1
vbText.Text = "VD v1.0"
vbText.TextColor3 = C.Blue
vbText.TextSize = 9
vbText.Font = Enum.Font.GothamBold

-- Window Controls (Minimize & Close)
local function Shutdown()
    IsRunning = false
    for k in pairs(Flags) do
        Flags[k] = false
    end
    pcall(function()
        Gui:Destroy()
    end)
    Notify("RYC HUB", "Script Closed Safely", 2)
end

local CloseBtn = Instance.new("TextButton", Top)
CloseBtn.Size = UDim2.fromOffset(24, 24)
CloseBtn.Position = UDim2.new(1, -30, 0.5, -12)
CloseBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = C.Sub
CloseBtn.TextSize = 11
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
local CloseStroke = Instance.new("UIStroke", CloseBtn)
CloseStroke.Color = C.Border
CloseStroke.Thickness = 1

CloseBtn.MouseEnter:Connect(function()
    tw(CloseBtn, { BackgroundColor3 = C.Red, TextColor3 = Color3.fromRGB(255, 255, 255) }, 0.15)
    tw(CloseStroke, { Color = C.RedGlow }, 0.15)
end)
CloseBtn.MouseLeave:Connect(function()
    tw(CloseBtn, { BackgroundColor3 = Color3.fromRGB(18, 22, 32), TextColor3 = C.Sub }, 0.15)
    tw(CloseStroke, { Color = C.Border }, 0.15)
end)
CloseBtn.MouseButton1Click:Connect(Shutdown)

local MinBtn = Instance.new("TextButton", Top)
MinBtn.Size = UDim2.fromOffset(24, 24)
MinBtn.Position = UDim2.new(1, -58, 0.5, -12)
MinBtn.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
MinBtn.Text = "-"
MinBtn.TextSize = 13
MinBtn.TextColor3 = C.Sub
MinBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)
local MinStroke = Instance.new("UIStroke", MinBtn)
MinStroke.Color = C.Border
MinStroke.Thickness = 1

MinBtn.MouseEnter:Connect(function()
    tw(MinBtn, { BackgroundColor3 = C.CardHover, TextColor3 = C.Txt }, 0.15)
    tw(MinStroke, { Color = C.Blue }, 0.15)
end)
MinBtn.MouseLeave:Connect(function()
    tw(MinBtn, { BackgroundColor3 = Color3.fromRGB(18, 22, 32), TextColor3 = C.Sub }, 0.15)
    tw(MinStroke, { Color = C.Border }, 0.15)
end)

-- Floating Mini Icon (when minimized)
local MiniIcon = Instance.new("Frame", Gui)
MiniIcon.Size = UDim2.fromOffset(52, 52)
MiniIcon.Position = UDim2.new(0, 20, 0.5, -26)
MiniIcon.BackgroundColor3 = Color3.fromRGB(13, 16, 22)
MiniIcon.BorderSizePixel = 0
MiniIcon.Visible = false
MiniIcon.Active = true
Instance.new("UICorner", MiniIcon).CornerRadius = UDim.new(0, 12)
local MiniStroke = Instance.new("UIStroke", MiniIcon)
MiniStroke.Color = Color3.fromRGB(0, 162, 255)
MiniStroke.Thickness = 2

local MiniLabel = Instance.new("TextLabel", MiniIcon)
MiniLabel.Size = UDim2.new(1, 0, 1, 0)
MiniLabel.BackgroundTransparency = 1
MiniLabel.Text = "RYC"
MiniLabel.TextColor3 = Color3.fromRGB(0, 162, 255)
MiniLabel.TextSize = 12
MiniLabel.Font = Enum.Font.GothamBold
MiniLabel.TextXAlignment = Enum.TextXAlignment.Center

local function SetMinimized(state)
    if state then
        tw(Main, { Size = UDim2.fromOffset(W, 0), BackgroundTransparency = 1 }, 0.2)
        task.delay(0.2, function()
            Main.Visible = false
            MiniIcon.Visible = true
            tw(MiniIcon, { BackgroundTransparency = 0 }, 0.15)
        end)
    else
        MiniIcon.Visible = false
        Main.Visible = true
        Main.BackgroundTransparency = 0
        tw(Main, { Size = UDim2.fromOffset(W, H) }, 0.2)
    end
end

MinBtn.MouseButton1Click:Connect(function()
    SetMinimized(true)
end)

MiniIcon.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local dragStart = input.Position
        local startPos = MiniIcon.Position
        local moved = false
        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.Change then
                local delta = input.Position - dragStart
                if delta.Magnitude > 4 then
                    moved = true
                    MiniIcon.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end
        end)
        local endConn
        endConn = UserInputService.InputEnded:Connect(function(endInput)
            if endInput == input then
                connection:Disconnect()
                endConn:Disconnect()
                if not moved then
                    SetMinimized(false)
                end
            end
        end)
    end
end)

-- Window Dragging
local isDragging, dragStart, startPos = false, nil, nil
Top.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDragging = true
        dragStart = input.Position
        startPos = Main.Position
        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.Change then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        local endConn
        endConn = UserInputService.InputEnded:Connect(function(endInput)
            if endInput == input then
                isDragging = false
                connection:Disconnect()
                endConn:Disconnect()
            end
        end)
    end
end)

-- Sidebar & Content Frame
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 114, 1, -38)
Sidebar.Position = UDim2.fromOffset(0, 38)
Sidebar.BackgroundColor3 = C.Sidebar
Sidebar.BorderSizePixel = 0

local SidebarBorder = Instance.new("Frame", Main)
SidebarBorder.Size = UDim2.new(0, 1, 1, -38)
SidebarBorder.Position = UDim2.fromOffset(114, 38)
SidebarBorder.BackgroundColor3 = C.Border
SidebarBorder.BorderSizePixel = 0
SidebarBorder.ZIndex = 3

local TabList = Instance.new("UIListLayout", Sidebar)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 3)

local TabPadding = Instance.new("UIPadding", Sidebar)
TabPadding.PaddingLeft = UDim.new(0, 6)
TabPadding.PaddingRight = UDim.new(0, 6)
TabPadding.PaddingTop = UDim.new(0, 8)
TabPadding.PaddingBottom = UDim.new(0, 8)

local Content = Instance.new("ScrollingFrame", Main)
Content.Size = UDim2.new(1, -122, 1, -44)
Content.Position = UDim2.fromOffset(118, 42)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
Content.ScrollBarThickness = 2
Content.ScrollBarImageColor3 = C.Blue
Content.CanvasSize = UDim2.new(0, 0, 0, 0)
Content.AutomaticCanvasSize = Enum.AutomaticSize.Y

local ContentPadding = Instance.new("UIPadding", Content)
ContentPadding.PaddingLeft = UDim.new(0, 8)
ContentPadding.PaddingRight = UDim.new(0, 8)
ContentPadding.PaddingTop = UDim.new(0, 4)
ContentPadding.PaddingBottom = UDim.new(0, 12)

local CL = Instance.new("UIListLayout", Content)
CL.SortOrder = Enum.SortOrder.LayoutOrder
CL.Padding = UDim.new(0, 5)

-- ==================== TAB NAVIGATION SYSTEM ====================
local Pages, TabBtns = {}, {}
local currentTab = "Info"

local function SetTab(name)
    currentTab = name
    for n, p in pairs(Pages) do
        p.Visible = (n == name)
    end
    for n, btnData in pairs(TabBtns) do
        local isSel = (n == name)
        tw(btnData.btn, {
            BackgroundTransparency = isSel and 0 or 1,
            BackgroundColor3 = isSel and C.SidebarActive or Color3.fromRGB(13, 16, 24)
        }, 0.15)
        tw(btnData.label, {
            TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or C.Sub
        }, 0.15)
        tw(btnData.icon, {
            ImageColor3 = isSel and Color3.fromRGB(0, 185, 255) or C.Sub
        }, 0.15)
        tw(btnData.stroke, {
            Transparency = isSel and 0.55 or 1,
            Color = isSel and C.Blue or C.Border
        }, 0.15)
        tw(btnData.indicator, {
            BackgroundTransparency = isSel and 0 or 1
        }, 0.15)
    end
end

local TabIcons = {
    Info = "rbxassetid://6031154871",
    Survivor = "rbxassetid://6031225818",
    Killer = "rbxassetid://10734975692",
    Generators = "rbxassetid://6031075931",
    Visuals = "rbxassetid://6031075931",
    Movement = "rbxassetid://10723354671"
}

local MakeTab = function(name, order)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(13, 16, 24)
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.LayoutOrder = order
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    local bStroke = Instance.new("UIStroke", btn)
    bStroke.Color = C.Blue
    bStroke.Transparency = 1
    bStroke.Thickness = 1

    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0, 3, 0, 16)
    indicator.Position = UDim2.new(0, 2, 0.5, -8)
    indicator.BackgroundColor3 = C.Blue
    indicator.BorderSizePixel = 0
    indicator.BackgroundTransparency = 1
    Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

    local icon = Instance.new("ImageLabel", btn)
    icon.Size = UDim2.fromOffset(14, 14)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.Position = UDim2.new(0, 10, 0.5, 0)
    icon.BackgroundTransparency = 1
    icon.Image = TabIcons[name] or "rbxassetid://6031154871"
    icon.ImageColor3 = C.Sub

    local label = Instance.new("TextLabel", btn)
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.fromOffset(28, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = C.Sub
    label.TextSize = 10.5
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left

    btn.MouseEnter:Connect(function()
        if currentTab ~= name then
            tw(btn, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(16, 21, 32) }, 0.12)
            tw(label, { TextColor3 = C.Txt }, 0.12)
            tw(icon, { ImageColor3 = C.Txt }, 0.12)
        end
    end)
    btn.MouseLeave:Connect(function()
        if currentTab ~= name then
            tw(btn, { BackgroundTransparency = 1 }, 0.12)
            tw(label, { TextColor3 = C.Sub }, 0.12)
            tw(icon, { ImageColor3 = C.Sub }, 0.12)
        end
    end)

    TabBtns[name] = {
        btn = btn,
        icon = icon,
        label = label,
        stroke = bStroke,
        indicator = indicator
    }

    local page = Instance.new("Frame", Content)
    page.Size = UDim2.new(1, 0, 0, 0)
    page.AutomaticSize = Enum.AutomaticSize.Y
    page.BackgroundTransparency = 1
    page.Visible = false
    local pl = Instance.new("UIListLayout", page)
    pl.Padding = UDim.new(0, 4)
    Pages[name] = page

    btn.MouseButton1Click:Connect(function()
        SetTab(name)
    end)
    return page
end

-- ==================== UI COMPONENT BUILDERS ====================
local function AddToggle(parent, label, key)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 32)
    f.BackgroundColor3 = C.Card
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7)
    local fStroke = Instance.new("UIStroke", f)
    fStroke.Color = C.CardStroke
    fStroke.Thickness = 1

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -60, 1, 0)
    l.Position = UDim2.fromOffset(12, 0)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = C.Txt
    l.TextSize = 11
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left

    local toggleTrack = Instance.new("Frame", f)
    toggleTrack.Size = UDim2.fromOffset(36, 18)
    toggleTrack.Position = UDim2.new(1, -46, 0.5, -9)
    toggleTrack.BackgroundColor3 = Flags[key] and C.Blue or C.Off
    Instance.new("UICorner", toggleTrack).CornerRadius = UDim.new(1, 0)
    local trackStroke = Instance.new("UIStroke", toggleTrack)
    trackStroke.Color = Flags[key] and C.Blue or C.Border
    trackStroke.Thickness = 1

    local knob = Instance.new("Frame", toggleTrack)
    knob.Size = UDim2.fromOffset(12, 12)
    knob.Position = Flags[key] and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
    knob.BackgroundColor3 = Flags[key] and Color3.fromRGB(255, 255, 255) or C.OffKnob
    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""

    local function Update(val)
        tw(toggleTrack, { BackgroundColor3 = val and C.Blue or C.Off }, 0.16)
        tw(trackStroke, { Color = val and C.Blue or C.Border }, 0.16)
        tw(knob, {
            Position = val and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6),
            BackgroundColor3 = val and Color3.fromRGB(255, 255, 255) or C.OffKnob
        }, 0.16)
    end

    ToggleUpdaters[key] = Update

    btn.MouseButton1Click:Connect(function()
        SetFlag(key, not Flags[key])
    end)

    btn.MouseEnter:Connect(function()
        tw(f, { BackgroundColor3 = C.CardHover }, 0.12)
        tw(fStroke, { Color = Color3.fromRGB(35, 45, 65) }, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        tw(f, { BackgroundColor3 = C.Card }, 0.12)
        tw(fStroke, { Color = C.CardStroke }, 0.12)
    end)
end

local function AddButton(parent, label, callback)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 32)
    f.BackgroundColor3 = C.Card
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7)
    local fStroke = Instance.new("UIStroke", f)
    fStroke.Color = C.CardStroke
    fStroke.Thickness = 1

    local b = Instance.new("TextButton", f)
    b.Size = UDim2.new(1, 0, 1, 0)
    b.BackgroundTransparency = 1
    b.Text = label
    b.TextColor3 = C.Txt
    b.TextSize = 11
    b.Font = Enum.Font.GothamBold
    b.AutoButtonColor = false

    b.MouseEnter:Connect(function()
        tw(f, { BackgroundColor3 = C.CardHover }, 0.12)
        tw(fStroke, { Color = C.Blue }, 0.12)
        tw(b, { TextColor3 = Color3.fromRGB(255, 255, 255) }, 0.12)
    end)
    b.MouseLeave:Connect(function()
        tw(f, { BackgroundColor3 = C.Card }, 0.12)
        tw(fStroke, { Color = C.CardStroke }, 0.12)
        tw(b, { TextColor3 = C.Txt }, 0.12)
    end)

    b.MouseButton1Click:Connect(function()
        tw(f, { BackgroundColor3 = Color3.fromRGB(18, 30, 48) }, 0.08)
        task.delay(0.08, function()
            tw(f, { BackgroundColor3 = C.CardHover }, 0.1)
        end)
        if callback then
            callback(b)
        end
    end)
    return b
end

local function AddSlider(parent, label, default, min, max, key, suffix)
    suffix = suffix or ""
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 40)
    f.BackgroundColor3 = C.Card
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7)
    local fStroke = Instance.new("UIStroke", f)
    fStroke.Color = C.CardStroke
    fStroke.Thickness = 1

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, -60, 0, 16)
    l.Position = UDim2.fromOffset(12, 4)
    l.BackgroundTransparency = 1
    l.Text = label
    l.TextColor3 = C.Txt
    l.TextSize = 10.5
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left

    local vl = Instance.new("TextLabel", f)
    vl.Size = UDim2.fromOffset(50, 16)
    vl.Position = UDim2.new(1, -62, 0, 4)
    vl.BackgroundTransparency = 1
    vl.Text = tostring(default) .. suffix
    vl.TextColor3 = C.Blue
    vl.TextSize = 10.5
    vl.Font = Enum.Font.GothamBold
    vl.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("Frame", f)
    track.Size = UDim2.new(1, -24, 0, 5)
    track.Position = UDim2.fromOffset(12, 26)
    track.BackgroundColor3 = C.Off
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame", track)
    local pct = math.clamp((default - min) / (max - min), 0, 1)
    fill.Size = UDim2.new(pct, 0, 1, 0)
    fill.BackgroundColor3 = C.Blue
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local isDraggingSlider = false
    local function UpdateFromX(x)
        local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local val = math.floor(min + (max - min) * rel)
        fill.Size = UDim2.new(rel, 0, 1, 0)
        vl.Text = tostring(val) .. suffix
        Flags[key] = val
    end

    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            isDraggingSlider = true
            UpdateFromX(i.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            isDraggingSlider = false
        end
    end)

    UserInputService.InputChanged:Connect(function(i)
        if isDraggingSlider and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            UpdateFromX(i.Position.X)
        end
    end)
end

local function AddSection(parent, title)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 22)
    f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = string.upper(title)
    l.TextColor3 = C.Sub
    l.TextSize = 9.5
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
end

-- ==================== BUILD TABS ====================
local InfoPage = MakeTab("Info", 1)
local SurvivorPage = MakeTab("Survivor", 2)
local KillerPage = MakeTab("Killer", 3)
local GensPage = MakeTab("Generators", 4)
local VisualsPage = MakeTab("Visuals", 5)
local MovementPage = MakeTab("Movement", 6)

-- ========== TAB 1: INFO ==========
local ProfileCard = Instance.new("Frame", InfoPage)
ProfileCard.Size = UDim2.new(1, 0, 0, 64)
ProfileCard.BackgroundColor3 = C.Card
ProfileCard.BorderSizePixel = 0
Instance.new("UICorner", ProfileCard).CornerRadius = UDim.new(0, 8)
local pStroke = Instance.new("UIStroke", ProfileCard)
pStroke.Color = C.CardStroke
pStroke.Thickness = 1

local AvatarImg = Instance.new("ImageLabel", ProfileCard)
AvatarImg.Size = UDim2.fromOffset(46, 46)
AvatarImg.Position = UDim2.fromOffset(9, 9)
AvatarImg.BackgroundColor3 = Color3.fromRGB(22, 28, 40)
AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
AvatarImg.BorderSizePixel = 0
Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)
local aStroke = Instance.new("UIStroke", AvatarImg)
aStroke.Color = C.Blue
aStroke.Thickness = 1.5

local DisplayNameLbl = Instance.new("TextLabel", ProfileCard)
DisplayNameLbl.Size = UDim2.new(1, -70, 0, 16)
DisplayNameLbl.Position = UDim2.fromOffset(64, 8)
DisplayNameLbl.BackgroundTransparency = 1
DisplayNameLbl.Text = player.DisplayName
DisplayNameLbl.TextColor3 = C.Txt
DisplayNameLbl.Font = Enum.Font.GothamBold
DisplayNameLbl.TextSize = 12
DisplayNameLbl.TextXAlignment = Enum.TextXAlignment.Left

local UsernameLbl = Instance.new("TextLabel", ProfileCard)
UsernameLbl.Size = UDim2.new(1, -70, 0, 14)
UsernameLbl.Position = UDim2.fromOffset(64, 24)
UsernameLbl.BackgroundTransparency = 1
UsernameLbl.Text = "@" .. player.Name .. "  •  ID: " .. tostring(player.UserId)
UsernameLbl.TextColor3 = C.Sub
UsernameLbl.Font = Enum.Font.GothamMedium
UsernameLbl.TextSize = 9
UsernameLbl.TextXAlignment = Enum.TextXAlignment.Left

local execName = (identifyexecutor and identifyexecutor()) or (getexecutorname and getexecutorname()) or "Executor"
local UserMetaLbl = Instance.new("TextLabel", ProfileCard)
UserMetaLbl.Size = UDim2.new(1, -70, 0, 14)
UserMetaLbl.Position = UDim2.fromOffset(64, 40)
UserMetaLbl.BackgroundTransparency = 1
UserMetaLbl.Text = "Account: " .. player.AccountAge .. " Days  |  " .. execName
UserMetaLbl.TextColor3 = C.Blue
UserMetaLbl.Font = Enum.Font.Gotham
UserMetaLbl.TextSize = 8.5
UserMetaLbl.TextXAlignment = Enum.TextXAlignment.Left

local StatsCard = Instance.new("Frame", InfoPage)
StatsCard.Size = UDim2.new(1, 0, 0, 34)
StatsCard.BackgroundColor3 = C.Card
StatsCard.BorderSizePixel = 0
Instance.new("UICorner", StatsCard).CornerRadius = UDim.new(0, 7)
local sStroke = Instance.new("UIStroke", StatsCard)
sStroke.Color = C.CardStroke
sStroke.Thickness = 1

local LiveStatsLbl = Instance.new("TextLabel", StatsCard)
LiveStatsLbl.Size = UDim2.new(1, -20, 1, 0)
LiveStatsLbl.Position = UDim2.fromOffset(10, 0)
LiveStatsLbl.BackgroundTransparency = 1
LiveStatsLbl.Text = "FPS: Scanning...  |  Ping: ...ms  |  Job: Local"
LiveStatsLbl.TextColor3 = Color3.fromRGB(130, 240, 160)
LiveStatsLbl.Font = Enum.Font.GothamMedium
LiveStatsLbl.TextSize = 9.5
LiveStatsLbl.TextXAlignment = Enum.TextXAlignment.Left

-- Live FPS & Ping loop
task.spawn(function()
    local lastTime = os.clock()
    local frameCount = 0
    local fps = 60
    local renderConn
    renderConn = RunService.RenderStepped:Connect(function()
        if not IsRunning or not LiveStatsLbl or not LiveStatsLbl.Parent then
            if renderConn then renderConn:Disconnect() end
            return
        end
        frameCount = frameCount + 1
        local curTime = os.clock()
        if curTime - lastTime >= 1 then
            fps = frameCount
            frameCount = 0
            lastTime = curTime
            local ping = "0"
            pcall(function()
                local statsItem = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
                if statsItem then ping = string.split(statsItem:GetValueString(), " ")[1] end
            end)
            local jobStr = (game.JobId and #game.JobId > 0) and string.sub(game.JobId, 1, 8) or "Local"
            LiveStatsLbl.Text = string.format("FPS: %d  |  Ping: %s ms  |  Job: %s", fps, ping, jobStr)
        end
    end)
end)

local function AddInfoRow(k, v)
    local f = Instance.new("Frame", InfoPage)
    f.Size = UDim2.new(1, 0, 0, 32)
    f.BackgroundColor3 = C.Card
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7)
    local fStroke = Instance.new("UIStroke", f)
    fStroke.Color = C.CardStroke
    fStroke.Thickness = 1

    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(0.5, 0, 1, 0)
    l.Position = UDim2.fromOffset(12, 0)
    l.BackgroundTransparency = 1
    l.Text = k
    l.TextColor3 = C.Sub
    l.TextSize = 11
    l.Font = Enum.Font.GothamMedium
    l.TextXAlignment = Enum.TextXAlignment.Left

    local r = Instance.new("TextLabel", f)
    r.Size = UDim2.new(0.5, -12, 1, 0)
    r.Position = UDim2.new(0.5, 0, 0, 0)
    r.BackgroundTransparency = 1
    r.Text = v
    r.TextColor3 = C.Txt
    r.TextSize = 11
    r.Font = Enum.Font.GothamBold
    r.TextXAlignment = Enum.TextXAlignment.Right
end

AddInfoRow("Game", "Violence District")
AddInfoRow("Hub Version", "RYC HUB v1.0")
AddInfoRow("Access Status", "Lifetime / Free")

AddButton(InfoPage, "Rejoin Server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, player)
end)

-- ========== HELPERS FOR VIOLENCE DISTRICT ==========
local function GetKiller()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            -- Heuristics for killer in Violence District
            local isKiller = p.Character:FindFirstChild("Killer") or p:FindFirstChild("IsKiller") or (p.Team and p.Team.Name:lower():find("killer"))
            if isKiller then
                return p.Character
            end
            -- Check for weapons like Knife, Bat, Machete, Chainsaw
            for _, item in ipairs(p.Character:GetChildren()) do
                if item:IsA("Tool") and (item.Name:lower():find("knife") or item.Name:lower():find("axe") or item.Name:lower():find("weapon") or item.Name:lower():find("machete") or item.Name:lower():find("bat")) then
                    return p.Character
                end
            end
        end
    end
    return nil
end

-- ========== TAB 2: SURVIVOR ==========
AddSection(SurvivorPage, "Combat & Defense")
AddToggle(SurvivorPage, "Auto Parry (Incoming Killer)", "AutoParry")
AddSlider(SurvivorPage, "Parry Distance", 15, 5, 30, "ParryDistance", "m")
AddToggle(SurvivorPage, "Auto Shoot / Stun Killer", "AutoShoot")
AddSlider(SurvivorPage, "Shoot Distance", 35, 10, 60, "ShootDistance", "m")
AddToggle(SurvivorPage, "Auto Heal", "AutoHeal")

AddSection(SurvivorPage, "Escape & Objectives")
AddToggle(SurvivorPage, "Auto Pull Exit Gate Lever", "AutoExitLever")

AddButton(SurvivorPage, "Teleport to Exit Gate", function()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    
    local foundGate = nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if (n:find("exit") or n:find("gate") or n:find("escape")) and (obj:IsA("BasePart") or obj:IsA("Model")) then
            local pos = obj:IsA("BasePart") and obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
            if pos then
                foundGate = pos
                break
            end
        end
    end
    
    if foundGate then
        char.HumanoidRootPart.CFrame = CFrame.new(foundGate + Vector3.new(0, 3, 0))
        Notify("RYC HUB", "Teleported to Exit Gate!", 2.5)
    else
        Notify("RYC HUB", "Exit Gate not found or not powered yet!", 2.5)
    end
end)

AddButton(SurvivorPage, "Teleport to Killer", function()
    local char = player.Character
    local killer = GetKiller()
    if char and char:FindFirstChild("HumanoidRootPart") and killer and killer:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = killer.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
        Notify("RYC HUB", "Teleported to Killer!", 2)
    else
        Notify("RYC HUB", "Killer character not detected!", 2)
    end
end)

AddButton(SurvivorPage, "Fling Killer (Push Away)", function()
    local char = player.Character
    local killer = GetKiller()
    if not char or not killer or not killer:FindFirstChild("HumanoidRootPart") then
        Notify("RYC HUB", "Killer not found!", 2)
        return
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then
        local oldPos = hrp.CFrame
        local killerHrp = killer.HumanoidRootPart
        
        -- High angular velocity fling
        local bv = Instance.new("BodyAngularVelocity")
        bv.AngularVelocity = Vector3.new(100000, 100000, 100000)
        bv.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bv.P = 1e9
        bv.Parent = hrp
        
        for i = 1, 20 do
            if not killerHrp or not killerHrp.Parent then break end
            hrp.CFrame = killerHrp.CFrame
            task.wait(0.02)
        end
        
        bv:Destroy()
        hrp.CFrame = oldPos
        Notify("RYC HUB", "Fling executed!", 2)
    end
end)

-- ========== TAB 3: KILLER ==========
AddSection(KillerPage, "Hitbox & Attack")
AddToggle(KillerPage, "Hitbox Expander (Survivors)", "HitboxExpander")
AddSlider(KillerPage, "Hitbox Size", 12, 4, 30, "HitboxSize", " stud")
AddToggle(KillerPage, "Kill Aura (Auto Attack)", "KillAura")
AddSlider(KillerPage, "Kill Aura Range", 15, 5, 25, "KillAuraRange", "m")

AddSection(KillerPage, "Hunter Actions")
AddButton(KillerPage, "Teleport to Nearest Survivor", function()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local myPos = char.HumanoidRootPart.Position

    local nearest, nearestDist = nil, math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
            if dist < nearestDist then
                nearest = p.Character.HumanoidRootPart
                nearestDist = dist
            end
        end
    end

    if nearest then
        char.HumanoidRootPart.CFrame = nearest.CFrame * CFrame.new(0, 0, 3)
        Notify("RYC HUB", "Teleported to Nearest Survivor!", 2)
    else
        Notify("RYC HUB", "No survivors found!", 2)
    end
end)

-- ========== TAB 4: GENERATORS ==========
AddSection(GensPage, "Generator Objectives")
AddToggle(GensPage, "Auto Repair Generator (Proximity)", "AutoFixGen")
AddToggle(GensPage, "Auto Perfect Skill Check", "AutoSkillcheck")

AddButton(GensPage, "Teleport to Nearest Generator", function()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local myPos = char.HumanoidRootPart.Position

    local nearestGen, nearestDist = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if (n:find("generator") or n:find("motor") or n:find("engine")) and (obj:IsA("Model") or obj:IsA("BasePart")) then
            local pos = obj:IsA("BasePart") and obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
            if pos then
                local dist = (pos - myPos).Magnitude
                if dist > 3 and dist < nearestDist then
                    nearestGen = pos
                    nearestDist = dist
                end
            end
        end
    end

    if nearestGen then
        char.HumanoidRootPart.CFrame = CFrame.new(nearestGen + Vector3.new(0, 3, 2))
        Notify("RYC HUB", "Teleported to Nearest Generator!", 2)
    else
        Notify("RYC HUB", "No generator found in map!", 2)
    end
end)

-- ========== TAB 5: VISUALS / ESP ==========
AddSection(VisualsPage, "ESP Highlights")
AddToggle(VisualsPage, "Killer ESP (Red Glow + Distance)", "KillerESP")
AddToggle(VisualsPage, "Survivor ESP (Cyan Glow + HP)", "SurvivorESP")
AddToggle(VisualsPage, "Generators ESP (Location & Progress)", "GeneratorESP")
AddToggle(VisualsPage, "Exit Gates ESP", "ExitESP")

AddSection(VisualsPage, "World Atmosphere")
AddToggle(VisualsPage, "Fullbright & Remove Fog", "Fullbright")

-- ========== TAB 6: MOVEMENT ==========
AddSection(MovementPage, "Character Speed & Stats")
AddToggle(MovementPage, "Enable SpeedHack", "SpeedHack")
AddSlider(MovementPage, "WalkSpeed", 24, 16, 120, "WalkSpeedVal", " spd")
AddToggle(MovementPage, "Infinite Stamina", "InfiniteStamina")
AddToggle(MovementPage, "Noclip (Walk Through Walls)", "Noclip")
AddToggle(MovementPage, "Fly Mode", "Fly")
AddSlider(MovementPage, "Fly Speed", 50, 20, 150, "FlySpeed")

-- ==================== CORE FUNCTIONALITY LOOPS ====================

-- 1. Noclip Loop
RunService.Stepped:Connect(function()
    if not IsRunning or not Flags.Noclip then return end
    pcall(function()
        local char = player.Character
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end)
end)

-- 2. Speedhack & Stamina Loop
task.spawn(function()
    while IsRunning do
        pcall(function()
            local char = player.Character
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then
                    if Flags.SpeedHack then
                        hum.WalkSpeed = Flags.WalkSpeedVal
                    end
                end

                -- Infinite Stamina check
                if Flags.InfiniteStamina then
                    for _, v in ipairs(char:GetDescendants()) do
                        if (v.Name:lower():find("stamina") or v.Name:lower():find("sprint")) and v:IsA("NumberValue") then
                            v.Value = 100
                        end
                    end
                    for _, v in ipairs(player:GetDescendants()) do
                        if (v.Name:lower():find("stamina") or v.Name:lower():find("sprint")) and v:IsA("NumberValue") then
                            v.Value = 100
                        end
                    end
                end
            end
        end)
        task.wait(0.2)
    end
end)

-- 3. Hitbox Expander Loop
task.spawn(function()
    while IsRunning do
        pcall(function()
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        if Flags.HitboxExpander then
                            hrp.Size = Vector3.new(Flags.HitboxSize, Flags.HitboxSize, Flags.HitboxSize)
                            hrp.Transparency = Flags.HitboxTransparency
                            hrp.CanCollide = false
                            hrp.Material = Enum.Material.ForceField
                        else
                            if hrp.Size ~= Vector3.new(2, 2, 1) then
                                hrp.Size = Vector3.new(2, 2, 1)
                                hrp.Transparency = 1
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.35)
    end
end)

-- 4. Fullbright & No Fog
task.spawn(function()
    while IsRunning do
        pcall(function()
            if Flags.Fullbright then
                Lighting.Brightness = 2
                Lighting.ClockTime = 14
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
                Lighting.Ambient = Color3.fromRGB(180, 180, 180)
            end
        end)
        task.wait(0.5)
    end
end)

-- 5. Auto Repair Generator & Exit Gate Lever (ProximityPrompt Trigger)
task.spawn(function()
    while IsRunning do
        pcall(function()
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local myPos = char.HumanoidRootPart.Position

            if Flags.AutoFixGen or Flags.AutoExitLever then
                for _, prompt in ipairs(Workspace:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                        local parent = prompt.Parent
                        if parent and parent:IsA("BasePart") then
                            local dist = (parent.Position - myPos).Magnitude
                            local pName = prompt.ActionText:lower() .. " " .. prompt.ObjectText:lower() .. " " .. parent.Name:lower()
                            
                            -- Generator repair
                            if Flags.AutoFixGen and (pName:find("repair") or pName:find("gen") or pName:find("fix") or pName:find("motor")) and dist <= prompt.MaxActivationDistance + 4 then
                                fireproximityprompt(prompt)
                            end

                            -- Exit Gate lever
                            if Flags.AutoExitLever and (pName:find("lever") or pName:find("gate") or pName:find("open") or pName:find("door") or pName:find("exit")) and dist <= prompt.MaxActivationDistance + 4 then
                                fireproximityprompt(prompt)
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.2)
    end
end)

-- 6. Auto Parry & Auto Shoot & Auto Heal
task.spawn(function()
    while IsRunning do
        pcall(function()
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local myPos = char.HumanoidRootPart.Position
            local killer = GetKiller()

            -- Auto Parry & Shoot
            if killer and killer:FindFirstChild("HumanoidRootPart") then
                local kDist = (killer.HumanoidRootPart.Position - myPos).Magnitude
                
                -- Auto Parry
                if Flags.AutoParry and kDist <= Flags.ParryDistance then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") and (tool.Name:lower():find("parry") or tool.Name:lower():find("block") or tool.Name:lower():find("shield")) then
                            tool:Activate()
                        end
                    end
                    -- Trigger keypress F (standard parry key in Violence District)
                    pcall(function()
                        if keypress then
                            keypress(0x46)
                            task.wait(0.05)
                            keyrelease(0x46)
                        end
                    end)
                end

                -- Auto Shoot
                if Flags.AutoShoot and kDist <= Flags.ShootDistance then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") and (tool.Name:lower():find("gun") or tool.Name:lower():find("shoot") or tool.Name:lower():find("taser") or tool.Name:lower():find("flare")) then
                            tool:Activate()
                        end
                    end
                end
            end

            -- Auto Heal
            if Flags.AutoHeal then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health < hum.MaxHealth * 0.75 then
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") and (tool.Name:lower():find("med") or tool.Name:lower():find("heal") or tool.Name:lower():find("bandage")) then
                            tool:Activate()
                        end
                    end
                end
            end
        end)
        task.wait(0.15)
    end
end)

-- 7. Kill Aura (For Killer)
task.spawn(function()
    while IsRunning do
        pcall(function()
            if not Flags.KillAura then return end
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local myPos = char.HumanoidRootPart.Position

            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local targetPos = p.Character.HumanoidRootPart.Position
                    if (targetPos - myPos).Magnitude <= Flags.KillAuraRange then
                        -- Activate equipped weapon
                        for _, tool in ipairs(char:GetChildren()) do
                            if tool:IsA("Tool") then
                                tool:Activate()
                            end
                        end
                    end
                end
            end
        end)
        task.wait(0.15)
    end
end)

-- 8. Visuals / ESP Engine
local ActiveESPs = {}

local function CreateHighlight(model, color)
    local hl = Instance.new("Highlight")
    hl.Adornee = model
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.45
    hl.OutlineTransparency = 0.1
    hl.Parent = CoreGui
    return hl
end

local function CreateTag(part, text, color)
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.fromOffset(130, 26)
    bb.Adornee = part
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    bb.Parent = CoreGui

    local lbl = Instance.new("TextLabel", bb)
    lbl.Size = UDim2.new(1, 0, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = color
    lbl.TextSize = 11
    lbl.Font = Enum.Font.GothamBold
    local stroke = Instance.new("UIStroke", lbl)
    stroke.Color = Color3.fromRGB(10, 10, 15)
    stroke.Thickness = 1.2
    return bb, lbl
end

task.spawn(function()
    while IsRunning do
        pcall(function()
            local char = player.Character
            local myPos = char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position or Vector3.new(0, 0, 0)

            -- Player / Killer / Survivor ESP
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local pChar = p.Character
                    local hrp = pChar.HumanoidRootPart
                    local dist = math.floor((hrp.Position - myPos).Magnitude)

                    local isKiller = (pChar == GetKiller())
                    local wanted = (isKiller and Flags.KillerESP) or (not isKiller and Flags.SurvivorESP)

                    if wanted then
                        local tagColor = isKiller and C.Red or C.Green
                        local titleText = isKiller and string.format("KILLER [%dm]", dist) or string.format("%s [%dm]", p.DisplayName, dist)

                        if not ActiveESPs[p] then
                            ActiveESPs[p] = {}
                            ActiveESPs[p].HL = CreateHighlight(pChar, tagColor)
                            ActiveESPs[p].BB, ActiveESPs[p].Lbl = CreateTag(hrp, titleText, tagColor)
                        else
                            ActiveESPs[p].Lbl.Text = titleText
                        end
                    else
                        if ActiveESPs[p] then
                            if ActiveESPs[p].HL then ActiveESPs[p].HL:Destroy() end
                            if ActiveESPs[p].BB then ActiveESPs[p].BB:Destroy() end
                            ActiveESPs[p] = nil
                        end
                    end
                else
                    if ActiveESPs[p] then
                        if ActiveESPs[p].HL then ActiveESPs[p].HL:Destroy() end
                        if ActiveESPs[p].BB then ActiveESPs[p].BB:Destroy() end
                        ActiveESPs[p] = nil
                    end
                end
            end
        end)
        task.wait(0.3)
    end

    -- Clean on exit
    for _, esp in pairs(ActiveESPs) do
        if esp.HL then esp.HL:Destroy() end
        if esp.BB then esp.BB:Destroy() end
    end
end)

-- Initial Tab
SetTab("Info")
Notify("RYC HUB", "Script Loaded!", 4)
