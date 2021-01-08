extends "res://tool/Tool.gd"

func draw(pos):
	use_preview = true
	image_draw_start()
	image_draw_rect(start_pos, pos)
	image_draw_end()

func end(pos):
	use_preview = false
	image_draw_start()
	image_draw_rect(start_pos, pos)
	image_draw_end()
