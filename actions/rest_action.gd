extends UtilityAction
class_name RestAction
## Lie down and recover energy. Once asleep, only urgent survival needs wake it up.

@export var recovery_rate : float = 8.0
var _resting : bool = false

func enter() -> void:
	_resting = true
	creature.movement.stop()

func run(delta: float) -> bool:
	creature.need("Energy").satisfy(recovery_rate * delta)
	creature.emote("Zz", 0.3)
	return creature.need("Energy").value <= 0.0

func exit() -> void:
	_resting = false

func is_committed() -> bool:
	return _resting
