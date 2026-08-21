-- ====================================================================
-- AWhub - ok pls no steal
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

pcall(function()
    if setclipboard then
        setclipboard("https://discord.gg/ux2fjm2rt8")
    end
end)

local function getGuiParent()
    local success, gui = pcall(function()
        if gethui then
            return gethui()
        elseif syn and syn.protect_gui then
            local container = Instance.new("Folder")
            container.Name = "ProtectedGuiContainer"
            syn.protect_gui(container)
            container.Parent = CoreGui
            return container
        elseif CoreGui:FindFirstChild("RobloxGui") then
            return CoreGui
        end
        return LP:WaitForChild("PlayerGui", 5)
    end)
    if success and gui then return gui end
    return LP:FindFirstChild("PlayerGui") or CoreGui
end

-- ==================== WATERPROOF SYSTEM (NICOLAS) ====================
local table_insert = table.insert

local nicolas = {}
nicolas.__index = nicolas

function nicolas.new()
    return setmetatable({_tasks = {}, _destroyed = false}, nicolas)
end

function nicolas:GiveTask(task)
    if self._destroyed then
        self:_cleanupTask(task)
        return
    end
    table_insert(self._tasks, task)
    return task
end

function nicolas:GiveTasks(...)
    for _, task in ipairs({...}) do
        self:GiveTask(task)
    end
end

function nicolas:_cleanupTask(task)
    local taskType = typeof(task)
    if taskType == "RBXScriptConnection" then
        task:Disconnect()
    elseif taskType == "Instance" then
        task:Destroy()
    elseif taskType == "function" then
        task()
    elseif taskType == "table" and type(task.Destroy) == "function" then
        task:Destroy()
    end
end

function nicolas:DoCleaning()
    if self._destroyed then return end
    self._destroyed = true
    for _, task in ipairs(self._tasks) do
        self:_cleanupTask(task)
    end
    self._tasks = {}
end

function nicolas:Destroy()
    self:DoCleaning()
end

local waterMaid = nil
local modifiedParts = {}

local function DisableWaterPart(part)
    if part and part:IsA("BasePart") then
        if not modifiedParts[part] then
            modifiedParts[part] = {
                CanTouch = part.CanTouch,
                CanCollide = part.CanCollide,
            }
        end
        part.CanTouch = false
        part.CanCollide = false
    end
end

local function CheckMaps()
    local yacht = Workspace:FindFirstChild("Yacht")
    if yacht then
        local intereactive = yacht:FindFirstChild("Intereactive")
        if intereactive then
            local water = intereactive:FindFirstChild("Water")
            if water then
                DisableWaterPart(water:FindFirstChild("WaterPart"))
            end
        end
    end
    
    local pier = Workspace:FindFirstChild("Pier")
    if pier then
        DisableWaterPart(pier:FindFirstChild("Respawn"))
    end
end

local function enableWaterImmunity()
    if waterMaid then
        waterMaid:DoCleaning()
        waterMaid = nil
    end
    
    waterMaid = nicolas.new()
    CheckMaps()
    
    waterMaid:GiveTask(Workspace.DescendantAdded:Connect(CheckMaps))
    waterMaid:GiveTask(Workspace.DescendantRemoved:Connect(CheckMaps))
end

task.spawn(enableWaterImmunity)

-- ==================== DEVICE SELECTION PROMPT ====================
local selectedScale = 1 
local promptLoaded = false

local function promptDeviceSelection()
    local parent = getGuiParent()
    local pGui = Instance.new("ScreenGui")
    pGui.Name = "AWhub_DeviceSelector"
    pGui.Parent = parent
    pGui.ResetOnSpawn = false
    pGui.DisplayOrder = 1000000
    pGui.IgnoreGuiInset = true

    local bg = Instance.new("Frame")
    bg.Size = UDim2.new(1, 0, 1, 0)
    bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    bg.BackgroundTransparency = 0.5
    bg.Parent = pGui

    local promptFrame = Instance.new("Frame")
    promptFrame.Size = UDim2.new(0, 360, 0, 200)
    promptFrame.Position = UDim2.new(0.5, -180, 0.5, -100)
    promptFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    promptFrame.Parent = pGui
    Instance.new("UICorner", promptFrame).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", promptFrame)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.2

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 15)
    title.BackgroundTransparency = 1
    title.Text = "Select Your Platform"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 18
    title.Parent = promptFrame

    local subTitle = Instance.new("TextLabel")
    subTitle.Size = UDim2.new(1, -20, 0, 30)
    subTitle.Position = UDim2.new(0, 10, 0, 55)
    subTitle.BackgroundTransparency = 1
    subTitle.Text = "PC UI will be 2x bigger than Mobile UI."
    subTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    subTitle.Font = Enum.Font.Gotham
    subTitle.TextSize = 12
    subTitle.Parent = promptFrame

    local mobBtn = Instance.new("TextButton")
    mobBtn.Size = UDim2.new(0, 140, 0, 45)
    mobBtn.Position = UDim2.new(0, 25, 0, 115)
    mobBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    mobBtn.Text = "Mobile"
    mobBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    mobBtn.Font = Enum.Font.GothamBold
    mobBtn.TextSize = 14
    mobBtn.Parent = promptFrame
    Instance.new("UICorner", mobBtn).CornerRadius = UDim.new(0, 8)

    local pcBtn = Instance.new("TextButton")
    pcBtn.Size = UDim2.new(0, 140, 0, 45)
    pcBtn.Position = UDim2.new(0, 195, 0, 115)
    pcBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    pcBtn.Text = "PC (2x Size)"
    pcBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    pcBtn.Font = Enum.Font.GothamBold
    pcBtn.TextSize = 14
    pcBtn.Parent = promptFrame
    Instance.new("UICorner", pcBtn).CornerRadius = UDim.new(0, 8)

    mobBtn.MouseButton1Click:Connect(function()
        selectedScale = 1
        promptLoaded = true
        pGui:Destroy()
    end)

    pcBtn.MouseButton1Click:Connect(function()
        selectedScale = 2
        promptLoaded = true
        pGui:Destroy()
    end)
