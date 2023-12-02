extends StaticBody2D

@export var health: float = 100.0
var ableToBeHit: bool = true

func _ready():
	pass

func _process(_delta):
	pass

func _hit(damage: int):
	if ableToBeHit:
		print("Crystal is hit")
		health -= damage
		if health <= 0:
			ableToBeHit = false
			$Sprite2D.modulate = Color("#ff0000")
			$DestroyedCrystalSpire.start()
			print("Timer Start")

func _on_destroyed_crystal_spire_timeout():
	get_parent().queue_free()
