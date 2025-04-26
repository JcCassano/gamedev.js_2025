extends Control

@export var shift_duration := 30  #  Seconds until level ends
@onready var label: Label = $MarginContainer/TimeLabel
@onready var timer: Timer = $Timer

var time_left: int

func _ready():
	time_left = shift_duration
	timer.wait_time = shift_duration
	timer.start()
	update_label()
	timer.timeout.connect(_on_timer_timeout)
	set_process(true)

func _process(_delta):
	if time_left > 0:
		time_left = int(timer.time_left)
		update_label()

func update_label():
	label.text = "Shift Ends: %ds" % time_left

func _on_timer_timeout():
	print(" Shift ended – player wins!")
	if GameManager:
		GameManager.win_game()
