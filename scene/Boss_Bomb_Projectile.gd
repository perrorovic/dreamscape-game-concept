extends Area2D

@export var damage: int = 5
@export var speed = 175
var target_position

func _ready():
	$Timeout.start()
	target_position = Global.player_position

func _process(delta):
	rotation_degrees += 1 * delta
	position = position.move_toward(target_position, delta * speed)
	if position == target_position:
		rotation_degrees -= 1 * delta
		scale = Vector2(3, 3)

func _on_timeout():
	queue_free()

func _on_body_entered(body):
	if body.has_method("_player_hit"):
		print("Player is hit by Bomb!")
		body._player_hit(damage)
