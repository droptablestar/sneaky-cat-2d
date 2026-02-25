extends Area2D

enum FurnitureType { SHELF, COUCH, TABLE, BOOKCASE }

# If true, the Platform child body is active so the cat can jump on it.
@export var is_platform: bool = false
@export var furniture_type: FurnitureType = FurnitureType.SHELF

@onready var platform: StaticBody2D = $Platform

# Platform CollisionShape2D is at y=-24 with half-height 6, so top surface is at y=-30
const PLATFORM_TOP_OFFSET = -30.0

var _bodies_in_zone: Array = []

func _ready() -> void:
	z_as_relative = false
	z_index = int(global_position.y)
	set_collision_mask_value(Layers.CAT, true)
	platform.set_collision_layer_value(Layers.WORLD, false)
	platform.set_collision_layer_value(Layers.PLATFORM, is_platform)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(_delta: float) -> void:
	for body in _bodies_in_zone:
		var should_hide: bool
		if is_platform:
			# Only hide when cat has landed on the platform, not when jumping below it
			var platform_top = global_position.y + PLATFORM_TOP_OFFSET
			should_hide = body.global_position.y <= platform_top + 2.0
		else:
			should_hide = true
		if body.get("is_hidden") != should_hide:
			body.set_hidden(should_hide)

func _draw_floor_shadow() -> void:
	var hw: float = 28.0 if is_platform else 36.0
	var floor_y := GameManager.FLOOR_Y
	var light := GameManager.SHADOW_LIGHT
	var shadow_y := floor_y - global_position.y
	var top_local_y := -30.0 if is_platform else -56.0
	var bottom_local_y := -22.0 if is_platform else 24.0
	var top_world_y := global_position.y + top_local_y
	var bottom_world_y := global_position.y + bottom_local_y
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
	var width_near := hw
	var width_far := hw * 0.4
	var alpha := clampf(0.24 - absf(far_x - near_x) * 0.0012, 0.08, 0.24)
	var pts := PackedVector2Array([
		Vector2(near_x - width_near, shadow_y), Vector2(near_x + width_near, shadow_y),
		Vector2(far_x + width_far, shadow_y + 4), Vector2(far_x - width_far, shadow_y + 4),
	])
	draw_colored_polygon(pts, Color(0.0, 0.0, 0.0, alpha))

