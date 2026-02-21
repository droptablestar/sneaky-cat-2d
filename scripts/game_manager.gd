extends Node

signal fish_updated(current: int, total: int)
signal player_caught
signal level_won

# Window light positions — used by objects to project floor shadows
const LIGHT_POSITIONS: Array[Vector2] = [Vector2(220.0, 115.0), Vector2(920.0, 115.0)]

var fish_collected: int = 0
var fish_total: int = 0
var _game_active: bool = true

func _ready() -> void:
	_setup_input_actions()

func register_fish() -> void:
	fish_total += 1

func collect_fish() -> void:
	if not _game_active:
		return
	fish_collected += 1
	fish_updated.emit(fish_collected, fish_total)

func catch_player() -> void:
	if not _game_active:
		return
	_game_active = false
	player_caught.emit()
	await get_tree().create_timer(1.5).timeout
	_reset()

func try_complete_level() -> void:
	if not _game_active or fish_collected < fish_total:
		return
	_game_active = false
	level_won.emit()
	await get_tree().create_timer(2.0).timeout
	_reset()

func _reset() -> void:
	fish_collected = 0
	fish_total = 0
	_game_active = true
	get_tree().reload_current_scene()

func _setup_input_actions() -> void:
	_add_action("move_left",  [KEY_LEFT,  KEY_A])
	_add_action("move_right", [KEY_RIGHT, KEY_D])
	_add_action("jump",       [KEY_SPACE, KEY_UP, KEY_W])

func _add_action(action: String, keys: Array) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	for keycode in keys:
		var event := InputEventKey.new()
		event.physical_keycode = keycode
		InputMap.action_add_event(action, event)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F11:
			_toggle_fullscreen()

func _toggle_fullscreen() -> void:
	var mode = DisplayServer.window_get_mode()
	if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
