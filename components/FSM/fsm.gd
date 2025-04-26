extends Node

var current_state: Node = null

func _ready():
	if get_child_count() > 0:
		current_state = get_child(0)
		current_state.enter()

func change_state(new_state: Node):
	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()

func _physics_process(delta):
	if current_state:
		current_state.update(delta)
