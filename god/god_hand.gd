extends Node2D
class_name GodHand
## The player's hand. Drag to grab and throw, double-click to pet, right-click to flick
## (or drop food on empty ground), click droppings to clean and dishes to refill.

const DRAG_START_DISTANCE := 3.0   ## px the mouse must move while pressed before it's a grab
const VELOCITY_WINDOW := 0.1       ## seconds of mouse movement used for throw velocity
const MIN_VELOCITY_TIME := 0.05    ## never measure over less time than this, so a tiny twitch isn't a throw
const SPEEDS : Array[float] = [1.0, 2.0, 4.0]
const REINTRODUCE_KEYS := {KEY_1: "Bat", KEY_2: "Dog", KEY_3: "Slime", KEY_4: "Human"}

@onready var world : World = get_parent()

var held : Creature = null
var _pressed_creature : Creature = null
var _press_pos : Vector2
var _pressing : bool = false
var _samples : Array = []   ## [[time, position]], oldest first
var _speed_index : int = 0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		_on_key(event.keycode)
		return
	var pos := get_global_mouse_position()
	# Letting go of the button always counts, even while paused, so nothing stays stuck to the cursor.
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		release_at(pos)
		return
	if get_tree().paused:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			press(pos, event.double_click)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			right_click(pos)
	elif event is InputEventMouseMotion:
		move(pos)

func press(pos: Vector2, double_click: bool = false) -> void:
	var c := world.creature_at(pos)
	if double_click and c:
		c.pet()
		_pressing = false
		return
	_pressing = true
	_pressed_creature = c
	_press_pos = pos
	_samples.clear()

func move(pos: Vector2) -> void:
	if held == null and _pressing and is_instance_valid(_pressed_creature) \
			and pos.distance_to(_press_pos) > DRAG_START_DISTANCE:
		held = _pressed_creature
		held.grab()
	if held:
		if not is_instance_valid(held) or held.is_dead:
			held = null
			return
		held.global_position = Terrarium.clamp_to_walk_area(pos)
		add_sample(held.global_position, _now())

func release_at(pos: Vector2) -> void:
	if held:
		if is_instance_valid(held) and not held.is_dead:
			held.release(release_velocity(_now()))
		held = null
	elif _pressing and _pressed_creature == null:
		_click_ground(pos)
	_pressing = false
	_pressed_creature = null

func right_click(pos: Vector2) -> void:
	if held:
		return
	var c := world.creature_at(pos)
	if c:
		c.flick(pos)
	else:
		world.drop_food(pos)

func add_sample(pos: Vector2, time: float) -> void:
	_samples.append([time, pos])
	_prune(time)

## Mouse velocity over the last VELOCITY_WINDOW seconds. Zero if the mouse has been still.
func release_velocity(now: float) -> Vector2:
	_prune(now)
	if _samples.size() < 2:
		return Vector2.ZERO
	var first : Array = _samples[0]
	var last : Array = _samples[-1]
	var dt : float = last[0] - first[0]
	return (last[1] - first[1]) / maxf(dt, MIN_VELOCITY_TIME)

func cycle_speed() -> void:
	_speed_index = (_speed_index + 1) % SPEEDS.size()
	Engine.time_scale = SPEEDS[_speed_index]

func toggle_pause() -> void:
	get_tree().paused = not get_tree().paused

func _click_ground(pos: Vector2) -> void:
	var dropping := world.object_at(pos, "dropping")
	if dropping:
		dropping.queue_free()
		return
	var dish := world.object_at(pos, "water")
	if dish:
		dish.refill()

func _on_key(keycode: Key) -> void:
	if keycode == KEY_SPACE:
		toggle_pause()
	elif keycode == KEY_TAB:
		cycle_speed()
	elif REINTRODUCE_KEYS.has(keycode):
		world.reintroduce(REINTRODUCE_KEYS[keycode])

func _prune(now: float) -> void:
	while not _samples.is_empty() and now - float(_samples[0][0]) > VELOCITY_WINDOW:
		_samples.pop_front()

func _now() -> float:
	return Time.get_ticks_msec() / 1000.0
