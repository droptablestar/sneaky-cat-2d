extends CharacterBody2D

enum State { PATROL, ALERT, CHASE }

# Override these in subclasses to tune each enemy type
@export var move_speed: float = 80.0
@export var patrol_distance: float = 120.0
@export var detection_range: float = 200.0

var state: State = State.PATROL
var patrol_origin: Vector2
var patrol_direction: float = 1.0  # 1 = right, -1 = left

const GRAVITY = 900.0

var raycast: RayCast2D

func _ready() -> void:
	patrol_origin = global_position
	set_collision_layer_value(Layers.WORLD, false)
	set_collision_layer_value(Layers.ENEMY, true)
	set_collision_mask_value(Layers.WORLD, true)
	# Build raycast in code to avoid @onready issues with inherited scripts
	raycast = RayCast2D.new()
	raycast.enabled = true
	raycast.collision_mask = (1 << (Layers.CAT - 1)) | (1 << (Layers.PLATFORM - 1))
	add_child(raycast)
	_setup_catch_zone()

func _setup_catch_zone() -> void:
	var zone := Area2D.new()
	zone.collision_mask = 1 << (Layers.CAT - 1)
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 18.0
	shape.shape = circle
	zone.add_child(shape)
	zone.body_entered.connect(_on_catch_zone_entered)
	add_child(zone)

func _on_catch_zone_entered(body: Node) -> void:
	if body.is_in_group("cat") and not body.get("is_hidden"):
		GameManager.catch_player()

func _physics_process(delta: float) -> void:
	_apply_gravity(delta)

	match state:
		State.PATROL:
			_patrol(delta)
			_check_detection()
		State.ALERT:
			_on_alert()
		State.CHASE:
			_chase(delta)

	move_and_slide()
	queue_redraw()

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

func _patrol(_delta: float) -> void:
	velocity.x = move_speed * patrol_direction

	var dist_from_origin = global_position.x - patrol_origin.x
	var past_boundary = abs(dist_from_origin) >= patrol_distance
	var moving_away = sign(dist_from_origin) == sign(patrol_direction)

	if (past_boundary and moving_away) or is_on_wall():
		patrol_direction *= -1
		$Sprite2D.flip_h = patrol_direction < 0

func _check_detection() -> void:
	if raycast == null:
		return
	raycast.target_position = Vector2(detection_range * patrol_direction, 0)
	raycast.force_raycast_update()

	if raycast.is_colliding():
		var hit = raycast.get_collider()
		if hit and hit.is_in_group("cat") and not hit.get("is_hidden"):
			_on_detect(hit)

func _on_detect(_target: Node) -> void:
	state = State.ALERT

# Override in subclasses for different alert/chase behaviors
func _on_alert() -> void:
	state = State.CHASE

func _chase(_delta: float) -> void:
	pass
