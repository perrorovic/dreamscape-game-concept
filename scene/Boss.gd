extends CharacterBody2D

@export var health: float = 2000.0

signal boss_action_shoot(boss_position, target_direction)
signal boss_action_bomb(boss_position)
signal boss_action_slash(boss_position, target_direction)
#var movement_set1: Array = ["shoot","shoot","shoot","shoot","shoot","shoot","slash","slash","slash","slash","bomb","bomb"]
var movement_set1: Array = ["shoot","shoot","shoot","bomb","shoot","shoot","slash"]
var movement_set2: Array = ["bomb","shoot","shoot","slash","bomb","shoot","bomb",]
var movement_set3: Array = ["slash","slash","shoot","shoot","bomb","slash","shoot"]
var movement_queue: Array = []
var boss_ableToAttack: bool = false
# Need to randomize a timer to set this to true once
# Without it the boss will launch 3 attack at the same time!
var boss_ableToShoot: bool = true
var boss_ableToBomb: bool = true
var boss_ableToSlash: bool = true

func _ready():
	$Moon.set_flip_h(false)
	$"../UI/BossHealth/Progress".max_value = health
	$Health.hide()
	##$Health.max_value = health
	

func _process(_delta):
	$"../UI/BossHealth/Progress".value = health
	if boss_ableToAttack:
		$_look_at_temp.look_at(Global.player_position)
#		print($Sprite2D2.rotation_degrees)
		_look_at()
		
		if movement_queue == []:
			print("movement_set1")
			print(movement_set1)
			print("movement_set2")
			print(movement_set2)
			print("movement_set3")
			print(movement_set3)
			var random :int = randi_range(1,3)
			match random:
				1:
					movement_queue += movement_set1
				2:
					movement_queue += movement_set2
				3: 
					movement_queue += movement_set3
			#if random == 1:
				#movement_queue += movement_set1
			#elif random == 2:
				#movement_queue += movement_set2
			#elif random == 3:
				#movement_queue += movement_set3

		elif movement_queue[0]=="shoot" and $ActionCooldown.time_left <= 0:
			print(movement_queue)
			_action_shoot()
			movement_queue.pop_front()
			#To shuffle the query
			#movement_queue.shuffle()
			$ActionCooldown.start(1)
		elif movement_queue[0]=="slash" and $ActionCooldown.time_left <= 0:
			print(movement_queue)
			_action_slash()
			movement_queue.pop_front()
			$ActionCooldown.start(2)
		elif movement_queue[0]=="bomb" and $ActionCooldown.time_left <= 0:
			print(movement_queue)
			_action_bomb()
			movement_queue.pop_front()
			$ActionCooldown.start(3)

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

func _hit(damage: int):
	print("Boss is hit")
	health -= damage
	if health <= 0:
		queue_free()

func _action_shoot():
#	print("Boss is Shooting!")
	# This direct the boss into the player
	var direction: Vector2 = (Global.player_position - position).normalized()
	boss_action_shoot.emit(position, direction)
	
func _action_bomb():
#	print("Boss is Bombing!")
	boss_action_bomb.emit(position)
	
func _action_slash():
#	print("Boss is Slashing!")
	# This direct the boss into the player
	var direction: Vector2 = (Global.player_position - position).normalized()
	boss_action_slash.emit(position, direction)


func _on_attack_area_body_entered(body: CharacterBody2D):
	if body.name == "Character":
		boss_ableToAttack = true
		$"../UI/BossHealth/Progress".show()

func _on_attack_area_body_exited(body: CharacterBody2D):
	if body.name == "Character":
		boss_ableToAttack = false
		$"../UI/BossHealth/Progress".hide()


