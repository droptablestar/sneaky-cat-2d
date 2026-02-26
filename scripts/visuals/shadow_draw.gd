class_name ShadowDraw
extends RefCounted


static func draw_floor_shadow(
	canvas: CanvasItem,
	world_position: Vector2,
	top_world_y: float,
	bottom_world_y: float,
	half_width_near: float,
	half_width_far_ratio: float = 0.35,
	alpha_base: float = 0.28,
	alpha_min: float = 0.08,
	far_y_offset: float = 4.0,
	perspective_alpha_factor: float = 0.0015
) -> void:
	var floor_y := GameManager.FLOOR_Y
	var light := GameManager.get_shadow_light_for_position(world_position.x)
	var clamped_top := top_world_y
	var clamped_bottom := bottom_world_y
	if clamped_bottom >= floor_y:
		clamped_bottom = floor_y - 1.0
	if clamped_top >= floor_y:
		clamped_top = floor_y - 8.0

	var top_t := (floor_y - light.y) / maxf(1.0, clamped_top - light.y)
	var bottom_t := (floor_y - light.y) / maxf(1.0, clamped_bottom - light.y)
	var top_x := light.x + (world_position.x - light.x) * top_t
	var bottom_x := light.x + (world_position.x - light.x) * bottom_t
	var near_x := bottom_x - world_position.x
	var far_x := top_x - world_position.x
	var width_far := half_width_near * half_width_far_ratio
	var alpha := clampf(
		alpha_base - absf(far_x - near_x) * perspective_alpha_factor, alpha_min, alpha_base
	)
	var shadow_y := floor_y - world_position.y
	var points := PackedVector2Array(
		[
			Vector2(near_x - half_width_near, shadow_y),
			Vector2(near_x + half_width_near, shadow_y),
			Vector2(far_x + width_far, shadow_y + far_y_offset),
			Vector2(far_x - width_far, shadow_y + far_y_offset),
		]
	)
	canvas.draw_colored_polygon(points, Color(0.0, 0.0, 0.0, alpha))
