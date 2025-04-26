extends CharacterBody2D

@export var move_speed := 45.0
@export var dash_speed := 160.0
@export var dash_duration := 0.2
@export var dash_cooldown := 1.0

@export var hit_sfx: AudioStream
@export var death_sfx: AudioStream

@onready var health := $HealthComponent
@onready var attack_area := $Area2D
@onready var health_bar := $MiniHealthBar
@onready var hit_flash := $HitFlashComponent
@onready var floating_damage := $FloatingDamageComponent
@onready var sfx_player := $SFXPlayer
@onready var timer := $Timer

var player
var is_dashing := false
var can_attack := true
var velocity_vector := Vector2.ZERO
var previous_health := -1

func _ready():
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	if health:
		health.max_health = 15
		health.current_health = 15
		health.died.connect(_on_died)
		health.health_changed.connect(_on_health_changed)
		health.damage_taken.connect(_on_damage_taken)

	timer.wait_time = dash_cooldown
	timer.one_shot = true
	timer.timeout.connect(_on_dash_cooldown_timeout)

	attack_area.body_entered.connect(_on_attack_area_body_entered)

func _physics_process(delta):
	if not is_instance_valid(player): return

	var target_pos = player.global_position + Vector2(0, 12)
	var dir = (target_pos - global_position).normalized()

	if is_dashing:
		pass
	elif not timer.is_stopped():
		velocity_vector = dir * move_speed
	else:
		is_dashing = true
		velocity_vector = dir * dash_speed
		timer.start()
		await get_tree().create_timer(dash_duration).timeout
		is_dashing = false

	velocity = velocity_vector
	move_and_slide()

	if velocity_vector.x != 0:
		$Sprite2D.flip_h = velocity_vector.x < 0

func _on_dash_cooldown_timeout():
	is_dashing = false
	can_attack = true

func _on_attack_area_body_entered(body):
	if is_dashing and can_attack and body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(1)
			can_attack = false

func _on_health_changed(current: int, max: int):
	if health_bar:
		health_bar.update_health(current, max)

	if previous_health == -1:
		previous_health = current
	else:
		if current < previous_health and hit_flash and hit_flash.has_method("flash"):
			hit_flash.flash()
		previous_health = current

	if current < max and hit_sfx and sfx_player:
		sfx_player.stream = hit_sfx
		sfx_player.play()

func _on_damage_taken(amount: int):
	if floating_damage and floating_damage.has_method("show_damage"):
		floating_damage.show_damage(amount)

func _on_died():
	GameStats.add_jockey_kill()
	if death_sfx:
		var death_audio := AudioStreamPlayer2D.new()
		death_audio.stream = death_sfx
		death_audio.global_position = global_position
		get_tree().current_scene.add_child(death_audio)
		death_audio.play()
		death_audio.finished.connect(death_audio.queue_free)

	if hit_flash and hit_flash.has_method("flash"):
		hit_flash.flash()

	print("☠️ Chicken Jockey defeated!")
	queue_free()
