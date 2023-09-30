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


var walls_points = []
var start_point = Vector2(0, 0)
var player_cell_position = Vector2(0, 0)
var walls = []
var selected_cells = {}

var wall_prefub = preload("res://scenes/Wall.tscn")

func destroy_walls():
	var walls_points_len = len(walls_points)
	if walls_points_len > 2:
		walls_points = walls_points.slice(walls_points_len - 2, walls_points_len)

func _ready():
	walls_points.append(start_point)

func _input(event):
	if event is InputEventKey and not event.is_pressed() and KeyCodesToDirection.has(event.get_scancode()):
		move_by_dir(KeyCodesToDirection[event.get_scancode()])

func move_by_dir(dir):
	var offset = DirectionToVector[dir]
	if offset != null:
		walls_points.append(walls_points[-1] + offset)
		_spawn_new_wall()
		$Player.move(
			player_cell_position * Consts.WallLength, 
			(player_cell_position + offset) * Consts.WallLength, 0.2)
		player_cell_position += offset
	_check_interaction()

func _check_interaction():
	var index = walls_points.find(walls_points[-1])
	if index != len(walls_points) - 1:
		var closed_area_walls_points = walls_points.slice(index, len(walls_points))
		var horizontal_walls = {}
		var vertical_walls = {}
		for i in range(1, len(closed_area_walls_points)):
			var wp1 = closed_area_walls_points[i]
			var wp2 = closed_area_walls_points[i - 1]
			if wp1.y == wp2.y:
				var column = min(wp1.x, wp2.x)
				var row = wp1.y
				if horizontal_walls.has(column):
					horizontal_walls[column][row] = true
				else:
					horizontal_walls[column] = {row: true, }
			else:
				var row = wp1.x
				var column = max(wp1.y, wp2.y)
				if vertical_walls.has(column):
					vertical_walls[column][row] = true
				else:
					vertical_walls[column] = {row: true, }
		
		var first_wpoint = closed_area_walls_points[0]
		var cells = _calc_cells_to_wpoint(first_wpoint)
		for i in len(cells):
			var c_point = cells[i]
			if _is_cpoint_inside(c_point, horizontal_walls):
				_fullfill_cell(c_point, selected_cells, horizontal_walls, vertical_walls)
				update()
				

func _should_change_player_pos(dir) -> bool:
	var player_cell_points = _calc_walls_points_to_cell(player_cell_position)
	return player_cell_points.find(walls_points[-1]) == -1

func _calc_walls_points_to_cell(cell_pos: Vector2):
	var res = [Vector2(0, 1), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1)]
	for i in len(res):
		res[i] += cell_pos
	return res

func _calc_cells_to_wpoint(wall_point: Vector2):
	var res = [Vector2(0, 1), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1)]
	for i in len(res):
		res[i] = wall_point - res[i]
	return res

func _is_cpoint_inside(cell_point, horizontal_walls):
	var ray_collide_counter = 0
	if horizontal_walls.has(cell_point.x):
		var column: Dictionary = horizontal_walls[cell_point.x]
		var values = column.keys()
		for i in len(values):
			var row = values[i]
			if row <= cell_point.y:
				ray_collide_counter += 1
	return ray_collide_counter % 2 == 1

func _fullfill_cell(cell_point, selected, horizontal, vertical):
	cell_point.x *= 1.0
	
	if selected.has(cell_point.x):
		if selected[cell_point.x].has(cell_point.y):
			return
		else:
			selected[cell_point.x][cell_point.y] = true
	else:
		selected[cell_point.x] = {}
	
	var go_south = cell_point.y <= 20
	var go_north = cell_point.y - 1 >= 0
	if horizontal.has(cell_point.x):
		var column = horizontal[cell_point.x].keys()
		for i in len(column):
			var row = column[i]
			if go_north and cell_point.y == row:
				go_north = false
			elif go_south and cell_point.y + 1 == row:
				go_south = false
	
	var go_west = cell_point.x >= 0
	var go_east = cell_point.x <= 20
	if vertical.has(cell_point.y):
		var row = vertical[cell_point.y].keys()
		for i in len(row):
			var col = row[i]
			if go_west and cell_point.x == col:
				go_west = false
			elif go_east and cell_point.x + 1 == col:
				go_east = false
	
	if go_north:
		_fullfill_cell(cell_point + Vector2(0, -1), selected, horizontal, vertical)
	if go_south:
		_fullfill_cell(cell_point + Vector2(0, 1), selected, horizontal, vertical)
	if go_west:
		_fullfill_cell(cell_point + Vector2(-1, 0), selected, horizontal, vertical)
	if go_east:
		_fullfill_cell(cell_point + Vector2(1, 0), selected, horizontal, vertical)
	

func _wall_point_to_world(wall_point: Vector2) -> Vector2:
	return wall_point * Consts.WallLength

func _spawn_new_wall():
	if len(walls_points) > 1:
		var last_wall_point = walls_points[-1]
		var pre_last_wall_point = walls_points[-2]
		var is_vertical = last_wall_point.y != pre_last_wall_point.y
		var wall_node_pos = (_wall_point_to_world(last_wall_point) + _wall_point_to_world(pre_last_wall_point)) / 2
		var new_wall = wall_prefub.instance()
		new_wall.set_wall_type(is_vertical)
		new_wall.position = wall_node_pos
		add_child(new_wall)
		walls.append(new_wall)

#
# DEBUG DRAWING FUNCTIONS
#

func _draw() -> void:
	_draw_grid()

func _draw_grid():
	var GRID_SIZE = 12
	for i in range(GRID_SIZE):
		draw_line(
			Vector2(0, i * Consts.WallLength), 
			Vector2(GRID_SIZE * Consts.WallLength, i * Consts.WallLength), 
			Color.aliceblue, 0.5)
	for i in range(GRID_SIZE):
		draw_line(
			Vector2(i * Consts.WallLength, 0), 
			Vector2(i * Consts.WallLength, GRID_SIZE * Consts.WallLength), 
			Color.aliceblue, 0.5)
	
	var rect = Rect2(Vector2(), Vector2(Consts.CellSize, Consts.CellSize))
	for i in selected_cells.keys():
		for j in len(selected_cells[i]):
			rect.position = Vector2(i, j) * Consts.CellSize
			draw_rect(rect, Color.red)
