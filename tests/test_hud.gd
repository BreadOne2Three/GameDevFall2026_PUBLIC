extends TestCase

const MAIN := preload("res://main.tscn")

func test_hud_toggles_and_describes_actions() -> void:
	var world : World = add(MAIN.instantiate())
	var hud : Control = world.get_node("HUD/Panel")
	assert_false(hud.show_hints, "hints start hidden to keep the screen calm")
	hud.toggle_hints()
	assert_true(hud.show_hints)
	hud.toggle_debug()
	assert_true(hud.show_debug)
	var c : Creature = world.get_tree().get_nodes_in_group("creatures")[0]
	assert_eq(hud.describe_action(c), "Idle")
	c.brain.think()
	assert_eq(hud.describe_action(c), c.brain.current_action_name().trim_suffix("Action"))
	assert_true(hud.describe_action(c) != "Idle")
	c.grab()
	assert_eq(hud.describe_action(c), "Held")

func test_hud_draws_without_errors() -> void:
	var world : World = add(MAIN.instantiate())
	var hud : Control = world.get_node("HUD/Panel")
	hud.toggle_debug()
	var c : Creature = world.get_tree().get_nodes_in_group("creatures")[0]
	c.brain.think()
	c.learning.reward(1.0)
	# Draw the hover panel too (the headless mouse isn't over any creature).
	var drawn := [0]
	hud.draw.connect(func():
		hud._draw_creature_panel(c)
		drawn[0] += 1)
	for i in 5:
		await tree.process_frame
	assert_true(drawn[0] > 0)
