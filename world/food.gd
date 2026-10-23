extends Node2D
class_name Food
## A berry dropped by the god-hand. Eaten whole.

@export var nutrition : float = 40.0

func _draw() -> void:
	Tiles.draw(self, Tiles.FOOD, Vector2(-4, -4))
