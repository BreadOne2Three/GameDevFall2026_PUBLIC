extends TestCase

const MAIN := preload("res://main.tscn")

var world : World
var hand : Node2D
var creature : Creature

func _setup() -> void:
	world = add(MAIN.instantiate()) as World
	hand = world.get_node("GodHand")
	creature = world.get_tree().get_nodes_in_group("creatures")[0]

func test_drag_grabs_and_holds_inside_glass() -> void:
	_setup()
	hand.press(creature.global_position)
	assert_eq(hand.held, null, "a press alone doesn't grab")
	hand.move(creature.global_position + Vector2(5, 0))
	assert_eq(hand.held, creature)
	assert_eq(creature.state, Creature.State.HELD)
	hand.move(Vector2(-100, 500))
	assert_eq(creature.global_position, Vector2(12, 308))

func test_release_after_holding_still_is_gentle() -> void:
	_setup()
	hand.add_sample(Vector2(100, 100), 0.0)
	hand.add_sample(Vector2(160, 100), 0.05)
	assert_true(hand.release_velocity(0.05).length() > 1000.0)
	assert_eq(hand.release_velocity(1.0), Vector2.ZERO, "samples are stale")

func test_click_cleans_dropping() -> void:
	_setup()
	var drop := world.spawn_object(World.DROPPING_SCENE, Vector2(200, 50))
	hand.press(Vector2(200, 50))
	hand.release_at(Vector2(200, 50))
	assert_true(drop.is_queued_for_deletion())

func test_double_click_pets() -> void:
	_setup()
	creature.brain.think()
	var action := creature.brain.current_action_name()
	hand.press(creature.global_position, true)
	assert_true(creature.learning.bias(action) > 0.0)

func test_right_click_flicks_creature_or_drops_food() -> void:
	_setup()
	var food_before := world.get_tree().get_nodes_in_group("food").size()
	hand.right_click(Vector2(30, 30))
	assert_eq(world.get_tree().get_nodes_in_group("food").size(), food_before + 1)
	hand.right_click(creature.global_position)
	assert_eq(creature.state, Creature.State.THROWN)

func test_speed_cycles() -> void:
	_setup()
	hand.cycle_speed()
	assert_near(Engine.time_scale, 2.0)
	hand.cycle_speed()
	hand.cycle_speed()
	assert_near(Engine.time_scale, 1.0)

func test_tiny_twitch_on_release_is_not_a_throw() -> void:
	_setup()
	hand.add_sample(Vector2(100, 100), 0.95)
	hand.add_sample(Vector2(103, 100), 0.966)
	assert_true(hand.release_velocity(0.966).length() < Creature.THROW_PUNISH_SPEED)

func test_release_while_paused_lets_go() -> void:
	_setup()
	hand.press(creature.global_position)
	hand.move(creature.global_position + Vector2(5, 0))
	tree.paused = true
	var release := InputEventMouseButton.new()
	release.button_index = MOUSE_BUTTON_LEFT
	release.pressed = false
	hand._unhandled_input(release)
	tree.paused = false
	assert_eq(hand.held, null)
	assert_true(creature.state != Creature.State.HELD)
