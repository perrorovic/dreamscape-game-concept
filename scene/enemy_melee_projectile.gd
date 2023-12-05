extends Area2D
@export var damage: int = 10

var ableToHit:bool = true
var set_rotation_degree

func _ready():
	$meleeCooldown.start()
	$AnimationPlayer.play("melee_slash")
	rotation_degrees = set_rotation_degree
	
	
func _check():
	if Global.worldType == "Night":
		queue_free()
		
func _on_melee_cooldown_timeout():
	queue_free()

func _on_body_entered(body):
	# There is collision issues because in animation cast more than 1 collision
	# Therefore the damage is set lower. because it hit x4
	# print("Slash Collision")
	if ableToHit == true and body.name == "Character":
		if body.has_method("_player_hit"):
			body._player_hit(damage)
			ableToHit = false
	#		print("Slash Hit")
