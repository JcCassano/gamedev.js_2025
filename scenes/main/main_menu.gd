extends Control

@onready var quit_button: Button = $QuitButton
@onready var overtime_button: Button = $VBoxContainer/OverTimeButton
@onready var instructions_button: Button = $VBoxContainer/InstructionsButton
@onready var options_button: Button = $VBoxContainer/Options
@onready var options_menu: CanvasLayer = $CanvasLayer/OptionsMenu
@onready var floating_ui := $FloatingUI

func _ready():
	# Connect static buttons
	quit_button.pressed.connect(_on_quit_pressed)
	overtime_button.pressed.connect(_on_overtime_pressed)
	instructions_button.pressed.connect(_on_instructions_pressed)
	options_button.pressed.connect(_on_options_pressed)

	# Connect level buttons manually (LevelButton_0 to LevelButton_8)
	for i in range(9):
		var level_btn := get_node_or_null("LevelButton_%d" % i)
		if level_btn:
			level_btn.pressed.connect(func():
				SFX.play_ui_click()
				var scene_path := "res://scenes/levels/level_%d.tscn" % i
				Transition.transition_to_scene(scene_path)
			)




	# Connect static buttons
	quit_button.pressed.connect(_on_quit_pressed)
	overtime_button.pressed.connect(_on_overtime_pressed)
	instructions_button.pressed.connect(_on_instructions_pressed)
	options_button.pressed.connect(_on_options_pressed)

func _on_quit_pressed():
	SFX.play_ui_click()
	get_tree().quit()

func _on_overtime_pressed():
	SFX.play_ui_click()
	print("🕒 Entering Overtime Arena Mode...")
	Transition.transition_to_scene("res://arcade/scenes/Arena/arena.tscn")

func _on_instructions_pressed():
	SFX.play_ui_click()
	Transition.transition_to_scene("res://scenes/main/instructions_menu.tscn")

func _on_options_pressed():
	SFX.play_ui_click()
	Transition.transition_to_scene("res://scenes/ui/options_menu.tscn")
