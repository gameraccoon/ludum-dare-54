extends Sprite

var is_completed = false

var coordinates = Vector2()

signal on_destroyed(pos)

func set_wall_type(is_vertical: bool):
	if is_vertical:
		region_rect.size.x = Consts.WallWidth
		region_rect.size.y = Consts.WallLength
		$Area2D.rotate(PI * 0.5)
	else:
		region_rect.size.x = Consts.WallLength
		region_rect.size.y = Consts.WallWidth


func _on_Area2D_body_entered(body):
	if is_completed:
		# kill the enemy
		body.queue_free()
	else:
		emit_signal("on_destroyed", coordinates)
