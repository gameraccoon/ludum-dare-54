extends Area2D

var target_pos = Vector2(0.0, 0.0)

func _ready():
	target_pos = position
	hide()


func _process(delta):
	var pos_diff = (target_pos - position)
	var distance = pos_diff.length()
	
	if distance < 0.1:
		return
	
	var velocity = pos_diff / distance
	
	rotation = velocity.angle()
	position += velocity * delta * 100


func start(pos):
	position = pos
	target_pos = position
	show()
