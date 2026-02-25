extends "res://scripts/characters/enemy_base.gd"

# Dogs: fast, short range, aggressive chase
func _ready() -> void:
	super._ready()
	move_speed = 140.0
	detection_range = 120.0
	patrol_distance = 100.0

var chase_target: Node = null

const SHADOW_HW: float = 12.0
const SHADOW_HEIGHT: float = 24.0

func _draw_floor_shadow() -> void:
	var floor_y := GameManager.FLOOR_Y
	var light := GameManager.SHADOW_LIGHT
	var shadow_y := floor_y - global_position.y
	var top_world_y := global_position.y + _get_collision_bottom() - _get_collision_height()
	var bottom_world_y := global_position.y + _get_collision_bottom()
	if bottom_world_y >= floor_y:
		bottom_world_y = floor_y - 1.0
	if top_world_y >= floor_y:
		top_world_y = floor_y - 8.0
	var top_t := (floor_y - light.y) / maxf(1.0, top_world_y - light.y)
	var bottom_t := (floor_y - light.y) / maxf(1.0, bottom_world_y - light.y)
	var top_x := light.x + (global_position.x - light.x) * top_t
	var bottom_x := light.x + (global_position.x - light.x) * bottom_t
	var near_x := bottom_x - global_position.x
	var far_x := top_x - global_position.x
	var width_near := SHADOW_HW
	var width_far := SHADOW_HW * 0.35
	var alpha := clampf(0.28 - absf(far_x - near_x) * 0.0015, 0.08, 0.28)
	var pts := PackedVector2Array([
		Vector2(near_x - width_near, shadow_y), Vector2(near_x + width_near, shadow_y),
		Vector2(far_x + width_far, shadow_y + 4), Vector2(far_x - width_far, shadow_y + 4),
	])
	draw_colored_polygon(pts, Color(0.0, 0.0, 0.0, alpha))

func _draw_ellipse_filled(center: Vector2, rx: float, ry: float, color: Color, segments: int = 20) -> void:
	var pts := PackedVector2Array()
	for i in segments:
		var angle := TAU * i / segments
		pts.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	draw_colored_polygon(pts, color)

func _draw_ellipse_border(center: Vector2, rx: float, ry: float, color: Color, width: float = 1.5, segments: int = 20) -> void:
	var pts := PackedVector2Array()
	for i in segments + 1:
		var angle := TAU * i / segments
		pts.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	draw_polyline(pts, color, width)

func _draw() -> void:
	_draw_floor_shadow()
	var foot_y := _get_collision_bottom()
	var facing := -1.0 if $Sprite2D.flip_h else 1.0

	var body_col := Color(0.55, 0.35, 0.15)
	var dark_col := Color(0.35, 0.2, 0.05)
	var belly_col := Color(0.75, 0.55, 0.35)
	var snout_col := Color(0.7, 0.52, 0.35)
	var nose_col := Color(0.1, 0.1, 0.1)
	var eye_white := Color(1.0, 1.0, 0.95)
	var eye_pupil := Color(0.1, 0.1, 0.05)
	var collar_col := Color(0.8, 0.15, 0.15)

	# Tail — short, angled up from back
	var tail_base_x := facing * -14.0
	var tail_tip_x := tail_base_x + facing * -8.0
	var tail_pts := PackedVector2Array([
		Vector2(tail_base_x, foot_y - 18.0),
		Vector2(tail_tip_x, foot_y - 28.0),
		Vector2(tail_tip_x + facing * -2.0, foot_y - 26.0),
		Vector2(tail_base_x + facing * -1.0, foot_y - 15.0),
	])
	draw_colored_polygon(tail_pts, body_col)

	# Back legs
	_draw_ellipse_filled(Vector2(facing * -7.0, foot_y - 3.0), 4.0, 4.5, dark_col)
	_draw_ellipse_filled(Vector2(facing * -7.0, foot_y - 3.0), 3.0, 3.5, body_col)

	# Body — wider horizontal oval (dog shape)
	_draw_ellipse_filled(Vector2(0, foot_y - 13.0), 15.0, 10.0, body_col)
	_draw_ellipse_border(Vector2(0, foot_y - 13.0), 15.0, 10.0, dark_col, 1.5)

	# Belly
	_draw_ellipse_filled(Vector2(facing * 2.0, foot_y - 10.0), 9.0, 5.0, belly_col)

	# Front legs
	_draw_ellipse_filled(Vector2(facing * 8.0, foot_y - 3.0), 4.0, 4.5, dark_col)
	_draw_ellipse_filled(Vector2(facing * 8.0, foot_y - 3.0), 3.0, 3.5, body_col)

	# Collar
	var collar_y := foot_y - 20.0
	draw_line(Vector2(facing * 2.0, collar_y), Vector2(facing * 12.0, collar_y), collar_col, 2.5)

	# Head — round, offset forward
	var head_x := facing * 12.0
	var head_y := foot_y - 22.0
	draw_circle(Vector2(head_x, head_y), 8.0, body_col)
	draw_arc(Vector2(head_x, head_y), 8.0, 0, TAU, 24, dark_col, 1.5)

	# Floppy ear — hangs down from top of head
	var ear_x := head_x + facing * -3.0
	var ear_pts := PackedVector2Array([
		Vector2(ear_x - 3.0, head_y - 6.0),
		Vector2(ear_x - 5.0, head_y + 2.0),
		Vector2(ear_x - 2.0, head_y + 5.0),
		Vector2(ear_x + 1.0, head_y + 1.0),
		Vector2(ear_x + 1.0, head_y - 5.0),
	])
	draw_colored_polygon(ear_pts, dark_col)

	# Snout — protruding oval
	var snout_x := head_x + facing * 7.0
	var snout_y := head_y + 2.0
	_draw_ellipse_filled(Vector2(snout_x, snout_y), 5.0, 3.5, snout_col)
	_draw_ellipse_border(Vector2(snout_x, snout_y), 5.0, 3.5, dark_col, 1.0)

	# Nose
	draw_circle(Vector2(snout_x + facing * 3.0, snout_y - 1.0), 2.0, nose_col)

	# Eye
	var eye_x := head_x + facing * 3.0
	var eye_y := head_y - 2.0
	_draw_ellipse_filled(Vector2(eye_x, eye_y), 3.0, 2.5, eye_white)
	draw_circle(Vector2(eye_x + facing * 0.5, eye_y), 1.5, eye_pupil)

	# Alert / chase indicator
	if state == State.ALERT or state == State.CHASE:
		var bubble_y := foot_y - 40.0
		# Bubble with pointer
		draw_circle(Vector2(0, bubble_y), 10.0, Color(1.0, 1.0, 1.0))
		draw_arc(Vector2(0, bubble_y), 10.0, 0, TAU, 20, Color(0.3, 0.3, 0.3), 1.0)
		var pointer := PackedVector2Array([
			Vector2(-3, bubble_y + 9), Vector2(3, bubble_y + 9), Vector2(0, bubble_y + 15),
		])
		draw_colored_polygon(pointer, Color(1.0, 1.0, 1.0))
		# Exclamation mark
		draw_rect(Rect2(-1.5, bubble_y - 7, 3, 9), Color(0.85, 0.15, 0.15))
		draw_circle(Vector2(0, bubble_y + 5), 1.8, Color(0.85, 0.15, 0.15))

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
