extends MainMenuParent

# Dont forget to change the process to 'when paused'
# Therefore the menu can work while the game tree is paused

func _ready():
	hide()
	%MasterVolume.value = Settings.audioMaster_volumeTemp
	%MusicVolume.value = Settings.audioMusic_volumeTemp
	%EffectVolume.value = Settings.audioEffect_volumeTemp
	print("Menu Inherited to Ingame Menu")
	$Menu.show()
	$Options.hide()
	%FullscreenButton.hide()
	%WindowedButton.show()

func _process(_delta):
	# This was supposed to be 'esc' as well but it launch both function in the same time
	if Input.is_action_just_pressed("esc") and $Timer.time_left == 0:
		_on_resume_pressed()

func esc():
	$Timer.start()

# --------------------------------------------------------------------------
# BaseButton function via pressed() signals
# --------------------------------------------------------------------------

func _on_resume_pressed():
	hide()
	get_tree().paused = false

func _on_options_pressed():
	$Menu.hide()
	$Options.show()
	
func _on_options_back_pressed():
	$Options.hide()
	$Menu.show()
	
func _on_quit_to_menu_pressed():
	get_tree().change_scene_to_file("res://scene/ui/Main_Menu.tscn")
	
func _on_quit_to_desktop_pressed():
	get_tree().quit()
