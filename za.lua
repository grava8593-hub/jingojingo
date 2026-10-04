local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local VirtualUser = game:GetService("VirtualUser")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

local targetParent = CoreGui
if not pcall(function() Instance.new("Folder", CoreGui):Destroy() end) then
    targetParent = PlayerGui
end

if targetParent:FindFirstChild("ErdevaRideAPet") then
    targetParent.ErdevaRideAPet:Destroy()
end

pcall(function()
    LP.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.zero)
    end)
end)

local function CopyClip(txt)
    pcall(function()
        if setclipboard then
            setclipboard(tostring(txt))
        end
    end)
end

local function SendNotif(title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 4
        })
    end)
    CopyClip(string.format("[%s] %s", title, text))
end

local iconPath = "ErdevaHubIconV2.png"
pcall(function()
    if isfile(iconPath) then delfile(iconPath) end
    writefile(iconPath, game:HttpGet("https://raw.githubusercontent.com/grava8593-hub/icon/main/erdeva.png"))
end)
local hubCustomIcon = isfile(iconPath) and getcustomasset(iconPath) or "rbxassetid://6031075931"

local discordIconPath = "ErdevaDiscordIcon.png"
pcall(function()
    if isfile(discordIconPath) then delfile(discordIconPath) end
    writefile(discordIconPath, game:HttpGet("https://raw.githubusercontent.com/grava8593-hub/icon/main/dcicon.png"))
end)
local discordCustomIcon = isfile(discordIconPath) and getcustomasset(discordIconPath) or ""

local Remotes = RS:WaitForChild("Remotes", 10)
local GameRemotes = Remotes and Remotes:FindFirstChild("Game")
local ReusableRemotes = Remotes and Remotes:FindFirstChild("Reusable")
local PlotRemotes = GameRemotes and GameRemotes:FindFirstChild("Plot")

local EggPickupRemote     = GameRemotes and GameRemotes:FindFirstChild("EggPickup")
local EggArrivalClaimRem  = GameRemotes and GameRemotes:FindFirstChild("EggArrivalClaim")
local EggPlacedRemote     = GameRemotes and GameRemotes:FindFirstChild("EggPlaced")
local RequestPlotEggsRem  = GameRemotes and GameRemotes:FindFirstChild("RequestPlotEggs")
local BasketDropRemote    = GameRemotes and GameRemotes:FindFirstChild("BasketDrop")
local EggBrokeRemote      = GameRemotes and GameRemotes:FindFirstChild("EggBroke")

pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if (method == "FireServer" or method == "InvokeServer") and typeof(self) == "Instance" then
            if self == EggBrokeRemote or string.lower(self.Name) == "eggbroke" then
                return nil
            end
        end
        return oldNamecall(self, ...)
    end))
end)

local AllEggList = {
    {name = "Volcanic Egg", tier = "Godly"},
    {name = "Blackhole Egg", tier = "Godly"},
    {name = "Bloom Egg", tier = "Godly"},
    {name = "Solaris Egg", tier = "Godly"},
    {name = "Galaxy Egg", tier = "Legendary"},
    {name = "Aurora Egg", tier = "Godly"},
    {name = "Asteroid Egg", tier = "Godly"},
    {name = "Devil Fruit Egg", tier = "Godly"},
    {name = "Dragon Egg", tier = "Godly"},
    {name = "Admin Egg", tier = "Godly"},
    {name = "Cherub Egg", tier = "Godly"},
    {name = "Dominus Egg", tier = "Legendary"},
    {name = "Sinister Egg", tier = "Legendary"},
    {name = "Soul Egg", tier = "Legendary"},
    {name = "Diamond Egg", tier = "Legendary"},
    {name = "Flaming Egg", tier = "Legendary"},
    {name = "Crystal Egg", tier = "Epic"},
    {name = "Tropical Egg", tier = "Epic"},
    {name = "Tidal Egg", tier = "Epic"},
    {name = "Giant Egg", tier = "Epic"},
    {name = "Easter Egg", tier = "Epic"},
    {name = "Mushroom Egg", tier = "Epic"},
    {name = "Golden Egg", tier = "Rare"},
    {name = "Cracked Egg", tier = "Rare"},
    {name = "Glass Egg", tier = "Rare"},
    {name = "Ice Egg", tier = "Rare"},
    {name = "Skull Egg", tier = "Rare"},
    {name = "Slime Egg", tier = "Rare"},
    {name = "Stone Egg", tier = "Uncommon"},
    {name = "Flower Egg", tier = "Uncommon"},
    {name = "Leaf Egg", tier = "Uncommon"},
    {name = "Brown Egg", tier = "Uncommon"},
    {name = "White Egg", tier = "Common"}
}

local TierPriority = {
    ["Godly"]     = 6,
    ["Legendary"] = 5,
    ["Epic"]      = 4,
    ["Rare"]      = 3,
    ["Uncommon"]  = 2,
    ["Common"]    = 1
}

local TierColors = {
    ["Godly"]     = Color3.fromRGB(255, 60, 95),
    ["Legendary"] = Color3.fromRGB(255, 175, 45),
    ["Epic"]      = Color3.fromRGB(195, 75, 255),
    ["Rare"]      = Color3.fromRGB(65, 170, 255),
    ["Uncommon"]  = Color3.fromRGB(65, 220, 125),
    ["Common"]    = Color3.fromRGB(180, 180, 185)
}

local IgnoredEggs = {}
local EggScanCache = {}
local LastEggScan = 0
local EggScanDelay = 0.8
local UpdateMonitorUI = function() end

local LastPickupPos = nil
local LastPickupTime = 0

local State = {
    MasterFarm   = false,
    InstantFarm  = false,
    FarmMode     = "Full Sequence",
    EggCount     = 0,
    Status       = "Idle",
    TargetName   = "None",
    TargetRarity = "None",
    AutoDeploy   = false,
    AutoCollect  = false,
    AutoFeed     = false,
    AutoHatch    = false,
    AutoUpgrade  = false,
    EggESP       = false,
    Flying       = false,
    FlySpeed     = 75,
    ReturnSpeed  = 500,
    WalkSpeed    = 16,
    JumpPower    = 50,
    BaseCFrame   = nil,
    PlotObject   = nil,
    Running      = true,
    SelectedEggs = {}
}

for _, item in ipairs(AllEggList) do
    State.SelectedEggs[item.name] = false
end

local function SafeFire(remote, ...)
    if remote then
        pcall(function(...) remote:FireServer(...) end, ...)
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

local function TriggerPromptInstant(prompt)
    if not prompt or not prompt:IsA("ProximityPrompt") then return end
    pcall(function()
        prompt.MaxActivationDistance = 999
        if fireproximityprompt then
            fireproximityprompt(prompt)
            return
        end
        if prompt.InputHoldBegin and prompt.InputHoldEnd then
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration + 0.15)
            prompt:InputHoldEnd()
        end
    end)
end

local function ClickOrActivateEgg()
    local char = LP.Character
    if not char then return end

    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            pcall(function() tool:Activate() end)
        end
    end

    pcall(function()
        VirtualUser:CaptureController()
        local cam = Workspace.CurrentCamera
        local center = cam and Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2) or Vector2.zero
        VirtualUser:ClickButton1(center)
    end)

    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("ProximityPrompt") then
            TriggerPromptInstant(p)
        end
    end
end

local function IsCarryingEgg()
    local char = LP.Character
    if not char then return false end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and string.find(string.lower(tool.Name), "egg") then
            return true
        end
    end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Model") and item ~= char then
            local n = string.lower(item.Name)
            if string.find(n, "egg") and not string.find(n, "pet") and not string.find(n, "mount") and not string.find(n, "nest") then
                return true
            end
        end
    end
    return false
