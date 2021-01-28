extends Node

func blank_image(image : Image, size : Vector2) -> void:
	image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)

func get_texture(image : Image) -> ImageTexture:
	var tex := ImageTexture.new()
	tex.create(image.get_width(), image.get_height(), Image.FORMAT_RGBA8, 0)
	tex.set_data(image)
	return tex

func image_rotate(image: Image, clockwise):
	var image_size = image.get_size()
	var image_copy : Image = image.duplicate()
	blank_image(image, Vector2(image_size.y, image_size.x))
	image.lock()
	image_copy.lock()
	for x in image_size.x:
		for y in image_size.y:
			var color = image_copy.get_pixel(x, y)
			if clockwise:
				image.set_pixel(image_size.y - 1 - y, x, color)
			else:
				image.set_pixel(y, image_size.x - 1 - x, color)
	image.unlock()
	image_copy.unlock()

func image_flip(image : Image, horizontal : bool):
	var image_size := image.get_size()
	var image_copy : Image = image.duplicate()
	image.lock()
	image_copy.lock()
	for x in image_size.x:
		for y in image_size.y:
			var color = image_copy.get_pixel(x, y)
			if horizontal:
				image.set_pixel(image_size.y - 1 - x, y, color)
			else:
				image.set_pixel(x, image_size.y - 1 - y, color)
	image.unlock()
	image_copy.unlock()
