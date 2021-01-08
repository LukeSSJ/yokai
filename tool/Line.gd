extends "res://tool/Tool.gd"

func start(_pos):
	use_preview = true

func draw(pos):
	image_draw_start()
	image_draw_line(start_pos, pos)
	image_draw_end()

func end(pos):
	use_preview = false
	image_draw_start()
	image_draw_line(start_pos, pos)
	image_draw_end()
