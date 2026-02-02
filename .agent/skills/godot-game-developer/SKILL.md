---
name: godot-game-developer
description: "Expert Godot Engine development including GDScript, C#, nodes, signals, and open-source game architecture"
---

# Godot Game Developer

## Overview

This skill transforms you into a **Godot Engine Expert**. You will master **GDScript**, **Node-Based Architecture**, **Signals**, and **Best Practices** for building games with the open-source Godot engine.

## When to Use This Skill

- Use when building 2D or 3D games with Godot
- Use when designing node-based scene architecture
- Use when writing GDScript or C# for Godot
- Use when implementing signals and event-driven design
- Use when exporting to multiple platforms

---

## Part 1: Godot Fundamentals

### 1.1 Core Concepts

| Concept | Description |
|---------|-------------|
| **Node** | Building block of scenes (Sprite2D, CharacterBody2D) |
| **Scene** | Reusable tree of nodes (.tscn file) |
| **Signal** | Event emitted by node (button_pressed, body_entered) |
| **Script** | Code attached to a node (GDScript, C#) |
| **Autoload** | Singleton scene/script (GameManager, SaveSystem) |

### 1.2 Node Types

| Node | Use Case |
|------|----------|
| **Node2D** | Base for 2D scenes |
| **Sprite2D** | Display images |
| **CharacterBody2D** | Player/enemy movement |
| **Area2D** | Collision detection without physics |
| **TileMap** | Level design with tiles |
| **Control** | UI elements |
| **AnimationPlayer** | Keyframe animations |

---

## Part 2: GDScript Patterns

### 2.1 Basic Script

```gdscript
extends CharacterBody2D

@export var speed: float = 300.0

func _physics_process(delta: float) -> void:
    var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = direction * speed
    move_and_slide()
```

### 2.2 Exports and Groups

```gdscript
@export_group("Movement")
@export var speed: float = 300.0
@export var jump_force: float = 500.0

@export_group("Combat")
@export var health: int = 100
@export var damage: int = 25
```

### 2.3 Static Typing

```gdscript
var enemies: Array[Enemy] = []
var player: Player = null

func take_damage(amount: int) -> void:
    health -= amount
```

---

## Part 3: Signals

### 3.1 Built-in Signals

```gdscript
func _ready() -> void:
    $Button.pressed.connect(_on_button_pressed)
    $Area2D.body_entered.connect(_on_body_entered)

func _on_button_pressed() -> void:
    print("Button pressed!")

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player"):
        print("Player entered!")
```

### 3.2 Custom Signals

```gdscript
signal health_changed(new_health: int)
signal died

func take_damage(amount: int) -> void:
    health -= amount
    health_changed.emit(health)
    
    if health <= 0:
        died.emit()
```

### 3.3 Signal Connection Patterns

```gdscript
# In receiving node
func _ready() -> void:
    var player := $Player
    player.health_changed.connect(_on_player_health_changed)

func _on_player_health_changed(new_health: int) -> void:
    health_bar.value = new_health
```

---

## Part 4: Scene Architecture

### 4.1 Composition Over Inheritance

Create reusable scenes, instantiate them.

```
Player.tscn
├── CharacterBody2D
│   ├── Sprite2D
│   ├── CollisionShape2D
│   ├── HealthComponent.tscn  ← Reusable
│   └── HitboxComponent.tscn  ← Reusable
```

### 4.2 Autoloads (Singletons)

Project Settings → Autoload → Add script/scene.

```gdscript
# GameManager.gd (autoload)
extends Node

var score: int = 0
var current_level: int = 1

signal score_changed(new_score: int)

func add_score(points: int) -> void:
    score += points
    score_changed.emit(score)
```

Access from anywhere: `GameManager.add_score(100)`

---

## Part 5: Common Systems

### 5.1 Save/Load (JSON)

```gdscript
const SAVE_PATH := "user://savegame.json"

func save_game() -> void:
    var data := {
        "score": GameManager.score,
        "level": GameManager.current_level,
    }
    var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
    file.store_string(JSON.stringify(data))

func load_game() -> void:
    if not FileAccess.file_exists(SAVE_PATH):
        return
    
    var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
    var data := JSON.parse_string(file.get_as_text())
    GameManager.score = data.score
    GameManager.current_level = data.level
```

### 5.2 Object Pooling

```gdscript
var bullet_pool: Array[Bullet] = []

func get_bullet() -> Bullet:
    for bullet in bullet_pool:
        if not bullet.active:
            bullet.activate()
            return bullet
    
    var new_bullet := bullet_scene.instantiate()
    bullet_pool.append(new_bullet)
    add_child(new_bullet)
    return new_bullet
```

---

## Part 6: Best Practices Checklist

### ✅ Do This

- ✅ **Use Signals for Decoupling**: Nodes shouldn't know about each other directly.
- ✅ **Static Typing**: Catch errors at compile time.
- ✅ **Scene Composition**: Small, reusable scenes.

### ❌ Avoid This

- ❌ **get_node() with Long Paths**: Use signals or @onready.
- ❌ **Putting All Logic in One Script**: Break into components.
- ❌ **Ignoring _physics_process for Movement**: Use for physics, not _process.

---

## Related Skills

- `@game-design-specialist` - Game design principles
- `@unity-game-developer` - Unity comparison
- `@roblox-developer-pro` - Roblox alternative
