extends CharacterBody2D

# --------------------------------------------------------------------------
# Signal that player character emit. This signal are being used in the level scene
# --------------------------------------------------------------------------

signal mouse1_melee(player_position, player_rotation, player_direction)
signal mouse2_melee(player_position, player_rotation, player_direction)
signal mouse1_ranged(player_position, player_rotation, player_direction)
signal mouse2_ranged(player_position, player_rotation, player_direction, is_Charged)

@onready var ui_path = get_node("/root/Scene/UI")
@onready var ui_worldType = $"../UI/%WorldTypeUI"
@onready var ui_playerHealth = $"../UI/%PlayerHealthUI"
@onready var ui_playerDash = $"../UI/%PlayerDashUI"
@onready var ui_playerRangedAmmo = $"../UI/%PlayerRangedAmmoUI"
@onready var ui_playerRangedSpecialAttack = $"../UI/%PlayerRangedSpecialAttackUI"
@onready var ui_playerMeleeEquipped = $"../UI/%PlayerMeleeEquippedUI"
@onready var ui_playerMeleeSpecialAttack = $"../UI/%PlayerMeleeSpecialAttackUI"
signal ui_feedback(ui_name)

@onready var scene = get_node("/root/Scene/")
signal scene_change_world_type()

# This is signal used in itself for calling other method
signal update_movement()

# --------------------------------------------------------------------------
# Player character property are listed and set with type and value here
# --------------------------------------------------------------------------

# Player movement speed are listed here
const move_speed: float = 128.0
var speed_modifier: float = 1.5
const speed_modifierDefault: float = 1.5
@export var player_moveSpeed: float = move_speed * speed_modifier
var player_moveSpeedDefault: float = move_speed * speed_modifier
# This being used in _movement() for user input
var direction: Vector2
# This being used in _ranged() for reloading and auto-reload feature
var player_isEmptyReloading: bool = false
var player_isAddingAmmo: bool = false
# This being used in _ranged() for special attack
var player_isCasting: bool = false
var is_Charged: bool = false
# This is for knockback and go together with _movement() to check for any knockbacks
var knockback_tweenValue: Vector2 = Vector2(0,0)
# This used for interaction
var player_canInteract: bool = false
var interactable_temp
signal player_interact(interactable_temp)
# --------------------------------------------------------------------------
# Function of _ready() and _physics_process() are listed below:
# --------------------------------------------------------------------------

func _ready():
	# Set color for filter and visibility for the weapon according to the world type
	$Filter.color = Color("#db9042")
	$Weapon/MeleeWeapon.show()
	$Weapon/RangedWeapon.hide()
	$Weapon/RangedWeapon/ChargingParticles.emitting = false
	# Set the values of the player health (Should move the health into UIs node)
	ui_playerHealth.max_value = Global.player_healthMax
	ui_playerRangedAmmo.max_value = Global.player_ammoMax

func _physics_process(_delta):
	# Update the player health value all the time
	ui_playerHealth.value = Global.player_health
	ui_playerRangedAmmo.value = Global.player_ammo
	# Set the location for melee projectile to spawn by using hit marker
	Global.player_position = global_position
	Global.player_meleeSlashSpawn = $Weapon/MeleeSlashSpawn.global_position
	Global.player_rotation = rotation_degrees
	# Below are function for process
	_loot_at()
	_movement()
	_swap_world_type()
	_melee()
	_dash()
	_ranged()
	_update_animation()
	_interact()

# --------------------------------------------------------------------------
# Function of _movement() (This function move the player around based on user-input)
# --------------------------------------------------------------------------

func _update_movement(method: String = "update", speed_modifierTemp: float = 0):
	# Set default state of the function if no param is specified
	if method == "update":
		# Update the movement to current 'speed_modifier'
		player_moveSpeed = move_speed * speed_modifier
	elif method == "set":
		# Update the movement to new set 'speed_modifier'
		speed_modifier = speed_modifierTemp
		player_moveSpeed = move_speed * speed_modifier
	print(player_moveSpeed)
	print(speed_modifier)

