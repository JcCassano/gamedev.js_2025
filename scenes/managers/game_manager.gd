extends Node

@export var rage_multiplier := 5.0
@export var decrease_clean_rate := 2.0

var is_game_over := false
var rage_bar: Node = null
var clean_bar: Node = null
var pause_menu: Node = null
var game_over_menu: Node = null
var win_menu: Node = null
var is_gameplay_scene := false
var is_ready := false
var arena_game_over_menu: Node = null

func _ready():
	print("📍 GameManager ready")
	get_tree().connect("scene_changed", _on_scene_changed)
	print("🎬 GameManager is now monitoring scene changes.")
	_on_scene_changed(get_tree().current_scene)

func _input(event):
	if not is_ready or not is_gameplay_scene or is_game_over:
		return
	if event.is_action_pressed("pause_game") and pause_menu:
		if pause_menu.visible:
			print("🔄 ESC pressed again – resuming game")
			pause_menu.hide_menu()
		else:
			print("⏸️ ESC pressed – opening pause menu")
			pause_menu.show_menu()

func _on_scene_changed(new_scene: Node):
	is_ready = false
	is_game_over = false

	rage_bar = null
	clean_bar = null
	pause_menu = null
	game_over_menu = null
	arena_game_over_menu = null

	var scene_name := new_scene.name
	print("📦 Scene Changed To:", scene_name)

	is_gameplay_scene = scene_name.to_lower().begins_with("level_") or scene_name == "Arena"
	print("🧠 Is Gameplay Scene:", is_gameplay_scene)

	if not is_gameplay_scene:
		print("❌ Skipping GameManager setup: not in gameplay scene.")
		return

	var ui_root = new_scene.get_node_or_null("UIManager")
	print("🧩 UIManager found:", ui_root != null)

	if not ui_root:
		push_error("❗ UIManager not found in scene!")
		return

	rage_bar = ui_root.get_node_or_null("RageBar")
	print("🔥 RageBar found:", rage_bar != null)

	clean_bar = ui_root.get_node_or_null("CleanBar")
	print("🧼 CleanBar found:", clean_bar != null)

	pause_menu = ui_root.get_node_or_null("PauseMenu")
	print("⏸️ PauseMenu found:", pause_menu != null)

	game_over_menu = ui_root.get_node_or_null("GameOverMenu")
	print("💀 GameOverMenu found:", game_over_menu != null)

	win_menu = ui_root.get_node_or_null("WinMenu")
	print("🏁 WinMenu found:", win_menu != null)

	arena_game_over_menu = ui_root.get_node_or_null("ArenaGameOverMenu")
	print("🎯 ArenaGameOverMenu found:", arena_game_over_menu != null)

	if rage_bar:
		rage_bar.connect("rage_maxed_out", _on_rage_maxed)
		print("✅ Connected to RageBar signal")
	else:
		print("⚠️ RageBar missing")

	if clean_bar:
		clean_bar.connect("clean_depleted", _on_clean_depleted)
		print("✅ Connected to CleanBar signal")
	else:
		print("⚠️ CleanBar missing")

	is_ready = true
	print("✅ GameManager setup completed and ready.")

func _on_rage_maxed():
	if is_game_over: return
	is_game_over = true
	print("💢 Game Over: Rage Meter Maxed!")
	_show_game_over_menu()

func _on_clean_depleted():
	if is_game_over: return
	is_game_over = true
	print("🧽 Game Over: Cleanliness depleted!")
	_show_game_over_menu()

func win_game():
	if is_game_over: return
	is_game_over = true
	print("🎉 Player survived the shift! YOU WIN!")
	_show_win_menu()

func _show_game_over_menu():
	if get_tree().current_scene.name == "Arena" and arena_game_over_menu:
		print("🧾 Showing Arcade Game Over Screen")
		var arena_script = get_tree().current_scene
		var time_survived = 0.0
		if arena_script.has_method("get_survival_time"):
			time_survived = arena_script.get_survival_time()

		var rats_killed = GameStats.rats_killed
		var jockeys_killed = GameStats.jockeys_killed
		var points = GameStats.calculate_score(time_survived, rats_killed, jockeys_killed)

		print("🐀 Rats:", rats_killed, " | 🐓 Jockeys:", jockeys_killed, " | ⭐ Points:", points)
		arena_game_over_menu.show_arena_results(points, time_survived, rats_killed, jockeys_killed)

		# Reset for next run
		GameStats.reset()
	else:
		print("📛 Showing normal game over menu")
		if game_over_menu:
			game_over_menu.show_game_over()
		else:
			print("❌ game_over_menu is null!")


func _show_win_menu():
	if win_menu:
		print("🏆 Showing Win Menu")
		win_menu.show_win()
	else:
		print("❌ WinMenu not found!")

# ==== Public APIs ====

func apply_rage(amount: float) -> void:
	if not is_ready or is_game_over or not is_gameplay_scene: return
	if rage_bar:
		print("🔥 Applying Rage:", amount)
		rage_bar.increase_rage(amount * rage_multiplier)

func decrease_clean_over_time(delta: float) -> void:
	if not is_ready or is_game_over or not is_gameplay_scene: return
	if clean_bar:
		clean_bar.decrease_clean(decrease_clean_rate * delta)

func apply_mess_penalty(amount: float) -> void:
	if not is_ready or is_game_over or not is_gameplay_scene: return
	if clean_bar:
		print("🗑️ Clean penalty applied:", amount)
		clean_bar.decrease_clean(amount)

func increase_clean(amount: float) -> void:
	if not is_ready or is_game_over or not is_gameplay_scene: return
	if clean_bar:
		print("✨ Clean increased by:", amount)
		clean_bar.increase_clean(amount)

func reset_rage_and_clean():
	is_game_over = false
	await get_tree().process_frame
	await get_tree().process_frame
	_on_scene_changed(get_tree().current_scene)
	if rage_bar:
		rage_bar.set_rage(0)
	if clean_bar:
		clean_bar.set_clean(100)
