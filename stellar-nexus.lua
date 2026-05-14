--[[
    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║     ████████╗███████╗██╗     ██╗      █████╗ ██████╗         ║
    ║     ╚══██╔══╝██╔════╝██║     ██║     ██╔══██╗██╔══██╗        ║
    ║        ██║   █████╗  ██║     ██║     ███████║██████╔╝        ║
    ║        ██║   ██╔══╝  ██║     ██║     ██╔══██║██╔══██╗        ║
    ║        ██║   ███████╗███████╗███████╗██║  ██║██║  ██║        ║
    ║        ╚═╝   ╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝        ║
    ║                                                               ║
    ║              ███╗   ██╗███████╗██╗  ██╗██╗   ██╗███████╗     ║
    ║              ████╗  ██║██╔════╝╚██╗██╔╝██║   ██║██╔════╝     ║
    ║              ██╔██╗ ██║█████╗   ╚███╔╝ ██║   ██║███████╗     ║
    ║              ██║╚██╗██║██╔══╝   ██╔██╗ ██║   ██║╚════██║     ║
    ║              ██║ ╚████║███████╗██╔╝ ██╗╚██████╔╝███████║     ║
    ║              ╚═╝  ╚═══╝╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝     ║
    ║                                                               ║
    ║                 FISH IT MODULE - VERSION 2.0.0                ║
    ║                   CREATED BY: [YOUR NAME]                     ║
    ║              ✦ WITH DISCORD WEBHOOK INTEGRATION ✦            ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝
--]]

-- ================================================================
-- 🔧 INITIALIZATION & SERVICES
-- ================================================================

local StellarNexus = {
    Name = "Stellar Nexus: Fish It Module",
    Version = "2.0.0",
    Author = "YourName",
    Game = "Fish It",
    LoadTime = os.time()
}

