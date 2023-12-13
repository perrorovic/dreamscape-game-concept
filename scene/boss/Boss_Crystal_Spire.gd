extends StaticBody2D

# To show the crystal in front of EVERYTHING you need to change this
# CanvasItems > Ordering > Z Index

@export var health: float = 100.0
var ableToBeHit: bool = false

func _ready():
	pass

func _process(_delta):
	pass

func _hit(damage, _iframe_type, _set_direction, _knockback_power):
	if ableToBeHit:
		print("Crystal is hit")
		health -= damage
		if health <= 0:
			ableToBeHit = false
			$Sprite2D.modulate = Color("#ff0000")
			# Set timer which the AOE will be deleted based on what type the world is
			# This type are assigned when spawned by boss therefore there will never be: A bomb on B world
			# And the assigned value will always be correct
			if Global.worldType == "Night":
				$DestroyedCrystalSpire.start(1.5)
				print("Crystal Night Timer")
			elif Global.worldType == "Day":
				$DestroyedCrystalSpire.start(0.5)
				print("Crystal Day Timer")

func _on_destroyed_crystal_spire_timeout():
	get_parent().queue_free()
