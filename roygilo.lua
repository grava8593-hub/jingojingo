print("==================================================")
print("[RYC HUB] MEMULAI INISIALISASI VIOLENCE DISTRICT...")
print("==================================================")
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
while not player do
    task.wait(0.1)
    player = Players.LocalPlayer
end
pcall(function()
    if gethui then
        local old = gethui():FindFirstChild("RYCHUB_VIOLENCE")
        if old then old:Destroy() end
    end
    if CoreGui:FindFirstChild("RYCHUB_VIOLENCE") then
        CoreGui.RYCHUB_VIOLENCE:Destroy()
    end
    if player and player:FindFirstChild("PlayerGui") then
        local old = player.PlayerGui:FindFirstChild("RYCHUB_VIOLENCE")
        if old then old:Destroy() end
    end
end)
local C = {
    Bg = Color3.fromRGB(19, 10, 32),
    Top = Color3.fromRGB(15, 8, 26),
    Sidebar = Color3.fromRGB(14, 7, 24),
    SidebarBtn = Color3.fromRGB(24, 13, 40),
    SidebarActive = Color3.fromRGB(35, 18, 60),
    Card = Color3.fromRGB(27, 14, 45),
    CardHover = Color3.fromRGB(36, 19, 60),
    CardStroke = Color3.fromRGB(48, 26, 78),
    WindowStroke = Color3.fromRGB(56, 30, 92),
    Purple = Color3.fromRGB(168, 85, 247),
    PurpleGlow = Color3.fromRGB(192, 132, 252),
    ActivePill = Color3.fromRGB(125, 175, 255),
    Red = Color3.fromRGB(235, 60, 75),
    Green = Color3.fromRGB(52, 211, 153),
    Txt = Color3.fromRGB(250, 245, 255),
    Sub = Color3.fromRGB(180, 160, 205),
    Border = Color3.fromRGB(38, 20, 62),
    Off = Color3.fromRGB(35, 20, 52),
    OffKnob = Color3.fromRGB(140, 125, 165)
}
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
local function GetRemote(pathStr)
    local cur = ReplicatedStorage
    for part in string.gmatch(pathStr, "[^%.]+") do
        if not cur then return nil end
        cur = cur:FindFirstChild(part)
    end
    return cur
end
local RemotePaths = {
    Parry = "Remotes.Items.Parrying Dagger.parry",
    Shoot = "Remotes.Items.Twist of Fate.Fire",
    BandageHeal = "Remotes.Items.Bandage.Fire",
    Adrenaline = "Remotes.Items.Adrenaline Shot.Healthy",
    HealEvent = "Remotes.Healing.HealEvent",
    GenRepair = "Remotes.Generator.RepairEvent",
    GenSkillEvent = "Remotes.Generator.SkillCheckEvent",
    GenSkillResult = "Remotes.Generator.SkillCheckResultEvent",
    HealSkillEvent = "Remotes.Healing.SkillCheckEvent",
    HealSkillResult = "Remotes.Healing.SkillCheckResultEvent",
    ExitLever = "Remotes.Exit.LeverEvent",
    ExitGate = "Remotes.Items.Gate.gate",
    BasicAttack = "Remotes.Attacks.BasicAttack",
    Hit = "Remotes.Attacks.hit",
    FlingReport = "Remotes.Killers.FlingReport",
    PalletStun = "Remotes.Pallet.Jason.Stun",
    TeleportChar = "Remotes.Mechanics.Teleportcharacter",
    GlobalTeleport = "Remotes.Teleport"
}
local Remotes = setmetatable({}, {
    __index = function(t, k)
        local path = RemotePaths[k]
        if not path then return nil end
        return GetRemote(path)
    end
})
local IsRunning = true
local Flags = {
    AutoShoot = false,
    AutoParry = false,
    AutoHeal = false,
    AutoLever = false,
    KillAura = false,
    HitboxExpander = false,
    HitboxSize = 14,
    AutoFixGen = false,
    AutoSkillcheck = true,
    KillerESP = false,
    SurvivorESP = false,
    GeneratorESP = false,
    ExitESP = false,
    Fullbright = false,
    SpeedHack = false,
    WalkSpeedVal = 24,
    InfiniteStamina = false,
    Noclip = false,
    Fly = false
}
local ToggleUpdaters = {}
local function SetFlag(key, val)
    Flags[key] = val
    if ToggleUpdaters[key] then
        ToggleUpdaters[key](val)
    end
