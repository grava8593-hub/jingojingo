--[[
    ERDEVA HUB - STEAL AN EGG
    Fixed & Optimized Version
    All bugs resolved, error handling added
]]

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")
local StarterGui = game:GetService("StarterGui")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

local targetParent = CoreGui
if not pcall(function() Instance.new("Folder", CoreGui):Destroy() end) then
    targetParent = PlayerGui
end

if targetParent:FindFirstChild("ErdevaStealAnEgg") then
    targetParent.ErdevaStealAnEgg:Destroy()
end

pcall(function()
    LP.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.zero)
    end)
end)

local iconPath = "ErdevaHubIcon.png"
if not isfile(iconPath) then
    pcall(function()
        writefile(iconPath, game:HttpGet("https://raw.githubusercontent.com/voxynoxy/ErdevaHub/main/icon.png"))
    end)
end
local hubCustomIcon = isfile(iconPath) and getcustomasset(iconPath) or "rbxassetid://6031075931"

local discordIconPath = "ErdevaDiscordIcon.png"
pcall(function()
    if isfile(discordIconPath) then delfile(discordIconPath) end
    writefile(discordIconPath, game:HttpGet("https://raw.githubusercontent.com/grava8593-hub/icon/main/dcicon.png"))
end)
local discordCustomIcon = isfile(discordIconPath) and getcustomasset(discordIconPath) or ""

local Net = RS:WaitForChild("Packages", 10) and RS.Packages:WaitForChild("Networking", 10)
local function GetNetRemote(name)
    if not Net then return nil end
    local ok, remote = pcall(function()
        return Net:FindFirstChild(name, true)
    end)
    return ok and remote or nil
end

local RF_AskFieldEggCarry = GetNetRemote("RF/EggWorld/AskFieldEggCarry")
local RF_AskFieldEggDrop  = GetNetRemote("RF/EggWorld/AskFieldEggDrop")
local RF_AskPlaceEgg      = GetNetRemote("RF/EggWorld/AskPlaceEgg")
local RF_AskHatch         = GetNetRemote("RF/EggWorld/AskHatch")
local RF_AskFinishHatch   = GetNetRemote("RF/EggWorld/AskFinishHatch")
local RF_AskSkipGrowth    = GetNetRemote("RF/EggWorld/AskSkipGrowth")

local RE_SellEveryPet     = GetNetRemote("RE/PetSatchel/SellEveryPet")
local RE_SellPet          = GetNetRemote("RE/PetSatchel/SellPet")
local RF_WearBest         = GetNetRemote("RF/Haul/WearBest")

local RE_BatSwing         = GetNetRemote("RE/BatSwing/Trigger")

local RF_AwayEarnings     = GetNetRemote("RF/AwayEarnings/AskCollect")
local RF_GroupPerk        = GetNetRemote("RF/GroupPerk/RedeemPerk")
local RF_CodexRedeemAll   = GetNetRemote("RF/Codex/AskRedeemAll")
local RF_ClaimQuest       = GetNetRemote("RF/OnboardingQuestline/AskClaim")

local RE_SpeedGained      = GetNetRemote("RE/Treadmill/SpeedGained")
local RF_AskTierRaise     = GetNetRemote("RF/Treadmill/AskTierRaise")

local State = {
    AutoSteal       = false,
    InstantSteal    = false,
    AutoPlace       = false,
    AutoHatch       = false,
    AutoSellPets    = false,
    AutoEquipBest   = false,
    AutoBatSwing    = false,
    AutoTreadmill   = false,
    AutoClaimGifts  = false,
    EggESP          = false,
    Flying          = false,
    FlySpeed        = 75,
    StealSpeed      = 500,
    WalkSpeed       = 16,
    JumpPower       = 50,
    EggsStolen      = 0,
    Status          = "Idle",
    TargetPlot      = "None",
    MyPlot          = nil,
    MyPlotCFrame    = nil,
    Running         = true
}

local IgnoredPrompts = {}
local UpdateMonitorUI = function() end

-- ==================== UTILITY FUNCTIONS ====================

local function SafeFire(remote, ...)
    if not remote then return end
    local ok, err = pcall(function(...)
        if remote:IsA("RemoteEvent") then
            remote:FireServer(...)
        elseif remote:IsA("RemoteFunction") then
            remote:InvokeServer(...)
        end
    end, ...)
    if not ok then
        warn("[Erdeva] SafeFire error:", err)
    end
end

local function GetRoot()
    local char = LP.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHum()
    local char = LP.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function TriggerPrompt(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.MaxActivationDistance = 999
        if fireproximityprompt then
            fireproximityprompt(prompt)
        end
        if prompt.InputHoldBegin and prompt.InputHoldEnd then
            prompt:InputHoldBegin()
            task.wait(0.2)
            prompt:InputHoldEnd()
        end
    end)
end

local function SafeTP(targetCFrame)
    if not targetCFrame then return end
    local char = LP.Character
    local root = GetRoot()
    if not root or not char then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end

    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    root.CFrame = targetCFrame
    task.wait(0.04)
    root.AssemblyLinearVelocity = Vector3.zero
end

