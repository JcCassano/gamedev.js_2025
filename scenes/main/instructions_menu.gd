extends Control

@onready var back_button := $BackButton

func _ready():
	back_button.pressed.connect(_on_back_pressed)

func _on_back_pressed():
	SFX.play_ui_click()
	Transition.transition_to_scene("res://scenes/main/main_menu.tscn")
