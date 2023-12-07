extends Area2D

@export var damage: int = 10
@export var speed = 300
# Variables from signals
var set_rotation_degree
var set_direction

func _ready():
	# Set the rotation so it face toward the mouse
	rotation_degrees = set_rotation_degree
	# Set timer for timeout if bullet escape collision
	
func _process(delta):
	position += set_direction * speed * delta
	# This function break the projectile when going into day worldType
	
func _on_timeout_timeout():
	queue_free()

func _on_body_entered(body):
	if body.has_method("_player_hit") and body.get_collision_mask_value(1) == true:
		print("Player is hit by Shoot!")
		body._player_hit(damage)
		queue_free()



