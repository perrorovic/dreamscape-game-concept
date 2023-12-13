extends CanvasLayer

var sprite_Checkpoint = preload("res://assets/ui/sprite_checkpoint.tscn")

func _ready():
	# BUG - Sometime the UI would be just filtered red for no reason and will be stuck like that until the player press the button accordingly to reset the button
	$PlayerDeath/Foreground.hide()
	$UIAnimation.play("RESET")
	_init_map()
	
func _process(_delta):
	
	$Minimap/SubViewportContainer/SubViewport/Camera2D.position = $"../Character".position
	$Minimap/SubViewportContainer/SubViewport/sprite_Character.position = $"../Character".position
	$Minimap/SubViewportContainer/SubViewport/sprite_Character.rotation_degrees = Global.player_rotation
	
	

func _init_map():
	for i in $"../Checkpoints".get_child_count():
		var checkpoint = sprite_Checkpoint.instantiate()
		$Minimap/SubViewportContainer/SubViewport/Checkpoints.add_child(checkpoint,true)
		checkpoint.z_index = 2
		checkpoint.position = $"../Checkpoints".get_child(i).position

func _activated_Checkpoint(checkpoint_position):
	for i in $Minimap/SubViewportContainer/SubViewport/Checkpoints.get_child_count():
		$Minimap/SubViewportContainer/SubViewport/Checkpoints.get_child(i).modulate = Color("ffffff")
	
	for i in $Minimap/SubViewportContainer/SubViewport/Checkpoints.get_child_count():
		if $Minimap/SubViewportContainer/SubViewport/Checkpoints.get_child(i).position == checkpoint_position:
			$Minimap/SubViewportContainer/SubViewport/Checkpoints.get_child(i).modulate = Color("#95cc00")
			break
	
