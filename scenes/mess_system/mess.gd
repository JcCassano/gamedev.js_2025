extends Area2D

@export var clean_time := 2.0
@export var increase_clean_amount := 5.0
@export var mess_penalty := 5.0

@onready var progress_bar: ProgressBar = $ProgressBar
@onready var bar_background := $ProgressBar/BarBackground
@onready var bar_fill := $ProgressBar/BarBackground/BarFill  #  BarFill for scaling

var player_inside := false
var clean_timer := 0.0
var is_cleaning := false
var player_ref: CharacterBody2D = null
var penalty_applied := false  # Prevent double penalty

func _ready():
	progress_bar.visible = false
	progress_bar.value = 0
	bar_fill.scale.x = 0.0  #  start empty
	bar_fill.z_index = 10  # Ensure it's in front
	bar_background.z_index = 9

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	await get_tree().process_frame
	await get_tree().process_frame

	if not penalty_applied and GameManager and GameManager.is_ready and GameManager.clean_bar:
		GameManager.apply_mess_penalty(mess_penalty)
		penalty_applied = true

func _process(delta):
	z_index = int(global_position.y)

	if not penalty_applied and GameManager and GameManager.is_gameplay_scene and GameManager.clean_bar:
		GameManager.apply_mess_penalty(mess_penalty)
		penalty_applied = true

	#if player_inside and Input.is_action_pressed("interact"):
	if player_inside:
		if not is_cleaning:
			is_cleaning = true
			progress_bar.visible = true
			player_ref.velocity = Vector2.ZERO
			player_ref.velocity_component.set_physics_process(false)

		clean_timer += delta
		var percent: float = clamp(clean_timer / clean_time, 0.0, 1.0)
		progress_bar.value = percent * 100.0
		update_fill_bar(percent)  #  Update bar fill scale

		if clean_timer >= clean_time:
			if GameManager:
				GameManager.increase_clean(increase_clean_amount)
			queue_free()
			player_ref.velocity_component.set_physics_process(true)

	elif is_cleaning:
		is_cleaning = false
		clean_timer = 0.0
		progress_bar.value = 0
		progress_bar.visible = false
		update_fill_bar(0.0)  #  reset
		player_ref.velocity_component.set_physics_process(true)

func _on_body_entered(body):
	if body is CharacterBody2D:
		player_inside = true
		player_ref = body

func _on_body_exited(body):
	if body == player_ref:
		player_inside = false
		clean_timer = 0.0
		is_cleaning = false
		progress_bar.visible = false
		progress_bar.value = 0
		update_fill_bar(0.0)  #  reset on exit
		player_ref.velocity_component.set_physics_process(true)

#  Fills the green bar visually
func update_fill_bar(percent: float):
	var tween := create_tween()
	tween.tween_property(bar_fill, "scale:x", percent, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
