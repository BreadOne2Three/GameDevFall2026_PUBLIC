extends UtilityAction
class_name CalmAction
## Humans walk over to aggressive creatures and soothe them, pausing their aggression.

@export var search_radius : float = 80.0
@export var calm_score : float = 0.7
var target : Creature

func score() -> float:
	target = creature.nearest_in_group("creatures", search_radius, func(c): return c.is_aggroed())
	return calm_score if target else 0.0

func run(_delta: float) -> bool:
	if not is_instance_valid(target) or target.is_dead or not target.is_aggroed():
		return true
	if walk_to(target.global_position):
		target.calm()
		return true
	return false
