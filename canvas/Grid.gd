extends Node2D

var area: Vector2

func _draw() -> void:
	for x in range(Global.grid_size.x, area.x, Global.grid_size.x):
		draw_line(Vector2(x, 0), Vector2(x, area.y), Color.BLACK)
	
	for y in range(Global.grid_size.y, area.y, Global.grid_size.y):
		draw_line(Vector2(0, y), Vector2(area.x, y), Color.BLACK)


func set_area(size: Vector2) -> void:
	area = size
	queue_redraw()
