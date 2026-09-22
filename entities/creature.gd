@tool
extends CharacterBody2D
class_name Creature

@onready var creature_sprite : Sprite2D = $Sprite2D
@export var legs : int = 4
@export var creature_name : String = "creature"
@export var move_speed : float = 40.0
@export var creature_color : Color = Color.ANTIQUE_WHITE:
	set(value):
		creature_color = value
		creature_sprite.modulate = creature_color
@export var health : int = 10

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func move_toward_point(target_pos: Vector2, delta : float) -> void:
	var direction := (target_pos - global_position).normalized()
	velocity = direction * move_speed * delta
	move_and_slide()

func make_sound() -> void:
	print(creature_name, " makes a random noise")
