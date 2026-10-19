extends Node
class_name HungerComponent

signal starved
signal hunger_changed(new_value: float)

@export var hunger : float = 0.0
@export var rate : float = 2.0

func _process(delta: float) -> void:
	if hunger >= 100.0:
		return
	hunger = clamp(hunger + rate*delta, 0.0, 100.0)
	hunger_changed.emit(hunger)
	if hunger >= 100.0:
		starved.emit()

func feed(amount : float) -> void:
	hunger = clamp(hunger - amount, 0, 100)
	hunger_changed.emit(hunger)
