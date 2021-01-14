extends Node2D

var select_rect : Rect2
var dragging : bool = false
var drag_offset : Vector2

func _ready():
	select_rect = Rect2(Vector2(-16, -16), Vector2(32, 32))

func _draw():
	var draw_rect : Rect2 = select_rect
	draw_rect.position -= Vector2(16, 16)
	draw_rect(draw_rect, Color.black, false)

func mouse_event_with_pos(event, mouse_pos):
	if dragging and event is InputEventMouseMotion:
		position = mouse_pos + drag_offset
		return true
	elif event is InputEventMouseButton and event.button_index:
		if event.pressed:
			if !select_rect.has_point(mouse_pos):
				return
			dragging = true
			drag_offset = position - mouse_pos
			get_tree().set_input_as_handled()
			return true
		elif dragging and !event.pressed:
			dragging = false
			return true

func select_region(rect):
	select_rect = rect
	update()
	show()
