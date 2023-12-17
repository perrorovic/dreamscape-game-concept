extends Scene_Parent

func _ready():
	print("Scene Inherited")
	_init_world()
	_init_day()
	
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