func _draw_rounded_rect(rect: Rect2, color: Color, radius: float = 4.0, segments: int = 6) -> void:
	var pts := PackedVector2Array()
	var corners := [
		Vector2(rect.position.x + radius, rect.position.y + radius),
		Vector2(rect.end.x - radius, rect.position.y + radius),
		Vector2(rect.end.x - radius, rect.end.y - radius),
		Vector2(rect.position.x + radius, rect.end.y - radius),
	]
	for ci in 4:
		var start_angle := PI + ci * PI * 0.5
		for si in segments + 1:
			var angle := start_angle + (PI * 0.5) * si / segments
			pts.append(corners[ci] + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(pts, color)

func _draw_rounded_rect_outline(rect: Rect2, color: Color, width: float = 1.0, radius: float = 4.0, segments: int = 6) -> void:
	var pts := PackedVector2Array()
	var corners := [
		Vector2(rect.position.x + radius, rect.position.y + radius),
		Vector2(rect.end.x - radius, rect.position.y + radius),
		Vector2(rect.end.x - radius, rect.end.y - radius),
		Vector2(rect.position.x + radius, rect.end.y - radius),
	]
	for ci in 4:
		var start_angle := PI + ci * PI * 0.5
		for si in segments + 1:
			var angle := start_angle + (PI * 0.5) * si / segments
			pts.append(corners[ci] + Vector2(cos(angle), sin(angle)) * radius)
	pts.append(pts[0])
	draw_polyline(pts, color, width)

func _draw() -> void:
	_draw_floor_shadow()
	match furniture_type:
		FurnitureType.SHELF:
			_draw_shelf()
		FurnitureType.COUCH:
			_draw_couch()
		FurnitureType.TABLE:
			_draw_table()
		FurnitureType.BOOKCASE:
			_draw_bookcase()

func _draw_shelf() -> void:
	var wood := Color(0.55, 0.38, 0.18)
	var wood_dark := Color(0.4, 0.25, 0.1)
	var wood_light := Color(0.65, 0.5, 0.3)
	var bracket := Color(0.35, 0.25, 0.12)

	# Wall bracket / back panel
	draw_rect(Rect2(-28, -54, 56, 26), wood_dark)
	draw_rect(Rect2(-28, -54, 56, 26), Color(0.3, 0.2, 0.08), false, 1.0)

	# Horizontal shelves
	for sy in [-54, -40, -28]:
		draw_rect(Rect2(-32, sy, 64, 4), wood)
		draw_line(Vector2(-32, sy), Vector2(32, sy), wood_light, 1.0)

	# Shelf surface (platform)
	draw_rect(Rect2(-34, -30, 68, 6), wood)
	draw_rect(Rect2(-34, -30, 68, 6), wood_dark, false, 1.0)
	draw_line(Vector2(-33, -29), Vector2(33, -29), wood_light, 1.0)

	# Brackets underneath
	var bracket_pts_l := PackedVector2Array([
		Vector2(-22, -24), Vector2(-22, -16), Vector2(-14, -16),
	])
	draw_colored_polygon(bracket_pts_l, bracket)
	var bracket_pts_r := PackedVector2Array([
		Vector2(22, -24), Vector2(22, -16), Vector2(14, -16),
	])
	draw_colored_polygon(bracket_pts_r, bracket)

	# Small decorative items on sub-shelves
	draw_rect(Rect2(-18, -52, 6, 10), Color(0.6, 0.3, 0.3))
	draw_rect(Rect2(4, -52, 8, 10), Color(0.3, 0.5, 0.6))
	draw_rect(Rect2(-8, -38, 5, 8), Color(0.7, 0.6, 0.3))
	draw_circle(Vector2(14, -34), 3, Color(0.4, 0.6, 0.4))

func _draw_couch() -> void:
	var fabric := Color(0.45, 0.35, 0.55)
	var fabric_dark := Color(0.3, 0.22, 0.4)
	var fabric_light := Color(0.55, 0.45, 0.65)
	var wood_leg := Color(0.4, 0.25, 0.12)

	# Legs
	draw_rect(Rect2(-34, -6, 5, 8), wood_leg)
	draw_rect(Rect2(29, -6, 5, 8), wood_leg)

	# Back rest
	_draw_rounded_rect(Rect2(-36, -50, 72, 24), fabric_dark, 5.0)
	_draw_rounded_rect_outline(Rect2(-36, -50, 72, 24), Color(0.25, 0.18, 0.35), 1.0, 5.0)

	# Seat
	_draw_rounded_rect(Rect2(-38, -30, 76, 22), fabric, 4.0)
	_draw_rounded_rect_outline(Rect2(-38, -30, 76, 22), fabric_dark, 1.5, 4.0)

	# Cushion lines
	draw_line(Vector2(-12, -28), Vector2(-12, -12), fabric_dark, 1.5)
	draw_line(Vector2(12, -28), Vector2(12, -12), fabric_dark, 1.5)

	# Cushion highlights
	for cx in [-24, 0, 24]:
		draw_line(Vector2(cx - 6.0, -22.0), Vector2(cx + 6.0, -22.0), fabric_light, 1.0)

	# Armrests
	_draw_rounded_rect(Rect2(-42, -36, 10, 28), fabric_dark, 3.0)
	_draw_rounded_rect(Rect2(32, -36, 10, 28), fabric_dark, 3.0)

func _draw_table() -> void:
	var wood := Color(0.5, 0.35, 0.18)
	var wood_dark := Color(0.38, 0.24, 0.1)
	var wood_light := Color(0.62, 0.48, 0.28)

	# Table legs
	draw_rect(Rect2(-28, -24, 4, 26), wood_dark)
	draw_rect(Rect2(24, -24, 4, 26), wood_dark)
	# Cross brace
	draw_line(Vector2(-26, -8), Vector2(26, -8), wood_dark, 1.5)

	# Table top — thick surface
	draw_rect(Rect2(-34, -32, 68, 8), wood)
	draw_rect(Rect2(-34, -32, 68, 8), wood_dark, false, 1.5)
	# Wood grain highlight
	draw_line(Vector2(-32, -29), Vector2(32, -29), wood_light, 1.0)
	draw_line(Vector2(-30, -26), Vector2(30, -26), wood_light, 0.8)

	# Small drawer
	draw_rect(Rect2(-10, -24, 20, 8), wood_dark)
	draw_rect(Rect2(-10, -24, 20, 8), Color(0.3, 0.18, 0.06), false, 1.0)
	# Drawer knob
	draw_circle(Vector2(0, -20), 1.5, Color(0.7, 0.6, 0.3))

func _draw_bookcase() -> void:
	var wood := Color(0.45, 0.3, 0.15)
	var wood_dark := Color(0.32, 0.2, 0.08)
	var wood_light := Color(0.58, 0.42, 0.22)

	# Main frame
	draw_rect(Rect2(-30, -60, 60, 62), wood)
	draw_rect(Rect2(-30, -60, 60, 62), wood_dark, false, 1.5)

	# Side panels (slightly darker)
	draw_rect(Rect2(-30, -60, 4, 62), wood_dark)
	draw_rect(Rect2(26, -60, 4, 62), wood_dark)

	# Top molding
	draw_rect(Rect2(-32, -62, 64, 4), wood_dark)
	draw_line(Vector2(-32, -62), Vector2(32, -62), wood_light, 1.0)

	# Shelf dividers
	for sy in [-46, -30]:
		draw_rect(Rect2(-26, sy, 52, 3), wood)
		draw_line(Vector2(-26, sy), Vector2(26, sy), wood_light, 0.8)

	# Books on top shelf
	var book_colors := [
		Color(0.7, 0.25, 0.2), Color(0.2, 0.5, 0.7), Color(0.6, 0.5, 0.2),
		Color(0.3, 0.6, 0.35), Color(0.5, 0.25, 0.5), Color(0.7, 0.4, 0.2),
	]
	var bx := -24.0
	for i in book_colors.size():
		var bw := 6.0 + fmod(i * 3.0, 3.0)
		var bh := 12.0 + fmod(i * 5.0, 4.0)
		draw_rect(Rect2(bx, -46 - bh, bw, bh), book_colors[i])
		draw_rect(Rect2(bx, -46 - bh, bw, bh), book_colors[i].darkened(0.3), false, 0.8)
		bx += bw + 1.0

	# Books on middle shelf
	bx = -22.0
	for i in range(4):
		var bw := 7.0 + fmod(i * 4.0, 3.0)
		var bh := 10.0 + fmod(i * 3.0, 5.0)
		var col: Color = book_colors[(i + 2) % book_colors.size()]
		draw_rect(Rect2(bx, -30 - bh, bw, bh), col)
		draw_rect(Rect2(bx, -30 - bh, bw, bh), col.darkened(0.3), false, 0.8)
		bx += bw + 2.0

	# Items on bottom shelf
	draw_circle(Vector2(-14, -6), 4, Color(0.6, 0.55, 0.5))
	draw_rect(Rect2(6, -12, 14, 12), Color(0.3, 0.45, 0.5))
	draw_rect(Rect2(6, -12, 14, 12), Color(0.2, 0.35, 0.4), false, 0.8)

	# Platform surface on top
	draw_rect(Rect2(-32, -64, 64, 4), wood)
	draw_line(Vector2(-31, -63), Vector2(31, -63), wood_light, 1.0)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("cat"):
		_bodies_in_zone.append(body)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("cat"):
		_bodies_in_zone.erase(body)
		body.set_hidden(false)