end
local function GetKiller()
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= player and p.Character then
            local pChar = p.Character
            if pChar:GetAttribute("IsKiller") or p:GetAttribute("IsKiller") or (p:GetAttribute("SelectedKiller") and p:GetAttribute("SelectedKiller") ~= "") then
                return pChar
            end
            if p.Team and p.Team.Name:lower():find("killer") then
                return pChar
            end
            for _, item in ipairs(pChar:GetChildren()) do
                if item:IsA("Tool") and (item.Name:lower():find("knife") or item.Name:lower():find("axe") or item.Name:lower():find("machete") or item.Name:lower():find("chainsaw") or item.Name:lower():find("claw")) then
                    return pChar
                end
            end
        end
    end
    return nil
end
local function GetSafeGuiParent()
    local pGui = player:WaitForChild("PlayerGui", 5) or player:FindFirstChildOfClass("PlayerGui")
    if pGui then
        return pGui
    end
    if gethui then
        local h = nil
        pcall(function() h = gethui() end)
        if h then return h end
    end
    return CoreGui
end
local safeParent = GetSafeGuiParent()
local LOGO_URL = "https://raw.githubusercontent.com/grava8593-hub/icon/main/rychub.png"
local LOGO_FILE = "rychub.png"
local LogoAssetId = nil
pcall(function()
    if getcustomasset and writefile and isfile then
        if not isfile(LOGO_FILE) then
            local ok, data = pcall(function() return game:HttpGet(LOGO_URL) end)
            if ok and data and #data > 500 then
                writefile(LOGO_FILE, data)
            end
        end
        if isfile(LOGO_FILE) then
            LogoAssetId = getcustomasset(LOGO_FILE)
        end
    end
end)
local W, H = 510, 325
local Cam = Workspace.CurrentCamera
if Cam and Cam.ViewportSize.Y < 420 then
    H = math.clamp(Cam.ViewportSize.Y - 35, 250, 325)
    W = math.clamp(Cam.ViewportSize.X - 35, 340, 510)
end
local Gui = Instance.new("ScreenGui")
Gui.Name = "RYCHUB_VIOLENCE"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.DisplayOrder = 999999
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.Enabled = true
local parentOk = false
pcall(function()
    Gui.Parent = safeParent
    parentOk = true
end)
if not parentOk or not Gui.Parent then
    pcall(function()
        Gui.Parent = player:WaitForChild("PlayerGui")
    end)
end
local Main = Instance.new("Frame", Gui)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Size = UDim2.fromOffset(W, H)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = C.Bg
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = C.WindowStroke
MainStroke.Thickness = 1.2
local Top = Instance.new("Frame", Main)
Top.Size = UDim2.new(1, 0, 0, 36)
Top.BackgroundColor3 = C.Top
Top.BorderSizePixel = 0
local TopLine = Instance.new("Frame", Top)
TopLine.Size = UDim2.new(1, 0, 0, 1)
TopLine.Position = UDim2.new(0, 0, 1, -1)
TopLine.BackgroundColor3 = C.Border
TopLine.BorderSizePixel = 0
local HeaderIcon = Instance.new("ImageLabel", Top)
HeaderIcon.Size = UDim2.fromOffset(20, 20)
HeaderIcon.Position = UDim2.new(0, 10, 0.5, -10)
HeaderIcon.BackgroundTransparency = 1
HeaderIcon.BorderSizePixel = 0
if LogoAssetId then
    HeaderIcon.Image = LogoAssetId
else
    HeaderIcon.Image = "rbxassetid://10734934585"
