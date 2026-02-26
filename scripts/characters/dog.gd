extends "res://scripts/characters/enemy_base.gd"

var chase_target: Node = null


func _ready() -> void:
	super._ready()
	move_speed = 140.0
	detection_range = 120.0
	patrol_distance = 100.0


func _on_detect(target: Node) -> void:
	chase_target = target
	super._on_detect(target)


func _chase(_delta: float) -> void:
	if chase_target == null:
		state = State.PATROL
		return

	if chase_target.get("is_hidden"):
		state = State.PATROL
		chase_target = null
		return

	var dir = sign(chase_target.global_position.x - global_position.x)
	velocity.x = move_speed * dir
	$Sprite2D.flip_h = dir < 0
