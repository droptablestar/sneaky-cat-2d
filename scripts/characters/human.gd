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

	var skin := Color(0.92, 0.76, 0.6)
	var shirt := Color(0.25, 0.45, 0.75)
	var shirt_dark := Color(0.15, 0.3, 0.55)
	var pants := Color(0.3, 0.3, 0.35)
	var pants_dark := Color(0.2, 0.2, 0.25)
	var shoe := Color(0.25, 0.15, 0.1)
	var hair := Color(0.3, 0.2, 0.1)
	var eye_white := Color(1.0, 1.0, 0.95)
	var eye_pupil := Color(0.15, 0.15, 0.1)
	var outline := Color(0.15, 0.15, 0.2)

	# Legs / pants
	# Back leg
	draw_rect(Rect2(facing * -5.0 - 3.0, foot_y - 12.0, 6.0, 10.0), pants)
	draw_rect(Rect2(facing * -5.0 - 3.0, foot_y - 12.0, 6.0, 10.0), pants_dark, false, 1.0)
	# Front leg
	draw_rect(Rect2(facing * 3.0 - 3.0, foot_y - 12.0, 6.0, 10.0), pants)
	draw_rect(Rect2(facing * 3.0 - 3.0, foot_y - 12.0, 6.0, 10.0), pants_dark, false, 1.0)

	# Shoes
	_draw_ellipse_filled(Vector2(facing * -5.0, foot_y - 1.0), 4.5, 2.5, shoe)
	_draw_ellipse_filled(Vector2(facing * 3.0, foot_y - 1.0), 4.5, 2.5, shoe)

	# Torso — rounded rectangle approximation
	var torso_y := foot_y - 28.0
	_draw_ellipse_filled(Vector2(0, torso_y + 7.0), 10.0, 14.0, shirt)
	_draw_ellipse_border(Vector2(0, torso_y + 7.0), 10.0, 14.0, shirt_dark, 1.5)

	# Arms
	# Back arm
	var arm_back_x := facing * -8.0
	draw_rect(Rect2(arm_back_x - 2.5, foot_y - 26.0, 5.0, 14.0), shirt_dark)
	# Hand
	draw_circle(Vector2(arm_back_x, foot_y - 11.0), 3.0, skin)
	# Front arm
	var arm_front_x := facing * 8.0
	draw_rect(Rect2(arm_front_x - 2.5, foot_y - 26.0, 5.0, 14.0), shirt)
	draw_rect(Rect2(arm_front_x - 2.5, foot_y - 26.0, 5.0, 14.0), shirt_dark, false, 1.0)
	draw_circle(Vector2(arm_front_x, foot_y - 11.0), 3.0, skin)

	# Collar / neckline
	var collar_pts := PackedVector2Array([
		Vector2(-5.0, foot_y - 33.0), Vector2(0, foot_y - 30.0), Vector2(5.0, foot_y - 33.0),
	])
	draw_polyline(collar_pts, shirt_dark, 1.5)

	# Head
	var head_x := facing * 1.0
	var head_y := foot_y - 40.0
	_draw_ellipse_filled(Vector2(head_x, head_y), 8.0, 9.0, skin)
	_draw_ellipse_border(Vector2(head_x, head_y), 8.0, 9.0, outline, 1.2)

	# Hair — cap on top half of head
	var hair_pts := PackedVector2Array()
	hair_pts.append(Vector2(head_x - 9.0, head_y))
	for i in 11:
		var angle := PI + (PI * i / 10.0)
		hair_pts.append(Vector2(head_x + cos(angle) * 9.0, head_y + sin(angle) * 10.0))
	hair_pts.append(Vector2(head_x + 9.0, head_y))
	draw_colored_polygon(hair_pts, hair)

	# Eye
	var eye_x := head_x + facing * 4.0
	var eye_y := head_y + 0.5
	_draw_ellipse_filled(Vector2(eye_x, eye_y), 2.5, 2.0, eye_white)
	draw_circle(Vector2(eye_x + facing * 0.5, eye_y), 1.2, eye_pupil)

	# Mouth — small line
	draw_line(
		Vector2(head_x + facing * 2.0, head_y + 5.0),
		Vector2(head_x + facing * 5.0, head_y + 5.0),
		outline, 1.0
	)

	# Alert / chase indicator
	if state == State.ALERT or state == State.CHASE:
		var bubble_y := foot_y - 58.0
		draw_circle(Vector2(0, bubble_y), 10.0, Color(1.0, 1.0, 1.0))
		draw_arc(Vector2(0, bubble_y), 10.0, 0, TAU, 20, Color(0.3, 0.3, 0.3), 1.0)
		var pointer := PackedVector2Array([
			Vector2(-3, bubble_y + 9), Vector2(3, bubble_y + 9), Vector2(0, bubble_y + 15),
		])
		draw_colored_polygon(pointer, Color(1.0, 1.0, 1.0))
		draw_rect(Rect2(-1.5, bubble_y - 7, 3, 9), Color(0.85, 0.15, 0.15))
		draw_circle(Vector2(0, bubble_y + 5), 1.8, Color(0.85, 0.15, 0.15))

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
