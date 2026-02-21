extends Area2D

# If true, the Platform child body is active so the cat can jump on it.
@export var is_platform: bool = false

@onready var platform: StaticBody2D = $Platform

# Platform CollisionShape2D is at y=-24 with half-height 6, so top surface is at y=-30
const PLATFORM_TOP_OFFSET = -30.0

var _bodies_in_zone: Array = []

func _ready() -> void:
	set_collision_mask_value(Layers.CAT, true)
	platform.set_collision_layer_value(Layers.WORLD, false)
	platform.set_collision_layer_value(Layers.PLATFORM, is_platform)

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(_delta: float) -> void:
	for body in _bodies_in_zone:
		var should_hide: bool
		if is_platform:
			# Only hide when cat has landed on the platform, not when jumping below it
			var platform_top = global_position.y + PLATFORM_TOP_OFFSET
			should_hide = body.global_position.y <= platform_top + 2.0
		else:
			should_hide = true
		if body.get("is_hidden") != should_hide:
			body.set_hidden(should_hide)

func _draw() -> void:
	if is_platform:
		# shelf surface
		draw_rect(Rect2(-32, -30, 64, 8), Color(0.5, 0.35, 0.15))
		# hide zone only above the platform surface (y=-56 to y=-30)
		draw_rect(Rect2(-40, -56, 80, 26), Color(0.2, 0.7, 0.2, 0.15))
		draw_rect(Rect2(-40, -56, 80, 26), Color(0.2, 0.7, 0.2, 0.6), false, 1.0)
	else:
		draw_rect(Rect2(-40, -56, 80, 80), Color(0.2, 0.7, 0.2, 0.15))
		draw_rect(Rect2(-40, -56, 80, 80), Color(0.2, 0.7, 0.2, 0.6), false, 1.0)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("cat"):
		_bodies_in_zone.append(body)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("cat"):
		_bodies_in_zone.erase(body)
		body.set_hidden(false)
