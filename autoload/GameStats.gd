extends Node

var rats_killed := 0
var jockeys_killed := 0

func reset():
	rats_killed = 0
	jockeys_killed = 0

func add_rat_kill():
	rats_killed += 1

func add_jockey_kill():
	jockeys_killed += 1

func calculate_score(survival_time: float, rat_kills: int, jockey_kills: int) -> int:
	var time_score = survival_time * 2
	var rat_score = rat_kills * 10
	var jockey_score = jockey_kills * 25  # adjust multiplier as needed
	return int(time_score + rat_score + jockey_score)
