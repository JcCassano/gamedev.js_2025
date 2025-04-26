extends Node

@export var target_node: NodePath
@export var float_time := 0.5
@export var font_size := 15
@export var font_color := Color.WHITE
@export var prefix := ""  # e.g., "-" for damage, "+" for healing

func show_damage(amount: int):
	var target = get_node_or_null(target_node)
	if not target:
		push_error(" FloatingDamageComponent: target_node not found!")
		return

	var damage_label := Label.new()
	damage_label.text = prefix + str(amount)
	damage_label.z_index = 99

	var settings := LabelSettings.new()
	settings.font_size = font_size
	damage_label.label_settings = settings
	damage_label.add_theme_color_override("font_color", font_color)

	damage_label.global_position = target.global_position + Vector2(0, -20)
	get_tree().current_scene.add_child(damage_label)

	var tween := damage_label.create_tween()
	tween.tween_property(damage_label, "global_position", damage_label.global_position + Vector2(0, -30), float_time)
	tween.tween_callback(Callable(damage_label, "queue_free"))

	print(" Floating damage label created at:", damage_label.global_position)