end

promptDeviceSelection()
repeat task.wait() until promptLoaded

local state = {
    farm = true,
    xpFarm = false,
    noclip = false,
    gun = false,
    afk = false,
    autoKillAll = false,
    autoShootMur = false,
    autoFlingMur = false,
    autoResetMurderer = false,
    autoResetSheriff = false,
    autoResetInnocent = false,
    antifling = true,
    disable3d = false,
    sendOnFull = false,
    autoRejoin = false,
    autoServerHop = false,
    autoPrestige = false,
}

local settingsConfig = { 
    webhookUrl = "",
    webhookCooldown = 30,
    discordUserId = ""
}

local CONFIG_FILE = "Appleware.json"

local function saveSettings()
    pcall(function()
        if writefile then
            writefile(CONFIG_FILE, HttpService:JSONEncode({
                state = state,
                config = settingsConfig
            }))
        end
    end)
end

local function loadSettings()
    pcall(function()
        if readfile and isfile and isfile(CONFIG_FILE) then
            local decoded = HttpService:JSONDecode(readfile(CONFIG_FILE))
            if decoded.state then
                for k, v in pairs(decoded.state) do
                    if state[k] ~= nil then state[k] = v end
                end
            end
            if decoded.config then
                for k, v in pairs(decoded.config) do
                    if settingsConfig[k] ~= nil then settingsConfig[k] = v end
                end
            end
        end
    end)
end
loadSettings()

local TWEEN_SPEED = 25
local UNDER = 3.4
local HIDE_POS = CFrame.new(0, 300, 0)
local MIN_BAG_FULL = 40

local isExecutingAction = false
local currentCoinCount = 0
local maxCoinCount = 40
local bagFull = false
local busy = false
local currentFarmTween = nil
local currentTargetCoin = nil -- Tracks the coin you are currently moving towards
local farmVelocityConn = nil  -- Tracks the velocity freeze connection
local totalCoinsEarned = 0
local activeResets = {}
local sessionStartTime = tick()

local lastRoundState = false
local roundStartTime = 0
local hasCollectedThisRound = false
local roundFullyStarted = false

local roleCache = {
    data = nil,
    timestamp = 0,
    TTL = 0.8,
}

local function getCachedRoleData()
    local now = tick()
    if roleCache.data and (now - roleCache.timestamp) < roleCache.TTL then
        return roleCache.data
    end
    local ok, result = pcall(function()
        local remote = ReplicatedStorage:FindFirstChild("GetPlayerData", true)
        if remote and remote:IsA("RemoteFunction") then
            return remote:InvokeServer()
        end
    end)
    if ok and result then
        roleCache.data = result
        roleCache.timestamp = now
        return result
    end
    roleCache.timestamp = now
    return roleCache.data
end

local function getMurd()
    local roleData = getCachedRoleData()
    if roleData then
        for playerName, data in pairs(roleData) do
            if data.Role == "Murderer" and not data.Killed and not data.Dead then
                local p = Players:FindFirstChild(playerName)
                if p and p ~= LP then return p end
            end
        end
    end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local bp = plr:FindFirstChild("Backpack")
            local char = plr.Character
            if (bp and bp:FindFirstChild("Knife")) or (char and char:FindFirstChild("Knife")) then
                return plr
            end
        end
    end
    return nil
end

local function triggerMenuReset()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Escape, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Escape, false, game)
        task.wait(0.15)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
        task.wait(0.15)
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    end)
end

local st
local blackScreen = nil

local function alive()
    local c = LP.Character
    return c and c:FindFirstChild("Humanoid") and c.Humanoid.Health > 0 and c:FindFirstChild("HumanoidRootPart")
end

local function standUp()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hum then
        hum.PlatformStand = false
        hum.AutoRotate = true
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end
    if root then
        root.Anchored = false
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

local function hideSky()
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.PlatformStand = true end
    if root then
        root.Anchored = true
        root.CFrame = HIDE_POS
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

local function cancelFarmTween()
    if currentFarmTween then
        pcall(function() currentFarmTween:Cancel() end)
        currentFarmTween = nil
    end
    if farmVelocityConn then
        farmVelocityConn:Disconnect()
        farmVelocityConn = nil
    end
    currentTargetCoin = nil
end

local function applyLowDeviceOptimizations(enabled)
    pcall(function()
        if enabled then
            RunService:Set3dRenderingEnabled(false)
            if blackScreen then blackScreen.Visible = true end
            UserGameSettings.SavedQualityLevel = Enum.SavedQualityLevel.Level0
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") then
                    v.Enabled = false
                end
            end
            task.spawn(function()
                for _, v in ipairs(Workspace:GetDescendants()) do
                    if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") then
                        v.Enabled = false
                    end
                end
            end)
            collectgarbage("collect")
        else
            RunService:Set3dRenderingEnabled(true)
            if blackScreen then blackScreen.Visible = false end
            UserGameSettings.SavedQualityLevel = Enum.SavedQualityLevel.Level10
            Lighting.GlobalShadows = true
            for _, v in ipairs(Lighting:GetChildren()) do
                if v:IsA("PostEffect") or v:IsA("Sky") or v:IsA("Atmosphere") then
                    v.Enabled = true
                end
            end
        end
    end)