local function MoveWithPhysics(targetPos, safeSpeed, timeout)
    safeSpeed = safeSpeed or 34
    timeout = timeout or 15

    local char = LP.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return false end

    root.Anchored = false
    hum.PlatformStand = false

    local startTime = tick()
    local reached = false

    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {char}
    rayParams.FilterType = RaycastFilterType.Exclude

    while (tick() - startTime) < timeout do
        RunService.Heartbeat:Wait()

        if not char.Parent or hum.Health <= 0 then break end
        if not State.Running then break end

        local curPos = root.Position
        local deltaX = targetPos.X - curPos.X
        local deltaZ = targetPos.Z - curPos.Z
        local distHorizontal = math.sqrt(deltaX * deltaX + deltaZ * deltaZ)

        if distHorizontal <= 3.5 then
            reached = true
            break
        end

        local dirX = deltaX / distHorizontal
        local dirZ = deltaZ / distHorizontal

        local forwardRay = Workspace:Raycast(curPos, Vector3.new(dirX * 3, 0, dirZ * 3), rayParams)
        if forwardRay and hum.FloorMaterial ~= Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end

        root.AssemblyLinearVelocity = Vector3.new(
            dirX * safeSpeed,
            root.AssemblyLinearVelocity.Y,
            dirZ * safeSpeed
        )

        root.CFrame = CFrame.lookAt(curPos, Vector3.new(targetPos.X, curPos.Y, targetPos.Z))
    end

    root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
    return reached
end

-- ==================== GLIDE FUNCTION (FIXED) ====================

local function GlideToPosition(targetPos, speed)
    speed = speed or 500
    local char = LP.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    root.Anchored = false
    local startTime = tick()
    local timeout = 5

    while (tick() - startTime) < timeout do
        RunService.Heartbeat:Wait()
        if not State.Running then break end

        local curPos = root.Position
        local dir = (targetPos - curPos)
        local dist = dir.Magnitude

        if dist <= 4 then
            break
        end

        root.AssemblyLinearVelocity = dir.Unit * speed
    end

    root.AssemblyLinearVelocity = Vector3.zero
    return true
end

-- ==================== FIND MY PLOT ====================

local function FindMyPlot()
    local plots = Workspace:FindFirstChild("Plots")
    if plots then
        for _, pl in ipairs(plots:GetChildren()) do
            local ok, pivot = pcall(function() return pl:GetPivot() end)
            if not ok then
                ok, pivot = pcall(function() return pl.CFrame end)
            end
            if not ok then
                pivot = CFrame.new(0, 10, 0)
            end

            for _, descendant in ipairs(pl:GetDescendants()) do
                if descendant:IsA("TextLabel") then
                    local text = descendant.Text or ""
                    if string.find(string.lower(text), string.lower(LP.Name)) or 
                       string.find(string.lower(text), string.lower(LP.DisplayName)) then
                        State.MyPlot = pl
                        return pivot + Vector3.new(0, 3, 0)
                    end
                end
                if descendant:IsA("ObjectValue") and descendant.Value == LP then
                    State.MyPlot = pl
                    return pivot + Vector3.new(0, 3, 0)
                end
                if descendant:IsA("StringValue") and 
                   (descendant.Value == LP.Name or descendant.Value == tostring(LP.UserId)) then
                    State.MyPlot = pl
                    return pivot + Vector3.new(0, 3, 0)
                end
            end
        end
    end

    local spawn = Workspace:FindFirstChildOfClass("SpawnLocation")
    if spawn then return spawn.CFrame + Vector3.new(0, 3, 0) end
    local root = GetRoot()
    return root and root.CFrame or CFrame.new(0, 10, 0)
end

task.spawn(function()
    task.wait(1)
    local ok, result = pcall(FindMyPlot)
    if ok then
        State.MyPlotCFrame = result
    end
end)

-- ==================== EGG DETECTION ====================

local function IsCarryingEgg()
    local char = LP.Character
    if not char then return false end

    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") and string.find(string.lower(item.Name), "egg") then
            return true
        end
        if item:IsA("Model") and string.find(string.lower(item.Name), "egg") and 
           not string.find(string.lower(item.Name), "pet") then
            return true
        end
    end
    return false
end

local function FindStealableEggs()
    local list = {}
    local myRoot = GetRoot()
    if not myRoot then return list end
    local myPos = myRoot.Position
    local myPlot = State.MyPlot

    local now = os.clock()
    for prompt, expire in pairs(IgnoredPrompts) do
        if now > expire then IgnoredPrompts[prompt] = nil end
    end

    for _, p in ipairs(Workspace:GetDescendants()) do
        if p:IsA("ProximityPrompt") and not IgnoredPrompts[p] then
            local action = string.lower(p.ActionText or "")
            local objText = string.lower(p.ObjectText or "")

            if string.find(action, "steal") or string.find(action, "take") or string.find(objText, "egg") then
                local parentPlot = p:FindFirstAncestor("Plots")
                local isMyPlot = false
                if myPlot and p:IsDescendantOf(myPlot) then
                    isMyPlot = true
                end

                if not isMyPlot then
                    local parentPart = p.Parent:IsA("BasePart") and p.Parent or p.Parent:FindFirstChildWhichIsA("BasePart")
                    if parentPart then
                        local dist = (myPos - parentPart.Position).Magnitude
                        table.insert(list, {
                            Prompt   = p,
                            Part     = parentPart,
                            Distance = dist,
                            PlotName = parentPlot and parentPlot.Name or "Wild"
                        })
                    end
                end
            end
        end
    end

    table.sort(list, function(a, b)
        return a.Distance < b.Distance
    end)

    return list
end

-- ==================== STEAL ACTIONS ====================

local function PerformEggSteal(target)
    local root = GetRoot()
    if not root then return false end

    GlideToPosition(target.Part.Position, State.StealSpeed)
    task.wait(0.1)
    if not State.Running then return false end

    TriggerPrompt(target.Prompt)
    SafeFire(RF_AskFieldEggCarry, target.Prompt.Parent)

    local startWait = os.clock()
    while os.clock() - startWait < 0.8 do
        if IsCarryingEgg() then return true end
        task.wait(0.05)
    end
    return IsCarryingEgg()
