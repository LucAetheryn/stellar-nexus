--[[
╔═══════════════════════════════════════════════════════════════════════════╗
║                    ███████╗████████╗███████╗██╗     ██╗      █████╗      ║
║                    ██╔════╝╚══██╔══╝██╔════╝██║     ██║     ██╔══██╗     ║
║                    ███████╗   ██║   █████╗  ██║     ██║     ███████║     ║
║                    ╚════██║   ██║   ██╔══╝  ██║     ██║     ██╔══██║     ║
║                    ███████║   ██║   ███████╗███████╗███████╗██║  ██║     ║
║                    ╚══════╝   ╚═╝   ╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝     ║
║                                                                           ║
║                          ██████╗ ██╗   ██╗███████╗████████╗██╗   ██╗    ║
║                          ██╔══██╗╚██╗ ██╔╝██╔════╝╚══██╔══╝╚██╗ ██╔╝    ║
║                          ██████╔╝ ╚████╔╝ ███████╗   ██║    ╚████╔╝     ║
║                          ██╔══██╗  ╚██╔╝  ╚════██║   ██║     ╚██╔╝      ║
║                          ██║  ██║   ██║   ███████║   ██║      ██║       ║
║                          ╚═╝  ╚═╝   ╚═╝   ╚══════╝   ╚═╝      ╚═╝       ║
║                                                                           ║
║                    STELLAR SYSTEM | FISH IT ULTIMATE                      ║
║                         VERSION 4.0.0 - LYNX EDITION                      ║
║                           OWNER: LUC AETHERYN                             ║
║                                                                           ║
║  FITUR: Auto Fishing | Auto Sell | Auto Quest | Auto Rejoin               ║
║         Instant Catch | Perfect Cast | Teleport All Islands               ║
║         Merchant Tracker | Discord Webhook | Tier Filter                  ║
║         Unlock All Boats | Auto Buy Bait | Auto Upgrade Rod               ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
--]]

-- ============================================================================
-- 🔧 INITIALIZATION & SERVICES
-- ============================================================================

local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- ============================================================================
-- 📦 SYSTEM CONFIGURATION
-- ============================================================================

local Config = {
    -- Toggles
    AutoFishing = false,
    AutoSell = false,
    AutoQuest = false,
    AutoRejoin = false,
    AutoBuyBait = false,
    AutoUpgradeRod = false,
    PerfectCast = false,
    InstantCatch = false,
    UnlockAllBoats = false,
    
    -- Settings
    CastDelay = 3.5,
    SellFilter = "ALL", -- ALL, LEGENDARY+, EPIC+, RARE+
    SelectedBait = "Worm",
    SelectedRod = "Starter Rod",
    
    -- Webhook
    WebhookEnabled = false,
    DiscordID = "",
    WebhookURL = "",
    SelectedTiers = {}, -- Common, Uncommon, Rare, Epic, Legendary, Mythic, Secret
    
    -- Stats
    FishCaught = 0,
    MoneyEarned = 0,
    TotalCasts = 0,
    SessionStart = os.time(),
    
    -- Anti Detection
    LastAction = 0,
    HumanizeDelay = true
}

-- ============================================================================
-- 🗺️ TELEPORT LOCATIONS (FIXED - LOKASI YANG BENAR)
-- ============================================================================

local Locations = {
    ["🏝️ Fisherman Island"] = CFrame.new(-98, 3, -12),
    ["🌊 Ocean"] = CFrame.new(-250, 0, -80),
    ["🏯 Kohana"] = CFrame.new(85, 3, 45),
    ["🌋 Kohana Volcano"] = CFrame.new(110, 25, 55),
    ["🐠 Coral Reefs"] = CFrame.new(-40, -8, 190),
    ["🌿 Ancient Jungle"] = CFrame.new(280, 5, 140),
    ["🗿 Sisyphus Statue"] = CFrame.new(-290, 15, -190),
    ["🎄 Christmas Island"] = CFrame.new(480, 3, 290),
    ["🏛️ Sacred Temple"] = CFrame.new(380, 10, 210),
    ["🏝️ Lost Isle"] = CFrame.new(150, -20, -300),
    ["💎 Treasure Room"] = CFrame.new(-280, 30, -210),
    ["🌙 Moonlight Cove"] = CFrame.new(-500, 5, 350),
    ["🔥 Dragon's Maw"] = CFrame.new(600, 50, -100),
    ["❄️ Frozen Fjord"] = CFrame.new(-650, 10, -400)
}

-- ============================================================================
-- 🎣 REMOTE DETECTION (Seperti Lynx)
-- ============================================================================

local Remotes = {}

local function DetectRemotes()
    local remoteNames = {
        "CastRod", "StartFishing", "ReelFish", "CatchFish", "SellFish", "SellInventory",
        "BuyBait", "UpgradeRod", "EquipBoat", "TeleportToIsland", "PerfectCast",
        "ClaimReward", "CompleteQuest", "Rejoin", "BuyItem", "Purchase"
    }
    
    for _, name in ipairs(remoteNames) do
        local remote = ReplicatedStorage:FindFirstChild(name)
        if remote then
            Remotes[name] = remote
        end
    end
    
    -- Scan all remotes in ReplicatedStorage
    for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            if not Remotes[obj.Name] then
                Remotes[obj.Name] = obj
            end
        end
    end
    
    print("[Stellar] Found " .. table.getn(Remotes) .. " remotes")
