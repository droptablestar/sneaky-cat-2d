extends Node2D

const SHADOW_HW: float = 10.0

var _host: CharacterBody2D
var _sprite: Sprite2D
var _collision_shape: CollisionShape2D


func _ready() -> void:
	_host = get_parent() as CharacterBody2D
	_sprite = _host.get_node("Sprite2D") as Sprite2D
	_collision_shape = _host.get_node("CollisionShape2D") as CollisionShape2D
	set_process(true)


func _process(_delta: float) -> void:
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


func _draw_ellipse_filled(
	center: Vector2, rx: float, ry: float, color: Color, segments: int = 20
) -> void:
	var pts := PackedVector2Array()
	for i in segments:
		var angle := TAU * i / segments
		pts.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	draw_colored_polygon(pts, color)


func _draw_ellipse_border(
	center: Vector2, rx: float, ry: float, color: Color, width: float = 1.5, segments: int = 20
) -> void:
	var pts := PackedVector2Array()
	for i in segments + 1:
		var angle := TAU * i / segments
		pts.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	draw_polyline(pts, color, width)


func _draw() -> void:
	var top_world_y := _host.global_position.y + _get_collision_bottom() - _get_collision_height()
	var bottom_world_y := _host.global_position.y + _get_collision_bottom()
	ShadowDraw.draw_floor_shadow(
		self, _host.global_position, top_world_y, bottom_world_y, SHADOW_HW
	)

	var t := VisualMotion.time_seconds()
	var max_speed := float(_host.get("speed"))
	var speed01 := VisualMotion.speed_ratio(absf(_host.velocity.x), max_speed)
	var bob_y := VisualMotion.idle_bob(t, 0.5 + (1.0 - speed01) * 0.25, 1.6)
	var run_swing := VisualMotion.run_swing(t, speed01, 1.8, 8.0)
	var tail_sway := VisualMotion.run_swing(t, 0.5 + speed01 * 0.5, 2.5, 3.5)

	var foot_y := _get_collision_bottom() + bob_y
	var alpha: float = 0.3 if bool(_host.get("is_hidden")) else 1.0
	var facing := -1.0 if _sprite.flip_h else 1.0

	var body_col := Color(1.0, 0.55, 0.0, alpha)
	var dark_col := Color(0.65, 0.3, 0.0, alpha)
	var belly_col := Color(1.0, 0.82, 0.55, alpha)
	var pink := Color(1.0, 0.55, 0.65, alpha)
	var eye_white := Color(1.0, 1.0, 0.95, alpha)
	var eye_iris := Color(0.3, 0.7, 0.2, alpha)
	var eye_pupil := Color(0.1, 0.1, 0.05, alpha)
	var whisker_col := Color(0.95, 0.95, 0.9, alpha)

	var tail_base_x := facing * -12.0
	var tail_pts := PackedVector2Array()
	for i in 9:
		var phase_t := i / 8.0
		var tx := tail_base_x + facing * -phase_t * 14.0
		var ty := foot_y - 14.0 - phase_t * 16.0 - sin(phase_t * PI) * (8.0 + tail_sway * 0.2)
		tail_pts.append(Vector2(tx, ty))
	for i in range(8, -1, -1):
		var phase_t := i / 8.0
		var tx := tail_base_x + facing * -phase_t * 14.0 + facing * -2.0
		var ty := foot_y - 12.0 - phase_t * 16.0 - sin(phase_t * PI) * (8.0 + tail_sway * 0.2)
		tail_pts.append(Vector2(tx, ty))
	draw_colored_polygon(tail_pts, body_col)

	_draw_ellipse_filled(Vector2(facing * -5.0, foot_y - 3.0 - run_swing), 4.0, 4.0, dark_col)
	_draw_ellipse_filled(Vector2(facing * -5.0, foot_y - 3.0 - run_swing), 3.0, 3.0, body_col)
	_draw_ellipse_filled(Vector2(0, foot_y - 14.0), 13.0, 10.0, body_col)
	_draw_ellipse_border(Vector2(0, foot_y - 14.0), 13.0, 10.0, dark_col, 1.5)
	_draw_ellipse_filled(Vector2(facing * 1.0, foot_y - 11.0), 8.0, 5.0, belly_col)
	_draw_ellipse_filled(Vector2(facing * 7.0, foot_y - 3.0 + run_swing), 4.0, 4.0, dark_col)
	_draw_ellipse_filled(Vector2(facing * 7.0, foot_y - 3.0 + run_swing), 3.0, 3.0, body_col)

	var head_x := facing * 6.0
	var head_y := foot_y - 27.0
	draw_circle(Vector2(head_x, head_y), 9.0, body_col)
	draw_arc(Vector2(head_x, head_y), 9.0, 0, TAU, 24, dark_col, 1.5)

	var ear_l_x := head_x + facing * -5.0
	var ear_r_x := head_x + facing * 5.0
	var ear_top_y := head_y - 14.0 + tail_sway * 0.2
	var ear_base_y := head_y - 5.0
	var ear_l := PackedVector2Array(
		[
			Vector2(ear_l_x - 4.0, ear_base_y),
			Vector2(ear_l_x, ear_top_y),
			Vector2(ear_l_x + 4.0, ear_base_y),
		]
	)
	draw_colored_polygon(ear_l, body_col)
	draw_polyline(ear_l, dark_col, 1.5)
	var ear_li := PackedVector2Array(
		[
			Vector2(ear_l_x - 2.0, ear_base_y + 1.0),
			Vector2(ear_l_x, ear_top_y + 3.0),
			Vector2(ear_l_x + 2.0, ear_base_y + 1.0),
		]
	)
	draw_colored_polygon(ear_li, pink)

	var ear_r := PackedVector2Array(
		[
			Vector2(ear_r_x - 4.0, ear_base_y),
			Vector2(ear_r_x, ear_top_y),
			Vector2(ear_r_x + 4.0, ear_base_y),
		]
	)
	draw_colored_polygon(ear_r, body_col)
	draw_polyline(ear_r, dark_col, 1.5)
	var ear_ri := PackedVector2Array(
		[
			Vector2(ear_r_x - 2.0, ear_base_y + 1.0),
			Vector2(ear_r_x, ear_top_y + 3.0),
			Vector2(ear_r_x + 2.0, ear_base_y + 1.0),
		]
	)
	draw_colored_polygon(ear_ri, pink)

	var eye_x := head_x + facing * 4.0
	var eye_y := head_y - 1.0
	_draw_ellipse_filled(Vector2(eye_x, eye_y), 3.5, 3.0, eye_white)
	draw_circle(Vector2(eye_x + facing * 0.8, eye_y), 2.0, eye_iris)
	draw_circle(Vector2(eye_x + facing * 1.2, eye_y), 1.0, eye_pupil)

	var nose_x := head_x + facing * 8.0
	var nose_y := head_y + 2.0
	var nose_pts := PackedVector2Array(
		[
			Vector2(nose_x, nose_y - 1.5),
			Vector2(nose_x - 2.0, nose_y + 1.5),
			Vector2(nose_x + 2.0, nose_y + 1.5),
		]
	)
	draw_colored_polygon(nose_pts, pink)

	var whisker_x := head_x + facing * 7.0
	var whisker_y := head_y + 3.0
	draw_line(
		Vector2(whisker_x, whisker_y),
		Vector2(whisker_x + facing * 12.0, whisker_y - 3.0),
		whisker_col,
		0.8
	)
	draw_line(
		Vector2(whisker_x, whisker_y + 1.0),
		Vector2(whisker_x + facing * 13.0, whisker_y + 1.0),
		whisker_col,
		0.8
	)
	draw_line(
		Vector2(whisker_x, whisker_y + 2.0),
		Vector2(whisker_x + facing * 12.0, whisker_y + 5.0),
		whisker_col,
		0.8
	)
