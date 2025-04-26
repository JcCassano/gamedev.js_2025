extends Node

var current_state: Node

func _ready():
	change_state($ArcadeIdle)

func change_state(new_state: Node):
	if current_state == new_state:
		return

	if current_state and current_state.has_method("exit"):
		current_state.exit()

	current_state = new_state

	if current_state and current_state.has_method("enter"):
		current_state.enter()

func _physics_process(delta):
	if current_state and current_state.has_method("update"):
		current_state.update(delta)