end
Instance.new("UICorner", HeaderIcon).CornerRadius = UDim.new(1, 0)
local Title = Instance.new("TextLabel", Top)
Title.Size = UDim2.new(1, -95, 1, 0)
Title.Position = UDim2.fromOffset(36, 0)
Title.BackgroundTransparency = 1
Title.Text = "RYC HUB | Violence District"
Title.TextColor3 = C.Txt
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold
Title.TextXAlignment = Enum.TextXAlignment.Left
local function Shutdown()
    IsRunning = false
    for k in pairs(Flags) do
        Flags[k] = false
    end
    pcall(function()
        Gui:Destroy()
    end)
    Notify("RYC HUB", "Script Closed!", 2)
end
local CloseBtn = Instance.new("TextButton", Top)
CloseBtn.Size = UDim2.fromOffset(22, 22)
CloseBtn.Position = UDim2.new(1, -28, 0.5, -11)
CloseBtn.BackgroundColor3 = Color3.fromRGB(28, 14, 40)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = C.Sub
CloseBtn.TextSize = 10.5
CloseBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)
local CloseStroke = Instance.new("UIStroke", CloseBtn)
CloseStroke.Color = C.Border
CloseBtn.MouseEnter:Connect(function()
    tw(CloseBtn, { BackgroundColor3 = C.Red, TextColor3 = Color3.fromRGB(255, 255, 255) }, 0.15)
end)
CloseBtn.MouseLeave:Connect(function()
    tw(CloseBtn, { BackgroundColor3 = Color3.fromRGB(28, 14, 40), TextColor3 = C.Sub }, 0.15)
end)
CloseBtn.MouseButton1Click:Connect(Shutdown)
local MinBtn = Instance.new("TextButton", Top)
MinBtn.Size = UDim2.fromOffset(22, 22)
MinBtn.Position = UDim2.new(1, -54, 0.5, -11)
MinBtn.BackgroundColor3 = Color3.fromRGB(28, 14, 40)
MinBtn.Text = "-"
MinBtn.TextSize = 13
MinBtn.TextColor3 = C.Sub
MinBtn.Font = Enum.Font.GothamBold
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 5)
local MinStroke = Instance.new("UIStroke", MinBtn)
MinStroke.Color = C.Border
local function SetMinimized(state)
    if state then
        tw(Main, { Size = UDim2.fromOffset(W, 0), BackgroundTransparency = 1 }, 0.16)
        task.delay(0.16, function()
            Main.Visible = false
        end)
    else
        Main.Visible = true
        Main.BackgroundTransparency = 0
        tw(Main, { Size = UDim2.fromOffset(W, H) }, 0.16)
    end
end
MinBtn.MouseButton1Click:Connect(function()
    SetMinimized(true)
end)
local FloatToggle = Instance.new("TextButton", Gui)
FloatToggle.Name = "RYC_FloatingLogo"
FloatToggle.Size = UDim2.fromOffset(46, 46)
FloatToggle.Position = UDim2.new(0, 16, 0.35, 0)
FloatToggle.BackgroundColor3 = Color3.fromRGB(20, 10, 34)
FloatToggle.BorderSizePixel = 0
FloatToggle.Text = ""
FloatToggle.AutoButtonColor = false
FloatToggle.ZIndex = 99999
Instance.new("UICorner", FloatToggle).CornerRadius = UDim.new(1, 0)
local FStroke = Instance.new("UIStroke", FloatToggle)
FStroke.Color = C.Purple
FStroke.Thickness = 2
local FloatImg = Instance.new("ImageLabel", FloatToggle)
FloatImg.Size = UDim2.new(1, -4, 1, -4)
FloatImg.Position = UDim2.new(0, 2, 0, 2)
FloatImg.BackgroundTransparency = 1
FloatImg.BorderSizePixel = 0
Instance.new("UICorner", FloatImg).CornerRadius = UDim.new(1, 0)
local FloatText = Instance.new("TextLabel", FloatToggle)
FloatText.Size = UDim2.new(1, 0, 1, 0)
FloatText.BackgroundTransparency = 1
FloatText.TextColor3 = C.PurpleGlow
FloatText.TextSize = 13
FloatText.Font = Enum.Font.GothamBold
if LogoAssetId then
    FloatImg.Image = LogoAssetId
    FloatText.Text = ""
