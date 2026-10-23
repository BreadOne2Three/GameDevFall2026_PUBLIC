extends Node2D
class_name Lake
## A permanent pond built from water tiles. It never runs dry;
## thirsty creatures walk to the nearest bit of shore.

@export var size_in_tiles : Vector2i = Vector2i(6, 4)
@export var sip_amount : float = 50.0

func has_water() -> bool:
	return true

## Takes one sip; returns how much thirst it quenches.
func drink() -> float:
	return sip_amount

func half_size() -> Vector2:
	return Vector2(size_in_tiles * Tiles.SIZE) / 2.0

func rect() -> Rect2:
	return Rect2(global_position - half_size(), half_size() * 2.0)

## Is pos on (or in) the water?
func contains(pos: Vector2) -> bool:
	return rect().has_point(pos)

## The point on the shore closest to `from`.
func shore_point(from: Vector2) -> Vector2:
	var r := rect()
	var p := from.clamp(r.position, r.end)
	if not contains(from):
		return p
	# Already in the water: step out through the nearest edge.
	var to_edge := [p.x - r.position.x, r.end.x - p.x, p.y - r.position.y, r.end.y - p.y]
	match to_edge.find(to_edge.min()):
		0: return Vector2(r.position.x, p.y)
		1: return Vector2(r.end.x, p.y)
		2: return Vector2(p.x, r.position.y)
		_: return Vector2(p.x, r.end.y)

func _draw() -> void:
	var top_left := -half_size()
	for y in size_in_tiles.y:
		for x in size_in_tiles.x:
			var col := 0 if x == 0 else (2 if x == size_in_tiles.x - 1 else 1)
			var row := 0 if y == 0 else (2 if y == size_in_tiles.y - 1 else 1)
			Tiles.draw(self, Tiles.WATER[row * 3 + col], top_left + Vector2(x, y) * Tiles.SIZE)
