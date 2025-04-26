extends Node
class_name SquashStretch

@export var default_duration := 0.3
@export var fast_duration := 0.1
@export var squash_scale := Vector2(1.2, 0.8)
@export var stretch_scale := Vector2(0.8, 1.2)
@export var rest_scale := Vector2(1, 1)

@export var bounce_loop := true
@export var bounce_delay := 0.0
@export var random_start_delay_range := Vector2(0.0, 0.3)
@export var random_duration_variation := Vector2(-0.05, 0.05)
@export var random_jitter_between_bounces := Vector2(0.0, 0.2)

var duration := default_duration
var tween: Tween
var is_looping := false

func _ready():
	get_parent().scale = rest_scale

	if bounce_loop:
		var random_delay = randf_range(random_start_delay_range.x, random_start_delay_range.y)
		await get_tree().create_timer(random_delay).timeout

		is_looping = true
		loop_bounce_async()

func loop_bounce_async() -> void:
	while is_looping:
		await bounce_once()
		var jitter = randf_range(random_jitter_between_bounces.x, random_jitter_between_bounces.y)
		await get_tree().create_timer(jitter).timeout

func bounce_once() -> Signal:
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	var bounce_duration: float = clamp(duration, 0.05, 1.0)

	tween.tween_property(get_parent(), "scale", squash_scale, bounce_duration)
	tween.tween_property(get_parent(), "scale", stretch_scale, bounce_duration)
	tween.tween_property(get_parent(), "scale", rest_scale, bounce_duration)

	return tween.finished

func set_bounce_speed(new_duration: float):
	duration = new_duration
