extends CharacterBody2D

@export var velocity_component: Node
@export var squash_node: SquashStretch


@onready var state_machine = $FSM

func _physics_process(delta):
	state_machine._physics_process(delta)
	velocity = velocity_component.velocity
	move_and_slide()

func _process(delta):
	z_index = int(global_position.y)
