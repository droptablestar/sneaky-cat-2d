extends CharacterBody2D

enum State { IDLE, RUNNING, JUMPING, HIDING }

@export var speed: float = 180.0
@export var jump_velocity: float = -460.0
@export var gravity: float = 900.0

var state: State = State.IDLE
var is_hidden: bool = false


func _ready() -> void:
	add_to_group("cat")
	z_as_relative = false
	set_collision_layer_value(Layers.WORLD, false)
	set_collision_layer_value(Layers.CAT, true)
	set_collision_mask_value(Layers.WORLD, true)
	set_collision_mask_value(Layers.PLATFORM, true)


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement()
	move_and_slide()
	_update_state()
	z_index = int(global_position.y)


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
