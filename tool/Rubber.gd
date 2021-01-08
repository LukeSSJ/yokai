extends "res://tool/Tool.gd"

func start(_pos):
	draw_color = Color.transparent

func draw(pos):
	image_draw_start()
	image_draw_point(pos)
	image_draw_end()
