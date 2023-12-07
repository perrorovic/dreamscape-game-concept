extends Area2D

@export var damage: int = 20
@export var speed = 300
# Variables from signals
var set_rotation_degree
var set_direction

var random_rotation: bool

func _ready():
	random_rotation = randi_range(0,1)
	# Set the rotation so it face toward the mouse
	rotation_degrees = set_rotation_degree
	# Set timer for timeout if bullet escape collision
	$Timeout.start()
	
func _process(delta):
	if random_rotation:
		rotation_degrees += 5
	else:
		rotation_degrees -= 5
	position += set_direction * speed * delta
	# This function break the projectile when going into day worldType
	
func _on_timeout():
	queue_free()

func _on_body_entered(body):
	if body.has_method("_player_hit") and body.get_collision_mask_value(1) == true:
		print("Player is hit by Slash!")
		body._player_hit(damage)