end

-- ==================== WEBHOOK SYSTEM ====================
local httpRequest = request or http_request or (syn and syn.request) or (fluxus and fluxus.request)

local function sendAppleWareWebhook(title, description, fields, color)
    if settingsConfig.webhookUrl == "" then return end

    local ping = ""
    if settingsConfig.discordUserId ~= "" then
        ping = "<@" .. settingsConfig.discordUserId .. ">"
    end

    local embed = {
        title = "⚡ " .. title,
        description = description,
        color = color or 0x2B2D31,
        fields = fields or {},
        footer = {
            text = "AWhub Automation Suite • " .. os.date("%H:%M:%S")
        },
        timestamp = DateTime.now():ToIsoDate()
    }

    local data = {
        content = ping ~= "" and (ping .. " 🔔 Status update report:") or nil,
        username = "AWhub Bot",
        embeds = {embed},
        allowed_mentions = {
            parse = {"users"}
        }
    }

    pcall(function()
        if httpRequest then
            httpRequest({
                Url = settingsConfig.webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end
    end)
end

local function sendStatusWebhook()
    local elapsed = tick() - sessionStartTime
    local hours = math.floor(elapsed / 3600)
    local minutes = math.floor((elapsed % 3600) / 60)
    local seconds = math.floor(elapsed % 60)
    
    local elapsedHours = math.max(elapsed / 3600, 0.001)
    local rate = math.floor((totalCoinsEarned or 0) / elapsedHours)

    local timeFormatted = string.format("%dh %dm %ds", hours, minutes, seconds)
    if hours == 0 then
        timeFormatted = string.format("%dm %ds", minutes, seconds)
    end

    sendAppleWareWebhook(
        "Session Progress Report",
        "Update for " .. tostring(LP.Name),
        {
            {name = "👤 User Profile", value = "`" .. tostring(LP.Name) .. "`\nID: `" .. tostring(LP.UserId) .. "`", inline = true},
            {name = "💰 Coin Statistics", value = "Bag Capacity: **" .. tostring(currentCoinCount) .. "/" .. tostring(maxCoinCount) .. "**\nTotal Harvested: **" .. tostring(totalCoinsEarned) .. " 🪙**", inline = true},
            {name = "⏱️ Performance", value = "Active Time: **" .. timeFormatted .. "**\nHarvest Rate: **" .. tostring(rate) .. " coins/hr**", inline = false},
            {name = "🌐 Server Details", value = "Place ID: `" .. tostring(game.PlaceId) .. "`\nJob ID: `" .. tostring(game.JobId) .. "`", inline = false}
        },
        0x00D26A
    )
end

task.spawn(function()
    while true do
        local waitTime = settingsConfig.webhookCooldown
        if not waitTime or waitTime < 5 then waitTime = 30 end
        task.wait(waitTime)

        if state.sendOnFull and settingsConfig.webhookUrl ~= "" then
            sendStatusWebhook()
        end
    end
end)

-- ==================== FLING ====================
local antiFlingBV, antiFlingBG = nil, nil

local function lockSelf(rootPart, lockCFrame)
    if antiFlingBV then pcall(function() antiFlingBV:Destroy() end) end
    if antiFlingBG then pcall(function() antiFlingBG:Destroy() end) end
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.zero
    bv.Parent = rootPart
    antiFlingBV = bv
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 9e8
    bg.CFrame = lockCFrame
    bg.Parent = rootPart
    antiFlingBG = bg
end

local function unlockSelf()
    if antiFlingBV then pcall(function() antiFlingBV:Destroy() end) antiFlingBV = nil end
    if antiFlingBG then pcall(function() antiFlingBG:Destroy() end) antiFlingBG = nil end
end

local function restoreSelf(character, savedData, originalDestroyHeight)
    if not character or not savedData then
        Workspace.FallenPartsDestroyHeight = originalDestroyHeight
        return
    end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then
        Workspace.FallenPartsDestroyHeight = originalDestroyHeight
        return
    end
    Workspace.FallenPartsDestroyHeight = originalDestroyHeight
    rootPart.Anchored = false
    rootPart.CFrame = savedData.cframe
    rootPart.AssemblyLinearVelocity = Vector3.zero
    rootPart.AssemblyAngularVelocity = Vector3.zero
    humanoid.PlatformStand = false
    pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.GettingUp) end)
end

