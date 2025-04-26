extends Area2D

var pos: Vector2
var rota: float
var dir: float
var speed = 500
@export var damage: int = 1

func _ready():
	global_position = pos
	global_rotation = rota
	connect("body_entered", _on_body_entered)

	# Start emitting trail (will follow because it's still parented)
	if $TrailParticles:
		$TrailParticles.emitting = true
		$TrailParticles.one_shot = false  # Continuous while moving

func _physics_process(delta):
	position += Vector2(speed * delta, 0).rotated(dir)

func _on_body_entered(body):
	print(" ENTERED BODY:", body.name)

	var health = body.find_child("HealthComponent", true, false)
	if health:
		print(" Bullet found HealthComponent on", body.name)
		if health.has_method("take_damage"):
			print(" Calling take_damage()!")
			health.take_damage(damage)

	# Detach and persist the trail effect
	var trail := $TrailParticles
	if trail and trail is CPUParticles2D:
		trail.one_shot = true
		trail.emitting = false
		trail.restart()
		trail.emitting = true
		trail.get_parent().remove_child(trail)
		trail.global_position = global_position
		get_tree().current_scene.add_child(trail)

		# Let the trail finish in the background (no await!)
		# We'll use a Timer or script cleanup later if needed

	#  Disable further hits immediately
	$CollisionShape2D.disabled = true
	visible = false

	# Remove projectile
	queue_free()
