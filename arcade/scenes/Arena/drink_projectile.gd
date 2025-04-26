extends Node2D

@export var fall_speed: float = 300.0
@export var damage: int = 1
@export var puddle_scene: PackedScene  # Assign Puddle.tscn in Inspector

@export var noodle_pickup_scene: PackedScene  # assign in inspector
@export var noodle_drop_chance := 0.05  # 5%


var direction := Vector2.DOWN
var is_falling := true
var target_y := 0.0

func _ready():
	$CPUParticles2D.emitting = false
	$Area2D.body_entered.connect(_on_body_entered)

func launch(from: Vector2):
	global_position = from
	target_y = from.y + 300
	is_falling = true

func _process(delta):
	if not is_falling: return
	position += direction * fall_speed * delta

	if global_position.y >= target_y:
		await _on_hit_ground()

func _on_hit_ground():
	is_falling = false
	$Sprite2D.visible = false
	$Shadow.visible = false
	$CPUParticles2D.emitting = true

	# 🧃 Spawn puddle
	if puddle_scene:
		var puddle = puddle_scene.instantiate()
		puddle.global_position = global_position
		get_tree().current_scene.add_child(puddle)

	await get_tree().create_timer(0.2).timeout
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