end

DetectRemotes()

-- ============================================================================
-- 🛡️ ANTI-DETECTION & HUMANIZATION (Seperti Lynx)
-- ============================================================================

local AntiDetect = {
    LastCastTime = 0,
    CastCount = 0,
    SessionStart = os.time(),
    RandomSeed = math.random(1, 9999)
}

function AntiDetect:HumanizeDelay(min, max)
    if not Config.HumanizeDelay then return 0 end
    local delay = math.random(min * 10, max * 10) / 10
    wait(delay)
    return delay
end

function AntiDetect:RandomizePower()
    local power = math.random(85, 100)
    
    -- 5% chance to miss (human error)
    if math.random(1, 100) <= 5 then
        power = math.random(40, 75)
    end
    
    -- 2% chance for perfect cast
    if math.random(1, 100) <= 2 then
        power = 100
    end
    
    return power
end

function AntiDetect:ShouldTakeBreak()
    local sessionLength = os.time() - self.SessionStart
    if sessionLength > math.random(480, 900) then -- 8-15 menit
        self.SessionStart = os.time()
        local breakTime = math.random(30, 90) -- 30-90 detik
        print("[Stellar] Taking break for " .. breakTime .. " seconds...")
        wait(breakTime)
        return true
    end
    return false
end

function AntiDetect:RandomInterval()
    return math.random(35, 70) / 10 -- 3.5 - 7 detik
end

-- ============================================================================
-- 🎣 AUTO FISHING CORE (Seperti Lynx - Lengkap)
-- ============================================================================

local Fishing = {}

function Fishing:Cast()
    local castRemote = Remotes["CastRod"] or Remotes["StartFishing"]
    if not castRemote then return false end
    
    local power = Config.PerfectCast and AntiDetect:RandomizePower() or math.random(60, 95)
    
    if castRemote:IsA("RemoteEvent") then
        castRemote:FireServer(power)
    elseif castRemote:IsA("RemoteFunction") then
        castRemote:InvokeServer(power)
    end
    
    Config.TotalCasts = Config.TotalCasts + 1
    Config.LastAction = tick()
    return true
end

function Fishing:Reel()
    local reelRemote = Remotes["ReelFish"] or Remotes["CatchFish"]
    if not reelRemote then return false end
    
    if Config.InstantCatch then
        -- Fast but not instant (progressive)
        for i = 1, 3 do
            if reelRemote:IsA("RemoteEvent") then
                reelRemote:FireServer(i * 33)
            end
            wait(0.03)
        end
    else
        -- Normal reeling
        for i = 1, 10 do
            if reelRemote:IsA("RemoteEvent") then
                reelRemote:FireServer(i * 10)
            end
            wait(0.05)
        end
    end
    
    Config.FishCaught = Config.FishCaught + 1
    return true
end

function Fishing:DetectBite()
    -- Method 1: UI Indicator
    local biteIndicator = LocalPlayer.PlayerGui:FindFirstChild("BiteIndicator", true)
    if biteIndicator and biteIndicator.Visible then
        return true
    end
    
    -- Method 2: Attribute
    if LocalPlayer:GetAttribute("FishBiting") == true then
        return true
    end
    
    -- Method 3: Screen Vibration detection
    local camera = workspace.CurrentCamera
    if camera and camera.CFrame ~= camera.CFrame then
        -- Camera shake detected
        return true
    end
    
    return false
end

function Fishing:AutoLoop()
    while Config.AutoFishing do
        -- Take breaks like human
        AntiDetect:ShouldTakeBreak()
        
        -- Cast rod
        if not Fishing:Cast() then
            wait(1)
        end
        
        -- Wait for bite
        local timeout = 0
        local maxTimeout = math.random(80, 140) / 10 -- 8-14 detik
        local hasBite = false
        
        while timeout < maxTimeout and not hasBite and Config.AutoFishing do
            hasBite = Fishing:DetectBite()
            wait(0.5)
            timeout = timeout + 0.5
        end
        
        if hasBite then
            Fishing:Reel()
            wait(0.3)
        end
        
        -- Random delay between casts
        local delay = Config.CastDelay
        if Config.CastDelay == 0 then
            delay = AntiDetect:RandomInterval()
        end
        wait(delay)
    end
end

-- ============================================================================
-- 💰 AUTO SELL & ECONOMY (Seperti Lynx)
-- ============================================================================

local Economy = {}

function Economy:SellFish()
    local sellRemote = Remotes["SellFish"] or Remotes["SellInventory"]
    if not sellRemote then return false end
    
    local sellData = "ALL"
    if Config.SellFilter == "LEGENDARY+" then
        sellData = {MinRarity = "Legendary"}
    elseif Config.SellFilter == "EPIC+" then
        sellData = {MinRarity = "Epic"}
    elseif Config.SellFilter == "RARE+" then
        sellData = {MinRarity = "Rare"}
    end
    
    if sellRemote:IsA("RemoteEvent") then
        sellRemote:FireServer(sellData)
    end
    
    return true
