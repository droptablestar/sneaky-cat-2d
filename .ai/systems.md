# Key Systems

## Collision Layers
Always use `Layers.*` constants — never raw integers.
| Layer | Name | Used by |
|-------|------|---------|
| 1 | WORLD | Floor, walls |
| 2 | CAT | Cat CharacterBody2D |
| 3 | ENEMY | Dog, Human CharacterBody2D |
| 4 | PLATFORM | Hide spot platforms (cat can land, enemies pass through) |

## Detection (RayCast2D)
- Each enemy creates a `RayCast2D` in code during `_ready()` (not in .tscn)
- Ray mask: layers CAT + PLATFORM — platforms block the ray, providing natural cover
- Direction updates each frame to match `patrol_direction`
- On hit: checks `is_in_group("cat")` and `hit.get("is_hidden")`

## Hiding
- `HideSpot` (Area2D) fires `body_entered`/`body_exited` → calls `cat.set_hidden(true/false)`
- Cat must be on collision layer 2 for the Area2D to detect it
- Dog chase checks `chase_target.get("is_hidden")` — use `.get()` not direct property access

## Cat Group Membership
- Cat is added to group `"cat"` in `cat.gd _ready()` via `add_to_group("cat")`
- Do NOT rely on `groups = ["cat"]` in the .tscn — Godot doesn't parse it correctly

## GameManager Signals
```
fish_updated(current: int, total: int)  # emitted on each fish collection
player_caught                            # emitted when dog catches cat
level_won                                # emitted when exit reached with all fish
```

## Input Actions (defined in code by GameManager)
| Action | Keys |
|--------|------|
| `move_left` | Left arrow, A |
| `move_right` | Right arrow, D |
| `jump` | Space, Up arrow, W |
