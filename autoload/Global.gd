extends Node
# Used in main function
var worldType: String
var player_ableToSwapWorld: bool = true

# This is used in UI
var player_haveSword: bool = false
var player_haveStaff: bool = false

# This is auto set boolean in main function
var player_ableToMelee: bool
var player_ableToThrow: bool
var player_ableToShoot: bool
var player_ableToFireball: bool
# Used in projectile spawn and targeting
var player_position
var player_rotation
# Used in character to determine the action
var player_meleeSlashSpawn
var player_ableToDash: bool = true
const player_ammoMax: int = 10
var player_ammo: int = 10
# Used for damage for player
var player_health: float
var player_healthMax: float = 300.0
# Used for player spawn point
var player_spawnpoint: Vector2

func _ready():
	pass
	# This hide the mouse and confine it to the window size
	# Bad idea...
	#Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _process(_delta):
	_check_player_health()

# This function make the health cannot exceed above the 'player_healthMax'
func _check_player_health():
	if player_health > player_healthMax:
		player_health = player_healthMax
		#print(player_health)
