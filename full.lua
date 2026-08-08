-- ====================================================================
-- AWhub -)
-- ====================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Automatically copy Discord link to clipboard on load
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
        end
        return CoreGui
    end)
    if success and gui then return gui end
    return LP:FindFirstChild("PlayerGui") or CoreGui
end

-- Everything starts as FALSE except for 'farm'
local state = {
    farm = true,
    noclip = false,
    gun = false,
    afk = false,
    autoKillAll = false,
    autoShootMur = false,
    autoFlingMur = false,
    autoResetMurderer = false,
    autoResetSheriff = false,
    autoResetInnocent = false,
    antifling = false,
    disable3d = false,
    sendOnFull = false,
    autoRejoin = false,
}

local settingsConfig = { 
    webhookUrl = "",
    webhookCooldown = 30,
    discordUserId = ""
}

-- Saves configuration files to workspace folder
local CONFIG_FILE = "AWhub_Settings_V14.json"

local function saveSettings()
    pcall(function()
        if writefile then
            local data = {
                state = state,
                config = settingsConfig
            }
            writefile(CONFIG_FILE, HttpService:JSONEncode(data))
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
local AURA_RADIUS = 6
local UNDER = 3.3
local MIN_BAG_FULL = 38
local HIDE_POS = CFrame.new(0, 300, 0)

local isExecutingAction = false
local currentCoinCount = 0
local maxCoinCount = 40
local bagFull = false
local busy = false
local currentFarmTween = nil
local lastWebhook = 0

local sessionStartTime = tick()
local totalCoinsEarned = 0
local isResetting = false

local roleCache = {
    data      = nil,
    timestamp = 0,
    TTL       = 0.8,
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
        roleCache.data      = result
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

local function touchParts(a, b)
    pcall(function()
        firetouchinterest(a, b, 0)
        firetouchinterest(a, b, 1)
    end)
end

-- Fallback reset sequence simulation via ESC -> R -> ENTER
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

-- ==========================================
-- DYNAMIC MOBILE ZOOM LOGIC
-- ==========================================
local isZoomed = false
local defaultFOV = 70
local targetFOV = 40

local function toggleMobileZoom(enable)
    if isZoomed == enable then return end
    isZoomed = enable
    
    local fov = enable and targetFOV or defaultFOV
    local tweenInfo = TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    
    pcall(function()
        local zoomTween = TweenService:Create(Camera, tweenInfo, {FieldOfView = fov})
        zoomTween:Play()
    end)
end
-- ==========================================

local function buildUI()
    local parent = getGuiParent()
    pcall(function()
        local old = parent:FindFirstChild("WordsFarmHub")
        if old then old:Destroy() end
        local old2 = parent:FindFirstChild("AWhub")
        if old2 then old2:Destroy() end
    end)

    local sg = Instance.new("ScreenGui")
    sg.Name = "AWhub"
    sg.Parent = parent
    sg.ResetOnSpawn = false
    sg.DisplayOrder = 999999
    sg.IgnoreGuiInset = true

    local f = Instance.new("Frame")
    f.Size = UDim2.new(0, 420, 0, 380)
    f.Position = UDim2.new(0.5, -210, 0.5, -190)
    f.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    f.BackgroundTransparency = 0.05
    f.Active = true
    f.Draggable = true
    f.Visible = true
    f.ClipsDescendants = true
    f.Parent = sg
    Instance.new("UICorner", f).CornerRadius = UDim.new(0, 12)

    local stroke = Instance.new("UIStroke", f)
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Thickness = 1.5
    stroke.Transparency = 0.2

    local h = Instance.new("Frame")
    h.Size = UDim2.new(1, 0, 0, 38)
    h.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    h.Parent = f
    Instance.new("UICorner", h).CornerRadius = UDim.new(0, 12)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 1, 0)
    title.Position = UDim2.new(0, 12, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "AWhub"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 13
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = h

    local tb = Instance.new("Frame")
    tb.Size = UDim2.new(1, -24, 0, 34)
    tb.Position = UDim2.new(0, 12, 0, 48)
    tb.BackgroundTransparency = 1
    tb.Parent = f

    local tabs = {"Farm", "Combat", "Webhook", "Misc"}
    local pages, btns = {}, {}

    for i, name in pairs(tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.25, -4, 1, 0)
        btn.Position = UDim2.new((i - 1) * 0.25, i > 1 and 3 or 0, 0, 0)
        btn.BackgroundColor3 = (i == 1) and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(15, 15, 15)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 11
        btn.Parent = tb
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
        btns[name] = btn

        local pg = Instance.new("ScrollingFrame")
        pg.Size = UDim2.new(1, -24, 1, -150)
        pg.Position = UDim2.new(0, 12, 0, 92)
        pg.BackgroundTransparency = 1
        pg.ScrollBarThickness = 4
        pg.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
        pg.CanvasSize = UDim2.new(0, 0, 0, 400)
        pg.Parent = f
        pg.Visible = (i == 1)
        pages[name] = pg

        btn.MouseButton1Click:Connect(function()
            for _, b in pairs(btns) do
                TweenService:Create(b, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                    BackgroundColor3 = Color3.fromRGB(15, 15, 15),
                    TextColor3 = Color3.fromRGB(255, 255, 255)
                }):Play()
            end
            TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            for _, p in pairs(pages) do p.Visible = false end
            pg.Visible = true
            
            pg.Position = UDim2.new(0, 12, 0, 105)
            TweenService:Create(pg, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                Position = UDim2.new(0, 12, 0, 92)
            }):Play()
        end)
    end

    local st = Instance.new("TextLabel")
    st.Size = UDim2.new(1, -24, 0, 26)
    st.Position = UDim2.new(0, 12, 1, -34)
    st.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
    st.Text = " AWhub System Ready"
    st.TextColor3 = Color3.fromRGB(255, 255, 255)
    st.Font = Enum.Font.GothamSemibold
    st.TextSize = 11
    st.TextXAlignment = Enum.TextXAlignment.Left
    st.Parent = f
    Instance.new("UICorner", st).CornerRadius = UDim.new(0, 6)

    local function tgg(page, name, y, key)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 32)
        btn.Position = UDim2.new(0, 0, 0, y)
        btn.BackgroundColor3 = state[key] and Color3.fromRGB(35, 35, 35) or Color3.fromRGB(15, 15, 15)
        btn.Text = "  " .. name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamMedium
        btn.TextSize = 11.5
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.Parent = page
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        local pill = Instance.new("Frame")
        pill.Size = UDim2.new(0, 38, 0, 18)
        pill.Position = UDim2.new(1, -44, 0.5, -9)
        pill.BackgroundColor3 = state[key] and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 40)
        pill.Parent = btn
        Instance.new("UICorner", pill).CornerRadius = UDim.new(1, 0)

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0, 14, 0, 14)
        dot.Position = state[key] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
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
            TweenService:Create(dot, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Position = state[key] and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
                BackgroundColor3 = state[key] and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(255, 255, 255)
            }):Play()
            
            if key == "disable3d" then
                RunService:Set3dRenderingEnabled(not state.disable3d)
            end
            if key == "farm" and state.farm then
                bagFull = false
            end
            saveSettings()
        end)
    end

    tgg(pages["Farm"], "Farm (Safe)", 0, "farm")
    tgg(pages["Farm"], "Disable 3D Rendering", 38, "disable3d")

    tgg(pages["Combat"], "Auto Shoot Murderer (Sheriff)", 0, "autoShootMur")
    tgg(pages["Combat"], "Auto Kill All (Murderer)", 38, "autoKillAll")
    tgg(pages["Combat"], "Fling Murderer (Innocent)", 76, "autoFlingMur")
    tgg(pages["Combat"], "Auto Reset: Murderer", 114, "autoResetMurderer")
    tgg(pages["Combat"], "Auto Reset: Sheriff", 152, "autoResetSheriff")
    tgg(pages["Combat"], "Auto Reset: Innocent", 190, "autoResetInnocent")

    tgg(pages["Webhook"], "Send on Bag Full", 0, "sendOnFull")

    local whBox = Instance.new("TextBox")
    whBox.Size = UDim2.new(1, 0, 0, 28)
    whBox.Position = UDim2.new(0, 0, 0, 38)
    whBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    whBox.PlaceholderText = "Webhook URL..."
    whBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    whBox.Text = settingsConfig.webhookUrl
    whBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    whBox.Font = Enum.Font.Gotham
    whBox.TextSize = 10
    whBox.Parent = pages["Webhook"]
    Instance.new("UICorner", whBox).CornerRadius = UDim.new(0, 6)
    whBox.FocusLost:Connect(function()
        settingsConfig.webhookUrl = whBox.Text
        saveSettings()
    end)

    local idLabel = Instance.new("TextLabel")
    idLabel.Size = UDim2.new(1, 0, 0, 18)
    idLabel.Position = UDim2.new(0, 0, 0, 74)
    idLabel.BackgroundTransparency = 1
    idLabel.Text = "Discord User ID (@ping):"
    idLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    idLabel.Font = Enum.Font.GothamBold
    idLabel.TextSize = 10
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.Parent = pages["Webhook"]

    local idBox = Instance.new("TextBox")
    idBox.Size = UDim2.new(1, 0, 0, 28)
    idBox.Position = UDim2.new(0, 0, 0, 96)
    idBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    idBox.PlaceholderText = "Enter Discord User ID..."
    idBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    idBox.Text = settingsConfig.discordUserId
    idBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    idBox.Font = Enum.Font.Gotham
    idBox.TextSize = 10
    idBox.Parent = pages["Webhook"]
    Instance.new("UICorner", idBox).CornerRadius = UDim.new(0, 6)
    idBox.FocusLost:Connect(function()
        settingsConfig.discordUserId = idBox.Text
        saveSettings()
    end)

    local cdLabel = Instance.new("TextLabel")
    cdLabel.Size = UDim2.new(1, 0, 0, 18)
    cdLabel.Position = UDim2.new(0, 0, 0, 132)
    cdLabel.BackgroundTransparency = 1
    cdLabel.Text = "Webhook Cooldown (Seconds):"
    cdLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    cdLabel.Font = Enum.Font.GothamBold
    cdLabel.TextSize = 10
    cdLabel.TextXAlignment = Enum.TextXAlignment.Left
    cdLabel.Parent = pages["Webhook"]

    local cdBox = Instance.new("TextBox")
    cdBox.Size = UDim2.new(1, 0, 0, 28)
    cdBox.Position = UDim2.new(0, 0, 0, 154)
    cdBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    cdBox.PlaceholderText = "Cooldown in seconds (e.g., 30)..."
    cdBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    cdBox.Text = tostring(settingsConfig.webhookCooldown)
    cdBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    cdBox.Font = Enum.Font.Gotham
    cdBox.TextSize = 10
    cdBox.Parent = pages["Webhook"]
    Instance.new("UICorner", cdBox).CornerRadius = UDim.new(0, 6)
    cdBox.FocusLost:Connect(function()
        local num = tonumber(cdBox.Text)
        if num then
            settingsConfig.webhookCooldown = num
            saveSettings()
        else
            cdBox.Text = tostring(settingsConfig.webhookCooldown)
        end
    end)

    tgg(pages["Misc"], "Anti AFK", 0, "afk")
    tgg(pages["Misc"], "Anti Fling", 38, "antifling")
    tgg(pages["Misc"], "Auto Grab Gun", 76, "gun")
    tgg(pages["Misc"], "Auto Rejoin", 114, "autoRejoin")

    local fb = Instance.new("TextButton")
    fb.Size = UDim2.new(0, 75, 0, 36)
    fb.Position = UDim2.new(0, 15, 0.3, 0)
    fb.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    fb.Text = "close"
    fb.TextColor3 = Color3.fromRGB(255, 255, 255)
    fb.Font = Enum.Font.GothamBold
    fb.TextSize = 12
    fb.Parent = sg
    fb.ZIndex = 99999
    fb.Active = true
    fb.Draggable = true
    Instance.new("UICorner", fb).CornerRadius = UDim.new(0, 8)
    local fbStroke = Instance.new("UIStroke", fb)
    fbStroke.Color = Color3.fromRGB(255, 255, 255)
    fbStroke.Thickness = 1
    fbStroke.Transparency = 0.3

    local isOpen = true
    fb.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            f.Visible = true
            TweenService:Create(f, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
                Size = UDim2.new(0, 420, 0, 380)
            }):Play()
            fb.Text = "close"
        else
            TweenService:Create(f, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                Size = UDim2.new(0, 420, 0, 0)
            }):Play()
            task.delay(0.25, function()
                if not isOpen then f.Visible = false end
            end)
            fb.Text = "open"
        end
    end)
    return st
