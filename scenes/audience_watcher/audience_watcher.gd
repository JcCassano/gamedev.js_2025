extends CharacterBody2D

@export var anger_rate: float = 1.0
@export var check_interval: float = 0.5
@export var squash_node: Node = null  # Drag in the SquashStretchComponent from Visual

@onready var raycasts := $Raycasts.get_children()
@onready var timer: Timer = $Timer

var player_blocking := false

var last_angry_time := 0.0
var angry_cooldown := 1.5  # seconds


signal player_blocked(rate: float)

func _process(delta):
	last_angry_time += delta

func _ready():
	timer.wait_time = check_interval
	timer.timeout.connect(_on_check_block)
	timer.start()

func _on_check_block():
	var is_blocked = false

	for ray in raycasts:
		if ray is RayCast2D and ray.is_colliding():
			var collider = ray.get_collider()
			if collider is CharacterBody2D:
				is_blocked = true
				print(" Ray hit player via", ray.name)
				break

	#  Adjust bounce speed dynamically
	if squash_node and squash_node.has_method("set_bounce_speed"):
		if is_blocked:
			squash_node.set_bounce_speed(squash_node.fast_duration)
		else:
			squash_node.set_bounce_speed(squash_node.default_duration)

	#  Rage + signal logic
	if is_blocked:
		# 🔊 Angry SFX!
		if last_angry_time >= angry_cooldown:
			SFX.play_audience_angry()
			last_angry_time = 0.0
		if not player_blocking:
			print(" Setting player_blocking to TRUE")
			player_blocking = true
			emit_signal("player_blocked", anger_rate)

		if GameManager:
			print(" Calling GameManager.apply_rage(", anger_rate, ")")
			GameManager.apply_rage(anger_rate)
		else:
			print(" GameManager not found?")
	else:
		if player_blocking:
			print(" Audience view is clear now.")
			player_blocking = false
