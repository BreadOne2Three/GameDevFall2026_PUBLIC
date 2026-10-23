extends Node2D
class_name Dropping
## Left behind by creatures that aren't potty trained. Click to clean. Starving slimes eat these.

@export var nutrition : float = 10.0

func _draw() -> void:
	Tiles.draw(self, Tiles.DROPPING, Vector2(-4, -4), Color(0.85, 0.62, 0.4))
