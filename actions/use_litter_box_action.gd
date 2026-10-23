extends UtilityAction
class_name UseLitterBoxAction
## Walk to the litter box first. Starts slightly disfavored (see LearningComponent.initial_biases);
## rewarding it, or punishing GoHereAction, makes creatures choose it on their own.

var box : Node2D

func score() -> float:
	box = creature.nearest_in_group("litter_box")
	if box == null:
		return 0.0
	return need_score()

func run(_delta: float) -> bool:
	if not is_instance_valid(box):
		return true
	if walk_to(box.global_position):
		creature.relieve(false)
		creature.emote("~")
		return true
	return false
