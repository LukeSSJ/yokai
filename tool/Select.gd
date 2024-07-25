extends "res://tool/Tool.gd"

func draw(pos : Vector2):
	var select_rect := Util.rect_from_points(start_pos, pos)
	Global.Canvas.select_region(select_rect)


func end(pos : Vector2):
	var select_rect := Util.rect_from_points(start_pos, pos)
	if not Global.Canvas.image_rect.intersects(select_rect):
		Global.Canvas.deselect()
