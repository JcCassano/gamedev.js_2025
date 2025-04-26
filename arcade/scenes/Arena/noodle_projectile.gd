extends Node2D

@export var fall_speed: float = 300.0
@export var noodle_pickup_scene: PackedScene  # ← Drag `NoodlePickup.tscn` into this in Inspector
@export var drop_distance: float = 300.0  # How far it falls
@export var float_offset_y: float = -4.0  # Fine-tune spawn Y if needed

var direction := Vector2.DOWN
var is_falling := true
var target_y := 0.0

func _ready():
	$CPUParticles2D.emitting = false

func launch(from: Vector2, dir := Vector2.DOWN):
	global_position = from
	direction = dir
	target_y = from.y + drop_distance
	is_falling = true
	print("Launched noodle projectile from:", from)

func _process(delta):
	if not is_falling:
		return

	position += direction * fall_speed * delta

	if global_position.y >= target_y:
		await _on_hit_ground()

func _on_hit_ground():
	is_falling = false
	print("NoodleProjectile hit ground at:", global_position)

	# Optional VFX
	$Sprite2D.visible = false
	if has_node("Shadow"):
		$Shadow.visible = false
	$CPUParticles2D.emitting = true

	# ✅ Spawn pickup
	if noodle_pickup_scene:
		var pickup = noodle_pickup_scene.instantiate()
		pickup.global_position = global_position + Vector2(0, float_offset_y)
		get_tree().current_scene.add_child(pickup)
		print("Spawned noodle pickup at:", pickup.global_position)
	else:
		print("No noodle pickup scene assigned!")

	await get_tree().create_timer(0.2).timeout
	queue_free()
