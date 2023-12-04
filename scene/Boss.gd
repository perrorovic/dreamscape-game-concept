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
	#$ShootCooldown.start()
	#$BombCooldown.start()
	#$SlashCooldown.start()
	

func _process(_delta):
	#var movement_set1: Array = ["shoot","shoot","shoot","shoot"]
	#var movement_set2: Array = ["bomb"]
	#var movement_set3: Array = ["slash","slash"]
	$"../UI/BossHealth/Progress".value = health
	##$Health.value = health
	if boss_ableToAttack:
		$Sprite2D2.look_at(Global.player_position)
#		print($Sprite2D2.rotation_degrees)d
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
			#movement_queue.shuffle()
			$ActionCooldown.start(1)
		elif movement_queue[0]=="slash" and $ActionCooldown.time_left <= 0:
			print(movement_queue)
			_action_slash()
			movement_queue.pop_front()
			#movement_queue.shuffle()
			$ActionCooldown.start(2)
		elif movement_queue[0]=="bomb" and $ActionCooldown.time_left <= 0:
			print(movement_queue)
			_action_bomb()
			movement_queue.pop_front()
			#movement_queue.shuffle()
			$ActionCooldown.start(3)
		#if boss_ableToShoot:
			#_action_shoot()
		#if boss_ableToBomb:
			#_action_bomb()
		#if boss_ableToSlash:
			#_action_slash()
#	print("Boss able to Attack")
#	if $MovementTimer/BossCooldownTimer.time_left <= 0:
#		print("BOSS GERAK")
#	if movement_Queue.is_empty():
#		print("kosong")
#		pass
#	elif  movement_Queue[0]=="Bomb" and $MovementTimer/BossCooldownTimer.time_left <= 0:
#		movement_Bomb()
#		movement_Queue.pop_front()
#		print("POP BOMB")
#		print(movement_Queue)
#		##fungsine digawe beda men ora kabeh move sue meng movement selanjute
#		##ex : shoot (projectile kecil dan jumlahe cuma 1) termasuk minor atk,
#		##nek cooldown e kembar karo sing lia mungkin ngko diem e sue bgt nembe move selanjute
#		$MovementTimer/BossCooldownTimer.start(2.5)
#	elif movement_Queue[0]=="Slash" and $MovementTimer/BossCooldownTimer.time_left <= 0:
#		movement_Slash()
#		movement_Queue.pop_front()
#		print("POP SLASH")
#		print(movement_Queue)
#		$MovementTimer/BossCooldownTimer.start(2.5)
#	elif movement_Queue[0]=="Shoot" and $MovementTimer/BossCooldownTimer.time_left <= 0:
#		movement_Shoot()
#		movement_Queue.pop_front()
#		print("POP SHOOT")
#		print(movement_Queue)
#		$MovementTimer/BossCooldownTimer.start(1.1)

func _look_at():
	# No ida on why this code only work with if-elif. dont touch it.
	# This code determine the boss view to left or right regarding the player position
	# Using the look_at() function to check the self.rotation
	if $Sprite2D2.rotation_degrees > 90 or $Sprite2D2.rotation_degrees < -90:
		$Moon.set_flip_h(true)
	elif $Sprite2D2.rotation_degrees < 90 or $Sprite2D2.rotation_degrees > -90:
		$Moon.set_flip_h(false) 
	# This reset the rotation of the boss the fulfill the statement before
	if $Sprite2D2.rotation_degrees <= -180:
		$Sprite2D2.set_rotation_degrees(180)
	elif $Sprite2D2.rotation_degrees >= 180:
		$Sprite2D2.set_rotation_degrees(-180)

func _hit(damage: int):
	print("Boss is hit")
	health -= damage
	if health <= 0:
		queue_free()

func _action_shoot():
	$ShootCooldown.start(randf_range(0.8,2))
	boss_ableToShoot = false
#	print("Boss is Shooting!")
	# This direct the boss into the player
	var direction: Vector2 = (Global.player_position - position).normalized()
	boss_action_shoot.emit(position, direction)
	
func _action_bomb():
	$BombCooldown.start(randf_range(4.8,5))
	boss_ableToBomb = false
#	print("Boss is Bombing!")
	boss_action_bomb.emit(position)
	
func _action_slash():
	$SlashCooldown.start(randf_range(5.2,8))
	boss_ableToSlash = false
#	print("Boss is Slashing!")
	# This direct the boss into the player
	var direction: Vector2 = (Global.player_position - position).normalized()
	boss_action_slash.emit(position, direction)

#func _action_shoot():
	#var direction: Vector2 = (Global.player_position - position).normalized()
	#movement_queue.pop_front()
	#boss_action_shoot.emit(position, direction)
	#
#func _action_bomb():
	#movement_queue.pop_front()
	#boss_action_bomb.emit(position)
	#
#func _action_slash():
	#movement_queue.pop_front()
	#var direction: Vector2 = (Global.player_position - position).normalized()
	#boss_action_slash.emit(position, direction)

func _on_attack_area_body_entered(body: CharacterBody2D):
	if body.name == "Character":
		boss_ableToAttack = true
		$"../UI/BossHealth/Progress".show()

func _on_attack_area_body_exited(body: CharacterBody2D):
	if body.name == "Character":
		boss_ableToAttack = false
		$"../UI/BossHealth/Progress".hide()

#func _on_shoot_cooldown_timeout():
	#movement_queue.push_back("shoot")
#
#func _on_bomb_cooldown_timeout():
	#movement_queue.push_back("bomb")
#
#func _on_slash_cooldown_timeout():
	#movement_queue.push_back("slash")
