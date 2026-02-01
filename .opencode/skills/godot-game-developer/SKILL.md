---
name: godot-game-developer
description: "Expert Godot Engine development including GDScript, C#, nodes, signals, and open-source game architecture"
---

# Godot Game Developer

## Overview

Master open-source game development with Godot. Leverage GDScript and C#, node-based scene architecture, powerful signal systems, and lightweight 2D/3D workflows.

## When to Use This Skill

- Use when building lightweight or open-source games
- Use when needing a fast, non-proprietary engine
- Use for both 2D and 3D game projects
- Use when prototyping ideas quickly with GDScript

## How It Works

### Step 1: Nodes & Scene Tree

```gdscript
# Player.gd
extends CharacterBody2D

@export var speed = 400

func _physics_process(delta):
    var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = direction * speed
    move_and_slide()
```

### Step 2: Signals & Communication

```gdscript
# Enemy.gd
signal health_depleted(final_score: int)

func die():
    health_depleted.emit(100)
    queue_free()

# Main.gd (Connecting signals)
func _ready():
    $Enemy.health_depleted.connect(_on_enemy_death)

func _on_enemy_death(score):
    total_score += score
```

### Step 3: C# Integration (GDExtension)

```csharp
using Godot;
using System;

public partial class MyNode : Node
{
    [Export]
    public int MyValue { get; set; } = 10;

    public override void _Process(double delta)
    {
        GD.Print($"Current value: {MyValue}");
    }
}
```

### Step 4: Resource Management

- **Resources**: Encapsulate data in `.tres` files (e.g., Stats, Item Definitions).
- **AutoLoads**: Use for global state managers (Singletons).
- **Tweens**: Use for simple animations via code.

## Best Practices

### ✅ Do This

- ✅ Compose complex scenes from smaller, reusable scenes
- ✅ Use `_physics_process` for movement, `_process` for UI/visuals
- ✅ Leverage signals for decoupled communication
- ✅ Use `@export` to expose variables to the editor
- ✅ Use "Groups" for broad actor categorization

### ❌ Avoid This

- ❌ Don't use `get_parent()` or `get_node()` with hardcoded paths (use `@onready` or Exports)
- ❌ Don't block the main thread with heavy computations
- ❌ Don't ignore the built-in "Input Map" system
- ❌ Don't skip "Type Hints" in GDScript for better IDE support

## Related Skills

- `@unity-game-developer` - Comparison of architectures
- `@python-automation-specialist` - GDScript syntax similarity
- `@senior-software-architect` - Game engine design
