extends TestCase

func _need() -> NeedComponent:
	return track(NeedComponent.new())

func test_rises_at_rate_times_multipliers() -> void:
	var need := _need()
	need.rate = 2.0
	need.gene_multiplier = 1.5
	need.env_multiplier = 2.0
	need._process(1.0)
	assert_near(need.value, 6.0)

func test_clamps_between_0_and_100() -> void:
	var need := _need()
	need.add(150.0)
	assert_near(need.value, 100.0)
	need.satisfy(500.0)
	assert_near(need.value, 0.0)

func test_maxed_emits_once() -> void:
	var need := _need()
	var hits := [0]
	need.maxed.connect(func(): hits[0] += 1)
	need.add(150.0)
	need.add(10.0)
	assert_eq(hits[0], 1)
	assert_true(need.is_maxed)

func test_relieved_only_below_threshold() -> void:
	var need := _need()
	var hits := [0]
	need.relieved.connect(func(): hits[0] += 1)
	need.add(100.0)
	need.satisfy(10.0)   # 90: still above relief_threshold (80)
	assert_eq(hits[0], 0)
	need.satisfy(15.0)   # 75
	assert_eq(hits[0], 1)
	assert_false(need.is_maxed)

func test_ratio() -> void:
	var need := _need()
	need.add(25.0)
	assert_near(need.ratio(), 0.25)
