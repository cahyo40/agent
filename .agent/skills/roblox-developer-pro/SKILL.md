---
name: roblox-developer-pro
description: "Expert Roblox development including advanced Luau, DataStores, Knit framework, and scalable game systems"
---

# Roblox Developer (Pro)

## Overview

Master professional Roblox development. Expertise in Luau performance, secure DataStore management, the Knit framework for modular architecture, and advanced synchronization between Client and Server.

## When to Use This Skill

- Use when building large-scale or high-revenue Roblox games
- Use when implementing secure and scalable backend systems
- Use for modular, professional game architecture via Knit
- Use when optimizing Luau code for millions of concurrent users

## How It Works

### Step 1: Advanced Luau & Type Checking

```lua
--!strict
type PlayerData = {
    Level: number,
    Experience: number,
    Inventory: {string}
}

local function ProcessData(data: PlayerData)
    print("Player Level: " .. data.Level)
end
```

### Step 2: Knit Framework Architecture

```lua
-- Service (Server)
local Knit = require(game:GetService("ReplicatedStorage").Packages.Knit)

local PointService = Knit.CreateService {
    Name = "PointService",
    Client = {
        PointsChanged = Knit.CreateSignal(),
    },
}

function PointService:AddPoints(player: Player, amount: number)
    -- Logic here
    self.Client.PointsChanged:Fire(player, newPoints)
end

Knit.Start():catch(warn)
```

### Step 3: Secure DataStores (ProfileService)

- **ProfileService**: Use for robust, session-locking data management to prevent item duplication bugs.
- **MemoryStore**: Use for cross-server matchmaking and real-time global auctions.
- **ReplicaService**: Use for efficient state replication from Server to Client.

### Step 4: Parallel Luau & Task Library

```lua
-- Using task library over wait()
task.wait(1)
task.spawn(function()
    -- Non-blocking logic
end)

-- Parallel Luau (Actor model)
-- Use 'task.desynchronize()' and 'task.synchronize()'
```

## Best Practices

### ✅ Do This

- ✅ Use Type Checking (`--!strict`) for better stability
- ✅ Use a framework like Knit to avoid "Spaghetti Code"
- ✅ Leverage `ProfileService` for transactional data safety
- ✅ Use `StreamingEnabled` for large worlds
- ✅ Sanitize all inputs from `RemoteEvents` on the Server

### ❌ Avoid This

- ❌ Don't trust the Client for any game-critical logic (Health, Currency)
- ❌ Don't use `wait()` or `spawn()`—use the `task` library
- ❌ Don't reach DataStore limits (implement proper caching/throttling)
- ❌ Don't over-rely on `RunService.Heartbeat` for heavy logic

## Related Skills

- `@roblox-developer` - Foundation skills
- `@senior-software-engineer` - Professional patterns
- `@backend-developer` - Data management
