extends CharacterBody2D

enum State { IDLE, RUNNING, JUMPING, HIDING }

@export var speed: float = 180.0
@export var jump_velocity: float = -460.0
@export var gravity: float = 900.0

var state: State = State.IDLE
var is_hidden: bool = false

var _collision_shape: CollisionShape2D

const SHADOW_HW: float = 10.0
const SHADOW_HEIGHT: float = 36.0

func _ready() -> void:
	add_to_group("cat")
	_collision_shape = $CollisionShape2D
	z_as_relative = false
	set_collision_layer_value(Layers.WORLD, false)
	set_collision_layer_value(Layers.CAT, true)
	set_collision_mask_value(Layers.WORLD, true)
	set_collision_mask_value(Layers.PLATFORM, true)

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement()
	move_and_slide()
	_update_state()
	z_index = int(global_position.y)
	queue_redraw()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func _handle_movement() -> void:
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = direction * speed
		$Sprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

func _update_state() -> void:
	if is_hidden:
		state = State.HIDING
	elif not is_on_floor():
		state = State.JUMPING
	elif abs(velocity.x) > 0:
		state = State.RUNNING
	else:
		state = State.IDLE

func set_hidden(value: bool) -> void:
	is_hidden = value
	queue_redraw()

func _get_collision_bottom() -> float:
	if _collision_shape == null or _collision_shape.shape == null:
		return 0.0
	var shape := _collision_shape.shape
	var offset_y := _collision_shape.position.y
	if shape is CapsuleShape2D:
		return offset_y + (shape.height * 0.5) + shape.radius
	if shape is RectangleShape2D:
		return offset_y + shape.size.y * 0.5
	if shape is CircleShape2D:
		return offset_y + shape.radius
	return offset_y

func _get_collision_height() -> float:
	if _collision_shape == null or _collision_shape.shape == null:
		return 0.0
	var shape := _collision_shape.shape
	if shape is CapsuleShape2D:
		return shape.height + shape.radius * 2.0
	if shape is RectangleShape2D:
		return shape.size.y
	if shape is CircleShape2D:
		return shape.radius * 2.0
	return 0.0

