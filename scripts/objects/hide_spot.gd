extends Area2D

# If true, this hide spot is also a platform the cat can jump on.
# The collision shape on the StaticBody2D sibling handles the platform physics.
@export var is_platform: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("cat"):
		body.set_hidden(true)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("cat"):
		body.set_hidden(false)
