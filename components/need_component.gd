extends Node
class_name NeedComponent
## A need that rises from 0 to 100 over time: hunger, thirst, energy, fun, social, bladder.
## Generalized from Week 2's HungerComponent. 0 = fully satisfied, 100 = desperate.

signal changed(new_value: float)
signal maxed     ## reached 100
signal relieved  ## dropped below relief_threshold after being maxed

const MAX := 100.0

@export var value : float = 0.0
@export var rate : float = 1.0              ## points per second
@export var relief_threshold : float = 80.0
var gene_multiplier : float = 1.0           ## set from the creature's Genome
var env_multiplier : float = 1.0            ## set by the environment (e.g. a dirty tank)
var is_maxed : bool = false

func _process(delta: float) -> void:
	add(rate * gene_multiplier * env_multiplier * delta)

func add(amount: float) -> void:
	_set_value(value + amount)

func satisfy(amount: float) -> void:
	_set_value(value - amount)

func ratio() -> float:
	return value / MAX

func _set_value(new_value: float) -> void:
	var old := value
	value = clampf(new_value, 0.0, MAX)
	if value != old:
		changed.emit(value)
	if not is_maxed and value >= MAX:
		is_maxed = true
		maxed.emit()
	elif is_maxed and value < relief_threshold:
		is_maxed = false
		relieved.emit()