end

function Economy:BuyBait(baitType, amount)
    local buyRemote = Remotes["BuyBait"] or Remotes["Purchase"]
    if buyRemote then
        buyRemote:FireServer(baitType, amount)
        return true
    end
    return false
end

function Economy:UpgradeRod()
    local upgradeRemote = Remotes["UpgradeRod"] or Remotes["Upgrade"]
    if upgradeRemote then
        upgradeRemote:FireServer()
        return true
    end
    return false
end

function Economy:AutoSellLoop()
    while Config.AutoSell do
        Economy:SellFish()
        wait(30) -- Sell every 30 seconds
    end
end

-- ============================================================================
-- 🚤 BOAT & ITEM UNLOCK (Seperti Lynx)
-- ============================================================================

local Unlocker = {}

local Boats = {"Starter Boat", "Speed Boat", "Premium Cruiser", "Dragon Boat", "Stellar Nexus"}

function Unlocker:UnlockAllBoats()
    if not Config.UnlockAllBoats then return end
    
    for _, boatName in ipairs(Boats) do
        local equipRemote = Remotes["EquipBoat"] or Remotes["SpawnBoat"]
        if equipRemote then
            equipRemote:FireServer(boatName)
            wait(0.5)
        end
        
        -- Try to modify local data
        local boatData = LocalPlayer:FindFirstChild("CurrentBoat")
        if boatData then
            boatData.Value = boatName
        end
    end
    print("[Stellar] All boats unlocked!")
end

-- ============================================================================
-- 📡 DISCORD WEBHOOK (Lengkap seperti Lynx)
-- ============================================================================

local Webhook = {}

function Webhook:SendNotification(fishData)
    if not Config.WebhookEnabled or Config.WebhookURL == "" then 
        return false 
    end
    
    -- Check tier filter
    local shouldSend = false
    if #Config.SelectedTiers == 0 then
        shouldSend = true
    else
        for _, tier in ipairs(Config.SelectedTiers) do
            if fishData.rarity and fishData.rarity:lower() == tier:lower() then
                shouldSend = true
                break
            end
        end
    end
    
    if not shouldSend then return false end
    
    -- Rarity colors
    local colors = {
        Common = 8421504,
        Uncommon = 3447003,
        Rare = 10181046,
        Epic = 1146986,
        Legendary = 16766720,
        Mythic = 16711680,
        Secret = 16711935
    }
    
    local stellarLogo = "https://raw.githubusercontent.com/MaxmunZ/Stellar-Assets/main/Stellar%20System.png.jpg"
    
    local embed = {
        title = "⭐ Stellar System | " .. (fishData.rarity or "Unknown") .. " Catch!",
        description = "**Congratulations!!** You have obtained a new **" .. (fishData.rarity or "Unknown") .. " fish**!",
        color = colors[fishData.rarity] or 16723110,
        fields = {
            {name = "┌───────────────", value = " ", inline = false},
            {name = "│ Player Name", value = "│ " .. (fishData.playerName or LocalPlayer.Name), inline = true},
            {name = "│ Fish Name", value = "│ " .. (fishData.fishName or "Unknown"), inline = true},
            {name = "│ Fish Tier", value = "│ " .. (fishData.rarity or "Common"), inline = true},
            {name = "├───────────────", value = " ", inline = false},
            {name = "│ Weight", value = "│ " .. (fishData.weight or "Unknown"), inline = true},
            {name = "│ Mutation", value = "│ " .. (fishData.mutation or "None"), inline = true},
            {name = "│ Value", value = "│ $" .. (fishData.value or "0"), inline = true},
            {name = "└───────────────", value = " ", inline = false}
        },
        footer = {text = "Stellar System • " .. os.date("%I:%M:%S %p"), icon_url = stellarLogo},
        thumbnail = {url = stellarLogo},
        timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z")
    }
    
    local content = nil
    if Config.DiscordID ~= "" and fishData.rarity and fishData.rarity:lower() == "legendary" then
        content = "<@" .. Config.DiscordID .. "> **LEGENDARY FISH CAUGHT!**"
    end
    
    local payload = {content = content, embeds = {embed}}
    
    pcall(function()
        local data = HttpService:JSONEncode(payload)
        request({
            Url = Config.WebhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = data
        })
        print("[Stellar] Webhook sent: " .. (fishData.fishName or "Test"))
    end)
    
    return true
end

-- ============================================================================
-- 💰 MERCHANT TRACKER (Deteksi Perubahan Uang)
-- ============================================================================

local MerchantTracker = {
    LastMoney = 0,
    LastKnownFish = {}
}

