---
name: unity-game-developer-pro
description: "Expert Unity development focusing on advanced patterns, DOTS, addressables, and performance optimization"
---

# Unity Game Developer (Pro)

## Overview

Master advanced Unity development. Expertise in DOTS (Data-Oriented Technology Stack), Entity Component System (ECS), Job System, Burst Compiler, Addressables for asset management, and advanced rendering optimization.

## When to Use This Skill

- Use when building large-scale, high-performance Unity games
- Use when optimizing CPU-bound game logic with DOTS
- Use for efficient memory and asset management via Addressables
- Use when implementing complex systems like massive crowd simulation

## How It Works

### Step 1: DOTS & ECS (Entity Component System)

```csharp
// Component Data
public struct Speed : IComponentData {
    public float Value;
}

// System using SystemBase
public partial class MoveSystem : SystemBase {
    protected override void OnUpdate() {
        float deltaTime = SystemAPI.Time.DeltaTime;
        
        Entities.ForEach((ref LocalTransform transform, in Speed speed) => {
            transform.Position += transform.Forward() * speed.Value * deltaTime;
        }).ScheduleParallel();
    }
}
```

### Step 2: C# Job System & Burst Compiler

```csharp
[BurstCompile]
public struct HeavyMathJob : IJobParallelFor {
    public NativeArray<float> Results;
    
    public void Execute(int index) {
        // High performance math here
        Results[index] = math.sqrt(math.pow(Results[index], 2));
    }
}
```

### Step 3: Addressables & Asset Management

```csharp
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

public class AssetLoader : MonoBehaviour {
    public AssetReference objectToLoad;

    void Start() {
        objectToLoad.InstantiateAsync().Completed += (op) => {
            if (op.Status == AsyncOperationStatus.Succeeded) {
                Debug.Log("Asset loaded!");
            }
        };
    }
}
```

### Step 4: SRP & Custom Shader Graph

- **URP/HDRP**: Choose the right Scriptable Render Pipeline for your hardware target.
- **Shader Graph**: Create custom visual effects with node-based logic.
- **VFX Graph**: Handle millions of GPU-simulated particles.

## Best Practices

### ✅ Do This

- ✅ Prefer `NativeArray` and `NativeList` for DOTS-compatible data structures
- ✅ Use `[BurstCompile]` on jobs for massive speedups
- ✅ Use Addressables to reduce initial app bundle size
- ✅ Profile with "Frame Debugger" and "Memory Profiler"
- ✅ Implementation of Object Pooling for non-ECS objects

### ❌ Avoid This

- ❌ Don't use `GameObject` or `MonoBehaviour` within ECS systems
- ❌ Don't block the main thread with heavy `AsyncOperation`
- ❌ Don't ignore "Batched Draw Calls" (use GPU Instancing)
- ❌ Don't use raw pointers without `unsafe` blocks and careful management

## Related Skills

- `@unity-game-developer` - Foundation skills
- `@c-sharp-developer` - Core language
- `@senior-software-architect` - Game engine patterns
