---
name: roblox-developer-pro
description: "Expert Roblox development including advanced Luau, DataStores, Knit framework, and scalable game systems"
---

# Roblox Developer Pro

## Overview

This skill transforms you into a **Professional Roblox Developer**. You will master **Luau Programming**, **DataStores**, **Framework Patterns (Knit)**, and **Monetization** for building production-quality Roblox experiences.

## When to Use This Skill

- Use when building Roblox games with complex systems
- Use when implementing persistent player data
- Use when structuring code with frameworks
- Use when optimizing for performance
- Use when implementing monetization (Robux)

---

## Part 1: Luau Patterns

### 1.1 Modern Luau Features

| Feature | Example |
|---------|---------|
| **Type Annotations** | `function add(a: number, b: number): number` |
| **Generics** | `type Array<T> = {[number]: T}` |
| **String Interpolation** | `` `Hello {name}` `` |
| **Compound Assignment** | `x += 1` |
| **Continue Statement** | `continue` in loops |

### 1.2 Type-Safe Luau

```lua
type PlayerData = {
    coins: number,
    level: number,
    inventory: {string},
}

local function saveData(player: Player, data: PlayerData): boolean
    -- Implementation
    return true
end
```

### 1.3 Module Pattern

```lua
-- PlayerService.lua
local PlayerService = {}

function PlayerService.init()
    -- Initialize
end

function PlayerService.getPlayer(userId: number): Player?
    return Players:GetPlayerByUserId(userId)
end

return PlayerService
```

---

## Part 2: DataStores

### 2.1 Basic DataStore

```lua
local DataStoreService = game:GetService("DataStoreService")
local playerDataStore = DataStoreService:GetDataStore("PlayerData")

local function loadData(player: Player)
    local success, data = pcall(function()
        return playerDataStore:GetAsync("Player_" .. player.UserId)
    end)
    
    if success and data then
        return data
    else
        return { coins = 0, level = 1 }  -- Default
    end
end

local function saveData(player: Player, data: PlayerData)
    local success, err = pcall(function()
        playerDataStore:SetAsync("Player_" .. player.UserId, data)
    end)
    
    if not success then
        warn("Failed to save: " .. err)
    end
end
```

### 2.2 UpdateAsync for Race Conditions

```lua
playerDataStore:UpdateAsync("Player_" .. player.UserId, function(oldData)
    oldData = oldData or { coins = 0 }
    oldData.coins += coinsToAdd
    return oldData
end)
```

### 2.3 SessionLocking (ProfileService)

Use ProfileService library for production:

- Prevents data loss from multiple servers.
- Auto-retry, auto-save.

---

## Part 3: Knit Framework

### 3.1 What is Knit?

A lightweight framework for organizing client/server code.

### 3.2 Server Service

```lua
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local CoinService = Knit.CreateService {
    Name = "CoinService",
    Client = {
        CoinsChanged = Knit.CreateSignal(),
    },
}

function CoinService:AddCoins(player: Player, amount: number)
    local data = self:GetData(player)
    data.coins += amount
    self.Client.CoinsChanged:Fire(player, data.coins)
end

function CoinService.Client:GetCoins(player: Player): number
    return self:GetData(player).coins
end

return CoinService
```

### 3.3 Client Controller

```lua
local Knit = require(game.ReplicatedStorage.Packages.Knit)

local CoinsController = Knit.CreateController { Name = "CoinsController" }

function CoinsController:KnitStart()
    local CoinService = Knit.GetService("CoinService")
    
    CoinService.CoinsChanged:Connect(function(coins)
        print("Coins updated: " .. coins)
    end)
end

return CoinsController
```

---

## Part 4: Monetization

### 4.1 Developer Products (One-Time)

```lua
local MarketplaceService = game:GetService("MarketplaceService")
local PRODUCT_ID = 123456789

MarketplaceService.ProcessReceipt = function(receiptInfo)
    local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
    if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
    
    if receiptInfo.ProductId == PRODUCT_ID then
        -- Grant coins
        playerData.coins += 1000
    end
    
    return Enum.ProductPurchaseDecision.PurchaseGranted
end
```

### 4.2 Game Passes (Permanent)

```lua
local function hasGamePass(player: Player, passId: number): boolean
    local success, owns = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
    end)
    return success and owns
end
```

---

## Part 5: Performance

### 5.1 Common Optimizations

| Issue | Solution |
|-------|----------|
| **Too many parts** | Use MeshParts, StreamingEnabled |
| **Expensive loops** | Use coroutines, batch processing |
| **Memory leaks** | Disconnect events, clear tables |
| **Network spam** | Throttle RemoteEvents |

### 5.2 Streaming Enabled

Dynamically load/unload map sections based on player position.

```lua
workspace.StreamingEnabled = true
workspace.StreamOutBehavior = Enum.StreamOutBehavior.Opportunistic
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use ProfileService**: For production data storage.
- ✅ **Validate Client Input**: Never trust the client.
- ✅ **Type Everything**: Luau types catch bugs early.

### ❌ Avoid This

- ❌ **Client Authority**: Server must validate all important actions.
- ❌ **Auto-Saving Too Often**: DataStore limits (60 requests/min/key).
- ❌ **Ignoring Mobile**: 50%+ players are on mobile.

---

## Related Skills

- `@roblox-developer` - Beginner Roblox
- `@game-design-specialist` - Game design principles
- `@senior-typescript-developer` - Roblox-ts alternative
