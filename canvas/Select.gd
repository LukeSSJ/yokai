extends Node2D

var select_rect : Rect2
var original_pos : Vector2
var dragging := false
var drag_offset : Vector2
var has_moved := false
var is_new := false
var selecting := false
var select_image := Image.new()
var select_texture : ImageTexture

onready var Change = preload("res://canvas/Change.gd")

func _ready():
	select_rect = Rect2(Vector2(-16, -16), Vector2(32, 32))
	hide()


func _draw():
	var draw_rect : Rect2 = select_rect
	if has_moved:
		draw_texture(select_texture, draw_rect.position)
	draw_rect(draw_rect, Color.black, false)
	draw_rect = draw_rect.grow(-0.1)
	draw_rect(draw_rect, Color.white, false)


func shift(pos):
	if selecting:
		grab_selection()
		select_rect.position += pos
		update()


func select_region(rect) -> void:
	confirm_selection()
	select_rect = rect
	original_pos = rect.position
	has_moved = false
	is_new = false
	selecting = true
	select_image = Global.Canvas.image.get_rect(select_rect)
	select_texture = ImageTools.get_texture(select_image)
	update()
	show()


func grab_selection():
	if not has_moved:
		has_moved = true
		update()
		Global.Canvas.delete_selection()


func mouse_event_with_pos(event : InputEventMouse, mouse_pos) -> bool:
	# Dragging
	if dragging and event is InputEventMouseMotion:
		select_rect.position = mouse_pos + drag_offset
		update()
		return true
		
	if event is InputEventMouseButton and event.button_index:
		# Start dragging
		if event.pressed:
			if not select_rect.has_point(mouse_pos):
				return false
			grab_selection()
			dragging = true
			drag_offset = select_rect.position - mouse_pos
			get_tree().set_input_as_handled()
			return true
		
		# Stop dragging
		if dragging and not event.pressed:
			dragging = false
			return true
	
	return false


func cancel_selection() -> void:
	if visible and has_moved and not is_new:
		Global.Canvas.image.blit_rect(select_image, Rect2(Vector2.ZERO, select_rect.size), original_pos)
		Global.Canvas.update_output()
		
	selecting = false
	select_texture = null
	hide()


func confirm_selection() -> void:
	if visible and has_moved:
		Global.Canvas.image.blend_rect(select_image, Rect2(Vector2.ZERO, select_rect.size), select_rect.position)
		
		var change = Change.new()
		change.action = "blend_image"
		change.params = [Global.Canvas.image.duplicate(), Vector2.ZERO]
		change.undo_action = "blit_image"
		change.undo_params = [Global.Canvas.prev_image.duplicate(), Vector2.ZERO]
		Global.Canvas.make_change(change)
	
	selecting = false
	select_texture = null
	hide()


func copy_selection() -> void:
	if visible and select_image:
		Global.clipboard_image = select_image.duplicate()


func paste() -> void:
	confirm_selection()
	
	if not Global.clipboard_image:
		return
	
	select_image = Global.clipboard_image.duplicate()
	select_texture = ImageTools.get_texture(select_image)
	select_rect = Rect2(Vector2.ZERO, select_image.get_size())
	has_moved = true
	is_new = true
	update()
	show()


func add_image(image : Image) -> void:
	select_image = image
	select_texture = ImageTools.get_texture(select_image)
	select_rect = Rect2(Vector2.ZERO, select_image.get_size())
	has_moved = true
	is_new = true
	update()
	show()


func rotate_selection(clockwise : bool):
	grab_selection()
	ImageTools.image_rotate(select_image, clockwise)
	select_texture = ImageTools.get_texture(select_image)
	select_rect.size = select_image.get_size()
	update()


func flip_selection(horizontal : bool):
	grab_selection()
	if horizontal:
		select_image.flip_x()
	else:
		select_image.flip_y()
	select_texture = ImageTools.get_texture(select_image)
	update()
