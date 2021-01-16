extends "res://tool/Tool.gd"

func start(_pos: Vector2):
	draw_color = Color.transparent

func draw(pos: Vector2):
	image_draw_start()
	image_draw_point(pos)
	image_draw_end()
