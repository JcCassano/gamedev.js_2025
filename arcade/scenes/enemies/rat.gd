extends CharacterBody2D

enum RatType { NORMAL, FAST, TANK }
@export var rat_type := RatType.NORMAL

@export var speed := 40.0
@export var charge_speed := 200.0
@export var charge_range := 50.0
@export var attack_cooldown := 1.0
@export var explosion_scene: PackedScene

@export var sprite_normal: Texture2D
@export var sprite_fast: Texture2D
@export var sprite_tank: Texture2D

@onready var timer := $Timer
@onready var attack_area := $Area2D
@onready var health := $HealthComponent
@onready var health_bar := $MiniHealthBar
@onready var hit_flash := $HitFlashComponent
@onready var sfx_player := $SFXPlayer
@onready var floating_damage := $FloatingDamageComponent

@export var hit_sfx: AudioStream
@export var death_sfx: AudioStream
@export var scale_normal := Vector2(1, 1)
@export var scale_fast := Vector2(0.75, 0.75)
@export var scale_tank := Vector2(1.25, 1.25)

# Exported attack motion tuning
@export var rat_lunge_distance := 24.0
@export var rat_jump_height := -10.0
@export var rat_dash_duration := 0.15
@export var rat_attack_offset_y := 12.0
@export var powerup_scene: PackedScene  # Drag your powerup_shotgun.tscn here
@export var powerup_chance := 0.1       # 10% chance (0.0 to 1.0)


var player
var is_charging = false
var can_attack = true
var velocity_vector := Vector2.ZERO
var dash_origin := Vector2.ZERO
var dash_tween: Tween = null
var previous_health := -1

func _ready():
	await get_tree().process_frame  # Wait one frame
	apply_rat_type()
	
	await _wait_for_player()
	
	timer.wait_time = attack_cooldown
	timer.one_shot = true
	timer.timeout.connect(_on_Timer_timeout)
	attack_area.body_entered.connect(_on_attack_area_body_entered)

	health.died.connect(_on_died)
	health.health_changed.connect(_on_health_changed)
	health.damage_taken.connect(_on_damage_taken)

	_on_health_changed(health.current_health, health.max_health)

func _wait_for_player() -> void:
	while true:
		player = get_tree().get_first_node_in_group("player")
		if player:
			break
		await get_tree().process_frame


func apply_rat_type():
	if not health:
		print("HealthComponent not ready!")
		return

	match rat_type:
		RatType.NORMAL:
			speed = 40.0
			charge_speed = 200.0
			health.max_health = 3
			if sprite_normal:
				$Sprite2D.texture = sprite_normal
			$Sprite2D.scale = scale_normal

		RatType.FAST:
			speed = 80.0
			charge_speed = 300.0
			health.max_health = 2
			if sprite_fast:
				$Sprite2D.texture = sprite_fast
			$Sprite2D.scale = scale_fast

		RatType.TANK:
			speed = 25.0
			charge_speed = 100.0
			health.max_health = 5
			if sprite_tank:
				$Sprite2D.texture = sprite_tank
			$Sprite2D.scale = scale_tank

	health.current_health = health.max_health

func _physics_process(delta):
	if not is_instance_valid(player): return

	var target_pos = player.global_position + Vector2(0, rat_attack_offset_y)
	var distance = global_position.distance_to(target_pos)

	if distance > charge_range:
		velocity_vector = (target_pos - global_position).normalized() * speed
	else:
		if !timer.is_stopped():
			velocity_vector = (target_pos - global_position).normalized() * speed
		else:
			velocity_vector = (target_pos - global_position).normalized() * charge_speed
			is_charging = true
			can_attack = true
			timer.start()

	if is_charging and can_attack:
		start_attack_tween()
		for body in attack_area.get_overlapping_bodies():
			if body.is_in_group("player"):
				if body.has_method("take_damage"):
					body.take_damage(1)
					can_attack = false

	velocity = velocity_vector
	move_and_slide()

	if velocity_vector.x != 0:
		$Sprite2D.flip_h = velocity_vector.x < 0

func start_attack_tween():
	if not is_instance_valid(player): return

	var attack_tween := create_tween()
	var direction = (player.global_position + Vector2(0, rat_attack_offset_y) - global_position).normalized()
	var target_pos = global_position + direction * rat_lunge_distance

	attack_tween.tween_property(self, "position", target_pos + Vector2(0, rat_jump_height), rat_dash_duration * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	attack_tween.tween_property(self, "position", target_pos, rat_dash_duration * 0.5)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _on_attack_area_body_entered(body):
	if body.is_in_group("player") and is_charging and can_attack:
		if body.has_method("take_damage"):
			body.take_damage(1)
			can_attack = false

func _on_Timer_timeout():
	is_charging = false
	can_attack = true

func _on_health_changed(current, max):
	if health_bar:
		health_bar.update_health(current, max)

	if previous_health == -1:
		previous_health = current
	else:
		if current < previous_health and hit_flash and hit_flash.has_method("flash"):
			hit_flash.flash()
		previous_health = current

	if current < max and sfx_player and hit_sfx:
		sfx_player.stream = hit_sfx
		sfx_player.play()

func _on_damage_taken(amount: int):
	if floating_damage and floating_damage.has_method("show_damage"):
		floating_damage.show_damage(amount)

func _on_died():
	GameStats.add_rat_kill()
	var fg := get_tree().current_scene.get_node_or_null("ForegroundAudience")
	if fg:
		fg.trigger_crowd_squash_fast()

	#  Spawn death effect immediately
	if explosion_scene:
		var fx = explosion_scene.instantiate()
		fx.global_position = global_position
		get_tree().current_scene.add_child(fx)
		var particles := fx.get_node_or_null("CPUParticles2D")
		if particles:
			particles.emitting = true

	# Play death SFX immediately
	if death_sfx:
		var death_audio := AudioStreamPlayer2D.new()
		death_audio.stream = death_sfx
		death_audio.global_position = global_position
		get_tree().current_scene.add_child(death_audio)
		death_audio.play()
		death_audio.finished.connect(death_audio.queue_free)

	#  Chance to spawn shotgun powerup
	if powerup_scene and randf() <= powerup_chance:
		var powerup = powerup_scene.instantiate()
		powerup.global_position = global_position
		get_tree().current_scene.add_child(powerup)
		print(" Shotgun powerup spawned!")

	# Shake camera
	if is_instance_valid(player) and player.has_method("shake_camera"):
		player.shake_camera(10, 0.15)

	# Kill rat immediately
	queue_free()

	# Optional: reset crowd squash after 0.4s
	if fg:
		await get_tree().create_timer(0.4).timeout
		fg.reset_crowd_speed()
