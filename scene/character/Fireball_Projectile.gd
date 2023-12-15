extends Area2D

@export var speed: int = 350
@export var damage: int = 500
@export var knockback_power: int = 175
# Variables from signals
var set_rotation_degree
var set_direction
var iframe_type: String = "ranged"
var exploded: bool = false

func _ready():
	# Set the rotation so it face toward the mouse
	rotation_degrees = set_rotation_degree
	# Set timer for timeout if bullet escape collision
	$Timeout.start()
	#Will automatically explode airborne after 1 second of airtime if dont collide anything
	$MidairExplosionWaittime.start()
	#_check()

func _process(delta):
	if exploded == false:
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

#Explode after colliding with anything
func _on_body_entered(body):
	$Explosion_AoE.set_collision_mask_value(7,true)
	exploded = true

#Explode after 1 second of airtime and not colliding anything
func _on_midair_explosion_waittime_timeout():
	$Explosion_AoE.set_collision_mask_value(7,true)
	exploded = true
	
#Explosion mechanic : deal damage, knockback, and any other shit
func _on_explosion_aoe_body_entered(body):
	#remove object only after exploded and there is enemy nearby, will stuck at wall and wait for timeout timer to despawn
	if body.has_method("_hit"):
		print("Enemy take damage by explosion")
		body._hit(damage, iframe_type, set_direction, knockback_power)
		queue_free()

func _on_timeout_timeout():
	queue_free()
