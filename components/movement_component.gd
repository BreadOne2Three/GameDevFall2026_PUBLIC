extends Node
class_name MovementComponent

signal destination_reached


@export var wander_radius : float = 50.0
@export var arrival_threshold : float = 4.0 


var target : Vector2
var has_target : bool = false

func wander_from(pos: Vector2) -> void:
	var offset :Vector2 = Vector2(randf_range(-wander_radius, wander_radius), randf_range(-wander_radius, wander_radius))
	target = pos + offset
	target.x = clamp(target.x, 0, get_window().size.x)
	target.y = clamp(target.y, 0, get_window().size.y)
	has_target = true
	
func check_arrival(current_pos: Vector2) -> void:
	if has_target and current_pos.distance_to(target) < arrival_threshold:
		has_target = false
		destination_reached.emit()
