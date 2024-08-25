extends "res://tool/Tool.gd"

func draw(pos: Vector2) -> void:
	use_preview = true
	image_draw_start()
	image_draw_rect(start_pos, pos)
	image_draw_end()


func end(pos: Vector2) -> void:
	use_preview = false
	image_draw_start()
	image_draw_rect(start_pos, pos)
	image_draw_end()