else
    FloatImg.Visible = false
    FloatText.Text = "RYC"
end
local floatMoved = false
FloatToggle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        floatMoved = false
        local dragStart = input.Position
        local startPos = FloatToggle.Position
        local connection, endConn
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.Change then
                local delta = input.Position - dragStart
                if delta.Magnitude > 5 then
                    floatMoved = true
                    FloatToggle.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end
        end)
        endConn = UserInputService.InputEnded:Connect(function(endInput)
            if endInput == input then
                if connection then connection:Disconnect() end
                if endConn then endConn:Disconnect() end
                if not floatMoved then
                    if Main.Visible then
                        SetMinimized(true)
                    else
                        SetMinimized(false)
                    end
                end
            end
        end)
    end
end)
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
local Sidebar = Instance.new("Frame", Main)
Sidebar.Size = UDim2.new(0, 126, 1, -36)
Sidebar.Position = UDim2.fromOffset(0, 36)
Sidebar.BackgroundColor3 = C.Sidebar
Sidebar.BorderSizePixel = 0
local SidebarBorder = Instance.new("Frame", Main)
SidebarBorder.Size = UDim2.new(0, 1, 1, -36)
SidebarBorder.Position = UDim2.fromOffset(126, 36)
SidebarBorder.BackgroundColor3 = C.Border
SidebarBorder.BorderSizePixel = 0
SidebarBorder.ZIndex = 3
local TabList = Instance.new("UIListLayout", Sidebar)
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 4)
local TabPadding = Instance.new("UIPadding", Sidebar)
TabPadding.PaddingLeft = UDim.new(0, 6)
TabPadding.PaddingRight = UDim.new(0, 6)
TabPadding.PaddingTop = UDim.new(0, 8)
TabPadding.PaddingBottom = UDim.new(0, 8)
local Content = Instance.new("Frame", Main)
Content.Name = "TabContentContainer"
Content.Size = UDim2.new(1, -134, 1, -44)
Content.Position = UDim2.fromOffset(130, 40)
Content.BackgroundTransparency = 1
Content.BorderSizePixel = 0
local Pages, TabBtns = {}, {}
local currentTab = "Survivor"
local function SetTab(name)
    currentTab = name
    for n, p in pairs(Pages) do
        p.Visible = (n == name)
    end
    for n, btnData in pairs(TabBtns) do
        local isSel = (n == name)
        tw(btnData.btn, {
            BackgroundTransparency = isSel and 0 or 1,
            BackgroundColor3 = isSel and C.SidebarActive or C.SidebarBtn
        }, 0.15)
        tw(btnData.label, {
            TextColor3 = isSel and Color3.fromRGB(255, 255, 255) or C.Sub
        }, 0.15)
        tw(btnData.icon, {
            ImageColor3 = isSel and Color3.fromRGB(255, 255, 255) or C.Sub
        }, 0.15)
        tw(btnData.indicator, {
            BackgroundTransparency = isSel and 0 or 1
        }, 0.15)
    end
end
local TabIcons = {
    Info = "rbxassetid://10734934585",
    Survivor = "rbxassetid://10747373176",
    Killer = "rbxassetid://10734951847",
    Generators = "rbxassetid://10723415205",
    ESP = "rbxassetid://10723346959",
    ["Troll Players"] = "rbxassetid://10709770560",
    ["Others Scripts"] = "rbxassetid://10723405649"
}
local MakeTab = function(name, order)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1, 0, 0, 32)
    btn.BackgroundColor3 = C.SidebarBtn
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.LayoutOrder = order
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 7)
    local indicator = Instance.new("Frame", btn)
    indicator.Size = UDim2.new(0, 3, 0, 16)
    indicator.Position = UDim2.new(0, 2, 0.5, -8)
    indicator.BackgroundColor3 = C.ActivePill
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
    label.Font = Enum.Font.GothamMedium
    label.TextXAlignment = Enum.TextXAlignment.Left
    btn.MouseEnter:Connect(function()
        if currentTab ~= name then
            tw(btn, { BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(28, 15, 48) }, 0.12)
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
        indicator = indicator
    }
    local page = Instance.new("ScrollingFrame", Content)
    page.Name = name .. "_Page"
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = C.Purple
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    local pl = Instance.new("UIListLayout", page)
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.Padding = UDim.new(0, 6)
    local pPad = Instance.new("UIPadding", page)
    pPad.PaddingLeft = UDim.new(0, 4)
    pPad.PaddingRight = UDim.new(0, 8)
    pPad.PaddingTop = UDim.new(0, 4)
    pPad.PaddingBottom = UDim.new(0, 16)
    Pages[name] = page
    btn.MouseButton1Click:Connect(function()
        SetTab(name)
    end)
    return page
