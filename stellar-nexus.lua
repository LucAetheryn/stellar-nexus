--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                    STELLAR SYSTEM | FISH IT                   ║
    ║                      VERSION 2.0.1 [FIXED]                    ║
    ║                       OWNER: LUCKY PRADITYA                   ║
    ╚═══════════════════════════════════════════════════════════════╝
--]]

-- ================================================================
-- 🔧 INITIALIZATION & SERVICES
-- ================================================================

print("[DEBUG] Script started loading...")

local StellarSystem = {
    Name = "Stellar System | Fish It",
    Version = "2.0.1 [FIXED]",
    Owner = "Lucky Praditya",
    Status = "Undetected",
    LastUpdate = "May 14, 2026"
}

local Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    CoreGui = game:GetService("CoreGui"),
    HttpService = game:GetService("HttpService")
}

local Player = Services.Players.LocalPlayer
print("[DEBUG] Player found: " .. Player.Name)

-- ================================================================
-- 📦 SYSTEM VARIABLES
-- ================================================================

local System = {
    AutoFishing = false,
    AutoSell = false,
    AutoQuest = false,
    AutoRejoin = false,
    PerfectCast = false,
    InstantReel = false,
    CastDelay = 4,
    WebhookEnabled = false,
    DiscordID = "",
    WebhookURL = "",
    TierFilters = {
        Common = false, Uncommon = false, Rare = false,
        Epic = false, Legendary = false, Mythic = false, Secret = false
    },
    VariantFilter = "All",
    NameFilter = "All",
    FishCaught = 0,
    MoneyEarned = 0,
    TotalCasts = 0,
    LastAction = 0,
    SessionStart = os.time()
}

-- ================================================================
-- 🛡️ ANTI-DETECTION SYSTEM
-- ================================================================

local AntiDetection = {}

function AntiDetection:RandomDelay(min, max)
    local delay = math.random(min * 10, max * 10) / 10
    wait(delay)
    return delay
end

function AntiDetection:HumanizePower()
    local power = math.random(85, 100)
    if math.random(1, 100) <= 8 then
        power = math.random(40, 75)
    end
    if math.random(1, 100) <= 3 then
        power = 100
    end
    return power
end

function AntiDetection:ShouldTakeBreak()
    local sessionLength = os.time() - System.SessionStart
    if sessionLength > math.random(300, 600) then
        System.SessionStart = os.time()
        local breakTime = math.random(15, 45)
        print("[Stellar] Taking a short break... (" .. breakTime .. "s)")
        wait(breakTime)
        return true
    end
    return false
end

function AntiDetection:RandomizeCastDelay()
    return math.random(35, 70) / 10
end

-- ================================================================
-- 🎣 FISHING CORE
-- ================================================================

local FishingCore = {}