end

local function PerformInstantSteal(target)
    local root = GetRoot()
    if not root then return false end

    SafeTP(CFrame.new(target.Part.Position + Vector3.new(0, 3, 0)))
    task.wait(0.05)
    if not State.Running then return false end

    TriggerPrompt(target.Prompt)
    SafeFire(RF_AskFieldEggCarry, target.Prompt.Parent)

    local startWait = os.clock()
    while os.clock() - startWait < 0.6 do
        if IsCarryingEgg() then return true end
        task.wait(0.05)
    end
    return IsCarryingEgg()
end

local function DeliverEggToBase(instant)
    local char = LP.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return false end

    local targetCFrame = State.MyPlotCFrame or FindMyPlot()
    State.MyPlotCFrame = targetCFrame

    if instant then
        SafeTP(targetCFrame)
        task.wait(0.2)
    else
        hum.WalkSpeed = 16
        hum.PlatformStand = false
        root.Anchored = false
        MoveWithPhysics(targetCFrame.Position, 34, 20)
        task.wait(0.2)
    end

    if RF_AskPlaceEgg then
        pcall(function() RF_AskPlaceEgg:InvokeServer() end)
    end
    if RF_AskFieldEggDrop then
        SafeFire(RF_AskFieldEggDrop)
    end

    return true
end

-- ==================== ESP ====================

local espFolder = nil
local function UpdateESP(enable)
    if espFolder then espFolder:Destroy(); espFolder = nil end
    if not enable or not State.Running then return end

    espFolder = Instance.new("Folder")
    espFolder.Name = "ErdevaStealESP"
    espFolder.Parent = Workspace

    local ok, eggs = pcall(FindStealableEggs)
    if not ok then return end

    for _, item in ipairs(eggs) do
        local p = item.Part
        if p and p.Parent then
            local hl = Instance.new("Highlight")
            hl.Adornee = p.Parent:IsA("Model") and p.Parent or p
            hl.FillColor = Color3.fromRGB(255, 60, 95)
            hl.FillTransparency = 0.5
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.Parent = espFolder

            local bb = Instance.new("BillboardGui")
            bb.Adornee = p
            bb.Size = UDim2.fromOffset(130, 32)
            bb.AlwaysOnTop = true
            bb.Parent = espFolder

            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = "EGG [" .. item.PlotName .. "]"
            lbl.TextColor3 = Color3.fromRGB(255, 80, 100)
            lbl.TextStrokeColor3 = Color3.fromRGB(20, 5, 8)
            lbl.TextStrokeTransparency = 0.2
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 11
            lbl.Parent = bb
        end
    end
end

-- ==================== FLY ====================

local flyBV, flyBG
local function ToggleFly(on)
    State.Flying = on
    local root = GetRoot()
    local hum = GetHum()
    if not root or not hum then return end

    if on then
        if root:FindFirstChild("ErdevaFlyBV") then root.ErdevaFlyBV:Destroy() end
        if root:FindFirstChild("ErdevaFlyBG") then root.ErdevaFlyBG:Destroy() end

        flyBV = Instance.new("BodyVelocity")
        flyBV.Name = "ErdevaFlyBV"
        flyBV.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        flyBV.Velocity = Vector3.zero
        flyBV.Parent = root

        flyBG = Instance.new("BodyGyro")
        flyBG.Name = "ErdevaFlyBG"
        flyBG.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        flyBG.P = 1e6
        flyBG.CFrame = root.CFrame
        flyBG.Parent = root

        hum.PlatformStand = true
    else
        if root:FindFirstChild("ErdevaFlyBV") then root.ErdevaFlyBV:Destroy() end
        if root:FindFirstChild("ErdevaFlyBG") then root.ErdevaFlyBG:Destroy() end
        hum.PlatformStand = false
        flyBV = nil
        flyBG = nil
    end
end

local heartbeatConn
heartbeatConn = RunService.Heartbeat:Connect(function()
    if not State.Running then
        if heartbeatConn then heartbeatConn:Disconnect() end
        return
    end
    local root = GetRoot()
    if State.Flying and root and flyBV and flyBG then
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local dir = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end

        flyBV.Velocity = dir.Magnitude > 0 and dir.Unit * State.FlySpeed or Vector3.zero
        flyBG.CFrame = cam.CFrame
    end
end)

-- ==================== UI STYLING ====================

local Clr = {
    MainBg     = Color3.fromRGB(18, 9, 12),
    Sidebar    = Color3.fromRGB(25, 11, 15),
    Card       = Color3.fromRGB(32, 14, 18),
    CardBorder = Color3.fromRGB(80, 24, 32),
    RedAccent  = Color3.fromRGB(235, 30, 48),
    RedDark    = Color3.fromRGB(150, 18, 28),
    RedGlow    = Color3.fromRGB(255, 75, 95),
    TextMain   = Color3.fromRGB(255, 240, 242),
    TextDim    = Color3.fromRGB(195, 145, 152),
    ToggleOff  = Color3.fromRGB(48, 18, 24),
    Discord    = Color3.fromRGB(88, 101, 242)
}

local SG = Instance.new("ScreenGui")
SG.Name = "ErdevaStealAnEgg"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.Parent = targetParent

