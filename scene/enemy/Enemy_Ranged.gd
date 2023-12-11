extends EnemyParent

signal attack(enemy_position, target_direction)
var able_toAttack: bool = true

func _ready():
	$Health.max_value = health
	$Sprite2D.self_modulate = Color("ff38a9")

func _on_attack_area_body_entered(body):
	if body.name == "Character" and able_toAttack == true:
		var direction: Vector2 = (Global.player_position - position).normalized()
		connect("attack", Callable(world, "_on_enemy_ranged_attack"), 4)
		attack.emit(position, direction)
		# Check for body entered every switch
		#$AttackArea.call_deferred("set_collision_mask_value", 1, false)
		$AttackArea.set_collision_mask_value(1, false)
		is_attacking = true
		able_toAttack = false
		$AttackCooldown.start()

func _on_attack_cooldown_timeout():
	#$AttackArea.call_deferred("set_collision_mask_value", 1, true)
	$AttackArea.set_collision_mask_value(1, true)
	is_attacking = false
	able_toAttack = true
