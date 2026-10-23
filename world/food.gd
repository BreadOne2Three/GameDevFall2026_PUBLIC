extends Node2D
class_name Food
## A food pellet dropped by the god-hand. Eaten whole.

@export var nutrition : float = 40.0

func _draw() -> void:
	draw_circle(Vector2.ZERO, 2.5, Color(0.95, 0.65, 0.2))
	draw_circle(Vector2(-0.7, -0.7), 1.0, Color(1.0, 0.85, 0.5))
