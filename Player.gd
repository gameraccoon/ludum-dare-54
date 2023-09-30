extends Area2D

var target_pos = Vector2(0.0, 0.0)
var distance_from_start = 10.0

var approaching_threshold = 5.0

func _ready():
	target_pos = position
	hide()


func _process(delta):
	var pos_diff = (target_pos - position)
	var distance = pos_diff.length()
	
	if distance < approaching_threshold:
		return
	
	var velocity = pos_diff / distance
	
	rotation = velocity.angle()
	position += velocity * delta * 100


func move(from, to):
	var pos_diff = to - from
	if from.distance_to(position) > approaching_threshold or abs(from.angle_to_point(to) - position.angle_to_point(target_pos)) > 45:
		position = from + pos_diff.normalize() * distance_from_start
	target_pos = to


func start(pos):
	position = pos
	target_pos = position
	show()
