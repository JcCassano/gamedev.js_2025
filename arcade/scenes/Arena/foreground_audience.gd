extends Node2D

@export var player: Node2D

func _ready():
	if player == null:
		player = get_tree().get_first_node_in_group("player")

func _process(_delta):
	if player:
		position.x = -player.global_position.x * 0.05  # parallax

func trigger_crowd_squash_fast():
	print("ForegroundAudience: speeding up squash")
	for audience in get_children():
		var squasher := audience.get_node_or_null("ForegroundSquash")
		if squasher:
			squasher.set_squash_speed(true)

func reset_crowd_speed():
	print("ForegroundAudience: reset squash speed")
	for audience in get_children():
		var squasher := audience.get_node_or_null("ForegroundSquash")
		if squasher:
			squasher.set_squash_speed(false)
