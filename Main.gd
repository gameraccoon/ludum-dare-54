extends Node

export(PackedScene) var mob_scene


func _ready():
	randomize()


func game_over():
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_game_over()
	$Music.stop()
	#$DeathSound.play()


func new_game():
	get_tree().call_group("mobs", "queue_free")
	$Player.start($StartPosition.position)
	$StartTimer.start()
	$HUD.update_score(floor(GameRules.get_time_left()))
	$HUD.show_message("Get Ready")
	#$Music.play()
	GameRules.reset()
	


func _on_MobTimer_timeout():
	# Create a new instance of the Mob scene.
	var mob = mob_scene.instance()

	# Choose a random location on Path2D.
	var mob_spawn_location1 = get_node("MobPath1/MobSpawnLocation1")
	var mob_spawn_location2 = get_node("MobPath2/MobSpawnLocation2")
	
	var mob_spawn_location = mob_spawn_location1 if randi() % 2 == 0 else mob_spawn_location2
	
	mob_spawn_location.offset = randi()

	# Set the mob's direction perpendicular to the path direction.
	var direction = mob_spawn_location.rotation + PI / 2

	# Set the mob's position to a random location.
	mob.position = mob_spawn_location.position

	# Add some randomness to the direction.
	#direction += rand_range(-PI / 4, PI / 4)
	mob.rotation = direction

	# Choose the velocity for the mob.
	var velocity = Vector2(rand_range(100.0, 150.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)

	# Spawn the mob by adding it to the Main scene.
	add_child(mob)


func _on_ScoreTimer_timeout():
	$HUD.update_score(floor(GameRules.get_time_left()))

func _process(delta):
	var should_continue = GameRules.process(delta)
	if should_continue == false:
		game_over()
	
	if $Player.position.distance_squared_to($Player.target_pos) < $Player.approaching_threshold * $Player.approaching_threshold:
		var move_dir = randi() % 4
		var move_x = 1 if move_dir == 0 else (-1 if move_dir == 1 else 0)
		var move_y = 1 if move_dir == 2 else (-1 if move_dir == 3 else 0)
		$Player.move($Player.position, $Player.position + Vector2(150.0 * move_x, 150.0 * move_y), 0.7)


func _on_StartTimer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
	GameRules.start_game()
