@tool
extends CharacterBody2D
class_name Creature

@onready var creature_sprite : Sprite2D = $Sprite2D
@onready var movement : MovementComponent = $MovementComponent
@export var legs : int = 4
@export var creature_name : String = "creature"
@export var move_speed : float = 40.0
@export var creature_color : Color = Color.ANTIQUE_WHITE:
	set(value):
		creature_color = value
		if is_node_ready():
			creature_sprite.modulate = creature_color
signal health_changed(new_value: int)
@export var health : int = 2:
	set(value):
		health = value
		health_changed.emit(health)
		print('health changed to: ', health)
		if health <= 0:
			self.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if not movement.has_target:
		movement.wander_from(global_position)
	move_toward_point(movement.target, delta)
	movement.check_arrival(global_position)

func move_toward_point(target_pos: Vector2, delta : float) -> void:
	var direction := (target_pos - global_position).normalized()
	velocity = direction * move_speed * delta
	move_and_slide()

func make_sound() -> void:
	print(creature_name, " makes a random noise")


func _on_starved() -> void:
	move_speed = move_speed * (1-.65)
	$TimeToLive.start(5.0)
	pass # Replace with function body.


func _on_time_to_live_timeout() -> void:
	health -= 1