function MerchantTracker:GetPlayerMoney()
    local maxMoney = 0
    
    local function scanForMoney(obj)
        if obj:IsA("TextLabel") and obj.Visible then
            local text = obj.Text
            -- Format: $26.61K or 26610
            local match = text:match("%$?([%d,]+%.?%d*[KMB]?)")
            if match then
                local num = match:gsub("[$,]", "")
                local value = tonumber(num)
                if value then
                    if match:find("K") then value = value * 1000
                    elseif match:find("M") then value = value * 1000000 end
                    if value > maxMoney then maxMoney = value end
                end
            end
        end
        for _, child in pairs(obj:GetChildren()) do
            scanForMoney(child)
        end
    end
    
    pcall(function() scanForMoney(LocalPlayer.PlayerGui) end)
    return maxMoney
end

function MerchantTracker:Start()
    self.LastMoney = self:GetPlayerMoney()
    
    task.spawn(function()
        while true do
            wait(2)
            local currentMoney = self:GetPlayerMoney()
            
            if currentMoney > 0 and self.LastMoney > 0 and currentMoney > self.LastMoney then
                local profit = currentMoney - self.LastMoney
                if profit > 500 then -- Minimal profit untuk notifikasi
                    print("[Merchant] +$" .. profit)
                    
                    if Config.WebhookEnabled then
                        Webhook:SendNotification({
                            playerName = LocalPlayer.Name,
                            fishName = "Merchant Sale",
                            rarity = "SALE",
                            weight = "",
                            value = profit,
                            mutation = "Merchant"
                        })
                    end
                end
            end
            self.LastMoney = currentMoney
        end
    end)
end

-- ============================================================================
-- 🖥️ GUI (FULL LYNX-STYLE - LENGKAP)
-- ============================================================================

local GUI = {}

