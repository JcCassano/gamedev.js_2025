extends Node

var player
var state_machine

func enter():
	player = get_parent().get_parent()
	state_machine = get_parent()

func update(_delta):
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if Input.is_action_just_pressed("dash"):
		if not player.is_dashing:
			player.start_dash() # 💨 call dash + ghost
		state_machine.change_state(state_machine.get_node("ArcadeDash"))
		return

	if player.velocity_component and player.velocity_component.has_method("update_velocity"):
		player.velocity_component.update_velocity(input_vector)

	# Flip and animate
	_play_walk_animation(input_vector)

	if input_vector.length() == 0:
		state_machine.change_state(state_machine.get_node("ArcadeIdle"))

func exit():
	player.get_node("AnimatedSprite2D").stop()

func _play_walk_animation(input_vector: Vector2):
	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	sprite.animation = "walk"

	# Flip based on horizontal input
	if input_vector.x != 0:
		sprite.flip_h = input_vector.x < 0

	if not sprite.is_playing():
		sprite.play()
