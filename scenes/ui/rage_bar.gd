extends Node

@onready var progress_bar: TextureProgressBar = $TextureProgressBar

var rage := 0.0 : set = set_rage
var max_rage := 100.0

signal rage_maxed_out

func _ready():
	update_bar()

func set_rage(value):
	rage = clamp(value, 0.0, max_rage)
	update_bar()
	if rage >= max_rage:
		emit_signal("rage_maxed_out")

func increase_rage(amount: float):
	set_rage(rage + amount)

func decrease_rage(amount: float):
	set_rage(rage - amount)

func update_bar():
	print("🧪 RageBar updated to:", rage)
	progress_bar.value = rage
