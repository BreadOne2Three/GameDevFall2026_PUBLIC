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

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.14, 0.18, 0.22))   # outside the glass
	draw_rect(INNER_RECT, Color(0.36, 0.27, 0.18))                   # soil
	var rng := RandomNumberGenerator.new()
	rng.seed = 7   # same speckles every run
	for i in 160:
		var speck := Vector2(rng.randf_range(INNER_RECT.position.x, INNER_RECT.end.x - 1), rng.randf_range(INNER_RECT.position.y, INNER_RECT.end.y - 1))
		draw_rect(Rect2(speck, Vector2.ONE), Color(0.29, 0.21, 0.13))
	draw_rect(INNER_RECT, Color(0.7, 0.9, 1.0, 0.6), false, 1.0)      # glass edge
