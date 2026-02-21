extends CharacterBody2D

enum State { IDLE, RUNNING, JUMPING, HIDING }

const SPEED = 180.0
const JUMP_VELOCITY = -460.0
const GRAVITY = 900.0

var state: State = State.IDLE
var is_hidden: bool = false

func _ready() -> void:
	add_to_group("cat")
	# Layer 2 = cat, collides with world (1) and platforms (4)
	set_collision_layer_value(1, false)
	set_collision_layer_value(2, true)
	set_collision_mask_value(4, true)

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement()
	move_and_slide()
	_update_state()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func _handle_movement() -> void:
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * SPEED
		$Sprite2D.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

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

func _draw() -> void:
	var color = Color(1.0, 0.55, 0.0) if not is_hidden else Color(1.0, 0.55, 0.0, 0.3)
	draw_rect(Rect2(-12, -28, 24, 28), color)
	# ears
	draw_rect(Rect2(-12, -36, 8, 10), color)
	draw_rect(Rect2(4, -36, 8, 10), color)
