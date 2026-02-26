extends Area2D


func _ready() -> void:
	z_as_relative = false
	z_index = int(global_position.y)
	GameManager.register_fish()
	set_collision_layer_value(Layers.WORLD, false)
	set_collision_mask_value(Layers.CAT, true)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("cat"):
		GameManager.collect_fish()
		queue_free()