end
local function AddToggle(parent, titleText, subText, key)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 42)
    f.BackgroundColor3 = C.Card
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    local fStroke = Instance.new("UIStroke", f)
    fStroke.Color = C.CardStroke
    fStroke.Thickness = 1
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, -70, 0, 18)
    t.Position = UDim2.fromOffset(12, 4)
    t.BackgroundTransparency = 1
    t.Text = titleText
    t.TextColor3 = C.Txt
    t.TextSize = 11.5
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left
    local s = Instance.new("TextLabel", f)
    s.Size = UDim2.new(1, -70, 0, 14)
    s.Position = UDim2.fromOffset(12, 22)
    s.BackgroundTransparency = 1
    s.Text = subText
    s.TextColor3 = C.Sub
    s.TextSize = 9.5
    s.Font = Enum.Font.GothamMedium
    s.TextXAlignment = Enum.TextXAlignment.Left
    local toggleTrack = Instance.new("Frame", f)
    toggleTrack.Size = UDim2.fromOffset(36, 18)
    toggleTrack.Position = UDim2.new(1, -48, 0.5, -9)
    toggleTrack.BackgroundColor3 = Flags[key] and C.Purple or C.Off
    Instance.new("UICorner", toggleTrack).CornerRadius = UDim.new(1, 0)
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
        tw(toggleTrack, { BackgroundColor3 = val and C.Purple or C.Off }, 0.16)
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
    end)
    btn.MouseLeave:Connect(function()
        tw(f, { BackgroundColor3 = C.Card }, 0.12)
    end)
end
local function AddActionCard(parent, titleText, subText, callback)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, subText ~= "" and 42 or 34)
    f.BackgroundColor3 = C.Card
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 8)
    local fStroke = Instance.new("UIStroke", f)
    fStroke.Color = C.CardStroke
    fStroke.Thickness = 1
    local t = Instance.new("TextLabel", f)
    t.Size = UDim2.new(1, -50, 0, subText ~= "" and 18 or 34)
    t.Position = UDim2.fromOffset(12, subText ~= "" and 4 or 0)
    t.BackgroundTransparency = 1
    t.Text = titleText
    t.TextColor3 = C.Txt
    t.TextSize = 11.5
    t.Font = Enum.Font.GothamBold
    t.TextXAlignment = Enum.TextXAlignment.Left
    if subText ~= "" then
        local s = Instance.new("TextLabel", f)
        s.Size = UDim2.new(1, -50, 0, 14)
        s.Position = UDim2.fromOffset(12, 22)
        s.BackgroundTransparency = 1
        s.Text = subText
        s.TextColor3 = C.Sub
        s.TextSize = 9.5
        s.Font = Enum.Font.GothamMedium
        s.TextXAlignment = Enum.TextXAlignment.Left
    end
    local arrow = Instance.new("TextLabel", f)
    arrow.Size = UDim2.fromOffset(24, 24)
    arrow.Position = UDim2.new(1, -34, 0.5, -12)
    arrow.BackgroundTransparency = 1
    arrow.Text = ">"
    arrow.TextColor3 = C.Sub
    arrow.TextSize = 13
    arrow.Font = Enum.Font.GothamBold
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.MouseEnter:Connect(function()
        tw(f, { BackgroundColor3 = C.CardHover }, 0.12)
        tw(arrow, { TextColor3 = C.PurpleGlow }, 0.12)
    end)
    btn.MouseLeave:Connect(function()
        tw(f, { BackgroundColor3 = C.Card }, 0.12)
        tw(arrow, { TextColor3 = C.Sub }, 0.12)
    end)
    btn.MouseButton1Click:Connect(function()
        tw(f, { BackgroundColor3 = Color3.fromRGB(45, 22, 75) }, 0.08)
        task.delay(0.08, function()
            tw(f, { BackgroundColor3 = C.CardHover }, 0.1)
        end)
        if callback then callback() end
    end)
