extends CanvasLayer

@onready var fullscreen_check: CheckButton = $Ticket/Panel/VBoxContainer/FullscreenCheck
@onready var bgm_slider: HSlider = $Ticket/Panel/VBoxContainer/BGMVolumeSlider
@onready var sfx_slider: HSlider = $Ticket/Panel/VBoxContainer/SFXVolumeSlider
@onready var main_menu_button: Button = $Ticket/Panel/VBoxContainer/MainMenuButton

const MUSIC_BUS := "BackgroundMusic"
const SFX_BUS := "SFX"

func _ready():
	
	# Fullscreen initial state
	fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN

	# Slider properties
	bgm_slider.min_value = 0.0
	bgm_slider.max_value = 1.0
	bgm_slider.step = 0.01

	sfx_slider.min_value = 0.0
	sfx_slider.max_value = 1.0
	sfx_slider.step = 0.01

	# Load volume values from AudioServer (or default to 0.5 if invalid)
	var bgm_db := AudioServer.get_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS))
	var sfx_db := AudioServer.get_bus_volume_db(AudioServer.get_bus_index(SFX_BUS))
	bgm_slider.value = clamp(db_to_linear(bgm_db), 0.0, 1.0) if bgm_db <= 0.0 else 0.5
	sfx_slider.value = clamp(db_to_linear(sfx_db), 0.0, 1.0) if sfx_db <= 0.0 else 0.5

	# Connect signals
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	bgm_slider.value_changed.connect(_on_bgm_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)

	# Start hidden or visible depending on your usage
	visible = true

func _on_fullscreen_toggled(toggled: bool):
	if toggled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _on_bgm_volume_changed(value: float):
	var db = linear_to_db(clamp(value, 0.0001, 1.0))
	db = min(db, 0.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(MUSIC_BUS), db)

func _on_sfx_volume_changed(value: float):
	var db = linear_to_db(clamp(value, 0.0001, 1.0))
	db = min(db, 0.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(SFX_BUS), db)

func _on_main_menu_pressed():
	SFX.play_ui_click()
	visible = false
	Transition.transition_to_scene("res://scenes/main/main_menu.tscn")
