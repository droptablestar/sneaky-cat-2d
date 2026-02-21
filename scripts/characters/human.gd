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

const SHADOW_HW: float = 8.0
const SHADOW_HEIGHT: float = 40.0

func _draw_floor_shadow() -> void:
	for lp: Vector2 in GameManager.LIGHT_POSITIONS:
		var dx: float = global_position.x - lp.x
		var dy: float = lp.y - global_position.y
		var slen: float = clampf(dx * SHADOW_HEIGHT / maxf(abs(dy), 80.0), -22.0, 22.0)
		var alpha: float = clampf(0.16 - absf(slen) * 0.003, 0.04, 0.16)
		var pts := PackedVector2Array([
			Vector2(-SHADOW_HW, 0), Vector2(SHADOW_HW, 0),
			Vector2(slen + SHADOW_HW * 0.5, 4), Vector2(slen - SHADOW_HW * 0.5, 4),
		])
		draw_colored_polygon(pts, Color(0.0, 0.0, 0.0, alpha))

func _draw() -> void:
	_draw_floor_shadow()
	# body
	draw_rect(Rect2(-10, -28, 20, 20), Color(0.3, 0.5, 0.8))
	# head
	draw_rect(Rect2(-8, -40, 16, 14), Color(0.9, 0.75, 0.6))

	if state == State.ALERT or state == State.CHASE:
		# bubble background
		draw_circle(Vector2(0, -54), 12, Color(1.0, 1.0, 1.0))
		# ! body
		draw_rect(Rect2(-2.5, -63, 5, 12), Color(0.1, 0.1, 0.1))
		# ! dot
		draw_rect(Rect2(-2.5, -48, 5, 5), Color(0.1, 0.1, 0.1))

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

	if chase_target.get("is_hidden"):
		state = State.PATROL
		chase_target = null
		return

	var dir = sign(chase_target.global_position.x - global_position.x)
	velocity.x = move_speed * dir
	$Sprite2D.flip_h = dir < 0
