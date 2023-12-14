extends Area2D

@export var speed: int = 250
@export var damage: int = 300
@export var knockback_power: int = 400
# Variables from signals
var set_rotation_degree
var set_direction
var iframe_type: String = "melee"

# Called when the node enters the scene tree for the first time.
func _ready():
	rotation_degrees = set_rotation_degree
	$Timeout.start()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += set_direction * speed * delta

func _on_body_entered(body):
	print("Special Attack Collision")
	if body.has_method("_hit"):
		body._hit(damage, iframe_type, set_direction, knockback_power)
	print("started timer")
	$"../../Character/Timer/MeleeCooldown".start(2)
	queue_free()

func _on_timeout_timeout():
	$"../../Character/Timer/MeleeCooldown".start(2)
	queue_free()
