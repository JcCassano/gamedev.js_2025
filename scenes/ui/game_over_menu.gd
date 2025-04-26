extends CanvasLayer

@onready var retry_button: Button = $Panel/VBoxContainer/RetryButton
@onready var main_menu_button: Button = $Panel/VBoxContainer/MainMenuButton

func _ready():
	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	process_mode = Node.PROCESS_MODE_ALWAYS  #  Ensure responsive even when paused
	visible = false  # Hidden by default

func show_game_over():
	print(" Showing Game Over Menu")
	visible = true
	get_tree().paused = true

func _on_retry_pressed():
	SFX.play_ui_click()
	print(" Retry pressed (Game Over)")
	visible = false
	get_tree().paused = false
	await get_tree().create_timer(0.05).timeout  #  Allow 1 frame delay before changing scene
	Transition.transition_to_scene(get_tree().current_scene.scene_file_path)

func _on_main_menu_pressed():
	SFX.play_ui_click()
	print("🏠 Main Menu pressed (Game Over)")

	visible = false
	get_tree().paused = false

	# 💡 Reset GameManager flags
	if GameManager:
		GameManager.is_game_over = false
		GameManager.is_ready = false
		GameManager.is_gameplay_scene = false

	# 💀 Safely remove player before leaving
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.queue_free()

	await get_tree().create_timer(0.05).timeout
	Transition.transition_to_scene("res://scenes/main/main_menu.tscn")
