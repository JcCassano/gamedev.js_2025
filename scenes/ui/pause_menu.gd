extends CanvasLayer

@onready var resume_button: Button = $Panel/VBoxContainer/ResumeButton
@onready var retry_button: Button = $Panel/VBoxContainer/RetryButton
@onready var main_menu_button: Button = $Panel/VBoxContainer/MainMenuButton

func _ready():
	resume_button.pressed.connect(_on_resume_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func show_menu():
	visible = true
	get_tree().paused = true

func hide_menu():
	visible = false
	get_tree().paused = false

func _on_resume_pressed():
	SFX.play_ui_click()
	print("▶️ Resume pressed")
	hide_menu()

func _on_retry_pressed():
	SFX.play_ui_click()
	print("🔁 Retry pressed")
	hide_menu()
	Transition.transition_to_scene(get_tree().current_scene.scene_file_path)

func _on_main_menu_pressed():
	SFX.play_ui_click()
	print("🏠 Main Menu pressed")
	hide_menu()
	Transition.transition_to_scene("res://scenes/main/main_menu.tscn")
