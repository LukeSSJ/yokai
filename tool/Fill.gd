extends "res://tool/Tool.gd"

func start(pos: Vector2) -> void:
	image_draw_start()
	if control_pressed:
		image_fill_global(pos, draw_color)
	else:
		image_fill(pos, draw_color)
	image_draw_end()
