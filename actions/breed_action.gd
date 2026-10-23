extends JointAction
class_name BreedAction
## Two happy, well-fed adults of the same species have a baby (World.spawn_baby).

@export var breed_score : float = 0.6
@export var breed_cooldown : float = 120.0

## Newcomers (founders, babies, reintroduced pairs) settle in before their first baby.
func _ready() -> void:
	cooldown_left = breed_cooldown

func score() -> float:
	if not creature.can_breed() or _world_full():
		return 0.0
	_candidate = find_partner()
	return breed_score if _candidate else 0.0

func is_valid_partner(other: Creature) -> bool:
	if other.species != creature.species or not other.can_breed():
		return false
	var their_breed := other.brain.get_action(name)
	return their_breed != null and their_breed.cooldown_left <= 0.0

func accepts_invite(_initiator: Creature) -> bool:
	return creature.can_breed()

func together(_delta: float) -> void:
	creature.movement.stop()
	creature.emote("<3", 0.5)

func finish_together() -> void:
	cooldown_left = breed_cooldown
	if invited:
		return
	# The partner may end its action a frame later without finishing, so cool it down too.
	var theirs := partner.brain.get_action(name)
	if theirs:
		theirs.cooldown_left = breed_cooldown
	creature.bred.emit(creature, partner)

## Looked up through the "world" group (not the World class) to avoid a preload cycle:
## world.gd preloads the creature scenes, which contain this action.
func _world_full() -> bool:
	var world = creature.get_tree().get_first_node_in_group("world")
	return world != null and world.population() >= world.MAX_POPULATION