func _movement():
	# To change movement speed if player is casting fireball
	# This make the dash UNUSABLE.
	#if player_isCasting == true:
		#player_moveSpeed = 75
	#elif player_isCasting == false:
		#player_moveSpeed = player_moveSpeedDefault
		
	# Get the user input and move the player character accordingly
	direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * player_moveSpeed + knockback_tweenValue
	# Play step sfx when the player is moving
	if Input.is_action_pressed("move_down") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up"):
		if $Timer/StepSfxCooldown.time_left <= 0:
			var StepSfx = $StepSfx.get_children()
			var StepSfxPicker = StepSfx[randi() % StepSfx.size()]
			StepSfxPicker.volume_db = 20
			StepSfxPicker.pitch_scale = randf_range(0.8, 1.2)
			StepSfxPicker.play()
			$Timer/StepSfxCooldown.start(0.4)
	# This is the main function that move the player around with _physic_process()
	move_and_slide()

# --------------------------------------------------------------------------
# Function of _swap_world_type() (This function change world property by user input)
# Also being use here: _swap_world_type_to_day() and _swap_world_type_to_night()
# This also send out a signal into the scene to run _change_world_type() function
# --------------------------------------------------------------------------

func _swap_world_type():
	# Animation problem of smooth modulating the color because the tilemaps are two different thing, day and night
	# Swap world type to night
	if Input.is_action_just_pressed("swap") and Global.worldType == "Day" and Global.player_ableToSwapWorld == true:
		# Animation world filter with tween
		var filterTween = get_tree().create_tween()
		filterTween.tween_property($Filter, "color", Color("#17a995"), 1)
		_swap_world_type_to_night()
		# Signal to scene to change the world type
		connect("scene_change_world_type", Callable(scene, "_change_world_type"), 4)
		scene_change_world_type.emit()
	# Swap world type to day
	elif Input.is_action_just_pressed("swap") and Global.worldType == "Night" and Global.player_ableToSwapWorld == true:
		# Animation world filter with tween
		var filterTween = get_tree().create_tween()
		filterTween.tween_property($Filter, "color", Color("#db9042"), 1)
		_swap_world_type_to_day()
		# Signal to scene to change the world type
		connect("scene_change_world_type", Callable(scene, "_change_world_type"), 4)
		scene_change_world_type.emit()
	# Set the progress value with timer time_left (this isnt dynamic and will break when you change the timer. Set for 5s)
	ui_worldType.value = 100 - $Timer/SwapWorldCooldown.time_left * 20

func _swap_world_type_to_day():
	# Show melee weapon in day
	$Weapon/MeleeWeapon.show()
	$Weapon/RangedWeapon.hide()
	# Change the world type and change the value in globals
	Global.worldType = "Day"
	Global.player_ableToSwapWorld = false
	Global.player_ableToMelee = true
	Global.player_ableToShoot = false
	# IS THIS EVEN NEEDED ANYMORE? WE ONLY USING 1 TILEMAP FOR NOW
	# Change the collision mask of the player suitable for day worldType
	#set_collision_mask_value(2, true)
	#set_collision_mask_value(3, false)
	# Start the timer for world swap
	$Timer/SwapWorldCooldown.start()

func _swap_world_type_to_night():
	# Show ranged weapon in day
	$Weapon/MeleeWeapon.hide()
	$Weapon/RangedWeapon.show()
	# Change the world type and change the value in globals
	Global.worldType = "Night"
	Global.player_ableToSwapWorld = false
	Global.player_ableToMelee = false
	Global.player_ableToShoot = true
	# IS THIS EVEN NEEDED ANYMORE? WE ONLY USING 1 TILEMAP FOR NOW
	# Change the collision mask of the player suitable for night worldType
	#set_collision_mask_value(2, false)
	#set_collision_mask_value(3, true)
	# Start the timer for world swap
	$Timer/SwapWorldCooldown.start()

# --------------------------------------------------------------------------
# Function of _look_at() (This function make the player character aim at the mouse position)
# @perrorovic responsible for this
# --------------------------------------------------------------------------

func _loot_at():
	# Weapon will look at the mouse position
	$Weapon.look_at(get_global_mouse_position())
	# Change the location of: character sprite, weapon (with their hit marker as well) based on the position of the mouse
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
		$Weapon/MeleeSlashSpawn.position = Vector2(200,88) # default pos
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
		$Weapon/MeleeSlashSpawn.position = Vector2(200,-88)
		$Weapon/RangedBulletSpawn.position = Vector2(152,-96)

