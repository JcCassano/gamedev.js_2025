extends Node2D

@export var arena_ui_scene: PackedScene
@onready var spawn_point := $PlayerSpawn

var survival_time := 0.0
var timer_label: Label = null
var unpaused_timer: Timer
var arena_game_over_menu: Node = null

func _ready():
	_spawn_arena_ui()


	# Timer that ticks even when game is paused
	unpaused_timer = Timer.new()
	unpaused_timer.wait_time = 1.0
	unpaused_timer.one_shot = false
	unpaused_timer.timeout.connect(_on_timer_tick)
	unpaused_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(unpaused_timer)
	unpaused_timer.start()

func _spawn_arena_ui():
	if not arena_ui_scene:
		push_error("Arena UI scene not assigned!")
		return

	var ui_instance = arena_ui_scene.instantiate()
	ui_instance.name = "ArenaUI"
	add_child(ui_instance)
	print("ArenaUI instantiated at scene root")

	timer_label = ui_instance.get_node_or_null("SurvivalTimerLabel")
	if timer_label:
		print("Timer label linked")
	else:
		print("SurvivalTimerLabel not found!")

	arena_game_over_menu = ui_instance.get_node_or_null("ArenaGameOverMenu")
	if arena_game_over_menu:
		arena_game_over_menu.visible = false
	else:
		print("⚠️ ArenaGameOverMenu not found!")

func _on_timer_tick():
	if not get_tree().paused:
		survival_time += 1.0
		if timer_label:
			var minutes := int(survival_time) / 60
			var seconds := int(survival_time) % 60
			timer_label.text = "Time: %02d:%02d" % [minutes, seconds]

func get_survival_time() -> float:
	return survival_time