end

buildUI()

local activeAimbot = false

RunService.RenderStepped:Connect(function()
    local char = LP.Character
    if char then
        local gunEquipped = char:FindFirstChild("Gun") ~= nil
        if gunEquipped and not isZoomed then
            toggleMobileZoom(true)
        elseif not gunEquipped and isZoomed then
            toggleMobileZoom(false)
        end
    end

    if activeAimbot then
        local mur = getMurd()
        if mur and mur.Character then
            local mHead = mur.Character:FindFirstChild("Head") or mur.Character:FindFirstChild("HumanoidRootPart")
            if mHead then
                pcall(function()
                    Camera.CFrame = CFrame.new(Camera.CFrame.Position, mHead.Position)
                end)
            end
        end
    end
end)

local function alive()
    local c = LP.Character
    return c and c:FindFirstChild("Humanoid") and c.Humanoid.Health > 0
        and c:FindFirstChild("HumanoidRootPart")
end

local function findTool(name)
    local char, bp = LP.Character, LP:FindFirstChild("Backpack")
    if char and char:FindFirstChild(name) then return char[name] end
    if bp and bp:FindFirstChild(name) then return bp[name] end
    return nil
end

local function equipTool(name)
    local char = LP.Character
    local bp = LP:FindFirstChild("Backpack")
    if not char then return nil end
    
    local existing = char:FindFirstChild(name)
    if existing then return existing end
    
    local tool = bp and bp:FindFirstChild(name)
    if tool then
        pcall(function()
            tool.Parent = char
        end)
        task.wait(0.15)
        return char:FindFirstChild(name)
    end
    return nil
