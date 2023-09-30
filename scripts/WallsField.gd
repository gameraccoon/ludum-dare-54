extends Node2D

export(PackedScene) var mob_scene

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

var wall_prefub = preload("res://scenes/Wall.tscn")

func destroy_walls():
	var walls_points_len = len(walls_points)
	if walls_points_len > 2:
		walls_points = walls_points.slice(walls_points_len - 2, walls_points_len)

func _ready():
	walls_points.append(start_point)
	var mob = mob_scene.instance()
	mob.position = Vector2(100, 100)
	mob.linear_velocity = Vector2(100, 0)
	$Enemies.add_child(mob)

func _input(event):
	if event is InputEventKey and not event.is_pressed() and KeyCodesToDirection.has(event.get_scancode()):
		move_by_dir(KeyCodesToDirection[event.get_scancode()])

func move_by_dir(dir):
	var offset = DirectionToVector[dir]
	if offset != null:
		walls_points.append(walls_points[-1] + offset)
		_spawn_new_wall()
		$Player.move(player_cell_position * Consts.WallLength, (player_cell_position + offset) * Consts.WallLength, 0.2)
		player_cell_position += offset

func _should_change_player_pos(dir) -> bool:
	var player_cell_points = _calc_walls_points_to_cell(player_cell_position)
	return player_cell_points.find(walls_points[-1]) == -1

func _calc_walls_points_to_cell(cell_pos: Vector2):
	var res = [Vector2(0, 1), Vector2(0, 0), Vector2(1, 0), Vector2(1, 1)]
	for i in len(res):
		res[i] += cell_pos
	return res

func _wall_point_to_world(wall_point: Vector2) -> Vector2:
	return wall_point * Consts.WallLength

func _on_wall_destroyed(pos):
	print("wall destroyed", pos)
	destroy_walls()

func _spawn_new_wall():
	if len(walls_points) > 1:
		var last_wall_point = walls_points[-1]
		var pre_last_wall_point = walls_points[-2]
		var is_vertical = last_wall_point.y != pre_last_wall_point.y
		var wall_node_pos = (_wall_point_to_world(last_wall_point) + _wall_point_to_world(pre_last_wall_point)) / 2
		var new_wall = wall_prefub.instance()
		new_wall.set_wall_type(is_vertical)
		new_wall.coordinates = last_wall_point
		new_wall.connect("on_destroyed", self, "_on_wall_destroyed")
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
		draw_line(Vector2(0, i * Consts.WallLength), Vector2(GRID_SIZE * Consts.WallLength, i * Consts.WallLength), Color.aliceblue, 0.5)
	for i in range(GRID_SIZE):
		draw_line(Vector2(i * Consts.WallLength, 0), Vector2(i * Consts.WallLength, GRID_SIZE * Consts.WallLength), Color.aliceblue, 0.5)

