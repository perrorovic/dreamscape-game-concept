extends CharacterBody2D

@export var health: float = 125
@export var speed_day: float = 75
@export var speed_night: float = 30
@export var collision_damage: float = 5

signal enemy_melee_attack(enemy_position, target_direction)


var is_following: bool = false
var is_patrolling: bool = false
var is_attacking: bool = false
var speed: float
var path_direction = 0

func _ready():

	$Health.max_value = health

func _physics_process(_delta):

	_patrol()
	
	$Sprite2D.look_at($NavigationAgent2D.get_next_path_position())
	$Health.value = health
	if is_attacking == true:
		speed = 0
	elif Global.worldType == "Day" and is_patrolling == false:
		speed = speed_day
	elif Global.worldType == "Day" and is_patrolling == true:
		speed = speed_day * 0.5
	elif Global.worldType == "Night" and is_patrolling == false:
		speed = speed_night
	elif Global.worldType == "Night" and is_patrolling == true:
		speed = speed_night * 0.5
	
	path_direction = to_local($NavigationAgent2D.get_next_path_position()).normalized()
	velocity = path_direction * speed
	#Speed assigned on each node *bug*
	if !$NavigationAgent2D.is_navigation_finished():
		move_and_slide()

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
			
func _hit(damage: int):
	print("Enemy is hit")
	health -= damage
	if health <= 0:
		queue_free()

func _patrol():
	if $PatrolCooldown.time_left <= 0 and is_following == false:
		$NavigationAgent2D.target_position = position + Vector2(randf_range(-75,75),randf_range(-75,75))
		$PatrolCooldown.start(5)
		is_patrolling = true
		
func _on_attack_area_body_entered(body):
	if body.name == "Character":
		var direction: Vector2 = (Global.player_position - position).normalized()
		enemy_melee_attack.emit(position, direction)
		$AttackArea.set_collision_mask_value(1, false)
		is_attacking = true
		$MeleeCooldown.start()
		
func _on_melee_cooldown_timeout():
	print(is_attacking)
	$AttackArea.set_collision_mask_value(1, true)
	is_attacking = false
	