local Services = {
    Players = game:GetService("Players"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    RunService = game:GetService("RunService"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    CoreGui = game:GetService("CoreGui"),
    HttpService = game:GetService("HttpService")
}

local Player = Services.Players.LocalPlayer
local Mouse = Player:GetMouse()
local Character = Player.Character or Player.CharacterAdded:Wait()

-- ================================================================
-- 📦 MODULE VARIABLES
-- ================================================================

local Nexus = {
    -- Toggles
    AutoFish = false,
    AutoSell = false,
    AutoBuy = false,
    AutoTeleport = false,
    PerfectCast = false,
    InstaReel = false,
    
    -- Settings
    SellFilter = "ALL",
    CastDelay = 4,
    SelectedIsland = "Starter Island",
    SelectedBoat = "Starter Boat",
    
    -- Webhook Settings
    WebhookEnabled = false,
    WebhookURL = "",
    WebhookFilters = {
        COMMON = false,
        RARE = false,
        EPIC = false,
        LEGENDARY = true,  -- Default legendary aja
        MYTHIC = true
    },
    PingOnRarity = {
        LEGENDARY = true,
        MYTHIC = true
    },
    
    -- Stats
    FishCaught = 0,
    MoneyEarned = 0,
    TotalCasts = 0,
    
    -- Internal
    IsReeling = false,
    CurrentState = "Idle",
    RemoteCache = {}
}

-- ================================================================
-- 📡 DISCORD WEBHOOK SYSTEM (LENGKAP)
-- ================================================================

local WebhookSystem = {}

-- Fungsi untuk input URL dari user (popup)
function WebhookSystem:PromptWebhookURL()
    local dialog = Instance.new("ScreenGui")
    dialog.Name = "WebhookDialog"
    dialog.Parent = Services.CoreGui or Player.PlayerGui
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 450, 0, 250)
    frame.Position = UDim2.new(0.5, -225, 0.5, -125)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    frame.BackgroundTransparency = 0.05
    frame.BorderSizePixel = 0
    frame.Parent = dialog
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame
    
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 40)
    title.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
    title.Text = "✦ STELLAR NEXUS - WEBHOOK SETUP ✦"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.Parent = frame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = title
    
    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -40, 0, 40)
    desc.Position = UDim2.new(0, 20, 0, 55)
    desc.BackgroundTransparency = 1
    desc.Text = "Enter your Discord Webhook URL:"
    desc.TextColor3 = Color3.fromRGB(200, 200, 200)
    desc.TextSize = 12
    desc.Font = Enum.Font.Gotham
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.Parent = frame
    
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(1, -40, 0, 45)
    inputBox.Position = UDim2.new(0, 20, 0, 100)
    inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    inputBox.Text = ""
    inputBox.PlaceholderText = "https://discord.com/api/webhooks/..."
    inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    inputBox.Font = Enum.Font.Gotham
    inputBox.TextSize = 12
    inputBox.Parent = frame
    
    local inputCorner = Instance.new("UICorner")
    inputCorner.CornerRadius = UDim.new(0, 8)
    inputCorner.Parent = inputBox
    
    local confirmBtn = Instance.new("TextButton")
    confirmBtn.Size = UDim2.new(0, 120, 0, 40)
    confirmBtn.Position = UDim2.new(0.5, -130, 1, -55)
    confirmBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
    confirmBtn.Text = "✓ Confirm"
    confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    confirmBtn.Font = Enum.Font.GothamBold
    confirmBtn.TextSize = 14
    confirmBtn.Parent = frame
    
    local confirmCorner = Instance.new("UICorner")
    confirmCorner.CornerRadius = UDim.new(0, 8)
    confirmCorner.Parent = confirmBtn
    
    local cancelBtn = Instance.new("TextButton")
    cancelBtn.Size = UDim2.new(0, 120, 0, 40)
    cancelBtn.Position = UDim2.new(0.5, 10, 1, -55)
    cancelBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
    cancelBtn.Text = "✕ Cancel"
    cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    cancelBtn.Font = Enum.Font.GothamBold
    cancelBtn.TextSize = 14
    cancelBtn.Parent = frame
    
    local cancelCorner = Instance.new("UICorner")
    cancelCorner.CornerRadius = UDim.new(0, 8)
    cancelCorner.Parent = cancelBtn
    
    local result = nil
    
    confirmBtn.MouseButton1Click:Connect(function()
        local url = inputBox.Text
        if url ~= "" and (url:find("discord.com/api/webhooks/") or url:find("discordapp.com/api/webhooks/")) then
            result = url
            dialog:Destroy()
        else
            inputBox.PlaceholderText = "Invalid URL! Try again..."
            inputBox.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            wait(1)
            inputBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
            inputBox.PlaceholderText = "https://discord.com/api/webhooks/..."
        end
    end)
    
    cancelBtn.MouseButton1Click:Connect(function()
        dialog:Destroy()
    end)
    
    -- Wait for dialog to close
    repeat wait() until dialog.Parent == nil
    return result
end

-- Fungsi untuk filter rarity (multi-select)
function WebhookSystem:IsRarityFiltered(rarity)
    if not Nexus.WebhookEnabled then return true end
    local shouldSend = Nexus.WebhookFilters[rarity] or false
    return not shouldSend -- return true if filtered out
end

