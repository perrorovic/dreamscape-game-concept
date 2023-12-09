extends CanvasLayer

func _ready():
	$PlayerDeath/Foreground.hide()
	$UIAnimation.play("RESET")
func _process(_delta):
	pass
