extends Node2D

@onready var spawn_timer: Timer = $SpawnTimer
@onready var audience_node: Node2D = $AudienceWatcher

@export var projectile_scene: PackedScene
@export var auto_spawn_audience: bool = false  #  Toggle in Inspector

# 🎯 Tuning Variables
@export var spawn_interval: float = 1.0
@export var launch_distance_min: float = 15.0
@export var launch_distance_max: float = 30.0
@export var launch_angle_degrees: float = 45.0
@export var throw_radius: float = 15.0

func _ready():
	randomize()

	#  Toggle audience watcher visibility and logic
	if auto_spawn_audience:
		audience_node.visible = true
		audience_node.set_process(true)
		audience_node.set_physics_process(true)
	else:
		audience_node.queue_free()

	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout():
	var spawn_pos = global_position

	#  Random splash offset around the seat
	var target_offset = Vector2(
		randf_range(-throw_radius, throw_radius),
		randf_range(-throw_radius * 0.5, throw_radius * 0.5)
	)
	var target_pos = global_position + target_offset
	var direction = (target_pos - spawn_pos).normalized()

	#  Fire popcorn
	var new_projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(new_projectile)

	var random_distance = randf_range(launch_distance_min, launch_distance_max)
	new_projectile.launch(spawn_pos, direction, random_distance, launch_angle_degrees)

func _process(delta):
	z_index = int(global_position.y)