local function VoidReset(TargetPlayer)
    if not TargetPlayer or TargetPlayer == LP then return end
    if activeResets[TargetPlayer.UserId] then return end

    local Character = LP.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Character:FindFirstChild("HumanoidRootPart")
    local TCharacter = TargetPlayer.Character
    if not (Humanoid and RootPart and TCharacter) then return end
    local TRootPart = TCharacter:FindFirstChild("HumanoidRootPart")
    if not TRootPart then return end

    local touchParts = {}
    for _, name in ipairs({"HumanoidRootPart", "Head", "UpperTorso", "Torso", "LowerTorso"}) do
        local p = TCharacter:FindFirstChild(name)
        if p then table.insert(touchParts, p) end
    end

    isExecutingAction = true
    cancelFarmTween()
    local oldFarm, oldXpFarm = state.farm, state.xpFarm
    state.farm, state.xpFarm = false, false

    if st then st.Text = " [AWhub] Flinging Murderer..." end

    local savedCF = RootPart.CFrame
    local originalDestroyHeight = Workspace.FallenPartsDestroyHeight
    Workspace.FallenPartsDestroyHeight = -math.huge
    Humanoid.PlatformStand = true
    RootPart.Anchored = false
    lockSelf(RootPart, savedCF)

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.new(0, -200000, 0)
    bv.Parent = RootPart

    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 9e8
    bg.Parent = RootPart

    local startTime = tick()
    local resetObj = {bv = bv, bg = bg, conn = nil}
    activeResets[TargetPlayer.UserId] = resetObj

    local function cleanup()
        activeResets[TargetPlayer.UserId] = nil
        if resetObj.conn then resetObj.conn:Disconnect() end
        pcall(function() bv:Destroy() end)
        pcall(function() bg:Destroy() end)
        unlockSelf()
        restoreSelf(Character, {cframe = savedCF}, originalDestroyHeight)
        state.farm, state.xpFarm = oldFarm, oldXpFarm
        isExecutingAction = false
        if st then st.Text = " [AWhub] Murderer fling attempt ended." end
    end

    resetObj.conn = RunService.Heartbeat:Connect(function()
        if not TargetPlayer.Character or not TRootPart.Parent or not RootPart.Parent then
            cleanup()
            return
        end
        if tick() - startTime >= 2.5 then
            cleanup()
            return
        end
        local aimPos = TRootPart.Position + TRootPart.AssemblyLinearVelocity * 0.04
        RootPart.CFrame = CFrame.new(aimPos)
        RootPart.AssemblyLinearVelocity = Vector3.new(0, -200000, 0)
        RootPart.AssemblyAngularVelocity = Vector3.new(15000, 15000, 15000)
        for _ = 1, 6 do
            for _, part in ipairs(touchParts) do
                pcall(firetouchinterest, RootPart, part, 0)
                pcall(firetouchinterest, RootPart, part, 1)
            end
        end
    end)
end

local function reliableFling(TargetPlayer)
    if not TargetPlayer or TargetPlayer == LP then return end
    task.spawn(function()
        local maxAttempts = 4
        for attempt = 1, maxAttempts do
            if not TargetPlayer or not TargetPlayer.Parent then break end
            
            local tChar = TargetPlayer.Character
            local tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
            if not tHum or tHum.Health <= 0 then break end

            VoidReset(TargetPlayer)

            while activeResets[TargetPlayer.UserId] do
                task.wait(0.1)
            end

            task.wait(0.4)

            tChar = TargetPlayer.Character
            tHum = tChar and tChar:FindFirstChildOfClass("Humanoid")
            if not tHum or tHum.Health <= 0 then
                if st then st.Text = " [AWhub] Murderer successfully eliminated!" end
                break
            else
                if attempt < maxAttempts then
                    if st then st.Text = " [AWhub] Fling failed, retrying (" .. (attempt + 1) .. "/" .. maxAttempts .. ")..." end
                    task.wait(0.6)
                else
                    if st then st.Text = " [AWhub] Max fling attempts reached." end
                end
            end
        end
    end)
end

local function flingMurdererNow()
    task.spawn(function()
        local mur = getMurd()
        if mur and mur.Character then
            reliableFling(mur)
        else
            if st then st.Text = " [AWhub] Murderer not found!" end
        end
    end)
end

local function serverHop()
    pcall(function()
        local servers = {}
        local success, body = pcall(function()
            return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
        end)
        if success and body and body.data then
            for _, s in ipairs(body.data) do
                if s.playing and s.maxPlayers and s.playing < s.maxPlayers and s.id ~= game.JobId then
                    table.insert(servers, s.id)
                end
            end
        end
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], LP)
        else
            TeleportService:Teleport(game.PlaceId, LP)
        end
    end)
end

-- ==================== COMBAT / UTILITY FUNCTIONS ====================
local function findTool(name)
    local char, bp = LP.Character, LP:FindFirstChild("Backpack")
    if char and char:FindFirstChild(name) then return char[name] end
    if bp and bp:FindFirstChild(name) then return bp[name] end
    return nil
end

local function equipTool(name)
    local char = LP.Character
    local bp = LP:FindFirstChild("Backpack")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char then return nil end
    
    local existing = char:FindFirstChild(name)
    if existing then return existing end
    
    local tool = bp and bp:FindFirstChild(name)
    if tool and hum then
        pcall(function()
            hum:EquipTool(tool)
        end)
        task.wait(0.15)
        -- Fallback force parent if EquipTool is blocked
        if not char:FindFirstChild(name) and tool.Parent == bp then
            pcall(function()
                tool.Parent = char
            end)
        end
        task.wait(0.05)
        return char:FindFirstChild(name)
    end
    return nil
end

local function getRole()
    local roleData = getCachedRoleData()
    if roleData and roleData[LP.Name] and roleData[LP.Name].Role then
        return roleData[LP.Name].Role
    end
    if findTool("Knife") then return "Murderer" end
    if findTool("Gun") then return "Sheriff" end
    return "Innocent"
end

-- Replace this with your actual bag check logic
local function isBagFull()
    -- Uses the global variables already tracking this in the script
    return bagFull or (currentCoinCount >= MIN_BAG_FULL)
end

