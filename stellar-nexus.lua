--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                                          ║
    ║    ███████╗████████╗███████╗██╗    ██╗         █████╗ ██████╗    ║
    ║    ██╔════╝ ╚══██╔══╝██╔════╝██║    ██║        ██╔══██╗██╔══██╗  ║
    ║    ███████╗    ██║   █████╗   ██║    ██║        ███████║██████╔╝  ║
    ║    ╚════██║    ██║   ██╔══╝   ██║    ██║        ██╔══██║██╔══██╗  ║
    ║    ███████║    ██║   ███████╗ ███████╗███████╗██║  ██║██║   ██║  ║
    ║    ╚══════╝    ╚═╝   ╚══════╝ ╚══════╝╚══════╝╚═╝  ╚═╝╚═╝   ╚═╝  ║
    ║                                                                          ║
    ║              ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗           ║
    ║              ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝          ║
    ║              ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗           ║
    ║              ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║          ║
    ║              ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║         ║
    ║              ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝          ║
    ║
    ║                 FISH IT MODULE - VERSION 2.0.0                           ║
    ║                   CREATED BY: Lucky Praditya                             ║
    ║              ✦ WITH DISCORD WEBHOOK INTEGRATION ✦                       ║
    ║                                                                          ║
    ╚═══════════════════════════════════════════════════════════════╝

-- ================================================================
-- 🔧 INITIALIZATION & SERVICES
-- ================================================================

