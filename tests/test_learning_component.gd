extends TestCase

func _learner() -> LearningComponent:
	return add(LearningComponent.new())

func test_starts_with_initial_biases() -> void:
	var l := _learner()
	assert_near(l.bias("UseLitterBoxAction"), -0.15)
	assert_near(l.bias("WanderAction"), 0.0)

func test_current_action_gets_full_credit() -> void:
	var l := _learner()
	l.record_action("A")
	l.reward(1.0)
	assert_near(l.bias("A"), 0.15)

func test_credit_decays_with_age() -> void:
	var l := _learner()
	l.record_action("A")
	l.record_action("B")   # A ends at t = 0
	l.now = 1.5            # reward arrives 1.5 s later -> A gets half credit
	l.reward(1.0)
	assert_near(l.bias("A"), 0.075)
	assert_near(l.bias("B"), 0.15)

func test_old_actions_outside_window_get_nothing() -> void:
	var l := _learner()
	l.record_action("A")
	l.record_action("B")   # A ends at t = 0
	l.now = 4.0            # past the 3 s credit window
	l.reward(-1.0)
	assert_near(l.bias("A"), 0.0)
	assert_near(l.bias("B"), -0.15)

func test_bias_is_clamped() -> void:
	var l := _learner()
	l.record_action("A")
	for i in 20:
		l.reward(1.0)
	assert_near(l.bias("A"), LearningComponent.MAX_BIAS)

func test_history_is_bounded() -> void:
	var l := _learner()
	for i in 20:
		l.record_action("A%d" % i)
	assert_eq(l.history.size(), LearningComponent.HISTORY_SIZE)

func test_inherit_passes_on_half_of_what_parents_learned() -> void:
	var mom := _learner()
	var dad := _learner()
	var kid := _learner()
	mom.biases["UseLitterBoxAction"] = 0.25    # learned +0.4 over the -0.15 default
	dad.biases["UseLitterBoxAction"] = 0.05    # learned +0.2
	mom.biases["HuntAction"] = -0.4
	kid.inherit_from(mom, dad)
	# default + half of average learned change: -0.15 + 0.5 * (0.15 - (-0.15)) = 0.0
	assert_near(kid.bias("UseLitterBoxAction"), 0.0)
	# HuntAction: default 0, average (-0.4 + 0) / 2 = -0.2 -> half = -0.1
	assert_near(kid.bias("HuntAction"), -0.1)
