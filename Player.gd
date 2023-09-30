extends Area2D

var target_pos = Vector2(0.0, 0.0)
var distance_from_start = 25.0
var speed = 0.0

var approaching_threshold = 2.0

func _ready():
	randomize()
	target_pos = position
	hide()


func _process(delta):
	var pos_diff = (target_pos - position)
	var distance = pos_diff.length()
	
	if distance < approaching_threshold:
		position = target_pos
		return
	
	var velocity = pos_diff / distance
	
	rotation = velocity.angle()
	position += velocity * delta * speed


func move(from, to, time):
	var pos_diff = to - from
	if from.distance_to(position) > approaching_threshold or abs(from.angle_to_point(to) - position.angle_to_point(target_pos)) > PI*0.4:
		position = from + pos_diff.normalized() * distance_from_start
	target_pos = to
	
	speed = position.distance_to(target_pos) / time
	approaching_threshold = speed / 60.0


func start(pos):
	position = pos
	target_pos = position
	show()
