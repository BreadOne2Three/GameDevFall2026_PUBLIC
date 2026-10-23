extends TestCase

const DOG := preload("res://entities/dog.tscn")
const SLIME := preload("res://entities/slime.tscn")

func _dog() -> Creature:
	return add(DOG.instantiate()) as Creature

func test_starving_applies_speed_once_and_recovers() -> void:
	var dog := _dog()
	var normal := dog.current_speed()
	dog.need("Hunger").add(100.0)
	assert_true(dog.is_starving)
	assert_near(dog.current_speed(), normal * 1.5)
	dog.need("Hunger").add(50.0)   # still maxed: no second penalty
	assert_near(dog.current_speed(), normal * 1.5)
	dog.need("Hunger").satisfy(30.0)
	assert_false(dog.is_starving)
	assert_near(dog.current_speed(), normal)

func test_health_drains_only_while_starving_or_dehydrated() -> void:
	var dog := _dog()
	var timer : Timer = dog.get_node("TimeToLive")
	assert_true(timer.is_stopped())
	dog.need("Thirst").add(100.0)
	assert_false(timer.is_stopped())
	dog.need("Thirst").satisfy(50.0)
	assert_true(timer.is_stopped())

func test_impact_damage() -> void:
	assert_eq(Creature.impact_damage(100.0), 0)
	assert_eq(Creature.impact_damage(150.0), 0)
	assert_eq(Creature.impact_damage(151.0), 1)
	assert_eq(Creature.impact_damage(260.0), 2)
	assert_eq(Creature.impact_damage(600.0), 5)

func test_death_emits_once() -> void:
	var dog := _dog()
	var deaths := [0]
	dog.died.connect(func(_c): deaths[0] += 1)
	dog.take_damage(100)
	dog.take_damage(100)
	assert_eq(deaths[0], 1)
	assert_true(dog.is_dead)

func test_fast_release_punishes_slow_release_does_not() -> void:
	var dog := _dog()
	dog.brain.think()
	var action := dog.brain.current_action_name()
	assert_eq(action, "WanderAction")
	dog.grab()
	dog.release(Vector2(20, 0))
	assert_near(dog.learning.bias(action), 0.0)
	dog.brain.think()
	dog.grab()
	dog.release(Vector2(400, 0))
	assert_true(dog.learning.bias(action) < 0.0)

func test_founder_genome_and_health() -> void:
	var dog := _dog()
	assert_true(dog.genome != null)
	assert_eq(dog.max_health, maxi(1, roundi(10 * dog.genome.size)))
	assert_eq(dog.health, dog.max_health)

func test_slime_expresses_color_gene() -> void:
	var slime := add(SLIME.instantiate()) as Creature
	assert_eq(slime.creature_color, slime.genome.color)

func test_aggro_needs_starving_and_not_calmed() -> void:
	var dog := _dog()
	assert_false(dog.is_aggroed())
	dog.need("Hunger").add(100.0)
	assert_true(dog.is_aggroed())
	dog.calm()
	assert_false(dog.is_aggroed())

func test_movement_clamps_to_walk_area() -> void:
	var dog := _dog()
	dog.movement.move_to(Vector2(-50, 500))
	assert_eq(dog.movement.target, Vector2(12, 308))
