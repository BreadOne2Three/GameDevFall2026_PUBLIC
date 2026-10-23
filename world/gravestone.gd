extends Node2D
class_name Gravestone
## Marks where a creature died. Fades away; starving slimes scavenge it.

@export var nutrition : float = 50.0
@export var lifetime : float = 30.0
var _time_left : float = 0.0

func _ready() -> void:
	_time_left = lifetime

func _process(delta: float) -> void:
	_time_left -= delta
	modulate.a = clampf(_time_left / lifetime, 0.0, 1.0)
	if _time_left <= 0.0:
		queue_free()

func _draw() -> void:
	draw_rect(Rect2(-3, -4, 6, 8), Color(0.6, 0.6, 0.65))
	draw_circle(Vector2(0, -4), 3.0, Color(0.6, 0.6, 0.65))
	draw_line(Vector2(0, -5), Vector2(0, -1), Color(0.35, 0.35, 0.4))
	draw_line(Vector2(-1.5, -3.5), Vector2(1.5, -3.5), Color(0.35, 0.35, 0.4))
