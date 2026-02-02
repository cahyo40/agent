---
name: unity-game-developer-pro
description: "Expert Unity development focusing on advanced patterns, DOTS, addressables, and performance optimization"
---

# Unity Game Developer Pro

## Overview

This skill transforms you into a **Professional Unity Developer**. You will master **ECS/DOTS**, **Addressables**, **Performance Optimization**, and **Advanced Patterns** for building AAA-quality games.

## When to Use This Skill

- Use when building performance-critical Unity games
- Use when implementing ECS/DOTS architecture
- Use when optimizing for mobile or console
- Use when managing large asset libraries
- Use when building multiplayer systems

---

## Part 1: Advanced Patterns

### 1.1 Dependency Injection (Zenject/VContainer)

```csharp
// Using VContainer
public class GameInstaller : LifetimeScope
{
    protected override void Configure(IContainerBuilder builder)
    {
        builder.Register<IPlayerService, PlayerService>(Lifetime.Singleton);
        builder.Register<IInventoryService, InventoryService>(Lifetime.Singleton);
    }
}

// Usage
public class Player : MonoBehaviour
{
    [Inject] private readonly IPlayerService _playerService;
}
```

### 1.2 Service Locator (Simple Pattern)

```csharp
public static class ServiceLocator
{
    private static readonly Dictionary<Type, object> _services = new();

    public static void Register<T>(T service) where T : class
    {
        _services[typeof(T)] = service;
    }

    public static T Get<T>() where T : class
    {
        return _services[typeof(T)] as T;
    }
}
```

### 1.3 State Machine

```csharp
public interface IState
{
    void Enter();
    void Update();
    void Exit();
}

public class StateMachine
{
    private IState _currentState;

    public void ChangeState(IState newState)
    {
        _currentState?.Exit();
        _currentState = newState;
        _currentState?.Enter();
    }

    public void Update() => _currentState?.Update();
}
```

---

## Part 2: ECS / DOTS

### 2.1 What is DOTS?

Data-Oriented Technology Stack:

- **Entities**: Lightweight game objects.
- **Components**: Pure data (no behavior).
- **Systems**: Logic that operates on components.

### 2.2 Example System

```csharp
public partial struct MovementSystem : ISystem
{
    public void OnUpdate(ref SystemState state)
    {
        float deltaTime = SystemAPI.Time.DeltaTime;
        
        foreach (var (transform, velocity) 
            in SystemAPI.Query<RefRW<LocalTransform>, RefRO<Velocity>>())
        {
            transform.ValueRW.Position += velocity.ValueRO.Value * deltaTime;
        }
    }
}
```

### 2.3 When to Use DOTS

- **Large Entity Counts**: 10,000+ objects.
- **CPU-Bound Workloads**: Simulations, AI.
- **Mobile Optimization**: Better battery/performance.

---

## Part 3: Addressables

### 3.1 Why Addressables?

- **Async Loading**: Don't block main thread.
- **Memory Management**: Load/unload by address.
- **Remote Content**: Download assets from CDN.

### 3.2 Loading Assets

```csharp
using UnityEngine.AddressableAssets;
using UnityEngine.ResourceManagement.AsyncOperations;

public async Task<GameObject> LoadPrefabAsync(string address)
{
    AsyncOperationHandle<GameObject> handle = Addressables.LoadAssetAsync<GameObject>(address);
    await handle.Task;
    
    if (handle.Status == AsyncOperationStatus.Succeeded)
    {
        return handle.Result;
    }
    
    Debug.LogError($"Failed to load: {address}");
    return null;
}
```

### 3.3 Releasing Assets

```csharp
Addressables.Release(handle);
```

---

## Part 4: Performance Optimization

### 4.1 Profiling Tools

| Tool | Purpose |
|------|---------|
| **Unity Profiler** | CPU, GPU, memory analysis |
| **Frame Debugger** | Draw call inspection |
| **Memory Profiler** | Heap snapshots |
| **Profile Analyzer** | Compare builds |

### 4.2 Common Optimizations

| Issue | Solution |
|-------|----------|
| **GC Spikes** | Object pooling, avoid allocations in Update |
| **Draw Calls** | Batching, GPU instancing, SRP Batching |
| **Overdraw** | Reduce transparent objects, occlusion culling |
| **Physics** | Simplify colliders, use layers |
| **Scripts** | Cache component references, avoid Find() |

### 4.3 Object Pooling

```csharp
public class ObjectPool<T> where T : Component
{
    private readonly Queue<T> _pool = new();
    private readonly T _prefab;
    private readonly Transform _parent;

    public ObjectPool(T prefab, int initialSize, Transform parent = null)
    {
        _prefab = prefab;
        _parent = parent;
        
        for (int i = 0; i < initialSize; i++)
        {
            var obj = Object.Instantiate(_prefab, _parent);
            obj.gameObject.SetActive(false);
            _pool.Enqueue(obj);
        }
    }

    public T Get()
    {
        var obj = _pool.Count > 0 ? _pool.Dequeue() : Object.Instantiate(_prefab, _parent);
        obj.gameObject.SetActive(true);
        return obj;
    }

    public void Return(T obj)
    {
        obj.gameObject.SetActive(false);
        _pool.Enqueue(obj);
    }
}
```

---

## Part 5: Multiplayer Basics

### 5.1 Options

| Solution | Best For |
|----------|----------|
| **Unity Netcode for GameObjects** | Small-medium games |
| **Mirror** | Open source, community |
| **Photon Fusion** | Competitive, low-latency |
| **FishNet** | Modern, performant |

### 5.2 Key Concepts

- **NetworkObject**: Synced across network.
- **ServerRpc**: Client → Server call.
- **ClientRpc**: Server → Client call.
- **NetworkVariable**: Auto-synced state.

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Profile Early, Profile Often**: Use Profiler from day one.
- ✅ **Async Loading**: Addressables for everything.
- ✅ **Use Scriptable Objects**: For data-driven design.

### ❌ Avoid This

- ❌ **Find() in Update**: Cache references in Awake/Start.
- ❌ **String Comparisons for Tags**: Use CompareTag().
- ❌ **Ignoring Mobile Constraints**: Test on device early.

---

## Related Skills

- `@unity-game-developer` - Beginner Unity
- `@game-design-specialist` - Game design
- `@cpp-developer` - Native plugins
