# Known Gotchas

- `@onready` across inherited scripts is unreliable — create nodes in `_ready()` instead
- Accessing script properties on untyped objects: use `.get("property")` not `.property`
- `class_name` alone doesn't make a script globally available — register as autoload in project.godot
- After adding a new autoload to project.godot, Godot needs a full project reload
- `groups = [...]` in hand-written .tscn files is not parsed — set groups in `_ready()`
