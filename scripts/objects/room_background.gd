extends Node2D

func _draw() -> void:
	# Wall fill — warm cream
	draw_rect(Rect2(0, 0, 1152, 400), Color(0.93, 0.87, 0.78))

	# Ceiling strip
	draw_rect(Rect2(0, 0, 1152, 14), Color(0.78, 0.72, 0.62))

	# Baseboard
	draw_rect(Rect2(0, 338, 1152, 14), Color(0.78, 0.72, 0.62))

	# Floor fill (below baseboard, fills gap under the floor StaticBody)
	draw_rect(Rect2(0, 352, 1152, 48), Color(0.3, 0.2, 0.1))

	# Windows
	_draw_window(160, 30)
	_draw_window(860, 30)

	# Picture frame
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
	var bar_x := gx + gw / 2 - 2
	draw_rect(Rect2(bar_x, gy, 4, gh), Color(0.75, 0.68, 0.55))

	# Horizontal bar (mid-height of glass)
	var bar_y := gy + gh / 2 - 2
	draw_rect(Rect2(gx, bar_y, gw, 4), Color(0.75, 0.68, 0.55))


func _draw_picture(x: int, y: int) -> void:
	const OW := 110
	const OH := 90
	const INSET := 8

	# Outer frame — brown
	draw_rect(Rect2(x, y, OW, OH), Color(0.55, 0.42, 0.25))

	# Inner canvas — muted teal
	draw_rect(Rect2(x + INSET, y + INSET, OW - INSET * 2, OH - INSET * 2), Color(0.55, 0.65, 0.6))
