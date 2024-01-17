extends MainMenuParent

func _ready():
	get_tree().paused = true
	_displaySettings()
	_audioSettings()
	print("Menu Inherited to Main Menu")
	$BackgoundMusic.play()
	$Menu.show()
	$Options.hide()

# --------------------------------------------------------------------------
# BaseButton function via pressed() signals
# --------------------------------------------------------------------------

func _on_play_pressed():
	# Get and play the scene
	$Audio/Start.play()
func _on_play_audio_finished():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scene/Scene_Inherited.tscn")

func _on_options_pressed():
	# Make a volume slider and fullscreen/windowed options
	$Audio/Foward.play(0.25)
	$Menu.hide()
	$Options.show()
	
func _on_options_back_pressed():
	$Audio/Back.play(0.25)
	$Options.hide()
	$Menu.show()
	
func _on_quit_pressed():
	$Audio/Quit.play()
func _on_quit_audio_finished():
	get_tree().quit()

# --------------------------------------------------------------------------
# Multiplayer function (huh?)
# Unused at the moment maybe just scrap this...
# --------------------------------------------------------------------------

var peer = ENetMultiplayerPeer.new()
var player_scene: PackedScene

func _on_host_pressed():
	peer.create_server(5320)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(multiplayer_addPlayer)
	multiplayer_addPlayer()

func _on_join_pressed():
	peer.create_client("127.0.0.1", 5320)
	multiplayer.multiplayer_peer = peer

func multiplayer_exitGame(id):
	multiplayer.peer_disconnected.connect(multiplayer_delPlayer)
	multiplayer_delPlayer(id)

func multiplayer_addPlayer(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)
	call_deferred("add_child", player)

func multiplayer_delPlayer(id):
	rpc("_multiplayer_delPlayer", id)
	
@rpc("any_peer", "call_local") func _multiplayer_delPlayer(id):
	get_node(str(id)).queue_free()
	
