extends Node

var game_started = false
var current_level = 1
var current_time = 0.0
var current_score = 0

var score_needed = 1000
var time_for_the_level = 100.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func reset():
	game_started = false
	current_level = 1
	current_time = 0


func is_game_started():
	return game_started


func start_game():
	game_started = true


func finish_game():
	game_started = false
	current_time = 0
	if current_score > score_needed:
		current_level += 1
		current_score = 0

func process(delta):
	if is_game_started():
		current_time += delta
		if current_time >= time_for_the_level:
			finish_game()
			return false
	return true


func get_time_left():
	return time_for_the_level - current_time