# --------------------------------------------------------------------------
# Player action function are listed below:
# --------------------------------------------------------------------------

# This function make player weapon move as in stabbing and recoil motion 
# being used in _melee() and _ranged() function
func _weapon_stroke(player_direction: Vector2, stroke_power: int):
	var weaponTrustTween = get_tree().create_tween()
	var weaponTrustPower = player_direction * stroke_power
	# Time are set manually for each move
	weaponTrustTween.tween_property($Weapon, "position", weaponTrustPower, 0.2)
	weaponTrustTween.tween_property($Weapon, "position", Vector2(0,0), 0.2)

# This function make the melee projectile for the player character action
func _melee():
	#Basic Attack (Thrust)
	if Input.is_action_pressed("mouse1") and Global.player_ableToMelee == true and Global.worldType == "Day":
		Global.player_ableToMelee = false
		var player_direction = (get_global_mouse_position() - position).normalized()
		# Create animation with tween to weapon move while still maintaining look_at() func
		_weapon_stroke(player_direction, 10)
		mouse1_melee.emit($Weapon/MeleeSlashSpawn.global_position, $Weapon.rotation_degrees, player_direction)
		$Timer/MeleeCooldown.start(0.4)
	#Special Attack (Throw) then cannot attack for certain duration until weapon spawn back
	elif Input.is_action_pressed("mouse2") and Global.player_ableToMelee == true and Global.player_ableToThrow == true and Global.worldType == "Day":
		Global.player_ableToMelee = false
		Global.player_ableToThrow = false
		$Weapon/MeleeWeapon.hide()
		var player_direction = (get_global_mouse_position() - position).normalized()
		# Create animation with tween to weapon move while still maintaining look_at() func
		_weapon_stroke(player_direction, 10)
		mouse2_melee.emit($Weapon/MeleeSlashSpawn.global_position, $Weapon.rotation_degrees, player_direction)
		#MeleeCooldown timer started by Melee_Throw after it hit wall/enemy/after timed out (3s)
		$Timer/ThrowCooldown.start()
		ui_playerMeleeEquipped.modulate = Color("#4a4a4a")
		
		#$Timer/MeleeCooldown.start(2)

# This function make the ranged projectile for the player character action
# @kepponn are responsible for this one
func _ranged():
	ui_playerRangedAmmo.value = Global.player_ammo
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
		
		
	# --------------------------------------------------------------------------
	# Special Attack (Fireball) deal AoE damage around the explosion (Knockback still bugged)
	# --------------------------------------------------------------------------
	# After mouse2 is pressed (only triggered once because we using casting timer otherwise it will keep reseting) character will start casting
	if Input.is_action_just_pressed("mouse2") and Global.player_ableToFireball == true and player_isCasting == false and Global.worldType == "Night":
		Global.player_ableToShoot = false
		player_isCasting = true
		# Using speed_modifier to change the speed
		connect("update_movement", Callable(self, "_update_movement") , 4)
		update_movement.emit("set" ,0.5)
		# Set the default state of the particles
		$Weapon/RangedWeapon/ChargingParticles.emitting = true
		$Weapon/RangedWeapon/ChargingParticles.self_modulate = Color("ffffff")
		$Timer/CastingTime.start()
	
	# After mouse2 is released, will emit signal depending on if player is done casting or not yet
	if Input.is_action_just_released("mouse2") and player_isCasting == true:
		Global.player_ableToFireball = false
		# Revert to default speed modifier
		connect("update_movement", Callable(self, "_update_movement") , 4)
		update_movement.emit("set", speed_modifierDefault)
		var player_direction = (get_global_mouse_position() - position).normalized()
	#	send signal into ["res://Main.gd"] script to spawn ranged bullet based on these parameter
	#	all parameter will be set into ["res://Scene/BulletProjectile.gd"] in there
		# Create animation with tween to weapon move while still maintaining look_at() func
		_weapon_stroke(player_direction, -3)
		
		# if casting is not done yet, it will release normal fireball,
		if $Timer/CastingTime.time_left > 0:
			print("Fireball")
			is_Charged = false
			mouse2_ranged.emit($Weapon/RangedBulletSpawn.global_position, $Weapon.rotation_degrees, player_direction, is_Charged)
		# if casting is done, it will cast enhanced fireball which will have different sprite, more damage, larger AoE, and higher knockback power
		elif $Timer/CastingTime.time_left <= 0:
			print("Charged Fireball")
			is_Charged = true
			mouse2_ranged.emit($Weapon/RangedBulletSpawn.global_position, $Weapon.rotation_degrees, player_direction, is_Charged)
		
		#RangedCooldown timer is used on time out to change Global.player_ableToShoot to true 
		#RangedCooldown is basically used to add delay time between spawning each bullet	
		$Timer/FireballCooldown.start()
		$Timer/RangedCooldown.start()
		player_isCasting = false
		$Weapon/RangedWeapon/ChargingParticles.emitting = false

