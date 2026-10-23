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

const GROUND := Color("222323")   ## the tile sheet's background color
const TILES_ACROSS := 40          ## 320 px / 8 px
## Tree spots (in tiles), kept clear of the lake, litter box and HUD bars.
const TREE_SPOTS : Array[Vector2i] = [Vector2i(2, 3), Vector2i(37, 5), Vector2i(3, 19), Vector2i(37, 24), Vector2i(24, 30)]

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, SIZE), GROUND)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7   # same decoration every run
	for i in 30:
		var spot := Vector2(rng.randi_range(2, TILES_ACROSS - 3), rng.randi_range(3, TILES_ACROSS - 6)) * Tiles.SIZE
		Tiles.draw(self, Tiles.SPROUTS if i % 3 == 0 else Tiles.SPECKLE, spot)
	for i in TREE_SPOTS.size():
		Tiles.draw(self, Tiles.TREES[i % Tiles.TREES.size()], Vector2(TREE_SPOTS[i] * Tiles.SIZE))
	_draw_walls()

## A ring of stone wall tiles along the edge (where the collision walls are).
func _draw_walls() -> void:
	var last := TILES_ACROSS - 1
	for i in range(1, last):
		Tiles.draw(self, Tiles.WALL, Vector2(i, 0) * Tiles.SIZE)
		Tiles.draw(self, Tiles.WALL, Vector2(i, last) * Tiles.SIZE)
		Tiles.draw(self, Tiles.WALL_LEFT, Vector2(0, i) * Tiles.SIZE)
		Tiles.draw(self, Tiles.WALL_RIGHT, Vector2(last, i) * Tiles.SIZE)
	Tiles.draw(self, Tiles.WALL_TOP_LEFT, Vector2.ZERO)
	Tiles.draw(self, Tiles.WALL_TOP_RIGHT, Vector2(last, 0) * Tiles.SIZE)
	Tiles.draw(self, Tiles.WALL_BOTTOM_LEFT, Vector2(0, last) * Tiles.SIZE)
	Tiles.draw(self, Tiles.WALL_BOTTOM_RIGHT, Vector2(last, last) * Tiles.SIZE)
