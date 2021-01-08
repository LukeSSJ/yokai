extends "res://tool/Tool.gd"

func start(pos):
	image_draw_start()
	image_grab_color(pos)
	image_draw_end()
