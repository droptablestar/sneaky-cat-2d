extends Area2D

var _is_open: bool = false

func _ready() -> void:
	set_collision_layer_value(Layers.WORLD, false)
	set_collision_mask_value(Layers.CAT, true)
	body_entered.connect(_on_body_entered)
	GameManager.fish_updated.connect(_on_fish_updated)

func _on_fish_updated(current: int, total: int) -> void:
	_is_open = total > 0 and current >= total
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("cat"):
		GameManager.try_complete_level()

func _draw() -> void:
	var door_color := Color(0.4, 0.25, 0.1) if not _is_open else Color(0.15, 0.6, 0.15)
	var trim_color := Color(0.6, 0.4, 0.15) if not _is_open else Color(0.3, 1.0, 0.3)
	# Door
	draw_rect(Rect2(-16, -52, 32, 52), door_color)
	draw_rect(Rect2(-16, -52, 32, 52), trim_color, false, 2.0)
	# Knob
	draw_circle(Vector2(8, -22), 3, Color(0.9, 0.75, 0.1))
	# Lock indicator
	if not _is_open:
		draw_rect(Rect2(-5, -30, 10, 8), Color(0.8, 0.2, 0.2))