end

local function getRole()
    if findTool("Knife") then return "Murderer" end
    if findTool("Gun") then return "Sheriff" end
    return "Innocent"
end

local function getCoins()
    local coins = {}
    for _, map in ipairs(Workspace:GetChildren()) do
        local cc = map:FindFirstChild("CoinContainer")
        if not cc and map.Name == "CoinContainer" then cc = map end
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

local function cancelFarmTween()
    if currentFarmTween then
        pcall(function() currentFarmTween:Cancel() end)
        currentFarmTween = nil
    end
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
        root.CFrame = HIDE_POS
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
end

local function shootMurdererUntilDeathOrSuccess()
    standUp()
    task.wait(0.2)

    local gun = equipTool("Gun")
    if not gun then
        for i = 1, 15 do
            task.wait(0.15)
            gun = equipTool("Gun")
            if gun then break end
        end
    end
    if not gun then return false end

    activeAimbot = true
    local killed = false

    while alive() and not killed do
        local mur = getMurd()
        if not mur or not mur.Character then
            killed = true
            break
        end

        local mHum = mur.Character:FindFirstChildOfClass("Humanoid")
        if not mHum or mHum.Health <= 0 then
            killed = true
            break
        end

        local mr = mur.Character:FindFirstChild("HumanoidRootPart")
        local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        
        if not mr or not myRoot then
            task.wait(0.15)
            continue
        end

        if gun.Parent ~= LP.Character then
            gun.Parent = LP.Character
        end

        myRoot.CFrame = mr.CFrame * CFrame.new(0, 0, 4)
        myRoot.AssemblyLinearVelocity = Vector3.zero
        myRoot.AssemblyAngularVelocity = Vector3.zero

        pcall(function()
            gun:Activate()
        end)

        pcall(function()
            local vp = Camera.ViewportSize
            local cx, cy = vp.X / 2, vp.Y / 2
            VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, true, game, 1)
            task.wait(0.02)
            VirtualInputManager:SendMouseButtonEvent(cx, cy, 0, false, game, 1)
        end)

        task.wait(0.08)
    end

    activeAimbot = false
    hideSky()
    return killed
