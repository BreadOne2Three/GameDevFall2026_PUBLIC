@tool
extends Creature
class_name Human
## The terrarium's peacekeeper: slower and tougher, calms aggressive creatures (CalmAction),
## and begs the god-hand for food when starving (BegAction).

const BEG_BONUS_WINDOW := 3.0   ## food eaten this soon after begging is worth double
const WALK_FPS := 8.0

var last_begged_at : float = -INF

func starving_speed_multiplier() -> float:
	return 1.0

func eat(food: Node2D, multiplier: float = 1.0) -> void:
	if age - last_begged_at < BEG_BONUS_WINDOW:
		multiplier *= 2.0
	super.eat(food, multiplier)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if Engine.is_editor_hint():
		return
	creature_sprite.frame = int(age * WALK_FPS) % 4 if velocity.length() > 1.0 else 0