-- Replace this with your actual kill logic (equipping knife, firing remote, etc.)
local function executeKill(targetPlayer)
    local targetChar = targetPlayer.Character
    local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
    local targetHumanoid = targetChar and targetChar:FindFirstChildOfClass("Humanoid")
    
    local LocalPlayer = Players.LocalPlayer
    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if targetHumanoid and targetHumanoid.Health > 0 and targetRoot and myRoot then
        local tStart = tick()
        while tick() - tStart < 1.2 and targetHumanoid.Health > 0 and targetRoot.Parent and myRoot.Parent and alive() do
            if not LocalPlayer.Character:FindFirstChild("Knife") then
                equipTool("Knife")
            end

            myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 2.2)
            myRoot.AssemblyLinearVelocity = Vector3.zero
            myRoot.AssemblyAngularVelocity = Vector3.zero

            pcall(function()
                local activeKnife = LocalPlayer.Character:FindFirstChild("Knife")
                if activeKnife then activeKnife:Activate() end
            end)
            
            pcall(function()
                for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
                    if v:IsA("RemoteEvent") and (string.lower(v.Name):find("knife") or string.lower(v.Name):find("hit") or string.lower(v.Name):find("stab") or string.lower(v.Name):find("kill")) then
                        v:FireServer(targetRoot.Position)
                    end
                end
            end)
            task.wait(0.04)
        end
    end
end

local function autoKillAllPlayers()
    local LocalPlayer = Players.LocalPlayer
    
    -- 1. Wait until the bag is full
    repeat task.wait(0.5) until isBagFull()

    standUp()
    task.wait(0.1)

    -- Force equip knife
    local knife = equipTool("Knife")
    if not knife then
        for i = 1, 20 do
            task.wait(0.1)
            knife = equipTool("Knife")
            if knife then break end
        end
    end
    if not knife then return end

    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")

    if not rootPart then return end

    -- 2. Iterate through all players
    for _, targetPlayer in ipairs(Players:GetPlayers()) do
        if targetPlayer ~= LocalPlayer then
            executeKill(targetPlayer)
        end
    end
end

