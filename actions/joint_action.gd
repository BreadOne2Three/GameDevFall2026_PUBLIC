extends UtilityAction
class_name JointAction
## An action two creatures do together (play, talk, breed).
## The initiator picks a partner and invites them via the partner's brain
## (BrainComponent.request_joint). If they accept, both run this action together.

const CONTACT := 10.0   ## how close the pair must be before the activity starts

@export var duration : float = 3.0
@export var search_radius : float = 100.0
@export var refused_cooldown : float = 5.0     ## wait this long after being turned down
@export var requires_contact : bool = true     ## walk up to the partner before starting

var partner : Creature = null
var invited : bool = false                     ## true on the creature that was asked
var _candidate : Creature = null
var _time_left : float = 0.0

func score() -> float:
	_candidate = find_partner()
	if _candidate == null:
		return 0.0
	return need_score()

func find_partner() -> Creature:
	return creature.nearest_in_group("creatures", search_radius, is_valid_partner)

## Subclasses narrow this (e.g. breeding needs the same species).
func is_valid_partner(other: Creature) -> bool:
	return other.state == Creature.State.NORMAL

## Called by the partner's brain when accepting an invitation.
func join(initiator: Creature) -> void:
	partner = initiator
	invited = true

func enter() -> void:
	_time_left = duration
	if invited:
		return
	partner = _candidate
	if partner == null or not partner.brain.request_joint(name, creature):
		partner = null
		cooldown_left = refused_cooldown

func run(delta: float) -> bool:
	if not _partner_still_with_us():
		return true
	if requires_contact and creature.global_position.distance_to(partner.global_position) > CONTACT:
		if invited:
			creature.movement.stop()   # wait for them to come over
		else:
			creature.movement.move_to(partner.global_position)
		return false
	_time_left -= delta
	together(delta)
	if _time_left <= 0.0:
		finish_together()
		return true
	return false

func exit() -> void:
	partner = null
	invited = false
	creature.movement.stop()

func is_committed() -> bool:
	return partner != null

## Every frame while together. Override.
func together(_delta: float) -> void:
	pass

## Once, when the activity completes successfully. Override.
func finish_together() -> void:
	pass

func _partner_still_with_us() -> bool:
	if partner == null or not is_instance_valid(partner) or partner.is_dead:
		return false
	if partner.state != Creature.State.NORMAL:
		return false
	return partner.brain.current_action_name() == String(name)
