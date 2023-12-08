extends Area2D

@export var damage: int = 50
@export var knockback_power:int = 20

var set_direction
var ableToHit:bool = true

func _ready():
	$AnimationPlayer.play("melee_slash")
	$MeleeCooldown.start()

func _process(_delta):
	position = Global.player_meleeSlashSpawn
	# if you want the slash to follow player direction at all time
#	rotation_degrees = Global.player_rotation - 90
	# This function break the projectile when going into night worldType
#	_check()
	
func _check():
	if Global.worldType == "Night":
		queue_free()
		
func _on_melee_cooldown_timeout():
	Global.player_ableToMelee = true
	queue_free()

func _on_body_entered(body):
	# There is collision issues because in animation cast more than 1 collision
	# Therefore the damage is set lower. because it hit x4
	# print("Slash Collision")
	if ableToHit == true:
		if body.has_method("_hit"):
			body._hit(damage)
			ableToHit = false
			if body.has_method("_knockback"):
				body._knockback(set_direction, knockback_power)
	#		print("Slash Hit")
