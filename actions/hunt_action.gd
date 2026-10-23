extends UtilityAction
class_name HuntAction
## Starving, aggressive creatures chase and bite prey. A kill is a big meal.
## Picking the prey up with the god-hand rescues it.

@export var search_radius : float = 120.0
@export var bite_damage : int = 1
@export var bite_interval : float = 1.0
@export var kill_nutrition : float = 60.0
@export var hunt_score : float = 0.95
var prey : Creature
var _bite_timer : float = 0.0

func score() -> float:
	if not creature.is_aggroed():
		return 0.0
	prey = creature.nearest_in_group("creatures", search_radius, is_prey)
	return hunt_score if prey else 0.0

func is_prey(other: Creature) -> bool:
	if other.species == creature.species or other.state == Creature.State.HELD:
		return false
	return other.species in creature.prey_species or not other.is_adult

func enter() -> void:
	_bite_timer = 0.0
	creature.emote("!")

func run(delta: float) -> bool:
	if not is_instance_valid(prey) or prey.is_dead or prey.state == Creature.State.HELD:
		return true
	if not creature.is_aggroed():
		return true
	if not walk_to(prey.global_position):
		return false
	_bite_timer -= delta
	if _bite_timer <= 0.0:
		_bite_timer = bite_interval
		prey.take_damage(bite_damage)
		if prey.is_dead:
			creature.need("Hunger").satisfy(kill_nutrition)
			return true
	return false
