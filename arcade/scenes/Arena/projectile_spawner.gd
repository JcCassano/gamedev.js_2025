extends Node2D

@export var red_x_scene: PackedScene
@export var popcorn_projectile_scene: PackedScene
@export var drink_projectile_scene: PackedScene
@export var noodle_projectile_scene: PackedScene

@export var popcorn_chance := 70
@export var noodle_chance := 10

@export var spawn_interval: float = 1.0
@export var delay_before_throw: float = 0.5
@export var arena_bounds: Rect2 = Rect2(Vector2(32, 275), Vector2(550, 80))

@export var multi_projectile_increase_interval := 30.0
@export var max_projectiles_per_wave := 5
@export var rotation_range_degrees := 10.0

var projectiles_per_wave := 1
var wave_increase_timer := 0.0
var barrage_active := false

func _ready():
	$Timer.wait_time = spawn_interval
	$Timer.timeout.connect(_spawn_projectile_with_warning)
	$Timer.start()

func _process(delta):
	wave_increase_timer += delta
	if wave_increase_timer >= multi_projectile_increase_interval:
		wave_increase_timer = 0.0
		projectiles_per_wave += 1
		projectiles_per_wave = clamp(projectiles_per_wave, 1, max_projectiles_per_wave)

func _spawn_projectile_with_warning():
	for i in projectiles_per_wave:
		var target_pos = get_random_position()

		if red_x_scene:
			var red_x = red_x_scene.instantiate()
			red_x.global_position = target_pos
			add_child(red_x)

			await _safe_wait(delay_before_throw)

			var projectile_scene = _choose_projectile_scene()
			if projectile_scene:
				var projectile = projectile_scene.instantiate()

				if projectile_scene != noodle_projectile_scene:
					projectile.rotation_degrees = randf_range(-rotation_range_degrees, rotation_range_degrees)

				if projectile.has_method("launch"):
					var arg_count = projectile.get_script().get_method_argument_count("launch")
					if arg_count == 2:
						projectile.launch(target_pos - Vector2(0, 300), Vector2(0, 1))
					else:
						projectile.launch(target_pos - Vector2(0, 300))

				get_tree().current_scene.add_child(projectile)

			red_x.queue_free()

func _choose_projectile_scene() -> PackedScene:
	var roll := randi() % 100
	if roll < noodle_chance:
		return noodle_projectile_scene
	elif roll < popcorn_chance:
		return popcorn_projectile_scene
	else:
		return drink_projectile_scene

func get_random_position() -> Vector2:
	return Vector2(
		randf_range(arena_bounds.position.x, arena_bounds.end.x),
		randf_range(arena_bounds.position.y, arena_bounds.end.y)
	)

func start_chicken_jockey_barrage(duration: float) -> void:
	if barrage_active:
		print("Barrage already active — skipping")
		return

	barrage_active = true
	print("[BARRAGE START] at:", Time.get_ticks_msec() / 1000.0, "s")

	var original_pause_state = get_tree().paused
	get_tree().paused = false  # Force unpause

	var elapsed := 0.0
	while elapsed < duration:
		if !is_inside_tree():
			print("[BARRAGE INTERRUPTED] - Node removed")
			barrage_active = false
			return

		var target_pos = get_random_position()
		var projectile_scene = _choose_projectile_scene()

		if projectile_scene:
			var projectile = projectile_scene.instantiate()
			projectile.rotation_degrees = randf_range(-rotation_range_degrees, rotation_range_degrees)

			if projectile.has_method("launch"):
				var arg_count = projectile.get_script().get_method_argument_count("launch")
				if arg_count == 2:
					projectile.launch(target_pos - Vector2(0, 300), Vector2(0, 1))
				else:
					projectile.launch(target_pos - Vector2(0, 300))

			get_tree().current_scene.add_child(projectile)
			print("➡️ Barrage Projectile at:", target_pos)

		await _safe_wait(0.05)
		elapsed += 0.05

	get_tree().paused = original_pause_state  # ✅ Restore pause state
	barrage_active = false
	print("[BARRAGE END] at:", Time.get_ticks_msec() / 1000.0, "s")

# Custom timer immune to pause state
func _safe_wait(seconds: float) -> void:
	var t := Timer.new()
	t.one_shot = true
	t.wait_time = seconds
	t.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(t)
	t.start()
	await t.timeout
	t.queue_free()
