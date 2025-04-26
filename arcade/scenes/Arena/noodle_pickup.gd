extends Node2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collider: CollisionShape2D = $CollisionShape2D

@export var float_range: float = 4.0
@export var float_duration: float = 0.5
@export var flash_interval: float = 0.3
@export var lifetime: float = 5.0  # Despawn after 5 seconds

var already_collected := false
var flash_timer := 0.0
var total_time := 0.0
var flash_on := false

func _ready():
	print("Noodle spawned at:", global_position)
	_start_floating()

func _start_floating():
	var original_y = global_position.y
	var tween = create_tween().set_loops()
	tween.tween_property(self, "global_position:y", original_y - float_range, float_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "global_position:y", original_y + float_range, float_duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _physics_process(delta):
	if already_collected:
		return

	# Flash white every `flash_interval`
	flash_timer += delta
	total_time += delta
	if flash_timer >= flash_interval:
		flash_timer = 0.0
		flash_on = not flash_on
		sprite.modulate = Color(1, 1, 1) if flash_on else Color(1, 1, 1, 0.8)  # alternate white and slightly transparent

	# Auto-despawn
	if total_time >= lifetime:
		print("Noodle despawned.")
		queue_free()

	# Overlap check
	var space_state = get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = collider.shape
	query.transform = global_transform
	query.collide_with_areas = false
	query.collide_with_bodies = true

	var results = space_state.intersect_shape(query)
	for result in results:
		var body = result.get("collider")
		if body and body.is_in_group("player") and body.has_method("add_health"):
			already_collected = true
			body.add_health(1)
			_show_floating_label(body)
			queue_free()
			break

func _show_floating_label(player: Node):
	if player.has_node("FloatingDamageComponent"):
		var float_comp = player.get_node("FloatingDamageComponent")
		float_comp.prefix = "+"
		float_comp.font_color = Color.LIME_GREEN
		float_comp.show_damage(1)
