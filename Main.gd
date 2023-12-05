extends Node2D

# Player projectile
var meleeProjectile: PackedScene = preload("res://scene/MeleeProjectile.tscn")
var rangedProjectile: PackedScene = preload("res://scene/BulletProjectile.tscn")

# Boss projectile
var boss_shootProjectile: PackedScene = preload("res://scene/Boss_Shoot_Projectile.tscn")
var boss_bombProjectileDay: PackedScene = preload("res://scene/Boss_Bomb_Projectile_Day.tscn")
var boss_bombProjectileNight: PackedScene = preload("res://scene/Boss_Bomb_Projectile_Night.tscn")
var boss_slashProjectile: PackedScene = preload("res://scene/Boss_Slash_Projectile.tscn")
var boss_crystalSpire: PackedScene = preload("res://scene/Boss_Crystal_Spire.tscn")

# Enemy projectile
var enemy_meleeDayProjectile: PackedScene = preload("res://scene/enemy_melee_projectile.tscn")

# World initiation
var sun: Texture2D = preload("res://assets/SunGede.png")
#var sunModulate: Color = Color("#db9042")
var moon: Texture2D = preload("res://assets/Fullmoon.png")
#var moonModulate: Color = Color("#17a995")

func _ready():
	$BGM.play()
	# Initiate to start the levels in day worldType
	_init_day()

func _process(_delta):
	# Check world will check the worldType in Global to set everything accordingly
	_check_world()

func _init_day():
	# Init for globals
	Global.worldType = "Day"
	Global.player_ableToMelee = true
	Global.player_ableToShoot = false
	# Init for world
	$DayNode.visible = true
	$NightNode.visible = false
	$TrapCollisionDay.visible = false
	$TrapCollisionNight.visible = false
	for n in $TrapCollisionDay.get_children():
		n.set_collision_mask_value(1, true)
	for n in $TrapCollisionNight.get_children():
		n.set_collision_mask_value(1, false)
		
func _check_world():
	if Global.worldType == "Night":
		# Change filter and lightning for night worldType
#		$CanvasModulate.color = moonModulate
		$Character/PointLight2D.shadow_enabled = true
		$Character/PointLight2D.energy = 2.5
		# In night world sound are speed-up a little bit
		$BGM.pitch_scale = 1.12
		# Show the maps for night worldType
		$NightNode.show()
		# Set the traps accordingly to the worldType
		for n in $TrapCollisionDay.get_children():
			n.set_collision_mask_value(1, false)
		for n in $TrapCollisionNight.get_children():
			n.set_collision_mask_value(1, true)
		# Set the UI accordingly to the night worldType
		$"UI/WorldType/Progress".texture_under = moon
		$"UI/WorldType/Progress".texture_progress = moon
	if Global.worldType == "Day":
		# Change filter and lightning for day worldType
#		$CanvasModulate.color = sunModulate
		$Character/PointLight2D.shadow_enabled = false
		$Character/PointLight2D.energy = 2
		# In day world sound are normal
		$"BGM".pitch_scale = 1
		# Hide the maps for night worldType
		$"NightNode".hide()
		# Set the traps accordingly to the worldType
		for n in $"TrapCollisionDay".get_children():
			n.set_collision_mask_value(1, true)
		for n in $"TrapCollisionNight".get_children():
			n.set_collision_mask_value(1, false)
		# Set the UI accordingly to the day worldType
		$"UI/WorldType/Progress".texture_under = sun
		$"UI/WorldType/Progress".texture_progress = sun

func _on_player_mouse1_melee(player_position, player_rotation):
	var melee = meleeProjectile.instantiate() as Area2D
	melee.position = player_position
	melee.rotation_degrees =  player_rotation - 90
	$ProjectileTemp.add_child(melee,true)

func _on_player_mouse1_ranged(player_position, player_rotation, player_direction):
	var bullet = rangedProjectile.instantiate() as Area2D
	bullet.set_rotation_degree = player_rotation + 90
	bullet.set_direction = player_direction
	bullet.position = player_position
	$ProjectileTemp.add_child(bullet,true)

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

# This dont have node connect signals shown but still work as intended because it connected from spawned scene
#func _on_boss_create_crystal(spawn_position):
	#var boss_crystal = boss_crystalSpire.instantiate() as StaticBody2D
	#boss_crystal.position = spawn_position
	#$EnemyStaticObject.add_child(boss_crystal,true)

func _on_enemy_day_melee_enemy_melee_attack(enemy_position, target_direction):
	var enemy_meleeDay = enemy_meleeDayProjectile.instantiate() as Area2D
	enemy_meleeDay.position = enemy_position
	enemy_meleeDay.set_rotation_degree = rad_to_deg(target_direction.angle()) - 90
	$EnemyProjectileTemp.add_child(enemy_meleeDay,true)