end

local function IsEggSelected(objName)
    local lowerName = string.lower(objName)
    for _, item in ipairs(AllEggList) do
        if State.SelectedEggs[item.name] == true then
            local eggLower = string.lower(item.name)
            local eggBase = string.gsub(eggLower, "%s*egg$", "")
            if string.find(lowerName, eggLower, 1, true) or string.find(lowerName, eggBase, 1, true) then
                return true, item.name, item.tier
            end
        end
    end
    return false, nil, nil
end

local function HasAnyEggSelected()
    for _, active in pairs(State.SelectedEggs) do
        if active == true then return true end
    end
    return false
end

local function FindMyPlot()
    local plots = Workspace:FindFirstChild("Plots") or Workspace:FindFirstChild("PlayerPlots")
    if plots then
        for _, pl in ipairs(plots:GetChildren()) do
            local owner = pl:FindFirstChild("Owner") or pl:FindFirstChild("Player")
            if (owner and owner.Value == LP) or string.find(string.lower(pl.Name), string.lower(LP.Name)) then
                State.PlotObject = pl
                local nest = pl:FindFirstChild("Nests") or pl:FindFirstChild("Nest") or pl:FindFirstChild("Plant1") or pl:FindFirstChildWhichIsA("BasePart")
                if nest then
                    local part = nest:IsA("BasePart") and nest or nest:FindFirstChildWhichIsA("BasePart")
                    if part then return part.CFrame + Vector3.new(0, 1.5, 0) end
                end
                return pl:GetPivot() + Vector3.new(0, 1.5, 0)
            end
        end
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("TextLabel") or obj:IsA("SurfaceGui") then
            local txt = obj:IsA("TextLabel") and obj.Text or (obj:FindFirstChildWhichIsA("TextLabel") and obj:FindFirstChildWhichIsA("TextLabel").Text or "")
            if string.find(string.lower(txt), string.lower(LP.Name)) and string.find(string.lower(txt), "plot") then
                local p = obj:FindFirstAncestorWhichIsA("Model") or obj:FindFirstAncestorWhichIsA("BasePart")
                if p then
                    State.PlotObject = p
                    return p:GetPivot() + Vector3.new(0, 1.5, 0)
                end
            end
        end
    end
    local sp = Workspace:FindFirstChildOfClass("SpawnLocation")
    if sp then return sp.CFrame + Vector3.new(0, 3, 0) end
    local root = GetRoot()
    return root and root.CFrame or CFrame.new(0, 10, 0)
end

task.spawn(function()
    task.wait(0.5)
    State.BaseCFrame = FindMyPlot()
end)

local function GetEggUUID(eggObj)
    if not eggObj then return nil end
    if string.find(eggObj.Name, "%x%x%x%x%x%x%x%x%-%x%x%x%x") then
        return eggObj.Name
    end
    for attName, attVal in pairs(eggObj:GetAttributes()) do
        if type(attVal) == "string" and string.find(attVal, "%x%x%x%x%x%x%x%x%-%x%x%x%x") then
            return attVal
        end
    end
    for _, child in ipairs(eggObj:GetChildren()) do
        if child:IsA("StringValue") and string.find(child.Value, "%x%x%x%x%x%x%x%x%-%x%x%x%x") then
            return child.Value
        end
        if string.find(child.Name, "%x%x%x%x%x%x%x%x%-%x%x%x%x") then
            return child.Name
        end
    end
    return nil
end

local function SnapToTarget(targetPos)
    local root = GetRoot()
    if not root then return end
    root.CFrame = CFrame.new(targetPos + Vector3.new(0, 2.5, 0))
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.05)
end

local function TweenRootTo(targetCFrame, speed)
    local root = GetRoot()
    local hum = GetHum()
    if not root then return false end

    local distance = (root.Position - targetCFrame.Position).Magnitude
    local duration = math.clamp(distance / math.max(speed or State.ReturnSpeed, 50), 0.1, 12)

    if hum then hum.PlatformStand = true end
    root.Anchored = true
    local tween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
    tween:Play()
    tween.Completed:Wait()
    root.Anchored = false
    if hum then hum.PlatformStand = false end
    root.AssemblyLinearVelocity = Vector3.zero
    return true
end

local function EnterVolcano()
    local root = GetRoot()
    local volcano = Workspace:FindFirstChild("Volcano")
    local entrance = volcano and volcano:FindFirstChild("VolcanoEntrance")
    local validate = volcano and volcano:FindFirstChild("VolcanoValidate")
    if not root or not entrance or not validate or not entrance:IsA("BasePart") or not validate:IsA("BasePart") then
        return false
    end

    if (root.Position - validate.Position).Magnitude <= 18 then
        return true
    end

    State.Status = "Entering Volcano..."
    UpdateMonitorUI()
    if not TweenRootTo(entrance.CFrame + Vector3.new(0, 2.5, 0), State.ReturnSpeed) then
        return false
    end

    root = GetRoot()
    if not root then return false end
    root.Anchored = true
    root.AssemblyLinearVelocity = Vector3.zero
    if firetouchinterest then
        pcall(function()
            firetouchinterest(root, entrance, 0)
            task.wait(0.2)
            firetouchinterest(root, entrance, 1)
        end)
    end
    task.wait(0.25)
    root = GetRoot()
    if root then
        root.Anchored = false
        root.AssemblyLinearVelocity = Vector3.zero
    end

    local started = os.clock()
    while os.clock() - started < 4 do
        root = GetRoot()
        if root and (root.Position - validate.Position).Magnitude <= 18 then
            return true
        end
        task.wait(0.1)
    end
    return false
end

local function ExitVolcanoToPlot()
    local root = GetRoot()
    local volcano = Workspace:FindFirstChild("Volcano")
    local entrance = volcano and volcano:FindFirstChild("VolcanoEntrance")
    local validate = volcano and volcano:FindFirstChild("VolcanoValidate")
    if not root or not entrance or not entrance:IsA("BasePart") then return false end

    State.Status = "Leaving Volcano..."
    UpdateMonitorUI()
    root.CFrame = entrance.CFrame + Vector3.new(0, 2.5, 0)
    root.AssemblyLinearVelocity = Vector3.zero
    root.Anchored = true
    if firetouchinterest then
        pcall(function()
            firetouchinterest(root, entrance, 0)
            task.wait(0.2)
            firetouchinterest(root, entrance, 1)
        end)
    end
    task.wait(0.25)
    root = GetRoot()
    if root then
        root.Anchored = false
        root.AssemblyLinearVelocity = Vector3.zero
    end

    local started = os.clock()
    while validate and os.clock() - started < 2 do
        root = GetRoot()
        if root and (root.Position - validate.Position).Magnitude > 18 then break end
        task.wait(0.1)
    end

    root = GetRoot()
    local baseCFrame = State.BaseCFrame or FindMyPlot()
    if root and baseCFrame then
        root.CFrame = baseCFrame + Vector3.new(0, 2.5, 0)
        root.AssemblyLinearVelocity = Vector3.zero
    end
    return true
end

