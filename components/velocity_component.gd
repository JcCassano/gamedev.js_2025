# res://components/velocity.gd
extends Node

@export var speed := 150.0
var velocity: Vector2 = Vector2.ZERO

func update_velocity(input_vector: Vector2) -> void:
	velocity = input_vector.normalized() * speed
