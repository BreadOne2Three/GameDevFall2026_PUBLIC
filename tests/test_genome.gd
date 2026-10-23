extends TestCase

func _genome(speed: float, size: float, metabolism: float, color: Color) -> Genome:
	var g := Genome.new()
	g.speed = speed
	g.size = size
	g.metabolism = metabolism
	g.color = color
	return g

func test_founder_traits_near_one() -> void:
	seed(1)
	for i in 50:
		var g := Genome.random_founder(Color.RED)
		assert_true(g.speed >= 0.9 and g.speed <= 1.1)
		assert_true(g.size >= 0.9 and g.size <= 1.1)
		assert_true(g.metabolism >= 0.9 and g.metabolism <= 1.1)
		assert_eq(g.color, Color.RED)

func test_inherited_traits_stay_in_range() -> void:
	seed(2)
	var a := _genome(Genome.SPEED_RANGE.x, Genome.SIZE_RANGE.x, Genome.METABOLISM_RANGE.x, Color.RED)
	var b := _genome(Genome.SPEED_RANGE.y, Genome.SIZE_RANGE.y, Genome.METABOLISM_RANGE.y, Color.BLUE)
	for i in 200:
		var child := Genome.inherit(a, b)
		assert_true(child.speed >= Genome.SPEED_RANGE.x and child.speed <= Genome.SPEED_RANGE.y)
		assert_true(child.size >= Genome.SIZE_RANGE.x and child.size <= Genome.SIZE_RANGE.y)
		assert_true(child.metabolism >= Genome.METABOLISM_RANGE.x and child.metabolism <= Genome.METABOLISM_RANGE.y)

func test_child_traits_land_between_parents_plus_small_mutation() -> void:
	seed(3)
	var a := _genome(0.8, 1.0, 1.0, Color.RED)
	var b := _genome(1.2, 1.0, 1.0, Color.RED)
	for i in 200:
		var child := Genome.inherit(a, b)
		assert_true(child.speed > 0.8 - 0.25 and child.speed < 1.2 + 0.25, "speed %s" % child.speed)

func test_color_hue_drifts_only_slightly_from_identical_parents() -> void:
	seed(4)
	var parent_color := Color.from_hsv(0.3, 0.8, 0.8)
	var a := _genome(1, 1, 1, parent_color)
	var b := _genome(1, 1, 1, parent_color)
	for i in 100:
		var child := Genome.inherit(a, b)
		var hue_diff := absf(child.color.h - 0.3)
		assert_true(minf(hue_diff, 1.0 - hue_diff) < 0.15, "hue %s" % child.color.h)
		assert_near(child.color.s, 0.8, 0.01)

func test_multipliers() -> void:
	var g := _genome(1.2, 1.1, 0.9, Color.WHITE)
	assert_near(g.need_multiplier(), 1.1 * 0.9)
	assert_near(g.energy_multiplier(), 1.1 * 0.9 * 1.2)
	assert_near(g.speed_multiplier(), 1.2 * (0.85 + 0.15 * 0.9))
	assert_near(g.health_multiplier(), 1.1)
