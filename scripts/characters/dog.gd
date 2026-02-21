extends "res://scripts/characters/enemy_base.gd"

# Dogs: fast, short range, aggressive chase
func _ready() -> void:
	super._ready()
	move_speed = 140.0
	detection_range = 120.0
	patrol_distance = 100.0
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

var chase_target: Node = null

func _draw() -> void:
	draw_rect(Rect2(-14, -24, 28, 24), Color(0.6, 0.4, 0.2))
	# snout
	draw_rect(Rect2(10, -14, 10, 8), Color(0.7, 0.5, 0.3))

	if state == State.ALERT or state == State.CHASE:
		# bubble background
		draw_circle(Vector2(0, -38), 12, Color(1.0, 1.0, 1.0))
		# ! body
		draw_rect(Rect2(-2.5, -47, 5, 12), Color(0.1, 0.1, 0.1))
		# ! dot
		draw_rect(Rect2(-2.5, -32, 5, 5), Color(0.1, 0.1, 0.1))

func _on_detect(target: Node) -> void:
	chase_target = target
	super._on_detect(target)

func _chase(_delta: float) -> void:
	if chase_target == null:
		state = State.PATROL
		return

	if chase_target.get("is_hidden"):
		state = State.PATROL
		chase_target = null
		return

	var dir = sign(chase_target.global_position.x - global_position.x)
	velocity.x = move_speed * dir
	$Sprite2D.flip_h = dir < 0