func _get_height_above_floor() -> float:
	return maxf(0.0, GameManager.FLOOR_Y - (global_position.y + _get_collision_bottom()))

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
	var a := 0.3 if is_hidden else 1.0
	var facing := -1.0 if $Sprite2D.flip_h else 1.0

	# Colors
	var body_col := Color(1.0, 0.55, 0.0, a)
	var dark_col := Color(0.65, 0.3, 0.0, a)
	var belly_col := Color(1.0, 0.82, 0.55, a)
	var pink := Color(1.0, 0.55, 0.65, a)
	var eye_white := Color(1.0, 1.0, 0.95, a)
	var eye_iris := Color(0.3, 0.7, 0.2, a)
	var eye_pupil := Color(0.1, 0.1, 0.05, a)
	var whisker_col := Color(0.95, 0.95, 0.9, a)

	# Tail — curves up from the back
	var tail_base_x := facing * -12.0
	var tail_pts := PackedVector2Array()
	for i in 9:
		var t := i / 8.0
		var tx := tail_base_x + facing * -t * 14.0
		var ty := foot_y - 14.0 - t * 16.0 - sin(t * PI) * 8.0
		tail_pts.append(Vector2(tx, ty))
	for i in range(8, -1, -1):
		var t := i / 8.0
		var tx := tail_base_x + facing * -t * 14.0 + facing * -2.0
		var ty := foot_y - 12.0 - t * 16.0 - sin(t * PI) * 8.0
		tail_pts.append(Vector2(tx, ty))
	draw_colored_polygon(tail_pts, body_col)

	# Back legs
	_draw_ellipse_filled(Vector2(facing * -5.0, foot_y - 3.0), 4.0, 4.0, dark_col)
	_draw_ellipse_filled(Vector2(facing * -5.0, foot_y - 3.0), 3.0, 3.0, body_col)

	# Body — oval
	_draw_ellipse_filled(Vector2(0, foot_y - 14.0), 13.0, 10.0, body_col)
	_draw_ellipse_border(Vector2(0, foot_y - 14.0), 13.0, 10.0, dark_col, 1.5)

	# Belly highlight
	_draw_ellipse_filled(Vector2(facing * 1.0, foot_y - 11.0), 8.0, 5.0, belly_col)

	# Front legs
	_draw_ellipse_filled(Vector2(facing * 7.0, foot_y - 3.0), 4.0, 4.0, dark_col)
	_draw_ellipse_filled(Vector2(facing * 7.0, foot_y - 3.0), 3.0, 3.0, body_col)

	# Head
	var head_x := facing * 6.0
	var head_y := foot_y - 27.0
	draw_circle(Vector2(head_x, head_y), 9.0, body_col)
	draw_arc(Vector2(head_x, head_y), 9.0, 0, TAU, 24, dark_col, 1.5)

	# Ears — pointed triangles
	var ear_l_x := head_x + facing * -5.0
	var ear_r_x := head_x + facing * 5.0
	var ear_top_y := head_y - 14.0
	var ear_base_y := head_y - 5.0
	# Left ear
	var ear_l := PackedVector2Array([
		Vector2(ear_l_x - 4.0, ear_base_y),
		Vector2(ear_l_x, ear_top_y),
		Vector2(ear_l_x + 4.0, ear_base_y),
	])
	draw_colored_polygon(ear_l, body_col)
	draw_polyline(ear_l, dark_col, 1.5)
	# Left inner ear
	var ear_li := PackedVector2Array([
		Vector2(ear_l_x - 2.0, ear_base_y + 1.0),
		Vector2(ear_l_x, ear_top_y + 3.0),
		Vector2(ear_l_x + 2.0, ear_base_y + 1.0),
	])
	draw_colored_polygon(ear_li, pink)
	# Right ear
	var ear_r := PackedVector2Array([
		Vector2(ear_r_x - 4.0, ear_base_y),
		Vector2(ear_r_x, ear_top_y),
		Vector2(ear_r_x + 4.0, ear_base_y),
	])
	draw_colored_polygon(ear_r, body_col)
	draw_polyline(ear_r, dark_col, 1.5)
	# Right inner ear
	var ear_ri := PackedVector2Array([
		Vector2(ear_r_x - 2.0, ear_base_y + 1.0),
		Vector2(ear_r_x, ear_top_y + 3.0),
		Vector2(ear_r_x + 2.0, ear_base_y + 1.0),
	])
	draw_colored_polygon(ear_ri, pink)

	# Eye
	var eye_x := head_x + facing * 4.0
	var eye_y := head_y - 1.0
	_draw_ellipse_filled(Vector2(eye_x, eye_y), 3.5, 3.0, eye_white)
	draw_circle(Vector2(eye_x + facing * 0.8, eye_y), 2.0, eye_iris)
	draw_circle(Vector2(eye_x + facing * 1.2, eye_y), 1.0, eye_pupil)

	# Nose
	var nose_x := head_x + facing * 8.0
	var nose_y := head_y + 2.0
	var nose_pts := PackedVector2Array([
		Vector2(nose_x, nose_y - 1.5),
		Vector2(nose_x - 2.0, nose_y + 1.5),
		Vector2(nose_x + 2.0, nose_y + 1.5),
	])
	draw_colored_polygon(nose_pts, pink)

	# Whiskers
	var w_x := head_x + facing * 7.0
	var w_y := head_y + 3.0
	draw_line(Vector2(w_x, w_y), Vector2(w_x + facing * 12.0, w_y - 3.0), whisker_col, 0.8)
	draw_line(Vector2(w_x, w_y + 1.0), Vector2(w_x + facing * 13.0, w_y + 1.0), whisker_col, 0.8)
	draw_line(Vector2(w_x, w_y + 2.0), Vector2(w_x + facing * 12.0, w_y + 5.0), whisker_col, 0.8)
