@tool
extends CharacterBody2D
class_name Creature
## Base class for everything that lives in the terrarium.
## Needs (components) rise over time, the Brain (utility AI) picks what to do about them,
## the LearningComponent remembers how the god-hand reacted, and the Genome holds inherited traits.

signal health_changed(new_value: int)
signal died(creature: Creature)
signal pooped(at: Vector2)
signal bred(parent_a: Creature, parent_b: Creature)

## NORMAL = the brain is in charge. HELD / THROWN = the god-hand is.
enum State { NORMAL, HELD, THROWN }

const FRICTION := 300.0              ## px/s² slowdown while flying
const MAX_THROW_SPEED := 600.0
const SAFE_IMPACT_SPEED := 150.0     ## wall hits slower than this don't hurt
const BOUNCE := 0.6
const THROW_PUNISH_SPEED := 100.0    ## releases faster than this count as a throw (learning −0.5)
const GROW_TIME := 60.0              ## seconds for a baby to grow up
const DIRTY_RADIUS := 24.0           ## droppings this close make the creature bored faster
const DIRTY_FUN_MULTIPLIER := 1.5
const CALM_TIME := 10.0
const BREED_HUNGER_MAX := 40.0
const BREED_THIRST_MAX := 40.0
const BREED_MOOD_MIN := 0.6

@onready var creature_sprite : Sprite2D = $Sprite2D
@onready var movement : MovementComponent = $MovementComponent
@onready var needs : Node = $Needs
@onready var brain : BrainComponent = $Brain
@onready var learning : LearningComponent = $LearningComponent
@onready var emote_label : Label = $Emote
@onready var emote_icon : Sprite2D = $EmoteIcon

@export var legs : int = 4
@export var creature_name : String = "creature"
@export var species : String = "Creature"
@export var move_speed : float = 40.0
@export var prey_species : Array[String] = []   ## who this creature hunts when starving (HuntAction)
@export var creature_color : Color = Color.ANTIQUE_WHITE:
	set(value):
		creature_color = value
		if is_node_ready():
			creature_sprite.modulate = creature_color
@export var health : int = 2:
	set(value):
		health = value
		health_changed.emit(health)
		if health <= 0 and is_inside_tree() and not Engine.is_editor_hint():
			die()

var max_health : int = 2
var state : State = State.NORMAL
var genome : Genome = null     ## World sets this before spawning a baby; founders roll their own
var is_baby : bool = false     ## World sets this before spawning a baby
var is_adult : bool = true
var growth : float = 1.0       ## 0.5 for newborns → 1.0 when grown
var is_starving : bool = false
var is_dehydrated : bool = false
var is_dead : bool = false
var age : float = 0.0          ## game-time seconds alive
var calmed_until : float = 0.0
var _emote_time : float = 0.0

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if genome == null:
		genome = Genome.random_founder(creature_color)
	if expresses_color_gene():
		creature_color = genome.color
	creature_sprite.modulate = creature_color
	if is_baby:
		is_adult = false
		growth = 0.5
	for need_node in needs.get_children():
		need_node.gene_multiplier = genome.need_multiplier()
	need("Energy").gene_multiplier = genome.energy_multiplier()
	_update_scale()
	max_health = maxi(1, roundi(health * genome.health_multiplier()))
	health = max_health
	brain.setup(self, learning)

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if _emote_time > 0.0:
		_emote_time -= delta
		if _emote_time <= 0.0:
			emote_label.visible = false
			emote_icon.visible = false

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	age += delta
	_grow(delta)
	need("Fun").env_multiplier = DIRTY_FUN_MULTIPLIER if nearest_in_group("dropping", DIRTY_RADIUS) else 1.0
	creature_sprite.rotation = sin(age * 25.0) * 0.4 if state == State.HELD else 0.0
	match state:
		State.NORMAL:
			brain.tick(delta)
			if movement.has_target:
				move_toward_point(movement.target, delta)
				movement.check_arrival(global_position)
			else:
				velocity = Vector2.ZERO
		State.THROWN:
			_fly(delta)

func move_toward_point(target_pos: Vector2, _delta : float) -> void:
	var direction := (target_pos - global_position).normalized()
	velocity = direction * current_speed()   # move_and_slide() applies delta itself
	move_and_slide()

func make_sound() -> void:
	print(creature_name, " makes a random noise")

func need(need_name: String) -> NeedComponent:
	return needs.get_node(need_name)

# --- Species hooks (override in subclasses) ---------------------------------

## Speed multiplier while starving. Base creatures (and slimes) get sluggish.
func starving_speed_multiplier() -> float:
	return 0.35

## Dogs and bats turn aggressive when starving.
func can_get_aggressive() -> bool:
	return false

## Slimes show their color gene; other species keep their scene color.
func expresses_color_gene() -> bool:
	return false

# --- State queries -----------------------------------------------------------

func current_speed() -> float:
	var speed := move_speed * genome.speed_multiplier()
	if is_starving:
		speed *= starving_speed_multiplier()
	return speed

func is_aggroed() -> bool:
	return can_get_aggressive() and is_starving and age >= calmed_until

