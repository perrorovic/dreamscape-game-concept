extends Scene_Parent

func _ready():
	print("Scene Inherited")
	
	_init_world()
	_init_day()
	_tutorial()
	
func _process(_delta):
	pass

# --------------------------------------------------------------------------
# TO BE DELETED LATER @kepponn RETARDOING
# DONT FORGET TO DELETE THIS SHEET AND DISCONNECT THE SIGNAL ON WHOLEMEME/MEME
# --------------------------------------------------------------------------

func _on_meme_body_entered(_body):
	$WHOLEMEME/VideoStreamPlayer.play()
	$"WHOLEMEME/Meme".set_collision_mask_value(1, false)
	pass

func _on_meme_2_body_entered(_body):
	$"WHOLEMEME/VideoStreamPlayer2".play()
	$"WHOLEMEME/Meme2".set_collision_mask_value(1, false)
	pass

func _tutorial():
	
	Global.player_health = 125.00
	
	$Character/Weapon/MeleeWeapon.hide()
	$Character/Weapon/RangedWeapon.hide()
	
	Global.player_ableToMelee = false
	Global.player_ableToThrow = false
	Global.player_ableToShoot = false
	Global.player_ableToFireball = false
	Global.player_ableToDash = false
	
	$UI/%WorldTypeUI.hide()
	$UI/%PlayerDashUI.hide()
	$UI/%PlayerRangedAmmoUI.hide()
	$UI/%PlayerMeleeEquippedUI.hide()
	$UI/%PlayerRangedSpecialAttackUI.hide()
	$UI/%PlayerMeleeSpecialAttackUI.hide()
	$UI/%SubViewportContainer.hide()

func _on_player_interact_key_item(interactable_temp):
	match interactable_temp.name :
		"Interactable_Sword":
			Global.player_ableToMelee = true
			$Character/Weapon/MeleeWeapon.show()
			Global.player_haveSword = true
			interactable_temp.queue_free()
		"interactable_Staff":
			Global.player_ableToMelee = true
			$Character/Weapon/MeleeWeapon.show()
			interactable_temp.queue_free()
		"EnableDash":
			Global.player_ableToDash = true
			$UI/%PlayerDashUI.show()
			interactable_temp.queue_free()
