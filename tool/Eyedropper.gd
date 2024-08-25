extends "res://tool/Tool.gd"

func start(pos) -> void:
	image_draw_start()
	change_made = false
	image_grab_color(pos)
	image_draw_end()
