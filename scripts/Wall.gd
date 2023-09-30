extends Sprite

func set_wall_type(is_vertical: bool):
	if is_vertical:
		region_rect.size.x = Consts.WallWidth
		region_rect.size.y = Consts.WallLength
	else:
		region_rect.size.x = Consts.WallLength
		region_rect.size.y = Consts.WallWidth
