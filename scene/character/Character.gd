extends CharacterBody2D

@export var player_moveSpeed: float = 128.0*1.5
const player_moveSpeedDefault: float = 128.0*1.5
var direction: Vector2

var player_isEmptyReloading: bool = false
#var player_isReloadingType: String
var player_isAddingAmmo: bool = false
# Empty | Chilling

var knockback_tween
var knockback_tweenValue: Vector2 = Vector2(0,0)

signal mouse1_melee(player_position, player_rotation, player_direction)
signal mouse1_ranged(player_position, player_rotation, player_direction)

func _ready():
	$Weapon/MeleeWeapon.show()
	$Weapon/RangedWeapon.hide()
	# Should move the health into UIs node
	$"../UI/PlayerHealth/Progress".max_value = Global.player_healthMax
	$"../UI/PlayerAmmo/Progress".max_value = Global.player_ammoMax
	$Filter.color = Color("#db9042")

func _physics_process(_delta):
	$"../UI/PlayerHealth/Progress".value = Global.player_health
	$"../UI/PlayerAmmo/Progress".value = Global.player_ammo
	# Set location for melee slash to spawn
	Global.player_position = global_position
	Global.player_meleeSlashSpawn = $Weapon/MeleeSlashSpawn.global_position
	Global.player_rotation = rotation_degrees
	# Player directional aim to mouse position
	_loot_at()
	# Below are function for process
	_movement()
	_swap_world_type()
	_melee()
	_dash()
	_ranged()
	_update_animation()

func _movement():
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * player_moveSpeed + knockback_tweenValue
	# Play step SFX
	if Input.is_action_pressed("move_down") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up"):
		if $Timer/StepSfxCooldown.time_left <= 0:
			var StepSfx = $StepSfx.get_children()
			var StepSfxPicker = StepSfx[randi() % StepSfx.size()]
			StepSfxPicker.volume_db = 20
			StepSfxPicker.pitch_scale = randf_range(0.8, 1.2)
			StepSfxPicker.play()
			$Timer/StepSfxCooldown.start(0.4)
			
		
	move_and_slide()

func _swap_world_type():
	# Animation problem of smooth modulating the color because the tilemaps are two different thing, day and night
	# Swap world type to night
	if Input.is_action_just_pressed("swap") and Global.worldType == "Day" and Global.player_ableToSwapWorld == true:
		# Animation world type filter with tween
		var filterTween = get_tree().create_tween()
		filterTween.tween_property($Filter, "color", Color("#17a995"), 1)
		_swap_world_type_to_night()
	# Swap world type to day
	elif Input.is_action_just_pressed("swap") and Global.worldType == "Night" and Global.player_ableToSwapWorld == true:
		# Animation world type filter with tween
		var filterTween = get_tree().create_tween()
		filterTween.tween_property($Filter, "color", Color("#db9042"), 1)
		_swap_world_type_to_day()
	# Set the progress value with timer time_left 
	# (this isnt dynamic and will break when you change the timer. Set for 5s)
	$"../UI/WorldType/Progress".value = 100 - $"../AbleToSwapWorldTimer".time_left * 20

func _update_animation():
	
	#Set animation to walking or idling
	#Set Dust Particles to spawn if player is moving
	if velocity == Vector2.ZERO:
		$AnimationTree.set("parameters/conditions/IsIdle", true)
		$AnimationTree.set("parameters/conditions/IsWalking", false)
		$GPUParticles2D.emitting = false
	else:
		$AnimationTree.set("parameters/conditions/IsIdle", false)
		$AnimationTree.set("parameters/conditions/IsWalking", true)
		$GPUParticles2D.emitting = true
	
	#To modify the dash afterimage particle need to change the dash property (dashdurationtimer and dash power on _dash())
	if $Timer/DashDuration.time_left > 0:
		$Dash_Afterimage.emitting = true
	else:
		$Dash_Afterimage.emitting = false
	#To flip afterimage particles to match the character
	if get_global_mouse_position().x > position.x:
		$Dash_Afterimage.scale.x = -1
	if get_global_mouse_position().x < position.x:
		$Dash_Afterimage.scale.x = 1
	
	#if UI on cooldown and get pressed then do feedback animation
	if Global.player_ableToDash == false and Input.is_action_just_pressed("dash"):
		$"../UI/UIAnimation2".play("unable_dash")

	if player_isEmptyReloading == true and Input.is_action_just_pressed("mouse1"):
		$"../UI/UIAnimation3".play("unable_shoot")

	if Global.player_ableToSwapWorld == false and Input.is_action_just_pressed("swap"):
		$"../UI/UIAnimation4".play("unable_change")

func _swap_world_type_to_night():
	$Weapon/MeleeWeapon.hide()
	$Weapon/RangedWeapon.show()
	# Change the world type and change the value in globals
	Global.worldType = "Night"
	Global.player_ableToSwapWorld = false
	Global.player_ableToMelee = false
	Global.player_ableToShoot = true
	# Change the collision mask of the player suitable for night worldType
	set_collision_mask_value(2, false)
	set_collision_mask_value(3, true)
	# Start the timer for world swap
	$"../AbleToSwapWorldTimer".start()

