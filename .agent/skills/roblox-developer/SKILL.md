---
name: roblox-developer
description: "Expert Roblox game development using Lua, Roblox Studio, and game monetization"
---

# Roblox Developer

## Overview

Build Roblox games using Lua scripting and Roblox Studio.

## When to Use This Skill

- Use when creating Roblox games
- Use when scripting game mechanics

## How It Works

### Step 1: Roblox Structure

```markdown
## Game Architecture

Workspace
├── Parts (3D objects)
├── Models (grouped objects)
├── NPCs & Characters
└── Terrain

ServerScriptService
└── Server-side scripts (secure)

ReplicatedStorage
└── Shared modules & assets

StarterPlayer
├── StarterCharacterScripts
└── StarterPlayerScripts (client)

ServerStorage
└── Server-only assets
```

### Step 2: Basic Lua Script

```lua
-- Server Script: Give player coins on touch
local part = script.Parent

local function onTouch(otherPart)
    local player = game.Players:GetPlayerFromCharacter(otherPart.Parent)
    if player then
        -- Get leaderstats
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            local coins = leaderstats:FindFirstChild("Coins")
            if coins then
                coins.Value = coins.Value + 10
                print(player.Name .. " collected 10 coins!")
            end
        end
        
        -- Destroy the coin
        part:Destroy()
    end
end

part.Touched:Connect(onTouch)
```

### Step 3: Leaderstats (Player Data)

```lua
-- ServerScriptService: Setup leaderstats
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local playerData = DataStoreService:GetDataStore("PlayerData")

local function onPlayerAdded(player)
    -- Create leaderstats folder
    local leaderstats = Instance.new("Folder")
    leaderstats.Name = "leaderstats"
    leaderstats.Parent = player
    
    -- Create Coins value
    local coins = Instance.new("IntValue")
    coins.Name = "Coins"
    coins.Parent = leaderstats
    
    -- Load saved data
    local success, savedCoins = pcall(function()
        return playerData:GetAsync("coins_" .. player.UserId)
    end)
    
    if success and savedCoins then
        coins.Value = savedCoins
    else
        coins.Value = 0
    end
end

local function onPlayerRemoving(player)
    local coins = player.leaderstats.Coins.Value
    
    pcall(function()
        playerData:SetAsync("coins_" .. player.UserId, coins)
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)
```

### Step 4: RemoteEvents (Client-Server)

```lua
-- ReplicatedStorage: Create RemoteEvent
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local purchaseEvent = Instance.new("RemoteEvent")
purchaseEvent.Name = "PurchaseItem"
purchaseEvent.Parent = ReplicatedStorage

-- Server Script: Handle purchase
local purchaseEvent = ReplicatedStorage:WaitForChild("PurchaseItem")

purchaseEvent.OnServerEvent:Connect(function(player, itemName, price)
    local coins = player.leaderstats.Coins
    
    if coins.Value >= price then
        coins.Value = coins.Value - price
        -- Give item to player
        giveItem(player, itemName)
        print(player.Name .. " purchased " .. itemName)
    else
        -- Not enough coins
        purchaseEvent:FireClient(player, "NotEnoughCoins")
    end
end)

-- Client Script: Request purchase
local purchaseEvent = ReplicatedStorage:WaitForChild("PurchaseItem")

local function buyItem(itemName, price)
    purchaseEvent:FireServer(itemName, price)
end
```

### Step 5: Game Pass & Robux

```lua
-- Check if player owns game pass
local MarketplaceService = game:GetService("MarketplaceService")

local GAMEPASS_ID = 12345678 -- Your gamepass ID

local function hasGamePass(player)
    local success, hasPass = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, GAMEPASS_ID)
    end)
    
    return success and hasPass
end

-- Prompt purchase
local function promptPurchase(player)
    MarketplaceService:PromptGamePassPurchase(player, GAMEPASS_ID)
end

-- Handle purchase completed
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, gamePassId, wasPurchased)
    if wasPurchased and gamePassId == GAMEPASS_ID then
        -- Give VIP benefits
        giveVIPBenefits(player)
    end
end)
```

## Best Practices

- ✅ Never trust client input
- ✅ Use DataStores with pcall
- ✅ Optimize with debounce
- ❌ Don't put secure logic on client
- ❌ Don't skip data backup

## Related Skills

- `@unity-game-developer`
- `@senior-backend-developer`
