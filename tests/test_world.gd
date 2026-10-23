extends TestCase

const MAIN := preload("res://main.tscn")

func _world() -> World:
	return add(MAIN.instantiate()) as World

func test_starts_with_a_pair_of_each_species() -> void:
	var world := _world()
	var counts := world.counts()
	assert_eq(counts["Bat"], 2)
	assert_eq(counts["Dog"], 2)
	assert_eq(counts["Slime"], 2)

func test_baby_inherits_species_and_starts_small() -> void:
	var world := _world()
	var dogs := world.get_tree().get_nodes_in_group("creatures").filter(func(c): return c.species == "Dog")
	var baby := world.spawn_baby(dogs[0], dogs[1])
	assert_eq(baby.species, "Dog")
	assert_false(baby.is_adult)
	assert_near(baby.growth, 0.5)
	assert_eq(world.counts()["Dog"], 3)

func test_population_cap() -> void:
	var world := _world()
	while world.population() < World.MAX_POPULATION:
		world.spawn_creature("Slime", Vector2(100, 100))
	var slimes := world.get_tree().get_nodes_in_group("creatures").filter(func(c): return c.species == "Slime")
	assert_eq(world.spawn_baby(slimes[0], slimes[1]), null)

func test_reintroduce_only_when_extinct() -> void:
	var world := _world()
	assert_false(world.reintroduce("Bat"))
	for c in world.get_tree().get_nodes_in_group("creatures"):
		if c.species == "Bat":
			c.die()
	assert_true(world.is_extinct("Bat"))
	assert_true(world.reintroduce("Bat"))
	assert_eq(world.counts()["Bat"], 2)

func test_death_leaves_gravestone_and_poop_leaves_dropping() -> void:
	var world := _world()
	var c : Creature = world.get_tree().get_nodes_in_group("creatures")[0]
	var stones_before := world.get_tree().get_nodes_in_group("gravestone").size()
	c.relieve(true)
	assert_true(world.object_at(c.global_position, "dropping") != null)
	c.die()
	assert_eq(world.get_tree().get_nodes_in_group("gravestone").size(), stones_before + 1)

func test_drop_food_is_clamped_inside_glass_and_capped() -> void:
	var world := _world()
	var food := world.drop_food(Vector2(-40, 400))
	assert_eq(food.global_position, Vector2(12, 308))
	for i in 30:
		world.drop_food(Vector2(100, 100))
	assert_eq(world.get_tree().get_nodes_in_group("food").size(), World.MAX_FOOD)

func test_water_dish_sips_and_refill() -> void:
	var dish : WaterDish = add(preload("res://world/water_dish.tscn").instantiate())
	for i in dish.max_sips:
		assert_near(dish.drink(), dish.sip_amount)
	assert_false(dish.has_water())
	assert_near(dish.drink(), 0.0)
	dish.refill()
	assert_true(dish.has_water())

func test_creature_at_picks_nearest_within_radius() -> void:
	var world := _world()
	var c : Creature = world.get_tree().get_nodes_in_group("creatures")[0]
	assert_eq(world.creature_at(c.global_position + Vector2(3, 0)), c)
	assert_eq(world.creature_at(Vector2(-100, -100)), null)