-- ==================== UI ====================
local function buildUI()
    local parent = getGuiParent()
    pcall(function()
        local old = parent:FindFirstChild("AWhub")
        if old then old:Destroy() end
    end)

    local baseWidth = 420 * selectedScale
    local baseHeight = 380 * selectedScale
    local fontSizeMult = selectedScale

    local sg = Instance.new("ScreenGui")
    sg.Name = "AWhub"
    sg.Parent = parent
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 999999
    sg.IgnoreGuiInset = true

    blackScreen = Instance.new("Frame")
    blackScreen.Size = UDim2.new(1, 0, 1, 0)
    blackScreen.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    blackScreen.BorderSizePixel = 0
    blackScreen.Visible = state.disable3d
    blackScreen.ZIndex = -1
    blackScreen.Parent = sg

    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, baseWidth, 0, baseHeight)
    f.Position = UDim2.new(0.5, -baseWidth/2, 0.5, -baseHeight/2)
    f.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    f.BackgroundTransparency = 0.05
    f.Active = true
    f.Draggable = true
    f.ClipsDescendants = true
    f.Parent = sg
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12 * selectedScale)

    local stroke = Instance.new("UIStroke", f)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1.5 * selectedScale
    stroke.Transparency = 0.2

    local h = Instance.new("Frame")
    h.Size = UDim2.new(1, 0, 0, 38 * selectedScale)
    h.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    h.Parent = f
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 12 * selectedScale)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20 * selectedScale, 1, 0)
    title.Position = UDim2.new(0, 12 * selectedScale, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "AWhub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13 * fontSizeMult
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = h

    local tb = Instance.new("Frame")
    tb.Size = UDim2.new(1, -24 * selectedScale, 0, 34 * selectedScale)
    tb.Position = UDim2.new(0, 12 * selectedScale, 0, 48 * selectedScale)
    tb.BackgroundTransparency = 1
    tb.Parent = f

    local tabs = {"Farm", "Combat", "Webhook", "Misc"}
    local pages, btns = {}, {}

    for i, name in pairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.25, -4 * selectedScale, 1, 0)
        btn.Position = UDim2.new((i - 1) * 0.25, i > 1 and (3 * selectedScale) or 0, 0, 0)
        btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(15, 15, 15)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11 * fontSizeMult
        btn.Parent = tb
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8 * selectedScale)
        btns[name] = btn

        local pg = Instance.new("ScrollingFrame")
        pg.Size = UDim2.new(1, -24 * selectedScale, 1, -150 * selectedScale)
        pg.Position = UDim2.new(0, 12 * selectedScale, 0, 92 * selectedScale)
        pg.BackgroundTransparency = 1
        pg.ScrollBarThickness = 4 * selectedScale
        pg.CanvasSize = UDim2.new(0, 0, 0, 400 * selectedScale)
        pg.Parent = f
        pg.Visible = (i == 1)
        pages[name] = pg

        btn.MouseButton1Click:Connect(function()
            for _, b in pairs(btns) do
                TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(15, 15, 15)}):Play()
            end
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
            for _, p in pairs(pages) do p.Visible = false end
            pg.Visible = true
        end)
    end

    st = Instance.new("TextLabel")
    st.Size = UDim2.new(1, -24 * selectedScale, 0, 26 * selectedScale)
    st.Position = UDim2.new(0, 12 * selectedScale, 1, -34 * selectedScale)
    st.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    st.Text = " AWhub Ready"
    st.TextColor3 = Color3.fromRGB(255, 255, 255)
    st.Font = Enum.Font.GothamSemibold
    st.TextSize = 11 * fontSizeMult
    st.TextXAlignment = Enum.TextXAlignment.Left
    st.Parent = f
    Instance.new("UICorner", st).CornerRadius = UDim.new(0, 6 * selectedScale)

    local function tgg(page, name, y, key)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32 * selectedScale)
        btn.Position = UDim2.new(0, 0, 0, y * selectedScale)
        btn.BackgroundColor3 = state[key] and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(15, 15, 15)
        btn.Text = "  " .. name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 11.5 * fontSizeMult
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = page
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6 * selectedScale)

        local pill = Instance.new("Frame")
        pill.Size = UDim2.new(0, 38 * selectedScale, 0, 18 * selectedScale)
        pill.Position = UDim2.new(1, -44 * selectedScale, 0.5, -9 * selectedScale)
        pill.BackgroundColor3 = state[key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 40)
        pill.Parent = btn
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 14 * selectedScale, 0, 14 * selectedScale)
        dot.Position = state[key] and UDim2.new(1, -16 * selectedScale, 0.5, -7 * selectedScale) or UDim2.new(0, 2 * selectedScale, 0.5, -7 * selectedScale)
        dot.BackgroundColor3 = state[key] and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
        dot.Parent = pill
        Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

        btn.MouseButton1Click:Connect(function()
            state[key] = not state[key]
            TweenService:Create(btn, TweenInfo.new(0.2), {
                BackgroundColor3 = state[key] and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(15, 15, 15)
            }):Play()
            TweenService:Create(pill, TweenInfo.new(0.2), {
                BackgroundColor3 = state[key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 40)
            }):Play()
            TweenService:Create(dot, TweenInfo.new(0.2), {
                Position = state[key] and UDim2.new(1, -16 * selectedScale, 0.5, -7 * selectedScale) or UDim2.new(0, 2 * selectedScale, 0.5, -7 * selectedScale),
                BackgroundColor3 = state[key] and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
            }):Play()
            
            if key == "disable3d" then
                applyLowDeviceOptimizations(state.disable3d)
            end
            
            saveSettings()
        end)
    end

    local function addActionButton(page, name, y, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32 * selectedScale)
        btn.Position = UDim2.new(0, 0, 0, y * selectedScale)
        btn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
        btn.Text = "  " .. name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 11.5 * fontSizeMult
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = page
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6 * selectedScale)
        btn.MouseButton1Click:Connect(function()
            callback()
        end)
    end

    tgg(pages["Farm"], "Farm (Safe)", 0, "farm")
    tgg(pages["Farm"], "XP Farm", 38, "xpFarm")
    tgg(pages["Farm"], "Disable 3D Rendering", 76, "disable3d")

    tgg(pages["Combat"], "Auto Shoot Murderer", 0, "autoShootMur")
    tgg(pages["Combat"], "Auto Kill All", 38, "autoKillAll")
    tgg(pages["Combat"], "Auto Fling Murderer", 76, "autoFlingMur")
    tgg(pages["Combat"], "Auto Reset: Murderer", 114, "autoResetMurderer")
    tgg(pages["Combat"], "Auto Reset: Sheriff", 152, "autoResetSheriff")
    tgg(pages["Combat"], "Auto Reset: Innocent", 190, "autoResetInnocent")
    addActionButton(pages["Combat"], "Fling Murderer Now", 228, flingMurdererNow)

    tgg(pages["Webhook"], "Auto send based off of timer", 0, "sendOnFull")

    local intervals = {
        {text = "30s", seconds = 30},
        {text = "1m", seconds = 60},
        {text = "5m", seconds = 300},
        {text = "10m", seconds = 600},
        {text = "20m", seconds = 1200}
    }

    local currentIntervalIndex = 1
    for i, v in ipairs(intervals) do
        if v.seconds == settingsConfig.webhookCooldown then
            currentIntervalIndex = i
            break
        end
    end

    local timerBtn = Instance.new("TextButton")
    timerBtn.Size = UDim2.new(1, 0, 0, 32 * selectedScale)
    timerBtn.Position = UDim2.new(0, 0, 0, 38 * selectedScale)
    timerBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    timerBtn.Text = "  Timer Interval: " .. intervals[currentIntervalIndex].text
    timerBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    timerBtn.Font = Enum.Font.GothamMedium
    timerBtn.TextSize = 11.5 * fontSizeMult
    timerBtn.TextXAlignment = Enum.TextXAlignment.Left
    timerBtn.Parent = pages["Webhook"]
    Instance.new("UICorner", timerBtn).CornerRadius = UDim.new(0, 6 * selectedScale)

    timerBtn.MouseButton1Click:Connect(function()
        currentIntervalIndex = currentIntervalIndex + 1
        if currentIntervalIndex > #intervals then
            currentIntervalIndex = 1
        end
        local selected = intervals[currentIntervalIndex]
        timerBtn.Text = "  Timer Interval: " .. selected.text
        settingsConfig.webhookCooldown = selected.seconds
        saveSettings()
    end)

    local whBox = Instance.new("TextBox")
    whBox.Size = UDim2.new(1, 0, 0, 28 * selectedScale)
    whBox.Position = UDim2.new(0, 0, 0, 76 * selectedScale)
    whBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    whBox.PlaceholderText = "Webhook URL..."
    whBox.Text = settingsConfig.webhookUrl
    whBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    whBox.Font = Enum.Font.Gotham
    whBox.TextSize = 10 * fontSizeMult
    whBox.Parent = pages["Webhook"]
    Instance.new("UICorner", whBox).CornerRadius = UDim.new(0, 6 * selectedScale)
    whBox.FocusLost:Connect(function()
        settingsConfig.webhookUrl = whBox.Text
        saveSettings()
    end)

    local idBox = Instance.new("TextBox")
    idBox.Size = UDim2.new(1, 0, 0, 28 * selectedScale)
    idBox.Position = UDim2.new(0, 0, 0, 114 * selectedScale)
    idBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    idBox.PlaceholderText = "Discord User ID (for ping)..."
    idBox.Text = settingsConfig.discordUserId
    idBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    idBox.Font = Enum.Font.Gotham
    idBox.TextSize = 10 * fontSizeMult
    idBox.Parent = pages["Webhook"]
    Instance.new("UICorner", idBox).CornerRadius = UDim.new(0, 6 * selectedScale)
    idBox.FocusLost:Connect(function()
        settingsConfig.discordUserId = idBox.Text
        saveSettings()
    end)

    tgg(pages["Misc"], "Anti AFK", 0, "afk")
    tgg(pages["Misc"], "Anti Fling", 38, "antifling")
    tgg(pages["Misc"], "Auto Grab Gun", 76, "gun")
    tgg(pages["Misc"], "Auto Rejoin", 114, "autoRejoin")
    tgg(pages["Misc"], "Auto Serverhop (<= 4)", 152, "autoServerHop")
    tgg(pages["Misc"], "Auto Prestige (Level 100)", 190, "autoPrestige")

    local fb = Instance.new("TextButton")
    fb.Size = UDim2.new(0, 75 * selectedScale, 0, 36 * selectedScale)
    fb.Position = UDim2.new(0, 15 * selectedScale, 0.3, 0)
    fb.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    fb.Text = "close"
    fb.TextColor3 = Color3.fromRGB(255, 255, 255)
    fb.Font = Enum.Font.GothamBold
    fb.TextSize = 12 * fontSizeMult
    fb.Parent = sg
    fb.ZIndex = 99999
    fb.Active = true
    fb.Draggable = true
    Instance.new("UICorner", fb).CornerRadius = UDim.new(0, 8 * selectedScale)

    local isOpen = true
    fb.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            f.Visible = true
            TweenService:Create(f, TweenInfo.new(0.3), {Size = UDim2.new(0, baseWidth, 0, baseHeight)}):Play()
            fb.Text = "close"
        else
            TweenService:Create(f, TweenInfo.new(0.25), {Size = UDim2.new(0, baseWidth, 0, 0)}):Play()
            task.delay(0.25, function()
                if not isOpen then f.Visible = false end
            end)
            fb.Text = "open"
        end
    end)
