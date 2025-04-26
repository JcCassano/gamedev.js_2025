extends Node2D

@export var fall_speed: float = 300.0
@export var damage: int = 1

var direction: Vector2
var is_falling = false
var target_y: float

func _ready():
	$Hurtbox.body_entered.connect(_on_body_entered)
	$Hurtbox.area_entered.connect(_on_area_entered)
	$CPUParticles2D.emitting = false  # Ensure it's not playing on spawn

func launch(from: Vector2, dir: Vector2):
	global_position = from
	direction = dir.normalized()
	target_y = from.y + 300
	is_falling = true


func _process(delta):
	if not is_falling:
		return

	position += direction * fall_speed * delta

	if global_position.y >= target_y:
		await _on_projectile_landed()

func _on_projectile_landed():
	global_position.y = target_y
	is_falling = false
	$Projectile.visible = false
	$Shadow.visible = false

	# Play particle effect
	$CPUParticles2D.emitting = true
	print("Arena projectile landed with effect at:", global_position)

	await get_tree().create_timer(0.3).timeout  # Delay cleanup
	queue_free()

func _on_body_entered(body):
	print("👀 body_entered triggered by:", body.name, "type:", typeof(body))
	if body.is_in_group("player"):
		print("DIRECT: Hit player group!")
		if body.has_method("take_damage"):
			print("Calling take_damage on:", body.name)
			body.take_damage(damage)
		else:
			print("body has NO take_damage method!")
		queue_free()  # Instantly despawn on hit

func _on_area_entered(area):
	print("⚠️ area_entered triggered by:", area.name, "type:", typeof(area))
