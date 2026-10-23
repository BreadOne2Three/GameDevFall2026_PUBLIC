extends Node
class_name BrainComponent
## Utility AI. Every think_interval seconds it scores every child UtilityAction and
## runs the best one. Final score = action score + learned bias (+ stickiness for
## the current action so creatures don't flicker between two similar choices).
## What a species can do is decided by which action nodes are children of its Brain.

signal action_changed(action_name: String)

const SURVIVAL_NEED_LEVEL := 0.8   ## at this need level, punishments can't stop survival actions
const INTERRUPT_SCORE := 0.7       ## committed actions only yield to survival actions this urgent
const GIVE_UP_COOLDOWN := 2.0      ## cooldown after abandoning an action that took too long

@export var think_interval : float = 0.25
@export var stickiness : float = 0.1

var creature : Node
var learning : LearningComponent
var actions : Array[UtilityAction] = []
var current_action : UtilityAction = null
var last_scores : Dictionary = {}  ## action name -> final score from the last think
var _think_timer : float = 0.0
var _action_time : float = 0.0

func setup(owner_creature: Node, learning_component: LearningComponent) -> void:
	creature = owner_creature
	learning = learning_component
	actions.clear()
	for child in get_children():
		if child is UtilityAction:
			child.creature = creature
			actions.append(child)

## Called by the creature every physics frame while it's in the NORMAL state.
func tick(delta: float) -> void:
	for action in actions:
		action.cooldown_left = maxf(0.0, action.cooldown_left - delta)
	_think_timer -= delta
	if current_action == null or _think_timer <= 0.0:
		think()
	if current_action == null:
		return
	_action_time += delta
	if current_action.run(delta):
		switch_to(null)
		think()
	elif _action_time > current_action.max_duration:
		current_action.cooldown_left = GIVE_UP_COOLDOWN
		switch_to(null)
		think()

func think() -> void:
	_think_timer = think_interval
	var best : UtilityAction = null
	var best_score := 0.0
	var best_survival : UtilityAction = null
	var best_survival_score := INTERRUPT_SCORE
	last_scores.clear()
	for action in actions:
		var s := final_score(action)
		last_scores[String(action.name)] = s
		if s > best_score:
			best_score = s
			best = action
		if action.is_survival and s >= best_survival_score:
			best_survival_score = s
			best_survival = action
	if current_action and current_action.is_committed():
		# Committed (resting, playing...): only an urgent survival need can interrupt.
		if best_survival and best_survival != current_action:
			switch_to(best_survival)
		return
	if best != current_action:
		switch_to(best)

func final_score(action: UtilityAction) -> float:
	if action.cooldown_left > 0.0:
		return 0.0
	var base := action.score()
	if base <= 0.0:
		return 0.0   # impossible right now (no food, no partner...): learning can't change that
	var bias := learning.bias(String(action.name)) if learning else 0.0
	if action.is_survival and bias < 0.0 and action.need_ratio() >= SURVIVAL_NEED_LEVEL:
		bias = 0.0
	var s := base + bias
	if action == current_action:
		s += stickiness
	return s

func switch_to(action: UtilityAction) -> void:
	if current_action:
		current_action.exit()
	current_action = action
	_action_time = 0.0
	var action_name := String(action.name) if action else ""
	if learning:
		learning.record_action(action_name)
	if action:
		action.enter()
	action_changed.emit(action_name)

## Stop whatever we're doing (e.g. picked up by the god-hand).
func interrupt() -> void:
	if current_action:
		switch_to(null)

func get_action(action_name: String) -> UtilityAction:
	return get_node_or_null(action_name) as UtilityAction

func current_action_name() -> String:
	return String(current_action.name) if current_action else ""

## Another creature asks us to join a joint action (play, talk, breed). Returns true if we accept.
func request_joint(action_name: String, initiator: Node) -> bool:
	if creature and creature.state != 0:   # 0 = Creature.State.NORMAL
		return false
	if current_action and (current_action.is_survival or current_action.is_committed()):
		return false
	var action := get_action(action_name)
	if action == null or action.cooldown_left > 0.0 or not action.accepts_invite(initiator):
		return false
	if action.has_method("join"):
		action.join(initiator)
	switch_to(action)
	_think_timer = think_interval
	return true