# This function make the player dash with immunity frame
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
		ui_playerDash.value = ui_playerDash.max_value * (1 - $Timer/DashCooldown.time_left / $Timer/DashCooldown.wait_time)

# --------------------------------------------------------------------------
# Function of player that being called by other entities such as: enemies and items pickups
# List of the function: _player_hit(), _knockback(), _on_items_pickup()
# --------------------------------------------------------------------------

# This function are being called by enemy projectile into the player
func _player_hit(damage):
	# This tween give the feedback of being hit
	var hit_feedback_tween
	hit_feedback_tween = get_tree().create_tween()
	hit_feedback_tween.tween_property($Sprite, "modulate", Color("#ff113f"), 0.1)
	hit_feedback_tween.tween_property($Sprite, "modulate", Color("#ffffff"), 0.1)
	# This decrease the player health by the damage received
	Global.player_health -= damage
	if Global.player_health <= 0:
		_dead()

# This function are being called by enemy projectile into the player
func _knockback(set_direction, knockback_power):
	var knockback = set_direction * knockback_power
	knockback_tweenValue = knockback
	var knockback_tween = get_tree().create_tween()
	knockback_tween.parallel().tween_property(self, "knockback_tweenValue", Vector2(0,0), 0.25)

# This one is being called by _player_hit() if health reaches 0
func _dead():
	# Reset position of the player into the latest spawn point
	position = Global.player_spawnpoint
	# Reset player health to full
	Global.player_health = Global.player_healthMax
	# Play animation death and reset to middle
	# Animation death is simple foreground color that dim to black
	# Show key to respawn

# This function being called by the items to the player character to refill resources
func _on_items_pickup(type):
	print(type)
	if type == "health":
		Global.player_health += 25
	elif type == "dash":
		$Timer/DashCooldown.stop()
		Global.player_ableToDash = true
		ui_playerDash.value = ui_playerDash.max_value
	elif type == "ammo":
		$Timer/ReloadTickCooldown.stop()
		Global.player_ammo = Global.player_ammoMax
		ui_playerRangedAmmo.value = Global.player_ammoMax
		Global.player_ableToShoot = true
	
# --------------------------------------------------------------------------
# Function of _update_animation() (Animation of the character are being add and modify here)
# @kepponn are responsible for this
# --------------------------------------------------------------------------