end

local function autoKillAllPlayers()
    standUp()
    task.wait(0.1)
    local knife = equipTool("Knife")
    if not knife then
        for i = 1, 10 do
            task.wait(0.15)
            knife = equipTool("Knife")
            if knife then break end
        end
    end
    if not knife then return end

    local myRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local tHum = plr.Character:FindFirstChildOfClass("Humanoid")
            local tRoot = plr.Character:FindFirstChild("HumanoidRootPart")
            if tHum and tHum.Health > 0 and tRoot then
                local tStart = tick()
                while tick() - tStart < 0.7 and tHum.Health > 0 and tRoot.Parent and myRoot.Parent and alive() do
                    if knife.Parent ~= LP.Character then knife.Parent = LP.Character end
                    myRoot.CFrame = tRoot.CFrame * CFrame.new(0, 0, 2.2)
                    myRoot.AssemblyLinearVelocity = Vector3.zero
                    myRoot.AssemblyAngularVelocity = Vector3.zero

                    pcall(function() knife:Activate() end)
                    pcall(function()
                        for _, v in ipairs(ReplicatedStorage:GetDescendants()) do
                            if v:IsA("RemoteEvent") and (string.lower(v.Name):find("knife") or string.lower(v.Name):find("hit") or string.lower(v.Name):find("stab") or string.lower(v.Name):find("kill")) then
                                v:FireServer(tRoot.Position)
                            end
                        end
                    end)
                    task.wait(0.05)
                end
            end
        end
    end
    hideSky()
