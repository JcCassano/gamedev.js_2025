extends Node
class_name SFXManager

var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()  #  Important: ensures randomness works properly every time

var click_sounds := [
	"res://assets/sfx/ui/click_1.mp3",
	"res://assets/sfx/ui/click_2.mp3",
	"res://assets/sfx/ui/click_3.mp3",
	"res://assets/sfx/ui/click_4.mp3",
	"res://assets/sfx/ui/click_5.mp3"
]

var audience_angry_sounds := [
	"res://assets/sfx/audience/angry_1.mp3",
	"res://assets/sfx/audience/angry_2.mp3",
	"res://assets/sfx/audience/angry_3.mp3"
]


func _play(path: String, bus: String = "SFX", pitch_variation := false):
	var sound = AudioStreamPlayer.new()
	sound.stream = load(path)
	sound.bus = bus
	if pitch_variation:
		sound.pitch_scale = rng.randf_range(0.95, 1.05)
	add_child(sound)
	sound.play()
	sound.finished.connect(sound.queue_free)

func play_ui_click():
	var sound = click_sounds[rng.randi_range(0, click_sounds.size() - 1)]
	_play(sound, "UI", true)

func play_audience_angry():
	var sound = audience_angry_sounds[rng.randi_range(0, audience_angry_sounds.size() - 1)]
	_play(sound, "SFX", true)  # Optional pitch variation