func _swap_world_type_to_day():
	$Weapon/MeleeWeapon.show()
	$Weapon/RangedWeapon.hide()
	# Change the world type and change the value in globals
	Global.worldType = "Day"
	Global.player_ableToSwapWorld = false
	Global.player_ableToMelee = true
	Global.player_ableToShoot = false
	# Change the collision mask of the player suitable for day worldType
	set_collision_mask_value(2, true)
	set_collision_mask_value(3, false)
	# Start the timer for world swap
	$"../AbleToSwapWorldTimer".start()

func _player_hit(damage):
	var hit_feedback_tween
	hit_feedback_tween = get_tree().create_tween()
	hit_feedback_tween.tween_property($Sprite, "modulate", Color("#ff113f"), 0.1)
	hit_feedback_tween.tween_property($Sprite, "modulate", Color("#ffffff"), 0.1)
#	print("Player is hit!")

	Global.player_health -= damage
	if Global.player_health <= 0:
		_dead()

func _dead():
	# Reset position into the middle for now
	position = Global.player_spawnpoint
	# Reset player health
	Global.player_health = Global.player_healthMax
	# Play animation death and reset to middle
	# Animation death is simple foreground color that dim to black
	# Show key to respawn

func _knockback(set_direction, knockback_power):
	var knockback = set_direction * knockback_power
	knockback_tweenValue = knockback
	knockback_tween = get_tree().create_tween()
	knockback_tween.parallel().tween_property(self, "knockback_tweenValue", Vector2(0,0), 0.25)
	#global_position += knockback

func _loot_at():
	$Weapon.look_at(get_global_mouse_position())
	#print(get_global_mouse_position())
	#print($Weapon/MeleeWeapon.position)
	if get_global_mouse_position().x > position.x:
		# character body
		$Sprite/Body.flip_h = true # default 
		$Sprite/Head.flip_h = true # default 
		$Weapon/Hand.flip_h = true # default 
		$Weapon/Hand.rotation_degrees = 102
		# melee and ranged weapon asset
		$Weapon/MeleeWeapon.flip_v = false
		$Weapon/MeleeWeapon.position = Vector2(82,90) # default pos
		$Weapon/RangedWeapon.flip_v = false
		$Weapon/RangedWeapon.position = Vector2(74,90) # default pos
		# hitbox relocation
		$Weapon/MeleeSlashSpawn.position = Vector2(152,96) # default pos
		$Weapon/RangedBulletSpawn.position = Vector2(152,96) # default pos
	elif get_global_mouse_position().x < position.x:
		# character body
		$Sprite/Body.flip_h = false
		$Sprite/Head.flip_h = false
		$Weapon/Hand.flip_h = false
		$Weapon/Hand.rotation_degrees = 80
		# melee and ranged weapon asset
		$Weapon/MeleeWeapon.flip_v = true
		$Weapon/MeleeWeapon.position = Vector2(82,-90)
		$Weapon/RangedWeapon.flip_v = false
		$Weapon/RangedWeapon.position = Vector2(74,-90)
		# hitbox relocation
		$Weapon/MeleeSlashSpawn.position = Vector2(152,-96)
		$Weapon/RangedBulletSpawn.position = Vector2(152,-96)

func _weapon_stroke(player_direction: Vector2, stroke_power: int):
	var weaponTrustTween = get_tree().create_tween()
	var weaponTrustPower = player_direction * stroke_power
	# Time are set manually for each move
	weaponTrustTween.tween_property($Weapon, "position", weaponTrustPower, 0.2)
	weaponTrustTween.tween_property($Weapon, "position", Vector2(0,0), 0.2)

func _melee():
	if Input.is_action_pressed("mouse1") and Global.player_ableToMelee == true and Global.worldType == "Day":
		Global.player_ableToMelee = false
		var player_direction = (get_global_mouse_position() - position).normalized()
		# Create animation with tween to weapon move while still maintaining look_at() func
		_weapon_stroke(player_direction, 10)
		mouse1_melee.emit($Weapon/MeleeSlashSpawn.global_position, $Weapon.rotation_degrees, player_direction)
		$Timer/MeleeCooldown.start()

func _dash():
	if Input.is_action_pressed("move_down") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up"):
		if Input.is_action_just_pressed("dash") and Global.player_ableToDash == true : #and Global.worldType == "Day":
			$Timer/DashDuration.start()
			$Timer/DashCooldown.start()
			Global.player_ableToDash = false
			#default Timer = 0.05, Mvspd = 1500, fixed FPS 30
			#default2 Timer = 0.3, Mvspd = 500, fixed FPS 30
			player_moveSpeed += 750 #Timer 0.1, fixed FPS 120 much better because afterimage running at 120 fps 
			set_collision_mask_value(1, false)
	if Global.player_ableToDash == false:
		$"../UI/PlayerDash/Progress".value = $"../UI/PlayerDash/Progress".max_value * (1 - $Timer/DashCooldown.time_left / $Timer/DashCooldown.wait_time)