local FloatBtn = Instance.new("ImageButton")
FloatBtn.Size = UDim2.fromOffset(46, 46)
FloatBtn.Position = UDim2.new(0, 18, 0.35, 0)
FloatBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
FloatBtn.Image = hubCustomIcon
FloatBtn.BorderSizePixel = 0
FloatBtn.Active = true
FloatBtn.Visible = false
FloatBtn.Parent = SG
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Size = UDim2.fromOffset(485, 290)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Clr.Sidebar
Main.BorderSizePixel = 0
Main.Active = true
Main.Parent = SG
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(160, 28, 40)
MainStroke.Thickness = 1.4
MainStroke.Parent = Main

FloatBtn.MouseButton1Click:Connect(function()
    FloatBtn.Visible = false
    Main.Visible = true
end)

local fDragging = false
local fDragStart, fStartPos
FloatBtn.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        fDragging = true; fDragStart = i.Position; fStartPos = FloatBtn.Position
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        fDragging = false
    end
end)
UIS.InputChanged:Connect(function(i)
    if fDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - fDragStart
        FloatBtn.Position = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + delta.X, fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y)
    end
end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 138, 1, 0)
Sidebar.BackgroundColor3 = Clr.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local SideBorderLine = Instance.new("Frame")
SideBorderLine.Size = UDim2.new(0, 1, 1, 0)
SideBorderLine.Position = UDim2.new(1, -1, 0, 0)
SideBorderLine.BackgroundColor3 = Clr.CardBorder
SideBorderLine.BorderSizePixel = 0
SideBorderLine.Parent = Sidebar

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 48)
Header.BackgroundTransparency = 1
Header.Parent = Sidebar

local CustomLogo = Instance.new("ImageLabel")
CustomLogo.Size = UDim2.fromOffset(26, 26)
CustomLogo.Position = UDim2.fromOffset(12, 11)
CustomLogo.BackgroundTransparency = 1
CustomLogo.Image = hubCustomIcon
CustomLogo.Parent = Header
Instance.new("UICorner", CustomLogo).CornerRadius = UDim.new(0, 6)

local GameTitle = Instance.new("TextLabel")
GameTitle.Size = UDim2.new(1, -44, 0, 16)
GameTitle.Position = UDim2.fromOffset(44, 9)
GameTitle.BackgroundTransparency = 1
GameTitle.Text = "ERDEVA HUB"
GameTitle.TextColor3 = Clr.TextMain
GameTitle.Font = Enum.Font.GothamBold
GameTitle.TextSize = 12
GameTitle.TextXAlignment = Enum.TextXAlignment.Left
GameTitle.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, -44, 0, 14)
SubTitle.Position = UDim2.fromOffset(44, 25)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Steal An Egg"
SubTitle.TextColor3 = Clr.RedGlow
SubTitle.Font = Enum.Font.GothamMedium
SubTitle.TextSize = 9
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Header

local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Size = UDim2.new(1, 0, 1, -88)
TabContainer.Position = UDim2.fromOffset(0, 50)
TabContainer.BackgroundTransparency = 1
TabContainer.BorderSizePixel = 0
TabContainer.ScrollBarThickness = 0
TabContainer.Parent = Sidebar

local TabList = Instance.new("UIListLayout")
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Padding = UDim.new(0, 3)
TabList.Parent = TabContainer

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -142, 1, 0)
ContentArea.Position = UDim2.fromOffset(142, 0)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = Main

local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 0, 32)
Topbar.BackgroundTransparency = 1
Topbar.Parent = ContentArea

local function DestroyAll()
    State.Running = false
    State.AutoSteal = false
    State.InstantSteal = false
    State.AutoPlace = false
    State.AutoHatch = false
    State.AutoSellPets = false
    State.AutoEquipBest = false
    State.AutoBatSwing = false
    State.AutoTreadmill = false
    State.AutoClaimGifts = false
    State.EggESP = false
    ToggleFly(false)
    UpdateESP(false)
    if heartbeatConn then heartbeatConn:Disconnect() end
    task.wait(0.2)
    SG:Destroy()
end

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(20, 20)
CloseBtn.Position = UDim2.new(1, -26, 0.5, -10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(42, 12, 16)
CloseBtn.Text = "x"
CloseBtn.TextColor3 = Clr.RedGlow
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 10
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Topbar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)
CloseBtn.MouseButton1Click:Connect(DestroyAll)

local MinMainBtn = Instance.new("TextButton")
MinMainBtn.Size = UDim2.fromOffset(20, 20)
MinMainBtn.Position = UDim2.new(1, -50, 0.5, -10)
MinMainBtn.BackgroundColor3 = Color3.fromRGB(36, 16, 20)
MinMainBtn.Text = "-"
MinMainBtn.TextColor3 = Clr.TextDim
MinMainBtn.Font = Enum.Font.GothamBold
MinMainBtn.TextSize = 12
MinMainBtn.BorderSizePixel = 0
MinMainBtn.Parent = Topbar
Instance.new("UICorner", MinMainBtn).CornerRadius = UDim.new(0, 5)
MinMainBtn.MouseButton1Click:Connect(function()
    Main.Visible = false
    FloatBtn.Visible = true
end)

local mDragging, mStart, mPos
Topbar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        mDragging = true; mStart = i.Position; mPos = Main.Position
    end
end)
UIS.InputEnded:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
        mDragging = false
    end
end)
UIS.InputChanged:Connect(function(i)
    if mDragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
        local delta = i.Position - mStart
        Main.Position = UDim2.new(mPos.X.Scale, mPos.X.Offset + delta.X, mPos.Y.Scale, mPos.Y.Offset + delta.Y)
    end
end)

local Pages = {}
local TabButtons = {}

