extends Node

var player: CharacterBody2D
var state_machine: Node

func enter():
	player = get_parent().get_parent()
	state_machine = get_parent()


func exit():
	pass

func update(_delta: float):
	pass
