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

local iconPath = "ErdevaHubIcon.png"
if not isfile(iconPath) then
    pcall(function()
        writefile(iconPath, game:HttpGet("https://raw.githubusercontent.com/voxynoxy/ErdevaHub/main/icon.png"))
    end)
end
local hubCustomIcon = isfile(iconPath) and getcustomasset(iconPath) or "rbxassetid://6031075931"

local discordIconPath = "ErdevaDiscordIcon.png"

pcall(function()
    if isfile(discordIconPath) then
        delfile(discordIconPath)
    end

    writefile(
        discordIconPath,
        game:HttpGet("https://raw.githubusercontent.com/grava8593-hub/icon/main/dcicon.png")
    )
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
    {name = "Blackhole Egg", tier = "Godly"},
    {name = "Bloom Egg", tier = "Godly"},
    {name = "Volcanic Egg", tier = "Godly"},
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
local UpdateMonitorUI = function() end

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
    ReturnSpeed  = 250,
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
        if fireproximityprompt then fireproximityprompt(prompt) end
        if prompt.InputHoldBegin and prompt.InputHoldEnd then
            prompt:InputHoldBegin()
            task.wait(0.15)
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

local function GlideToBaseSafe(basePos)
    local root = GetRoot()
    local hum = GetHum()
    if not root then return end

    local startPos = root.Position
    local targetPos = basePos + Vector3.new(0, 2.5, 0)
    local dist = (startPos - targetPos).Magnitude

    local speed = math.max(State.ReturnSpeed or 250, 50)
    local totalTime = math.clamp(dist / speed, 0.1, 8.0)

    if hum then hum.PlatformStand = true end
    root.Anchored = true

    local startTime = os.clock()
    while os.clock() - startTime < totalTime do
        local alpha = math.clamp((os.clock() - startTime) / totalTime, 0, 1)
        root.CFrame = CFrame.new(startPos:Lerp(targetPos, alpha))
        task.wait(0.02)
    end

    root.CFrame = CFrame.new(targetPos)
    root.Anchored = false
    if hum then hum.PlatformStand = false end
    root.AssemblyLinearVelocity = Vector3.zero
    task.wait(0.05)
end

local function FindEggsInMap()
    local list = {}
    local root = GetRoot()
    local myPos = root and root.Position or Vector3.zero

    local baseCFrame = State.BaseCFrame or FindMyPlot()
    local basePos = baseCFrame and baseCFrame.Position or Vector3.zero
    local myPlotObj = State.PlotObject

    local blacklist =
