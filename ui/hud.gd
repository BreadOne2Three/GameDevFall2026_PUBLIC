extends Control
class_name HUD
## Heads-up display: population, hovered-creature info, key hints and the AI debug overlay.
## Everything is drawn in _draw() so it stays crisp in the 320×320 window.

const FONT_SIZE := 8
const LINE := 9
const BAR_WIDTH := 40.0
# Colors taken from the tile sheet so the HUD matches the art.
const PANEL := Color(0.133, 0.137, 0.137, 0.85)
const TEXT := Color("f4f4f4")
const DIM := Color("c0c0d0")
const ACCENT := Color("f8c858")
const RED := Color("e2574c")
const ORANGE := Color("f0a058")
const BAR_BACK := Color("4c4c50")
const NEED_NAMES : Array[String] = ["Hunger", "Thirst", "Energy", "Fun", "Social", "Bladder"]
const HINTS : Array[String] = [
	"drag: throw   2x click: pet   R-click: flick/food",
	"click poop: clean   Space: pause   Tab: speed",
	"1-4: add bat/dog/slime/human   D: debug   H: hints",
]

var show_hints : bool = false
var show_debug : bool = false
var world : World
var font : Font

func _ready() -> void:
	font = ThemeDB.fallback_font
	world = get_tree().get_first_node_in_group("world")

func _process(_delta: float) -> void:
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_H:
			toggle_hints()
		elif event.keycode == KEY_D:
			toggle_debug()

func toggle_hints() -> void:
	show_hints = not show_hints

func toggle_debug() -> void:
	show_debug = not show_debug

func describe_action(c: Creature) -> String:
	if c.state == Creature.State.HELD:
		return "Held"
	if c.state == Creature.State.THROWN:
		return "Flying"
	var action_name := c.brain.current_action_name()
	return action_name.trim_suffix("Action") if action_name != "" else "Idle"

func _draw() -> void:
	if world == null:
		return
	if show_debug:
		for c in get_tree().get_nodes_in_group("creatures"):
			if not c.is_dead:
				_text(c.global_position + Vector2(-14, 12), describe_action(c), ACCENT)
	_draw_population()
	var hovered := world.creature_at(get_global_mouse_position(), 10.0)
	if hovered:
		_draw_creature_panel(hovered)
	if show_hints:
		_draw_hints()
	else:
		_pill(Vector2(282, 317), "H: help", DIM)

func _draw_population() -> void:
	var counts := world.counts()
	var parts := PackedStringArray()
	for species in counts:
		parts.append("%s %d" % [species, counts[species]])
	_pill(Vector2(3, 8), "  ".join(parts))
	var status := "PAUSED" if get_tree().paused else "x%d" % int(Engine.time_scale)
	_pill(Vector2(317 - _width(status), 8), status, ACCENT)

func _draw_creature_panel(c: Creature) -> void:
	var rows := 11 + (8 if show_debug else 0)
	var origin := Vector2(2, 13)
	draw_rect(Rect2(origin, Vector2(116, rows * LINE + 4)), PANEL)
	var y := origin.y + 8.0
	var title := c.creature_name + ("  (baby)" if not c.is_adult else "")
	_text(Vector2(4, y), title, c.creature_color.lightened(0.3)); y += LINE
	_text(Vector2(4, y), "doing: " + describe_action(c)); y += LINE
	_bar(y, "HP", float(c.health) / c.max_health, RED); y += LINE
	for need_name in NEED_NAMES:
		_bar(y, need_name.substr(0, 3), c.need(need_name).ratio(), ORANGE); y += LINE
	_text(Vector2(4, y), "mood %.2f" % c.mood()); y += LINE
	var g := c.genome
	_text(Vector2(4, y), "spd %.2f size %.2f met %.2f" % [g.speed, g.size, g.metabolism]); y += LINE
	if show_debug:
		_text(Vector2(4, y), "top scores:", ACCENT); y += LINE
		for entry in _top(c.brain.last_scores, 3):
			_text(Vector2(8, y), "%s %.2f" % entry); y += LINE
		_text(Vector2(4, y), "learned:", ACCENT); y += LINE
		for entry in _top(c.learning.biases, 3, true):
			_text(Vector2(8, y), "%s %+.2f" % entry); y += LINE

func _bar(y: float, label: String, fill: float, color: Color) -> void:
	_text(Vector2(4, y), label)
	var rect := Rect2(28, y - 6, BAR_WIDTH, 5)
	draw_rect(rect, BAR_BACK)
	draw_rect(Rect2(rect.position, Vector2(BAR_WIDTH * clampf(fill, 0.0, 1.0), 5)), color)

func _draw_hints() -> void:
	var top := 320.0 - HINTS.size() * LINE - 3
	draw_rect(Rect2(0, top, 320, 320 - top), PANEL)
	for i in HINTS.size():
		_text(Vector2(2, top + 8 + i * LINE), HINTS[i], DIM)

## The `count` largest entries as [short_name, value] pairs (by absolute value if by_magnitude).
func _top(values: Dictionary, count: int, by_magnitude: bool = false) -> Array:
	var keys := values.keys()
	keys.sort_custom(func(a, b):
		var va : float = absf(values[a]) if by_magnitude else values[a]
		var vb : float = absf(values[b]) if by_magnitude else values[b]
		return va > vb)
	var result := []
	for key in keys.slice(0, count):
		result.append([String(key).trim_suffix("Action"), values[key]])
	return result

## Text on a small dark panel just big enough for it (so the walls stay visible).
func _pill(pos: Vector2, text: String, color: Color = TEXT) -> void:
	draw_rect(Rect2(pos + Vector2(-2, -7), Vector2(_width(text) + 4, 9)), PANEL)
	_text(pos, text, color)

func _width(text: String) -> float:
	return font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE).x

func _text(pos: Vector2, text: String, color: Color = TEXT) -> void:
	draw_string(font, pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, FONT_SIZE, color)
