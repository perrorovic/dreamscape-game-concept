extends CharacterBody2D

@export var player_moveSpeed: float = 128.0
const player_moveSpeedDefault: float = 128.0

signal mouse1_melee(player_position, player_rotation)
signal mouse1_ranged(player_position, player_rotation, player_direction)

func _ready():
	# Should move the health into UIs node
	$"../UI/PlayerHealth/Progress".max_value = Global.player_health
	$SwapAnimation/SwapTransisition.color = Color("#ffffff00")
	$CanvasModulate.color = Color("#db9042")

func _physics_process(_delta):
	$"../UI/PlayerHealth/Progress".value = Global.player_health
	# Set location for melee slash to spawn
	Global.player_position = global_position
	Global.player_meleeSlashSpawn = $MeleeSlashSpawn.global_position
	Global.player_rotation = rotation_degrees
	# Player directional aim to mouse position
	look_at(get_global_mouse_position())
	# Below are function for process
	_movement()
	_swap_world_type()
	_melee()
	_dash()
	_ranged()

func _movement():
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction * player_moveSpeed
	#	if Input.is_action_just_pressed("move_Down"):
#		$Sprite2D.rotation_degrees = 180
#	if Input.is_action_just_pressed("move_Up"):
#		$Sprite2D.rotation_degrees = 0
#	if Input.is_action_just_pressed("move_Left"):
#		$Sprite2D.rotation_degrees = 270
#	if Input.is_action_just_pressed("move_Right"):
#		$Sprite2D.rotation_degrees = 90
	# Play step SFX
	if Input.is_action_pressed("move_down") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up"):
		if $StepSfxCooldown.time_left <= 0:
			var StepSfx = $StepSfx.get_children()
			var StepSfxPicker = StepSfx[randi() % StepSfx.size()]
			StepSfxPicker.volume_db = 20
			StepSfxPicker.pitch_scale = randf_range(0.8, 1.2)
			StepSfxPicker.play()
			$StepSfxCooldown.start(0.4)
	move_and_slide()

func _swap_world_type():
	if Input.is_action_just_pressed("swap") and Global.worldType == "Day" and Global.player_ableToSwapWorld == true:
		_swap_world_type_to_night()
#		$SwapAnimation/SwapToNight.play("swap_to_night")
	elif Input.is_action_just_pressed("swap") and Global.worldType == "Night" and Global.player_ableToSwapWorld == true:
		_swap_world_type_to_day()
#		$SwapAnimation/SwapToDay.play("swap_to_day")
	# Set the progress value with timer time_left 
	# (this isnt dynamic and will break when you change the timer. Set for 5s)
	$"../UI/WorldType/Progress".value = 100 - $"../AbleToSwapWorldTimer".time_left * 20

func _swap_world_type_to_night():
	$SwapRipple/Swap.play("swap_animation")
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
	$SwapRipple/Swap.play_backwards("swap_animation")
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
#	print("Player is hit!")
	Global.player_health -= damage
	if Global.player_health <= 0:
		_dead()

func _dead():
	# Reset position into the middle for now
	position = Vector2(-17,-16)
	# Reset player health
	Global.player_health = 200
	# Play animation death and reset to middle

func _melee():
	if Input.is_action_pressed("mouse1") and Global.player_ableToMelee == true and Global.worldType == "Day":
		Global.player_ableToMelee = false
		mouse1_melee.emit($MeleeSlashSpawn.global_position, rotation_degrees)

func _dash():
	if Input.is_action_pressed("move_down") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right") or Input.is_action_pressed("move_up"):
		if Input.is_action_just_pressed("mouse2") and Global.player_ableToDash == true : #and Global.worldType == "Day":
			$DashDuration.start()
			$DashCooldown.start()
			Global.player_ableToDash = false
			player_moveSpeed += 1500
			set_collision_mask_value(1, false)

func _ranged():
	if Input.is_action_pressed("mouse1") and Global.player_ableToShoot == true and Global.worldType == "Night":
		$RangedCooldown.start()
		Global.player_ableToShoot = false
		var player_direction = (get_global_mouse_position() - position).normalized()
#		send signal into ["res://Main.gd"] script to spawn ranged bullet based on these parameter
#		all parameter will be set into ["res://Scene/BulletProjectile.gd"] in there
		mouse1_ranged.emit($RangedBulletSpawn.global_position, rotation_degrees, player_direction)

func _on_able_to_swap_world_timer_timeout():
	Global.player_ableToSwapWorld = true

func _on_ranged_cooldown_timeout():
	Global.player_ableToShoot = true

func _on_dash_duration_timeout():
	player_moveSpeed = player_moveSpeedDefault
	set_collision_mask_value(1, true)

func _on_dash_cooldown_timeout():
	Global.player_ableToDash = true

func _on_swap_to_night_animation_finished(_anim_name):
	_swap_world_type_to_night()
	$SwapAnimation/ToVisible.play("to_visible")

func _on_swap_to_day_animation_finished(_anim_name):
	_swap_world_type_to_day()
	$SwapAnimation/ToVisible.play("to_visible")
