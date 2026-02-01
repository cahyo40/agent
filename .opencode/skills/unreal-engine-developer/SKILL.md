---
name: unreal-engine-developer
description: "Expert Unreal Engine development including C++, Blueprints, Nanite, Lumen, and AAA game mechanics"
---

# Unreal Engine Developer

## Overview

Master AAA game development with Unreal Engine. Leverage C++ and Blueprints for game logic, Nanite for virtualized geometry, Lumen for dynamic lighting, and advanced animation systems.

## When to Use This Skill

- Use when building high-fidelity 3D games
- Use when needing performant C++ game logic
- Use when implementing complex physics or AI
- Use when creating cinematic experiences or visualizations

## How It Works

### Step 1: C++ Game Logic & Blueprints

```cpp
// MyCharacter.h
UCLASS()
class MYGAME_API AMyCharacter : public ACharacter
{
    GENERATED_BODY()

public:
    AMyCharacter();

    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Combat")
    float Health;

    UFUNCTION(BlueprintCallable, Category = "Combat")
    void TakeDamage(float Amount);
};

// MyCharacter.cpp
void AMyCharacter::TakeDamage(float Amount) {
    Health = FMath::Max(0.0f, Health - Amount);
}
```

### Step 2: Actor Communication & Events

```cpp
// Delegate for events
DECLARE_DYNAMIC_MULTICAST_DELEGATE_OneParam(FOnHealthChanged, float, NewHealth);

UPROPERTY(BlueprintAssignable, Category = "Events")
FOnHealthChanged OnHealthChanged;

// Broadcasting
OnHealthChanged.Broadcast(Health);
```

### Step 3: Performance Features (Nanite & Lumen)

- **Nanite**: Enable on static meshes for infinite geometric detail without traditional LODs.
- **Lumen**: Use for real-time global illumination and reflections. Adjust "Post Process Volume" for lighting quality.
- **Virtual Textures**: Use for massive texture datasets.

### Step 4: Networking & Multiplayer

```cpp
// Replicating variables
UPROPERTY(ReplicatedUsing = OnRep_Health)
float Health;

void AMyCharacter::GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const {
    Super::GetLifetimeReplicatedProps(OutLifetimeProps);
    DOREPLIFETIME(AMyCharacter, Health);
}

UFUNCTION()
void OnRep_Health() {
    // Client-side logic when health updates
}
```

## Best Practices

### ✅ Do This

- ✅ Use C++ for performance-heavy logic, Blueprints for design flexibility
- ✅ Use `UPROPERTY` and `UFUNCTION` macros for engine reflection
- ✅ Profile with "Unreal Insights" for performance bottlenecks
- ✅ Implement memory management via Smart Pointers and GC references
- ✅ Use "Data Assets" for game configuration

### ❌ Avoid This

- ❌ Don't put heavy logic in `Tick` functions unless necessary
- ❌ Don't hard-reference assets in code (use `TSoftObjectPtr`)
- ❌ Don't ignore "Collision Channels" setup
- ❌ Don't skip "Unit Testing" with the Automation System

## Related Skills

- `@cpp-developer` - Core logic language
- `@unity-game-developer` - Cross-engine comparison
- `@senior-software-architect` - Large-scale game systems
