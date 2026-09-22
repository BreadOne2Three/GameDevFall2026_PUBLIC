@tool
extends Creature
class_name Bat

func make_sound() -> void:
	print(creature_name, "squeak squeak")

func move_toward_point(target_pos: Vector2, delta : float) -> void:
	global_position = global_position.move_toward(target_pos, move_speed * delta)
