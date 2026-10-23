extends UtilityAction
class_name DrinkAction
## Walk to the nearest water dish that still has water and take a sip.

var dish : WaterDish

func score() -> float:
	dish = creature.nearest_in_group("water", INF, func(d): return d.has_water())
	if dish == null:
		return 0.0
	return need_score()

func run(_delta: float) -> bool:
	if not is_instance_valid(dish) or not dish.has_water():
		return true
	if walk_to(dish.global_position):
		creature.need("Thirst").satisfy(dish.drink())
		creature.emote("~")
		return true
	return false
