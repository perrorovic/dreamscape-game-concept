# --------------------------------------------------------------------------
# This script are available to be extended with 'extends Enemy_Parent'
# Currently this script being used by: "res://scene/enemy/Enemy_Melee.gd", "res://scene/enemy/Enemy_Ranged.gd"
# --------------------------------------------------------------------------

extends CharacterBody2D
class_name Enemy_Parent

# --------------------------------------------------------------------------
# Signal that Enemy_Parent emit. This signal are being used in the level scene
# Please note the signal are processed with connect() function
# --------------------------------------------------------------------------

signal item_dropped(item_name, enemy_position)
# Get world node ready to be used in signal
@onready var world = get_node("/root/Node2D/")
@onready var UI = get_node("/root/Node2D/UI")

# --------------------------------------------------------------------------
# Enemy_Parent property are listed and set with type and value here
# DONT FORGET TO SET THE PROPERTY IN THE INHERITED CHILD SCENE
# --------------------------------------------------------------------------

@export_category("Enemies Property")
@export_enum("Day", "Night") var enemy_type: String
@export var health: float
# This is the default speed of the enemies on their own world type, and will be reduced if the world type is changed
@export var speed: float
@export var speed_when_attacking: float = 0
# This is patrol variables
var patrol_speed: float = 0.5
@export var patrol_radius: int = 75
var patrol_random_radius = Vector2(randf_range(-patrol_radius,patrol_radius),randf_range(-patrol_radius,patrol_radius))
var is_patrolling: bool = false
# State of the enemies
var is_attacking: bool = false
# This variable are being used for navigation and movement
var path_direction: Vector2
var is_following: bool = false
var movement_speed: float
var move_speed: float
# This variable for item drops
var item_name: String
# This variable for iframe in _hit() function
var iframe: bool
# This variable for knockback used in movement
var knockback_tween: Tween
var knockback_tweenValue: Vector2 = Vector2(0,0)

# --------------------------------------------------------------------------
# Function of _ready() and _process() are listed below:
# --------------------------------------------------------------------------

func _ready():
	# Health setter (please call this in the childern scene)
	# $Health.max_value = health
	pass

func _process(_delta):
	# Health updater
	$Health.value = health
	
	# Set the navigation layer for each enemies based on their type
	# Check tilemaps for navigation layer list: (as per 12/12/2023)
	# navigation_layer_0 -> navigation
	# navigation_layer_1 -> day_env
	# navigation_layer_2 -> night_env
	if enemy_type == "Day":
		modulate = Color("fc6e00")
		$NavigationAgent2D.set_navigation_layer_value(1, true)
		$NavigationAgent2D.set_navigation_layer_value(2, true)
		# same question with this as in "res://scene/character/Character.gd"
		#set_collision_mask_value(2,true)
		#set_collision_mask_value(3,false)
	elif enemy_type == "Night":
		modulate = Color("0bb2cc")
		$NavigationAgent2D.set_navigation_layer_value(1, true)
		$NavigationAgent2D.set_navigation_layer_value(3, true)
		# same question with this as in "res://scene/character/Character.gd"
		#set_collision_mask_value(2,false)
		#set_collision_mask_value(3,true)
	
	# Enemy movement based on their type, enemy will move slower in other world type
	if Global.worldType ==  enemy_type:
		move_speed = speed
		$PointLight2D.show()
	elif Global.worldType != enemy_type:
		move_speed = speed * 0.75
		$PointLight2D.hide()
	
	# Enemy speed based on their patrol property
	if is_patrolling:
		movement_speed = 50
	elif is_patrolling == false and is_attacking == true:
		movement_speed = speed_when_attacking
	elif is_patrolling == false:
		movement_speed = move_speed
	
	# Navigation essentials
	$Sprite2D.look_at($NavigationAgent2D.get_next_path_position())
	path_direction = to_local($NavigationAgent2D.get_next_path_position()).normalized()
	
	#UNDER CONSTRUCTION
	#velocity = path_direction * movement_speed
	var total_movement = path_direction * movement_speed
	velocity = total_movement + knockback_tweenValue
	
	#print("total_movement",total_movement)
	#print("velocity",velocity)
	#print("=======================================")
	
	if !$NavigationAgent2D.is_navigation_finished():
		move_and_slide()
	
	# Calling _patrol() function to patrol their surronding location
	_patrol()

# --------------------------------------------------------------------------
# Function of Enemy_Parent that being used in _process()
# --------------------------------------------------------------------------

func _patrol():
	if $PatrolCooldown.time_left <= 0 and is_following == false:
		$NavigationAgent2D.target_position = position + patrol_random_radius
		$PatrolCooldown.start(5)
		is_patrolling = true

# --------------------------------------------------------------------------
# Function of Enemy_Parent that being called by other entities
# --------------------------------------------------------------------------

func _hit(damage: int, iframe_type: String, set_direction, knockback_power):
	# Can only do this if enemy is not on iframe
	if iframe == false:
		# Change iframe to true so enemy can't be hit more than once
		iframe = true
		print("Enemy is hit")
		# To make enemy aggro to player if hit enemy while enemy is patrolling
		is_following = true
		is_patrolling = false
		$AggroCooldown.start(5)
		# Enemy take damage
		health -= damage
		# Add hit feedback tween to the entity
		var hit_feedback_tween
		hit_feedback_tween = get_tree().create_tween()
		# Color feedback tween 
		hit_feedback_tween.tween_property($Sprite2D, "self_modulate", Color("#ff113f"), 0.1)
		hit_feedback_tween.tween_property($Sprite2D, "self_modulate", Color("#ffffff"), 0.1)
		# Knockback feedback tween
		var knockback = set_direction * knockback_power
		knockback_tweenValue = knockback
		hit_feedback_tween.parallel().tween_property(self, "knockback_tweenValue", Vector2(0,0), 0.25)
		
		# Set how long the iframe is for each type of attack, either set all of them same as the lowest one or a little bit higher than the lowest one, or each type of attack have its own time
		if iframe_type == "melee":
			$IframeDuration.start(0.5)
		elif iframe_type =="ranged":
			$IframeDuration.start(0.15)
	
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
		connect("item_dropped", Callable(world, "_on_enemy_drop"), 4)
		connect("item_dropped", Callable(UI, "_update_Items"), 4)
		item_dropped.emit(item_name, position)
		queue_free()

# --------------------------------------------------------------------------
# Timer with signal feedback that being used by Enemy_Parent
# --------------------------------------------------------------------------

func _on_pathfinding_cooldown_timeout():
	if is_following == true:
		$NavigationAgent2D.target_position = Global.player_position
		$PathfindingCooldown.start()

func _on_pathfinding_area_body_entered(body):
	if body.name == "Character":
		is_following = true
		is_patrolling = false

func _on_pathfinding_area_body_exited(body):
	if body.name == "Character":
		is_following = false
		$PatrolCooldown.start(5)

func _on_aggro_cooldown_timeout():
	is_following = false
	$PatrolCooldown.start(5)

func _on_iframe_duration_timeout():
	iframe = false
