extends Area2D
class_name Items

@onready var UI = get_node("/root/Node2D/UI")
signal update_Items(index)

# Set type for items "health" or "dash" or "projectile"
# This being used in 'func _on_body_entered(body: CharacterBody2D):'
@export var type: String
# List of color for each items orb type please also self_modulate itself in their scene
var health_color: Color = Color("ff0000")
var dash_color: Color = Color("00ffff")
var ammo_color: Color = Color("00ff00")

func _ready():
	pass
	
func _process(_delta):
	# Make the sprite rotate smoothly
	$Sprite2D.rotation_degrees += 5

func _on_body_entered(body: CharacterBody2D):
	if body.name == "Character" and body.has_method("_on_items_pickup"):
		
		print("Item taken is on index ", get_index())
		
		connect("update_Items", Callable(UI, "_remove_Items"), 4)
		update_Items.emit(get_index())
		
		body._on_items_pickup(type)
		queue_free()
