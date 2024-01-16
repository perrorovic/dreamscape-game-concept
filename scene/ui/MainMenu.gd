extends MainMenuParent

func _ready():
	get_tree().paused = true
	%MasterVolume.value = Settings.audioMaster_volumeTemp
	%MusicVolume.value = Settings.audioMusic_volumeTemp
	%EffectVolume.value = Settings.audioEffect_volumeTemp
	print("Menu Inherited to Main Menu")
	$BackgoundMusic.play()
	$Menu.show()
	$Options.hide()
	%FullscreenButton.hide()
	%WindowedButton.show()

# --------------------------------------------------------------------------
# BaseButton function via pressed() signals
# --------------------------------------------------------------------------

func _on_play_pressed():
	# Get and play the scene
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/Scene_Inherited.tscn")

func _on_options_pressed():
	# Make a volume slider and fullscreen/windowed options
	$Menu.hide()
	$Options.show()
	
func _on_options_back_pressed():
	$Options.hide()
	$Menu.show()
	
func _on_quit_pressed():
	get_tree().quit()
