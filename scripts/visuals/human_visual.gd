extends Node2D

const SHADOW_HW: float = 8.0

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
	var bob_y := VisualMotion.idle_bob(t, 0.25 + (1.0 - speed01) * 0.2, 1.5)
	var run_swing := VisualMotion.run_swing(t, speed01, 1.2, 6.5)
	var arm_swing := VisualMotion.run_swing(t, speed01, 2.0, 6.5)

	var foot_y := _get_collision_bottom() + bob_y
	var facing := -1.0 if _sprite.flip_h else 1.0

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

	draw_rect(Rect2(facing * -5.0 - 3.0, foot_y - 12.0 - run_swing, 6.0, 10.0), pants)
	draw_rect(
		Rect2(facing * -5.0 - 3.0, foot_y - 12.0 - run_swing, 6.0, 10.0), pants_dark, false, 1.0
	)
	draw_rect(Rect2(facing * 3.0 - 3.0, foot_y - 12.0 + run_swing, 6.0, 10.0), pants)
	draw_rect(
		Rect2(facing * 3.0 - 3.0, foot_y - 12.0 + run_swing, 6.0, 10.0), pants_dark, false, 1.0
	)

	_draw_ellipse_filled(Vector2(facing * -5.0, foot_y - 1.0 - run_swing), 4.5, 2.5, shoe)
	_draw_ellipse_filled(Vector2(facing * 3.0, foot_y - 1.0 + run_swing), 4.5, 2.5, shoe)

	var torso_y := foot_y - 28.0
	_draw_ellipse_filled(Vector2(0, torso_y + 7.0), 10.0, 14.0, shirt)
	_draw_ellipse_border(Vector2(0, torso_y + 7.0), 10.0, 14.0, shirt_dark, 1.5)

	var arm_back_x := facing * -8.0
	draw_rect(Rect2(arm_back_x - 2.5, foot_y - 26.0 - arm_swing, 5.0, 14.0), shirt_dark)
	draw_circle(Vector2(arm_back_x, foot_y - 11.0 - arm_swing), 3.0, skin)
	var arm_front_x := facing * 8.0
	draw_rect(Rect2(arm_front_x - 2.5, foot_y - 26.0 + arm_swing, 5.0, 14.0), shirt)
	draw_rect(
		Rect2(arm_front_x - 2.5, foot_y - 26.0 + arm_swing, 5.0, 14.0), shirt_dark, false, 1.0
	)
	draw_circle(Vector2(arm_front_x, foot_y - 11.0 + arm_swing), 3.0, skin)

	var collar_pts := PackedVector2Array(
		[
			Vector2(-5.0, foot_y - 33.0),
			Vector2(0, foot_y - 30.0),
			Vector2(5.0, foot_y - 33.0),
		]
	)
	draw_polyline(collar_pts, shirt_dark, 1.5)

	var head_x := facing * 1.0
	var head_y := foot_y - 40.0
	_draw_ellipse_filled(Vector2(head_x, head_y), 8.0, 9.0, skin)
	_draw_ellipse_border(Vector2(head_x, head_y), 8.0, 9.0, outline, 1.2)

	var hair_pts := PackedVector2Array()
	hair_pts.append(Vector2(head_x - 9.0, head_y))
	for i in 11:
		var angle := PI + (PI * i / 10.0)
		hair_pts.append(Vector2(head_x + cos(angle) * 9.0, head_y + sin(angle) * 10.0))
	hair_pts.append(Vector2(head_x + 9.0, head_y))
	draw_colored_polygon(hair_pts, hair)

	var eye_x := head_x + facing * 4.0
	var eye_y := head_y + 0.5
	_draw_ellipse_filled(Vector2(eye_x, eye_y), 2.5, 2.0, eye_white)
	draw_circle(Vector2(eye_x + facing * 0.5, eye_y), 1.2, eye_pupil)
	draw_line(
		Vector2(head_x + facing * 2.0, head_y + 5.0),
		Vector2(head_x + facing * 5.0, head_y + 5.0),
		outline,
		1.0
	)

	var state: int = int(_host.get("state"))
	if state == 1 or state == 2:
		var bubble_y := foot_y - 58.0
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