local function findRemotes()
    local remotes = {}
    for _, obj in ipairs(Services.ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            remotes[obj.Name] = obj
            print("[DEBUG] Found remote: " .. obj.Name)
        end
    end
    return remotes
end

local Remotes = findRemotes()
print("[DEBUG] Total remotes found: " .. table.getn(Remotes))

function FishingCore:Cast()
    local castRemote = Remotes["CastRod"] or Remotes["StartFishing"]
    if not castRemote then 
        print("[DEBUG] Cast remote not found!")
        return false 
    end
    local power = System.PerfectCast and AntiDetection:HumanizePower() or math.random(60, 95)
    if castRemote:IsA("RemoteEvent") then
        castRemote:FireServer(power)
    end
    System.TotalCasts = System.TotalCasts + 1
    return true
end

function FishingCore:Reel()
    if System.InstantReel then
        local reelRemote = Remotes["ReelFish"]
        if reelRemote then
            for i = 1, 5 do
                reelRemote:FireServer(i * 20)
                wait(0.05)
            end
            System.FishCaught = System.FishCaught + 1
            return true
        end
    end
    return false
end

function FishingCore:DetectBite()
    local biteIndicator = Player.PlayerGui:FindFirstChild("BiteIndicator", true)
    if biteIndicator and biteIndicator.Visible then
        return true
    end
    if Player:GetAttribute("FishBiting") == true then
        return true
    end
    return false
end

function FishingCore:AutoFishLoop()
    while System.AutoFishing do
        if AntiDetection:ShouldTakeBreak() then end
        FishingCore:Cast()
        local timeout = 0
        local maxTimeout = math.random(80, 120) / 10
        local hasBite = false
        while timeout < maxTimeout and not hasBite and System.AutoFishing do
            hasBite = FishingCore:DetectBite()
            wait(0.5)
            timeout = timeout + 0.5
        end
        if hasBite then
            FishingCore:Reel()
            wait(0.3)
        end
        local delay = System.CastDelay
        if System.CastDelay == 0 then
            delay = AntiDetection:RandomizeCastDelay()
        end
        wait(delay)
    end
end

-- ================================================================
-- 📡 WEBHOOK SYSTEM
-- ================================================================

local WebhookSystem = {}

function WebhookSystem:SendToDiscord(fishData)
    if not System.WebhookEnabled or System.WebhookURL == "" then 
        return false 
    end
    local tierName = fishData.Rarity:gsub("^%l", string.upper)
    if not System.TierFilters[tierName] and tierName ~= "Secret" then
        return false
    end
    local embed = {
        title = "✨ Stellar System | " .. fishData.Rarity .. " Catch! ✨",
        description = "**Congratulations!!** You have obtained a new **" .. fishData.Rarity .. " fish**!",
        color = fishData.Rarity == "LEGENDARY" and 16766720 or 10181046,
        fields = {
            {name = "Player Name", value = Player.Name, inline = true},
            {name = "Fish Name", value = fishData.FishName, inline = true},
            {name = "Fish Tier", value = fishData.Rarity, inline = true},
            {name = "Weight", value = fishData.Weight, inline = true},
            {name = "Mutation", value = fishData.Mutation or "None", inline = true},
            {name = "Value", value = "$" .. fishData.Value, inline = true},
            {name = "Location", value = fishData.Location, inline = false}
        },
        footer = {text = "Stellar System • " .. os.date("%I:%M:%S %p")},
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    }
    local content = nil
    if System.DiscordID ~= "" and fishData.Rarity == "LEGENDARY" then
        content = "<@" .. System.DiscordID .. "> **LEGENDARY FISH CAUGHT!**"
    end
    local payload = {content = content, embeds = {embed}}
    pcall(function()
        local data = Services.HttpService:JSONEncode(payload)
        request({
            Url = System.WebhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = data
        })
    end)
    return true
end

function WebhookSystem:TestConnection()
    if System.WebhookURL == "" then
        print("[Stellar] Please set Webhook URL first!")
        return false
    end
    local testData = {
        FishName = "Test Connection",
        Rarity = "SYSTEM",
        Weight = "0kg",
        Mutation = "None",
        Value = "0",
        Location = "Stellar System"
    }
    return WebhookSystem:SendToDiscord(testData)
end

-- ================================================================
-- 🎨 GUI (FIXED - DENGAN DEBUG)
-- ================================================================

local GUI = {}

function GUI:CreateMainWindow()
    print("[DEBUG] Creating GUI...")
    
    -- 🔥 FIX: Coba multiple parent options
    local guiParent = nil
    
    -- Option 1: Try CoreGui
    local success, coreGui = pcall(function()
        return Services.CoreGui
    end)
    if success and coreGui then
        guiParent = coreGui
        print("[DEBUG] Using CoreGui")
    end
    
    -- Option 2: Try PlayerGui (most reliable)
    if not guiParent then
        guiParent = Player:FindFirstChild("PlayerGui")
        if not guiParent then
            guiParent = Instance.new("ScreenGui")
            guiParent.Name = "TempGui"
            guiParent.Parent = Player
            wait(0.5)
            guiParent = Player:FindFirstChild("PlayerGui") or Player
        end
        print("[DEBUG] Using PlayerGui: " .. tostring(guiParent))
    end
    
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StellarSystem"
    screenGui.ResetOnSpawn = false
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = guiParent
    
    print("[DEBUG] ScreenGui parent set to: " .. tostring(screenGui.Parent))
    
    -- 🔥 FIX: Tambahkan papan penanda bahwa GUI berhasil dibuat
    local debugText = Instance.new("TextLabel")
    debugText.Size = UDim2.new(0, 200, 0, 30)
    debugText.Position = UDim2.new(0, 10, 0, 10)
    debugText.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    debugText.BackgroundTransparency = 0.5
    debugText.Text = "Stellar System LOADING..."
    debugText.TextColor3 = Color3.fromRGB(255, 255, 0)
    debugText.Font = Enum.Font.GothamBold
    debugText.TextSize = 12
    debugText.Parent = screenGui
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 450, 0, 550)
    mainFrame.Position = UDim2.new(0.5, -225, 0.5, -275)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local corners = Instance.new("UICorner")
    corners.CornerRadius = UDim.new(0, 12)
    corners.Parent = mainFrame
    
    -- Hapus debug text setelah main frame jadi
    debugText:Destroy()
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 50)
    titleBar.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
    titleBar.BackgroundTransparency = 0.15
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorners = Instance.new("UICorner")
    titleCorners.CornerRadius = UDim.new(0, 12)
    titleCorners.Parent = titleBar
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -60, 1, 0)
    titleText.Position = UDim2.new(0, 15, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "Stellar System | Fish It"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextSize = 18
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    -- Draggable functionality
    local dragging = false
    local dragStart, startPos
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
        end
    end)
    
    Services.UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    Services.UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Tab Menu (sederhana untuk test)
    local tabY = 55
    
    local function createTabButton(name, xPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 60, 0, 35)
        btn.Position = UDim2.new(xPos, 0, 0, tabY)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 12
        btn.Parent = mainFrame
        
        local btnCorners = Instance.new("UICorner")
        btnCorners.CornerRadius = UDim.new(0, 6)
        btnCorners.Parent = btn
        
        return btn
    end
    
    local tabButtons = {
        createTabButton("Info", 0.02),
        createTabButton("Fishing", 0.19),
        createTabButton("Auto", 0.36),
        createTabButton("Webhook", 0.60),
        createTabButton("Config", 0.82)
    }
    
    -- Content Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -115)
    contentFrame.Position = UDim2.new(0, 10, 0, 100)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- INFO TAB (Simplified)
    local infoContent = Instance.new("Frame")
    infoContent.Size = UDim2.new(1, 0, 1, 0)
    infoContent.BackgroundTransparency = 1
    infoContent.Parent = contentFrame
    
    local infoBg = Instance.new("Frame")
    infoBg.Size = UDim2.new(1, -20, 1, -20)
    infoBg.Position = UDim2.new(0, 10, 0, 10)
    infoBg.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    infoBg.BackgroundTransparency = 0.3
    infoBg.Parent = infoContent
    
    local infoCorners = Instance.new("UICorner")
    infoCorners.CornerRadius = UDim.new(0, 10)
    infoCorners.Parent = infoBg
    
    local infoTitle = Instance.new("TextLabel")
    infoTitle.Size = UDim2.new(1, -40, 0, 40)
    infoTitle.Position = UDim2.new(0, 20, 0, 20)
    infoTitle.BackgroundTransparency = 1
    infoTitle.Text = "-- Stellar System Hub --"
    infoTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
    infoTitle.TextSize = 18
    infoTitle.Font = Enum.Font.GothamBold
    infoTitle.Parent = infoBg
    
    local infoLines = {
        "Version: " .. StellarSystem.Version,
        "Owner: " .. StellarSystem.Owner,
        "Status: " .. StellarSystem.Status,
        "Last Update: " .. StellarSystem.LastUpdate
    }
    
    for i, line in ipairs(infoLines) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -40, 0, 25)
        label.Position = UDim2.new(0, 20, 0, 70 + (i-1) * 30)
        label.BackgroundTransparency = 1
        label.Text = line
        label.TextColor3 = Color3.fromRGB(200, 200, 200)
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = infoBg
    end
    
    -- FISHING TAB
    local fishingContent = Instance.new("Frame")
    fishingContent.Size = UDim2.new(1, 0, 1, 0)
    fishingContent.BackgroundTransparency = 1
    fishingContent.Visible = false
    fishingContent.Parent = contentFrame
    
    local function createToggleButton(parent, text, y, varName)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 40)
        btn.Position = UDim2.new(0.05, 0, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        btn.Text = text .. " [OFF]"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 13
        btn.Parent = parent
        
        local btnCorners = Instance.new("UICorner")
        btnCorners.CornerRadius = UDim.new(0, 8)
        btnCorners.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            System[varName] = not System[varName]
            btn.BackgroundColor3 = System[varName] and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(60, 60, 80)
            btn.Text = text .. (System[varName] and " [ON]" or " [OFF]")
            if varName == "AutoFishing" and System[varName] then
                spawn(FishingCore.AutoFishLoop)
            end
        end)
        
        return btn
    end
    
    createToggleButton(fishingContent, "🔁 Auto Fishing", 10, "AutoFishing")
    createToggleButton(fishingContent, "🎯 Perfect Cast", 60, "PerfectCast")
    createToggleButton(fishingContent, "⚡ Instant Reel", 110, "InstantReel")
    
    -- AUTO TAB
    local autoContent = Instance.new("Frame")
    autoContent.Size = UDim2.new(1, 0, 1, 0)
    autoContent.BackgroundTransparency = 1
    autoContent.Visible = false
    autoContent.Parent = contentFrame
    
    createToggleButton(autoContent, "💰 Auto Sell", 10, "AutoSell")
    createToggleButton(autoContent, "🔄 Auto Rejoin", 60, "AutoRejoin")
    
    -- WEBHOOK TAB (Simplified)
    local webhookContent = Instance.new("Frame")
    webhookContent.Size = UDim2.new(1, 0, 1, 0)
    webhookContent.BackgroundTransparency = 1
    webhookContent.Visible = false
    webhookContent.Parent = contentFrame
    
    createToggleButton(webhookContent, "📡 Webhook Enabled", 10, "WebhookEnabled")
    
    -- Webhook URL Input
    local urlLabel = Instance.new("TextLabel")
    urlLabel.Size = UDim2.new(0.3, 0, 0, 30)
    urlLabel.Position = UDim2.new(0.05, 0, 0, 60)
    urlLabel.BackgroundTransparency = 1
    urlLabel.Text = "Webhook URL"
    urlLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    urlLabel.TextSize = 12
    urlLabel.Font = Enum.Font.Gotham
    urlLabel.Parent = webhookContent
    
    local urlInput = Instance.new("TextBox")
    urlInput.Size = UDim2.new(0.55, 0, 0, 35)
    urlInput.Position = UDim2.new(0.4, 0, 0, 57)
    urlInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    urlInput.Text = ""
    urlInput.PlaceholderText = "https://discord.com/api/webhooks/..."
    urlInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    urlInput.Font = Enum.Font.Gotham
    urlInput.TextSize = 11
    urlInput.Parent = webhookContent
    
    local urlCorners = Instance.new("UICorner")
    urlCorners.CornerRadius = UDim.new(0, 6)
    urlCorners.Parent = urlInput
    
    urlInput.FocusLost:Connect(function()
        System.WebhookURL = urlInput.Text
    end)
    
    -- Test Button
    local testBtn = Instance.new("TextButton")
    testBtn.Size = UDim2.new(0.4, 0, 0, 40)
    testBtn.Position = UDim2.new(0.05, 0, 0, 110)
    testBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
    testBtn.Text = "Test Webhook"
    testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    testBtn.Font = Enum.Font.GothamBold
    testBtn.TextSize = 12
    testBtn.Parent = webhookContent
    
    local testCorners = Instance.new("UICorner")
    testCorners.CornerRadius = UDim.new(0, 8)
    testCorners.Parent = testBtn
    
    testBtn.MouseButton1Click:Connect(function()
        if System.WebhookURL == "" then
            urlInput.PlaceholderText = "⚠️ SET URL FIRST!"
            urlInput.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            wait(2)
            urlInput.PlaceholderText = "https://discord.com/api/webhooks/..."
            urlInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        else
            WebhookSystem:TestConnection()
            testBtn.Text = "✓ Sent!"
            testBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
            wait(1.5)
            testBtn.Text = "Test Webhook"
            testBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
        end
    end)
    
    -- CONFIG TAB
    local configContent = Instance.new("Frame")
    configContent.Size = UDim2.new(1, 0, 1, 0)
    configContent.BackgroundTransparency = 1
    configContent.Visible = false
    configContent.Parent = contentFrame
    
    local delayLabel = Instance.new("TextLabel")
    delayLabel.Size = UDim2.new(0.5, 0, 0, 30)
    delayLabel.Position = UDim2.new(0.05, 0, 0, 10)
    delayLabel.BackgroundTransparency = 1
    delayLabel.Text = "Cast Delay: " .. System.CastDelay .. "s"
    delayLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    delayLabel.TextSize = 12
    delayLabel.Font = Enum.Font.Gotham
    delayLabel.Parent = configContent
    
    local delaySlider = Instance.new("TextBox")
    delaySlider.Size = UDim2.new(0.3, 0, 0, 35)
    delaySlider.Position = UDim2.new(0.55, 0, 0, 7)
    delaySlider.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    delaySlider.Text = tostring(System.CastDelay)
    delaySlider.TextColor3 = Color3.fromRGB(255, 255, 255)
    delaySlider.Font = Enum.Font.Gotham
    delaySlider.TextSize = 12
    delaySlider.Parent = configContent
    
    local sliderCorners = Instance.new("UICorner")
    sliderCorners.CornerRadius = UDim.new(0, 6)
    sliderCorners.Parent = delaySlider
    
    delaySlider.FocusLost:Connect(function()
        local val = tonumber(delaySlider.Text)
        if val then
            System.CastDelay = math.clamp(val, 1, 10)
            delayLabel.Text = "Cast Delay: " .. System.CastDelay .. "s"
            delaySlider.Text = tostring(System.CastDelay)
        else
            delaySlider.Text = tostring(System.CastDelay)
        end
    end)
    
    -- Tab switching
    local frames = {infoContent, fishingContent, autoContent, webhookContent, configContent}
    
    for i, btn in ipairs(tabButtons) do
        btn.MouseButton1Click:Connect(function()
            for _, frame in ipairs(frames) do
                frame.Visible = false
            end
            frames[i].Visible = true
            for _, b in ipairs(tabButtons) do
                b.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            end
            btn.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
        end)
    end
    
    -- Set default
    infoContent.Visible = true
    tabButtons[1].BackgroundColor3 = Color3.fromRGB(100, 50, 200)
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 35, 0, 35)
    closeBtn.Position = UDim2.new(1, -45, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = mainFrame
    
    local closeCorners = Instance.new("UICorner")
    closeCorners.CornerRadius = UDim.new(0, 8)
    closeCorners.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    print("[DEBUG] GUI created successfully!")
    print("[Stellar System] GUI Loaded - Status: UNDETECTED")
end

-- ================================================================
-- 🚀 INITIALIZATION
-- ================================================================

local function Initialize()
    print("═══════════════════════════════════════════════════════════════")
    print("✦ STELLAR SYSTEM | FISH IT ✦")
    print("Version: " .. StellarSystem.Version)
    print("Owner: " .. StellarSystem.Owner)
    print("Status: " .. StellarSystem.Status)
    print("═══════════════════════════════════════════════════════════════")
    
    -- Setup fish detection for webhook
    local fishReward = Remotes["FishReward"] or Remotes["OnFishCaught"]
    if fishReward and fishReward.OnClientEvent then
        fishReward.OnClientEvent:Connect(function(data)
            local fishInfo = {
                FishName = data.Name or data.FishName or "Unknown",
                Rarity = string.upper(data.Rarity or data.Tier or "COMMON"),
                Weight = (data.Weight or math.random(1, 50)) .. "kg",
                Mutation = data.Mutation or "None",
                Value = data.Value or math.random(100, 5000),
                Location = "Fisherman Island"
            }
            WebhookSystem:SendToDiscord(fishInfo)
            System.FishCaught = System.FishCaught + 1
            System.MoneyEarned = System.MoneyEarned + (data.Value or 0)
        end)
    end
    
    GUI:CreateMainWindow()
    
    print("[Stellar System] Ready! If you see this, script is working.")
    print("═══════════════════════════════════════════════════════════════")
end

-- Start
local success, err = pcall(Initialize)
if not success then
    print("[ERROR] Script failed: " .. tostring(err))
    warn("[ERROR] " .. tostring(err))
end