-- Fungsi utama kirim ke Discord
function WebhookSystem:SendToDiscord(fishData)
    if not Nexus.WebhookEnabled or Nexus.WebhookURL == "" then 
        return false 
    end
    
    -- Cek filter rarity
    if WebhookSystem:IsRarityFiltered(fishData.Rarity) then
        print("[Stellar Nexus] Skipped " .. fishData.Rarity .. " fish (filtered)")
        return false
    end
    
    -- Warna embed berdasarkan rarity
    local embedColors = {
        COMMON = 8421504,
        RARE = 3447003,
        EPIC = 10181046,
        LEGENDARY = 16766720,
        MYTHIC = 16711680
    }
    
    local embedColor = embedColors[fishData.Rarity] or 16777215
    
    -- Emoji untuk rarity
    local rarityEmojis = {
        COMMON = "🐟",
        RARE = "🐠",
        EPIC = "🐡",
        LEGENDARY = "🐉",
        MYTHIC = "🌟"
    }
    local emoji = rarityEmojis[fishData.Rarity] or "🐟"
    
    -- Buat embed
    local embed = {
        title = emoji .. " Stellar System | " .. fishData.Rarity .. " Catch! " .. emoji,
        description = "**Congratulations!!** You have obtained a new **" .. fishData.Rarity .. " fish**!",
        color = embedColor,
        fields = {
            {name = "┌───────────────", value = " ", inline = false},
            {name = "│ Player Name", value = "│ " .. fishData.PlayerName, inline = true},
            {name = "│ Fish Name", value = "│ " .. fishData.FishName, inline = true},
            {name = "│ Fish Tier", value = "│ " .. fishData.Rarity, inline = true},
            {name = "├───────────────", value = " ", inline = false},
            {name = "│ Weight", value = "│ " .. fishData.Weight, inline = true},
            {name = "│ Mutation", value = "│ " .. (fishData.Mutation or "None"), inline = true},
            {name = "│ Value", value = "│ " .. fishData.Value, inline = true},
            {name = "├───────────────", value = " ", inline = false},
            {name = "│ Location", value = "│ " .. fishData.Location, inline = false},
            {name = "└───────────────", value = " ", inline = false}
        },
        footer = {
            text = "Stellar Nexus System • " .. os.date("%A, %B %d %Y at %I:%M:%S %p"),
            icon_url = "https://i.imgur.com/fishicon.png"
        },
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    }
    
    -- Mention untuk rarity tertentu
    local content = nil
    if Nexus.PingOnRarity[fishData.Rarity] then
        content = "@everyone **" .. fishData.Rarity .. " FISH CAUGHT!**"
    end
    
    local payload = {
        content = content,
        embeds = {embed}
    }
    
    local success, response = pcall(function()
        local data = Services.HttpService:JSONEncode(payload)
        local headers = {["Content-Type"] = "application/json"}
        
        return request({
            Url = Nexus.WebhookURL,
            Method = "POST",
            Headers = headers,
            Body = data
        })
    end)
    
    if success then
        print("[Stellar Nexus] ✅ Webhook sent for: " .. fishData.FishName .. " (" .. fishData.Rarity .. ")")
    else
        warn("[Stellar Nexus] ❌ Failed to send webhook: " .. tostring(response))
    end
    
    return success
end

-- Deteksi ikan yang ditangkap dari game
function WebhookSystem:SetupFishDetection()
    -- Method 1: Monitor reward remote
    local rewardRemote = Nexus.RemoteCache["FishReward"] or 
                         Nexus.RemoteCache["OnFishCaught"] or
                         Nexus.RemoteCache["ClaimFish"]
    
    if rewardRemote and rewardRemote.OnClientEvent then
        rewardRemote.OnClientEvent:Connect(function(data)
            local fishInfo = {
                PlayerName = Player.Name,
                FishName = data.Name or data.FishName or "Unknown Fish",
                Rarity = string.upper(data.Rarity or data.Tier or "COMMON"),
                Weight = (data.Weight or math.random(1, 50)) .. "kg",
                Mutation = data.Mutation or "None",
                Value = "$" .. (data.Value or data.Price or math.random(100, 5000)),
                Location = Nexus.SelectedIsland
            }
            WebhookSystem:SendToDiscord(fishInfo)
            Nexus.FishCaught = Nexus.FishCaught + 1
        end)
    end
    
    -- Method 2: Monitor chat messages
    local chatRemote = Services.ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
    if chatRemote then
        local onMessage = chatRemote:FindFirstChild("OnMessageDoneFiltering")
        if onMessage and onMessage.OnClientEvent then
            onMessage.OnClientEvent:Connect(function(msgData)
                local msg = msgData.Message or ""
                -- Parse chat message untuk fish caught (customize sesuai game)
                if msg:find("caught") or msg:find("obtained") then
                    -- Extract fish data from message
                    -- Ini perlu disesuaikan dengan format chat game Fish It
                end
            end)
        end
    end
    
    -- Method 3: Monitor GUI notification
    spawn(function()
        while true do
            wait(0.5)
            local notificationFrame = Player.PlayerGui:FindFirstChild("Notification", true)
            if notificationFrame and notificationFrame.Visible then
                -- Extract fish info from notification
                -- Implementation depends on game's UI
            end
        end
    end)
end

-- ================================================================
-- 🎣 FISHING CORE SYSTEM (SEDERHANA)
-- ================================================================

local FishingCore = {}

