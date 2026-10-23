extends UtilityAction
class_name GoHereAction
## Go to the bathroom right where you stand, leaving a dropping.
## Potty training (pets/flicks) teaches creatures to prefer UseLitterBoxAction instead.

func enter() -> void:
	creature.movement.stop()

func run(_delta: float) -> bool:
	creature.relieve(true)
	return true
