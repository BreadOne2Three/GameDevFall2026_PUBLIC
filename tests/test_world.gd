extends TestCase

const MAIN := preload("res://main.tscn")

func _world() -> World:
	return add(MAIN.instantiate()) as World

func test_starts_with_just_a_pair_of_slimes() -> void:
	var world := _world()
	var counts := world.counts()
	assert_eq(counts["Slime"], 2)
	assert_eq(counts["Bat"], 0)
	assert_eq(counts["Dog"], 0)
	assert_eq(counts["Human"], 0)

func test_baby_inherits_species_and_starts_small() -> void:
	var world := _world()
	var slimes := world.get_tree().get_nodes_in_group("creatures").filter(func(c): return c.species == "Slime")
	var baby := world.spawn_baby(slimes[0], slimes[1])
	assert_eq(baby.species, "Slime")
	assert_false(baby.is_adult)
	assert_near(baby.growth, 0.5)
	assert_eq(world.counts()["Slime"], 3)

func test_population_cap() -> void:
	var world := _world()
	while world.population() < World.MAX_POPULATION:
		world.spawn_creature("Slime", Vector2(100, 100))
	var slimes := world.get_tree().get_nodes_in_group("creatures").filter(func(c): return c.species == "Slime")
	assert_eq(world.spawn_baby(slimes[0], slimes[1]), null)

func test_reintroduce_only_when_extinct() -> void:
	var world := _world()
	assert_true(world.reintroduce("Bat"))
	assert_eq(world.counts()["Bat"], 2)
	assert_false(world.reintroduce("Bat"))
	assert_false(world.reintroduce("Slime"))
	for c in world.get_tree().get_nodes_in_group("creatures"):
		if c.species == "Slime":
			c.die()
	assert_true(world.is_extinct("Slime"))
	assert_true(world.reintroduce("Slime"))

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

func test_lake_never_runs_out() -> void:
	var lake : Node2D = add(load("res://world/lake.tscn").instantiate())
	for i in 100:
		assert_near(lake.drink(), lake.sip_amount)
	assert_true(lake.has_water())

func test_lake_shore_point_faces_the_creature() -> void:
	var lake : Node2D = add(load("res://world/lake.tscn").instantiate())
	lake.position = Vector2(100, 100)
	var shore : Vector2 = lake.shore_point(Vector2(200, 100))
	assert_near(shore.x, 100 + lake.radius.x, 0.01)
	assert_near(shore.y, 100.0, 0.01)
	assert_true(lake.contains(Vector2(105, 102)))
	assert_false(lake.contains(Vector2(200, 100)))

func test_creature_at_picks_nearest_within_radius() -> void:
	var world := _world()
	var c : Creature = world.get_tree().get_nodes_in_group("creatures")[0]
	assert_eq(world.creature_at(c.global_position + Vector2(3, 0)), c)
	assert_eq(world.creature_at(Vector2(-100, -100)), null)