local function FindEggsInMap()
    local list = {}
    local scanNow = os.clock()

    if scanNow - LastEggScan < EggScanDelay then
        for _, egg in ipairs(EggScanCache) do
            if egg.Object
                and egg.Object:IsDescendantOf(Workspace)
                and not IgnoredEggs[egg.Object]
                and State.SelectedEggs[egg.Name] then
                table.insert(list, egg)
            end
        end
        return list
    end

    LastEggScan = scanNow
    local root = GetRoot()
    local myPos = root and root.Position or Vector3.zero

    local baseCFrame = State.BaseCFrame or FindMyPlot()
    local basePos = baseCFrame and baseCFrame.Position or Vector3.zero
    local myPlotObj = State.PlotObject

    local blacklist = {"tracker", "stand", "pedestal", "shop", "store", "display", "base", "nest", "plot", "buy", "sample", "plant", "incubator"}

    local now = os.clock()
    for k, expire in pairs(IgnoredEggs) do
        if now > expire then IgnoredEggs[k] = nil end
    end

    if not HasAnyEggSelected() then return list end

    for _, obj in ipairs(Workspace:GetDescendants()) do
        if not IgnoredEggs[obj] and (obj:IsA("Model") or (obj:IsA("BasePart") and not obj.Parent:IsA("Model"))) then
            
            local inAnyPlot = obj:FindFirstAncestor("Plots") or obj:FindFirstAncestor("PlayerPlots")
            if myPlotObj and obj:IsDescendantOf(myPlotObj) then
                inAnyPlot = true
            end

            local isBlack = false
            local ancestor = obj
            while ancestor and ancestor ~= Workspace do
                local aName = string.lower(ancestor.Name)
                for _, word in ipairs(blacklist) do
                    if string.find(aName, word) then
                        isBlack = true
                        break
                    end
                end
                if isBlack then break end
                ancestor = ancestor.Parent
            end

            if not inAnyPlot and not isBlack and not obj:IsDescendantOf(LP.Character) then
                local selected, eggName, eggTier = IsEggSelected(obj.Name)
                if selected then
                    local p = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart")
                    if p and p.Transparency < 0.9 and not IgnoredEggs[p] then
                        
                        local distToBase = (p.Position - basePos).Magnitude
                        if distToBase > 120 then
                            local dist = (myPos - p.Position).Magnitude
                            local tierVal = TierPriority[eggTier] or 1
                            table.insert(list, {
                                Object    = obj,
                                Part      = p,
                                Name      = eggName,
                                Tier      = eggTier,
                                Priority  = tierVal,
                                Distance  = dist,
                                UUID      = GetEggUUID(obj)
                            })
                        end
                    end
                end
            end
        end
    end

    table.sort(list, function(a, b)
        if a.Priority ~= b.Priority then return a.Priority > b.Priority end
        return a.Distance < b.Distance
    end)

    EggScanCache = list
    return list
end

local function CollectEggAtCurrentPosition(egg, timeout, allowObjectGone)
    local root = GetRoot()
    if not root or not egg or not egg.Part then return false end

    for _, prompt in ipairs(egg.Object:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            TriggerPromptInstant(prompt)
        end
    end

    if firetouchinterest and root and egg.Part then
        pcall(function()
            firetouchinterest(root, egg.Part, 0)
            firetouchinterest(root, egg.Part, 1)
        end)
    end

    local uuid = egg.UUID or GetEggUUID(egg.Object)
    if EggPickupRemote then
        if uuid then
            SafeFire(EggPickupRemote, uuid)
        end
    end

    ClickOrActivateEgg()

    local startWait = os.clock()
    while os.clock() - startWait < timeout do
        if IsCarryingEgg() or not egg.Object:IsDescendantOf(Workspace) or (egg.Part and egg.Part.Transparency >= 0.9) then
            LastPickupPos = egg.Part.Position
            LastPickupTime = os.clock()
            ClickOrActivateEgg()
            return true
        end
        task.wait(0.08)
    end

    if IsCarryingEgg() then
        LastPickupPos = egg.Part.Position
        LastPickupTime = os.clock()
        return true
    end

    return allowObjectGone and not egg.Object:IsDescendantOf(Workspace)
end

local function PerformInstantPickup(egg)
    local root = GetRoot()
    if not root or not egg or not egg.Part then return false end

    root.CFrame = CFrame.new(egg.Part.Position + Vector3.new(0, 2.5, 0))
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.08)

    if CollectEggAtCurrentPosition(egg, 0.8, true) then
        return true
    end

    root = GetRoot()
    if not root or not egg.Part or not egg.Part.Parent then return false end
    root.CFrame = CFrame.new(egg.Part.Position + Vector3.new(0, 2.5, 0))
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.1)
    return CollectEggAtCurrentPosition(egg, 0.8, true)
end

local function PerformVolcanicPickup(egg, instant)
    if not EnterVolcano() then return false end

    State.Status = "Teleporting to Volcanic Egg..."
    UpdateMonitorUI()
    local success = PerformInstantPickup(egg)
    if success or IsCarryingEgg() then
        ExitVolcanoToPlot()
    end
    return success
end

local function DeliverSafelyAtPlot(basePos)
    local root = GetRoot()
    if not root then return end

    local dist = 3000
    if LastPickupPos then
        dist = math.max((basePos - LastPickupPos).Magnitude, 500)
    end

    local safeDuration = math.clamp(dist / 80, 5, 85)
    local elapsed = os.clock() - (LastPickupTime > 0 and LastPickupTime or (os.clock() - 1))
    local remaining = safeDuration - elapsed

    root.Anchored = true
    root.AssemblyLinearVelocity = Vector3.zero

    while remaining > 0 do
        State.Status = string.format("Plot Wait: %ds", math.ceil(remaining))
        UpdateMonitorUI()
        local step = math.min(remaining, 0.5)
        task.wait(step)
        remaining = remaining - step
        root = GetRoot()
        if root then root.Anchored = true end
    end

    root = GetRoot()
    if root then
        root.Anchored = false
        root.AssemblyLinearVelocity = Vector3.zero
    end

    State.Status = "Storing & Claiming..."
    UpdateMonitorUI()

    if EggArrivalClaimRem then
        local safeStart = os.time() - math.ceil(safeDuration)
        SafeFire(EggArrivalClaimRem, safeStart, basePos.X, basePos.Y, basePos.Z, {})
    end
    task.wait(0.08)

    if RequestPlotEggsRem then
        SafeFire(RequestPlotEggsRem, false)
    end
    task.wait(0.08)

    if EggPlacedRemote then
        SafeFire(EggPlacedRemote, {})
    end
    if BasketDropRemote then
        SafeFire(BasketDropRemote)
    end

    local plotObj = State.PlotObject or FindMyPlot()
    if plotObj and typeof(plotObj) == "Instance" then
        for _, prompt in ipairs(plotObj:GetDescendants()) do
            if prompt:IsA("ProximityPrompt") then
                TriggerPromptInstant(prompt)
            end
        end
    end

    ClickOrActivateEgg()
    task.wait(0.08)

    local hum = GetHum()
    if hum then
        pcall(function() hum:UnequipTools() end)
    end

    pcall(function()
        for _, g in ipairs(PlayerGui:GetDescendants()) do
            if (g:IsA("TextButton") or g:IsA("ImageButton")) and g.Visible then
                local txt = string.lower(g:IsA("TextButton") and g.Text or g.Name)
                if string.find(txt, "drop") or string.find(txt, "store") or string.find(txt, "place") or string.find(txt, "bag") then
                    if g.MouseButton1Click then
                        for _, c in ipairs(getconnections(g.MouseButton1Click)) do c:Fire() end
                    end
                end
            end
        end
    end)

    task.wait(0.2)
end

local function PerformInstantDelivery()
    local root = GetRoot()
    if not root then return end

    local baseCFrame = State.BaseCFrame or FindMyPlot()
    local basePos = baseCFrame and baseCFrame.Position or root.Position

    root.CFrame = CFrame.new(basePos + Vector3.new(0, 2.5, 0))
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.08)

    DeliverSafelyAtPlot(basePos)
