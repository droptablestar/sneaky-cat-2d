extends Node2D


func _draw() -> void:
	var host := get_parent() as Node2D
	if host == null:
		return
	var is_platform: bool = bool(host.get("is_platform"))
	var furniture_type: int = int(host.get("furniture_type"))

	var hw: float = 28.0 if is_platform else 36.0
	var top_local_y: float = -30.0 if is_platform else -56.0
	var bottom_local_y: float = -22.0 if is_platform else 24.0
	var top_world_y: float = host.global_position.y + top_local_y
	var bottom_world_y: float = host.global_position.y + bottom_local_y
	ShadowDraw.draw_floor_shadow(
		self, host.global_position, top_world_y, bottom_world_y, hw, 0.4, 0.24, 0.08, 4.0, 0.0012
	)

	match furniture_type:
		0:
			_draw_shelf()
		1:
			_draw_couch()
		2:
			_draw_table()
		3:
			_draw_bookcase()


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


func _draw_rounded_rect_outline(
	rect: Rect2, color: Color, width: float = 1.0, radius: float = 4.0, segments: int = 6
) -> void:
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


func _draw_shelf() -> void:
	var wood := Color(0.55, 0.38, 0.18)
	var wood_dark := Color(0.4, 0.25, 0.1)
	var wood_light := Color(0.65, 0.5, 0.3)
	var bracket := Color(0.35, 0.25, 0.12)
	draw_rect(Rect2(-28, -54, 56, 26), wood_dark)
	draw_rect(Rect2(-28, -54, 56, 26), Color(0.3, 0.2, 0.08), false, 1.0)
	for sy in [-54, -40, -28]:
		draw_rect(Rect2(-32, sy, 64, 4), wood)
		draw_line(Vector2(-32, sy), Vector2(32, sy), wood_light, 1.0)
	draw_rect(Rect2(-34, -30, 68, 6), wood)
	draw_rect(Rect2(-34, -30, 68, 6), wood_dark, false, 1.0)
	draw_line(Vector2(-33, -29), Vector2(33, -29), wood_light, 1.0)
	var bracket_pts_l := PackedVector2Array(
		[
			Vector2(-22, -24),
			Vector2(-22, -16),
			Vector2(-14, -16),
		]
	)
	draw_colored_polygon(bracket_pts_l, bracket)
	var bracket_pts_r := PackedVector2Array(
		[
			Vector2(22, -24),
			Vector2(22, -16),
			Vector2(14, -16),
		]
	)
	draw_colored_polygon(bracket_pts_r, bracket)
	draw_rect(Rect2(-18, -52, 6, 10), Color(0.6, 0.3, 0.3))
	draw_rect(Rect2(4, -52, 8, 10), Color(0.3, 0.5, 0.6))
	draw_rect(Rect2(-8, -38, 5, 8), Color(0.7, 0.6, 0.3))
	draw_circle(Vector2(14, -34), 3, Color(0.4, 0.6, 0.4))


func _draw_couch() -> void:
	var fabric := Color(0.45, 0.35, 0.55)
	var fabric_dark := Color(0.3, 0.22, 0.4)
	var fabric_light := Color(0.55, 0.45, 0.65)
	var wood_leg := Color(0.4, 0.25, 0.12)
	draw_rect(Rect2(-34, -6, 5, 8), wood_leg)
	draw_rect(Rect2(29, -6, 5, 8), wood_leg)
	_draw_rounded_rect(Rect2(-36, -50, 72, 24), fabric_dark, 5.0)
	_draw_rounded_rect_outline(Rect2(-36, -50, 72, 24), Color(0.25, 0.18, 0.35), 1.0, 5.0)
	_draw_rounded_rect(Rect2(-38, -30, 76, 22), fabric, 4.0)
	_draw_rounded_rect_outline(Rect2(-38, -30, 76, 22), fabric_dark, 1.5, 4.0)
	draw_line(Vector2(-12, -28), Vector2(-12, -12), fabric_dark, 1.5)
	draw_line(Vector2(12, -28), Vector2(12, -12), fabric_dark, 1.5)
	for cx in [-24, 0, 24]:
		draw_line(Vector2(cx - 6.0, -22.0), Vector2(cx + 6.0, -22.0), fabric_light, 1.0)
	_draw_rounded_rect(Rect2(-42, -36, 10, 28), fabric_dark, 3.0)
	_draw_rounded_rect(Rect2(32, -36, 10, 28), fabric_dark, 3.0)


