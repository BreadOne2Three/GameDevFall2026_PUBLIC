extends UtilityAction
class_name ScavengeAction
## Starving slimes ooze over to droppings and gravestones and eat them.
## A hungry slime cleans the tank for you.

@export var scavenge_score : float = 0.9
var target : Node2D

func _init() -> void:
	is_survival = true
	need_name = "Hunger"

func score() -> float:
	if not creature.is_starving:
		return 0.0
	target = _nearest_scrap()
	return scavenge_score if target else 0.0

func run(_delta: float) -> bool:
	if not is_instance_valid(target) or target.is_queued_for_deletion():
		return true
	if walk_to(target.global_position):
		creature.eat(target)
		return true
	return false

func _nearest_scrap() -> Node2D:
	var dropping := creature.nearest_in_group("dropping")
	var grave := creature.nearest_in_group("gravestone")
	if dropping == null:
		return grave
	if grave == null:
		return dropping
	var pos : Vector2 = creature.global_position
	return dropping if pos.distance_to(dropping.global_position) < pos.distance_to(grave.global_position) else grave
