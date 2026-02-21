extends CharacterBody2D

enum State { IDLE, RUNNING, JUMPING, HIDING }

const SPEED = 180.0
const JUMP_VELOCITY = -380.0
const GRAVITY = 900.0

var state: State = State.IDLE
var is_hidden: bool = false

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
