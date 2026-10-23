extends TestCase

const DOG := preload("res://entities/dog.tscn")
const SLIME := preload("res://entities/slime.tscn")

func _spawn(scene: PackedScene, pos: Vector2) -> Creature:
	var c : Creature = scene.instantiate()
	c.position = pos
	return add(c) as Creature

func _content(c: Creature) -> void:
	for n in ["Hunger", "Thirst", "Energy", "Fun", "Social", "Bladder"]:
		c.need(n).satisfy(100.0)
	c.brain.get_action("BreedAction").cooldown_left = 0.0   # skip the settling-in period

func test_communicate_invites_partner_who_switches_too() -> void:
	var a := _spawn(DOG, Vector2(100, 100))
	var b := _spawn(SLIME, Vector2(110, 100))
	a.need("Social").add(90.0)
	b.need("Social").add(50.0)
	var talk := a.brain.get_action("CommunicateAction")
	assert_true(talk.score() > 0.0)
	a.brain.switch_to(talk)
	assert_eq(b.brain.current_action_name(), "CommunicateAction")
	assert_eq(talk.partner, b)

func test_partner_refuses_when_need_is_low_and_initiator_cools_down() -> void:
	var a := _spawn(DOG, Vector2(100, 100))
	var b := _spawn(SLIME, Vector2(110, 100))
	a.need("Social").add(90.0)
	var talk := a.brain.get_action("CommunicateAction")
	talk.score()
	a.brain.switch_to(talk)
	assert_eq(talk.partner, null)
	assert_true(talk.cooldown_left > 0.0)
	assert_eq(b.brain.current_action_name(), "")

func test_joint_action_ends_when_partner_is_grabbed() -> void:
	var a := _spawn(DOG, Vector2(100, 100))
	var b := _spawn(SLIME, Vector2(105, 100))
	a.need("Fun").add(90.0)
	b.need("Fun").add(60.0)
	var play := a.brain.get_action("PlayAction")
	play.score()
	a.brain.switch_to(play)
	b.grab()
	assert_true(play.run(0.1))

func test_joint_action_ends_when_partner_dies() -> void:
	var a := _spawn(DOG, Vector2(100, 100))
	var b := _spawn(SLIME, Vector2(105, 100))
	a.need("Fun").add(90.0)
	b.need("Fun").add(60.0)
	var play := a.brain.get_action("PlayAction")
	play.score()
	a.brain.switch_to(play)
	b.free()
	assert_true(play.run(0.1))

func test_breed_requires_two_content_adults_of_same_species() -> void:
	var a := _spawn(DOG, Vector2(100, 100))
	var b := _spawn(DOG, Vector2(110, 100))
	var s := _spawn(SLIME, Vector2(105, 100))
	_content(a); _content(b); _content(s)
	var breed := a.brain.get_action("BreedAction")
	assert_true(breed.score() > 0.0)
	assert_eq(breed.find_partner(), b)
	b.need("Hunger").add(60.0)
	assert_near(breed.score(), 0.0, 0.001, "hungry partner can't breed")

func _breed_pair(invited_ticks_first: bool) -> Array:
	var a := _spawn(DOG, Vector2(100, 100))
	var b := _spawn(DOG, Vector2(105, 100))
	_content(a); _content(b)
	var births := [0]
	a.bred.connect(func(_x, _y): births[0] += 1)
	b.bred.connect(func(_x, _y): births[0] += 1)
	var breed := a.brain.get_action("BreedAction")
	breed.score()
	a.brain.switch_to(breed)
	for i in 30:
		if invited_ticks_first:
			b.brain.tick(0.1)
			a.brain.tick(0.1)
		else:
			a.brain.tick(0.1)
			b.brain.tick(0.1)
	return [births[0], breed.cooldown_left, b.brain.get_action("BreedAction").cooldown_left]

func test_breeding_emits_bred_once_and_sets_cooldowns() -> void:
	var result := _breed_pair(false)
	assert_eq(result[0], 1)
	assert_true(result[1] > 0.0)
	assert_true(result[2] > 0.0)

func test_breeding_completes_when_partner_ticks_first() -> void:
	var result := _breed_pair(true)
	assert_eq(result[0], 1)
	assert_true(result[1] > 0.0)
	assert_true(result[2] > 0.0)

func test_babies_cannot_breed() -> void:
	var a := _spawn(DOG, Vector2(100, 100))
	var baby : Creature = DOG.instantiate()
	baby.is_baby = true
	baby.position = Vector2(105, 100)
	add(baby)
	_content(a); _content(baby)
	assert_false(baby.can_breed())
	assert_eq(a.brain.get_action("BreedAction").find_partner(), null)
