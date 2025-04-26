extends Node2D

var initial_speed: float
var throw_angle_degrees: float
const gravity: float = 9.8
var time: float = 0.0

var initial_position: Vector2
var throw_direction: Vector2
var z_axis = 0.0
var is_launch: bool = false
var time_mult: float = 6.0

@export var mess_scene: PackedScene

func _ready():
	set_process(true)

func _process(delta):
	z_index = int(global_position.y)

	if is_launch:
		time += delta * time_mult
		z_axis = initial_speed * sin(deg_to_rad(throw_angle_degrees)) * time - 0.5 * gravity * pow(time, 2)

		if z_axis > 0:
			var x_axis = initial_speed * cos(deg_to_rad(throw_angle_degrees)) * time
			global_position = initial_position + throw_direction * x_axis
			$Projectile.position.y = -z_axis

			$Shadow.position.x = $Projectile.position.x
			$Shadow.position.y = 0

			var max_scale = 1.0
			var min_scale = 0.4
			var scale_ratio = clamp(1.0 - (z_axis / 300.0), min_scale, max_scale)
			$Shadow.scale = Vector2(scale_ratio, scale_ratio)
		else:
			await _on_landed()

func launch(initial_pos: Vector2, direction: Vector2, distance: float, angle_deg: float):
	initial_position = initial_pos
	throw_direction = direction.normalized()
	throw_angle_degrees = angle_deg
	initial_speed = sqrt(distance * gravity / sin(2 * deg_to_rad(angle_deg)))
	global_position = initial_position
	time = 0.0
	z_axis = 0
	is_launch = true

func _on_landed() -> void:
	is_launch = false
	z_axis = 0
	$Projectile.position.y = 0
	$Shadow.visible = false
	set_process(false)

	await get_tree().create_timer(1.0).timeout
	
	if SFX:
		SFX._play("res://assets/sfx/world/pop_sound.mp3", "SFX", true)

	# 🎯 30% spawn chance
	if randi() % 10 < 3 and mess_scene:
		var mess = mess_scene.instantiate()
		mess.global_position = global_position
		get_tree().current_scene.add_child(mess)

	queue_free()
