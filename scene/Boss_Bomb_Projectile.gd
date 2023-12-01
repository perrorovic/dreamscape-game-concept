extends Area2D

@export var dot_damage: int = 1
@export var explosion_damage: int = 30
@export var speed: int = 175
# Unique variable to this script for AOE and DOT status
var bomb_isExploded: bool = false
var player_isInside:bool = false
# Signal variable for targeting to player
var target_position

func _ready():
	$Timeout.start()
	target_position = Global.player_position

func _process(delta):
	rotation_degrees += 1 * delta
	position = position.move_toward(target_position, delta * speed)
	if position == target_position and $DotTick.time_left <= 0:
		$Sprite2D.texture = preload("res://assets/Flame.png")
		#Bomb will able deal damage on explosion and DoT
		set_collision_mask_value(1, true)
		rotation_degrees -= 10 * delta
		scale = Vector2(3, 3)
	#To give time to deal explosion damage for once otherwise bomb_isExploded is set to true immediately and player won't take explosion damage
	if position == target_position and $ExplosionWait.is_stopped():
		$ExplosionWait.start(0.1)
		
func _on_timeout():
	queue_free()

func _on_body_entered(body):
	if body.has_method("_player_hit") and bomb_isExploded == false and body.get_collision_mask_value(1) == true:
		print("Player is hit by Bomb Explosion!")
		body._player_hit(explosion_damage)
		set_collision_mask_value(1, false)
		$DotTick.start()
		
	elif body.has_method("_player_hit") and bomb_isExploded == true and body.get_collision_mask_value(1) == true:
		print("Player is hit by Bomb!")
		body._player_hit(dot_damage)
		set_collision_mask_value(1, false)
		$DotTick.start()

#To tell if bomb is exploded
func _on_explosion_wait_timeout():
	print("Change bomb_isExploded to True")
	bomb_isExploded = true
	print(bomb_isExploded)
