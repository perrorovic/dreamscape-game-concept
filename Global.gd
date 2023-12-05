extends Node
# Used in main function
var worldType: String
var player_ableToSwapWorld: bool = true
# This is auto set boolean in main function
var player_ableToMelee
var player_ableToShoot
# Used in projectile spawn and targeting
var player_position
var player_rotation
# Used in character to determine the action
var player_meleeSlashSpawn
var player_ableToDash: bool = true
const player_ammoMax: int = 10
var player_ammo:int = 10
# Used for damage for player
var player_health: float = 200.0

func _process(_delta):
	if Input.is_action_pressed("close"):
		get_tree().quit()
	pass
