extends CanvasLayer

var fade_rect: ColorRect
var is_fading := false
var next_scene_path := ""  # <- Temp variable to store path

func _ready():
	await get_tree().process_frame  #  Let the scene fully initialize

	fade_rect = $FadeRect
	fade_rect.color = Color.BLACK
	fade_rect.modulate.a = 0.0
	fade_rect.visible = true
	fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func transition_to_scene(scene_path: String):
	if is_fading:
		return

	is_fading = true
	next_scene_path = scene_path

	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
	tween.tween_callback(Callable(self, "_on_fade_out_complete"))

func _on_fade_out_complete():
	get_tree().change_scene_to_file(next_scene_path)

	await get_tree().process_frame  #  Wait for scene change
	await get_tree().process_frame  #  Wait one more frame (important!)

	if GameManager and get_tree().current_scene:
		GameManager._on_scene_changed(get_tree().current_scene)

	fade_in()



func fade_in():
	fade_rect.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.5)
	tween.tween_callback(Callable(self, "_on_fade_in_complete"))

func _on_fade_in_complete():
	is_fading = false
