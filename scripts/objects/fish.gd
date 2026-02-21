extends Area2D

func _ready() -> void:
	GameManager.register_fish()
	set_collision_layer_value(Layers.WORLD, false)
	set_collision_mask_value(Layers.CAT, true)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("cat"):
		GameManager.collect_fish()
		queue_free()

func _draw() -> void:
	# Body
	draw_circle(Vector2(3, 0), 8, Color(1.0, 0.75, 0.0))
	# Tail
	var tail := PackedVector2Array([Vector2(-5, 0), Vector2(-13, -6), Vector2(-13, 6)])
	draw_colored_polygon(tail, Color(1.0, 0.75, 0.0))
	# Eye
	draw_circle(Vector2(8, -2), 2, Color(0.1, 0.1, 0.1))
