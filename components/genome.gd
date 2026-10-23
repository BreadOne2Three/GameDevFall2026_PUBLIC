extends RefCounted
class_name Genome
## Inheritable traits. Every creature has one; babies blend their parents' genomes
## with a little random mutation, so traits drift over generations (natural selection!).
## Trade-offs: fast creatures tire faster, big ones are tougher but hungrier,
## low metabolism is hardy but sluggish.

const SPEED_RANGE := Vector2(0.7, 1.4)
const SIZE_RANGE := Vector2(0.8, 1.3)
const METABOLISM_RANGE := Vector2(0.7, 1.3)
const MUTATION := 0.05       ## std-dev of random change per generation
const HUE_MUTATION := 0.03   ## std-dev of hue change per generation (slime colors)

var speed : float = 1.0
var size : float = 1.0
var metabolism : float = 1.0
var color : Color = Color.WHITE

## A starting creature placed in the scene: traits close to 1.0.
static func random_founder(founder_color: Color) -> Genome:
	var g := Genome.new()
	g.speed = 1.0 + randf_range(-0.1, 0.1)
	g.size = 1.0 + randf_range(-0.1, 0.1)
	g.metabolism = 1.0 + randf_range(-0.1, 0.1)
	g.color = founder_color
	return g

## A baby's genome: each trait lands somewhere between the parents, plus mutation.
static func inherit(a: Genome, b: Genome) -> Genome:
	var g := Genome.new()
	g.speed = _blend(a.speed, b.speed, SPEED_RANGE)
	g.size = _blend(a.size, b.size, SIZE_RANGE)
	g.metabolism = _blend(a.metabolism, b.metabolism, METABOLISM_RANGE)
	var mixed := a.color.lerp(b.color, randf())
	g.color = Color.from_hsv(fposmod(mixed.h + randfn(0.0, HUE_MUTATION), 1.0), mixed.s, mixed.v)
	return g

static func _blend(x: float, y: float, bounds: Vector2) -> float:
	return clampf(lerpf(x, y, randf()) + randfn(0.0, MUTATION), bounds.x, bounds.y)

## All need rates are multiplied by this: big and fast-metabolism creatures get needy sooner.
func need_multiplier() -> float:
	return size * metabolism

## Energy drains faster for fast creatures too.
func energy_multiplier() -> float:
	return need_multiplier() * speed

func speed_multiplier() -> float:
	return speed * (0.85 + 0.15 * metabolism)

func health_multiplier() -> float:
	return size