local StellarSystem = {
    Name = "Stellar System | Fish It",
    Version = "1.0.0 [BETA]",
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

-- ================================================================
-- 📦 SYSTEM VARIABLES
-- ================================================================

local System = {
    -- Auto Toggles
    AutoFishing = false,
    AutoSell = false,
    AutoQuest = false,
    AutoRejoin = false,
    
    -- Fishing Settings
    PerfectCast = false,
    InstantReel = false,
    CastDelay = 4,
    
    -- Webhook Settings
    WebhookEnabled = false,
    DiscordID = "",
    WebhookURL = "",
    TierFilters = {
        Common = false,
        Uncommon = false,
        Rare = false,
        Epic = false,
        Legendary = false,
        Mythic = false,
        Secret = false
    },
    VariantFilter = "All",
    NameFilter = "All",
    
    -- Stats
    FishCaught = 0,
    MoneyEarned = 0,
    TotalCasts = 0,
    
    -- Anti-Detection
    LastAction = 0,
    SessionStart = os.time()
}

-- ================================================================
-- 🛡️ ANTI-DETECTION SYSTEM (BYPASS CHEATING DETECTION)
-- ================================================================

local AntiDetection = {}

function AntiDetection:RandomDelay(min, max)
    local delay = math.random(min * 10, max * 10) / 10
    wait(delay)
    return delay
end

function AntiDetection:HumanizePower()
    -- Base power 85-100 (perfect range)
    local power = math.random(85, 100)
    
    -- 8% chance to "miss" (simulate human error)
    if math.random(1, 100) <= 8 then
        power = math.random(40, 75)
    end
    
    -- 3% chance to "perfect cast" (exactly 100)
    if math.random(1, 100) <= 3 then
        power = 100
    end
    
    return power
end

function AntiDetection:ShouldTakeBreak()
    -- Take a break every 5-10 minutes (like human)
    local sessionLength = os.time() - System.SessionStart
    if sessionLength > math.random(300, 600) then
        System.SessionStart = os.time()
        local breakTime = math.random(15, 45) -- 15-45 seconds break
        print("[Stellar] Taking a short break... (" .. breakTime .. "s)")
        wait(breakTime)
        return true
    end
    return false
end

function AntiDetection:RandomizeCastDelay()
    -- Random delay between 3.5 to 7 seconds (not always same)
    return math.random(35, 70) / 10
end

-- ================================================================
-- 🎣 FISHING CORE (UNDETECTED)
-- ================================================================

local FishingCore = {}

-- Detect remotes
local function findRemotes()
    local remotes = {}
    for _, obj in ipairs(Services.ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            remotes[obj.Name] = obj
        end
    end
    return remotes
end

local Remotes = findRemotes()

function FishingCore:Cast()
    local castRemote = Remotes["CastRod"] or Remotes["StartFishing"]
    if not castRemote then return false end
    
    -- Use humanized power (not always 100)
    local power = System.PerfectCast and AntiDetection:HumanizePower() or math.random(60, 95)
    
    if castRemote:IsA("RemoteEvent") then
        castRemote:FireServer(power)
    end
    
    System.TotalCasts = System.TotalCasts + 1
    return true
end

function FishingCore:Reel()
    if System.InstantReel then
        -- Simulate fast but not instant reeling
        local reelRemote = Remotes["ReelFish"]
        if reelRemote then
            -- Progressive reeling (not instant)
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
    -- Check UI indicator
    local biteIndicator = Player.PlayerGui:FindFirstChild("BiteIndicator", true)
    if biteIndicator and biteIndicator.Visible then
        return true
    end
    
    -- Check attribute
    if Player:GetAttribute("FishBiting") == true then
        return true
    end
    
    return false
end

function FishingCore:AutoFishLoop()
    while System.AutoFishing do
        -- Take random breaks to avoid detection
        if AntiDetection:ShouldTakeBreak() then
            -- Continue after break
        end
        
        -- Cast rod
        FishingCore:Cast()
        
        -- Wait for bite with random timeout
        local timeout = 0
        local maxTimeout = math.random(80, 120) / 10 -- 8-12 seconds
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
        
        -- Random delay between casts
        local delay = System.CastDelay
        if System.CastDelay == 0 then
            delay = AntiDetection:RandomizeCastDelay()
        end
        wait(delay)
    end
end

-- ================================================================
-- 📡 WEBHOOK SYSTEM (Match Your UI Design)
-- ================================================================

local WebhookSystem = {}

function WebhookSystem:SendToDiscord(fishData)
    if not System.WebhookEnabled or System.WebhookURL == "" then 
        return false 
    end
    
    -- Check tier filter
    local tierName = fishData.Rarity:gsub("^%l", string.upper)
    if not System.TierFilters[tierName] and tierName ~= "Secret" then
        return false
    end
    
    -- Build embed
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
    
    -- Mention if Discord ID provided
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
        PlayerName = Player.Name,
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
-- 🎨 GUI (EXACT MATCH YOUR DESIGN)
-- ================================================================

local GUI = {}

function GUI:CreateMainWindow()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StellarSystem"
    screenGui.Parent = Services.CoreGui or Player.PlayerGui
    
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
    
    -- Tab Menu
    local tabButtons = {
        {name = "Info", pos = 0.02},
        {name = "Fishing", pos = 0.19},
        {name = "Automatically", pos = 0.36},
        {name = "Menu", pos = 0.53},
        {name = "Quest", pos = 0.65},
        {name = "Webhook", pos = 0.77},
        {name = "Config", pos = 0.89}
    }
    
    local tabs = {}
    local currentTab = nil
    
    local function createTabButton(name, xPos)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 60, 0, 35)
        btn.Position = UDim2.new(xPos, 0, 0, 55)
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
    
    -- Content Frame
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -115)
    contentFrame.Position = UDim2.new(0, 10, 0, 100)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- === TAB 1: INFO ===
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
    
    -- Discord Link
    local discordBtn = Instance.new("TextButton")
    discordBtn.Size = UDim2.new(0.8, 0, 0, 40)
    discordBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
    discordBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    discordBtn.Text = "Copy Link Discord"
    discordBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordBtn.Font = Enum.Font.GothamBold
    discordBtn.TextSize = 14
    discordBtn.Parent = infoBg
    
    local discordCorners = Instance.new("UICorner")
    discordCorners.CornerRadius = UDim.new(0, 8)
    discordCorners.Parent = discordBtn
    
    discordBtn.MouseButton1Click:Connect(function()
        setclipboard("https://discord.gg/stellarsystem")
        print("[Stellar] Discord link copied!")
    end)
    
    -- === TAB 2: FISHING ===
    local fishingContent = Instance.new("Frame")
    fishingContent.Size = UDim2.new(1, 0, 1, 0)
    fishingContent.BackgroundTransparency = 1
    fishingContent.Visible = false
    fishingContent.Parent = contentFrame
    
    local function createToggleButton(parent, text, y, varName, callback)
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
            if callback then callback(System[varName]) end
        end)
        
        return btn
    end
    
    createToggleButton(fishingContent, "🔁 Auto Fishing", 10, "AutoFishing", function(val)
        if val then spawn(FishingCore.AutoFishLoop) end
    end)
    
    createToggleButton(fishingContent, "🎯 Perfect Cast", 60, "PerfectCast")
    createToggleButton(fishingContent, "⚡ Instant Reel", 110, "InstantReel")
    
    -- === TAB 3: AUTOMATICALLY ===
    local autoContent = Instance.new("Frame")
    autoContent.Size = UDim2.new(1, 0, 1, 0)
    autoContent.BackgroundTransparency = 1
    autoContent.Visible = false
    autoContent.Parent = contentFrame
    
    createToggleButton(autoContent, "💰 Auto Sell", 10, "AutoSell")
    createToggleButton(autoContent, "🔄 Auto Rejoin", 60, "AutoRejoin")
    
    -- === TAB 4: MENU (Settings) ===
    local menuContent = Instance.new("Frame")
    menuContent.Size = UDim2.new(1, 0, 1, 0)
    menuContent.BackgroundTransparency = 1
    menuContent.Visible = false
    menuContent.Parent = contentFrame
    
    -- === TAB 5: QUEST ===
    local questContent = Instance.new("Frame")
    questContent.Size = UDim2.new(1, 0, 1, 0)
    questContent.BackgroundTransparency = 1
    questContent.Visible = false
    questContent.Parent = contentFrame
    
    createToggleButton(questContent, "📋 Auto Quest", 10, "AutoQuest")
    
    -- === TAB 6: WEBHOOK ===
    local webhookContent = Instance.new("Frame")
    webhookContent.Size = UDim2.new(1, 0, 1, 0)
    webhookContent.BackgroundTransparency = 1
    webhookContent.Visible = false
    webhookContent.Parent = contentFrame
    
    -- Webhook toggle
    local webhookToggle = createToggleButton(webhookContent, "📡 Webhook Fish Caught", 5, "WebhookEnabled")
    
    -- Discord ID Input
    local discordIdLabel = Instance.new("TextLabel")
    discordIdLabel.Size = UDim2.new(0.3, 0, 0, 30)
    discordIdLabel.Position = UDim2.new(0.05, 0, 0, 55)
    discordIdLabel.BackgroundTransparency = 1
    discordIdLabel.Text = "Input ID Discord"
    discordIdLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    discordIdLabel.TextSize = 12
    discordIdLabel.Font = Enum.Font.Gotham
    discordIdLabel.TextXAlignment = Enum.TextXAlignment.Left
    discordIdLabel.Parent = webhookContent
    
    local discordIdInput = Instance.new("TextBox")
    discordIdInput.Size = UDim2.new(0.55, 0, 0, 35)
    discordIdInput.Position = UDim2.new(0.4, 0, 0, 52)
    discordIdInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    discordIdInput.Text = ""
    discordIdInput.PlaceholderText = "Enter Discord User ID"
    discordIdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    discordIdInput.Font = Enum.Font.Gotham
    discordIdInput.TextSize = 12
    discordIdInput.Parent = webhookContent
    
    local idCorners = Instance.new("UICorner")
    idCorners.CornerRadius = UDim.new(0, 6)
    idCorners.Parent = discordIdInput
    
    discordIdInput.FocusLost:Connect(function()
        System.DiscordID = discordIdInput.Text
    end)
    
    -- Webhook URL Input
    local webhookUrlLabel = Instance.new("TextLabel")
    webhookUrlLabel.Size = UDim2.new(0.3, 0, 0, 30)
    webhookUrlLabel.Position = UDim2.new(0.05, 0, 0, 95)
    webhookUrlLabel.BackgroundTransparency = 1
    webhookUrlLabel.Text = "Webhook URL"
    webhookUrlLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    webhookUrlLabel.TextSize = 12
    webhookUrlLabel.Font = Enum.Font.Gotham
    webhookUrlLabel.TextXAlignment = Enum.TextXAlignment.Left
    webhookUrlLabel.Parent = webhookContent
    
    local webhookUrlInput = Instance.new("TextBox")
    webhookUrlInput.Size = UDim2.new(0.55, 0, 0, 35)
    webhookUrlInput.Position = UDim2.new(0.4, 0, 0, 92)
    webhookUrlInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    webhookUrlInput.Text = ""
    webhookUrlInput.PlaceholderText = "https://discord.com/api/webhooks/..."
    webhookUrlInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    webhookUrlInput.Font = Enum.Font.Gotham
    webhookUrlInput.TextSize = 11
    webhookUrlInput.Parent = webhookContent
    
    local urlCorners = Instance.new("UICorner")
    urlCorners.CornerRadius = UDim.new(0, 6)
    urlCorners.Parent = webhookUrlInput
    
    webhookUrlInput.FocusLost:Connect(function()
        System.WebhookURL = webhookUrlInput.Text
    end)
    
    -- Tier Filter Label
    local tierLabel = Instance.new("TextLabel")
    tierLabel.Size = UDim2.new(1, -20, 0, 30)
    tierLabel.Position = UDim2.new(0, 10, 0, 140)
    tierLabel.BackgroundTransparency = 1
    tierLabel.Text = "Tier Filter"
    tierLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
    tierLabel.TextSize = 13
    tierLabel.Font = Enum.Font.GothamBold
    tierLabel.TextXAlignment = Enum.TextXAlignment.Left
    tierLabel.Parent = webhookContent
    
    -- Tier Filter Buttons (Multi-select)
    local tiers = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"}
    local tierBtns = {}
    
    for i, tier in ipairs(tiers) do
        local row = math.floor((i-1) / 3)
        local col = (i-1) % 3
        local xPos = 0.05 + (col * 0.31)
        local yPos = 175 + (row * 40)
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.28, 0, 0, 32)
        btn.Position = UDim2.new(xPos, 0, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        btn.Text = "⬜ " .. tier
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.Parent = webhookContent
        
        local btnCorners = Instance.new("UICorner")
        btnCorners.CornerRadius = UDim.new(0, 6)
        btnCorners.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            System.TierFilters[tier] = not System.TierFilters[tier]
            btn.Text = (System.TierFilters[tier] and "✅ " or "⬜ ") .. tier
            btn.BackgroundColor3 = System.TierFilters[tier] and Color3.fromRGB(80, 120, 80) or Color3.fromRGB(50, 50, 70)
        end)
        
        tierBtns[tier] = btn
    end
    
    -- Variant Filter
    local variantLabel = Instance.new("TextLabel")
    variantLabel.Size = UDim2.new(0.3, 0, 0, 30)
    variantLabel.Position = UDim2.new(0.05, 0, 0, 260)
    variantLabel.BackgroundTransparency = 1
    variantLabel.Text = "Variant Filter"
    variantLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    variantLabel.TextSize = 12
    variantLabel.Font = Enum.Font.Gotham
    variantLabel.TextXAlignment = Enum.TextXAlignment.Left
    variantLabel.Parent = webhookContent
    
    local variantDropdown = Instance.new("TextButton")
    variantDropdown.Size = UDim2.new(0.4, 0, 0, 32)
    variantDropdown.Position = UDim2.new(0.4, 0, 0, 257)
    variantDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    variantDropdown.Text = "Select Options ▼"
    variantDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    variantDropdown.Font = Enum.Font.Gotham
    variantDropdown.TextSize = 12
    variantDropdown.Parent = webhookContent
    
    local variantCorners = Instance.new("UICorner")
    variantCorners.CornerRadius = UDim.new(0, 6)
    variantCorners.Parent = variantDropdown
    
    -- Name Filter
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(0.3, 0, 0, 30)
    nameLabel.Position = UDim2.new(0.05, 0, 0, 300)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = "Name Filter"
    nameLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    nameLabel.TextSize = 12
    nameLabel.Font = Enum.Font.Gotham
    nameLabel.TextXAlignment = Enum.TextXAlignment.Left
    nameLabel.Parent = webhookContent
    
    local nameDropdown = Instance.new("TextButton")
    nameDropdown.Size = UDim2.new(0.4, 0, 0, 32)
    nameDropdown.Position = UDim2.new(0.4, 0, 0, 297)
    nameDropdown.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    nameDropdown.Text = "Select Options ▼"
    nameDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameDropdown.Font = Enum.Font.Gotham
    nameDropdown.TextSize = 12
    nameDropdown.Parent = webhookContent
    
    local nameCorners = Instance.new("UICorner")
    nameCorners.CornerRadius = UDim.new(0, 6)
    nameCorners.Parent = nameDropdown
    
    -- Test Webhook Button
    local testBtn = Instance.new("TextButton")
    testBtn.Size = UDim2.new(0.4, 0, 0, 40)
    testBtn.Position = UDim2.new(0.05, 0, 0, 350)
    testBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
    testBtn.Text = "Test Webhook Connection"
    testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    testBtn.Font = Enum.Font.GothamBold
    testBtn.TextSize = 12
    testBtn.Parent = webhookContent
    
    local testCorners = Instance.new("UICorner")
    testCorners.CornerRadius = UDim.new(0, 8)
    testCorners.Parent = testBtn
    
    testBtn.MouseButton1Click:Connect(function()
        if System.WebhookURL == "" then
            webhookUrlInput.PlaceholderText = "⚠️ SET URL FIRST!"
            webhookUrlInput.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            wait(2)
            webhookUrlInput.PlaceholderText = "https://discord.com/api/webhooks/..."
            webhookUrlInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        else
            WebhookSystem:TestConnection()
            testBtn.Text = "✓ Test Sent!"
            testBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
            wait(1.5)
            testBtn.Text = "Test Webhook Connection"
            testBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
        end
    end)
    
    -- === TAB 7: CONFIG ===
    local configContent = Instance.new("Frame")
    configContent.Size = UDim2.new(1, 0, 1, 0)
    configContent.BackgroundTransparency = 1
    configContent.Visible = false
    configContent.Parent = contentFrame
    
    -- Tab switching
    local tabFrames = {
        Info = infoContent,
        Fishing = fishingContent,
        Automatically = autoContent,
        Menu = menuContent,
        Quest = questContent,
        Webhook = webhookContent,
        Config = configContent
    }
    
    local tabButtonsList = {}
    for _, tab in ipairs(tabButtons) do
        local btn = createTabButton(tab.name, tab.pos)
        tabButtonsList[tab.name] = btn
        
        btn.MouseButton1Click:Connect(function()
            for name, frame in pairs(tabFrames) do
                frame.Visible = (name == tab.name)
            end
            for name, button in pairs(tabButtonsList) do
                button.BackgroundColor3 = (name == tab.name) and Color3.fromRGB(100, 50, 200) or Color3.fromRGB(60, 60, 80)
            end
        end)
    end
    
    -- Set default visible tab
    infoContent.Visible = true
    tabButtonsList.Info.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
    
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
    
    print("[Stellar System] Ready! Status: UNDETECTED")
    print("═══════════════════════════════════════════════════════════════")
end

Initialize()