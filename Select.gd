extends Node2D

var rect

func _ready():
	rect = Rect2(Vector2(-16, -16), Vector2(32, 32))

func _draw():
	draw_rect(rect, Color.black, false)

func select_region(vec):
	rect.position = vec / -2
	rect.size = vec
	show()
