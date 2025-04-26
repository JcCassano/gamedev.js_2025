extends Node

func _ready():
	print("🧪 %s loaded." % get_tree().current_scene.name)

	# Let GameManager finish _on_scene_changed first
	await get_tree().process_frame

	if GameManager:
		GameManager.reset_rage_and_clean()
