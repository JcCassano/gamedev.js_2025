extends Node2D

func _ready():
	$CleanupTimer.timeout.connect(queue_free)
