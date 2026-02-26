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


func _draw() -> void:
	var top_world_y := _host.global_position.y + _get_collision_bottom() - _get_collision_height()
	var bottom_world_y := _host.global_position.y + _get_collision_bottom()
	ShadowDraw.draw_floor_shadow(
		self, _host.global_position, top_world_y, bottom_world_y, 14.0, 0.35, 0.26
	)

	var foot_y := _get_collision_bottom()
	var is_open: bool = _host.call("is_open")
	var t := VisualMotion.time_seconds()
	var pulse := VisualMotion.pulse01(t, 1.8)

	var door_col: Color
	var door_dark: Color
	var trim_col: Color
	var panel_col: Color

	if is_open:
		door_col = Color(0.18, 0.55, 0.2)
		door_dark = Color(0.1, 0.38, 0.12)
		trim_col = Color(0.3, 0.75, 0.35)
		panel_col = Color(0.22, 0.62, 0.25)
	else:
		door_col = Color(0.42, 0.28, 0.12)
		door_dark = Color(0.3, 0.18, 0.06)
		trim_col = Color(0.55, 0.4, 0.18)
		panel_col = Color(0.48, 0.32, 0.14)

	draw_rect(Rect2(-19, foot_y - 56, 38, 56), trim_col)
	draw_rect(Rect2(-16, foot_y - 54, 32, 54), door_col)
	draw_rect(Rect2(-12, foot_y - 50, 24, 18), panel_col)
	draw_rect(Rect2(-12, foot_y - 50, 24, 18), door_dark, false, 1.0)
	draw_rect(Rect2(-12, foot_y - 26, 24, 18), panel_col)
	draw_rect(Rect2(-12, foot_y - 26, 24, 18), door_dark, false, 1.0)
	draw_rect(Rect2(-19, foot_y - 56, 38, 56), door_dark, false, 1.5)

	draw_rect(Rect2(-16, foot_y - 48, 3, 6), Color(0.4, 0.35, 0.25))
	draw_rect(Rect2(-16, foot_y - 18, 3, 6), Color(0.4, 0.35, 0.25))
	draw_circle(Vector2(9, foot_y - 24), 5, door_dark)
	draw_circle(Vector2(9, foot_y - 24), 3, Color(0.85, 0.7, 0.15))
	draw_circle(Vector2(9, foot_y - 24), 3, Color(0.95, 0.85, 0.4), false, 0.8)

	if not is_open:
		draw_circle(Vector2(9, foot_y - 20), 1.2, Color(0.15, 0.1, 0.05))
		draw_circle(Vector2(0, foot_y - 32), 4, Color(0.8, 0.15, 0.15, 0.28 + pulse * 0.08))
		draw_circle(Vector2(0, foot_y - 32), 2.5, Color(0.9, 0.2, 0.2))
	else:
		draw_circle(
			Vector2(0, foot_y - 32), 4.0 + pulse * 1.4, Color(0.2, 0.9, 0.2, 0.2 + pulse * 0.18)
		)
		draw_circle(Vector2(0, foot_y - 32), 2.5 + pulse * 0.4, Color(0.3, 1.0, 0.3))
