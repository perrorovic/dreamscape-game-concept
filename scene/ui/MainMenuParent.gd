extends CanvasLayer
class_name MainMenuParent

# --------------------------------------------------------------------------
# This function should be a scene with all node needed and simply imported for both main-menu and in-game menu
# Remember to put this _ready() function in the child
# Current child:
# "res://scene/ui/MainMenu.gd"
# "res://scene/ui/IngameMenu.gd"
# --------------------------------------------------------------------------

func _ready():
	#get_tree().paused = true or hide()
	#_displaySettings()
	#_audioSettings()
	#print("Menu Inherited")
	#$Menu.show()
	#$Options.hide()
	pass

func _displaySettings():
	if Settings.displayMode_fullscreen:
		%FullscreenButton.show()
		%WindowedButton.hide()
	else:
		%FullscreenButton.hide()
		%WindowedButton.show()

func _audioSettings():
	%MasterVolume.value = Settings.audioMaster_volumeTemp
	%MusicVolume.value = Settings.audioMusic_volumeTemp
	%EffectVolume.value = Settings.audioEffect_volumeTemp

# --------------------------------------------------------------------------
# Audio volume settings
# Check the bus index name in editor bottom window > audio
# --------------------------------------------------------------------------

var audioMaster_volume = AudioServer.get_bus_index("Master")
var audioMusic_volume = AudioServer.get_bus_index("Music")
var audioEffect_volume = AudioServer.get_bus_index("Effect")

func audioMuteCheck(value, audioBus):
	# Volume slider value are based on audio-dB
	# 0dB as max and -30dB as minimum/muted
	if value == -30:
		AudioServer.set_bus_mute(audioBus, true)
		print("Audio Muted")
	else:
		AudioServer.set_bus_mute(audioBus, false)
		#print("Audio Unmute")
	
# --------------------------------------------------------------------------
# Resolution change settings fullscreen / windowed
# MINOR ISSUES - How to save the display mode in settings?
# --------------------------------------------------------------------------

func _on_options_fullscreen_pressed():
	$Audio/Foward.play(0.25) # This is supposed to be in the parent
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	Settings.displayMode_fullscreen = false
	_displaySettings()
	print("Display mode changed: Windowed")
	#%FullscreenButton.hide()
	#%WindowedButton.show()

func _on_options_windowed_pressed():
	$Audio/Foward.play(0.25) # This is supposed to be in the parent
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	Settings.displayMode_fullscreen = true
	_displaySettings()
	print("Display mode changed: Fullscreen")
	#%WindowedButton.hide()
	#%FullscreenButton.show()
	
# --------------------------------------------------------------------------
# Audio volume slider settings
# --------------------------------------------------------------------------
	
func _on_options_master_volume(value):
	AudioServer.set_bus_volume_db(audioMaster_volume, value)
	Settings.audioMaster_volumeTemp = value
	audioMuteCheck(value, audioMaster_volume)

func _on_options_music_volume(value):
	AudioServer.set_bus_volume_db(audioMusic_volume, value)
	Settings.audioMusic_volumeTemp = value
	audioMuteCheck(value, audioMusic_volume)
	
func _on_options_effect_volume(value):
	AudioServer.set_bus_volume_db(audioEffect_volume, value)
	Settings.audioEffect_volumeTemp = value
	audioMuteCheck(value, audioEffect_volume)
