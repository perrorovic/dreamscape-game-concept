extends Node2D

#https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_exports.html#examples #export documentation, goodshit
#How to create dropdown selection in inspector
#@export_enum("selection 1", "selection 2", "selection 3") var selection_name: int #return array number. ex: if "selection 1" will return 0, and so on
#@export_enum("Slow:30", "Average:60", "Very Fast:200") var character_speed: int #return explicit value. ex: if selection "slow" will return 30, and so on
#@export_enum("Rebecca", "Mary", "Leah") var character_name: String #return string name. ex: if selection "Rebecca" will return "Rebecca", and so on
#@export_enum("Rebecca", "Mary", "Leah") var character_name: String = "Rebecca" #same as before but have default value "Rebecca"

@export var rate_item: Dictionary = {
	"HP": {"Rate": 1, "TotalHpHealed": 2},
	"Ammo": {"Rate": null, "TotalAmmoDrop": null}
}

# Player projectile
var meleeProjectile: PackedScene = preload("res://scene/character/Melee_Projectile.tscn")
var meleeNew: PackedScene = preload("res://scene/character/Melee_Trust.tscn")
var rangedProjectile: PackedScene = preload("res://scene/character/Bullet_Projectile.tscn")

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

# World initiation
var sun: Texture2D = preload("res://assets/ui/sun.png")
#var sunModulate: Color = Color("#db9042")
var moon: Texture2D = preload("res://assets/ui/fullmoon.png")
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

func _on_player_mouse1_melee(player_position, player_rotation, player_direction):
	var melee = meleeNew.instantiate() as Area2D
	melee.set_direction = player_direction
	melee.position = player_position
	melee.set_rotation_degree = player_rotation
	$ProjectileTemp.add_child(melee,true)
	#var melee = meleeProjectile.instantiate() as Area2D
	#melee.set_direction = player_direction
	#melee.position = player_position
	#melee.rotation_degrees = player_rotation - 90
	#$ProjectileTemp.add_child(melee,true)

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

# enemy signal with inheritance:
func _on_enemy_melee_attack(enemy_position, target_direction):
	var enemy_meleeDay = enemy_meleeDayProjectile.instantiate() as Area2D
	enemy_meleeDay.position = enemy_position
	enemy_meleeDay.set_direction = target_direction
	enemy_meleeDay.set_rotation_degree = rad_to_deg(target_direction.angle()) - 90
	$EnemyProjectileTemp.call_deferred("add_child",enemy_meleeDay,true)
	#$EnemyProjectileTemp.add_child(enemy_meleeDay,true)

func _on_enemy_ranged_attack(enemy_position, target_direction):
	var enemy_rangedDay = enemy_rangedDayProjectile.instantiate() as Area2D
	enemy_rangedDay.position = enemy_position
	enemy_rangedDay.set_rotation_degree = rad_to_deg(target_direction.angle()) - 90
	enemy_rangedDay.set_direction = target_direction
	$EnemyProjectileTemp.call_deferred("add_child",enemy_rangedDay,true)
	#$EnemyProjectileTemp.add_child(enemy_rangedDay,true)

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
