extends TestCase

func test_region_for_tile_index() -> void:
	assert_eq(Tiles.region(0), Rect2(0, 0, 8, 8))
	assert_eq(Tiles.region(17), Rect2(8, 8, 8, 8))
	assert_eq(Tiles.region(157), Rect2(13 * 8, 9 * 8, 8, 8))

func test_emote_shows_pack_icon_for_known_emotes() -> void:
	var c : Creature = add(load("res://entities/slime.tscn").instantiate())
	c.emote("<3")
	var icon : Sprite2D = c.get_node("EmoteIcon")
	assert_true(icon.visible)
	assert_eq(icon.region_rect, Tiles.region(Tiles.HEART))
	assert_false(c.emote_label.visible)

func test_emote_falls_back_to_text() -> void:
	var c : Creature = add(load("res://entities/slime.tscn").instantiate())
	c.emote("Zz")
	assert_true(c.emote_label.visible)
	assert_eq(c.emote_label.text, "Zz")
	assert_false(c.get_node("EmoteIcon").visible)