end

-- Role-based execution strictly triggered when the bag is full
local function runBagFullAction()
    if busy then return end
    if not bagFull and currentCoinCount < MIN_BAG_FULL then return end

    busy = true
    isExecutingAction = true
    cancelFarmTween()
    bagFull = true

    standUp()

    local role = getRole()
    totalCoinsEarned = totalCoinsEarned + currentCoinCount

    pcall(function()
        if role == "Sheriff" then
            if state.autoShootMur then
                shootMurdererUntilDeathOrSuccess()
            end
            if state.autoResetSheriff then
                triggerMenuReset()
                task.wait(1.8)
            end
        elseif role == "Murderer" then
            if state.autoKillAll then
                autoKillAllPlayers()
                task.wait(0.5)
            end
            if state.autoResetMurderer then
                triggerMenuReset()
                task.wait(1.8)
            end
        elseif role == "Innocent" then
            if state.autoFlingMur then
                -- Optional behavior or pass
            end
            if state.autoResetInnocent then
                triggerMenuReset()
                task.wait(1.8)
            end
        end
    end)

    hideSky()
    busy = false
    isExecutingAction = false
    bagFull = false
end

task.spawn(function()
    local ok, remote = pcall(function()
        return ReplicatedStorage:WaitForChild("Remotes", 12)
            :WaitForChild("Gameplay", 12)
            :WaitForChild("CoinCollected", 12)
    end)
    if ok and remote then
        remote.OnClientEvent:Connect(function(_, currentCoins, maxCoins)
            if typeof(currentCoins) == "number" then
                currentCoinCount = math.clamp(currentCoins, 0, 50)
            end
            if typeof(maxCoins) == "number" and maxCoins >= 30 and maxCoins <= 50 then
                maxCoinCount = maxCoins
            end
            if typeof(currentCoins) ~= "number" then return end

            if currentCoins <= 0 then
                bagFull = false
                return
            end

            if (currentCoins == 40 or currentCoins == 50 or (typeof(maxCoins) == "number" and currentCoins >= maxCoins)) and currentCoins >= MIN_BAG_FULL then
                bagFull = true
                task.spawn(runBagFullAction)
            end
        end)
    end
end)

