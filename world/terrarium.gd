extends Node2D
class_name Terrarium
## The glass tank. Draws soil and glass; owns the walls creatures bounce off.

const SIZE := Vector2(320, 320)
const INNER_RECT := Rect2(8, 8, 304, 304)    ## inside of the glass
const WALK_RECT := Rect2(12, 12, 296, 296)   ## where a creature's center may be (radius ~4)

static func clamp_to_walk_area(pos: Vector2) -> Vector2:
	return pos.clamp(WALK_RECT.position, WALK_RECT.end)

static func random_point() -> Vector2:
	return Vector2(randf_range(WALK_RECT.position.x, WALK_RECT.end.x), randf_range(WALK_RECT.position.y, WALK_RECT.end.y))
