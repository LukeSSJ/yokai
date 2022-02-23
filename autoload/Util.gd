extends Node

func rect_from_points(start_pos, pos) -> Rect2:
	var top_left := Vector2(min(pos.x, start_pos.x), min(pos.y, start_pos.y))
	var bottom_right := Vector2(max(pos.x, start_pos.x) + 1, max(pos.y, start_pos.y) + 1)
	return Rect2(top_left, bottom_right - top_left)
