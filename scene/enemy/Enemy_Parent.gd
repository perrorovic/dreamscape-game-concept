extends CharacterBody2D
class_name EnemyParent

#
signal item_dropped(item_name, enemy_position)

@export_category("Enemies Property")
# Enemies type and health
@export_enum("Day", "Night") var enemy_type: String
@export var health: float

# This is the default speed of the enemies on their own world type
# And will be reduced if the world type is changed
@export var speed: float
# Neverfucking mind just use this instead
#@export var speed_day: float
#@export var speed_night: float
@export var speed_when_attacking: float = 0

# This is patrol variables
var patrol_speed: float = 0.5
@export var patrol_radius: int = 75
var patrol_random_radius = Vector2(randf_range(-patrol_radius,patrol_radius),randf_range(-patrol_radius,patrol_radius))
var is_patrolling: bool = false

var is_attacking: bool = false

# This variable are being used for navigation and movement
var path_direction
var is_following: bool = false
var movement_speed: float
var move_speed: float

# This variable for item drops
var item_name: String

var iframe: bool

func _ready():
	# Health setter (please call this in the childern scene)
	# $Health.max_value = health
	#if enemy_type == "Day":
		#modulate = Color("fc6e00")
		#$NavigationAgent2D.set_navigation_layer_value(1, true)
		#$NavigationAgent2D.set_navigation_layer_value(2, false)
	#elif enemy_type == "Night":
		#modulate = Color("0bb2cc")
		#$NavigationAgent2D.set_navigation_layer_value(1, false)
		#$NavigationAgent2D.set_navigation_layer_value(2, true)
	pass
func _process(_delta):
	if enemy_type == "Day":
		modulate = Color("fc6e00")
		$NavigationAgent2D.set_navigation_layer_value(1, true)
		$NavigationAgent2D.set_navigation_layer_value(2, false)
		#set_collision_mask_value(2,true)
		#set_collision_mask_value(3,false)
	elif enemy_type == "Night":
		modulate = Color("0bb2cc")
		$NavigationAgent2D.set_navigation_layer_value(1, false)
		$NavigationAgent2D.set_navigation_layer_value(2, true)
		#set_collision_mask_value(2,false)
		#set_collision_mask_value(3,true)
	# Health updater
	$Health.value = health
	# Is this required for melee enemies but not so much on ranged ones
	# There is nothing to set the is_attacking to true or false atm
	#if is_attacking == true:
		#move_speed = speed_when_attacking
	## Need to repair this based on the enemy_type and set the speed accordingly
	#elif Global.worldType == "Day" and is_patrolling == false:
		#move_speed = speed_day
	#elif Global.worldType == "Day" and is_patrolling == true:
		#move_speed = speed_day * patrol_speed
	#elif Global.worldType == "Night" and is_patrolling == false:
		#move_speed = speed_night
	#elif Global.worldType == "Night" and is_patrolling == true:
		#move_speed = speed_night * patrol_speed
		
	
		
		
	
		
	if Global.worldType ==  enemy_type:
		move_speed = speed
	elif Global.worldType != enemy_type:
		move_speed = speed * 0.75
	
	if is_patrolling:
		movement_speed = 50
	elif is_patrolling == false and is_attacking == true:
		movement_speed = speed_when_attacking
	elif is_patrolling == false:
		movement_speed = move_speed
	
	$Sprite2D.look_at($NavigationAgent2D.get_next_path_position())
	path_direction = to_local($NavigationAgent2D.get_next_path_position()).normalized()
	velocity = path_direction * movement_speed

	if !$NavigationAgent2D.is_navigation_finished():
		move_and_slide()
	
	_patrol()
	
	

func _on_pathfinding_cooldown_timeout():
	if is_following == true:
		$NavigationAgent2D.target_position = Global.player_position
		$PathfindingCooldown.start()

func _on_pathfinding_area_body_entered(_body):
	is_following = true
	is_patrolling = false
	
func _on_pathfinding_area_body_exited(_body):
	is_following = false
	$PatrolCooldown.start(5)
			
func _hit(damage: int, iframe_type: String):
	if iframe == false:
		iframe = true
		print("Enemy is hit")
		is_following = true
		is_patrolling = false
		$AggroCooldown.start(5)
		health -= damage
		
		var hit_feedback_tween
		hit_feedback_tween = get_tree().create_tween()
		hit_feedback_tween.tween_property($Sprite2D, "self_modulate", Color("#ff113f"), 0.1)
		hit_feedback_tween.tween_property($Sprite2D, "self_modulate", Color("#ffffff"), 0.1)
		if iframe_type == "melee":
			$IframeDuration.start(0.4)
		elif iframe_type =="ranged":
			$IframeDuration.start(0.1)
	
	# drop chance for each type of the enemies make a function for it and call it with the enemy_type param
	if health <= 0:
		# There's gonna be something more nicer than this right
		var drop_random = randi_range(0,100)
		#No Drop 50%
		if drop_random >= 0 and drop_random < 50:
			print("No Drop")
		#Drop HP 15%
		if drop_random >= 50 and drop_random < 65:
			item_name = "health"
		#Drop Ammo 25%
		if drop_random >= 65 and drop_random < 90:
			item_name = "ammo"
		#Drop Dash 10%
		if drop_random >= 90 and drop_random < 100:
			item_name = "dash"
		# Emit the signal into the level and queue_free the enemies
		print("item dropped")
		item_dropped.emit(item_name,position)
		queue_free()

func _patrol():
	if $PatrolCooldown.time_left <= 0 and is_following == false:
		$NavigationAgent2D.target_position = position + patrol_random_radius
		$PatrolCooldown.start(5)
		is_patrolling = true

func _on_aggro_cooldown_timeout():
	is_following = false
	$PatrolCooldown.start(5)

func _knockback(set_direction, knockback_power):
	var knockback = set_direction * knockback_power
	global_position += knockback

func _on_iframe_duration_timeout():
	iframe = false
