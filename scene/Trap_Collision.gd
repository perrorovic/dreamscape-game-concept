extends Area2D

@export var damage:float = 30

func _on_body_entered(body: CharacterBody2D):
	if body.name == "Character":
		body._player_hit(damage)
		queue_free()
	
