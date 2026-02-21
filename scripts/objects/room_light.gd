extends PointLight2D

## Window light — illumination only, no engine shadow casting.
@export var light_color: Color = Color(1.0, 0.95, 0.85)
@export var light_energy: float = 0.7
@export var light_scale: float = 4.5

func _ready() -> void:
	var grad := Gradient.new()
	grad.set_color(0, Color(1.0, 1.0, 1.0, 1.0))
	grad.set_color(1, Color(1.0, 1.0, 1.0, 0.0))
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.fill = GradientTexture2D.FILL_RADIAL
	tex.fill_from = Vector2(0.5, 0.5)
	tex.fill_to = Vector2(0.5, 0.0)
	tex.width = 512
	tex.height = 512
	texture = tex
	color = light_color
	energy = light_energy
	texture_scale = light_scale
	shadow_enabled = false