local function CreateTab(name, assetId, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -12, 0, 28)
    btn.Position = UDim2.fromOffset(6, 0)
    btn.BackgroundColor3 = Color3.fromRGB(38, 16, 20)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.Parent = TabContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local barIndicator = Instance.new("Frame")
    barIndicator.Size = UDim2.new(0, 3, 0.6, 0)
    barIndicator.Position = UDim2.new(0, 2, 0.2, 0)
    barIndicator.BackgroundColor3 = Clr.RedAccent
    barIndicator.BorderSizePixel = 0
    barIndicator.Visible = false
    barIndicator.Parent = btn
    Instance.new("UICorner", barIndicator).CornerRadius = UDim.new(1, 0)

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.fromOffset(15, 15)
    icon.Position = UDim2.fromOffset(10, 6.5)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://" .. tostring(assetId)
    icon.ImageColor3 = Clr.TextDim
    icon.Parent = btn

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -34, 1, 0)
    titleLbl.Position = UDim2.fromOffset(32, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = name
    titleLbl.TextColor3 = Clr.TextDim
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextSize = 10
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -12, 1, -38)
    page.Position = UDim2.fromOffset(4, 34)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2.5
    page.ScrollBarImageColor3 = Clr.RedAccent
    page.ScrollBarImageTransparency = 0.3
    page.Visible = false
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Parent = ContentArea

    local pLay = Instance.new("UIListLayout")
    pLay.SortOrder = Enum.SortOrder.LayoutOrder
    pLay.Padding = UDim.new(0, 6)
    pLay.Parent = page
    pLay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        page.CanvasSize = UDim2.new(0, 0, 0, pLay.AbsoluteContentSize.Y + 12)
    end)

    Pages[name] = page
    TabButtons[name] = {Btn = btn, Icon = icon, Label = titleLbl, Bar = barIndicator}

    btn.MouseButton1Click:Connect(function()
        for pName, pObj in pairs(Pages) do pObj.Visible = (pName == name) end
        for bName, bData in pairs(TabButtons) do
            local isSel = (bName == name)
            TweenService:Create(bData.Btn, TweenInfo.new(0.14), {
                BackgroundTransparency = isSel and 0 or 1,
                BackgroundColor3 = isSel and Color3.fromRGB(48, 18, 24) or Color3.fromRGB(38, 16, 20)
            }):Play()
            TweenService:Create(bData.Label, TweenInfo.new(0.14), {TextColor3 = isSel and Clr.TextMain or Clr.TextDim}):Play()
            TweenService:Create(bData.Icon, TweenInfo.new(0.14), {ImageColor3 = isSel and Clr.RedGlow or Clr.TextDim}):Play()
            bData.Bar.Visible = isSel
        end
    end)

    return page
end

local function MakeCard(parent, title, desc, order)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, desc and 42 or 34)
    f.BackgroundColor3 = Clr.Card
    f.BorderSizePixel = 0
    f.LayoutOrder = order or 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7)
    local str = Instance.new("UIStroke")
    str.Color = Clr.CardBorder
    str.Thickness = 1
    str.Parent = f

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(0.68, 0, 0, 15)
    tl.Position = UDim2.fromOffset(10, desc and 6 or 9)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.TextColor3 = Clr.TextMain
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 10.5
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = f

    if desc then
        local dl = Instance.new("TextLabel")
        dl.Size = UDim2.new(0.68, 0, 0, 13)
        dl.Position = UDim2.fromOffset(10, 22)
        dl.BackgroundTransparency = 1
        dl.Text = desc
        dl.TextColor3 = Clr.TextDim
        dl.Font = Enum.Font.Gotham
        dl.TextSize = 8.5
        dl.TextXAlignment = Enum.TextXAlignment.Left
        dl.TextTruncate = Enum.TextTruncate.AtEnd
        dl.Parent = f
    end
    return f
end

local function MakeToggle(parent, title, desc, default, order, callback)
    local card = MakeCard(parent, title, desc, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(36, 18)
    btn.Position = UDim2.new(1, -44, 0.5, -9)
    btn.BackgroundColor3 = default and Clr.RedAccent or Clr.ToggleOff
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.Parent = card
    Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(14, 14)
    dot.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    dot.BackgroundColor3 = Color3.new(1, 1, 1)
    dot.BorderSizePixel = 0
    dot.Parent = btn
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(btn, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            BackgroundColor3 = state and Clr.RedAccent or Clr.ToggleOff
        }):Play()
        TweenService:Create(dot, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        local ok, err = pcall(callback, state)
        if not ok then
            warn("[Erdeva] Callback error:", err)
        end
    end)
    return card
end

local function MakeButton(parent, text, order, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1, 0, 0, 32)
    b.BackgroundColor3 = Color3.fromRGB(40, 16, 22)
    b.BorderSizePixel = 0
    b.Text = text
    b.TextColor3 = Clr.TextMain
    b.Font = Enum.Font.GothamBold
    b.TextSize = 10
    b.LayoutOrder = order or 0
    b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    local s = Instance.new("UIStroke")
    s.Color = Clr.CardBorder
    s.Thickness = 1
    s.Parent = b

    b.MouseButton1Click:Connect(function()
        TweenService:Create(b, TweenInfo.new(0.08), {BackgroundColor3 = Clr.RedDark}):Play()
        task.delay(0.1, function()
            TweenService:Create(b, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 16, 22)}):Play()
        end)
        local ok, err = pcall(callback)
        if not ok then
            warn("[Erdeva] Button callback error:", err)
        end
    end)
    return b
end

