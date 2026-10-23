extends Node2D
class_name Lake
## A permanent pond. It never runs dry; thirsty creatures walk to the nearest bit of shore.

@export var radius : Vector2 = Vector2(34, 20)   ## half-width and half-height of the oval
@export var sip_amount : float = 50.0

func has_water() -> bool:
	return true

## Takes one sip; returns how much thirst it quenches.
func drink() -> float:
	return sip_amount

## Is pos on (or in) the water?
func contains(pos: Vector2) -> bool:
	var d := (pos - global_position) / radius
	return d.length() <= 1.0

## The point on the shore closest to `from` (along the line to the lake's center).
func shore_point(from: Vector2) -> Vector2:
	var d := (from - global_position) / radius
	if d.is_zero_approx():
		d = Vector2.RIGHT
	return global_position + d.normalized() * radius

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, radius.y / radius.x))
	draw_circle(Vector2.ZERO, radius.x + 2.0, Color(0.42, 0.36, 0.22))   # muddy bank
	draw_circle(Vector2.ZERO, radius.x, Color(0.2, 0.42, 0.75))
	draw_circle(Vector2(-radius.x * 0.25, -radius.x * 0.2), radius.x * 0.55, Color(0.3, 0.55, 0.88))
	draw_set_transform(Vector2.ZERO)
