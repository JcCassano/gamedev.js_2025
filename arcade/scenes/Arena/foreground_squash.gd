extends Sprite2D

@export var squash_scale := Vector2(1.2, 0.8)
@export var stretch_scale := Vector2(0.8, 1.2)
@export var rest_scale := Vector2(1, 1)

@export var bounce_duration := 0.5
@export var fast_bounce_duration := 0.1

@export var loop := true
@export var random_start_delay_range := Vector2(0.1, 0.8)  # Greater randomness at start
@export var random_loop_jitter := Vector2(0.1, 0.4)        # Pause between bounces

var current_duration := 0.5
var tween: Tween
var is_looping := false


func _ready():
	current_duration = bounce_duration
	scale = rest_scale

	if loop:
		var delay = randf_range(random_start_delay_range.x, random_start_delay_range.y)
		await get_tree().create_timer(delay).timeout
		is_looping = true
		_loop_squash()


func _loop_squash() -> void:
	while is_looping:
		await _play_squash()
		var pause = randf_range(random_loop_jitter.x, random_loop_jitter.y)
		await get_tree().create_timer(pause).timeout


func _play_squash() -> Signal:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(self, "scale", squash_scale, current_duration)
	tween.tween_property(self, "scale", stretch_scale, current_duration)
	tween.tween_property(self, "scale", rest_scale, current_duration)
	return tween.finished


func set_squash_speed(fast: bool):
	current_duration = fast_bounce_duration if fast else bounce_duration
	print("⚡ ForegroundSquash: speed set to", current_duration)

	# Optional: restart squash immediately for visual clarity
	if tween:
		tween.kill()
	_play_squash()
