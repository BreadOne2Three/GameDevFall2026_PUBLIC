extends UtilityAction
class_name GoHereAction
## Go to the bathroom right where you stand, leaving a dropping.
## Potty training (pets/flicks) teaches creatures to prefer UseLitterBoxAction instead.

func _init() -> void:
	need_name = "Bladder"
	ramp_start = 0.6
	ramp_end = 1.0
	max_score = 0.8

func enter() -> void:
	creature.movement.stop()

func run(_delta: float) -> bool:
	creature.relieve(true)
	return true
