extends Node2D
class_name LitterBox
## Where well-trained creatures go to the bathroom.

func _draw() -> void:
	draw_rect(Rect2(-9, -7, 18, 14), Color(0.45, 0.3, 0.2))
	draw_rect(Rect2(-8, -6, 16, 12), Color(0.85, 0.78, 0.55))
