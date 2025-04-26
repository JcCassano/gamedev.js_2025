extends Node2D

@export var gravity: float = 9.8
@export var time_mult: float = 6.0
@export var throw_angle_degrees: float = 60.0
@export var distance: float = 200.0

var initial_speed: float
var time: float = 0.0
var z_axis: float = 0.0
var is_launching: bool = false
var direction: Vector2
var initial_position: Vector2

func _ready():
	set_process(true)

#  This is the function your spawner is trying to call!
func launch(from: Vector2, dir: Vector2):
	initial_position = from
	direction = dir.normalized()
	initial_speed = sqrt(distance * gravity / sin(2 * deg_to_rad(throw_angle_degrees)))
	global_position = initial_position
	time = 0.0
	z_axis = 0.0
	is_launching = true
	$CleanupTimer.start()

func _process(delta):
	if not is_launching: return

	time += delta * time_mult
	z_axis = initial_speed * sin(deg_to_rad(throw_angle_degrees)) * time - 0.5 * gravity * time * time

	if z_axis > 0:
		var x_axis = initial_speed * cos(deg_to_rad(throw_angle_degrees)) * time
		global_position = initial_position + direction * x_axis
		$Projectile.position.y = -z_axis

		$Shadow.position.x = $Projectile.position.x
		$Shadow.position.y = 0

		var max_scale = 1.0
		var min_scale = 0.4
		var scale_ratio = clamp(1.0 - (z_axis / 300.0), min_scale, max_scale)
		$Shadow.scale = Vector2(scale_ratio, scale_ratio)
	else:
		land()

func land():
	is_launching = false
	$Projectile.position.y = 0
	$Shadow.visible = false
	print(" Arena projectile landed at:", global_position)

func _on_CleanupTimer_timeout():
	queue_free()