end

local espFolder = nil
local function UpdateESP(enable)
    if espFolder then espFolder:Destroy(); espFolder = nil end
    if not enable or not State.Running then return end
    espFolder = Instance.new("Folder")
    espFolder.Name = "ErdevaEggESP"
    espFolder.Parent = Workspace
    for _, item in ipairs(FindEggsInMap()) do
        local p = item.Part
        if p and p.Parent then
            local hl = Instance.new("Highlight")
            hl.Adornee = item.Object
            hl.FillColor = TierColors[item.Tier] or Color3.fromRGB(235, 30, 48)
            hl.FillTransparency = 0.5
            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.OutlineTransparency = 0.1
            hl.Parent = espFolder
            local bb = Instance.new("BillboardGui")
            bb.Adornee = p
            bb.Size = UDim2.fromOffset(130, 36)
            bb.AlwaysOnTop = true
            bb.Parent = espFolder
            local lbl = Instance.new("TextLabel")
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = item.Name .. " [" .. item.Tier .. "]"
            lbl.TextColor3 = TierColors[item.Tier] or Color3.fromRGB(255, 75, 95)
            lbl.TextStrokeColor3 = Color3.fromRGB(25, 5, 8)
            lbl.TextStrokeTransparency = 0.2
            lbl.Font = Enum.Font.GothamBold
            lbl.TextSize = 11
            lbl.Parent = bb
        end
    end
end

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

local Clr = {
    MainBg     = Color3.fromRGB(13, 13, 16),
    Sidebar    = Color3.fromRGB(19, 15, 18),
    Card       = Color3.fromRGB(25, 20, 23),
    CardBorder = Color3.fromRGB(83, 38, 50),
    RedAccent  = Color3.fromRGB(220, 20, 60),
    RedDark    = Color3.fromRGB(116, 18, 39),
    RedGlow    = Color3.fromRGB(247, 82, 108),
    TextMain   = Color3.fromRGB(244, 239, 241),
    TextDim    = Color3.fromRGB(170, 153, 158),
    ToggleOff  = Color3.fromRGB(50, 41, 45),
    Discord    = Color3.fromRGB(88, 101, 242),
    DiscordDark= Color3.fromRGB(60, 70, 180)
}

local SG = Instance.new("ScreenGui")
SG.Name = "ErdevaRideAPet"
SG.ResetOnSpawn = false
SG.IgnoreGuiInset = true
SG.Parent = targetParent

local FloatBtn = Instance.new("ImageButton")
FloatBtn.Size = UDim2.fromOffset(46, 46)
FloatBtn.Position = UDim2.new(0, 18, 0.35, 0)
FloatBtn.BackgroundColor3 = Clr.Card
FloatBtn.Image = hubCustomIcon
FloatBtn.BorderSizePixel = 0
FloatBtn.Active = true
FloatBtn.Visible = false
FloatBtn.Parent = SG
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(1, 0)

local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Size = UDim2.fromOffset(460, 285)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.BackgroundColor3 = Clr.MainBg
Main.BorderSizePixel = 0
Main.ClipsDescendants = false
Main.Active = true
Main.Parent = SG
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Clr.CardBorder
MainStroke.Thickness = 1.6
MainStroke.Parent = Main

local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 17, 20)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(11, 11, 14))
})
MainGradient.Rotation = 90
MainGradient.Parent = Main

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
        local targetPos = UDim2.new(fStartPos.X.Scale, fStartPos.X.Offset + delta.X, fStartPos.Y.Scale, fStartPos.Y.Offset + delta.Y)
        TweenService:Create(FloatBtn, TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetPos}):Play()
    end
end)

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 108, 1, -48)
Sidebar.Position = UDim2.fromOffset(6, 42)
Sidebar.BackgroundColor3 = Clr.Sidebar
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Main
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 12)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, -120, 0, 42)
Header.BackgroundTransparency = 1
Header.Parent = Main

local CustomLogo = Instance.new("ImageLabel")
CustomLogo.Size = UDim2.fromOffset(25, 25)
CustomLogo.Position = UDim2.fromOffset(12, 8)
CustomLogo.BackgroundTransparency = 1
CustomLogo.Image = hubCustomIcon
CustomLogo.Parent = Header
Instance.new("UICorner", CustomLogo).CornerRadius = UDim.new(0, 6)

local GameTitle = Instance.new("TextLabel")
GameTitle.Size = UDim2.new(0, 155, 0, 16)
GameTitle.Position = UDim2.fromOffset(45, 7)
GameTitle.BackgroundTransparency = 1
GameTitle.Text = "ERDEVA HUB"
GameTitle.TextColor3 = Clr.TextMain
GameTitle.Font = Enum.Font.GothamBold
GameTitle.TextSize = 11.5
GameTitle.TextXAlignment = Enum.TextXAlignment.Left
GameTitle.Parent = Header

local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(0, 155, 0, 14)
SubTitle.Position = UDim2.fromOffset(45, 22)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "Ride A Pet"
SubTitle.TextColor3 = Clr.RedGlow
SubTitle.Font = Enum.Font.GothamMedium
SubTitle.TextSize = 8.5
SubTitle.TextXAlignment = Enum.TextXAlignment.Left
SubTitle.Parent = Header

local TabContainer = Instance.new("ScrollingFrame")
TabContainer.Size = UDim2.new(1, -10, 1, -10)
TabContainer.Position = UDim2.fromOffset(6, 5)
TabContainer.BackgroundTransparency = 1
TabContainer.BorderSizePixel = 0
TabContainer.ScrollBarThickness = 0
TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
TabContainer.CanvasSize = UDim2.new()
TabContainer.Parent = Sidebar

local TabList = Instance.new("UIListLayout")
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.FillDirection = Enum.FillDirection.Vertical
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.Padding = UDim.new(0, 4)
TabList.Parent = TabContainer

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -122, 1, -46)
ContentArea.Position = UDim2.fromOffset(116, 46)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent = Main

local Topbar = Instance.new("Frame")
Topbar.Size = UDim2.new(1, 0, 1, 0)
Topbar.BackgroundTransparency = 1
Topbar.Active = true
Topbar.Parent = Header

local function DestroyAll()
    State.Running = false
    State.MasterFarm = false
    State.InstantFarm = false
    State.AutoDeploy = false
    State.AutoCollect = false
    State.AutoFeed = false
    State.AutoHatch = false
    State.AutoUpgrade = false
    State.EggESP = false
    ToggleFly(false)
    UpdateESP(false)
    SG:Destroy()
end

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.fromOffset(20, 20)
CloseBtn.Position = UDim2.new(1, -30, 0, 11)
CloseBtn.BackgroundColor3 = Color3.fromRGB(48, 22, 29)
CloseBtn.Text = "x"
CloseBtn.TextColor3 = Clr.RedGlow
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 10
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Main
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 5)
CloseBtn.MouseButton1Click:Connect(DestroyAll)

