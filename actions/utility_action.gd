extends Node
class_name UtilityAction
## One thing a creature can choose to do. Every think, the BrainComponent asks each
## action "how much do you want to run right now?" (score) and runs the winner.
## Subclasses override score() / enter() / run() / exit().

const REACH := 6.0  ## how close counts as "arrived" when walking to something

@export var is_survival : bool = false     ## eating/drinking-type actions: learning can't suppress them when desperate
@export var need_name : String = ""        ## the need that drives this action (a child of the creature's Needs node)
## Default score shape: 0 until the need reaches ramp_start, rising linearly to max_score at ramp_end.
@export var ramp_start : float = 0.5
@export var ramp_end : float = 1.0
@export var max_score : float = 1.0
## Optional: draw your own score shape in the inspector (x = need 0..1, y = score). Overrides the ramp.
@export var score_curve : Curve
@export var max_duration : float = 15.0    ## the brain gives up on this action after this many seconds

var creature : Creature                    ## set by BrainComponent.setup()
var cooldown_left : float = 0.0            ## while > 0 the brain treats this action as impossible

## How much this action wants to run (0 = impossible / not at all, ~1 = urgent).
func score() -> float:
	return need_score()

## 0..1 fill level of the driving need.
func need_ratio() -> float:
	if need_name == "" or creature == null:
		return 0.0
	return creature.need(need_name).ratio()

func need_score() -> float:
	var x := need_ratio()
	if score_curve:
		return score_curve.sample(x)
	if x <= ramp_start:
		return 0.0
	return clampf(inverse_lerp(ramp_start, ramp_end, x), 0.0, 1.0) * max_score

func enter() -> void:
	pass

## Called every physics frame while this action runs. Return true when finished.
func run(_delta: float) -> bool:
	return true

func exit() -> void:
	pass

## Committed actions (resting, playing...) can only be interrupted by urgent survival actions.
func is_committed() -> bool:
	return false

## Joint actions: would this creature join `initiator`? Default: if our need is at least 30% unmet.
func accepts_invite(_initiator: Creature) -> bool:
	return need_ratio() >= 0.3

## Walk toward pos. Returns true once within REACH (and stops).
func walk_to(pos: Vector2) -> bool:
	if creature.global_position.distance_to(pos) <= REACH:
		creature.movement.stop()
		return true
	creature.movement.move_to(pos)
	return false
