extends UtilityAction
class_name BegAction
## Starving humans follow your cursor, begging. Food they eat soon after is worth double.

@export var beg_score : float = 0.9

func score() -> float:
	return beg_score if creature.is_starving else 0.0

func run(_delta: float) -> bool:
	if not creature.is_starving:
		return true
	(creature as Human).last_begged_at = creature.age
	creature.emote("!", 0.3)
	walk_to(creature.get_global_mouse_position())
	return false
