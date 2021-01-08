extends "res://tool/Tool.gd"

func draw(pos):
	image_draw_start()
	image_draw_line(prev_pos, pos)
	image_draw_end()
