extends Node2D
class_name World
## The terrarium's laws of nature: keeps track of creatures and spawns babies,
## droppings and gravestones in response to creature signals.

const MAX_POPULATION := 30
const MAX_FOOD := 15
const PICK_RADIUS := 8.0
const OBJECT_PICK_RADIUS := 7.0
const SPECIES : Array[String] = ["Bat", "Dog", "Slime", "Human"]
const SPECIES_SCENES := {
	"Bat": preload("res://entities/bat.tscn"),
	"Dog": preload("res://entities/dog.tscn"),
	"Slime": preload("res://entities/slime.tscn"),
	"Human": preload("res://entities/human.tscn"),
}
const FOOD_SCENE := preload("res://world/food.tscn")
const DROPPING_SCENE := preload("res://world/dropping.tscn")
const GRAVESTONE_SCENE := preload("res://world/gravestone.tscn")

@onready var creatures : Node2D = $Creatures
@onready var objects : Node2D = $Objects

func _ready() -> void:
	for c in creatures.get_children():
		register(c)

func register(c: Creature) -> void:
	c.died.connect(_on_creature_died)
	c.pooped.connect(_on_creature_pooped)
	c.bred.connect(_on_creature_bred)

func spawn_creature(species: String, pos: Vector2, genome: Genome = null, baby: bool = false) -> Creature:
	var c : Creature = SPECIES_SCENES[species].instantiate()
	c.position = Terrarium.clamp_to_walk_area(pos)
	c.genome = genome
	c.is_baby = baby
	creatures.add_child(c)
	register(c)
	return c

## Two parents make a baby that blends their genes and half of what they learned.
func spawn_baby(a: Creature, b: Creature) -> Creature:
	if population() >= MAX_POPULATION:
		return null
	var pos := (a.global_position + b.global_position) / 2.0
	var baby := spawn_creature(a.species, pos, Genome.inherit(a.genome, b.genome), true)
	baby.learning.inherit_from(a.learning, b.learning)
	return baby

func population() -> int:
	var total := 0
	for c in get_tree().get_nodes_in_group("creatures"):
		if not c.is_dead:
			total += 1
	return total

func counts() -> Dictionary:
	var result := {}
	for species in SPECIES:
		result[species] = 0
	for c in get_tree().get_nodes_in_group("creatures"):
		if not c.is_dead and result.has(c.species):
			result[c.species] += 1
	return result

func is_extinct(species: String) -> bool:
	return counts().get(species, 0) == 0

## Spawning is minimal: you can only bring back a species that died out, as a breeding pair.
func reintroduce(species: String) -> bool:
	if not SPECIES_SCENES.has(species) or not is_extinct(species):
		return false
	for i in 2:
		spawn_creature(species, Terrarium.random_point())
	return true

func drop_food(pos: Vector2) -> Node2D:
	if get_tree().get_nodes_in_group("food").size() >= MAX_FOOD:
		return null
	return spawn_object(FOOD_SCENE, pos)

func spawn_object(scene: PackedScene, pos: Vector2) -> Node2D:
	var obj : Node2D = scene.instantiate()
	obj.position = Terrarium.clamp_to_walk_area(pos)
	objects.add_child(obj)
	return obj

func creature_at(pos: Vector2, radius: float = PICK_RADIUS) -> Creature:
	var best : Creature = null
	var best_dist := radius
	for c in get_tree().get_nodes_in_group("creatures"):
		if c.is_dead:
			continue
		var dist : float = pos.distance_to(c.global_position)
		if dist <= best_dist:
			best_dist = dist
			best = c
	return best

func object_at(pos: Vector2, group: StringName, radius: float = OBJECT_PICK_RADIUS) -> Node2D:
	var best : Node2D = null
	var best_dist := radius
	for obj in get_tree().get_nodes_in_group(group):
		if obj.is_queued_for_deletion():
			continue
		var dist : float = pos.distance_to(obj.global_position)
		if dist <= best_dist:
			best_dist = dist
			best = obj
	return best

func _on_creature_died(c: Creature) -> void:
	spawn_object(GRAVESTONE_SCENE, c.global_position)

func _on_creature_pooped(at: Vector2) -> void:
	spawn_object(DROPPING_SCENE, at)

func _on_creature_bred(a: Creature, b: Creature) -> void:
	spawn_baby(a, b)
