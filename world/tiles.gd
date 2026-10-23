extends RefCounted
class_name Tiles
## Kenney's Micro Roguelike sheet (CC0): 16 × 10 tiles of 8 × 8 px.
## Tile numbers count left-to-right, top-to-bottom, starting at 0.

const SHEET := preload("res://assets/micro_roguelike.png")
const SIZE := 8
const COLUMNS := 16

# Walls
const WALL_TOP_LEFT := 0
const WALL := 1
const WALL_TOP_RIGHT := 3
const WALL_LEFT := 16
const WALL_RIGHT := 19
const WALL_BOTTOM_LEFT := 64
const WALL_BOTTOM_RIGHT := 65
# Ground decoration
const SPECKLE := 68
const SPROUTS := 69
const TREES : Array[int] = [84, 85, 86]
# Water (a 3 × 3 set: corners, edges and middle)
const WATER : Array[int] = [123, 124, 125, 139, 140, 141, 155, 156, 157]
# Objects
const FOOD := 56
const DROPPING := 41
const GRATE := 61
const GRAVE := 120
# Emotes
const SPEECH := 63
const HEART := 102
const ALERT := 116
const SPARKLE := 132

static func region(index: int) -> Rect2:
	return Rect2((index % COLUMNS) * SIZE, (index / COLUMNS) * SIZE, SIZE, SIZE)

## Draws one tile onto `canvas` with its top-left corner at `pos`.
static func draw(canvas: CanvasItem, index: int, pos: Vector2, tint: Color = Color.WHITE) -> void:
	canvas.draw_texture_rect_region(SHEET, Rect2(pos, Vector2(SIZE, SIZE)), region(index), tint)
