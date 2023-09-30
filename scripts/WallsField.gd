extends Node2D

enum Direction { West, East, North, South }

const KeyCodesToDirection = {
	KEY_LEFT: Direction.West,
	KEY_RIGHT: Direction.East,
	KEY_UP: Direction.North,
	KEY_DOWN: Direction.South
}

const DirectionToVector = {
	Direction.West: Vector2(-1, 0),
	Direction.East: Vector2(1, 0),
	Direction.North: Vector2(0, -1),
	Direction.South: Vector2(0, 1),
}

const WALL_SIZE = 40

var walls_points = []
var start_point = Vector2(0, 0)


func destroy_walls():
	var walls_points_len = len(walls_points)
	if walls_points_len > 2:
		walls_points = walls_points.slice(walls_points_len - 2, walls_points_len)
	update()

func _ready():
	walls_points.append(start_point)

func _input(event):
	if event is InputEventKey and not event.is_pressed():
		var dir = KeyCodesToDirection[event.get_scancode()]
		if dir != null:
			move_by_dir(dir)

func move_by_dir(direction):
	var offset = DirectionToVector[direction]
	if offset != null:
		walls_points.append(walls_points[-1] + offset)
		update()

func _draw() -> void:
	# DEBUG DRAWING
	var GRID_SIZE = 12
	for i in range(GRID_SIZE):
		draw_line(Vector2(0, i * WALL_SIZE), Vector2(GRID_SIZE * WALL_SIZE, i * WALL_SIZE), Color.aliceblue, 0.5)
	for i in range(GRID_SIZE):
		draw_line(Vector2(i * WALL_SIZE, 0), Vector2(i * WALL_SIZE, GRID_SIZE * WALL_SIZE), Color.aliceblue, 0.5)
	
	if len(walls_points) > 1:
		for i in range(1, len(walls_points)):
			draw_line(walls_points[i - 1] * WALL_SIZE, walls_points[i] * WALL_SIZE, Color.red, 2.0)	

