extends Area2D

# If true, the Platform child body is active so the cat can jump on it.
@export var is_platform: bool = false

@onready var platform: StaticBody2D = $Platform

func _ready() -> void:
	# Enable or disable the physical platform based on the export flag
	platform.set_collision_layer_value(1, is_platform)
	platform.set_collision_mask_value(1, is_platform)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("cat"):
		body.set_hidden(true)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("cat"):
		body.set_hidden(false)
