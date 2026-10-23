extends UtilityAction
class_name DrinkAction
## Walk to the nearest shore of the lake and take a sip.

var lake : Lake

func score() -> float:
	lake = creature.nearest_in_group("water")
	if lake == null:
		return 0.0
	return need_score()

func run(_delta: float) -> bool:
	if not is_instance_valid(lake):
		return true
	var here : Vector2 = creature.global_position
	if lake.contains(here) or walk_to(lake.shore_point(here)):
		creature.movement.stop()
		creature.need("Thirst").satisfy(lake.drink())
		creature.emote("~")
		return true
	return false
