extends CanvasLayer

@onready var continue_button: Button = $Panel/VBoxContainer/ContinueButton
@onready var retry_button: Button = $Panel/VBoxContainer/RetryButton
@onready var main_menu_button: Button = $Panel/VBoxContainer/MainMenuButton

func _ready():
	continue_button.pressed.connect(_on_continue_pressed)
	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func show_win():
	print(" Showing Win Menu")
	visible = true
	get_tree().paused = true

func hide_menu():
	visible = false
	get_tree().paused = false

func _on_continue_pressed():
	SFX.play_ui_click()
	print("➡️ Continue to next level")
	hide_menu()

	var current_scene = get_tree().current_scene
	if current_scene:
		var regex := RegEx.new()
		var pattern := "^level_(\\d+)$"
		var error = regex.compile(pattern)

		if error == OK:
			var result = regex.search(current_scene.name)
			if result:
				var current_level = int(result.get_string(1))
				var next_level = current_level + 1
				var next_scene_path = "res://scenes/levels/level_%d.tscn" % next_level  # 🔥 small "level" !

				if ResourceLoader.exists(next_scene_path):
					print("✅ Loading next level: level_%d" % next_level)
					Transition.transition_to_scene(next_scene_path)
				else:
					print("🏁 No more levels. Returning to main menu.")
					Transition.transition_to_scene("res://scenes/main/main_menu.tscn")
			else:
				print("⚠️ Scene name does not match level_X format. Returning to main menu.")
				Transition.transition_to_scene("res://scenes/main/main_menu.tscn")
		else:
			print("❗ Failed to compile regex pattern. Returning to main menu.")
			Transition.transition_to_scene("res://scenes/main/main_menu.tscn")
	else:
		print("❗ No current_scene found. Returning to main menu.")
		Transition.transition_to_scene("res://scenes/main/main_menu.tscn")



func _on_retry_pressed():
	SFX.play_ui_click()
	print(" Retry pressed (Win)")
	hide_menu()
	Transition.transition_to_scene(get_tree().current_scene.scene_file_path)

func _on_main_menu_pressed():
	SFX.play_ui_click()
	print(" Main Menu pressed (Win)")
	hide_menu()
	Transition.transition_to_scene("res://scenes/main/main_menu.tscn")
