extends Area2D

@export var speed: int = 500
@export var damage: int = 20
# Variables from signals
var set_rotation_degree
var set_direction

func _ready():
	# Set the rotation so it face toward the mouse
	rotation_degrees = set_rotation_degree
	# Set timer for timeout if bullet escape collision
	#$Timeout.start()

func _process(delta):
	position += set_direction * speed * delta
	# This function break the projectile when going into day worldType
#	_check()

func _check():
	if Global.worldType == "Day":
		queue_free()

func _on_body_entered(body):
	print("Bullet Collision")
	if body.has_method("_hit"):
		body._hit(damage)
#		print("Bullet Hit")
		queue_free()
	queue_free()

func _on_bullet_timeout():
#	print("Bullet Timeout")
	queue_free()
