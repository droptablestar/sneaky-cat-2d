extends CharacterBody2D

enum State { IDLE, RUNNING, JUMPING, HIDING }

@export var speed: float = 180.0
@export var jump_velocity: float = -460.0
@export var gravity: float = 900.0

var state: State = State.IDLE
var is_hidden: bool = false

const SHADOW_HW: float = 10.0
const SHADOW_HEIGHT: float = 36.0

func _ready() -> void:
	add_to_group("cat")
	set_collision_layer_value(Layers.WORLD, false)
	set_collision_layer_value(Layers.CAT, true)
	set_collision_mask_value(Layers.WORLD, true)
	set_collision_mask_value(Layers.PLATFORM, true)

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement()
	move_and_slide()
	_update_state()
	queue_redraw()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func _handle_movement() -> void:
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0:
		velocity.x = direction * speed
		$Sprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

func _update_state() -> void:
	if is_hidden:
		state = State.HIDING
	elif not is_on_floor():
		state = State.JUMPING
	elif abs(velocity.x) > 0:
		state = State.RUNNING
	else:
		state = State.IDLE

func set_hidden(value: bool) -> void:
	is_hidden = value
	queue_redraw()

func _draw_floor_shadow() -> void:
	for lp: Vector2 in GameManager.LIGHT_POSITIONS:
		var dx: float = global_position.x - lp.x
		var dy: float = lp.y - global_position.y
		var slen: float = clampf(dx * SHADOW_HEIGHT / maxf(abs(dy), 80.0), -22.0, 22.0)
		var alpha: float = clampf(0.16 - absf(slen) * 0.003, 0.04, 0.16)
		if not is_on_floor():
			alpha *= 0.3
		var pts := PackedVector2Array([
			Vector2(-SHADOW_HW, 0), Vector2(SHADOW_HW, 0),
			Vector2(slen + SHADOW_HW * 0.5, 4), Vector2(slen - SHADOW_HW * 0.5, 4),
		])
		draw_colored_polygon(pts, Color(0.0, 0.0, 0.0, alpha))

func _draw() -> void:
	_draw_floor_shadow()
	var color = Color(1.0, 0.55, 0.0) if not is_hidden else Color(1.0, 0.55, 0.0, 0.3)
	draw_rect(Rect2(-12, -28, 24, 28), color)
	# ears
	draw_rect(Rect2(-12, -36, 8, 10), color)
	draw_rect(Rect2(4, -36, 8, 10), color)
