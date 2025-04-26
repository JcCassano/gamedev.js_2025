extends "res://components/FSM/state.gd"

@export var dash_speed := 600.0
@export var dash_duration := 0.2
var timer := 0.0
var dash_vector := Vector2.ZERO

func enter():
	print("Entered Dash")
	player = get_parent().get_parent()
	state_machine = get_parent()

	timer = dash_duration
	dash_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	# Prevent NaN or stationary dash
	if dash_vector == Vector2.ZERO:
		dash_vector = Vector2.DOWN

	player.velocity = dash_vector.normalized() * dash_speed

func update(delta):
	timer -= delta
	player.move_and_slide()

	if timer <= 0:
		state_machine.change_state(state_machine.get_node("ArcadeIdle"))

func exit():
	player.velocity = Vector2.ZERO  # Optional reset
