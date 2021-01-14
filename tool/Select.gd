extends "res://tool/Tool.gd"


func draw(pos):
	var top_left := Vector2(min(pos.x, start_pos.x), min(pos.y, start_pos.y))
	var bottom_right := Vector2(max(pos.x, start_pos.x) + 1, max(pos.y, start_pos.y) + 1)
	var select_rect := Rect2(top_left, bottom_right - top_left)
	Global.Canvas.select_region(select_rect)
