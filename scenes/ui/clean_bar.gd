extends Node

@onready var bar: TextureProgressBar = $TextureProgressBar

var clean := 100.0 : set = set_clean  # Starts full
var max_clean := 100.0

signal clean_depleted

func _ready():
	set_clean(max_clean)  # Initialize full

func set_clean(value):
	clean = clamp(value, 0.0, max_clean)
	update_bar()
	if clean <= 0:
		emit_signal("clean_depleted")

func increase_clean(amount: float):
	set_clean(clean + amount)

func decrease_clean(amount: float):
	set_clean(clean - amount)

func update_bar():
	print("🧼 CleanBar updated to:", clean)
	bar.value = clean
