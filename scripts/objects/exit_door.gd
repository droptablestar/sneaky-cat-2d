extends Area2D

var _is_open: bool = false

@onready var _visuals: Node2D = $Visuals


func _ready() -> void:
	z_as_relative = false
	z_index = int(global_position.y)
	set_collision_layer_value(Layers.WORLD, false)
	set_collision_mask_value(Layers.CAT, true)
	body_entered.connect(_on_body_entered)
	GameManager.fish_updated.connect(_on_fish_updated)


func _on_fish_updated(current: int, total: int) -> void:
	_is_open = total > 0 and current >= total
	_visuals.queue_redraw()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("cat"):
		GameManager.try_complete_level()


func is_open() -> bool:
	return _is_open
