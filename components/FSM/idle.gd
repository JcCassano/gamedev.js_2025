extends "res://components/FSM/state.gd"

func enter():
	player = get_parent().get_parent()
	state_machine = get_parent()

	# Auto-find SquashStretchComponent if it exists
	var squash_component := player.get_node_or_null("SquashStretchComponent")
	if squash_component and squash_component.has_method("play_bounce_loop"):
		squash_component.play_bounce_loop()


func update(_delta):
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if input_vector.length() > 0:
		state_machine.change_state(state_machine.get_node("Move"))

	if Input.is_action_just_pressed("dash"):
		state_machine.change_state(state_machine.get_node("Dash"))
