extends CharacterBody2D

@export var health: float = 125
@export var speed_day: float = 75
@export var speed_night: float = 30
@export var collision_damage: float = 5
var _spawnposition
var _following: bool = false
var speed: float
var path_direction

func _ready():
	_spawnposition = position
	#$Sprite2D.rotation_degrees = -90
	$Health.max_value = health
	

func _physics_process(_delta):
	
	$Sprite2D.look_at($NavigationAgent2D.get_next_path_position())
	#rotation_degrees = $_look_at_temp.rotation_degrees
	$Health.value = health
	if Global.worldType == "Day" and _following == true:
		speed = speed_day
		#$NavigationAgent2D.set_navigation_layer_value(1, true)
		#$NavigationAgent2D.set_navigation_layer_value(2, false)
	elif Global.worldType == "Night" and _following == true:
		speed = speed_night
		#$NavigationAgent2D.set_navigation_layer_value(1, false)
		#$NavigationAgent2D.set_navigation_layer_value(2, true)
	path_direction = to_local($NavigationAgent2D.get_next_path_position()).normalized()
	#Speed assigned on each node *bug*
	velocity = path_direction * speed
	
	move_and_slide()

func _on_pathfinding_cooldown_timeout():
	if _following == true:
		$NavigationAgent2D.target_position = Global.player_position
		
func _hit(damage: int):
	print("Enemy is hit")
	health -= damage
	if health <= 0:
		queue_free()

	#How to hit player if colliding???
	#alternative : create attack range for meele -> create melee projectile -> projectile hit player -> player take damage

func _on_pathfinding_area_body_entered(_body):
	_following = true
	
func _on_pathfinding_area_body_exited(_body):
	_following = false
	$ReturnCooldown.start()

func _on_return_cooldown_timeout():
	$NavigationAgent2D.target_position = _spawnposition
