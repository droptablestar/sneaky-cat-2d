extends CanvasLayer

@onready var fish_label: Label = $FishLabel
@onready var overlay: ColorRect = $Overlay
@onready var message_label: Label = $MessageLabel

func _ready() -> void:
	overlay.modulate.a = 0.0
	message_label.visible = false
	_update_fish_label(GameManager.fish_collected, GameManager.fish_total)
	GameManager.fish_updated.connect(_on_fish_updated)
	GameManager.player_caught.connect(_on_player_caught)
	GameManager.level_won.connect(_on_level_won)

func _on_fish_updated(current: int, total: int) -> void:
	_update_fish_label(current, total)

func _update_fish_label(current: int, total: int) -> void:
	fish_label.text = "Fish: %d / %d" % [current, total]

func _on_player_caught() -> void:
	message_label.text = "CAUGHT!"
	message_label.visible = true
	_flash(Color(0.8, 0.1, 0.1, 0.6))

func _on_level_won() -> void:
	message_label.text = "YOU WIN!"
	message_label.visible = true
	_flash(Color(0.1, 0.8, 0.1, 0.4))

func _flash(color: Color) -> void:
	overlay.color = color
	var tween := create_tween()
	tween.tween_property(overlay, "modulate:a", 1.0, 0.15)
	tween.tween_property(overlay, "modulate:a", 0.0, 1.2)