local MinMainBtn = Instance.new("TextButton")
MinMainBtn.Size = UDim2.fromOffset(20, 20)
MinMainBtn.Position = UDim2.new(1, -56, 0, 11)
MinMainBtn.BackgroundColor3 = Clr.Card
MinMainBtn.Text = "-"
MinMainBtn.TextColor3 = Clr.TextDim
MinMainBtn.Font = Enum.Font.GothamBold
MinMainBtn.TextSize = 12
MinMainBtn.BorderSizePixel = 0
MinMainBtn.Parent = Main
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
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.Position = UDim2.new()
    btn.BackgroundColor3 = Color3.fromRGB(48, 23, 31)
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.BorderSizePixel = 0
    btn.LayoutOrder = order
    btn.Parent = TabContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    local barIndicator = Instance.new("Frame")
    barIndicator.Size = UDim2.new(0, 3, 0, 16)
    barIndicator.Position = UDim2.new(0, 2, 0.5, -8)
    barIndicator.BackgroundColor3 = Clr.RedAccent
    barIndicator.BorderSizePixel = 0
    barIndicator.Visible = false
    barIndicator.Parent = btn
    Instance.new("UICorner", barIndicator).CornerRadius = UDim.new(1, 0)

    local icon = Instance.new("ImageLabel")
    icon.Size = UDim2.fromOffset(14, 14)
    icon.Position = UDim2.fromOffset(9, 7)
    icon.BackgroundTransparency = 1
    icon.Image = "rbxassetid://" .. tostring(assetId)
    icon.ImageColor3 = Clr.TextDim
    icon.Parent = btn

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -35, 1, 0)
    titleLbl.Position = UDim2.fromOffset(31, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = name
    titleLbl.TextColor3 = Clr.TextDim
    titleLbl.Font = Enum.Font.GothamMedium
    titleLbl.TextSize = 8
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.Parent = btn

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, -14, 1, -10)
    page.Position = UDim2.fromOffset(7, 5)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2.5
    page.ScrollBarImageColor3 = Clr.RedAccent
    page.ScrollBarImageTransparency = 0.3
    page.Visible = false
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
                BackgroundColor3 = isSel and Color3.fromRGB(61, 25, 35) or Color3.fromRGB(48, 23, 31)
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
    str.Transparency = 0.38
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
        TweenService:Create(btn, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = state and Clr.RedAccent or Clr.ToggleOff}):Play()
        TweenService:Create(dot, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)}):Play()
        callback(state)
    end)
    return card
end

local ModalOverlay = Instance.new("Frame")
ModalOverlay.Size = UDim2.new(1, 0, 1, 0)
ModalOverlay.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
ModalOverlay.BackgroundTransparency = 0.4
ModalOverlay.Visible = false
ModalOverlay.ZIndex = 50
ModalOverlay.Parent = Main

local OverlayBackdropBtn = Instance.new("TextButton")
OverlayBackdropBtn.Size = UDim2.new(1, 0, 1, 0)
OverlayBackdropBtn.BackgroundTransparency = 1
OverlayBackdropBtn.Text = ""
OverlayBackdropBtn.ZIndex = 50
OverlayBackdropBtn.Parent = ModalOverlay
OverlayBackdropBtn.MouseButton1Click:Connect(function() ModalOverlay.Visible = false end)

local ModalBox = Instance.new("Frame")
ModalBox.Size = UDim2.fromOffset(250, 230)
ModalBox.AnchorPoint = Vector2.new(0.5, 0.5)
ModalBox.Position = UDim2.new(0.5, 0, 0.5, 0)
ModalBox.BackgroundColor3 = Clr.Card
ModalBox.BorderSizePixel = 0
ModalBox.ZIndex = 51
ModalBox.Parent = ModalOverlay
Instance.new("UICorner", ModalBox).CornerRadius = UDim.new(0, 8)

local modalStroke = Instance.new("UIStroke")
modalStroke.Color = Clr.RedAccent
modalStroke.Thickness = 1.2
modalStroke.Transparency = 0.25
modalStroke.Parent = ModalBox

local ModalTitle = Instance.new("TextLabel")
ModalTitle.Size = UDim2.new(1, -70, 0, 24)
ModalTitle.Position = UDim2.fromOffset(10, 4)
ModalTitle.BackgroundTransparency = 1
ModalTitle.Text = "SELECT TARGET EGGS"
ModalTitle.TextColor3 = Clr.RedGlow
ModalTitle.Font = Enum.Font.GothamBold
ModalTitle.TextSize = 11
ModalTitle.TextXAlignment = Enum.TextXAlignment.Left
ModalTitle.ZIndex = 55
ModalTitle.Parent = ModalBox

local ModalCloseBtn = Instance.new("TextButton")
ModalCloseBtn.Size = UDim2.fromOffset(18, 18)
ModalCloseBtn.Position = UDim2.new(1, -30, 0, 4)
ModalCloseBtn.BackgroundColor3 = Color3.fromRGB(43, 24, 31)
ModalCloseBtn.Text = "X"
ModalCloseBtn.TextColor3 = Color3.new(1, 1, 1)
ModalCloseBtn.Font = Enum.Font.GothamBold
ModalCloseBtn.TextSize = 13
ModalCloseBtn.BorderSizePixel = 0
ModalCloseBtn.ZIndex = 65
ModalCloseBtn.Parent = ModalBox
Instance.new("UICorner", ModalCloseBtn).CornerRadius = UDim.new(0, 6)
ModalCloseBtn.MouseButton1Click:Connect(function() ModalOverlay.Visible = false end)

local QuickRow = Instance.new("Frame")
QuickRow.Size = UDim2.new(1, -16, 0, 20)
QuickRow.Position = UDim2.fromOffset(8, 28)
QuickRow.BackgroundTransparency = 1
QuickRow.ZIndex = 52
QuickRow.Parent = ModalBox

local BtnResetOff = Instance.new("TextButton")
BtnResetOff.Size = UDim2.new(0.48, 0, 1, 0)
BtnResetOff.BackgroundColor3 = Clr.Card
BtnResetOff.Text = "Reset All OFF"
BtnResetOff.TextColor3 = Clr.TextDim
BtnResetOff.Font = Enum.Font.GothamMedium
BtnResetOff.TextSize = 9
BtnResetOff.BorderSizePixel = 0
BtnResetOff.ZIndex = 53
BtnResetOff.Parent = QuickRow
Instance.new("UICorner", BtnResetOff).CornerRadius = UDim.new(0, 4)

local BtnAllGodly = Instance.new("TextButton")
BtnAllGodly.Size = UDim2.new(0.48, 0, 1, 0)
BtnAllGodly.Position = UDim2.new(0.52, 0, 0, 0)
BtnAllGodly.BackgroundColor3 = Color3.fromRGB(61, 25, 35)
BtnAllGodly.Text = "+ All Godly"
BtnAllGodly.TextColor3 = Clr.RedGlow
BtnAllGodly.Font = Enum.Font.GothamMedium
BtnAllGodly.TextSize = 9
BtnAllGodly.BorderSizePixel = 0
BtnAllGodly.ZIndex = 53
BtnAllGodly.Parent = QuickRow
Instance.new("UICorner", BtnAllGodly).CornerRadius = UDim.new(0, 4)

local ModalScroll = Instance.new("ScrollingFrame")
ModalScroll.Size = UDim2.new(1, -16, 1, -54)
ModalScroll.Position = UDim2.fromOffset(8, 50)
ModalScroll.BackgroundTransparency = 1
ModalScroll.BorderSizePixel = 0
ModalScroll.ScrollBarThickness = 2.5
ModalScroll.ScrollBarImageColor3 = Clr.RedAccent
ModalScroll.ZIndex = 52
ModalScroll.Parent = ModalBox

local modalLayout = Instance.new("UIListLayout")
modalLayout.SortOrder = Enum.SortOrder.LayoutOrder
modalLayout.Padding = UDim.new(0, 4)
modalLayout.Parent = ModalScroll
modalLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    ModalScroll.CanvasSize = UDim2.new(0, 0, 0, modalLayout.AbsoluteContentSize.Y + 10)
end)

