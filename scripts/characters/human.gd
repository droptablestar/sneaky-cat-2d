extends "res://scripts/characters/enemy_base.gd"

# Humans: slower, wider vision range, stop and look around when alerted
func _ready() -> void:
	super._ready()
	move_speed = 60.0
	detection_range = 260.0
	patrol_distance = 150.0

var alert_timer: float = 0.0
const ALERT_DURATION = 2.0

var chase_target: Node = null

func _draw() -> void:
	# body
	draw_rect(Rect2(-10, -28, 20, 20), Color(0.3, 0.5, 0.8))
	# head
	draw_rect(Rect2(-8, -40, 16, 14), Color(0.9, 0.75, 0.6))

func _on_detect(target: Node) -> void:
	chase_target = target
	alert_timer = ALERT_DURATION
	super._on_detect(target)

func _on_alert() -> void:
	# Humans pause and look around before giving chase
	velocity.x = 0
	alert_timer -= get_physics_process_delta_time()
	if alert_timer <= 0:
		state = State.CHASE

func _chase(_delta: float) -> void:
	if chase_target == null:
		state = State.PATROL
		return

	if chase_target.is_hidden:
		state = State.PATROL
		chase_target = null
		return

	var dir = sign(chase_target.global_position.x - global_position.x)
	velocity.x = move_speed * dir
	$Sprite2D.flip_h = dir < 0
