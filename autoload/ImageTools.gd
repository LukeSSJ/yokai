extends Node

func blank_image(size : Vector2) -> Image:
	return Image.create_empty(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)


func get_texture(image : Image) -> ImageTexture:
	return ImageTexture.create_from_image(image)


func image_rotate(image: Image, clockwise: bool) -> Image:
	var image_size = image.get_size()
	var image_copy : Image = image.duplicate()
	
	image = blank_image(Vector2(image_size.y, image_size.x))
	
	for x in image_size.x:
		for y in image_size.y:
			var color = image_copy.get_pixel(x, y)
			if clockwise:
				image.set_pixel(image_size.y - 1 - y, x, color)
			else:
				image.set_pixel(y, image_size.x - 1 - x, color)
	
	return image


func image_flood_fill(image: Image, pos: Vector2, color_replace: Color) -> bool:
	var color_find = image.get_pixelv(pos)
	if colors_match(color_find, color_replace):
		return false
	
	var image_size := image.get_size()
	var fill_positions := [pos]
	
	while len(fill_positions) > 0:
		var current_pos = fill_positions.pop_back()
		Global.canvas.image.set_pixelv(current_pos, color_replace)
		
		if current_pos.x > 0 and colors_match(image.get_pixel(current_pos.x - 1, current_pos.y), color_find):
			fill_positions.push_back(Vector2(current_pos.x - 1, current_pos.y))
		
		if current_pos.x < image_size.x - 1 and colors_match(image.get_pixel(current_pos.x + 1, current_pos.y), color_find):
			fill_positions.push_back(Vector2(current_pos.x + 1, current_pos.y))
		
		if current_pos.y > 0 and colors_match(image.get_pixel(current_pos.x, current_pos.y - 1), color_find):
			fill_positions.push_back(Vector2(current_pos.x, current_pos.y - 1))
		
		if current_pos.y < image_size.y - 1 and colors_match(image.get_pixel(current_pos.x, current_pos.y + 1), color_find):
			fill_positions.push_back(Vector2(current_pos.x, current_pos.y + 1))
	
	return true

func colors_match(color_1: Color, color_2: Color) -> bool:
	return color_1 == color_2 or (color_1.a8 == 0 and color_2.a8 == 0)
