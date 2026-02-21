# Conventions

## Code Style
- Use `Layers.*` constants for all collision layer references — never raw integers
- Use `.get("property")` when accessing script properties on untyped Node references
- Create nodes in `_ready()` rather than relying on `@onready` across inherited scripts
- Write scene structure as `.tscn` text files rather than using the Godot editor
- Prefer editing existing files over creating new ones

## Communication
- Keep responses concise
- No emojis
