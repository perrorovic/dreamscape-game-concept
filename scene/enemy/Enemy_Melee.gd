# --------------------------------------------------------------------------
# This script are extended from 'Enemy_Parent'
# Please check "res://scene/enemy/Enemy_Parent.gd" for more information
# --------------------------------------------------------------------------

extends Enemy_Parent

signal attack(enemy_position, target_direction)

func _ready():
	$Health.max_value = health

func _on_attack_area_body_entered(body):
	if body.name == "Character":
		var direction: Vector2 = (Global.player_position - position).normalized()
		connect("attack", Callable(world, "_on_enemy_melee_attack"), 4)
		attack.emit(%AttackPoint.global_position, direction)
		$AttackArea.set_collision_mask_value(1, false)
		is_attacking = true
		$AttackCooldown.start()

func _on_attack_cooldown_timeout():
	#print(is_attacking)
	$AttackArea.set_collision_mask_value(1, true)
	is_attacking = false