end

buildUI()

if state.disable3d then
    applyLowDeviceOptimizations(true)
end

local function getCoins()
    local coins = {}
    for _, map in ipairs(Workspace:GetChildren()) do
        local cc = map:FindFirstChild("CoinContainer") or (map.Name == "CoinContainer" and map)
        if cc then
            for _, d in ipairs(cc:GetDescendants()) do
                if d:IsA("BasePart") and d:FindFirstChild("TouchInterest") then
                    table.insert(coins, d)
                end
            end
        end
    end
    return coins
end

local function isInRound()
    for _, map in ipairs(Workspace:GetChildren()) do
        if map:FindFirstChild("CoinContainer") or map.Name == "CoinContainer" then return true end
    end
    return false
end

local function isLobby()
    return not isInRound()
end

local function collectCoin(root, coin)
    if not root or not coin or not coin.Parent then return end
    pcall(function()
        for _ = 1, 3 do
            firetouchinterest(root, coin, 0)
            firetouchinterest(root, coin, 1)
        end
    end)
end

local function runBagFullAction()
    if busy or not hasCollectedThisRound then return end
    if currentCoinCount < MIN_BAG_FULL then return end

    busy = true
    isExecutingAction = true
    bagFull = true
    cancelFarmTween()

    totalCoinsEarned = totalCoinsEarned + currentCoinCount

    local role = getRole()

    pcall(function()
        if role == "Murderer" then
            standUp()
            if state.autoKillAll then
                if st then st.Text = " [AWhub] Executing Auto Kill All..." end
                autoKillAllPlayers()
                task.wait(0.5)
            end
            if state.autoResetMurderer then
                triggerMenuReset()
                task.wait(1.5)
            end
        else
            if state.autoFlingMur then
                local mur = getMurd()
                if mur and mur.Character then
                    if st then st.Text = " [AWhub] Flinging Murderer..." end
                    busy = false
                    isExecutingAction = false
                    reliableFling(mur)
                    busy = true
                    isExecutingAction = true
                end
            end

            if role == "Innocent" and state.autoResetInnocent then
                triggerMenuReset()
                task.wait(1.5)
            elseif role == "Sheriff" and state.autoResetSheriff then
                triggerMenuReset()
                task.wait(1.5)
            end
        end
    end)

    if not (role == "Murderer" and state.autoKillAll) then
        hideSky()
    end
    
    busy = false
    isExecutingAction = false
end

task.spawn(function()
    local ok, remote = pcall(function()
        return ReplicatedStorage:WaitForChild("Remotes", 10):WaitForChild("Gameplay", 10):WaitForChild("CoinCollected", 10)
    end)
    if ok and remote then
        remote.OnClientEvent:Connect(function(_, currentCoins, maxCoins)
            if typeof(currentCoins) == "number" then
                currentCoinCount = math.clamp(currentCoins, 0, 50)
                if currentCoins > 0 then hasCollectedThisRound = true end
            end
            if typeof(maxCoins) == "number" then maxCoinCount = maxCoins end
            if typeof(currentCoins) == "number" and currentCoins <= 0 then
                currentCoinCount = 0
                bagFull = false
                return
            end
            if typeof(currentCoins) == "number" and currentCoins >= MIN_BAG_FULL then
                bagFull = true
                task.spawn(runBagFullAction)
            end
        end)
    end
end)

