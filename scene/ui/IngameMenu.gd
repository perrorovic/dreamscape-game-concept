extends MainMenuParent

# Dont forget to change the process to 'when paused'
# Therefore the menu can work while the game tree is paused

func _ready():
	%MasterVolume.value = Settings.audioMaster_volumeTemp
	%MusicVolume.value = Settings.audioMusic_volumeTemp
	%EffectVolume.value = Settings.audioEffect_volumeTemp
	print("Menu Inherited")
	$Menu.show()
	$Options.hide()
	%FullscreenButton.hide()
	%WindowedButton.show()

# --------------------------------------------------------------------------
# BaseButton function via pressed() signals
# --------------------------------------------------------------------------

func _on_options_pressed():
	$Menu.hide()
	$Options.show()
	
func _on_options_back_pressed():
	$Options.hide()
	$Menu.show()
	
func _on_quit_to_menu_pressed():
	get_tree().change_scene_to_file("res://scene/ui/Main_Menu.tscn")
	
func _on_quit_to_os_pressed():
	get_tree().quit()
