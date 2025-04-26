extends Node2D

@export var slow_duration := 3.0

@onready var area: Area2D = $Area2D
@onready var timer := $LifetimeTimer
var players_touching := []

func _ready():
	if area:
		area.body_entered.connect(_on_body_entered)
		area.body_exited.connect(_on_body_exited)
	else:
		push_error("Area2D node not found!")

	timer.timeout.connect(_on_LifetimeTimer_timeout)
	timer.start()

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player ENTERED puddle!")
		if body not in players_touching:
			players_touching.append(body)
			print("Calling apply_slow on:", body.name)
			body.call_deferred("apply_slow", slow_duration)

func _on_body_exited(body):
	if body in players_touching:
		print("Player EXITED puddle!")
		players_touching.erase(body)


func _on_LifetimeTimer_timeout():
	queue_free()
