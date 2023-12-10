extends StaticBody2D

var checkpoint_Activated
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	#$AnimationPlayer.play("Idle")
	$CrystalSpire.self_modulate = Color("#ffffff")
	$PointLight2D.energy = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Global.player_spawnpoint == position + Vector2(0,25):
		$AnimationTree["parameters/Activating_Checkpoint/blend_amount"] = 1
	elif Global.player_spawnpoint != position + Vector2(0,25):
		$AnimationTree["parameters/Activating_Checkpoint/blend_amount"] = 0
	

func _on_checkpoint_area_body_entered(body):
	if body.name =="Character":
		#$AnimationTree["parameters/conditions/is_activating"] = true
		Global.player_health = Global.player_healthMax
		print(body.name)
		#$AnimationPlayer.play("Activated")
		#$CrystalSpire.self_modulate = Color("#df0101" )
		#$PointLight2D.energy = 2
		Global.player_spawnpoint = position + Vector2(0,25)
