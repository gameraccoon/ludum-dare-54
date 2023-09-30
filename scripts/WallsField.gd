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
var player_cell_position = Vector2(0, 0)

func destroy_walls():
	var walls_points_len = len(walls_points)
	if walls_points_len > 2:
		walls_points = walls_points.slice(walls_points_len - 2, walls_points_len)
	update()

func _ready():
	walls_points.append(start_point)

func _input(event):
	if event is InputEventKey and not event.is_pressed() and KeyCodesToDirection.has(event.get_scancode()):
		move_by_dir(KeyCodesToDirection[event.get_scancode()])

func move_by_dir(dir):
	var offset = DirectionToVector[dir]
	if offset != null:
		walls_points.append(walls_points[-1] + offset)
		#if _should_change_player_pos(dir):
		player_cell_position += offset
		$Player.move($Player.position, player_cell_position * WALL_SIZE, 0.4)
		update()

func _should_change_player_pos(dir) -> bool:
	var player_cell_points = _calc_walls_points_to_cell(player_cell_position)
	return player_cell_points.find(walls_points[-1]) == -1

func _calc_walls_points_to_cell(cell_pos: Vector2):
	var res = [Vector2(0, 1), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1)]
	for i in len(res):
		res[i] += cell_pos
	return res

func _wall_point_to_world(wall_point: Vector2) -> Vector2:
	return wall_point * WALL_SIZE

#
# DEBUG DRAWING FUNCTIONS
#

func _draw() -> void:
	_draw_grid()
	_draw_walls()

func _draw_grid():
	var GRID_SIZE = 12
	for i in range(GRID_SIZE):
		draw_line(Vector2(0, i * WALL_SIZE), Vector2(GRID_SIZE * WALL_SIZE, i * WALL_SIZE), Color.aliceblue, 0.5)
	for i in range(GRID_SIZE):
		draw_line(Vector2(i * WALL_SIZE, 0), Vector2(i * WALL_SIZE, GRID_SIZE * WALL_SIZE), Color.aliceblue, 0.5)

func _draw_walls():
	if len(walls_points) > 1:
		for i in range(1, len(walls_points)):
			draw_line(
				_wall_point_to_world(walls_points[i - 1]), 
				_wall_point_to_world(walls_points[i]), 
				Color.red, 2.0)

