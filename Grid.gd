extends Node2D

var area := Vector2(32, 32)
var snap := 16

func _draw():
	for x in range(snap, area.x, snap):
		draw_line(Vector2(x, 0), Vector2(x, area.y), Color.black)
	for y in range(snap, area.y, snap):
		draw_line(Vector2(0, y), Vector2(area.x, y), Color.black)

func set_area(size: Vector2):
	area = size
	update()
