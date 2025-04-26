extends PointLight2D

var flicker_timer: Timer

func start_random_flicker():
	visible = true
	if not flicker_timer:
		flicker_timer = Timer.new()
		flicker_timer.one_shot = false
		add_child(flicker_timer)
		flicker_timer.timeout.connect(_toggle_visibility)

	_toggle_visibility()  # flick immediately
	flicker_timer.start()
	_schedule_next_flicker()

func _toggle_visibility():
	visible = !visible
	_schedule_next_flicker()

func _schedule_next_flicker():
	if flicker_timer:
		flicker_timer.wait_time = randf_range(0.05, 0.12)

func disable_flicker():
	if flicker_timer:
		flicker_timer.stop()
	visible = false
