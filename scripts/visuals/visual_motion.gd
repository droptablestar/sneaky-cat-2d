class_name VisualMotion
extends RefCounted


static func time_seconds() -> float:
	return Time.get_ticks_msec() * 0.001


static func speed_ratio(speed: float, max_speed: float) -> float:
	return clampf(speed / maxf(1.0, max_speed), 0.0, 1.0)


static func idle_bob(t: float, amplitude: float = 1.0, frequency: float = 1.5) -> float:
	return sin(t * TAU * frequency) * amplitude


static func run_swing(
	t: float, speed01: float, amplitude: float = 2.0, frequency: float = 7.0
) -> float:
	return sin(t * TAU * frequency) * amplitude * speed01


static func pulse01(t: float, frequency: float = 2.0) -> float:
	return 0.5 + 0.5 * sin(t * TAU * frequency)
