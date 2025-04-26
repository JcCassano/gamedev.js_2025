extends Node

@export var rat_scene: PackedScene
@export var initial_spawn_interval := 2.0
@export var spawn_limit := 30
@export var difficulty_increase_interval := 30.0
@export var min_spawn_interval := 0.5
@export var chicken_jockey_scene: PackedScene


@onready var spawn_timer: Timer = $SpawnTimer
var spawn_points: Array[Marker2D] = []
var difficulty_timer := 0.0
var current_spawn_interval := 0.0

func _ready():
	for child in get_children():
		if child is Marker2D:
			spawn_points.append(child)

	if spawn_points.is_empty():
		push_warning("No Marker2D spawn points found!")

	current_spawn_interval = initial_spawn_interval
	spawn_timer.wait_time = current_spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _process(delta):
	difficulty_timer += delta
	if difficulty_timer >= difficulty_increase_interval:
		difficulty_timer = 0.0
		current_spawn_interval = max(min_spawn_interval, current_spawn_interval - 0.25)
		spawn_timer.wait_time = current_spawn_interval
		print("Rat spawn rate increased! Interval now:", current_spawn_interval)

func _on_spawn_timer_timeout():
	if spawn_points.is_empty() or spawn_limit <= 0:
		return

	var spawn_point = spawn_points.pick_random()
	var rat = rat_scene.instantiate()
	rat.global_position = spawn_point.global_position

	var types = [rat.RatType.NORMAL, rat.RatType.FAST, rat.RatType.TANK]
	rat.rat_type = types.pick_random()
	rat.apply_rat_type()  #  Important: assign speed, sprite, and HP

	get_tree().current_scene.add_child(rat)
	print("Spawned rat at:", spawn_point.name)

	spawn_limit -= 1

func spawn_chicken_jockeys(count := 3):
	if spawn_points.is_empty():
		return

	for i in count:
		var spawn_point = spawn_points.pick_random()
		var jockey = chicken_jockey_scene.instantiate()
		jockey.global_position = spawn_point.global_position
		get_tree().current_scene.add_child(jockey)
		print("Spawned Chicken Jockey at:", spawn_point.name)
