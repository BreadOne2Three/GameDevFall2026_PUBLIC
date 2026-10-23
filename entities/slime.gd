@tool
extends Creature
class_name Slime

const SUPPORTED_COLORS : Array[Color] = [Color.ANTIQUE_WHITE, Color.SEA_GREEN, Color.NAVY_BLUE, Color.DARK_RED]

@export var selected_color : int = 0:
	set(value):
		value = posmod(value, SUPPORTED_COLORS.size())
		selected_color = value
		creature_color = SUPPORTED_COLORS[selected_color]
		


func move_toward_point(target_pos: Vector2, delta : float) -> void:
	super.move_toward_point(target_pos, delta)
	if randf() < .02:
		velocity.y -= 10

## Slimes wear their color gene, so breeding can produce brand-new colors.
func expresses_color_gene() -> bool:
	return true
