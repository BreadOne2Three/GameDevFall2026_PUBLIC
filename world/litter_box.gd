extends Node2D
class_name LitterBox
## Where well-trained creatures go to the bathroom.

func _draw() -> void:
	for y in 2:
		for x in 2:
			Tiles.draw(self, Tiles.GRATE, Vector2(x * 8 - 8, y * 8 - 8), Color(0.95, 0.85, 0.6))
