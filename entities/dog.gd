@tool
extends Creature
class_name Dog
## Starving dogs speed up (×1.5) and hunt smaller creatures (HuntAction).

func starving_speed_multiplier() -> float:
	return 1.5

func can_get_aggressive() -> bool:
	return true
