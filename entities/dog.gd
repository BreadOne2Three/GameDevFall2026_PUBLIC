@tool
extends Creature
class_name Dog

var is_aggroed : bool = false

func _on_starved() -> void:
	is_aggroed = true
	move_speed = move_speed * 1.5
