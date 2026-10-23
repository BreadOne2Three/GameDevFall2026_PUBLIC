extends Node2D
class_name Food
## A food pellet dropped by the god-hand. Eaten whole.

@export var nutrition : float = 40.0

func _draw() -> void:
	draw_circle(Vector2.ZERO, 2.0, Color(0.55, 0.35, 0.15))
	draw_circle(Vector2(-0.5, -0.5), 0.8, Color(0.8, 0.55, 0.3))
