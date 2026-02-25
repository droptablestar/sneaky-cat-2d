extends Area2D

var _collision_shape: CollisionShape2D

func _ready() -> void:
	_collision_shape = $CollisionShape2D
	z_as_relative = false
	z_index = int(global_position.y)
	GameManager.register_fish()
	set_collision_layer_value(Layers.WORLD, false)
	set_collision_mask_value(Layers.CAT, true)
	body_entered.connect(_on_body_entered)

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

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("cat"):
		GameManager.collect_fish()
		queue_free()

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
	var width_near := 6.0
	var width_far := 2.5
	var alpha := clampf(0.24 - absf(far_x - near_x) * 0.0015, 0.06, 0.24)
	var pts := PackedVector2Array([
		Vector2(near_x - width_near, shadow_y), Vector2(near_x + width_near, shadow_y),
		Vector2(far_x + width_far, shadow_y + 3), Vector2(far_x - width_far, shadow_y + 3),
	])
	draw_colored_polygon(pts, Color(0.0, 0.0, 0.0, alpha))

func _draw_ellipse_filled(center: Vector2, rx: float, ry: float, color: Color, segments: int = 20) -> void:
	var pts := PackedVector2Array()
	for i in segments:
		var angle := TAU * i / segments
		pts.append(center + Vector2(cos(angle) * rx, sin(angle) * ry))
	draw_colored_polygon(pts, color)

func _draw() -> void:
	_draw_floor_shadow()

	var body_col := Color(1.0, 0.75, 0.1)
	var body_light := Color(1.0, 0.88, 0.4)
	var fin_col := Color(1.0, 0.65, 0.0)
	var eye_white := Color(1.0, 1.0, 0.95)
	var eye_pupil := Color(0.1, 0.1, 0.05)
	var outline := Color(0.7, 0.45, 0.0)

	# Glow effect — subtle golden aura
	draw_circle(Vector2(2, 0), 14, Color(1.0, 0.85, 0.2, 0.08))
	draw_circle(Vector2(2, 0), 11, Color(1.0, 0.85, 0.2, 0.06))

	# Tail fin — forked
	var tail := PackedVector2Array([
		Vector2(-5, 0), Vector2(-14, -7), Vector2(-10, -2),
		Vector2(-14, 0),
		Vector2(-10, 2), Vector2(-14, 7),
	])
	draw_colored_polygon(tail, fin_col)
	draw_polyline(PackedVector2Array([Vector2(-14, -7), Vector2(-5, 0), Vector2(-14, 7)]), outline, 1.0)

	# Body — oval
	_draw_ellipse_filled(Vector2(2, 0), 9, 6, body_col)

	# Belly highlight
	_draw_ellipse_filled(Vector2(3, 2), 6, 3, body_light)

	# Outline
	var outline_pts := PackedVector2Array()
	for i in 21:
		var angle := TAU * i / 20
		outline_pts.append(Vector2(2 + cos(angle) * 9, sin(angle) * 6))
	draw_polyline(outline_pts, outline, 1.0)

	# Dorsal fin
	var dorsal := PackedVector2Array([
		Vector2(-1, -5.5), Vector2(3, -11), Vector2(7, -5.5),
	])
	draw_colored_polygon(dorsal, fin_col)
	draw_polyline(dorsal, outline, 0.8)

	# Pectoral fin (small, underneath)
	var pec := PackedVector2Array([
		Vector2(0, 2), Vector2(-3, 7), Vector2(3, 5),
	])
	draw_colored_polygon(pec, fin_col)

	# Eye
	draw_circle(Vector2(7, -1.5), 2.5, eye_white)
	draw_circle(Vector2(7.5, -1.5), 1.3, eye_pupil)

	# Mouth
	draw_arc(Vector2(11, 1), 2, -0.3, 0.3, 6, outline, 0.8)
