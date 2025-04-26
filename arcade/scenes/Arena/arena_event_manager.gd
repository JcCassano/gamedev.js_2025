extends Node

@onready var modulate := $"../CanvasModulate"
@onready var tv_light := $"../StageBackground/tv_light"
@onready var tv_light2 := $"../StageBackground/tv_light2"
@onready var tv_lights := [tv_light, tv_light2]
@onready var flicker_lights := $"../StageBackground/FlickerLights".get_children()
@onready var event_timer := $EventTimer

@export var chicken_jockey_audio: AudioStream
@export var chicken_audience_audio: AudioStream
@export var flint_and_steel_audio: AudioStream
@export var off_to_on_audio: AudioStream
@export var switch_off_audio: AudioStream
@export var flickering_audio: AudioStream
@export var flicker_duration := 5.0

var jockey_audio_player := AudioStreamPlayer.new()
var audience_audio_player := AudioStreamPlayer.new()
var flint_audio_player := AudioStreamPlayer.new()
var off_to_on_player := AudioStreamPlayer.new()
var switch_off_player := AudioStreamPlayer.new()
var flickering_player := AudioStreamPlayer.new()

func _ready():
	randomize()
	_initialize_state()
	add_child(jockey_audio_player)
	add_child(audience_audio_player)
	add_child(flint_audio_player)
	add_child(off_to_on_player)
	add_child(switch_off_player)
	add_child(flickering_player)
	call_deferred("start_event_sequence")

func _initialize_state():
	modulate.color = Color.WHITE
	for light in tv_lights:
		light.visible = false
	for light in flicker_lights:
		light.visible = false
		if light.has_method("disable_flicker"):
			light.disable_flicker()

func start_event_sequence() -> void:
	await _wait(15.0)
	_play_switch_off()
	_set_cinema_mode()

	await _wait(15.0)
	_trigger_chicken_jockey()
	await _wait(5.0)
	_play_switch_off()
	_set_cinema_mode()

	await _wait(25.0)
	await _trigger_flicker_event()
	await _wait(5.0)
	_play_switch_off()
	_turn_off_flickers_only()
	await _wait(5.0)
	_set_cinema_mode()

	await _wait(20.0)  # This brings us to ~90s
	_trigger_nether_event()
	print("Triggered [Nether Event] at:", Time.get_ticks_msec() / 1000.0, "s")
	await _wait(5.0)
	_play_switch_off()
	_turn_off_flickers_only()
	await _wait(5.0)
	_set_cinema_mode()
	await _wait(15.0)

	while true:
		await _trigger_random_event()
		await _wait(5.0)
		_play_switch_off()
		_turn_off_flickers_only()
		await _wait(5.0)
		_set_cinema_mode()
		await _wait(15.0)

func _wait(duration: float) -> void:
	event_timer.stop()
	event_timer.wait_time = duration
	event_timer.start()
	await event_timer.timeout

func _play_switch_off():
	if switch_off_audio:
		switch_off_player.stream = switch_off_audio
		switch_off_player.play()

func _set_cinema_mode():
	var all_lights_off := true
	for light in tv_lights:
		if light.visible:
			all_lights_off = false
			break

	modulate.color = Color(0.2, 0.2, 0.2, 1)
	for light in tv_lights:
		light.visible = true

	for f in flicker_lights:
		f.visible = false
		if f.has_method("disable_flicker"):
			f.disable_flicker()

	if all_lights_off and off_to_on_audio:
		off_to_on_player.stream = off_to_on_audio
		off_to_on_player.play()

func _trigger_random_event() -> void:
	var roll = randi() % 3
	match roll:
		0: _trigger_chicken_jockey()
		1: await _trigger_flicker_event()
		2: _trigger_nether_event()

func _trigger_chicken_jockey():
	print("Chicken Jockey Triggered (Projectile Barrage)")
	for light in tv_lights:
		light.visible = true
	for f in flicker_lights:
		f.visible = false
		if f.has_method("disable_flicker"):
			f.disable_flicker()

	if chicken_jockey_audio:
		jockey_audio_player.stream = chicken_jockey_audio
		jockey_audio_player.play()

	if chicken_audience_audio:
		audience_audio_player.stream = chicken_audience_audio
		audience_audio_player.play()

	var scene = get_tree().current_scene
	if scene and scene.has_method("trigger_chicken_jockey"):
		scene.trigger_chicken_jockey()

	var spawner = scene.get_node_or_null("ProjectileSpawner")
	if spawner and spawner.has_method("start_chicken_jockey_barrage"):
		spawner.start_chicken_jockey_barrage(3.0)

func _trigger_flicker_event() -> void:
	print("Flicker Event Triggered")
	for light in tv_lights:
		light.visible = false
	for f in flicker_lights:
		if f.has_method("start_random_flicker"):
			f.visible = true
			f.start_random_flicker()

	if flint_and_steel_audio:
		flint_audio_player.stream = flint_and_steel_audio
		flint_audio_player.play()

	if flickering_audio:
		flickering_player.stream = flickering_audio
		flickering_player.play()

func _trigger_nether_event():
	print("Nether Event Triggered: Chicken Jockey Rush!")
	for light in tv_lights:
		light.visible = true
	for f in flicker_lights:
		f.visible = false
		if f.has_method("disable_flicker"):
			f.disable_flicker()

	if chicken_jockey_audio:
		jockey_audio_player.stream = chicken_jockey_audio
		jockey_audio_player.play()

	var scene = get_tree().current_scene
	if scene and scene.has_node("EnemySpawner"):
		var spawner = scene.get_node("EnemySpawner")
		if spawner and spawner.has_method("spawn_chicken_jockeys"):
			var count = randi_range(2, 4)
			spawner.spawn_chicken_jockeys(count)

func _turn_off_flickers_only():
	for light in tv_lights:
		light.visible = false
	for f in flicker_lights:
		f.visible = false
		if f.has_method("disable_flicker"):
			f.disable_flicker()