local function MakeSlider(parent, title, minVal, maxVal, curVal, order, callback)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 44)
    f.BackgroundColor3 = Clr.Card
    f.BorderSizePixel = 0
    f.LayoutOrder = order or 0
    f.Parent = parent
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 7)
    local str = Instance.new("UIStroke")
    str.Color = Clr.CardBorder
    str.Thickness = 1
    str.Parent = f

    local tl = Instance.new("TextLabel")
    tl.Size = UDim2.new(0.65, 0, 0, 14)
    tl.Position = UDim2.fromOffset(10, 6)
    tl.BackgroundTransparency = 1
    tl.Text = title
    tl.TextColor3 = Clr.TextMain
    tl.Font = Enum.Font.GothamBold
    tl.TextSize = 10
    tl.TextXAlignment = Enum.TextXAlignment.Left
    tl.Parent = f

    local valBadge = Instance.new("TextLabel")
    valBadge.Size = UDim2.fromOffset(45, 14)
    valBadge.Position = UDim2.new(1, -55, 0, 6)
    valBadge.BackgroundColor3 = Color3.fromRGB(42, 16, 22)
    valBadge.Text = tostring(curVal)
    valBadge.TextColor3 = Clr.RedGlow
    valBadge.Font = Enum.Font.GothamBold
    valBadge.TextSize = 9.5
    valBadge.BorderSizePixel = 0
    valBadge.Parent = f
    Instance.new("UICorner", valBadge).CornerRadius = UDim.new(0, 4)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, -20, 0, 4)
    bar.Position = UDim2.fromOffset(10, 28)
    bar.BackgroundColor3 = Color3.fromRGB(48, 20, 26)
    bar.BorderSizePixel = 0
    bar.Parent = f
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    local ratio = math.clamp((curVal - minVal) / (maxVal - minVal), 0, 1)
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    fill.BackgroundColor3 = Clr.RedAccent
    fill.BorderSizePixel = 0
    fill.Parent = bar
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local sliding = false
    local hit = Instance.new("TextButton")
    hit.Size = UDim2.new(1, 0, 3, 0)
    hit.Position = UDim2.new(0, 0, -1, 0)
    hit.BackgroundTransparency = 1
    hit.Text = ""
    hit.Parent = bar

    hit.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliding = true
        end
    end)
    hit.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            sliding = false
        end
    end)

    UIS.InputChanged:Connect(function(i)
        if sliding and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local rel = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local val = math.floor(minVal + (maxVal - minVal) * rel)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valBadge.Text = tostring(val)
            local ok, err = pcall(callback, val)
            if not ok then warn("[Erdeva] Slider callback error:", err) end
        end
    end)
end

-- ==================== TABS SETUP ====================

local pSteal     = CreateTab("Steal",      10734965572, 1)
local pBase      = CreateTab("Base & Nest", 6031265976, 2)
local pSatchel   = CreateTab("Pets",       6034287594, 3)
local pCombat    = CreateTab("Combat",     6031763426, 4)
local pTeleport  = CreateTab("Teleport",   6031154871, 5)
local pMovement  = CreateTab("Movement",   6034287594, 6)
local pSystem    = CreateTab("System",     6031280882, 7)

Pages["Steal"].Visible = true
TabButtons["Steal"].Btn.BackgroundTransparency = 0
TabButtons["Steal"].Btn.BackgroundColor3 = Color3.fromRGB(48, 18, 24)
TabButtons["Steal"].Label.TextColor3 = Clr.TextMain
TabButtons["Steal"].Icon.ImageColor3 = Clr.RedGlow
TabButtons["Steal"].Bar.Visible = true

-- ==================== MONITOR CARD ====================

local MonitorCard = Instance.new("Frame")
MonitorCard.Size = UDim2.new(1, 0, 0, 68)
MonitorCard.BackgroundColor3 = Color3.fromRGB(26, 12, 16)
MonitorCard.BorderSizePixel = 0
MonitorCard.LayoutOrder = 1
MonitorCard.Parent = pSteal
Instance.new("UICorner", MonitorCard).CornerRadius = UDim.new(0, 8)
local mStroke = Instance.new("UIStroke")
mStroke.Color = Clr.CardBorder
mStroke.Thickness = 1
mStroke.Parent = MonitorCard

local MTitle = Instance.new("TextLabel")
MTitle.Size = UDim2.new(0.5, 0, 0, 16)
MTitle.Position = UDim2.fromOffset(10, 6)
MTitle.BackgroundTransparency = 1
MTitle.Text = "STEAL ENGINE MONITOR"
MTitle.TextColor3 = Clr.TextDim
MTitle.Font = Enum.Font.GothamBold
MTitle.TextSize = 9.5
MTitle.TextXAlignment = Enum.TextXAlignment.Left
MTitle.Parent = MonitorCard

local MStatus = Instance.new("TextLabel")
MStatus.Size = UDim2.fromOffset(130, 16)
MStatus.Position = UDim2.new(1, -140, 0, 6)
MStatus.BackgroundTransparency = 1
MStatus.Text = "Status: Idle"
MStatus.TextColor3 = Color3.fromRGB(130, 240, 160)
MStatus.Font = Enum.Font.GothamBold
MStatus.TextSize = 9.5
MStatus.TextXAlignment = Enum.TextXAlignment.Right
MStatus.Parent = MonitorCard

local MTarget = Instance.new("TextLabel")
MTarget.Size = UDim2.new(1, -20, 0, 14)
MTarget.Position = UDim2.fromOffset(10, 26)
MTarget.BackgroundTransparency = 1
MTarget.Text = "Target: None"
MTarget.TextColor3 = Clr.TextMain
MTarget.Font = Enum.Font.GothamMedium
MTarget.TextSize = 9.5
MTarget.TextXAlignment = Enum.TextXAlignment.Left
MTarget.Parent = MonitorCard