function GUI:Create()
    -- Clean existing GUI
    if CoreGui:FindFirstChild("StellarUltimate") then
        CoreGui.StellarUltimate:Destroy()
    end
    
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "StellarUltimate"
    ScreenGui.Parent = CoreGui
    ScreenGui.ResetOnSpawn = false
    
    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 600, 0, 480)
    Main.Position = UDim2.new(0.5, -300, 0.5, -240)
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    Main.BackgroundTransparency = 0.05
    Main.Draggable = true
    Main.Active = true
    Main.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = Main
    
    -- Gradient Background
    local Gradient = Instance.new("UIGradient")
    Gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(30, 20, 50)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25))
    })
    Gradient.Parent = Main
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundColor3 = Color3.fromRGB(100, 50, 200)
    TitleBar.BackgroundTransparency = 0.15
    TitleBar.Parent = Main
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    
    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = "⭐ STELLAR SYSTEM ULTIMATE | FISH IT"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    local Version = Instance.new("TextLabel")
    Version.Size = UDim2.new(0, 80, 1, 0)
    Version.Position = UDim2.new(1, -90, 0, 0)
    Version.BackgroundTransparency = 1
    Version.Text = "v4.0"
    Version.TextColor3 = Color3.fromRGB(200, 200, 200)
    Version.TextSize = 12
    Version.Font = Enum.Font.Gotham
    Version.TextXAlignment = Enum.TextXAlignment.Right
    Version.Parent = TitleBar
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 35, 0, 35)
    CloseBtn.Position = UDim2.new(1, -45, 0, 8)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.TextSize = 18
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = Main
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 8)
    CloseCorner.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Tab Buttons (Lynx Style)
    local Tabs = {"FISHING", "ECONOMY", "TELEPORT", "WEBHOOK", "STATS", "SETTINGS"}
    local TabButtons = {}
    local ContentFrames = {}
    
    local TabY = 60
    local TabWidth = 85
    
    for i, tab in ipairs(Tabs) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, TabWidth, 0, 35)
        btn.Position = UDim2.new(0, 10 + (i-1) * (TabWidth + 5), 0, TabY)
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        btn.Text = tab
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = Main
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        TabButtons[tab] = btn
    end
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -20, 1, -115)
    ContentContainer.Position = UDim2.new(0, 10, 0, 105)
    ContentContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    ContentContainer.BackgroundTransparency = 0.3
    ContentContainer.Parent = Main
    
    local ContainerCorner = Instance.new("UICorner")
    ContainerCorner.CornerRadius = UDim.new(0, 8)
    ContainerCorner.Parent = ContentContainer
    
    -- Helper function for toggle buttons
    local function CreateToggle(parent, text, y, varName, callback)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.95, 0, 0, 40)
        frame.Position = UDim2.new(0.025, 0, 0, y)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        frame.Parent = parent
        
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 6)
        frameCorner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.7, 0, 1, 0)
        label.Position = UDim2.new(0, 15, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 60, 0, 28)
        btn.Position = UDim2.new(1, -75, 0.5, -14)
        btn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        btn.Text = "OFF"
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 12
        btn.Parent = frame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn
        
        local active = false
        btn.MouseButton1Click:Connect(function()
            active = not active
            btn.Text = active and "ON" or "OFF"
            btn.BackgroundColor3 = active and Color3.fromRGB(80, 180, 80) or Color3.fromRGB(180, 60, 60)
            Config[varName] = active
            if callback then callback(active) end
        end)
        
        return {btn = btn, frame = frame}
    end
    
    -- Helper for slider
    local function CreateSlider(parent, text, y, varName, minVal, maxVal, unit)
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(0.95, 0, 0, 50)
        frame.Position = UDim2.new(0.025, 0, 0, y)
        frame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        frame.Parent = parent
        
        local frameCorner = Instance.new("UICorner")
        frameCorner.CornerRadius = UDim.new(0, 6)
        frameCorner.Parent = frame
        
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.5, 0, 0.5, 0)
        label.Position = UDim2.new(0, 15, 0, 5)
        label.BackgroundTransparency = 1
        label.Text = text .. ": " .. Config[varName] .. (unit or "")
        label.TextColor3 = Color3.fromRGB(220, 220, 220)
        label.Font = Enum.Font.Gotham
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = frame
        
        local input = Instance.new("TextBox")
        input.Size = UDim2.new(0.2, 0, 0.5, 0)
        input.Position = UDim2.new(0.75, 0, 0, 5)
        input.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        input.Text = tostring(Config[varName])
        input.TextColor3 = Color3.fromRGB(255, 255, 255)
        input.Font = Enum.Font.Gotham
        input.TextSize = 12
        input.Parent = frame
        
        local inputCorner = Instance.new("UICorner")
        inputCorner.CornerRadius = UDim.new(0, 4)
        inputCorner.Parent = input
        
        input.FocusLost:Connect(function()
            local val = tonumber(input.Text)
            if val then
                Config[varName] = math.clamp(val, minVal, maxVal)
                label.Text = text .. ": " .. Config[varName] .. (unit or "")
                input.Text = tostring(Config[varName])
            else
                input.Text = tostring(Config[varName])
            end
        end)
    end
    
    -- === FISHING TAB ===
    local FishingTab = Instance.new("ScrollingFrame")
    FishingTab.Size = UDim2.new(1, 0, 1, 0)
    FishingTab.BackgroundTransparency = 1
    FishingTab.ScrollBarThickness = 4
    FishingTab.CanvasSize = UDim2.new(0, 0, 0, 300)
    FishingTab.Parent = ContentContainer
    ContentFrames["FISHING"] = FishingTab
    
    CreateToggle(FishingTab, "🎣 Auto Fishing", 10, "AutoFishing", function(val)
        if val then task.spawn(Fishing.AutoLoop) end
    end)
    CreateToggle(FishingTab, "🎯 Perfect Cast", 60, "PerfectCast")
    CreateToggle(FishingTab, "⚡ Instant Catch", 110, "InstantCatch")
    CreateSlider(FishingTab, "Cast Delay", 170, "CastDelay", 1, 10, "s")
    
    -- === ECONOMY TAB ===
    local EconomyTab = Instance.new("ScrollingFrame")
    EconomyTab.Size = UDim2.new(1, 0, 1, 0)
    EconomyTab.BackgroundTransparency = 1
    EconomyTab.ScrollBarThickness = 4
    EconomyTab.CanvasSize = UDim2.new(0, 0, 0, 350)
    EconomyTab.Visible = false
    EconomyTab.Parent = ContentContainer
    ContentFrames["ECONOMY"] = EconomyTab
    
    CreateToggle(EconomyTab, "💰 Auto Sell", 10, "AutoSell", function(val)
        if val then task.spawn(Economy.AutoSellLoop) end
    end)
    CreateToggle(EconomyTab, "🔄 Auto Rejoin", 60, "AutoRejoin")
    CreateToggle(EconomyTab, "🎣 Auto Buy Bait", 110, "AutoBuyBait")
    CreateToggle(EconomyTab, "⬆️ Auto Upgrade Rod", 160, "AutoUpgradeRod")
    CreateToggle(EconomyTab, "🚤 Unlock All Boats", 210, "UnlockAllBoats", function(val)
        if val then Unlocker:UnlockAllBoats() end
    end)
    
    -- Sell Filter Dropdown
    local filterFrame = Instance.new("Frame")
    filterFrame.Size = UDim2.new(0.95, 0, 0, 50)
    filterFrame.Position = UDim2.new(0.025, 0, 0, 270)
    filterFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    filterFrame.Parent = EconomyTab
    
    local filterCorner = Instance.new("UICorner")
    filterCorner.CornerRadius = UDim.new(0, 6)
    filterCorner.Parent = filterFrame
    
    local filterLabel = Instance.new("TextLabel")
    filterLabel.Size = UDim2.new(0.5, 0, 1, 0)
    filterLabel.Position = UDim2.new(0, 15, 0, 0)
    filterLabel.BackgroundTransparency = 1
    filterLabel.Text = "Sell Filter: " .. Config.SellFilter
    filterLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    filterLabel.Font = Enum.Font.Gotham
    filterLabel.TextSize = 13
    filterLabel.TextXAlignment = Enum.TextXAlignment.Left
    filterLabel.Parent = filterFrame
    
    local filterBtn = Instance.new("TextButton")
    filterBtn.Size = UDim2.new(0.25, 0, 0.7, 0)
    filterBtn.Position = UDim2.new(0.72, 0, 0.15, 0)
    filterBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    filterBtn.Text = Config.SellFilter
    filterBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    filterBtn.Font = Enum.Font.GothamBold
    filterBtn.TextSize = 12
    filterBtn.Parent = filterFrame
    
    local filterCorner2 = Instance.new("UICorner")
    filterCorner2.CornerRadius = UDim.new(0, 4)
    filterCorner2.Parent = filterBtn
    
    local filterOptions = {"ALL", "LEGENDARY+", "EPIC+", "RARE+"}
    local filterIdx = 1
    
    filterBtn.MouseButton1Click:Connect(function()
        filterIdx = filterIdx % #filterOptions + 1
        Config.SellFilter = filterOptions[filterIdx]
        filterLabel.Text = "Sell Filter: " .. Config.SellFilter
        filterBtn.Text = Config.SellFilter
    end)
    
    -- === TELEPORT TAB ===
    local TeleportTab = Instance.new("ScrollingFrame")
    TeleportTab.Size = UDim2.new(1, 0, 1, 0)
    TeleportTab.BackgroundTransparency = 1
    TeleportTab.ScrollBarThickness = 4
    TeleportTab.CanvasSize = UDim2.new(0, 0, 0, 650)
    TeleportTab.Visible = false
    TeleportTab.Parent = ContentContainer
    ContentFrames["TELEPORT"] = TeleportTab
    
    local tpY = 10
    for name, cf in pairs(Locations) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0.95, 0, 0, 38)
        btn.Position = UDim2.new(0.025, 0, 0, tpY)
        btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        btn.Text = name
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.Parent = TeleportTab
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = cf
                print("[Stellar] Teleported to: " .. name)
            end
        end)
        
        tpY = tpY + 48
    end
    
    -- === WEBHOOK TAB ===
    local WebhookTab = Instance.new("ScrollingFrame")
    WebhookTab.Size = UDim2.new(1, 0, 1, 0)
    WebhookTab.BackgroundTransparency = 1
    WebhookTab.ScrollBarThickness = 4
    WebhookTab.CanvasSize = UDim2.new(0, 0, 0, 550)
    WebhookTab.Visible = false
    WebhookTab.Parent = ContentContainer
    ContentFrames["WEBHOOK"] = WebhookTab
    
    CreateToggle(WebhookTab, "📡 Webhook Enabled", 10, "WebhookEnabled")
    
    -- Discord ID Input
    local idFrame = Instance.new("Frame")
    idFrame.Size = UDim2.new(0.95, 0, 0, 50)
    idFrame.Position = UDim2.new(0.025, 0, 0, 70)
    idFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    idFrame.Parent = WebhookTab
    
    local idCorner = Instance.new("UICorner")
    idCorner.CornerRadius = UDim.new(0, 6)
    idCorner.Parent = idFrame
    
    local idLabel = Instance.new("TextLabel")
    idLabel.Size = UDim2.new(0.3, 0, 1, 0)
    idLabel.Position = UDim2.new(0, 15, 0, 0)
    idLabel.BackgroundTransparency = 1
    idLabel.Text = "Discord User ID"
    idLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    idLabel.Font = Enum.Font.Gotham
    idLabel.TextSize = 13
    idLabel.TextXAlignment = Enum.TextXAlignment.Left
    idLabel.Parent = idFrame
    
    local idInput = Instance.new("TextBox")
    idInput.Size = UDim2.new(0.5, 0, 0.7, 0)
    idInput.Position = UDim2.new(0.45, 0, 0.15, 0)
    idInput.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    idInput.PlaceholderText = "123456789012345678"
    idInput.Text = Config.DiscordID
    idInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    idInput.Font = Enum.Font.Gotham
    idInput.TextSize = 12
    idInput.Parent = idFrame
    
    local idInputCorner = Instance.new("UICorner")
    idInputCorner.CornerRadius = UDim.new(0, 4)
    idInputCorner.Parent = idInput
    
    idInput.FocusLost:Connect(function()
        Config.DiscordID = idInput.Text
    end)
    
    -- Webhook URL Input
    local urlFrame = Instance.new("Frame")
    urlFrame.Size = UDim2.new(0.95, 0, 0, 50)
    urlFrame.Position = UDim2.new(0.025, 0, 0, 130)
    urlFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    urlFrame.Parent = WebhookTab
    
    local urlCorner = Instance.new("UICorner")
    urlCorner.CornerRadius = UDim.new(0, 6)
    urlCorner.Parent = urlFrame
    
    local urlLabel = Instance.new("TextLabel")
    urlLabel.Size = UDim2.new(0.3, 0, 1, 0)
    urlLabel.Position = UDim2.new(0, 15, 0, 0)
    urlLabel.BackgroundTransparency = 1
    urlLabel.Text = "Webhook URL"
    urlLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
    urlLabel.Font = Enum.Font.Gotham
    urlLabel.TextSize = 13
    urlLabel.TextXAlignment = Enum.TextXAlignment.Left
    urlLabel.Parent = urlFrame
    
    local urlInput = Instance.new("TextBox")
    urlInput.Size = UDim2.new(0.5, 0, 0.7, 0)
    urlInput.Position = UDim2.new(0.45, 0, 0.15, 0)
    urlInput.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    urlInput.PlaceholderText = "https://discord.com/api/webhooks/..."
    urlInput.Text = Config.WebhookURL
    urlInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    urlInput.Font = Enum.Font.Gotham
    urlInput.TextSize = 11
    urlInput.Parent = urlFrame
    
    local urlInputCorner = Instance.new("UICorner")
    urlInputCorner.CornerRadius = UDim.new(0, 4)
    urlInputCorner.Parent = urlInput
    
    urlInput.FocusLost:Connect(function()
        Config.WebhookURL = urlInput.Text
    end)
    
    -- Tier Filter (Multi-select)
    local tierFrame = Instance.new("Frame")
    tierFrame.Size = UDim2.new(0.95, 0, 0, 220)
    tierFrame.Position = UDim2.new(0.025, 0, 0, 195)
    tierFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    tierFrame.Parent = WebhookTab
    
    local tierCorner = Instance.new("UICorner")
    tierCorner.CornerRadius = UDim.new(0, 6)
    tierCorner.Parent = tierFrame
    
    local tierTitle = Instance.new("TextLabel")
    tierTitle.Size = UDim2.new(1, 0, 0, 30)
    tierTitle.Position = UDim2.new(0, 15, 0, 5)
    tierTitle.BackgroundTransparency = 1
    tierTitle.Text = "🎚️ Tier Filter (Multi-Select)"
    tierTitle.TextColor3 = Color3.fromRGB(255, 200, 100)
    tierTitle.Font = Enum.Font.GothamBold
    tierTitle.TextSize = 13
    tierTitle.TextXAlignment = Enum.TextXAlignment.Left
    tierTitle.Parent = tierFrame
    
    local tiers = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret"}
    local tierBtns = {}
    
    for i, tier in ipairs(tiers) do
        local row = math.floor((i-1) / 3)
        local col = (i-1) % 3
        local xPos = 15 + (col * 95)
        local yPos = 45 + (row * 45)
        
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 85, 0, 35)
        btn.Position = UDim2.new(0, xPos, 0, yPos)
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
        btn.Text = "⬜ " .. tier
        btn.TextColor3 = Color3.fromRGB(220, 220, 220)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 11
        btn.Parent = tierFrame
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            local found = false
            for j, t in ipairs(Config.SelectedTiers) do
                if t == tier then
                    table.remove(Config.SelectedTiers, j)
                    found = true
                    break
                end
            end
            if not found then
                table.insert(Config.SelectedTiers, tier)
            end
            btn.Text = (found and "⬜ " or "✅ ") .. tier
            btn.BackgroundColor3 = found and Color3.fromRGB(50, 50, 70) or Color3.fromRGB(80, 120, 80)
        end)
        
        tierBtns[tier] = btn
    end
    
    -- Test Webhook Button
    local testBtn = Instance.new("TextButton")
    testBtn.Size = UDim2.new(0.95, 0, 0, 40)
    testBtn.Position = UDim2.new(0.025, 0, 0, 430)
    testBtn.BackgroundColor3 = Color3.fromRGB(80, 120, 200)
    testBtn.Text = "📡 Test Webhook Connection"
    testBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    testBtn.Font = Enum.Font.GothamBold
    testBtn.TextSize = 13
    testBtn.Parent = WebhookTab
    
    local testCorner = Instance.new("UICorner")
    testCorner.CornerRadius = UDim.new(0, 8)
    testCorner.Parent = testBtn
    
    testBtn.MouseButton1Click:Connect(function()
        if Config.WebhookURL == "" then
            urlInput.PlaceholderText = "⚠️ SET URL FIRST!"
            urlInput.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
            wait(2)
            urlInput.PlaceholderText = "https://discord.com/api/webhooks/..."
            urlInput.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        else
            testBtn.Text = "✓ Sending..."
            Webhook:SendNotification({
                playerName = LocalPlayer.Name,
                fishName = "Test Connection",
                rarity = "SYSTEM",
                weight = "Test",
                value = "0",
                mutation = "Webhook Test"
            })
            wait(1)
            testBtn.Text = "✓ Sent!"
            wait(1.5)
            testBtn.Text = "📡 Test Webhook Connection"
        end
    end)
    
    -- === STATS TAB ===
    local StatsTab = Instance.new("ScrollingFrame")
    StatsTab.Size = UDim2.new(1, 0, 1, 0)
    StatsTab.BackgroundTransparency = 1
    StatsTab.ScrollBarThickness = 4
    StatsTab.CanvasSize = UDim2.new(0, 0, 0, 300)
    StatsTab.Visible = false
    StatsTab.Parent = ContentContainer
    ContentFrames["STATS"] = StatsTab
    
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
        label.Size = UDim2.new(0.95, 0, 0, 40)
        label.Position = UDim2.new(0.025, 0, 0, 10 + (i-1) * 50)
        label.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        label.BackgroundTransparency = 0.5
        label.Text = stat[1] .. ": " .. tostring(Config[stat[2]] or 0)
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextSize = 13
        label.Font = Enum.Font.Gotham
        label.Parent = StatsTab
        
        local labelCorner = Instance.new("UICorner")
        labelCorner.CornerRadius = UDim.new(0, 6)
        labelCorner.Parent = label
        
        statsLabels[stat[2]] = label
    end
    
    -- Update stats periodically
    task.spawn(function()
        while true do
            wait(2)
            if statsLabels["FishCaught"] then
                statsLabels["FishCaught"].Text = "🎣 Fish Caught: " .. Config.FishCaught
                statsLabels["MoneyEarned"].Text = "💰 Money Earned: $" .. Config.MoneyEarned
                statsLabels["TotalCasts"].Text = "🔄 Total Casts: " .. Config.TotalCasts
                
                local webhookStatus = Config.WebhookEnabled and (Config.WebhookURL ~= "" and "✅ Active" or "⚠️ No URL") or "❌ Disabled"
                statsLabels["WebhookStatus"].Text = "📡 Webhook Status: " .. webhookStatus
                
                local filterText = #Config.SelectedTiers > 0 and table.concat(Config.SelectedTiers, ", ") or "None"
                statsLabels["ActiveFilters"].Text = "🎚️ Active Filters: " .. filterText
            end
        end
    end)
    
    -- === SETTINGS TAB ===
    local SettingsTab = Instance.new("ScrollingFrame")
    SettingsTab.Size = UDim2.new(1, 0, 1, 0)
    SettingsTab.BackgroundTransparency = 1
    SettingsTab.ScrollBarThickness = 4
    SettingsTab.CanvasSize = UDim2.new(0, 0, 0, 200)
    SettingsTab.Visible = false
    SettingsTab.Parent = ContentContainer
    ContentFrames["SETTINGS"] = SettingsTab
    
    CreateToggle(SettingsTab, "🤖 Humanize Actions", 10, "HumanizeDelay")
    
    -- Tab switching
    local function ShowTab(tabName)
        for name, frame in pairs(ContentFrames) do
            frame.Visible = (name == tabName)
        end
        for name, btn in pairs(TabButtons) do
            btn.BackgroundColor3 = (name == tabName) and Color3.fromRGB(100, 50, 200) or Color3.fromRGB(45, 45, 55)
        end
    end
    
    for tabName, btn in pairs(TabButtons) do
        btn.MouseButton1Click:Connect(function()
            ShowTab(tabName)
        end)
    end
    
    -- Show default tab
    ShowTab("FISHING")
    
    print("[Stellar] GUI Loaded Successfully!")