end
local function AddSection(parent, sectionTitle)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1, 0, 0, 24)
    f.BackgroundTransparency = 1
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1, 0, 1, 0)
    l.BackgroundTransparency = 1
    l.Text = sectionTitle
    l.TextColor3 = Color3.fromRGB(240, 230, 255)
    l.TextSize = 11.5
    l.Font = Enum.Font.GothamBold
    l.TextXAlignment = Enum.TextXAlignment.Left
end
local InfoPage = MakeTab("Info", 1)
local SurvivorPage = MakeTab("Survivor", 2)
local KillerPage = MakeTab("Killer", 3)
local GensPage = MakeTab("Generators", 4)
local GeneratorsPage = GensPage
local ESPPage = MakeTab("ESP", 5)
local TrollPage = MakeTab("Troll Players", 6)
local OthersPage = MakeTab("Others Scripts", 7)
SetTab("Survivor")
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
AvatarImg.BackgroundColor3 = Color3.fromRGB(30, 15, 48)
AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. player.UserId .. "&w=150&h=150"
AvatarImg.BorderSizePixel = 0
Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)
local aStroke = Instance.new("UIStroke", AvatarImg)
aStroke.Color = C.Purple
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
UsernameLbl.Text = "@" .. player.Name .. "  |  ID: " .. tostring(player.UserId)
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
UserMetaLbl.TextColor3 = C.PurpleGlow
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
AddActionCard(SurvivorPage, "Teleport to the Killer", "Teleport to the Killer", function()
    local char = player.Character
    local killer = GetKiller()
    if char and char:FindFirstChild("HumanoidRootPart") and killer and killer:FindFirstChild("HumanoidRootPart") then
        char.HumanoidRootPart.CFrame = killer.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4)
        Notify("RYC HUB", "Teleported to Killer!", 2)
    else
        Notify("RYC HUB", "Killer not found in match!", 2)
    end
