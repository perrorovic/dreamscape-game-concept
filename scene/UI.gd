extends CanvasLayer

# I DONT FUCKING KNOW ANYMORE WITH THIS YEE-YEE ASS FUCNTION/VARS NAMING MAN

# Is this really needed to be a scene to preload from?
var sprite_Checkpoint = preload("res://assets/ui/sprite_checkpoint.tscn")
var sprite_Items = preload("res://assets/ui/sprite_items.tscn")
@onready var minimap_camera = $Minimap/SubViewportContainer/SubViewport/Camera2D
@onready var minimap_characterSprite = $Minimap/SubViewportContainer/SubViewport/sprite_Character
@onready var minimap_checkpoints = $Minimap/SubViewportContainer/SubViewport/Checkpoints
@onready var minimap_items = $Minimap/SubViewportContainer/SubViewport/Items
var map_isExpanded = false

# How do you want to do the feedback animation? is it wise to use the animator?
# Or just go caveman with tween?
# Tween probably the best. ONE FUCNTION THAT SOLVE ALL FEEDBACK

func _ready():
	# Set a new minimap tilemap to "$Minimap/SubViewportContainer/SubViewport/MinimapTileMap"
	# BUG - Sometime the UI would be just filtered red for no reason and will be stuck like that until the player press the button accordingly to reset the button
	%BossHealthUI.hide()
	_init_map()
	_init_items()

func _process(_delta):
	minimap_camera.position = $"../Character".position
	minimap_characterSprite.position = $"../Character".position
	minimap_characterSprite.rotation_degrees = Global.player_rotation
	
	_toggle_map()
	_check_world()

func _ui_feedback(ui_name):
	# Async signal from player character
	var ui_feedback_tween
	ui_feedback_tween = get_tree().create_tween()
	# You could assign the default stuff from the 'ui_name' into local var
	# Change the initial value and set back to default value
	# But all items in the UI are fucking rescaled their own way...
	#var ui_defaultScale = ui_name.scale
	# How to chain parallel tween 2 and 2? This is the best that i could find
	# FUCK THE SCALE
	#ui_feedback_tween.set_parallel(true)
	ui_feedback_tween.tween_property(ui_name, "modulate", Color("#ff113f"), 0.25)
	#ui_feedback_tween.tween_property(ui_name, "scale", ui_defaultScale+Vector2(0.01, 0.01), 0.25)
	#ui_feedback_tween.set_parallel(false)
	ui_feedback_tween.tween_property(ui_name, "modulate", Color("#ffffff"), 0.25)
	#ui_feedback_tween.tween_property(ui_name, "scale", ui_defaultScale, 0.25)
	print("ui feedback for ", ui_name)

func _check_world():
	#if Global.worldType == "Day":
		#%PlayerMeleeEquippedUI.show()
		#%PlayerMeleeSpecialAttackUI.show()
		#%PlayerRangedAmmoUI.hide()
		#%PlayerRangedSpecialAttackUI.hide()
	#if Global.worldType == "Night":
		#%PlayerMeleeEquippedUI.hide()
		#%PlayerMeleeSpecialAttackUI.hide()
		#%PlayerRangedAmmoUI.show()
		#%PlayerRangedSpecialAttackUI.show()
	
	## This node will be used later on
	#if Global.worldType == "Day":
		#if Global.player_haveSword == true:
			#%PlayerMeleeEquippedUI.show()
			#if Global.player_ableToThrow == true:
				#%PlayerMeleeSpecialAttackUI.show()
		#if Global.player_haveStaff == true:
			#%PlayerRangedAmmoUI.hide()
			#%PlayerRangedSpecialAttackUI.hide()
	#if Global.worldType == "Night":
		#if Global.player_haveSword == true:
			#%PlayerMeleeEquippedUI.hide()
			#%PlayerMeleeSpecialAttackUI.hide()
		#if Global.player_haveStaff == true:
			#%PlayerRangedAmmoUI.show()
			#if Global.player_ableToFireball == true:
				#%PlayerRangedSpecialAttackUI.show()
		pass
		
func _init_map():
	# Getting all checkpoint in the world to the minimap
	for i in $"../CheckpointsTemp".get_child_count():
		var checkpoint = sprite_Checkpoint.instantiate()
		minimap_checkpoints.add_child(checkpoint,true)
		checkpoint.z_index = 2
		checkpoint.position = $"../CheckpointsTemp".get_child(i).position

func _activated_checkpoint(checkpoint_position):
	# Check for async signal to change with checkpoint is currently activated
	for i in minimap_checkpoints.get_child_count():
		minimap_checkpoints.get_child(i).modulate = Color("ffffff")
	for i in minimap_checkpoints.get_child_count():
		if minimap_checkpoints.get_child(i).position == checkpoint_position:
			minimap_checkpoints.get_child(i).modulate = Color("#95cc00")
			print("World Map Checkpoint ", minimap_checkpoints.get_child(i).name , "Activated")
			break
	
func _init_items():
	# Getting all items drop in the world to the minimap
	for i in $"../ItemTemp".get_child_count():
		var items = sprite_Items.instantiate()
		minimap_items.add_child(items,true)
		items.z_index = 0
		items.position = $"../ItemTemp".get_child(i).position

func _remove_items(index):
	# Async signal to remove specific items
	minimap_items.get_child(index).queue_free()

func _update_items(item_name, set_position):
	# Async signal to update the items world to minimap
	if item_name != "":
		var items = sprite_Items.instantiate()
		minimap_items.add_child(items,true)
		items.z_index = 2
		items.position = set_position

func _toggle_map():
	#Map change to Minimap
	if Input.is_action_just_pressed("expand_map") and map_isExpanded == true:
		map_isExpanded = false
		print(get_viewport().size)
		$Minimap/SubViewportContainer/SubViewport.size = Vector2(100,100)
		$Minimap/SubViewportContainer.size = Vector2(100,100)
		$Minimap/SubViewportContainer.position = Vector2(get_viewport().size - $Minimap/SubViewportContainer/SubViewport.size - Vector2i(30,get_viewport().size.y - 130))
		print($Minimap/SubViewportContainer.position)
	#Map change to World Map
	elif  Input.is_action_just_pressed("expand_map") and map_isExpanded == false:
		print(get_viewport().size)
		map_isExpanded = true
		$Minimap/SubViewportContainer/SubViewport.size = Vector2(300,300)
		$Minimap/SubViewportContainer.size = Vector2(300,300)
		$Minimap/SubViewportContainer.position = Vector2(get_viewport().size/2 - $Minimap/SubViewportContainer/SubViewport.size/2)