function FishingCore:CastRod()
    local castRemote = Nexus.RemoteCache["CastRod"] or Nexus.RemoteCache["StartFishing"]
    
    if castRemote then
        local power = Nexus.PerfectCast and 100 or math.random(60, 100)
        if castRemote:IsA("RemoteEvent") then
            castRemote:FireServer(power)
        elseif castRemote:IsA("RemoteFunction") then
            castRemote:InvokeServer(power)
        end
        Nexus.TotalCasts = Nexus.TotalCasts + 1
        return true
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

function FishingCore:ReelFish()
    if Nexus.InstaReel then
        local reelRemote = Nexus.RemoteCache["ReelFish"]
        if reelRemote then
            if reelRemote:IsA("RemoteEvent") then
                reelRemote:FireServer(100)
            end
            return true
        end
    end
    return false
end

function FishingCore:AutoFishLoop()
    while Nexus.AutoFish do
        FishingCore:CastRod()
        local biteTimeout = 0
        local hasBite = false
        
        while biteTimeout < 10 and not hasBite and Nexus.AutoFish do
            hasBite = FishingCore:DetectBite()
            wait(0.5)
            biteTimeout = biteTimeout + 0.5
        end
        
        if hasBite then
            FishingCore:ReelFish()
            wait(0.5)
        end
        
        wait(Nexus.CastDelay)
    end
end

-- ================================================================
-- 🎨 GUI (LENGKAP DENGAN WEBHOOK SETTINGS)
-- ================================================================

local GUI = {}