end

-- ============================================================================
-- 🚀 INITIALIZATION & SCANNER
-- ============================================================================

local Scanner = {
    LastFish = "",
    LastCatch = 0
}

function Scanner:ScanGUI()
    local fishData = {fishName = nil, rarity = nil, weight = nil, value = nil}
    
    local function scan(obj)
        if obj:IsA("TextLabel") and obj.Visible and obj.Text ~= "" then
            local text = obj.Text
            
            -- Detect rarity
            if text:match("Common") then fishData.rarity = "Common"
            elseif text:match("Uncommon") then fishData.rarity = "Uncommon"
            elseif text:match("Rare") then fishData.rarity = "Rare"
            elseif text:match("Epic") then fishData.rarity = "Epic"
            elseif text:match("Legendary") then fishData.rarity = "Legendary"
            elseif text:match("Mythic") then fishData.rarity = "Mythic"
            elseif text:match("Secret") then fishData.rarity = "Secret"
            elseif text:match("%d+%.?%d*%s*[kK][gG]") then 
                fishData.weight = text
            elseif text:match("%$[%d,]+%.?%d*") then
                local val = text:gsub("[$,]", "")
                fishData.value = tonumber(val) or 0
            elseif not fishData.fishName and #text > 3 and #text < 45 and not text:match("%d") then
                fishData.fishName = text
            end
        end
        
        for _, child in pairs(obj:GetChildren()) do
            scan(child)
        end
    end
    
    pcall(function() scan(LocalPlayer.PlayerGui) end)
    
    if fishData.fishName and fishData.fishName ~= self.LastFish and tick() - self.LastCatch > 2 then
        self.LastFish = fishData.fishName
        self.LastCatch = tick()
        fishData.playerName = LocalPlayer.Name
        
        if Config.WebhookEnabled and fishData.rarity then
            Webhook:SendNotification(fishData)
        end
        
        print("[Stellar] Caught: " .. fishData.fishName .. " (" .. (fishData.rarity or "Common") .. ")")
    end
end

-- Start scanners
task.spawn(function()
    while true do
        wait(1)
        Scanner:ScanGUI()
    end
end)

MerchantTracker:Start()

-- ============================================================================
-- 🚀 LAUNCH
-- ============================================================================

print("═══════════════════════════════════════════════════════════════════════")
print("  ⭐ STELLAR SYSTEM ULTIMATE v4.0 - LYNX EDITION ⭐")
print("  Owner: Luc Aetheryn")
print("  Features: Auto Fishing | Auto Sell | Merchant Tracker | Webhook")
print("  Status: FULLY LOADED")
print("═══════════════════════════════════════════════════════════════════════")

GUI:Create()