extends UtilityAction
class_name WanderAction
## Fallback: amble somewhere nearby, then linger a moment, when nothing else is pressing.

@export var base_score : float = 0.15
@export var pause_min : float = 2.0   ## seconds to linger after arriving
@export var pause_max : float = 4.0
var _pause_left : float = 0.0

func score() -> float:
	return base_score

func enter() -> void:
	_pause_left = randf_range(pause_min, pause_max)
	creature.movement.wander_from(creature.global_position)

func run(delta: float) -> bool:
	if creature.movement.has_target:
		return false
	_pause_left -= delta
	return _pause_left <= 0.0
