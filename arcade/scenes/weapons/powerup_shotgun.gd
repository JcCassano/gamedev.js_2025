extends Area2D

@export var powerup_duration: float = 5.0  # How long shotgun lasts when picked up
@export var float_range: float = 4.0  # How much it floats up and down
@export var float_duration: float = 0.5  # How fast it floats
@export var lifetime: float = 20.0  # Despawn after 20 seconds if not collected

var life_timer := 0.0
var floating_started := false

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	_start_floating()

func _physics_process(delta):
	life_timer += delta
	if life_timer >= lifetime:
		print("🧹 Powerup despawned after", lifetime, "seconds.")
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.activate_shotgun_mode(powerup_duration)
		queue_free()

func _start_floating():
	if floating_started:
		return
	floating_started = true

	var original_y = global_position.y
	var tween = create_tween().set_loops()
	tween.tween_property(self, "global_position:y", original_y - float_range, float_duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position:y", original_y + float_range, float_duration)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
