extends CanvasLayer
class_name MainMenuParent

# Remember to put this _ready() function in the child
func _ready():
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
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	%FullscreenButton.hide()
	%WindowedButton.show()

func _on_options_windowed_pressed():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	%WindowedButton.hide()
	%FullscreenButton.show()
	
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