local MMeta = Instance.new("TextLabel")
MMeta.Size = UDim2.new(1, -20, 0, 14)
MMeta.Position = UDim2.fromOffset(10, 44)
MMeta.BackgroundTransparency = 1
MMeta.Text = "Eggs Stolen: 0 | Speed: 500"
MMeta.TextColor3 = Clr.RedGlow
MMeta.Font = Enum.Font.Gotham
MMeta.TextSize = 9
MMeta.TextXAlignment = Enum.TextXAlignment.Left
MMeta.Parent = MonitorCard

UpdateMonitorUI = function()
    MStatus.Text = "Status: " .. State.Status
    if string.find(State.Status, "Stealing") or string.find(State.Status, "Taking") then
        MStatus.TextColor3 = Color3.fromRGB(255, 185, 80)
    elseif string.find(State.Status, "Base") or string.find(State.Status, "Placing") then
        MStatus.TextColor3 = Color3.fromRGB(100, 210, 255)
    else
        MStatus.TextColor3 = Color3.fromRGB(130, 240, 160)
    end
    MTarget.Text = "Target: Plot " .. State.TargetPlot
    MMeta.Text = string.format("Eggs Stolen: %d | Travel Speed: %d", State.EggsStolen, State.StealSpeed)
end

-- ==================== TAB 1: STEAL ====================

MakeToggle(pSteal, "Auto Steal (Glide)", "Fly smoothly to enemy nests and steal eggs", false, 2, function(v)
    State.AutoSteal = v
    if v then
        State.Status = "Scanning Nests..."
        UpdateMonitorUI()
        task.spawn(function()
            while State.AutoSteal and State.Running do
                local ok, err = pcall(function()
                    if IsCarryingEgg() then
                        State.Status = "Delivering to Base..."
                        UpdateMonitorUI()
                        DeliverEggToBase(false)
                    else
                        local targets = FindStealableEggs()
                        if #targets > 0 then
                            local target = targets[1]
                            State.Status = "Stealing..."
                            State.TargetPlot = target.PlotName
                            UpdateMonitorUI()

                            local success = PerformEggSteal(target)
                            if success or IsCarryingEgg() then
                                State.EggsStolen = State.EggsStolen + 1
                                State.Status = "Returning Base..."
                                UpdateMonitorUI()
                                DeliverEggToBase(false)
                                IgnoredPrompts[target.Prompt] = os.clock() + 15
                            else
                                IgnoredPrompts[target.Prompt] = os.clock() + 3
                            end
                        else
                            State.Status = "No Eggs Available"
                            State.TargetPlot = "None"
                            UpdateMonitorUI()
                        end
                    end
                end)
                if not ok then
                    warn("[Erdeva] AutoSteal loop error:", err)
                    task.wait(1)
                end
                task.wait(0.2)
            end
            State.Status = "Idle"
            UpdateMonitorUI()
        end)
    else
        State.Status = "Idle"
        UpdateMonitorUI()
    end
end)

MakeToggle(pSteal, "Instant Steal (Teleport)", "Instantly TP to eggs & claim them", false, 3, function(v)
    State.InstantSteal = v
    if v then
        State.Status = "Scanning (Instant)..."
        UpdateMonitorUI()
        task.spawn(function()
            while State.InstantSteal and State.Running do
                local ok, err = pcall(function()
                    if IsCarryingEgg() then
                        State.Status = "Instant Returning..."
                        UpdateMonitorUI()
                        DeliverEggToBase(true)
                    else
                        local targets = FindStealableEggs()
                        if #targets > 0 then
                            local target = targets[1]
                            State.Status = "Instant Steal..."
                            State.TargetPlot = target.PlotName
                            UpdateMonitorUI()

                            local success = PerformInstantSteal(target)
                            if success or IsCarryingEgg() then
                                State.EggsStolen = State.EggsStolen + 1
                                State.Status = "Instant Delivering..."
                                UpdateMonitorUI()
                                DeliverEggToBase(true)
                                IgnoredPrompts[target.Prompt] = os.clock() + 15
                            else
                                IgnoredPrompts[target.Prompt] = os.clock() + 3
                            end
                        else
                            State.Status = "No Eggs Available"
                            State.TargetPlot = "None"
                            UpdateMonitorUI()
                        end
                    end
                end)
                if not ok then
                    warn("[Erdeva] InstantSteal loop error:", err)
                    task.wait(1)
                end
                task.wait(0.15)
            end
            State.Status = "Idle"
            UpdateMonitorUI()
        end)
    else
        State.Status = "Idle"
        UpdateMonitorUI()
    end
end)

MakeSlider(pSteal, "Steal Glide Speed", 100, 1000, State.StealSpeed, 4, function(v)
    State.StealSpeed = v
    UpdateMonitorUI()
end)

MakeToggle(pSteal, "Egg ESP", "Show tags on stealable eggs in all bases", false, 5, function(v)
    State.EggESP = v
    UpdateESP(v)
    if v then
        task.spawn(function()
            while State.EggESP and State.Running do
                task.wait(3.0)
                if State.EggESP and State.Running then
                    pcall(UpdateESP, true)
                end
            end
        end)
    end
end)

-- ==================== TAB 2: BASE & NEST ====================

