extends UtilityAction
class_name WanderAction
## Fallback: amble somewhere nearby when nothing else is pressing.

@export var base_score : float = 0.15

func score() -> float:
	return base_score

func enter() -> void:
	creature.movement.wander_from(creature.global_position)

func run(_delta: float) -> bool:
	return not creature.movement.has_target