local BtnEggTrigger = nil
local EggRowsUI = {}

local function UpdateEggButtonText()
    if not BtnEggTrigger then return end
    local count = 0
    local last = nil
    for _, item in ipairs(AllEggList) do
        if State.SelectedEggs[item.name] == true then
            count = count + 1
            last = item.name
        end
    end
    if count == 0 then
        BtnEggTrigger.Text = "None Selected"
        BtnEggTrigger.TextColor3 = Clr.TextDim
    elseif count == 1 then
        BtnEggTrigger.Text = last
        BtnEggTrigger.TextColor3 = Clr.RedGlow
    else
        BtnEggTrigger.Text = string.format("%d Eggs Selected", count)
        BtnEggTrigger.TextColor3 = Clr.RedGlow
    end
end

for idx, item in ipairs(AllEggList) do
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundColor3 = Color3.fromRGB(31, 23, 27)
    row.BorderSizePixel = 0
    row.Text = ""
    row.LayoutOrder = idx
    row.ZIndex = 53
    row.Parent = ModalScroll
    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 5)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -90, 1, 0)
    lbl.Position = UDim2.fromOffset(8, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = item.name
    lbl.TextColor3 = Clr.TextMain
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 9.5
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 54
    lbl.Parent = row

    local badge = Instance.new("TextLabel")
    badge.Size = UDim2.fromOffset(50, 16)
    badge.Position = UDim2.new(1, -82, 0.5, -8)
    badge.BackgroundTransparency = 1
    badge.Text = item.tier
    badge.TextColor3 = TierColors[item.tier] or Clr.TextDim
    badge.Font = Enum.Font.GothamBold
    badge.TextSize = 8.5
    badge.ZIndex = 54
    badge.Parent = row

    local chk = Instance.new("TextLabel")
    chk.Size = UDim2.fromOffset(26, 16)
    chk.Position = UDim2.new(1, -30, 0.5, -8)
    chk.BackgroundColor3 = Clr.ToggleOff
    chk.Text = "OFF"
    chk.TextColor3 = Clr.TextDim
    chk.Font = Enum.Font.GothamBold
    chk.TextSize = 8.5
    chk.BorderSizePixel = 0
    chk.ZIndex = 54
    chk.Parent = row
    Instance.new("UICorner", chk).CornerRadius = UDim.new(0, 4)

    EggRowsUI[item.name] = {Row = row, Chk = chk}

    row.MouseButton1Click:Connect(function()
        State.SelectedEggs[item.name] = not State.SelectedEggs[item.name]
        local on = State.SelectedEggs[item.name]
        chk.Text = on and "ON" or "OFF"
        chk.BackgroundColor3 = on and Clr.RedAccent or Clr.ToggleOff
        chk.TextColor3 = on and Color3.new(1, 1, 1) or Clr.TextDim
        UpdateEggButtonText()
        if State.EggESP then UpdateESP(true) end
    end)
end

BtnResetOff.MouseButton1Click:Connect(function()
    for _, item in ipairs(AllEggList) do
        State.SelectedEggs[item.name] = false
        local ui = EggRowsUI[item.name]
        if ui then
            ui.Chk.Text = "OFF"
            ui.Chk.BackgroundColor3 = Clr.ToggleOff
            ui.Chk.TextColor3 = Clr.TextDim
        end
    end
    UpdateEggButtonText()
    if State.EggESP then UpdateESP(true) end
end)

BtnAllGodly.MouseButton1Click:Connect(function()
    for _, item in ipairs(AllEggList) do
        if item.tier == "Godly" then
            State.SelectedEggs[item.name] = true
            local ui = EggRowsUI[item.name]
            if ui then
                ui.Chk.Text = "ON"
                ui.Chk.BackgroundColor3 = Clr.RedAccent
                ui.Chk.TextColor3 = Color3.new(1, 1, 1)
            end
        end
    end
    UpdateEggButtonText()
    if State.EggESP then UpdateESP(true) end
end)

local pHarvest   = CreateTab("Harvest",   10734965572, 1)
local pSanctuary = CreateTab("Plot",       6031265976, 2)
local pRadar     = CreateTab("Egg Radar",  6031763426, 3)
local pTeleport  = CreateTab("Teleport",   6031154871, 4)
local pMovement  = CreateTab("Movement",   6034287594, 5)
local pSystem    = CreateTab("System",     6031280882, 6)

Pages["Harvest"].Visible = true
TabButtons["Harvest"].Btn.BackgroundTransparency = 0
TabButtons["Harvest"].Btn.BackgroundColor3 = Color3.fromRGB(61, 25, 35)
TabButtons["Harvest"].Label.TextColor3 = Clr.TextMain
TabButtons["Harvest"].Icon.ImageColor3 = Clr.RedGlow
TabButtons["Harvest"].Bar.Visible = true

local MonitorCard = Instance.new("Frame")
MonitorCard.Size = UDim2.new(1, 0, 0, 68)
MonitorCard.BackgroundColor3 = Clr.Card
MonitorCard.BorderSizePixel = 0
MonitorCard.LayoutOrder = 1
MonitorCard.Parent = pHarvest
Instance.new("UICorner", MonitorCard).CornerRadius = UDim.new(0, 8)
local mStroke = Instance.new("UIStroke")
mStroke.Color = Clr.CardBorder
mStroke.Thickness = 1
mStroke.Transparency = 0.38
mStroke.Parent = MonitorCard

local MTitle = Instance.new("TextLabel")
MTitle.Size = UDim2.new(0.5, 0, 0, 16)
MTitle.Position = UDim2.fromOffset(10, 6)
MTitle.BackgroundTransparency = 1
MTitle.Text = "ENGINE MONITOR"
MTitle.TextColor3 = Clr.TextDim
MTitle.Font = Enum.Font.GothamBold
MTitle.TextSize = 9.5
MTitle.TextXAlignment = Enum.TextXAlignment.Left
MTitle.Parent = MonitorCard

local MStatus = Instance.new("TextLabel")
MStatus.Size = UDim2.fromOffset(120, 16)
MStatus.Position = UDim2.new(1, -130, 0, 6)
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
MTarget.Text = "Target: None [None]"
MTarget.TextColor3 = Clr.TextMain
MTarget.Font = Enum.Font.GothamMedium
MTarget.TextSize = 9.5
MTarget.TextXAlignment = Enum.TextXAlignment.Left
MTarget.Parent = MonitorCard

local MMeta = Instance.new("TextLabel")
MMeta.Size = UDim2.new(1, -20, 0, 14)
MMeta.Position = UDim2.fromOffset(10, 44)
MMeta.BackgroundTransparency = 1
MMeta.Text = "Harvested: 0 | Engine: Instant Catch (Safe Wait)"
MMeta.TextColor3 = Clr.RedGlow
MMeta.Font = Enum.Font.Gotham
MMeta.TextSize = 9
MMeta.TextXAlignment = Enum.TextXAlignment.Left
MMeta.Parent = MonitorCard

UpdateMonitorUI = function()
    MStatus.Text = "Status: " .. State.Status
    if State.Status == "Farming" or string.find(State.Status, "Taking") then
        MStatus.TextColor3 = Color3.fromRGB(255, 185, 80)
    elseif string.find(State.Status, "Base") or string.find(State.Status, "Wait") or string.find(State.Status, "Storing") then
        MStatus.TextColor3 = Color3.fromRGB(100, 210, 255)
    else
        MStatus.TextColor3 = Color3.fromRGB(130, 240, 160)
    end
    MTarget.Text = "Target: " .. State.TargetName .. " [" .. State.TargetRarity .. "]"
    MMeta.Text = string.format("Harvested: %d | Status: %s", State.EggCount, State.Status)
end

local function StartFarmLoop()
    if not State.BaseCFrame then
        State.BaseCFrame = FindMyPlot()
    end
    local deliveryAttempts = 0
    while (State.MasterFarm or State.InstantFarm) and State.Running do
        if not HasAnyEggSelected() then
            State.Status = "Select Eggs First!"
            State.TargetName = "None"
            State.TargetRarity = "None"
            UpdateMonitorUI()
            task.wait(0.5)
        else
            if IsCarryingEgg() then
                deliveryAttempts = deliveryAttempts + 1
                State.Status = "Delivering Held Egg..."
                UpdateMonitorUI()
                PerformInstantDelivery()
                task.wait(0.1)

                if deliveryAttempts >= 2 then
                    ClickOrActivateEgg()
                    local hum = GetHum()
                    if hum then hum:UnequipTools() end
                    deliveryAttempts = 0
                    task.wait(0.15)
                end
            else
                deliveryAttempts = 0
                local eggs = FindEggsInMap()
                if #eggs > 0 then
                    local egg = eggs[1]
                    State.Status = "Farming"
                    State.TargetName = egg.Name
                    State.TargetRarity = egg.Tier
                    UpdateMonitorUI()

                    State.Status = "Taking Egg..."
                    UpdateMonitorUI()

                    local success = egg.Name == "Volcanic Egg"
                        and PerformVolcanicPickup(egg, true)
                        or PerformInstantPickup(egg)

                    if success or IsCarryingEgg() then
                        State.Status = "Teleport to Plot..."
                        UpdateMonitorUI()

                        PerformInstantDelivery()

                        State.EggCount = State.EggCount + 1
                        SendNotif("SUKSES PANEN", string.format("Berhasil panen telur %s! Total: %d", egg.Name, State.EggCount))
                        IgnoredEggs[egg.Object] = os.clock() + 30
                        if egg.Part then IgnoredEggs[egg.Part] = os.clock() + 30 end
                    else
                        IgnoredEggs[egg.Object] = os.clock() + 4
                        if egg.Part then IgnoredEggs[egg.Part] = os.clock() + 4 end
                    end

                    task.wait(0.1)
                else
                    State.Status = "Scanning Eggs..."
                    State.TargetName = "None"
                    State.TargetRarity = "None"
                    UpdateMonitorUI()
                end
            end
        end
        task.wait(0.4)
    end
    State.Status = "Idle"
    State.TargetName = "None"
    State.TargetRarity = "None"
    UpdateMonitorUI()
end

MakeToggle(pHarvest, "Auto Farm", "Instant catch & smart plot delivery", false, 2, function(v)
    State.MasterFarm = v
    if v then
        State.InstantFarm = false
        State.Status = "Searching..."
        UpdateMonitorUI()
        task.spawn(StartFarmLoop)
    else
        State.Status = "Idle"
        State.TargetName = "None"
        State.TargetRarity = "None"
        UpdateMonitorUI()
    end
end)

MakeToggle(pHarvest, "Instant Farm", "Instant catch & smart plot delivery", false, 3, function(v)
    State.InstantFarm = v
    if v then
        State.MasterFarm = false
        State.Status = "Searching..."
        UpdateMonitorUI()
        task.spawn(StartFarmLoop)
    else
        State.Status = "Idle"
        State.TargetName = "None"
        State.TargetRarity = "None"
        UpdateMonitorUI()
    end
end)

local eggCard = MakeCard(pHarvest, "Target Egg Filter", "Select which eggs to collect", 4)
BtnEggTrigger = Instance.new("TextButton")
BtnEggTrigger.Size = UDim2.fromOffset(88, 22)
BtnEggTrigger.Position = UDim2.new(1, -96, 0.5, -11)
BtnEggTrigger.BackgroundColor3 = Color3.fromRGB(43, 24, 31)
BtnEggTrigger.BorderSizePixel = 0
BtnEggTrigger.Text = "None Selected"
BtnEggTrigger.TextColor3 = Clr.TextDim
BtnEggTrigger.Font = Enum.Font.GothamBold
BtnEggTrigger.TextSize = 9
BtnEggTrigger.Parent = eggCard
Instance.new("UICorner", BtnEggTrigger).CornerRadius = UDim.new(0, 5)
local rStroke = Instance.new("UIStroke")
rStroke.Color = Clr.CardBorder
rStroke.Thickness = 1
rStroke.Transparency = 0.4
rStroke.Parent = BtnEggTrigger
BtnEggTrigger.MouseButton1Click:Connect(function() ModalOverlay.Visible = true end)

MakeToggle(pSanctuary, "Auto Deploy All Eggs", "Automatically plants eggs", false, 1, function(v)
    State.AutoDeploy = v
    if v then
        task.spawn(function()
            while State.AutoDeploy and State.Running do
                local root = GetRoot()
                local hum = GetHum()
                local char = LP.Character
                local bp = LP:FindFirstChild("Backpack")

                if root and hum and char and bp then
                    local eggTool = nil
                    for _, item in ipairs(char:GetChildren()) do
                        if item:IsA("Tool") and string.find(string.lower(item.Name), "egg") then
                            eggTool = item
                            break
                        end
                    end
                    if not eggTool then
                        for _, item in ipairs(bp:GetChildren()) do
                            if item:IsA("Tool") and string.find(string.lower(item.Name), "egg") then
                                eggTool = item
                                break
                            end
                        end
                    end

                    if eggTool then
                        local baseCFrame = State.BaseCFrame or FindMyPlot()
                        local basePos = baseCFrame and baseCFrame.Position or root.Position
                        
                        if (root.Position - basePos).Magnitude > 100 then
                            root.CFrame = CFrame.new(basePos + Vector3.new(0, 2.5, 0))
                            task.wait(0.15)
                        end

                        if eggTool.Parent ~= char then
                            hum:EquipTool(eggTool)
                            task.wait(0.12)
                        end

                        pcall(function() eggTool:Activate() end)
                        
                        pcall(function()
                            VirtualUser:CaptureController()
                            local cam = Workspace.CurrentCamera
                            local center = cam and Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2) or Vector2.zero
                            VirtualUser:ClickButton1(center)
                        end)

                        if EggPlacedRemote then
                            SafeFire(EggPlacedRemote, {})
                        end

                        local plotObj = State.PlotObject or FindMyPlot()
                        if plotObj and typeof(plotObj) == "Instance" then
                            for _, prompt in ipairs(plotObj:GetDescendants()) do
                                if prompt:IsA("ProximityPrompt") and prompt.Enabled then
                                    local txt = string.lower(prompt.ActionText)
                                    if string.find(txt, "place") or string.find(txt, "plant") or string.find(txt, "tanam") then
                                        TriggerPromptInstant(prompt)
                                    end
                                end
                            end
                        end

                        task.wait(0.35)
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end)

MakeToggle(pSanctuary, "Auto Collect Cash / Drops", "Automatically collect pet drops and cash", false, 2, function(v)
    State.AutoCollect = v
    if v then
        task.spawn(function()
            while State.AutoCollect and State.Running do
                if GameRemotes then
                    local pc = GameRemotes:FindFirstChild("PetCollect") or GameRemotes:FindFirstChild("CollectCash") or GameRemotes:FindFirstChild("ClaimDrops")
                    if pc then SafeFire(pc) end
                end
                task.wait(1.2)
            end
        end)
    end
end)

MakeToggle(pSanctuary, "Auto Feed All Pets", "Feed all pets to level up faster", false, 3, function(v)
    State.AutoFeed = v
    if v then
        task.spawn(function()
            while State.AutoFeed and State.Running do
                if GameRemotes then
                    local fp = GameRemotes:FindFirstChild("FeedPet") or (PlotRemotes and PlotRemotes:FindFirstChild("FeedPet"))
                    if fp then SafeFire(fp) end
                end
                task.wait(2.2)
            end
        end)
    end
end)

MakeToggle(pSanctuary, "Auto Hatch Incubation", "Automatically hatch ready incubated eggs", false, 4, function(v)
    State.AutoHatch = v
    if v then
        task.spawn(function()
            while State.AutoHatch and State.Running do
                local h = GameRemotes and (GameRemotes:FindFirstChild("Hatch") or GameRemotes:FindFirstChild("HatchEgg") or GameRemotes:FindFirstChild("OpenEgg"))
                if h then
                    SafeFire(h)
                    SafeFire(h, "Plant1")
                    SafeFire(h, 1)
                end
                local searchTarget = State.PlotObject or Workspace
                for _, prompt in ipairs(searchTarget:GetDescendants()) do
                    if prompt:IsA("ProximityPrompt") then
                        local txt = string.lower(prompt.ActionText) .. " " .. string.lower(prompt.ObjectText)
                        if string.find(txt, "hatch") or string.find(txt, "open") or string.find(txt, "claim") then
                            TriggerPromptInstant(prompt)
                        end
                    end
                end
                task.wait(1.5)
            end
        end)
    end
end)

MakeToggle(pSanctuary, "Auto Upgrade Plot & Nests", "Upgrade plots and nests periodically", false, 5, function(v)
    State.AutoUpgrade = v
    if v then
        task.spawn(function()
            while State.AutoUpgrade and State.Running do
                if PlotRemotes then
                    local n = PlotRemotes:FindFirstChild("Nests")
                    local u = PlotRemotes:FindFirstChild("Upgrades")
                    if n then SafeFire(n) end
                    if u then SafeFire(u) end
                end
                task.wait(3.5)
            end
        end)
    end
end)

MakeToggle(pRadar, "Egg Radar (ESP)", "Highlight wild eggs on map with tags", false, 1, function(v)
    State.EggESP = v
    UpdateESP(v)
    if v then
        task.spawn(function()
            while State.EggESP and State.Running do
                task.wait(3.0)
                if State.EggESP and State.Running then UpdateESP(true) end
            end
        end)
    end
end)

MakeButton(pRadar, "Refresh Radar Scan", 2, function()
    if State.EggESP then UpdateESP(true) end
end)

MakeButton(pTeleport, "Teleport to My Plot", 1, function()
    if GameRemotes and GameRemotes:FindFirstChild("TeleportToPlot") then
        SafeFire(GameRemotes.TeleportToPlot)
    end
    local targetPos = State.BaseCFrame or FindMyPlot()
    local root = GetRoot()
    if root and targetPos then
        root.CFrame = targetPos + Vector3.new(0, 3, 0)
    end
end)

MakeToggle(pMovement, "FLY (PC - WASD ONLY)", "Fly freely in all directions", false, 1, function(v)
    ToggleFly(v)
end)

MakeSlider(pMovement, "Fly Speed", 20, 250, 75, 2, function(v) State.FlySpeed = v end)
MakeSlider(pMovement, "Walk Speed", 16, 200, 16, 3, function(v) 
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

local ProfileCard = Instance.new("Frame")
ProfileCard.Size = UDim2.new(1, 0, 0, 64)
ProfileCard.BackgroundColor3 = Clr.Card
ProfileCard.BorderSizePixel = 0
ProfileCard.LayoutOrder = 1
ProfileCard.Parent = pSystem
Instance.new("UICorner", ProfileCard).CornerRadius = UDim.new(0, 8)

local pStroke = Instance.new("UIStroke")
pStroke.Color = Clr.CardBorder
pStroke.Thickness = 1
pStroke.Transparency = 0.38
pStroke.Parent = ProfileCard

local AvatarImg = Instance.new("ImageLabel")
AvatarImg.Size = UDim2.fromOffset(46, 46)
AvatarImg.Position = UDim2.fromOffset(9, 9)
AvatarImg.BackgroundColor3 = Color3.fromRGB(32, 24, 28)
AvatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LP.UserId .. "&w=150&h=150"
AvatarImg.BorderSizePixel = 0
AvatarImg.Parent = ProfileCard
Instance.new("UICorner", AvatarImg).CornerRadius = UDim.new(1, 0)

local DisplayNameLbl = Instance.new("TextLabel")
DisplayNameLbl.Size = UDim2.new(1, -70, 0, 16)
DisplayNameLbl.Position = UDim2.fromOffset(64, 8)
DisplayNameLbl.BackgroundTransparency = 1
DisplayNameLbl.Text = LP.DisplayName
DisplayNameLbl.TextColor3 = Clr.TextMain
DisplayNameLbl.Font = Enum.Font.GothamBold
DisplayNameLbl.TextSize = 12
DisplayNameLbl.TextXAlignment = Enum.TextXAlignment.Left
DisplayNameLbl.Parent = ProfileCard

local UsernameLbl = Instance.new("TextLabel")
UsernameLbl.Size = UDim2.new(1, -70, 0, 14)
UsernameLbl.Position = UDim2.fromOffset(64, 24)
UsernameLbl.BackgroundTransparency = 1
UsernameLbl.Text = "@" .. LP.Name .. "  •  ID: " .. tostring(LP.UserId)
UsernameLbl.TextColor3 = Clr.TextDim
UsernameLbl.Font = Enum.Font.GothamMedium
UsernameLbl.TextSize = 9
UsernameLbl.TextXAlignment = Enum.TextXAlignment.Left
UsernameLbl.Parent = ProfileCard

local execName = (identifyexecutor and identifyexecutor()) or "Executor"
local UserMetaLbl = Instance.new("TextLabel")
UserMetaLbl.Size = UDim2.new(1, -70, 0, 14)
UserMetaLbl.Position = UDim2.fromOffset(64, 40)
UserMetaLbl.BackgroundTransparency = 1
UserMetaLbl.Text = "Account: " .. LP.AccountAge .. " Days  |  " .. execName
UserMetaLbl.TextColor3 = Clr.RedGlow
UserMetaLbl.Font = Enum.Font.Gotham
UserMetaLbl.TextSize = 8.5
UserMetaLbl.TextXAlignment = Enum.TextXAlignment.Left
UserMetaLbl.Parent = ProfileCard

MakeButton(pSystem, "Claim Free Server Gifts", 3, function()
    if ReusableRemotes then
        local cg = ReusableRemotes:FindFirstChild("ClaimGroupReward")
        local ce = ReusableRemotes:FindFirstChild("ClaimEventReward")
        local r = ReusableRemotes:FindFirstChild("Roulette")
        if cg then SafeFire(cg) end
        if ce then SafeFire(ce) end
        if r then SafeFire(r) end
    end
    if GameRemotes then
        local ci = GameRemotes:FindFirstChild("ClaimIndexReward")
        local oe = GameRemotes:FindFirstChild("OfflineEarnings")
        if ci then SafeFire(ci) end
        if oe then SafeFire(oe) end
    end
end)

MakeButton(pSystem, "Destroy GUI", 6, DestroyAll)

SendNotif("ERDEVA HUB", "Script Siap! Opsi 3 (Instant Catch + Smart Plot Wait) Aktif!")