task.spawn(function()
    while true do
        task.wait(0.4)
        local inRound = isInRound()
        local hasRoles = getMurd() ~= nil

        if not inRound then
            lastRoundState = false
            roundFullyStarted = false
            hasCollectedThisRound = false
            currentCoinCount = 0
            bagFull = false
        end

        if inRound and hasRoles and not roundFullyStarted then
            if not lastRoundState then
                currentCoinCount = 0
                bagFull = false
                hasCollectedThisRound = false
                busy = false
                isExecutingAction = false
                roundStartTime = tick()
                lastRoundState = true
                if st then st.Text = " [AWhub] Map loaded..." end
            end
            if (tick() - roundStartTime) > 6 then
                roundFullyStarted = true
                if st then st.Text = " [AWhub] Round started" end
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.04)

        if not alive() then
            cancelFarmTween()
            continue
        end

        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then continue end

        if state.xpFarm then
            cancelFarmTween()
            humanoid.PlatformStand = true
            root.Anchored = true
            root.CFrame = HIDE_POS
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            continue
        end

        if not state.farm then
            cancelFarmTween()
            continue
        end

        if isLobby() or bagFull or isExecutingAction then
            cancelFarmTween()
            humanoid.PlatformStand = true
            root.Anchored = true
            root.CFrame = HIDE_POS
            root.AssemblyLinearVelocity = Vector3.zero
            continue
        end

        root.Anchored = false
        humanoid.PlatformStand = true
        humanoid.AutoRotate = false
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        local coins = getCoins()
        if #coins == 0 then
            cancelFarmTween()
            continue
        end

        local closestCoin, shortest = nil, math.huge
        for _, c in ipairs(coins) do
            local dist = (root.Position - c.Position).Magnitude
            if dist < shortest then
                shortest = dist
                closestCoin = c
            end
        end
        
        if not closestCoin then 
            cancelFarmTween()
            continue 
        end

        local dist = (root.Position - closestCoin.Position).Magnitude

        if dist <= 7 then
            collectCoin(root, closestCoin)
        end

        -- If we are already smoothly moving to this exact coin, don't interrupt the tween
        if currentFarmTween and currentFarmTween.PlaybackState == Enum.PlaybackState.Playing and currentTargetCoin == closestCoin then
            collectCoin(root, closestCoin)
            continue
        end

        -- Target changed or no tween playing: cancel old movement and seamlessly start new one
        cancelFarmTween()
        currentTargetCoin = closestCoin

        local targetPos = closestCoin.Position + Vector3.new(0, -UNDER, 0)
        local targetCFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(90), 0, math.rad(180))
        local duration = math.clamp(dist / TWEEN_SPEED, 0.05, 3.3)

        currentFarmTween = TweenService:Create(
            root,
            TweenInfo.new(duration, Enum.EasingStyle.Linear),
            {CFrame = targetCFrame}
        )
        currentFarmTween:Play()

        -- Lock velocity so anti-cheat/physics doesn't fight the tween
        farmVelocityConn = RunService.Heartbeat:Connect(function()
            if not root or not root.Parent then
                cancelFarmTween()
                return
            end
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end)
    end
end)

local function getPrestigeRemote()
    for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
        if v.Name:lower():find("prestige") and (v:IsA("RemoteEvent") or v:IsA("RemoteFunction")) then
            return v
        end
    end
    return nil
end

task.spawn(function()
    while true do
        task.wait(2)
        if state.autoPrestige then
            pcall(function()
                local leaderstats = LP:FindFirstChild("leaderstats")
                local levelVal = leaderstats and (leaderstats:FindFirstChild("Level") or leaderstats:FindFirstChild("Lvl"))
                if levelVal and levelVal.Value >= 100 then
                    local prestigeRemote = getPrestigeRemote()
                    if prestigeRemote then
                        if prestigeRemote:IsA("RemoteEvent") then
                            prestigeRemote:FireServer()
                        elseif prestigeRemote:IsA("RemoteFunction") then
                            prestigeRemote:InvokeServer()
                        end
                    end
                end
            end)
        end
    end
end)

RunService.Stepped:Connect(function()
    if LP.Character and not bagFull and not isExecutingAction and not isLobby() and not state.xpFarm then
        for _, val in ipairs(LP.Character:GetDescendants()) do
            if val:IsA("BasePart") then val.CanCollide = false end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if not state.antifling or next(activeResets) then return end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if root and hum then
        local vel = root.AssemblyLinearVelocity
        if math.abs(vel.X) > 500 or math.abs(vel.Y) > 500 or math.abs(vel.Z) > 500 then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            hum.PlatformStand = false
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(3)
        if state.autoServerHop and isLobby() and #Players:GetPlayers() <= 4 then
            if st then st.Text = " [AWhub] Server hopping..." end
            serverHop()
            task.wait(10)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.15)
        if state.gun and alive() and not isExecutingAction and not findTool("Gun") then
            local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if root then
                for _, v in pairs(Workspace:GetDescendants()) do
                    if v.Name == "GunDrop" and v:IsA("BasePart") then
                        pcall(function()
                            firetouchinterest(root, v, 0)
                            firetouchinterest(root, v, 1)
                        end)
                        break
                    end
                end
            end
        end
    end
end)

task.spawn(function()
    pcall(function()
        local vu = game:GetService("VirtualUser")
        LP.Idled:Connect(function()
            if state.afk then
                vu:CaptureController()
                vu:ClickButton2(Vector2.new())
            end
        end)
    end)
end)

print("Appleware loaded - enjoy my script also fuck you but have a good day (made hy word)")
