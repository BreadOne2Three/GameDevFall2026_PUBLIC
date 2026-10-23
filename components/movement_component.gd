extends Node
class_name MovementComponent
## Where the creature is walking to. Actions set the target; Creature steers toward it.

signal destination_reached

@export var wander_radius : float = 50.0
@export var arrival_threshold : float = 4.0

var target : Vector2
var has_target : bool = false

func wander_from(pos: Vector2) -> void:
	var offset : Vector2 = Vector2(randf_range(-wander_radius, wander_radius), randf_range(-wander_radius, wander_radius))
	move_to(pos + offset)

## Walk toward pos (kept inside the terrarium glass).
func move_to(pos: Vector2) -> void:
	target = Terrarium.clamp_to_walk_area(pos)
	has_target = true

func stop() -> void:
	has_target = false

func check_arrival(current_pos: Vector2) -> bool:
	if has_target and current_pos.distance_to(target) < arrival_threshold:
		has_target = false
		destination_reached.emit()
		return true
	return false
