# --------------------------------------------------------------------------
# This script are available to be extended with 'extends Scene_Parent' by other script
# --------------------------------------------------------------------------

extends Node2D
class_name Scene_Parent

#https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html#examples #export documentation, goodshit
#How to create dropdown selection in inspector

# --------------------------------------------------------------------------
# Preload scene of needed assets for the game are listed down below:
# --------------------------------------------------------------------------

# Player projectile
var meleeProjectile: PackedScene = preload("res://scene/character/Melee_Projectile.tscn")
var meleeNew: PackedScene = preload("res://scene/character/Melee_Trust.tscn")
var throw: PackedScene = preload("res://scene/character/Melee_Throw.tscn")
var rangedProjectile: PackedScene = preload("res://scene/character/Bullet_Projectile.tscn")
var fireball: PackedScene = preload("res://scene/character/Fireball_Projectile.tscn")
# Boss projectile
var boss_shootProjectile: PackedScene = preload("res://scene/boss/Boss_Shoot_Projectile.tscn")
var boss_bombProjectileDay: PackedScene = preload("res://scene/boss/Boss_Bomb_Projectile_Day.tscn")
var boss_bombProjectileNight: PackedScene = preload("res://scene/boss/Boss_Bomb_Projectile_Night.tscn")
var boss_slashProjectile: PackedScene = preload("res://scene/boss/Boss_Slash_Projectile.tscn")
var boss_crystalSpire: PackedScene = preload("res://scene/boss/Boss_Crystal_Spire.tscn")
# Enemy projectile
var enemy_meleeDayProjectile: PackedScene = preload("res://scene/enemy/Enemy_Melee_Projectile.tscn")
var enemy_rangedDayProjectile: PackedScene = preload("res://scene/enemy/Enemy_Ranged_Projectile.tscn")
# Items
var items_dash:PackedScene = preload("res://scene/entity/Items_Dash.tscn")
var items_ammo:PackedScene = preload("res://scene/entity/Items_Ammo.tscn")
var items_health:PackedScene = preload("res://scene/entity/Items_Health.tscn")
# UI textures
var sun: Texture2D = preload("res://assets/ui/sun.png") #db9042
var moon: Texture2D = preload("res://assets/ui/fullmoon.png") #17a995

# --------------------------------------------------------------------------
# Function of _ready() and _process() are listed below:
# --------------------------------------------------------------------------

func _ready():
	_init_day()

func _process(_delta):
	pass

func _init_day():
	# Initation of the world scene, set needed property to the world settings
	$BGM.play()
	Global.worldType = "Day"
	Global.player_ableToMelee = true
	Global.player_ableToThrow = true
	Global.player_ableToShoot = false
	Global.player_ableToFireball = true
	$Node2D/TileMap.set_layer_enabled(1,true)
	$Node2D/TileMap.set_layer_enabled(2,false)
	
# --------------------------------------------------------------------------
# Check the world type and assign the needed property accordingly
# This function are triggered by signal sent by player character! ("res://scene/character/Character.gd")
# --------------------------------------------------------------------------

func _change_world_type():
	if Global.worldType == "Day":
		# This enable the tilemap 'Day_Env' layer
		$Node2D/TileMap.set_layer_enabled(1,true)
		# This disable the tilemap 'Night_Env' layer
		$Node2D/TileMap.set_layer_enabled(2,false)
		# Change filter and lightning for night worldType
		# This line of code are moved to "res://scene/character/Character.gd"
		$Character/PointLight2D.shadow_enabled = false
		$Character/PointLight2D.energy = 2
		# In day world sound are normal
		$"BGM".pitch_scale = 1
		# Set the UI accordingly to the day worldType
		$"UI/WorldType/Progress".texture_under = sun
		$"UI/WorldType/Progress".texture_progress = sun
	if Global.worldType == "Night":
		# This disable the tilemap 'Day_Env' layer
		$Node2D/TileMap.set_layer_enabled(1,false)
		# This enable the tilemap 'Night_Env' layer
		$Node2D/TileMap.set_layer_enabled(2,true)
		# Change filter and lightning for night worldType
		# This line of code are moved to "res://scene/character/Character.gd"
		$Character/PointLight2D.shadow_enabled = true
		$Character/PointLight2D.energy = 2.5
		# In night world sound are speed-up a little bit
		$BGM.pitch_scale = 1.12
		# Set the UI accordingly to the night worldType
		$"UI/WorldType/Progress".texture_under = moon
		$"UI/WorldType/Progress".texture_progress = moon

# --------------------------------------------------------------------------
# Player signal listed here, all the signal are from "res://scene/character/Character.gd"
# --------------------------------------------------------------------------

func _on_player_mouse1_melee(player_position, player_rotation, player_direction):
	var melee = meleeNew.instantiate() as Area2D
	melee.set_direction = player_direction
	melee.position = player_position
	melee.set_rotation_degree = player_rotation
	$ProjectileTemp.add_child(melee,true)

