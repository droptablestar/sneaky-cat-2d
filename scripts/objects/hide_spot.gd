extends Area2D

# If true, the Platform child body is active so the cat can jump on it.
@export var is_platform: bool = false

@onready var platform: StaticBody2D = $Platform

func _ready() -> void:
	set_collision_mask_value(Layers.CAT, true)
	platform.set_collision_layer_value(Layers.WORLD, false)
	platform.set_collision_layer_value(Layers.PLATFORM, is_platform)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _draw() -> void:
	# hide zone outline
	draw_rect(Rect2(-40, -24, 80, 48), Color(0.2, 0.7, 0.2, 0.15))
	draw_rect(Rect2(-40, -24, 80, 48), Color(0.2, 0.7, 0.2, 0.6), false, 1.0)
	if is_platform:
		# shelf surface
		draw_rect(Rect2(-32, -30, 64, 8), Color(0.5, 0.35, 0.15))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("cat"):
		body.set_hidden(true)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("cat"):
		body.set_hidden(false)
