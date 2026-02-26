extends Node2D

const SHADOW_HW: float = 12.0

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
	var max_speed := float(_host.get("move_speed"))
	var speed01 := VisualMotion.speed_ratio(absf(_host.velocity.x), max_speed)
	var bob_y := VisualMotion.idle_bob(t, 0.35 + (1.0 - speed01) * 0.2, 1.8)
	var run_swing := VisualMotion.run_swing(t, speed01, 1.4, 7.5)
	var ear_flop := VisualMotion.run_swing(t, 0.4 + speed01 * 0.6, 1.5, 3.0)

	var foot_y := _get_collision_bottom() + bob_y
	var facing := -1.0 if _sprite.flip_h else 1.0

	var body_col := Color(0.55, 0.35, 0.15)
	var dark_col := Color(0.35, 0.2, 0.05)
	var belly_col := Color(0.75, 0.55, 0.35)
	var snout_col := Color(0.7, 0.52, 0.35)
	var nose_col := Color(0.1, 0.1, 0.1)
	var eye_white := Color(1.0, 1.0, 0.95)
	var eye_pupil := Color(0.1, 0.1, 0.05)
	var collar_col := Color(0.8, 0.15, 0.15)

	var tail_base_x := facing * -14.0
	var tail_tip_x := tail_base_x + facing * -8.0
	var tail_pts := PackedVector2Array(
		[
			Vector2(tail_base_x, foot_y - 18.0),
			Vector2(tail_tip_x, foot_y - 28.0 - ear_flop * 0.2),
			Vector2(tail_tip_x + facing * -2.0, foot_y - 26.0 - ear_flop * 0.2),
			Vector2(tail_base_x + facing * -1.0, foot_y - 15.0),
		]
	)
	draw_colored_polygon(tail_pts, body_col)

	_draw_ellipse_filled(Vector2(facing * -7.0, foot_y - 3.0 - run_swing), 4.0, 4.5, dark_col)
	_draw_ellipse_filled(Vector2(facing * -7.0, foot_y - 3.0 - run_swing), 3.0, 3.5, body_col)
	_draw_ellipse_filled(Vector2(0, foot_y - 13.0), 15.0, 10.0, body_col)
	_draw_ellipse_border(Vector2(0, foot_y - 13.0), 15.0, 10.0, dark_col, 1.5)
	_draw_ellipse_filled(Vector2(facing * 2.0, foot_y - 10.0), 9.0, 5.0, belly_col)
	_draw_ellipse_filled(Vector2(facing * 8.0, foot_y - 3.0 + run_swing), 4.0, 4.5, dark_col)
	_draw_ellipse_filled(Vector2(facing * 8.0, foot_y - 3.0 + run_swing), 3.0, 3.5, body_col)

	var collar_y := foot_y - 20.0
	draw_line(Vector2(facing * 2.0, collar_y), Vector2(facing * 12.0, collar_y), collar_col, 2.5)

	var head_x := facing * 12.0
	var head_y := foot_y - 22.0
	draw_circle(Vector2(head_x, head_y), 8.0, body_col)
	draw_arc(Vector2(head_x, head_y), 8.0, 0, TAU, 24, dark_col, 1.5)

	var ear_x := head_x + facing * -3.0
	var ear_pts := PackedVector2Array(
		[
			Vector2(ear_x - 3.0, head_y - 6.0),
			Vector2(ear_x - 5.0, head_y + 2.0 + ear_flop),
			Vector2(ear_x - 2.0, head_y + 5.0 + ear_flop),
			Vector2(ear_x + 1.0, head_y + 1.0),
			Vector2(ear_x + 1.0, head_y - 5.0),
		]
	)
	draw_colored_polygon(ear_pts, dark_col)

	var snout_x := head_x + facing * 7.0
	var snout_y := head_y + 2.0
	_draw_ellipse_filled(Vector2(snout_x, snout_y), 5.0, 3.5, snout_col)
	_draw_ellipse_border(Vector2(snout_x, snout_y), 5.0, 3.5, dark_col, 1.0)
	draw_circle(Vector2(snout_x + facing * 3.0, snout_y - 1.0), 2.0, nose_col)

	var eye_x := head_x + facing * 3.0
	var eye_y := head_y - 2.0
	_draw_ellipse_filled(Vector2(eye_x, eye_y), 3.0, 2.5, eye_white)
	draw_circle(Vector2(eye_x + facing * 0.5, eye_y), 1.5, eye_pupil)

	var state: int = int(_host.get("state"))
	if state == 1 or state == 2:
		var bubble_y := foot_y - 40.0
		draw_circle(Vector2(0, bubble_y), 10.0, Color(1.0, 1.0, 1.0))
		draw_arc(Vector2(0, bubble_y), 10.0, 0, TAU, 20, Color(0.3, 0.3, 0.3), 1.0)
		var pointer := PackedVector2Array(
			[
				Vector2(-3, bubble_y + 9),
				Vector2(3, bubble_y + 9),
				Vector2(0, bubble_y + 15),
			]
		)
		draw_colored_polygon(pointer, Color(1.0, 1.0, 1.0))
		draw_rect(Rect2(-1.5, bubble_y - 7, 3, 9), Color(0.85, 0.15, 0.15))
		draw_circle(Vector2(0, bubble_y + 5), 1.8, Color(0.85, 0.15, 0.15))