MakeToggle(pBase, "Auto Place Stolen Eggs", "Automatically places held eggs in nest", false, 1, function(v)
    State.AutoPlace = v
    if v then
        task.spawn(function()
            while State.AutoPlace and State.Running do
                if IsCarryingEgg() then
                    pcall(function()
                        if RF_AskPlaceEgg then RF_AskPlaceEgg:InvokeServer() end
                        SafeFire(RF_AskFieldEggDrop)
                    end)
                end
                task.wait(1.0)
            end
        end)
    end
end)

MakeToggle(pBase, "Auto Hatch Ready Eggs", "Automatically hatches ready incubated eggs", false, 2, function(v)
    State.AutoHatch = v
    if v then
        task.spawn(function()
            while State.AutoHatch and State.Running do
                SafeFire(RF_AskHatch)
                SafeFire(RF_AskFinishHatch)
                SafeFire(RF_AskSkipGrowth)
                task.wait(1.5)
            end
        end)
    end
end)

MakeToggle(pBase, "Auto Treadmill Speed Train", "Gains character walkspeed automatically", false, 3, function(v)
    State.AutoTreadmill = v
    if v then
        task.spawn(function()
            while State.AutoTreadmill and State.Running do
                SafeFire(RE_SpeedGained)
                SafeFire(RF_AskTierRaise)
                task.wait(1.0)
            end
        end)
    end
end)

-- ==================== TAB 3: PETS ====================

MakeToggle(pSatchel, "Auto Sell All Pets", "Continuously sells excess pets for cash", false, 1, function(v)
    State.AutoSellPets = v
    if v then
        task.spawn(function()
            while State.AutoSellPets and State.Running do
                SafeFire(RE_SellEveryPet)
                task.wait(3.0)
            end
        end)
    end
end)

MakeButton(pSatchel, "Sell All Pets Now", 2, function()
    SafeFire(RE_SellEveryPet)
    StarterGui:SetCore("SendNotification", {
        Title = "Pets Sold!",
        Text = "Successfully sold all non-favorited pets!",
        Duration = 3
    })
end)

MakeToggle(pSatchel, "Auto Equip Best Pets", "Equips your strongest pets automatically", false, 3, function(v)
    State.AutoEquipBest = v
    if v then
        task.spawn(function()
            while State.AutoEquipBest and State.Running do
                SafeFire(RF_WearBest)
                task.wait(5.0)
            end
        end)
    end
end)

-- ==================== TAB 4: COMBAT ====================

MakeToggle(pCombat, "Auto Bat Swing", "Automatically hits nearby guards and egg thieves", false, 1, function(v)
    State.AutoBatSwing = v
    if v then
        task.spawn(function()
            while State.AutoBatSwing and State.Running do
                SafeFire(RE_BatSwing)
                local char = LP.Character
                if char then
                    local bat = char:FindFirstChildOfClass("Tool")
                    if bat then
                        pcall(function() bat:Activate() end)
                    end
                end
                task.wait(0.25)
            end
        end)
    end
end)

-- ==================== TAB 5: TELEPORT ====================

MakeButton(pTeleport, "Teleport to My Base", 1, function()
    local cframe = State.MyPlotCFrame or FindMyPlot()
    State.MyPlotCFrame = cframe
    if cframe then SafeTP(cframe) end
end)

MakeButton(pTeleport, "Teleport to Fuse Machine", 2, function()
    SafeTP(CFrame.new(542, 73, -454))
end)

MakeButton(pTeleport, "Teleport to Sell Merchant", 3, function()
    local prompt = Workspace:FindFirstChild("SellAll", true)
    if prompt and prompt:IsA("BasePart") then
        SafeTP(prompt.CFrame + Vector3.new(0, 3, 0))
    else
        SafeTP(CFrame.new(600, 70, -330))
    end
end)

MakeButton(pTeleport, "Teleport to Enchanted Tree", 4, function()
    local tree = Workspace:FindFirstChild("EnchantedTreeEntrance", true)
    if tree and tree:IsA("BasePart") then
        SafeTP(tree.CFrame + Vector3.new(0, 3, 0))
    end
end)

-- ==================== TAB 6: MOVEMENT ====================

MakeToggle(pMovement, "Hover Fly (Universal)", "Fly freely in all directions", false, 1, function(v)
    ToggleFly(v)
end)

MakeSlider(pMovement, "Fly Speed", 20, 300, 75, 2, function(v) State.FlySpeed = v end)
MakeSlider(pMovement, "Walk Speed", 16, 250, 16, 3, function(v)
    State.WalkSpeed = v
    local hum = GetHum()
    if hum then hum.WalkSpeed = v end
end)
MakeSlider(pMovement, "Jump Power", 50, 300, 50, 4, function(v)
    State.JumpPower = v
    local hum = GetHum()
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = v
    end
end)

-- ==================== TAB 7: SYSTEM ====================

MakeButton(pSystem, "Claim All Free Rewards & Gifts", 1, function()
    SafeFire(RF_AwayEarnings)
    SafeFire(RF_GroupPerk)
    SafeFire(RF_CodexRedeemAll)
    SafeFire(RF_ClaimQuest)
    StarterGui:SetCore("SendNotification", {
        Title = "Rewards Claimed!",
        Text = "Claimed Away Earnings, Group Perk & Quests!",
        Duration = 3
    })
end)

MakeButton(pSystem, "Rejoin Current Server", 2, function()
    local ts = game:GetService("TeleportService")
    pcall(function()
        ts:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
    end)
end)

MakeButton(pSystem, "Destroy GUI", 3, DestroyAll)

StarterGui:SetCore("SendNotification", {
    Title = "Erdeva Hub",
    Text = "Steal An Egg Script Loaded!",
    Duration = 5
})
