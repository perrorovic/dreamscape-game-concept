extends Area2D

@export var speed: int = 300
@export var damage: int = 500
@export var knockback_power: int = 425
# Variables from signals
var set_rotation_degree
var set_direction
var iframe_type: String = "ranged"
var exploded: bool = false

func _ready():
	# Set the rotation so it face toward the mouse
	rotation_degrees = set_rotation_degree
	#Will automatically explode airborne after 1 second of airtime if dont collide anything
	$MidairExplosionWaittime.start()

func _process(delta):
	if exploded == false:
		position += set_direction * speed * delta

#Explode after colliding
func _on_body_entered(_body):
	$Explosion_AoE.set_collision_mask_value(7,true)
	$AnimationPlayer.play("Explode")
	exploded = true

#Explode after x second of airtime
func _on_midair_explosion_waittime_timeout():
	$Explosion_AoE.set_collision_mask_value(7,true)
	$AnimationPlayer.play("Explode")
	exploded = true
	
#Explosion mechanic : deal damage, knockback, and any other shit
func _on_explosion_aoe_body_entered(body):
	if body.has_method("_hit"):
		print("Enemy take damage by Charged explosion")
		body._hit(damage, iframe_type, set_direction, knockback_power)
		
#Queue free after animation is finished
func _on_animation_player_animation_finished(_anim_name):
	queue_free()
