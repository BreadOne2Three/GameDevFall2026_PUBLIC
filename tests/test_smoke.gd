extends TestCase
## Runs the whole terrarium for 60 game-seconds at 4× speed, throwing one creature
## into a wall along the way. run.sh fails the suite if any SCRIPT ERROR is printed.

const MAIN := preload("res://main.tscn")

func test_terrarium_runs_for_a_minute() -> void:
	var world : World = add(MAIN.instantiate())
	Engine.time_scale = 4.0
	var thrown : Creature = world.get_tree().get_nodes_in_group("creatures")[0]
	thrown.throw(Vector2(500, 0))
	for i in 900:   # 900 frames × 1/60 s × 4 = 60 s
		await tree.physics_frame
	Engine.time_scale = 1.0
	assert_true(world.population() > 0)
	var acted := 0
	for c in world.get_tree().get_nodes_in_group("creatures"):
		if c.brain.current_action_name() != "" or c.state != Creature.State.NORMAL:
			acted += 1
	assert_true(acted > 0, "creatures should be doing things")
