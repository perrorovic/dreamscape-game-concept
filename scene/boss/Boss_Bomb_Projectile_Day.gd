extends Area2D

# Create a signal that will be used in parent script
#signal boss_createCrystal(spawn_position)
# Keep a reference to your world scene (Main.tscn)
# (This is how this projectile get assigned to in the main tree)
#@onready var world = get_node("/root/Node2D/")

@export var dot_damage: int = 1
@export var explosion_damage: int = 30
@export var speed: int = 175
# Unique variable to this script for AOE and DOT status
var bomb_isExploded: bool = false
var player_isInside:bool = false
# Signal variable for targeting to player
var target_position

func _ready():
	# Connect 'boss_createCrystal' signal into the 'world' at '_on_boss_create_crystal' function with one-shot connection
#	connect("boss_createCrystal", Callable(world, "_on_boss_create_crystal"), 4)
	$FlameArea.hide()
	$Boss_Crystal_Spire.hide()
	$Boss_Crystal_Spire.set_collision_mask_value(6, false)
	$Boss_Crystal_Spire.set_collision_layer_value(1, false)
	$Boss_Crystal_Spire.set_collision_layer_value(7, false)
	target_position = Global.player_position
	set_collision_mask_value(1, false)
	

func _process(delta):
	_check_world_type()
	$BombProjectile.rotation_degrees -= 120 * delta
	position = position.move_toward(target_position, delta * speed)
	$FlameArea.rotation_degrees -= 10 * delta
	if position == target_position and $DotTick.time_left <= 0:		
		$BombProjectile.hide()
		$FlameArea.show()
		#Bomb will able deal damage on explosion and DoT
		set_collision_mask_value(1, true)
		# Change collision size for AOE bombing and stay as DoT area
		$CollisionShape2D.scale = Vector2(4.8, 4.8)
		if $Boss_Crystal_Spire.ableToBeHit == false and $Boss_Crystal_Spire.health != 0:
			$Boss_Crystal_Spire.ableToBeHit = true
			
#		boss_createCrystal.emit(position)
	#To give time to deal explosion damage for once otherwise bomb_isExploded is set to true immediately and player won't take explosion damage
	if position == target_position and $ExplosionWait.is_stopped():
		$ExplosionWait.start(0.1)
		
func _on_timeout():
	queue_free()

func _on_body_entered(body):
	if body.has_method("_player_hit") and bomb_isExploded == false and body.get_collision_mask_value(1) == true:
#		print("Player is hit by Bomb Explosion!")
		body._player_hit(explosion_damage)
		set_collision_mask_value(1, false)
		$DotTick.start()
		
	elif body.has_method("_player_hit") and bomb_isExploded == true and body.get_collision_mask_value(1) == true:
#		print("Player is hit by Bomb!")
		body._player_hit(dot_damage)
		set_collision_mask_value(1, false)
		$DotTick.start()

#To tell if bomb is exploded
func _on_explosion_wait_timeout():
#	print("Change bomb_isExploded to True")
	bomb_isExploded = true
#	print(bomb_isExploded)

func _check_world_type():
	if Global.worldType == "Day" and position == target_position:
		$Boss_Crystal_Spire.hide()
		$Boss_Crystal_Spire.set_collision_mask_value(6, false)
		$Boss_Crystal_Spire.set_collision_layer_value(1, false)
		$Boss_Crystal_Spire.set_collision_layer_value(7, false)
	if Global.worldType == "Night" and position == target_position:
		$Boss_Crystal_Spire.show()
		$Boss_Crystal_Spire.set_collision_mask_value(6, true)
		$Boss_Crystal_Spire.set_collision_layer_value(7, true)
		$Boss_Crystal_Spire.set_collision_layer_value(1, true)
