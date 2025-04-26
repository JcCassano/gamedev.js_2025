extends Node
class_name FloatingUI

@export var amplitude_y := 10.0       # Vertical bob amount
@export var amplitude_x := 4.0        # Horizontal wobble amount
@export var speed := 1.5              # Global speed multiplier

var base_position := Vector2.ZERO

func _ready():
	if get_parent() is Node2D or get_parent() is Control:
		base_position = get_parent().position
	else:
		push_warning("FloatingUI must be a child of Node2D or Control")

func _process(delta):
	var time := Time.get_ticks_msec() / 1000.0
	var y_offset := sin(time * speed) * amplitude_y
	var x_offset := sin((time + 1.0) * speed * 0.7) * amplitude_x

	var offset := Vector2(x_offset, y_offset)
	var parent := get_parent()

	if parent is Node2D:
		parent.position = base_position + offset
	elif parent is Control:
		parent.position = base_position + offset