func _update_animation():
	#Update Special Attack UI Cooldown | Set wait_time on timer, currently at 10s
	ui_playerMeleeSpecialAttack.value = $Timer/ThrowCooldown.wait_time - $Timer/ThrowCooldown.time_left
	ui_playerRangedSpecialAttack.value = $Timer/FireballCooldown.wait_time - $Timer/FireballCooldown.time_left
	
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
	
	# UI on cooldown and get pressed then do feedback animation
	# BUG where when pressed for the first time for the action it blink red
	# Maybe add a timer check for it
	if Global.player_ableToSwapWorld == false and Input.is_action_just_pressed("swap") and $Timer/SwapWorldCooldown.time_left < $Timer/SwapWorldCooldown.wait_time:
		connect("ui_feedback", Callable(ui_path, "_ui_feedback"), 4)
		ui_feedback.emit(ui_worldType)
	if Global.player_ableToDash == false and Input.is_action_just_pressed("dash") and $Timer/DashDuration.time_left < $Timer/DashDuration.wait_time:
		connect("ui_feedback", Callable(ui_path, "_ui_feedback"), 4)
		ui_feedback.emit(ui_playerDash)
	# What the timer for player_isEmptyReloading action?
	if player_isEmptyReloading == true and Input.is_action_just_pressed("mouse1") and $Timer/ReloadAutoCooldown.time_left < $Timer/ReloadAutoCooldown.wait_time:
		connect("ui_feedback", Callable(ui_path, "_ui_feedback"), 4)
		ui_feedback.emit(ui_playerRangedAmmo)
	if Global.player_ableToThrow == false and Input.is_action_just_pressed("mouse2") and $Timer/ThrowCooldown.time_left < $Timer/ThrowCooldown.wait_time:
		connect("ui_feedback", Callable(ui_path, "_ui_feedback"), 4)
		ui_feedback.emit(ui_playerMeleeSpecialAttack)
	if Global.player_ableToFireball == false and Input.is_action_just_pressed("mouse2") and $Timer/FireballCooldown.time_left < $Timer/FireballCooldown.wait_time:
		connect("ui_feedback", Callable(ui_path, "_ui_feedback"), 4)
		ui_feedback.emit(ui_playerRangedSpecialAttack)
	# Fuck animation
	#if UI on cooldown and get pressed then do feedback animation
	#if Global.player_ableToDash == false and Input.is_action_just_pressed("dash"):
		#$"../UI/PlayerDash/UIDashAnimation".play("unable_dash")
	#if player_isEmptyReloading == true and Input.is_action_just_pressed("mouse1"):
		#$"../UI/PlayerRanged/UIAmmoAnimation".play("unable_shoot")
	#if Global.player_ableToSwapWorld == false and Input.is_action_just_pressed("swap"):
		#$"../UI/WorldType/UIWorldAnimation".play("unable_change")
	#if Global.player_ableToThrow == false and Input.is_action_just_pressed("mouse2"):
		#$"../UI/PlayerMelee/UISpecialAttackAnimation".play("unable_special")
	#if Global.player_ableToFireball == false and Input.is_action_just_pressed("mouse2"):
		#$"../UI/PlayerRanged/UISpecialAttackAnimation".play("unable_special")

# --------------------------------------------------------------------------
# Timer with signal feedback that being used by the player character
# Please note that some timer will be used without the signal feedback!
# DO NOT DELETE ANY TIMER (ask for permission for it and review what it does)
# --------------------------------------------------------------------------

func _on_swap_world_cooldown_timeout():
	Global.player_ableToSwapWorld = true

func _on_melee_cooldown_timeout():
	Global.player_ableToMelee = true
	# FIXED - Bug showing both weapon if the melee is thrown and world change to night
	# Because of this didnt check the world type before setting the visible property
	if $Weapon/MeleeWeapon.visible == false and Global.worldType == "Day":
		$Weapon/MeleeWeapon.visible = true
		ui_playerMeleeEquipped.modulate = Color("#ffffff")

func _on_throw_cooldown_timeout():
	Global.player_ableToThrow = true

func _on_ranged_cooldown_timeout():
	Global.player_ableToShoot = true

func _on_casting_timeout():
	# Sending different color particle for charged fireball
	# Should be better if you could check for the time and change the color slowly
	# and pop a flash on the staff to indicate the fireball is fully charged
	$Weapon/RangedWeapon/ChargingParticles.self_modulate = Color("ff0000")

func _on_fireball_cooldown_timeout():
	Global.player_ableToFireball = true

func _on_dash_duration_timeout():
	# This update the movement speed to the CURRENT state (with param '0')
	# For example if the movement is slowed then it will return the movement with the slowed stats as well
	# This signal + function did not MUTATE any VARIABLES!
	connect("update_movement", Callable(self, "_update_movement") , 4)
	update_movement.emit()
	set_collision_mask_value(1, true)

func _on_dash_cooldown_timeout():
	Global.player_ableToDash = true

func _on_interaction_area_body_entered(body):
	print("body entered")
	player_canInteract = true
	interactable_temp = body
	
func _on_interaction_area_body_exited(body):
	player_canInteract = false
	
func _interact():
	if player_canInteract == true:
		print(interactable_temp.name)
		player_interact.emit(interactable_temp)
		