## 1 = perfectly happy, 0 = exhausted, bored and lonely. Never lethal; gates breeding.
func mood() -> float:
	return 1.0 - (need("Energy").value + need("Fun").value + need("Social").value) / 300.0

func can_breed() -> bool:
	return is_adult and not is_dead and state == State.NORMAL \
		and need("Hunger").value < BREED_HUNGER_MAX \
		and need("Thirst").value < BREED_THIRST_MAX \
		and mood() > BREED_MOOD_MIN

## Nearest node in `group` within max_dist (skips self, the dead, and things being deleted).
func nearest_in_group(group: StringName, max_dist: float = INF, filter: Callable = Callable()) -> Node2D:
	var best : Node2D = null
	var best_dist := max_dist
	for node in get_tree().get_nodes_in_group(group):
		if node == self or node.is_queued_for_deletion():
			continue
		if node is Creature and node.is_dead:
			continue
		if filter.is_valid() and not filter.call(node):
			continue
		var dist : float = global_position.distance_to(node.global_position)
		if dist < best_dist:
			best_dist = dist
			best = node
	return best

# --- Needs -------------------------------------------------------------------

func _on_starved() -> void:
	is_starving = true
	_update_health_drain()

func _on_fed() -> void:
	is_starving = false
	_update_health_drain()

func _on_dehydrated() -> void:
	is_dehydrated = true
	_update_health_drain()

func _on_rehydrated() -> void:
	is_dehydrated = false
	_update_health_drain()

## Can't hold it any longer: an accident right here.
func _on_bladder_full() -> void:
	if state == State.NORMAL:
		brain.switch_to(brain.get_action("GoHereAction"))

func _update_health_drain() -> void:
	if is_starving or is_dehydrated:
		if $TimeToLive.is_stopped():
			$TimeToLive.start()
	else:
		$TimeToLive.stop()

func _on_time_to_live_timeout() -> void:
	take_damage(1)

func eat(food: Node2D, multiplier: float = 1.0) -> void:
	need("Hunger").satisfy(food.nutrition * multiplier)
	food.queue_free()
	emote("~")

func relieve(leave_dropping: bool) -> void:
	need("Bladder").satisfy(NeedComponent.MAX)
	if leave_dropping:
		pooped.emit(global_position)

# --- Health ------------------------------------------------------------------

func take_damage(amount: int) -> void:
	if amount <= 0 or is_dead:
		return
	health -= amount
	if not is_dead:
		creature_sprite.modulate = Color.RED
		create_tween().tween_property(creature_sprite, "modulate", creature_color, 0.2)

func die() -> void:
	if is_dead:
		return
	is_dead = true
	died.emit(self)
	queue_free()

# --- God-hand ----------------------------------------------------------------

func grab() -> void:
	state = State.HELD
	brain.interrupt()
	movement.stop()
	velocity = Vector2.ZERO

func release(throw_velocity: Vector2) -> void:
	if throw_velocity.length() > THROW_PUNISH_SPEED:
		learning.reward(-0.5)
	throw(throw_velocity)

func throw(throw_velocity: Vector2) -> void:
	state = State.THROWN
	brain.interrupt()
	movement.stop()
	velocity = throw_velocity.limit_length(MAX_THROW_SPEED)

func pet() -> void:
	learning.reward(1.0)
	emote("<3")

func flick(from: Vector2) -> void:
	learning.reward(-1.0)
	emote("!")
	throw((global_position - from).normalized() * 120.0)

func calm() -> void:
	calmed_until = age + CALM_TIME
	emote("~")

## Damage from hitting the glass at `speed` px/s (only the part of the velocity into the wall counts).
static func impact_damage(speed: float) -> int:
	if speed <= SAFE_IMPACT_SPEED:
		return 0
	return 1 + int((speed - SAFE_IMPACT_SPEED) / 100.0)

func _fly(delta: float) -> void:
	var collision := move_and_collide(velocity * delta)
	if collision:
		var normal := collision.get_normal()
		take_damage(impact_damage(absf(velocity.dot(normal))))
		velocity = velocity.bounce(normal) * BOUNCE
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	if velocity.length() < 10.0:
		velocity = Vector2.ZERO
		state = State.NORMAL

# --- Visuals -----------------------------------------------------------------

## Emotes that have an icon in the tile sheet; anything else is shown as text.
const EMOTE_ICONS := {"<3": Tiles.HEART, "!": Tiles.ALERT, "?": Tiles.SPEECH, "~": Tiles.SPARKLE}

func emote(text: String, duration: float = 2.0) -> void:
	var has_icon := EMOTE_ICONS.has(text)
	emote_icon.visible = has_icon
	emote_label.visible = not has_icon
	if has_icon:
		emote_icon.region_rect = Tiles.region(EMOTE_ICONS[text])
	else:
		emote_label.text = text
	_emote_time = duration

func _grow(delta: float) -> void:
	if is_adult:
		return
	growth = minf(1.0, growth + 0.5 * delta / GROW_TIME)
	_update_scale()
	if growth >= 1.0:
		is_adult = true

func _update_scale() -> void:
	var s := Vector2.ONE * genome.size * growth
	creature_sprite.scale = s
	$CollisionShape2D.scale = s
