extends Node2D

@onready var bar_fill := $BarBackground/BarFill

func update_health(current: int, max: int):
	if max <= 0:
		bar_fill.size.x = 0
		return
	var ratio = clamp(float(current) / float(max), 0.0, 1.0)
	bar_fill.size.x = 20 * ratio  # Inside 22px background with 1px margin
