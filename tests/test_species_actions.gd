extends TestCase

const DOG := preload("res://entities/dog.tscn")
const BAT := preload("res://entities/bat.tscn")
const SLIME := preload("res://entities/slime.tscn")
const DROPPING := preload("res://world/dropping.tscn")
const FOOD := preload("res://world/food.tscn")

func _spawn(scene: PackedScene, pos: Vector2) -> Node2D:
	var node : Node2D = scene.instantiate()
	node.position = pos
	return add(node)

func _human(pos: Vector2) -> Creature:
	return _spawn(load("res://entities/human.tscn"), pos)

func test_hunt_only_when_starving_and_prey_nearby() -> void:
	var dog : Creature = _spawn(DOG, Vector2(100, 100))
	var slime : Creature = _spawn(SLIME, Vector2(140, 100))
	var hunt := dog.brain.get_action("HuntAction")
	assert_near(hunt.score(), 0.0)
	dog.need("Hunger").add(100.0)
	assert_near(hunt.score(), 0.95)
	slime.grab()
	assert_near(hunt.score(), 0.0, 0.001, "held prey is safe")

func test_hunt_ends_when_prey_dies() -> void:
	var dog : Creature = _spawn(DOG, Vector2(100, 100))
	var slime : Creature = _spawn(SLIME, Vector2(140, 100))
	dog.need("Hunger").add(100.0)
	var hunt := dog.brain.get_action("HuntAction")
	hunt.score()
	slime.free()
	assert_true(hunt.run(0.1))

func test_kill_feeds_the_hunter() -> void:
	var dog : Creature = _spawn(DOG, Vector2(100, 100))
	var slime : Creature = _spawn(SLIME, Vector2(103, 100))
	slime.health = 1
	dog.need("Hunger").add(100.0)
	var hunt := dog.brain.get_action("HuntAction")
	hunt.score()
	hunt.enter()
	assert_true(hunt.run(0.1))
	assert_true(slime.is_dead)
	assert_near(dog.need("Hunger").value, 40.0)

func test_dogs_do_not_hunt_dogs() -> void:
	var dog : Creature = _spawn(DOG, Vector2(100, 100))
	_spawn(DOG, Vector2(110, 100))
	dog.need("Hunger").add(100.0)
	assert_near(dog.brain.get_action("HuntAction").score(), 0.0)

func test_bat_drain_feeds_hunger_and_thirst() -> void:
	var bat : Creature = _spawn(BAT, Vector2(100, 100))
	var dog : Creature = _spawn(DOG, Vector2(103, 100))
	bat.need("Hunger").add(100.0)
	bat.need("Thirst").add(50.0)
	var drain := bat.brain.get_action("DrainAction")
	assert_near(drain.score(), 0.95)
	drain.enter()
	var dog_health := dog.health
	drain.run(0.1)
	assert_eq(dog.health, dog_health - 1)
	assert_near(bat.need("Hunger").value, 85.0)
	assert_near(bat.need("Thirst").value, 35.0)

func test_starving_slime_scavenges_droppings() -> void:
	var slime : Creature = _spawn(SLIME, Vector2(100, 100))
	var drop := _spawn(DROPPING, Vector2(102, 100))
	var scavenge := slime.brain.get_action("ScavengeAction")
	assert_near(scavenge.score(), 0.0)
	slime.need("Hunger").add(100.0)
	assert_near(scavenge.score(), 0.9)
	assert_true(scavenge.run(0.1))
	assert_true(drop.is_queued_for_deletion())

func test_human_calms_aggroed_dog() -> void:
	var human := _human(Vector2(100, 100))
	var dog : Creature = _spawn(DOG, Vector2(103, 100))
	var calm := human.brain.get_action("CalmAction")
	assert_near(calm.score(), 0.0)
	dog.need("Hunger").add(100.0)
	assert_near(calm.score(), 0.7)
	assert_true(calm.run(0.1))
	assert_false(dog.is_aggroed())

func test_food_after_begging_is_worth_double() -> void:
	var human := _human(Vector2(100, 100))
	human.need("Hunger").add(100.0)
	var beg := human.brain.get_action("BegAction")
	assert_near(beg.score(), 0.9)
	beg.run(0.1)
	var food := _spawn(FOOD, Vector2(102, 100))
	human.eat(food)
	assert_near(human.need("Hunger").value, 20.0)
