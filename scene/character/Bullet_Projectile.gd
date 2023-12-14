extends Area2D

@export var speed: int = 500
@export var damage: int = 20
@export var knockback_power: int = 75
# Variables from signals
var set_rotation_degree
var set_direction
var iframe_type: String = "melee"

func _ready():
	# Set the rotation so it face toward the mouse
	rotation_degrees = set_rotation_degree
	# Set timer for timeout if bullet escape collision
	$Timeout.start()
	
	#_check()

func _process(delta):
	position += set_direction * speed * delta

	# This function break the projectile when going into day worldType
#	_check()
	#print(set_direction)

#i forgor what is this
#func _check():
	##To check if world is day then only day masking is true otherwise collision will always detect wall even if its hidden because of world type
	#if Global.worldType == "Day":
		#set_collision_mask_value(2,true)
		#set_collision_mask_value(3,false)
	#elif Global.worldType == "Night":
		#set_collision_mask_value(2,false)
		#set_collision_mask_value(3,true)

func _on_body_entered(body):
	print("Bullet Collision")
	if body.has_method("_hit"):
		body._hit(damage, iframe_type, set_direction, knockback_power)
	queue_free()

func _on_bullet_timeout():
#	print("Bullet Timeout")
	queue_free()
