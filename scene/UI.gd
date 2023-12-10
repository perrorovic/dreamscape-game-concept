extends CanvasLayer

func _ready():
	# BUG - Sometime the UI would be just filtered red for no reason and will be stuck like that until the player press the button accordingly to reset the button
	$PlayerDeath/Foreground.hide()
	$UIAnimation.play("RESET")
	
func _process(_delta):
	pass
