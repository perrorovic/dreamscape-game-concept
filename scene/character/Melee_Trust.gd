extends Area2D

@export var speed: int = 100
@export var damage: int = 50
@export var knockback_power: int = 20
# Variables from signals
var set_rotation_degree
var set_direction
var iframe_type: String = "melee"

func _ready():
	# Set the rotation so it face toward the mouse
	rotation_degrees = set_rotation_degree
	# Set timer for timeout if bullet escape collision
	$Timeout.start()

func _process(delta):
	position += set_direction * speed * delta
	# This function break the projectile when going into day worldType
#	_check()
	#print(set_direction)

func _on_body_entered(body):
	print("Bullet Collision")
	if body.has_method("_hit"):
		body._hit(damage, iframe_type)
		if body.has_method("_knockback"):
			body._knockback( set_direction, knockback_power)
#		print("Bullet Hit")
	#queue_free()

func _on_timeout():
	queue_free()
