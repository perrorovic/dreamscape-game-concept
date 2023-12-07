extends Area2D

@export var damage: float = 7.5
@export var speed_day = 200
@export var speed_night = 125
var speed
# Variables from signals
var set_rotation_degree
var set_direction

func _ready():
	# Set the rotation so it face toward the mouse
	rotation_degrees = set_rotation_degree
	# Set timer for timeout if bullet escape collision
	$Timeout.start()
	
func _process(delta):
	if Global.worldType == "Day":
		speed = speed_day
	elif Global.worldType == "Night":
		speed = speed_night
		
	position += set_direction * speed * delta
	# This function break the projectile when going into day worldType
	
func _on_timeout():
	queue_free()

func _on_body_entered(body):
	if body.has_method("_player_hit") and body.get_collision_mask_value(1) == true:
		print("Player is hit by Shoot!")
		body._player_hit(damage)
		queue_free()