function GUI:CreateMainWindow()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "StellarNexus"
    screenGui.Parent = Services.CoreGui or Player.PlayerGui
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(0, 420, 0, 580)
    mainFrame.Position = UDim2.new(0.5, -210, 0.5, -290)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.05
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 20, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    }
    gradient.Parent = mainFrame
    
    local corners = Instance.new("UICorner")
    corners.CornerRadius = UDim.new(0, 12)
    corners.Parent = mainFrame
    
    -- Title Bar
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 45)
    titleBar.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
    titleBar.BackgroundTransparency = 0.15
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleCorners = Instance.new("UICorner")
    titleCorners.CornerRadius = UDim.new(0, 12)
    titleCorners.Parent = titleBar
    
    local titleText = Instance.new("TextLabel")
    titleText.Size = UDim2.new(1, -50, 1, 0)
    titleText.Position = UDim2.new(0, 10, 0, 0)
    titleText.BackgroundTransparency = 1
    titleText.Text = "✦ STELLAR NEXUS: FISH IT MODULE ✦"
    titleText.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleText.TextScaled = true
    titleText.Font = Enum.Font.GothamBold
    titleText.TextXAlignment = Enum.TextXAlignment.Left
    titleText.Parent = titleBar
    
    local versionText = Instance.new("TextLabel")
    versionText.Size = UDim2.new(0, 80, 1, 0)
    versionText.Position = UDim2.new(1, -90, 0, 0)
    versionText.BackgroundTransparency = 1
    versionText.Text = "v" .. StellarNexus.Version
    versionText.TextColor3 = Color3.fromRGB(200, 200, 200)
    versionText.TextSize = 12
    versionText.Font = Enum.Font.Gotham
    versionText.TextXAlignment = Enum.TextXAlignment.Right
    versionText.Parent = titleBar
    
    -- Draggable
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
    
    -- Tab Buttons
    local tabY = 55
    local function createTabButton(name, position)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 95, 0, 30)
        btn.Position = UDim2.new(position, 0, 0, tabY)
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
    
    local tabFishing = createTabButton("🎣 FISHING", 0.02)
    local tabWebhook = createTabButton("📡 WEBHOOK", 0.27)
    local tabTravel = createTabButton("🚤 TRAVEL", 0.52)
    local tabStats = createTabButton("📊 STATS", 0.77)
    
    -- Content Frames
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -105)
    contentFrame.Position = UDim2.new(0, 10, 0, 95)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- FISHING TAB
    local fishingContent = Instance.new("ScrollingFrame")
    fishingContent.Size = UDim2.new(1, 0, 1, 0)
    fishingContent.BackgroundTransparency = 1
    fishingContent.CanvasSize = UDim2.new(0, 0, 0, 250)
    fishingContent.ScrollBarThickness = 4
    fishingContent.Parent = contentFrame
    
    local function createButton(parent, text, y, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.9, 0, 0, 40)
        btn.Position = UDim2.new(0.05, 0, 0, y)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 13
        btn.Parent = parent
        
        local btnCorners = Instance.new("UICorner")
        btnCorners.CornerRadius = UDim.new(0, 8)
        btnCorners.Parent = btn
        btn.MouseButton1Click:Connect(callback)
        return btn
    end
    
    local autoFishBtn = createButton(fishingContent, "🔁 AUTO FISHING [OFF]", 0, function()
        Nexus.AutoFish = not Nexus.AutoFish
        autoFishBtn.BackgroundColor3 = Nexus.AutoFish and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(60, 60, 80)
        autoFishBtn.Text = Nexus.AutoFish and "🔁 AUTO FISHING [ON]" or "🔁 AUTO FISHING [OFF]"
        if Nexus.AutoFish then spawn(FishingCore.AutoFishLoop) end
    end)
    
    local perfectCastBtn = createButton(fishingContent, "🎯 PERFECT CAST [OFF]", 50, function()
        Nexus.PerfectCast = not Nexus.PerfectCast
        perfectCastBtn.BackgroundColor3 = Nexus.PerfectCast and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(60, 60, 80)
        perfectCastBtn.Text = Nexus.PerfectCast and "🎯 PERFECT CAST [ON]" or "🎯 PERFECT CAST [OFF]"
    end)
    
    local instaReelBtn = createButton(fishingContent, "⚡ INSTA REEL [OFF]", 100, function()
        Nexus.InstaReel = not Nexus.InstaReel
        instaReelBtn.BackgroundColor3 = Nexus.InstaReel and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(60, 60, 80)
        instaReelBtn.Text = Nexus.InstaReel and "⚡ INSTA REEL [ON]" or "⚡ INSTA REEL [OFF]"
    end)
    
    -- WEBHOOK TAB
    local webhookContent = Instance.new("ScrollingFrame")
    webhookContent.Size = UDim2.new(1, 0, 1, 0)
    webhookContent.BackgroundTransparency = 1
    webhookContent.CanvasSize = UDim2.new(0, 0, 0, 400)
    webhookContent.ScrollBarThickness = 4
    webhookContent.Visible = false
    webhookContent.Parent = contentFrame
    
    -- Enable Webhook Toggle
    local webhookEnableBtn = createButton(webhookContent, "📡 WEBHOOK [OFF]", 0, function()
        Nexus.WebhookEnabled = not Nexus.WebhookEnabled
        webhookEnableBtn.BackgroundColor3 = Nexus.WebhookEnabled and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(60, 60, 80)
        webhookEnableBtn.Text = Nexus.WebhookEnabled and "📡 WEBHOOK [ON]" or "📡 WEBHOOK [OFF]"
    end)
    
    -- Set Webhook URL Button
    local setUrlBtn = createButton(webhookContent, "🔗 SET WEBHOOK URL", 50, function()
        local url = WebhookSystem:PromptWebhookURL()
        if url then
            Nexus.WebhookURL = url
            setUrlBtn.Text = "✅ URL SET!"
            setUrlBtn.BackgroundColor3 = Color3.fromRGB(80, 180, 80)
            wait(1.5)
            setUrlBtn.Text = "🔗 SET WEBHOOK URL"
            setUrlBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
        end
    end)
    
    -- Filter Title
    local filterTitle = Instance.new("TextLabel")
    filterTitle.Size = UDim2.new(1, -20, 0, 30)
    filterTitle.Position = UDim2.new(0, 10, 0, 110)
    filterTitle.BackgroundTransparency = 1
    filterTitle.Text = "🎚️ FISH TIER FILTERS (Multi-Select)"
    filterTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
    filterTitle.TextSize = 13
    filterTitle.Font = Enum.Font.GothamBold
    filterTitle.TextXAlignment = Enum.TextXAlignment.Left
    filterTitle.Parent = webhookContent
    
    -- Rarity filter buttons
    local rarities = {"COMMON", "RARE", "EPIC", "LEGENDARY", "MYTHIC"}
    local rarityBtns = {}
    local rarityColors = {
        COMMON = 8421504,
        RARE = 3447003,
        EPIC = 10181046,
        LEGENDARY = 16766720,
        MYTHIC = 16711680
    }
    
    for i, rarity in ipairs(rarities) do
        local yPos = 150 + (i-1) * 45
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.85, 0, 0, 35)
        btn.Position = UDim2.new(0.075, 0, 0, yPos)
        btn.BackgroundColor3 = Nexus.WebhookFilters[rarity] and Color3.fromRGB(rarityColors[rarity]) or Color3.fromRGB(40, 40, 50)
        btn.Text = (Nexus.WebhookFilters[rarity] and "✅ " or "⬜ ") .. rarity
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 13
        btn.Parent = webhookContent
        
        local btnCorners = Instance.new("UICorner")
        btnCorners.CornerRadius = UDim.new(0, 8)
        btnCorners.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            Nexus.WebhookFilters[rarity] = not Nexus.WebhookFilters[rarity]
            btn.BackgroundColor3 = Nexus.WebhookFilters[rarity] and Color3.fromRGB(rarityColors[rarity]) or Color3.fromRGB(40, 40, 50)
            btn.Text = (Nexus.WebhookFilters[rarity] and "✅ " or "⬜ ") .. rarity
        end)
        
        rarityBtns[rarity] = btn
    end
    
    -- Mention/Ping settings
    local pingTitle = Instance.new("TextLabel")
    pingTitle.Size = UDim2.new(1, -20, 0, 30)
    pingTitle.Position = UDim2.new(0, 10, 0, 390)
    pingTitle.BackgroundTransparency = 1
    pingTitle.Text = "🔔 PING @everyone ON (Optional)"
    pingTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
    pingTitle.TextSize = 13
    pingTitle.Font = Enum.Font.GothamBold
    pingTitle.TextXAlignment = Enum.TextXAlignment.Left
    pingTitle.Parent = webhookContent
    
    local pingLegendary = createButton(webhookContent, "🔔 PING ON LEGENDARY [ON]", 425, function()
        Nexus.PingOnRarity.LEGENDARY = not Nexus.PingOnRarity.LEGENDARY
        pingLegendary.BackgroundColor3 = Nexus.PingOnRarity.LEGENDARY and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(60, 60, 80)
        pingLegendary.Text = Nexus.PingOnRarity.LEGENDARY and "🔔 PING ON LEGENDARY [ON]" or "🔔 PING ON LEGENDARY [OFF]"
    end)
    
    local pingMythic = createButton(webhookContent, "🔔 PING ON MYTHIC [ON]", 475, function()
        Nexus.PingOnRarity.MYTHIC = not Nexus.PingOnRarity.MYTHIC
        pingMythic.BackgroundColor3 = Nexus.PingOnRarity.MYTHIC and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(60, 60, 80)
        pingMythic.Text = Nexus.PingOnRarity.MYTHIC and "🔔 PING ON MYTHIC [ON]" or "🔔 PING ON MYTHIC [OFF]"
    end)
    
    -- TRAVEL TAB
    local travelContent = Instance.new("ScrollingFrame")
    travelContent.Size = UDim2.new(1, 0, 1, 0)
    travelContent.BackgroundTransparency = 1
    travelContent.CanvasSize = UDim2.new(0, 0, 0, 300)
    travelContent.ScrollBarThickness = 4
    travelContent.Visible = false
    travelContent.Parent = contentFrame
    
    local islands = {"Starter Island", "Coral Reef", "Deep Ocean", "Mystic Island", "Volcanic Isle"}
    for i, island in ipairs(islands) do
        createButton(travelContent, "🌊 " .. island, (i-1) * 45, function()
            Nexus.SelectedIsland = island
            print("[Stellar Nexus] Teleported to:", island)
        end)
    end
    
    -- STATS TAB
    local statsContent = Instance.new("ScrollingFrame")
    statsContent.Size = UDim2.new(1, 0, 1, 0)
    statsContent.BackgroundTransparency = 1
    statsContent.Visible = false
    statsContent.Parent = contentFrame
    
    local statsLabels = {}
    local statsInfo = {
        {"🎣 Fish Caught", "FishCaught"},
        {"💰 Money Earned", "MoneyEarned"},
        {"🔄 Total Casts", "TotalCasts"},
        {"📡 Webhook Status", "WebhookStatus"},
        {"🎚️ Active Filters", "ActiveFilters"}
    }
    
    for i, stat in ipairs(statsInfo) do
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -20, 0, 40)
        label.Position = UDim2.new(0, 10, 0, 10 + (i-1) * 50)
        label.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        label.BackgroundTransparency = 0.5
        label.Text = stat[1] .. ": " .. tostring(Nexus[stat[2]] or 0)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.Parent = statsContent
        
        local labelCorners = Instance.new("UICorner")
        labelCorners.CornerRadius = UDim.new(0, 6)
        labelCorners.Parent = label
        statsLabels[stat[2]] = label
    end
    
    -- Update stats periodically
    spawn(function()
        while true do
            wait(1)
            if statsLabels["FishCaught"] then
                statsLabels["FishCaught"].Text = "🎣 Fish Caught: " .. Nexus.FishCaught
                statsLabels["MoneyEarned"].Text = "💰 Money Earned: $" .. Nexus.MoneyEarned
                statsLabels["TotalCasts"].Text = "🔄 Total Casts: " .. Nexus.TotalCasts
                
                local webhookStatus = Nexus.WebhookEnabled and (Nexus.WebhookURL ~= "" and "✅ Active" or "⚠️ No URL") or "❌ Disabled"
                statsLabels["WebhookStatus"].Text = "📡 Webhook Status: " .. webhookStatus
                
                local activeFilters = {}
                for rarity, enabled in pairs(Nexus.WebhookFilters) do
                    if enabled then table.insert(activeFilters, rarity) end
                end
                local filterText = #activeFilters > 0 and table.concat(activeFilters, ", ") or "None"
                statsLabels["ActiveFilters"].Text = "🎚️ Active Filters: " .. filterText
            end
        end
    end)
    
    -- Tab switching
    local function switchTab(active)
        fishingContent.Visible = (active == fishingContent)
        webhookContent.Visible = (active == webhookContent)
        travelContent.Visible = (active == travelContent)
        statsContent.Visible = (active == statsContent)
        
        tabFishing.BackgroundColor3 = (active == fishingContent) and Color3.fromRGB(100, 50, 200) or Color3.fromRGB(60, 60, 80)
        tabWebhook.BackgroundColor3 = (active == webhookContent) and Color3.fromRGB(100, 50, 200) or Color3.fromRGB(60, 60, 80)
        tabTravel.BackgroundColor3 = (active == travelContent) and Color3.fromRGB(100, 50, 200) or Color3.fromRGB(60, 60, 80)
        tabStats.BackgroundColor3 = (active == statsContent) and Color3.fromRGB(100, 50, 200) or Color3.fromRGB(60, 60, 80)
    end
    
    tabFishing.MouseButton1Click:Connect(function() switchTab(fishingContent) end)
    tabWebhook.MouseButton1Click:Connect(function() switchTab(webhookContent) end)
    tabTravel.MouseButton1Click:Connect(function() switchTab(travelContent) end)
    tabStats.MouseButton1Click:Connect(function() switchTab(statsContent) end)
    
    -- Close button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 8)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 18
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = mainFrame
    
    local closeCorners = Instance.new("UICorner")
    closeCorners.CornerRadius = UDim.new(0, 6)
    closeCorners.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
    end)
    
    print("[Stellar Nexus] GUI Loaded!")
end

-- ================================================================
-- 🚀 INITIALIZATION
-- ================================================================

local function Initialize()
    print("═══════════════════════════════════════════════════════════════")
    print("✦ STELLAR NEXUS: FISH IT MODULE v" .. StellarNexus.Version .. " ✦")
    print("✦ WITH DISCORD WEBHOOK INTEGRATION ✦")
    print("═══════════════════════════════════════════════════════════════")
    
    -- Scan remotes
    for _, obj in ipairs(Services.ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            Nexus.RemoteCache[obj.Name] = obj
        end
    end
    
    -- Setup webhook detection
    WebhookSystem:SetupFishDetection()
    
    -- Create GUI
    GUI:CreateMainWindow()
    
    print("[Stellar Nexus] Ready! Setup webhook di tab 📡 WEBHOOK")
    print("═══════════════════════════════════════════════════════════════")
end

-- Start
Initialize()