extends Node2D
class_name WaterDish
## Holds a few sips of water. Click it to refill.

@export var max_sips : int = 5
@export var sip_amount : float = 50.0
var sips : int = 0

func _ready() -> void:
	sips = max_sips

func has_water() -> bool:
	return sips > 0

## Takes one sip; returns how much thirst it quenches (0 if empty).
func drink() -> float:
	if sips <= 0:
		return 0.0
	sips -= 1
	queue_redraw()
	return sip_amount

func refill() -> void:
	sips = max_sips
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(-7, -4, 14, 8), Color(0.55, 0.55, 0.6))
	var fill := float(sips) / max_sips
	if fill > 0.0:
		var width := 12.0 * fill
		draw_rect(Rect2(-width / 2.0, -3, width, 6), Color(0.3, 0.6, 1.0))
