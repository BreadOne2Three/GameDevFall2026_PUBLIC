extends UtilityAction
class_name DrainAction
## Starving bats latch onto another creature and drink its blood,
## easing both hunger and thirst. Rarely kills, but weakens the victim.

@export var search_radius : float = 120.0
@export var drains : int = 3
@export var drain_interval : float = 1.0
@export var drain_damage : int = 1
@export var nutrition : float = 15.0
@export var drain_score : float = 0.95
var victim : Creature
var _drains_left : int = 0
var _drain_timer : float = 0.0

func _init() -> void:
	is_survival = true
	need_name = "Hunger"

func score() -> float:
	if not creature.is_aggroed():
		return 0.0
	victim = creature.nearest_in_group("creatures", search_radius, is_victim)
	return drain_score if victim else 0.0

func is_victim(other: Creature) -> bool:
	return other.species != creature.species and other.state != Creature.State.HELD

func enter() -> void:
	_drains_left = drains
	_drain_timer = 0.0
	creature.emote("!")

func run(delta: float) -> bool:
	if not is_instance_valid(victim) or victim.is_dead or victim.state == Creature.State.HELD:
		return true
	if not creature.is_aggroed():
		return true
	if not walk_to(victim.global_position):
		return false
	_drain_timer -= delta
	if _drain_timer <= 0.0:
		_drain_timer = drain_interval
		victim.take_damage(drain_damage)
		creature.need("Hunger").satisfy(nutrition)
		creature.need("Thirst").satisfy(nutrition)
		_drains_left -= 1
	return _drains_left <= 0 or victim.is_dead
