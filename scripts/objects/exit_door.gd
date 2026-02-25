extends Area2D

var _is_open: bool = false
var _collision_shape: CollisionShape2D

const SHADOW_HW: float = 14.0
const SHADOW_HEIGHT: float = 52.0

func _ready() -> void:
	_collision_shape = $CollisionShape2D
	z_as_relative = false
	z_index = int(global_position.y)
	set_collision_layer_value(Layers.WORLD, false)
	set_collision_mask_value(Layers.CAT, true)
	body_entered.connect(_on_body_entered)
	GameManager.fish_updated.connect(_on_fish_updated)

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

func _on_fish_updated(current: int, total: int) -> void:
	_is_open = total > 0 and current >= total
	queue_redraw()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("cat"):
		GameManager.try_complete_level()

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
	var width_near := SHADOW_HW
	var width_far := SHADOW_HW * 0.35
	var alpha := clampf(0.26 - absf(far_x - near_x) * 0.0015, 0.08, 0.26)
	var pts := PackedVector2Array([
		Vector2(near_x - width_near, shadow_y), Vector2(near_x + width_near, shadow_y),
		Vector2(far_x + width_far, shadow_y + 4), Vector2(far_x - width_far, shadow_y + 4),
	])
	draw_colored_polygon(pts, Color(0.0, 0.0, 0.0, alpha))

func _draw() -> void:
	_draw_floor_shadow()
	var foot_y := _get_collision_bottom()

	var door_col: Color
	var door_dark: Color
	var trim_col: Color
	var panel_col: Color

	if _is_open:
		door_col = Color(0.18, 0.55, 0.2)
		door_dark = Color(0.1, 0.38, 0.12)
		trim_col = Color(0.3, 0.75, 0.35)
		panel_col = Color(0.22, 0.62, 0.25)
	else:
		door_col = Color(0.42, 0.28, 0.12)
		door_dark = Color(0.3, 0.18, 0.06)
		trim_col = Color(0.55, 0.4, 0.18)
		panel_col = Color(0.48, 0.32, 0.14)

	# Door frame
	draw_rect(Rect2(-19, foot_y - 56, 38, 56), trim_col)

	# Door body
	draw_rect(Rect2(-16, foot_y - 54, 32, 54), door_col)

	# Panel insets (two panels)
	# Top panel
	draw_rect(Rect2(-12, foot_y - 50, 24, 18), panel_col)
	draw_rect(Rect2(-12, foot_y - 50, 24, 18), door_dark, false, 1.0)
	# Bottom panel
	draw_rect(Rect2(-12, foot_y - 26, 24, 18), panel_col)
	draw_rect(Rect2(-12, foot_y - 26, 24, 18), door_dark, false, 1.0)

	# Frame outline
	draw_rect(Rect2(-19, foot_y - 56, 38, 56), door_dark, false, 1.5)

	# Hinges
	draw_rect(Rect2(-16, foot_y - 48, 3, 6), Color(0.4, 0.35, 0.25))
	draw_rect(Rect2(-16, foot_y - 18, 3, 6), Color(0.4, 0.35, 0.25))

	# Knob plate
	draw_circle(Vector2(9, foot_y - 24), 5, door_dark)
	# Knob
	draw_circle(Vector2(9, foot_y - 24), 3, Color(0.85, 0.7, 0.15))
	draw_circle(Vector2(9, foot_y - 24), 3, Color(0.95, 0.85, 0.4), false, 0.8)
	# Keyhole
	if not _is_open:
		draw_circle(Vector2(9, foot_y - 20), 1.2, Color(0.15, 0.1, 0.05))

	# Lock indicator glow for locked state
	if not _is_open:
		draw_circle(Vector2(0, foot_y - 32), 4, Color(0.8, 0.15, 0.15, 0.3))
		draw_circle(Vector2(0, foot_y - 32), 2.5, Color(0.9, 0.2, 0.2))
	else:
		# Open indicator — green glow
		draw_circle(Vector2(0, foot_y - 32), 4, Color(0.2, 0.9, 0.2, 0.3))
		draw_circle(Vector2(0, foot_y - 32), 2.5, Color(0.3, 1.0, 0.3))