end)
AddToggle(SurvivorPage, "Auto Shoot", "Auto Shoot (Need Hability)", "AutoShoot")
AddToggle(SurvivorPage, "Auto Parry", "Auto Parry (Need Hability)", "AutoParry")
AddToggle(SurvivorPage, "Auto Heal", "Auto skill Heal", "AutoHeal")
AddActionCard(SurvivorPage, "Fling Killer", "Fling Killer (beta)", function()
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
        local bv = Instance.new("BodyAngularVelocity")
        bv.AngularVelocity = Vector3.new(200000, 200000, 200000)
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
AddSection(SurvivorPage, "Exit Options")
AddToggle(SurvivorPage, "Auto Lever", "Auto Lever", "AutoLever")
AddActionCard(SurvivorPage, "Teleport to the exit", "Teleport to the exit", function()
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local foundGate = nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        local n = obj.Name:lower()
        if (n:find("exit") or n:find("gate") or n:find("lever")) and (obj:IsA("BasePart") or obj:IsA("Model")) then
            local pos = obj:IsA("BasePart") and obj.Position or (obj.PrimaryPart and obj.PrimaryPart.Position)
            if pos then
                foundGate = pos
                break
            end
        end
    end
    if foundGate then
        char.HumanoidRootPart.CFrame = CFrame.new(foundGate + Vector3.new(0, 3, 2))
        Notify("RYC HUB", "Teleported to Exit Gate!", 2.5)
    else
        Notify("RYC HUB", "Exit Gate not found or not active!", 2.5)
    end
end)
AddToggle(KillerPage, "Kill Aura", "Auto Attack Nearby Survivors", "KillAura")
AddToggle(KillerPage, "Hitbox Expander", "Expand Survivor Hitboxes", "HitboxExpander")
AddActionCard(KillerPage, "Teleport to Nearest Survivor", "Instantly hunt nearest player", function()
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
AddToggle(GeneratorsPage, "Auto Repair Generator", "Auto Interact with Generators", "AutoFixGen")
AddToggle(GeneratorsPage, "Auto Perfect Skill Check", "Never Miss a Skill Check", "AutoSkillcheck")
AddActionCard(GeneratorsPage, "Teleport to Nearest Generator", "Cycle to next incomplete gen", function()
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
AddToggle(ESPPage, "Killer ESP", "Highlight Killer with Red Glow", "KillerESP")
AddToggle(ESPPage, "Survivor ESP", "Highlight Survivors with Cyan Glow", "SurvivorESP")
AddToggle(ESPPage, "Generators ESP", "Show Generator Distance & Status", "GeneratorESP")
AddToggle(ESPPage, "Exit Gates ESP", "Show Exit Gate Locations", "ExitESP")
AddToggle(ESPPage, "Fullbright", "Remove Atmosphere Darkness & Fog", "Fullbright")
AddToggle(TrollPage, "Noclip", "Walk through walls and obstacles", "Noclip")
AddToggle(TrollPage, "Fly Mode", "Free Fly across the map", "Fly")
AddToggle(TrollPage, "Infinite Stamina", "Never run out of sprint stamina", "InfiniteStamina")
AddActionCard(OthersPage, "ERDEVA SCRIPT", "LINK DISCORD https://discord.gg/fTv3aKA9Ed", function()
    if setclipboard then
        setclipboard("https://discord.gg/fTv3aKA9Ed")
    elseif toclipboard then
        toclipboard("https://discord.gg/fTv3aKA9Ed")
    end
    Notify("ERDEVA SCRIPT", "Discord link copied to clipboard!", 3)
end)
AddActionCard(OthersPage, "Rejoin Server", "Quick rejoin this current server", function()
    game:GetService("TeleportService"):Teleport(game.PlaceId, player)
end)
task.spawn(function()
    local connectedGen, connectedHeal = false, false
    while IsRunning and (not connectedGen or not connectedHeal) do
        pcall(function()
            if not connectedGen and Remotes.GenSkillEvent then
                Remotes.GenSkillEvent.OnClientEvent:Connect(function(...)
                    local args = {...}
                    if Flags.AutoSkillcheck and Remotes.GenSkillResult then
                        pcall(function()
                            Remotes.GenSkillResult:FireServer(true, unpack(args))
                        end)
                    end
                end)
                connectedGen = true
            end
            if not connectedHeal and Remotes.HealSkillEvent then
                Remotes.HealSkillEvent.OnClientEvent:Connect(function(...)
                    local args = {...}
                    if Flags.AutoSkillcheck and Remotes.HealSkillResult then
                        pcall(function()
                            Remotes.HealSkillResult:FireServer(true, unpack(args))
                        end)
                    end
                end)
                connectedHeal = true
            end
        end)
        task.wait(1.5)
    end
end)
task.spawn(function()
    while IsRunning do
        pcall(function()
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local myPos = char.HumanoidRootPart.Position
            local killer = GetKiller()
            if killer and killer:FindFirstChild("HumanoidRootPart") then
                local kDist = (killer.HumanoidRootPart.Position - myPos).Magnitude
                if Flags.AutoParry and kDist <= 16 then
                    if Remotes.Parry then
                        Remotes.Parry:FireServer()
                    end
                    for _, t in ipairs(char:GetChildren()) do
                        if t:IsA("Tool") and t.Name:lower():find("parry") then
                            t:Activate()
                        end
                    end
                end
                if Flags.AutoShoot and kDist <= 35 then
                    if Remotes.Shoot then
                        Remotes.Shoot:FireServer(killer.HumanoidRootPart.Position)
                    end
                    for _, t in ipairs(char:GetChildren()) do
                        if t:IsA("Tool") and (t.Name:lower():find("twist") or t.Name:lower():find("fate") or t.Name:lower():find("gun")) then
                            t:Activate()
                        end
                    end
                end
            end
            if Flags.AutoHeal then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health < hum.MaxHealth * 0.8 then
                    if Remotes.BandageHeal then
                        Remotes.BandageHeal:FireServer()
                    end
                    if Remotes.Adrenaline then
                        Remotes.Adrenaline:FireServer()
                    end
                    if Remotes.HealEvent then
                        Remotes.HealEvent:FireServer()
                    end
                    for _, t in ipairs(char:GetChildren()) do
                        if t:IsA("Tool") and (t.Name:lower():find("bandage") or t.Name:lower():find("adren") or t.Name:lower():find("med")) then
                            t:Activate()
                        end
                    end
                end
            end
            if Flags.AutoLever then
                if Remotes.ExitLever then
                    Remotes.ExitLever:FireServer()
                end
                if Remotes.ExitGate then
                    Remotes.ExitGate:FireServer()
                end
            end
        end)
        task.wait(0.12)
    end
end)
task.spawn(function()
    while IsRunning do
        pcall(function()
            if not Flags.AutoFixGen then return end
            local char = player.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then return end
            local myPos = char.HumanoidRootPart.Position
            if Remotes.GenRepair then
                Remotes.GenRepair:FireServer()
            end
            for _, prompt in ipairs(Workspace:GetDescendants()) do
                if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                    local pName = prompt.ActionText:lower() .. " " .. prompt.ObjectText:lower()
                    if pName:find("repair") or pName:find("gen") or pName:find("motor") or pName:find("fix") then
                        fireproximityprompt(prompt)
                    end
                end
            end
        end)
        task.wait(0.2)
    end
end)
task.spawn(function()
    while IsRunning do
        pcall(function()
            local char = player.Character
            local myPos = char and char:FindFirstChild("HumanoidRootPart") and char.HumanoidRootPart.Position or Vector3.new(0, 0, 0)
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local targetHrp = p.Character.HumanoidRootPart
                    local dist = (targetHrp.Position - myPos).Magnitude
                    if Flags.KillAura and dist <= 16 then
                        if Remotes.BasicAttack then
                            Remotes.BasicAttack:FireServer()
                        end
                        if Remotes.Hit then
                            Remotes.Hit:FireServer(p.Character)
                        end
                    end
                    if Flags.HitboxExpander then
                        targetHrp.Size = Vector3.new(Flags.HitboxSize, Flags.HitboxSize, Flags.HitboxSize)
                        targetHrp.Transparency = 0.65
                        targetHrp.CanCollide = false
                    else
                        if targetHrp.Size ~= Vector3.new(2, 2, 1) then
                            targetHrp.Size = Vector3.new(2, 2, 1)
                            targetHrp.Transparency = 1
                        end
                    end
                end
            end
        end)
        task.wait(0.2)
    end
end)
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
task.spawn(function()
    while IsRunning do
        pcall(function()
            if Flags.Fullbright then
                Lighting.Brightness = 2.5
                Lighting.ClockTime = 14
                Lighting.FogEnd = 1000000
                Lighting.GlobalShadows = false
                Lighting.Ambient = Color3.fromRGB(200, 200, 200)
            end
        end)
        task.wait(0.5)
    end
end)
local ActiveESPs = {}
local function CreateHighlight(model, color)
    local hl = Instance.new("Highlight")
    hl.Adornee = model
    hl.FillColor = color
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.45
    hl.OutlineTransparency = 0.1
    pcall(function() hl.Parent = safeParent end)
    if not hl.Parent then
        pcall(function() hl.Parent = model end)
    end
    return hl
end
local function CreateTag(part, text, color)
    local bb = Instance.new("BillboardGui")
    bb.Size = UDim2.fromOffset(130, 26)
    bb.Adornee = part
    bb.AlwaysOnTop = true
    bb.StudsOffset = Vector3.new(0, 2.5, 0)
    pcall(function() bb.Parent = safeParent end)
    if not bb.Parent then
        pcall(function() bb.Parent = part end)
    end
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
                end
            end
        end)
        task.wait(0.3)
    end
end)
SetTab("Survivor")
Notify("RYC HUB", "Script Loaded!", 3.5)
