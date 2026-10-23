extends JointAction
class_name CommunicateAction
## Walk up to someone and have a little chat. Friends of the same species count more.

const EMOTES : Array[String] = ["<3", "!", "?", "~"]

@export var social_per_second : float = 15.0
@export var same_species_bonus : float = 1.5
var _emote_timer : float = 0.0

func together(delta: float) -> void:
	creature.movement.stop()
	var amount := social_per_second * delta
	if partner.species == creature.species:
		amount *= same_species_bonus
	creature.need("Social").satisfy(amount)
	_emote_timer -= delta
	if _emote_timer <= 0.0:
		_emote_timer = 2.0
		creature.emote(EMOTES.pick_random(), 1.0)
