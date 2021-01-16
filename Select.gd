extends Node2D

onready var Selection = $Selection

var select_rect : Rect2
var original_pos : Vector2
var dragging : bool = false
var drag_offset : Vector2
var has_moved : bool
var select_image := Image.new()
var select_texture : ImageTexture

func _ready():
	select_rect = Rect2(Vector2(-16, -16), Vector2(32, 32))

func _draw():
	var draw_rect : Rect2 = select_rect
	draw_rect.position -= Vector2(16, 16)
	if select_texture:
		draw_texture(select_texture, draw_rect.position)
	draw_rect(draw_rect, Color.black, false)

func mouse_event_with_pos(event : InputEventMouse, mouse_pos) -> bool:
	if dragging and event is InputEventMouseMotion:
		# Dragging
		select_rect.position = mouse_pos + drag_offset
		update()
		return true
	elif event is InputEventMouseButton and event.button_index:
		# Start dragging
		if event.pressed:
			if !select_rect.has_point(mouse_pos):
				return false
			dragging = true
			if !has_moved:
				ImageTools.blank_image(select_image, select_rect.size)
				select_image.blit_rect(Global.Canvas.image, select_rect, Vector2.ZERO)
				select_texture = ImageTools.get_texture(select_image)
				update()
				Global.Canvas.delete_selection()
				has_moved = true
			drag_offset = select_rect.position - mouse_pos
			get_tree().set_input_as_handled()
			return true
		elif dragging and !event.pressed:
			# Stop dragging
			dragging = false
			return true
	return false

func select_region(rect) -> void:
	select_rect = rect
	original_pos = rect.position
	has_moved = false
	select_texture = null
	update()
	show()

func cancel_selection() -> void:
	if visible and has_moved:
		Global.Canvas.image.blit_rect(select_image, Rect2(Vector2.ZERO, select_rect.size), original_pos)
		Global.Canvas.update_output()
	select_texture = null
	hide()

func confirm_selection() -> void:
	Global.Canvas.image.blit_rect(select_image, Rect2(Vector2.ZERO, select_rect.size), select_rect.position)
	Global.Canvas.update_output()
	Global.Canvas.undo_add()
	select_texture = null
	hide()
