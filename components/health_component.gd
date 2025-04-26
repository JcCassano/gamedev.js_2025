extends Node

@export var max_health: int = 10


var current_health: int

signal died
signal health_changed(current: int, max: int)
signal damage_taken(amount: int)  #  NEW SIGNAL


func _ready():
	current_health = max_health

func take_damage(amount: int):
	current_health -= amount
	emit_signal("health_changed", current_health, max_health)
	emit_signal("damage_taken", amount)  #  Emit damage taken
	print(" Took damage! Health:", current_health, "/", max_health)

	if current_health <= 0:
		die()


func die():
	print("💀 Entity died!")
	emit_signal("died")
