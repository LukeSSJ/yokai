extends Node2D

var area := Vector2(32, 32)
var snap := 16

func _draw() -> void:
	for x in range(snap, area.x, snap):
		draw_line(Vector2(x, 0), Vector2(x, area.y), Color.BLACK)
	for y in range(snap, area.y, snap):
		draw_line(Vector2(0, y), Vector2(area.x, y), Color.BLACK)


func set_area(size: Vector2) -> void:
	area = size
	queue_redraw()