func _ranged():
	$"../UI/PlayerAmmo/Progress".value = Global.player_ammo
	
	#if shooting on any ammo except last ammo (1 ammo or more {2,3,4,5,...} left), auto reload timer will be started
	if Global.player_ammo > 1 and Input.is_action_pressed("mouse1") and Global.player_ableToShoot == true and Global.worldType == "Night":
		Global.player_ableToShoot = false
		var player_direction = (get_global_mouse_position() - position).normalized()
#		send signal into ["res://Main.gd"] script to spawn ranged bullet based on these parameter
#		all parameter will be set into ["res://Scene/BulletProjectile.gd"] in there
		# Create animation with tween to weapon move while still maintaining look_at() func
		_weapon_stroke(player_direction, -3)
		mouse1_ranged.emit($Weapon/RangedBulletSpawn.global_position, $Weapon.rotation_degrees, player_direction)
		Global.player_ammo -= 1
		player_isAddingAmmo = false
		$Timer/ReloadAutoCooldown.start(2.5)
		#RangedCooldown timer is used on time out to change Global.player_ableToShoot to true 
		#RangedCooldown is basically used to add delay time between spawning each bullet
		$Timer/RangedCooldown.start()
		$Timer/ReloadTickCooldown.stop()
	
	#if shooting on last ammo (1 ammo left)
	elif Global.player_ammo == 1 and Input.is_action_pressed("mouse1") and Global.player_ableToShoot == true:
		Global.player_ableToShoot = false
		var player_direction = (get_global_mouse_position() - position).normalized()
#		send signal into ["res://Main.gd"] script to spawn ranged bullet based on these parameter
#		all parameter will be set into ["res://Scene/BulletProjectile.gd"] in there
		# Create animation with tween to weapon move while still maintaining look_at() func
		_weapon_stroke(player_direction, -3)
		mouse1_ranged.emit($Weapon/RangedBulletSpawn.global_position, $Weapon.rotation_degrees, player_direction)
		Global.player_ammo -= 1
		player_isEmptyReloading = true
		$Timer/ReloadTickCooldown.start(1)

	if player_isEmptyReloading == true and player_isAddingAmmo == false and $Timer/ReloadTickCooldown.time_left <= 0:
		print("Empty Reload")
		player_isAddingAmmo = true
		if $Timer/ReloadTickCooldown.time_left <= 0 and Global.player_ammo < Global.player_ammoMax:
			Global.player_ammo += 1
			print("Adding Ammo")
			player_isAddingAmmo = false
		if Global.player_ammo == Global.player_ammoMax:
			Global.player_ableToShoot = true
			player_isEmptyReloading = false
		$Timer/ReloadTickCooldown.start(0.2)
	#dont touch this shiet
	#After idling for 3 second after shooting
	elif $Timer/ReloadAutoCooldown.time_left <= 0 and Global.player_ammo < Global.player_ammoMax and player_isAddingAmmo == false and $Timer/ReloadTickCooldown.time_left <= 0 :
		print("Auto Reload")
		player_isAddingAmmo = true
		if $Timer/ReloadTickCooldown.time_left <= 0 and Global.player_ammo < Global.player_ammoMax:
			Global.player_ammo += 1
			print("Adding Ammo")
			player_isAddingAmmo = false
		$Timer/ReloadTickCooldown.start(0.2)

func _on_items_pickup(type):
	print(type)
	if type == "health":
		Global.player_health += 25
	elif type == "dash":
		$Timer/DashCooldown.stop()
		Global.player_ableToDash = true
		$"../UI/PlayerDash/Progress".value = $"../UI/PlayerDash/Progress".max_value
	elif type == "ammo":
		$Timer/ReloadTickCooldown.stop()
		Global.player_ammo = Global.player_ammoMax
		$"../UI/PlayerAmmo/Progress".value = Global.player_ammoMax
		Global.player_ableToShoot = true
	
func _on_able_to_swap_world_timer_timeout():
	Global.player_ableToSwapWorld = true

func _on_ranged_cooldown_timeout():
	Global.player_ableToShoot = true

func _on_dash_duration_timeout():
	player_moveSpeed = player_moveSpeedDefault
	set_collision_mask_value(1, true)

func _on_dash_cooldown_timeout():
	Global.player_ableToDash = true

func _on_melee_cooldown_timeout():
	Global.player_ableToMelee = true

#TO BE DELETED LATER
#DONT FORGET TO DELETE THIS SHEET AND DISCONNECT THE SIGNAL ON WHOLEMEME/MEME
func _on_meme_body_entered(body):
	$"../WHOLEMEME/VideoStreamPlayer".play()
	$"../WHOLEMEME/Meme".set_collision_mask_value(1, false)
	pass


func _on_meme_2_body_entered(body):
	$"../WHOLEMEME/VideoStreamPlayer2".play()
	$"../WHOLEMEME/Meme2".set_collision_mask_value(1, false)
	pass # Replace with function body.
