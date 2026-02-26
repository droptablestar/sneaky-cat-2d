extends Node2D

var _host: Area2D
var _collision_shape: CollisionShape2D


func _ready() -> void:
	_host = get_parent() as Area2D
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


func _draw() -> void:
	var t := VisualMotion.time_seconds()
	var bob_y := VisualMotion.idle_bob(t, 2.0, 1.2)
	var shimmer := VisualMotion.pulse01(t, 2.8)

	var top_world_y := (
		_host.global_position.y + _get_collision_bottom() - _get_collision_height() + bob_y
	)
	var bottom_world_y := _host.global_position.y + _get_collision_bottom() + bob_y
	ShadowDraw.draw_floor_shadow(
		self, _host.global_position, top_world_y, bottom_world_y, 6.0, 0.42, 0.24, 0.06, 3.0
	)

	var base := Vector2(0.0, bob_y)
	var body_col := Color(1.0, 0.75, 0.1)
	var body_light := Color(1.0, 0.88, 0.4)
	var fin_col := Color(1.0, 0.65, 0.0)
	var eye_white := Color(1.0, 1.0, 0.95)
	var eye_pupil := Color(0.1, 0.1, 0.05)
	var outline := Color(0.7, 0.45, 0.0)

	draw_circle(
		base + Vector2(2, 0), 14 + shimmer * 0.7, Color(1.0, 0.85, 0.2, 0.08 + shimmer * 0.02)
	)
	draw_circle(
		base + Vector2(2, 0), 11 + shimmer * 0.4, Color(1.0, 0.85, 0.2, 0.06 + shimmer * 0.02)
	)

	var tail := PackedVector2Array(
		[
			base + Vector2(-5, 0),
			base + Vector2(-14, -7),
			base + Vector2(-10, -2),
			base + Vector2(-14, 0),
			base + Vector2(-10, 2),
			base + Vector2(-14, 7),
		]
	)
	draw_colored_polygon(tail, fin_col)
	draw_polyline(
		PackedVector2Array(
			[base + Vector2(-14, -7), base + Vector2(-5, 0), base + Vector2(-14, 7)]
		),
		outline,
		1.0
	)
	_draw_ellipse_filled(base + Vector2(2, 0), 9, 6, body_col)
	_draw_ellipse_filled(base + Vector2(3, 2), 6, 3, body_light)

	var outline_pts := PackedVector2Array()
	for i in 21:
		var angle := TAU * i / 20
		outline_pts.append(base + Vector2(2 + cos(angle) * 9, sin(angle) * 6))
	draw_polyline(outline_pts, outline, 1.0)

	var dorsal := PackedVector2Array(
		[
			base + Vector2(-1, -5.5),
			base + Vector2(3, -11),
			base + Vector2(7, -5.5),
		]
	)
	draw_colored_polygon(dorsal, fin_col)
	draw_polyline(dorsal, outline, 0.8)

	var pectoral := PackedVector2Array(
		[
			base + Vector2(0, 2),
			base + Vector2(-3, 7),
			base + Vector2(3, 5),
		]
	)
	draw_colored_polygon(pectoral, fin_col)

	draw_circle(base + Vector2(7, -1.5), 2.5, eye_white)
	draw_circle(base + Vector2(7.5, -1.5), 1.3, eye_pupil)
	draw_arc(base + Vector2(11, 1), 2, -0.3, 0.3, 6, outline, 0.8)
