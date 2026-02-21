# Architecture

## Tech Stack
- Engine: Godot 4.6 (GDScript)
- Target platform: Web (HTML5 export)
- Window size: 1152x400
- No external packages or plugins
- Placeholder visuals drawn with `_draw()` — no sprite assets yet
- Scenes hand-authored as `.tscn` text files (avoid the Godot editor where possible)

## Autoloads (global singletons)
| Name | Path | Purpose |
|------|------|---------|
| `Layers` | `scripts/core/layers.gd` | Collision layer constants (WORLD=1, CAT=2, ENEMY=3, PLATFORM=4) |
| `GameManager` | `scripts/game_manager.gd` | Fish tracking, caught/win state, scene reload, input setup, fullscreen toggle |

## Scene Structure
```
scenes/
  main.tscn               # Entry point, no script (GameManager is autoload)
  levels/
    level_01.tscn         # Floor, cat, dog, hide spots, fish, exit door, HUD
  characters/
    cat.tscn              # Player (CharacterBody2D)
    dog.tscn              # Enemy (CharacterBody2D)
    human.tscn            # Enemy (CharacterBody2D) — scripted, not in level yet
  objects/
    hide_spot.tscn        # Area2D hide zone + optional StaticBody2D platform
    fish.tscn             # Collectible (Area2D)
    exit_door.tscn        # Level exit (Area2D)
  ui/
    hud.tscn              # CanvasLayer: fish counter, flash overlay, messages
```

## Script Structure
```
scripts/
  core/
    layers.gd             # Collision layer constants
  game_manager.gd         # Autoload: game state, input actions, fullscreen
  characters/
    cat.gd                # Player: movement, jump, state machine, hiding
    enemy_base.gd         # Shared enemy: patrol, raycast detection, state machine
    dog.gd                # Extends enemy_base: fast, short range, catch zone
    human.gd              # Extends enemy_base: slow, wide range, alert pause
  objects/
    hide_spot.gd          # Toggles cat is_hidden, optional platform
    fish.gd               # Registers with GameManager, collected on touch
    exit_door.gd          # Opens when all fish collected, triggers win
    floor.gd              # Draws the floor rectangle (placeholder visual)
  ui/
    hud.gd                # Connects to GameManager signals, updates UI
```
