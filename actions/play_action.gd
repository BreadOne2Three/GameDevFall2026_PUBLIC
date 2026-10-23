extends JointAction
class_name PlayAction
## Tag! The initiator chases, the partner runs away. Both have fun.

@export var fun_per_second : float = 12.0

func enter() -> void:
	super.enter()
	if partner:
		creature.emote("!")

func together(delta: float) -> void:
	creature.need("Fun").satisfy(fun_per_second * delta)
	if invited:
		var away := (creature.global_position - partner.global_position).normalized()
		creature.movement.move_to(creature.global_position + away * 20.0)
	else:
		creature.movement.move_to(partner.global_position)