func _on_character_mouse_2_melee(player_position, player_rotation, player_direction):
	var throw = throw.instantiate() as Area2D
	throw.set_direction = player_direction
	throw.position = player_position
	throw.set_rotation_degree = player_rotation
	$ProjectileTemp.add_child(throw,true)

func _on_player_mouse1_ranged(player_position, player_rotation, player_direction):
	var bullet = rangedProjectile.instantiate() as Area2D
	bullet.set_rotation_degree = player_rotation + 90
	bullet.set_direction = player_direction
	bullet.position = player_position
	$ProjectileTemp.add_child(bullet,true)

func _on_character_mouse_2_ranged(player_position, player_rotation, player_direction):
	var fireball = fireball.instantiate() as Area2D
	fireball.set_rotation_degree = player_rotation + 90
	fireball.set_direction = player_direction
	fireball.position = player_position
	$ProjectileTemp.add_child(fireball,true)

# --------------------------------------------------------------------------
# Boss signal listed here, all the signal are from "res://scene/boss/Boss.gd"
# --------------------------------------------------------------------------

func _on_boss_action_shoot(boss_position, target_direction):
	var boss_shoot = boss_shootProjectile.instantiate() as Area2D
	boss_shoot.set_rotation_degree = rad_to_deg(target_direction.angle()) + 90
	boss_shoot.set_direction = target_direction
	boss_shoot.position = boss_position
	$EnemyProjectileTemp.add_child(boss_shoot,true)

func _on_boss_action_slash(boss_position, target_direction):
	var boss_slash = boss_slashProjectile.instantiate() as Area2D
	boss_slash.set_rotation_degree = rad_to_deg(target_direction.angle()) + 90
	boss_slash.set_direction = target_direction
	boss_slash.position = boss_position
	$EnemyProjectileTemp.add_child(boss_slash,true)

func _on_boss_action_bomb(boss_position):
	if Global.worldType == "Day":
		var boss_bomb = boss_bombProjectileDay.instantiate() as Area2D
		boss_bomb.position = boss_position
		$EnemyProjectileTemp.add_child(boss_bomb,true)
	if Global.worldType == "Night":
		var boss_bomb = boss_bombProjectileNight.instantiate() as Area2D
		boss_bomb.position = boss_position
		$EnemyProjectileTemp.add_child(boss_bomb,true)

# --------------------------------------------------------------------------
# This dont have node connect signals shown but still work as intended because it connected manually
# Enemy signal with inheritance all listed below:
# --------------------------------------------------------------------------

# Signal from $EnemyTemp ["res://scene/enemy/Enemy_Melee.gd"]
func _on_enemy_melee_attack(enemy_position, target_direction):
	var enemy_meleeDay = enemy_meleeDayProjectile.instantiate() as Area2D
	enemy_meleeDay.position = enemy_position
	enemy_meleeDay.set_direction = target_direction
	enemy_meleeDay.set_rotation_degree = rad_to_deg(target_direction.angle()) - 90
	# Requested to be deferred by game engine
	$EnemyProjectileTemp.call_deferred("add_child",enemy_meleeDay,true)
	#$EnemyProjectileTemp.add_child(enemy_meleeDay,true)

# Signal from $EnemyTemp ["res://scene/enemy/Enemy_Ranged.gd"]
func _on_enemy_ranged_attack(enemy_position, target_direction):
	var enemy_rangedDay = enemy_rangedDayProjectile.instantiate() as Area2D
	enemy_rangedDay.position = enemy_position
	enemy_rangedDay.set_rotation_degree = rad_to_deg(target_direction.angle()) - 90
	enemy_rangedDay.set_direction = target_direction
	# Requested to be deferred by game engine
	$EnemyProjectileTemp.call_deferred("add_child",enemy_rangedDay,true)
	#$EnemyProjectileTemp.add_child(enemy_rangedDay,true)

# Signal from $EnemyTemp ["res://scene/enemy/Enemy_Parent.gd"]
func _on_enemy_drop(item_name, enemy_position):
	
	if item_name == "health":
		var item_dropped = items_health.instantiate() as Area2D
		item_dropped.position = enemy_position
		$ItemTemp.call_deferred("add_child", item_dropped,true)
		print("Health Dropped")
	elif item_name == "ammo":
		var item_dropped = items_ammo.instantiate() as Area2D
		item_dropped.position = enemy_position
		$ItemTemp.call_deferred("add_child", item_dropped,true)
		print("Ammo Dropped")
	elif item_name == "dash":
		var item_dropped = items_dash.instantiate() as Area2D
		item_dropped.position = enemy_position
		$ItemTemp.call_deferred("add_child", item_dropped,true)
		print("Dash Dropped")
		
	



