extends Node2D


func _draw() -> void:
	# --- Back wall fill ---
	draw_rect(Rect2(0, 0, 1152, 352), Color(0.93, 0.87, 0.78))

	# --- Side walls (trapezoids for 3D box-room depth) ---
	# VP = (576, 190); side wall edges at x=80 and x=1072
	# Left side wall
	var left_wall := PackedVector2Array(
		[
			Vector2(0, 0),
			Vector2(80, 26),
			Vector2(80, 329),
			Vector2(0, 352),
		]
	)
	draw_colored_polygon(left_wall, Color(0.70, 0.62, 0.50))

	# Right side wall
	var right_wall := PackedVector2Array(
		[
			Vector2(1072, 26),
			Vector2(1152, 0),
			Vector2(1152, 352),
			Vector2(1072, 329),
		]
	)
	draw_colored_polygon(right_wall, Color(0.70, 0.62, 0.50))

	# --- Ceiling strip ---
	draw_rect(Rect2(0, 0, 1152, 14), Color(0.78, 0.72, 0.62))

	# --- Baseboard ---
	draw_rect(Rect2(0, 338, 1152, 14), Color(0.78, 0.72, 0.62))

	# --- Floor base ---
	draw_rect(Rect2(0, 352, 1152, 48), Color(0.38, 0.27, 0.14))

	# --- Floor perspective grid ---
	var vp_x := 576.0
	var vp_y := 352.0
	var floor_bottom := 400.0
	var grid_color := Color(0.45, 0.33, 0.18)

	# Depth lines fanning from VP to bottom edge
	var x := 0.0
	while x <= 1152.0:
		draw_line(Vector2(vp_x, vp_y), Vector2(x, floor_bottom), grid_color, 1.5)
		x += 96.0

	# Horizontal tile rows (tighter spacing near far edge = perspective)
	draw_line(Vector2(0, 380), Vector2(1152, 380), grid_color, 1.5)
	draw_line(Vector2(0, 393), Vector2(1152, 393), grid_color, 1.5)

	# --- Floor corner darkening (where side walls meet floor) ---
	draw_rect(Rect2(0, 352, 80, 48), Color(0.28, 0.18, 0.08))
	draw_rect(Rect2(1072, 352, 80, 48), Color(0.28, 0.18, 0.08))

	# --- Windows ---
	_draw_window(160, 30)
	_draw_window(860, 30)

	# --- Picture frame ---
	_draw_picture(490, 55)


func _draw_window(x: int, y: int) -> void:
	const W := 120
	const H := 170
	const INSET := 8

	# Outer frame
	draw_rect(Rect2(x, y, W, H), Color(0.75, 0.68, 0.55))

	# Glass (inset)
	var gx := x + INSET
	var gy := y + INSET
	var gw := W - INSET * 2
	var gh := H - INSET * 2
	draw_rect(Rect2(gx, gy, gw, gh), Color(0.72, 0.88, 1.0, 0.6))

	# Light cast — faint warm glow below window down to baseboard
	draw_rect(Rect2(x, y + H, W, 338 - (y + H)), Color(1.0, 0.95, 0.8, 0.1))

	# Vertical bar (center of glass)
	var bar_x := gx + gw / 2.0 - 2
	draw_rect(Rect2(bar_x, gy, 4, gh), Color(0.75, 0.68, 0.55))

	# Horizontal bar (mid-height of glass)
	var bar_y := gy + gh / 2.0 - 2
	draw_rect(Rect2(gx, bar_y, gw, 4), Color(0.75, 0.68, 0.55))


func _draw_picture(x: int, y: int) -> void:
	const OW := 110
	const OH := 90
	const INSET := 8

	# Outer frame — brown
	draw_rect(Rect2(x, y, OW, OH), Color(0.55, 0.42, 0.25))

	# Inner canvas — muted teal
	draw_rect(Rect2(x + INSET, y + INSET, OW - INSET * 2, OH - INSET * 2), Color(0.55, 0.65, 0.6))
