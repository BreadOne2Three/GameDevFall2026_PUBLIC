extends Node
class_name LearningComponent
## Learns from the god-hand. Every brain action has a learned bias that is added to
## its utility score, so rewarded behaviors get chosen more and punished ones less.
## This is a simple bandit-style learner trained by human feedback
## (search terms: "multi-armed bandit", "learning from human feedback", "TAMER").
##
## The hard part of reinforcement learning is credit assignment: WHICH behavior was
## the reward for? We give full credit to what the creature is doing right now and
## partial credit to things it finished in the last credit_window seconds.

const MAX_BIAS := 0.5
const HISTORY_SIZE := 5

@export var learning_rate : float = 0.15
@export var credit_window : float = 3.0
## Starting biases. Creatures start slightly against walking to the litter box.
@export var initial_biases : Dictionary = {"UseLitterBoxAction": -0.15}

var biases : Dictionary = {}
var history : Array = []       ## recently finished actions: [{"action": String, "ended_at": float}], newest last
var current_action : String = ""
var now : float = 0.0          ## game-time clock (respects pause and speed)

func _ready() -> void:
	if biases.is_empty():
		biases = initial_biases.duplicate()

func _process(delta: float) -> void:
	now += delta

func bias(action_name: String) -> float:
	return biases.get(action_name, 0.0)

## The brain calls this every time the creature switches action ("" = nothing).
func record_action(action_name: String) -> void:
	if current_action != "":
		history.append({"action": current_action, "ended_at": now})
		if history.size() > HISTORY_SIZE:
			history.pop_front()
	current_action = action_name

## Positive = reward (pet), negative = punishment (flick, throw).
## Each action is credited once, by its most recent occurrence, so an action that
## repeats a lot (like wandering) doesn't soak up several rewards at once.
func reward(amount: float) -> void:
	var credit := {}   # action name -> share of the reward (0..1)
	if current_action != "":
		credit[current_action] = 1.0
	for entry in history:
		var age : float = now - entry["ended_at"]
		if age <= credit_window:
			var share := 1.0 - age / credit_window
			credit[entry["action"]] = maxf(credit.get(entry["action"], 0.0), share)
	for action_name in credit:
		_adjust(action_name, amount * credit[action_name])

## Babies start with the defaults plus half of what their parents learned.
func inherit_from(a: LearningComponent, b: LearningComponent) -> void:
	var keys := {}
	for key in a.biases: keys[key] = true
	for key in b.biases: keys[key] = true
	for key in initial_biases: keys[key] = true
	for key in keys:
		var base : float = initial_biases.get(key, 0.0)
		var parents_avg : float = (a.bias(key) + b.bias(key)) / 2.0
		biases[key] = base + 0.5 * (parents_avg - base)

func _adjust(action_name: String, amount: float) -> void:
	biases[action_name] = clampf(bias(action_name) + learning_rate * amount, -MAX_BIAS, MAX_BIAS)
