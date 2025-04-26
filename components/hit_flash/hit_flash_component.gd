extends Node

@export var target_node_name: String = "Sprite2D"
@export var flash_duration := 0.1

@onready var flash_overlay := $CanvasLayer/ColorRect
@onready var shader_node := $ShaderNode

var sprite_node: CanvasItem

func _ready():
	sprite_node = get_parent().get_node_or_null(target_node_name)

	if not sprite_node:
		push_error(" Could not find sprite_node: " + target_node_name)
		return

	if not (sprite_node is CanvasItem):
		push_error(" Target node is not a CanvasItem")
		return

	print(" HitFlash target set to:", sprite_node.name)

	if shader_node and shader_node.flash_material:
		var unique_material = shader_node.flash_material.duplicate()
		sprite_node.material = unique_material
		shader_node.flash_material = unique_material
		print(" Unique shader material applied to:", sprite_node.name)
	else:
		print(" No shader material found!")

	if shader_node and shader_node.flash_material:
		shader_node.flash_material.set_shader_parameter("flash_strength", 0.0)


func flash():
	if not sprite_node:
		print("⚠️ No sprite to flash")
		return

	if not shader_node or not shader_node.flash_material:
		print(" Missing shader or flash material")
		return

	var mat = shader_node.flash_material
	if mat is ShaderMaterial:
		var tween = create_tween()
		tween.tween_property(mat, "shader_parameter/flash_strength", 1.0, 0.05)
		tween.tween_property(mat, "shader_parameter/flash_strength", 0.0, flash_duration)
