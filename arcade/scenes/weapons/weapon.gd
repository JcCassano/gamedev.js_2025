extends Node2D

@export var fire_cooldown := 0.2  # Base cooldown (may be overridden in shotgun mode)
@export var fire_sfx: AudioStream

var bullet_path = preload("res://arcade/scenes/projectiles/projectile_base.tscn")
@onready var muzzle := $Muzzle
@onready var sfx_player := $AudioStreamPlayer2D

var fire_timer := 0.0

func _ready():
	sfx_player.bus = "SFX"

func _physics_process(delta):
	look_at(get_global_mouse_position())

	var dir = get_global_mouse_position().x - global_position.x
	scale.y = -1 if dir < 0 else 1

	fire_timer -= delta
	if Input.is_action_pressed("shoot") and fire_timer <= 0:
		fire()
		
		# Use player's cooldown if available
		var arcade_player := get_parent() as CharacterBody2D
		if arcade_player and arcade_player.shotgun_mode:
			fire_timer = arcade_player.shotgun_fire_rate
		else:
			fire_timer = arcade_player.normal_fire_rate if arcade_player else fire_cooldown


func fire():
	var arcade_player := get_parent() as CharacterBody2D
	var use_shotgun: bool = arcade_player and arcade_player.shotgun_mode

	var bullet_count = 3 if use_shotgun else 1
	var spread_angle = arcade_player.shotgun_spread if use_shotgun else arcade_player.normal_spread

	for i in bullet_count:
		var bullet = bullet_path.instantiate()
		var spread = deg_to_rad(randf_range(-spread_angle * 0.5, spread_angle * 0.5))
		var final_rotation = global_rotation + spread

		bullet.dir = final_rotation
		bullet.pos = muzzle.global_position
		bullet.rota = final_rotation
		get_parent().add_child(bullet)

	if fire_sfx and sfx_player:
		sfx_player.stream = fire_sfx
		sfx_player.pitch_scale = randf_range(0.95, 1.1)
		sfx_player.play()