func _draw_table() -> void:
	var wood := Color(0.5, 0.35, 0.18)
	var wood_dark := Color(0.38, 0.24, 0.1)
	var wood_light := Color(0.62, 0.48, 0.28)
	draw_rect(Rect2(-28, -24, 4, 26), wood_dark)
	draw_rect(Rect2(24, -24, 4, 26), wood_dark)
	draw_line(Vector2(-26, -8), Vector2(26, -8), wood_dark, 1.5)
	draw_rect(Rect2(-34, -32, 68, 8), wood)
	draw_rect(Rect2(-34, -32, 68, 8), wood_dark, false, 1.5)
	draw_line(Vector2(-32, -29), Vector2(32, -29), wood_light, 1.0)
	draw_line(Vector2(-30, -26), Vector2(30, -26), wood_light, 0.8)
	draw_rect(Rect2(-10, -24, 20, 8), wood_dark)
	draw_rect(Rect2(-10, -24, 20, 8), Color(0.3, 0.18, 0.06), false, 1.0)
	draw_circle(Vector2(0, -20), 1.5, Color(0.7, 0.6, 0.3))


func _draw_bookcase() -> void:
	var wood := Color(0.45, 0.3, 0.15)
	var wood_dark := Color(0.32, 0.2, 0.08)
	var wood_light := Color(0.58, 0.42, 0.22)
	draw_rect(Rect2(-30, -60, 60, 62), wood)
	draw_rect(Rect2(-30, -60, 60, 62), wood_dark, false, 1.5)
	draw_rect(Rect2(-30, -60, 4, 62), wood_dark)
	draw_rect(Rect2(26, -60, 4, 62), wood_dark)
	draw_rect(Rect2(-32, -62, 64, 4), wood_dark)
	draw_line(Vector2(-32, -62), Vector2(32, -62), wood_light, 1.0)
	for sy in [-46, -30]:
		draw_rect(Rect2(-26, sy, 52, 3), wood)
		draw_line(Vector2(-26, sy), Vector2(26, sy), wood_light, 0.8)
	var book_colors := [
		Color(0.7, 0.25, 0.2),
		Color(0.2, 0.5, 0.7),
		Color(0.6, 0.5, 0.2),
		Color(0.3, 0.6, 0.35),
		Color(0.5, 0.25, 0.5),
		Color(0.7, 0.4, 0.2),
	]
	var bx := -24.0
	for i in book_colors.size():
		var bw := 6.0 + fmod(i * 3.0, 3.0)
		var bh := 12.0 + fmod(i * 5.0, 4.0)
		draw_rect(Rect2(bx, -46 - bh, bw, bh), book_colors[i])
		draw_rect(Rect2(bx, -46 - bh, bw, bh), book_colors[i].darkened(0.3), false, 0.8)
		bx += bw + 1.0
	bx = -22.0
	for i in range(4):
		var bw := 7.0 + fmod(i * 4.0, 3.0)
		var bh := 10.0 + fmod(i * 3.0, 5.0)
		var col: Color = book_colors[(i + 2) % book_colors.size()]
		draw_rect(Rect2(bx, -30 - bh, bw, bh), col)
		draw_rect(Rect2(bx, -30 - bh, bw, bh), col.darkened(0.3), false, 0.8)
		bx += bw + 2.0
	draw_circle(Vector2(-14, -6), 4, Color(0.6, 0.55, 0.5))
	draw_rect(Rect2(6, -12, 14, 12), Color(0.3, 0.45, 0.5))
	draw_rect(Rect2(6, -12, 14, 12), Color(0.2, 0.35, 0.4), false, 0.8)
	draw_rect(Rect2(-32, -64, 64, 4), wood)
	draw_line(Vector2(-31, -63), Vector2(31, -63), wood_light, 1.0)
