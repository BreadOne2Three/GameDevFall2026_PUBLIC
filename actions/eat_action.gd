extends UtilityAction
class_name EatAction
## Walk to the nearest food pellet and eat it.

var food : Node2D

func score() -> float:
	food = creature.nearest_in_group("food")
	if food == null:
		return 0.0
	return need_score()

func run(_delta: float) -> bool:
	if not is_instance_valid(food) or food.is_queued_for_deletion():
		return true
	if walk_to(food.global_position):
		creature.eat(food)
		return true
	return false
