extends CharacterBody2D

# --------------------------------------------------------------------------
# Signal that boss emit. This signal are being used in the level scene
# --------------------------------------------------------------------------

@onready var world = get_node("/root/Scene/")

signal boss_action_shoot(boss_position, target_direction)
signal boss_action_bomb(boss_position)
signal boss_action_slash(boss_position, target_direction)

# --------------------------------------------------------------------------
# Boss property are listed and set with type and value here
# --------------------------------------------------------------------------

@export var health: float = 2000.0

# Prepare the array for movement set for the boss
var movement_queue: Array = []
# Set the movement set for the boss
var movement_set1: Array = ["shoot","shoot","shoot","bomb","shoot","shoot","slash"]
var movement_set2: Array = ["bomb","shoot","shoot","slash","bomb","shoot","bomb",]
var movement_set3: Array = ["slash","slash","shoot","shoot","bomb","slash","shoot"]
# Boss action setter being used in their own function
var boss_ableToAttack: bool = false
var boss_ableToShoot: bool = true
var boss_ableToBomb: bool = true
var boss_ableToSlash: bool = true

# --------------------------------------------------------------------------
# Function of _ready() and _process() are listed below:
# --------------------------------------------------------------------------

func _ready():
	# Set the left-right view of the boss sprite
	$Moon.set_flip_h(false)
	# Set boss UI and hide the UI
	$"../../UI/%BossHealthUI".max_value = health
	$"../../UI/%BossHealthUI".hide()

func _process(_delta):
	# Update the health
	$"../../UI/%BossHealthUI".value = health
	if boss_ableToAttack:
		# Boss will look at the player
		$_look_at_temp.look_at(Global.player_position)
		_look_at()
		# Getting the random moveset
		if movement_queue == []:
			var random :int = randi_range(1,3)
			match random:
				1:
					movement_queue += movement_set1
				2:
					movement_queue += movement_set2
				3: 
					movement_queue += movement_set3
		# Execute shoot move
		elif movement_queue[0]=="shoot" and $ActionCooldown.time_left <= 0:
			#print(movement_queue)
			_action_shoot()
			movement_queue.pop_front()
			#To shuffle the query
			#movement_queue.shuffle()
			$ActionCooldown.start(1)
		# Execute slash move
		elif movement_queue[0]=="slash" and $ActionCooldown.time_left <= 0:
			#print(movement_queue)
			_action_slash()
			movement_queue.pop_front()
			$ActionCooldown.start(2)
		# Execute bomb move
		elif movement_queue[0]=="bomb" and $ActionCooldown.time_left <= 0:
			#print(movement_queue)
			_action_bomb()
			movement_queue.pop_front()
			$ActionCooldown.start(3)

# --------------------------------------------------------------------------
# Boss action function are listed below:
# --------------------------------------------------------------------------

func _look_at():
	# No idea on why this code only work with if-elif. dont touch it.
	# This code determine the boss view to left or right regarding the player position
	# Using the look_at() function to check the self.rotation
	if $_look_at_temp.rotation_degrees > 90 or $_look_at_temp.rotation_degrees < -90:
		$Moon.set_flip_h(true)
	elif $_look_at_temp.rotation_degrees < 90 or $_look_at_temp.rotation_degrees > -90:
		$Moon.set_flip_h(false) 
	# This reset the rotation of the boss the fulfill the statement before
	if $_look_at_temp.rotation_degrees <= -180:
		$_look_at_temp.set_rotation_degrees(180)
	elif $_look_at_temp.rotation_degrees >= 180:
		$_look_at_temp.set_rotation_degrees(-180)

func _action_shoot():
#	print("Boss is Shooting!")
	# This direct the boss into the player
	var direction: Vector2 = (Global.player_position - position).normalized()
	connect("boss_action_shoot", Callable(world, "_on_boss_action_shoot"), 4)
	boss_action_shoot.emit(position, direction)
	
func _action_bomb():
#	print("Boss is Bombing!")
	connect("boss_action_bomb", Callable(world, "_on_boss_action_bomb"), 4)
	boss_action_bomb.emit(position)
	
func _action_slash():
#	print("Boss is Slashing!")
	# This direct the boss into the player
	var direction: Vector2 = (Global.player_position - position).normalized()
	connect("boss_action_slash", Callable(world, "_on_boss_action_slash"), 4)
	boss_action_slash.emit(position, direction)

# --------------------------------------------------------------------------
# Function of boss that being called by other entities
# --------------------------------------------------------------------------

func _hit(damage, _iframe_type, _set_direction, _knockback_power):
	#print("Boss is hit")
	health -= damage
	if health <= 0:
		queue_free()

func _on_attack_area_body_entered(body: CharacterBody2D):
	if body.name == "Character":
		boss_ableToAttack = true
		$"../../UI/%BossHealthUI".show()

func _on_attack_area_body_exited(body: CharacterBody2D):
	if body.name == "Character":
		boss_ableToAttack = false
		$"../../UI/%BossHealthUI".hide()
