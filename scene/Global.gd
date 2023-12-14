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
var player_ammo: int = 10
# Used for damage for player
var player_health: float = 125.0
var player_healthMax: float = 200.0
# Used for player spawn point
var player_spawnpoint: Vector2

func _ready():
	pass
	# This hide the mouse and confine it to the window size
	# Bad idea...
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _process(_delta):
	if Input.is_action_pressed("close"):
		get_tree().quit()
	_check_player_health()

# This function make the health cannot exceed above the 'player_healthMax'
func _check_player_health():
	if player_health > 200:
		player_health = 200
		#print(player_health)
