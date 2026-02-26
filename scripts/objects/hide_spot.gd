extends Area2D

enum FurnitureType { SHELF, COUCH, TABLE, BOOKCASE }

const PLATFORM_TOP_OFFSET: float = -30.0

@export var is_platform: bool = false
@export var furniture_type: FurnitureType = FurnitureType.SHELF

var _bodies_in_zone: Array = []

@onready var platform: StaticBody2D = $Platform


func _ready() -> void:
	z_as_relative = false
	z_index = int(global_position.y)
	set_collision_mask_value(Layers.CAT, true)
	platform.set_collision_layer_value(Layers.WORLD, false)
	platform.set_collision_layer_value(Layers.PLATFORM, is_platform)
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _physics_process(_delta: float) -> void:
	for body in _bodies_in_zone:
		var should_hide: bool
		if is_platform:
			var platform_top = global_position.y + PLATFORM_TOP_OFFSET
			should_hide = body.global_position.y <= platform_top + 2.0
		else:
			should_hide = true
		if body.get("is_hidden") != should_hide:
			body.set_hidden(should_hide)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("cat"):
		_bodies_in_zone.append(body)


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("cat"):
		_bodies_in_zone.erase(body)
		body.set_hidden(false)