RunService.Stepped:Connect(function()
    if LP.Character and not bagFull and not isExecutingAction and not isLobby() then
        for _, val in ipairs(LP.Character:GetDescendants()) do
            if val:IsA("BasePart") then val.CanCollide = false end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.03)
        if not alive() or bagFull or isExecutingAction then continue end
        if isLobby() then continue end
        local root = LP.Character:FindFirstChild("HumanoidRootPart")
        if not root then continue end
        local pos = root.Position
        for _, coin in ipairs(getCoins()) do
            if (pos - coin.Position).Magnitude <= AURA_RADIUS + 3 then
                collectCoin(root, coin)
            end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.05)
        if not alive() then
            cancelFarmTween()
            continue
        end

        local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if not root or not humanoid then continue end

        if bagFull or isExecutingAction then
            cancelFarmTween()
            root.Anchored = false
            continue
        end

        -- Hide at HIDE_POS (0, 300, 0) during lobby/intermission before any coins spawn
        if isLobby() then
            cancelFarmTween()
            root.Anchored = false
            humanoid.PlatformStand = true
            humanoid.AutoRotate = false
            root.CFrame = HIDE_POS
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
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
        if not closestCoin then continue end

        if (root.Position - closestCoin.Position).Magnitude <= AURA_RADIUS + 1 then
            collectCoin(root, closestCoin)
            root.CFrame = CFrame.new(closestCoin.Position.X, closestCoin.Position.Y - UNDER, closestCoin.Position.Z) * CFrame.Angles(math.rad(90), 0, math.rad(180))
            task.wait(0.05)
            continue
        end

        if currentFarmTween and currentFarmTween.PlaybackState == Enum.PlaybackState.Playing then
            collectCoin(root, closestCoin)
            continue
        end

        cancelFarmTween()

        local targetPos = closestCoin.Position - Vector3.new(0, UNDER, 0)
        local targetCFrame = CFrame.new(targetPos) * CFrame.Angles(math.rad(90), 0, math.rad(180))
        local distance = (root.Position - targetPos).Magnitude
        local duration = math.clamp(distance / TWEEN_SPEED, 0.08, 4)

        currentFarmTween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = targetCFrame })
        currentFarmTween:Play()

        local conn
        conn = RunService.Heartbeat:Connect(function()
            if not root.Parent then
                if conn then conn:Disconnect() end
                return
            end
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
        end)

        currentFarmTween.Completed:Wait()
        if conn then conn:Disconnect() end
        currentFarmTween = nil
    end
end)

RunService.Heartbeat:Connect(function()
    if not state.gun or not alive() or isExecutingAction then return end
    if findTool("Gun") then return end
    local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not root then return end
    for _, v in pairs(Workspace:GetDescendants()) do
        if v.Name == "GunDrop" and v:IsA("BasePart") then
            pcall(function()
                v.CFrame = root.CFrame
                firetouchinterest(root, v, 0)
                firetouchinterest(root, v, 1)
            end)
            break
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

print("AWhub Fully Loaded: enjoy 😉 (made by word)")