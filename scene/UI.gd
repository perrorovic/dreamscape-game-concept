extends CanvasLayer

var sprite_Checkpoint = preload("res://assets/ui/sprite_checkpoint.tscn")
var sprite_Items = preload("res://assets/ui/sprite_items.tscn")
var map_isExpanded = false

func _ready():
	# BUG - Sometime the UI would be just filtered red for no reason and will be stuck like that until the player press the button accordingly to reset the button
	$PlayerDeath/Foreground.hide()
	$UIAnimation.play("RESET")
	_init_map()
	_init_Items()
	
func _process(_delta):
	
	$Minimap/SubViewportContainer/SubViewport/Camera2D.position = $"../Character".position
	$Minimap/SubViewportContainer/SubViewport/sprite_Character.position = $"../Character".position
	$Minimap/SubViewportContainer/SubViewport/sprite_Character.rotation_degrees = Global.player_rotation
	
	_toggle_map()
	_check_world()
	
	
func _check_world():
	if Global.worldType == "Day":
		$PlayerRanged.hide()
		$PlayerMelee.show()
	if Global.worldType == "Night":
		$PlayerRanged.show()
		$PlayerMelee.hide()
		
func _init_map():
	for i in $"../CheckpointsTemp".get_child_count():
		var checkpoint = sprite_Checkpoint.instantiate()
		$Minimap/SubViewportContainer/SubViewport/Checkpoints.add_child(checkpoint,true)
		checkpoint.z_index = 2
		checkpoint.position = $"../CheckpointsTemp".get_child(i).position

func _activated_Checkpoint(checkpoint_position):

	for i in $Minimap/SubViewportContainer/SubViewport/Checkpoints.get_child_count():
		$Minimap/SubViewportContainer/SubViewport/Checkpoints.get_child(i).modulate = Color("ffffff")
	
	for i in $Minimap/SubViewportContainer/SubViewport/Checkpoints.get_child_count():
		if $Minimap/SubViewportContainer/SubViewport/Checkpoints.get_child(i).position == checkpoint_position:
			$Minimap/SubViewportContainer/SubViewport/Checkpoints.get_child(i).modulate = Color("#95cc00")
			
			print("WORLD MAP Checkpoint ", $Minimap/SubViewportContainer/SubViewport/Checkpoints.get_child(i).name , "Activated")
			break
	
func _init_Items():
	for i in $"../ItemTemp".get_child_count():
		var items = sprite_Items.instantiate()
		$Minimap/SubViewportContainer/SubViewport/Items.add_child(items,true)
		items.z_index = 0
		items.position = $"../ItemTemp".get_child(i).position

func _remove_Items(index):
	$Minimap/SubViewportContainer/SubViewport/Items.get_child(index).queue_free()

func _update_Items(item_name, set_position):
	if item_name != "":
		var items = sprite_Items.instantiate()
		$Minimap/SubViewportContainer/SubViewport/Items.add_child(items,true)
		items.z_index = 2
		items.position = set_position

func _toggle_map():
	#Map change to Minimap
	if Input.is_action_just_pressed("expand_map") and map_isExpanded == true:
		map_isExpanded = false
		$Minimap/SubViewportContainer/SubViewport.size = Vector2(100,100)
		$Minimap/SubViewportContainer.size = Vector2(100,100)
		$Minimap/SubViewportContainer.position = Vector2(848,13)
		
	#Map change to World Map
	elif  Input.is_action_just_pressed("expand_map") and map_isExpanded == false:
		map_isExpanded = true
		
		$Minimap/SubViewportContainer/SubViewport.size = Vector2(300,300)
		$Minimap/SubViewportContainer.size = Vector2(300,300)
		$Minimap/SubViewportContainer.position = Vector2(330,100)
		
		
		
		
		
		
