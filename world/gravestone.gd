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
	Tiles.draw(self, Tiles.GRAVE, Vector2(-4, -4))
