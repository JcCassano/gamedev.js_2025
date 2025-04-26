extends CharacterBody2D

@export var velocity_component: Node
@onready var state_machine := $ArcadePlayerFSM
@onready var health := $HealthComponent
@onready var health_bar := $MiniHealthBar
@onready var weapon := $Weapon
@onready var hit_flash := $HitFlashComponent
@onready var camera := $Camera2D
@onready var floating_damage := $FloatingDamageComponent
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var ghost_timer: Timer = $GhostTimer

# Slowing mechanism
@export var slow_multiplier := 0.5
@export var slow_duration := 3.0
@export var ghost_scene: PackedScene = preload("res://arcade/scenes/ArcadePlayer/ghost.tscn") # ← adjust path if needed
@export var z_index_offset := 16  # Tune this value to match foot level

var is_slowed := false
var slow_timer := 0.0

var ui_health_bar: ProgressBar
var is_dashing := false

#  Shotgun Powerup
var shotgun_mode := false
var shotgun_timer: Timer
var normal_spread := 10
var normal_fire_rate := .2
var shotgun_spread := 45
var shotgun_fire_rate := 0.1

func _ready():
	ghost_timer.timeout.connect(_on_ghost_timer_timeout)

	if health:
		health.died.connect(_on_player_died)
		health.health_changed.connect(_on_health_changed)
		health.damage_taken.connect(_on_damage_taken)
		_on_health_changed(health.current_health, health.max_health)

	# UI Link
	var ui_root: Node = null
	if get_tree().current_scene.has_node("UIManager"):
		ui_root = get_tree().current_scene.get_node("UIManager")
	elif get_tree().current_scene.has_node("ArenaUI"):
		ui_root = get_tree().current_scene.get_node("ArenaUI")

	if ui_root:
		ui_health_bar = ui_root.get_node_or_null("PlayerHealthBar")
		if ui_health_bar:
			ui_health_bar.max_value = health.max_health
			ui_health_bar.value = health.current_health
		else:
			print("UI HealthBar NOT found!")
	else:
		print("No UI root (UIManager or ArenaUI) found!")

func _process(_delta):
	if sprite and sprite.sprite_frames:
		var frame_texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
		if frame_texture:
			z_index = int(global_position.y + sprite.position.y + frame_texture.get_height() * 0.5 - z_index_offset)

func _physics_process(delta):
	if is_slowed:
		slow_timer -= delta
		if slow_timer <= 0:
			is_slowed = false
			print(" Slow effect ended")

	var multiplier = slow_multiplier if is_slowed else 1.0
	if is_slowed:
		print("Slowed movement! Multiplier:", multiplier)

	velocity = velocity_component.velocity * multiplier
	state_machine._physics_process(delta)
	move_and_slide()

func take_damage(amount: int):
	print("take_damage() CALLED! Amount:", amount)
	if health:
		health.take_damage(amount)
	else:
		print("No HealthComponent attached!")

	if hit_flash and hit_flash.has_method("flash"):
		hit_flash.flash()
		print("Player flash triggered")

	shake_camera(2.5, 0.12, 20)

func _on_damage_taken(amount: int):
	if floating_damage and floating_damage.has_method("show_damage"):
		floating_damage.show_damage(amount)

func _on_health_changed(current: int, max: int):
	if ui_health_bar:
		ui_health_bar.max_value = max
		ui_health_bar.value = current
	if health_bar and health_bar.has_method("update_health"):
		health_bar.update_health(current, max)

func _on_player_died():
	print("Player died!")
	if has_node("/root/GameManager"):
		get_node("/root/GameManager")._show_game_over_menu()
	else:
		print("GameManager not found!")
	get_tree().paused = true

func _on_Hurtbox_body_entered(body):
	print("Hurtbox collision with:", body.name)
	if body.is_in_group("enemy_projectile"):
		print(" Projectile hit player via Hurtbox!")
		if health:
			health.take_damage(1)
		else:
			print("No health component on player!")

# External trigger from puddle
func apply_slow(duration = 3.0):
	print("Player is SLOWED for", duration, "seconds!")
	is_slowed = true
	slow_timer = duration

func add_health(amount: int):
	if health:
		health.current_health = clamp(health.current_health + amount, 0, health.max_health)
		_on_health_changed(health.current_health, health.max_health)
		print("Healed! HP:", health.current_health, "/", health.max_health)
	else:
		print("No HealthComponent to add health to!")

# 🎥 Screen Shake Function (Juicy + Dampened)
func shake_camera(amount := 4.0, duration := 0.15, frequency := 25):
	if not camera:
		return

	var tween := create_tween()
	var shake_times = int(frequency * duration)
	var shake_interval = duration / shake_times

	for i in range(shake_times):
		var factor = 1.0 - float(i) / shake_times
		var offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * amount * factor
		tween.tween_property(camera, "offset", offset, shake_interval * 0.5)
		tween.tween_property(camera, "offset", Vector2.ZERO, shake_interval * 0.5)

func start_dash():
	if is_dashing: return
	is_dashing = true
	print("✅ Entered Dash")

	_trigger_fast_audience_squash()

	ghost_timer.start()
	await get_tree().create_timer(0.2).timeout  # Dash duration
	is_dashing = false
	ghost_timer.stop()
	print("🏁 Dash ended")

func _on_ghost_timer_timeout():
	spawn_ghost()

func spawn_ghost():
	print("Spawning ghost...")

	var ghost := ghost_scene.instantiate()
	var ghost_sprite := ghost.get_node("AnimatedSprite2D")

	if not sprite or not ghost_sprite:
		print("Missing sprite or ghost sprite!")
		return

	var animation_name := sprite.animation
	var frame_index := sprite.frame

	if sprite.sprite_frames and sprite.sprite_frames.has_animation(animation_name):
		ghost_sprite.sprite_frames = sprite.sprite_frames
		ghost_sprite.animation = animation_name
		ghost_sprite.frame = frame_index
	else:
		print("Sprite animation invalid:", animation_name)
		return

	ghost.global_position = global_position
	ghost_sprite.flip_h = sprite.flip_h
	ghost_sprite.scale = sprite.global_scale
	ghost_sprite.modulate = Color(1, 1, 1, 0.7)

	ghost.z_index = sprite.z_index - 1

	get_tree().current_scene.add_child(ghost)

	var tween := ghost.create_tween()
	tween.tween_property(ghost_sprite, "modulate:a", 0.0, 0.3).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(Callable(ghost, "queue_free"))

	print("Ghost added at:", ghost.global_position, "| Scale:", ghost_sprite.scale)

func _trigger_fast_audience_squash():
	var fg := get_tree().current_scene.get_node_or_null("ForegroundAudience")
	if fg and fg.has_method("trigger_crowd_squash_fast"):
		fg.trigger_crowd_squash_fast()
		await get_tree().create_timer(0.4).timeout
		fg.reset_crowd_speed()

#  Shotgun Powerup logic
func activate_shotgun_mode(duration: float):
	shotgun_mode = true
	print(" Shotgun mode activated for", duration, "seconds")

	if shotgun_timer:
		shotgun_timer.stop()
	else:
		shotgun_timer = Timer.new()
		shotgun_timer.one_shot = true
		shotgun_timer.timeout.connect(_on_shotgun_timeout)
		add_child(shotgun_timer)

	shotgun_timer.start(duration)

func _on_shotgun_timeout():
	shotgun_mode = false
	print("💤 Shotgun mode ended")
