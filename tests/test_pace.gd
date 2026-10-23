extends TestCase
## The terrarium should be calm enough to follow what's happening (playtest feedback).

const SPEEDS := {"bat": 35.0, "dog": 20.0, "slime": 15.0, "human": 15.0}

func test_creatures_walk_slowly() -> void:
	for species in SPEEDS:
		var c : Creature = add(load("res://entities/%s.tscn" % species).instantiate())
		assert_near(c.move_speed, SPEEDS[species], 0.001, species)

func test_needs_rise_slowly() -> void:
	var c : Creature = add(load("res://entities/slime.tscn").instantiate())
	assert_near(c.need("Hunger").rate, 0.5, 0.001, "about 3 minutes to starve")
	assert_near(c.need("Thirst").rate, 0.7)
	assert_near(c.need("Bladder").rate, 0.6)

func test_population_stays_small() -> void:
	assert_eq(World.MAX_POPULATION, 12)
	var c : Creature = add(load("res://entities/slime.tscn").instantiate())
	assert_near(c.brain.get_action("BreedAction").breed_cooldown, 120.0)

func test_new_arrivals_settle_in_before_breeding() -> void:
	var c : Creature = add(load("res://entities/slime.tscn").instantiate())
	var breed := c.brain.get_action("BreedAction")
	assert_near(breed.cooldown_left, breed.breed_cooldown)
