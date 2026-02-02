---
name: unreal-engine-developer
description: "Expert Unreal Engine development including C++, Blueprints, Nanite, Lumen, and AAA game mechanics"
---

# Unreal Engine Developer

## Overview

This skill transforms you into an **Unreal Engine Expert**. You will master **C++/Blueprints**, **Nanite/Lumen**, **GAS (Gameplay Ability System)**, and **AAA Workflows** for building high-fidelity games.

## When to Use This Skill

- Use when building high-fidelity 3D games
- Use when implementing complex gameplay systems
- Use when using Nanite/Lumen rendering
- Use when balancing C++ and Blueprints
- Use when targeting PC/console AAA quality

---

## Part 1: Unreal Fundamentals

### 1.1 Core Concepts

| Concept | Description |
|---------|-------------|
| **Actor** | Any object placed in world |
| **Component** | Building block of Actors (Mesh, Light) |
| **Pawn** | Actor that can be possessed |
| **Character** | Pawn with movement capabilities |
| **GameMode** | Rules of the game |
| **PlayerController** | Interface between player and Pawn |

### 1.2 C++ vs Blueprints

| Use Case | Language |
|----------|----------|
| **Core Systems** | C++ |
| **Game Logic** | Either |
| **Rapid Prototyping** | Blueprints |
| **UI Event Handling** | Blueprints |
| **Performance-Critical** | C++ |

---

## Part 2: C++ in Unreal

### 2.1 Actor Class

```cpp
// MyActor.h
#pragma once
#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "MyActor.generated.h"

UCLASS()
class MYGAME_API AMyActor : public AActor
{
    GENERATED_BODY()
    
public:
    AMyActor();
    
    UPROPERTY(EditAnywhere, BlueprintReadWrite, Category = "Stats")
    float Health = 100.0f;
    
    UFUNCTION(BlueprintCallable, Category = "Combat")
    void TakeDamage(float Amount);
    
protected:
    virtual void BeginPlay() override;
    virtual void Tick(float DeltaTime) override;
};
```

```cpp
// MyActor.cpp
#include "MyActor.h"

AMyActor::AMyActor()
{
    PrimaryActorTick.bCanEverTick = true;
}

void AMyActor::BeginPlay()
{
    Super::BeginPlay();
}

void AMyActor::Tick(float DeltaTime)
{
    Super::Tick(DeltaTime);
}

void AMyActor::TakeDamage(float Amount)
{
    Health -= Amount;
    if (Health <= 0.0f)
    {
        Destroy();
    }
}
```

### 2.2 Key Macros

| Macro | Purpose |
|-------|---------|
| `UPROPERTY()` | Expose variable to editor/BP |
| `UFUNCTION()` | Expose function to BP |
| `UCLASS()` | Reflect class to Unreal |
| `GENERATED_BODY()` | Required in UCLASS |

---

## Part 3: UE5 Rendering

### 3.1 Nanite

Virtualized geometry for film-quality assets.

- Import high-poly meshes directly.
- No LOD setup needed.
- Streaming from disk.

Enable per mesh: `Mesh Settings → Enable Nanite`.

### 3.2 Lumen

Global illumination and reflections.

- Real-time, dynamic.
- Software + hardware raytracing.

`Project Settings → Rendering → Global Illumination → Lumen`.

### 3.3 Virtual Shadow Maps

High-quality dynamic shadows for Nanite.
Pairs with Lumen automatically.

---

## Part 4: Gameplay Ability System (GAS)

### 4.1 What is GAS?

Framework for abilities, attributes, and effects.

- Used in Fortnite, Paragon.

### 4.2 Core Components

| Component | Purpose |
|-----------|---------|
| **AbilitySystemComponent** | Manages abilities |
| **GameplayAbility** | Single ability logic |
| **GameplayEffect** | Modifier (buff, debuff) |
| **GameplayAttribute** | Stats (Health, Mana) |
| **GameplayTag** | Categorization/filtering |

### 4.3 Example Ability

```cpp
UCLASS()
class UGA_FireBall : public UGameplayAbility
{
    GENERATED_BODY()
    
public:
    virtual void ActivateAbility(...);
    virtual void EndAbility(...);
};
```

---

## Part 5: Multiplayer (Replication)

### 5.1 Key Concepts

| Concept | Description |
|---------|-------------|
| **Replicated** | Variable synced to clients |
| **RPC** | Remote Procedure Call |
| **NetMulticast** | Server → All clients |
| **Server** | Client → Server |
| **Client** | Server → Owning client |

### 5.2 Replicated Property

```cpp
UPROPERTY(Replicated)
float Health;

void GetLifetimeReplicatedProps(TArray<FLifetimeProperty>& OutLifetimeProps) const
{
    DOREPLIFETIME(AMyActor, Health);
}
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use C++ for Core, BP for Polish**: Hybrid workflow.
- ✅ **Validation in PostEditChangeProperty**: Catch editor errors.
- ✅ **Profile with Unreal Insights**: CPU/GPU analysis.

### ❌ Avoid This

- ❌ **Tick on Everything**: Disable tick when not needed.
- ❌ **Blueprint Spaghetti**: Break into BP Functions.
- ❌ **Ignoring Memory**: Use TWeakObjectPtr for non-owning refs.

---

## Related Skills

- `@unity-game-developer-pro` - Unity comparison
- `@game-design-specialist` - Game design
- `@cpp-developer` - Advanced C++
