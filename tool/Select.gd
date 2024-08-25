extends "res://tool/Tool.gd"

func draw(pos : Vector2) -> void:
	var select_rect := Util.rect_from_points(start_pos, pos)
	Global.canvas.select_region(select_rect)


func end(pos : Vector2) -> void:
	var select_rect := Util.rect_from_points(start_pos, pos)
	if not Global.canvas.image_rect.intersects(select_rect):
		Global.canvas.deselect()
