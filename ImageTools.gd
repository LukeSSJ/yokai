extends Node

func blank_image(image : Image, size : Vector2) -> void:
	image.create(int(size.x), int(size.y), false, Image.FORMAT_RGBA8)

func get_texture(image : Image) -> ImageTexture:
	var tex := ImageTexture.new()
	tex.create(image.get_width(), image.get_height(), Image.FORMAT_RGBA8, 0)
	tex.set_data(image)
	return tex
