extends Node

var player
var state_machine

func enter():
	player = get_parent().get_parent()
	state_machine = get_parent()

	# Play idle animation
	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	sprite.animation = "idle"
	sprite.play()

func update(_delta):
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_vector.length() > 0:
		state_machine.change_state(state_machine.get_node("ArcadeMove"))

func exit():
	player.get_node("AnimatedSprite2D").stop()
