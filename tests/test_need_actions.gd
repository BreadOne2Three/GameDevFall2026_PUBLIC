extends TestCase

const DOG := preload("res://entities/dog.tscn")
const FOOD := preload("res://world/food.tscn")
const DISH := preload("res://world/water_dish.tscn")
const BOX := preload("res://world/litter_box.tscn")

func _at(scene: PackedScene, pos: Vector2) -> Node2D:
	var node : Node2D = scene.instantiate()
	node.position = pos
	return add(node)

func _dog(pos: Vector2 = Vector2(100, 100)) -> Creature:
	return _at(DOG, pos) as Creature

func test_eat_scores_zero_without_food() -> void:
	var dog := _dog()
	dog.need("Hunger").add(80.0)
	assert_near(dog.brain.get_action("EatAction").score(), 0.0)

func test_eat_scores_with_food_and_hunger() -> void:
	var dog := _dog()
	_at(FOOD, Vector2(150, 100))
	dog.need("Hunger").add(90.0)
	assert_near(dog.brain.get_action("EatAction").score(), 1.0)

func test_eating_satisfies_hunger_and_consumes_food() -> void:
	var dog := _dog()
	var food := _at(FOOD, Vector2(102, 100))
	dog.need("Hunger").add(90.0)
	var eat := dog.brain.get_action("EatAction")
	eat.score()
	assert_true(eat.run(0.016))
	assert_near(dog.need("Hunger").value, 50.0)
	assert_true(food.is_queued_for_deletion())

func test_eat_ends_cleanly_when_food_vanishes() -> void:
	var dog := _dog()
	var food := _at(FOOD, Vector2(200, 100))
	dog.need("Hunger").add(90.0)
	var eat := dog.brain.get_action("EatAction")
	eat.score()
	food.free()
	assert_true(eat.run(0.016))

func test_drink_ignores_empty_dish() -> void:
	var dog := _dog()
	var dish : WaterDish = _at(DISH, Vector2(120, 100))
	dog.need("Thirst").add(90.0)
	var drink := dog.brain.get_action("DrinkAction")
	assert_true(drink.score() > 0.0)
	for i in dish.max_sips:
		dish.drink()
	assert_near(drink.score(), 0.0)

func test_rest_is_committed_until_rested() -> void:
	var dog := _dog()
	dog.need("Energy").add(100.0)
	var rest := dog.brain.get_action("RestAction")
	rest.enter()
	assert_true(rest.is_committed())
	assert_false(rest.run(1.0))
	assert_true(rest.run(20.0))

func test_untrained_creature_goes_on_the_floor() -> void:
	var dog := _dog()
	_at(BOX, Vector2(290, 290))
	dog.need("Bladder").add(80.0)
	dog.brain.think()
	assert_eq(dog.brain.current_action_name(), "GoHereAction")

func test_potty_training_flips_the_choice() -> void:
	var dog := _dog()
	_at(BOX, Vector2(290, 290))
	dog.need("Bladder").add(80.0)
	# Simulate three times: goes on the floor, gets flicked right away.
	for i in 3:
		dog.learning.record_action("GoHereAction")
		dog.learning.reward(-1.0)
	dog.learning.record_action("")
	dog.brain.think()
	assert_eq(dog.brain.current_action_name(), "UseLitterBoxAction")

func test_go_here_leaves_dropping_and_empties_bladder() -> void:
	var dog := _dog()
	var drops := [0]
	dog.pooped.connect(func(_at): drops[0] += 1)
	dog.need("Bladder").add(70.0)
	assert_true(dog.brain.get_action("GoHereAction").run(0.016))
	assert_eq(drops[0], 1)
	assert_near(dog.need("Bladder").value, 0.0)

func test_bladder_full_forces_accident() -> void:
	var dog := _dog()
	dog.need("Bladder").add(100.0)
	assert_eq(dog.brain.current_action_name(), "GoHereAction")
