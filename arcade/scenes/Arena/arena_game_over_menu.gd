extends CanvasLayer

@onready var time_label: Label = $Panel/VBoxContainer/TimeLabel
@onready var rats_label: Label = $Panel/VBoxContainer/RatsLabel
@onready var jockeys_label: Label = $Panel/VBoxContainer/JockeysLabel
@onready var score_label: Label = $Panel/VBoxContainer/ScoreLabel
@onready var retry_button: Button = $Panel/VBoxContainer/RetryButton
@onready var main_menu_button: Button = $Panel/VBoxContainer/MainMenuButton

func _ready():
	retry_button.pressed.connect(_on_retry_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func show_arena_results(points: int, time_seconds: float, rat_kills: int, jockey_kills: int) -> void:
	visible = true

	var minutes := int(time_seconds) / 60
	var seconds := int(time_seconds) % 60

	time_label.text = "Time Survived: %02d:%02d" % [minutes, seconds]
	rats_label.text = "Rats Defeated: %d" % rat_kills
	jockeys_label.text = "Jockeys Defeated: %d" % jockey_kills
	score_label.text = "Points: %d" % points

	get_tree().paused = true

func _on_retry_pressed():
	SFX.play_ui_click()
	print("Retry pressed (Arena)")
	visible = false
	get_tree().paused = false
	await get_tree().create_timer(0.05).timeout
	Transition.transition_to_scene(get_tree().current_scene.scene_file_path)

func _on_main_menu_pressed():
	SFX.play_ui_click()
	print("🏠 Main Menu pressed (Arena)")
	visible = false
	get_tree().paused = false
	await get_tree().create_timer(0.05).timeout
	Transition.transition_to_scene("res://scenes/main/main_menu.tscn")
