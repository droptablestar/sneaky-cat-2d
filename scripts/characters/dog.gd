extends "res://scripts/characters/enemy_base.gd"

# Dogs: fast, short range, aggressive chase
func _ready() -> void:
	super._ready()
	move_speed = 140.0
	detection_range = 120.0
	patrol_distance = 100.0

var chase_target: Node = null

func _draw() -> void:
	draw_rect(Rect2(-14, -24, 28, 24), Color(0.6, 0.4, 0.2))
	# snout
	draw_rect(Rect2(10, -14, 10, 8), Color(0.7, 0.5, 0.3))

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
