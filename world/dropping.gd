extends Node2D
class_name Dropping
## Left behind by creatures that aren't potty trained. Click to clean. Starving slimes eat these.

@export var nutrition : float = 10.0

func _draw() -> void:
	draw_circle(Vector2(0, 1), 2.0, Color(0.35, 0.22, 0.1))
	draw_circle(Vector2(0, -0.5), 1.3, Color(0.4, 0.26, 0.12))
