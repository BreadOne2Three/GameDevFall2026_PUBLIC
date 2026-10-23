@tool
extends Creature
class_name Bat
## Starving bats speed up (×1.25) and drain other creatures' blood (DrainAction).

func make_sound() -> void:
	print(creature_name, "squeak squeak")

func starving_speed_multiplier() -> float:
	return 1.25

func can_get_aggressive() -> bool:
	return true
