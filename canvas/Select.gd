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

@onready var Change = preload("res://canvas/Change.gd")

func _ready() -> void:
	select_rect = Rect2(Vector2(-16, -16), Vector2(32, 32))
	hide()


func _draw() -> void:
	var rect := select_rect
	if has_moved:
		draw_texture(select_texture, rect.position)
	
	draw_rect(rect, Color.BLACK, false)
	rect = rect.grow(-0.1)
	draw_rect(rect, Color.WHITE, false)


func shift(pos: Vector2) -> void:
	if selecting:
		grab_selection()
		select_rect.position += pos
		queue_redraw()


func select_region(rect: Rect2) -> void:
	confirm_selection()
	select_rect = rect
	original_pos = rect.position
	has_moved = false
	is_new = false
	selecting = true
	select_image = Global.canvas.image.get_region(select_rect)
	select_texture = ImageTools.get_texture(select_image)
	queue_redraw()
	show()


func grab_selection() -> void:
	if not has_moved:
		has_moved = true
		queue_redraw()
		Global.canvas.delete_selection()


func mouse_event_with_pos(event: InputEventMouse, mouse_pos: Vector2) -> bool:
	# Dragging
	if dragging and event is InputEventMouseMotion:
		select_rect.position = mouse_pos + drag_offset
		queue_redraw()
		return true
		
	if event is InputEventMouseButton and event.button_index:
		# Start dragging
		if event.pressed:
			if not select_rect.has_point(mouse_pos):
				return false
			grab_selection()
			dragging = true
			drag_offset = select_rect.position - mouse_pos
			get_viewport().set_input_as_handled()
			return true
		
		# Stop dragging
		if dragging and not event.pressed:
			dragging = false
			return true
	
	return false


func cancel_selection() -> void:
	if visible and has_moved and not is_new:
		Global.canvas.image.blit_rect(select_image, Rect2(Vector2.ZERO, select_rect.size), original_pos)
		Global.canvas.update_output()
		
	selecting = false
	select_texture = null
	hide()


func confirm_selection() -> void:
	if visible and has_moved:
		Global.canvas.image.blend_rect(select_image, Rect2(Vector2.ZERO, select_rect.size), select_rect.position)
		
		var change = Change.new()
		change.action = "blend_image"
		change.params = [Global.canvas.image.duplicate(), Vector2.ZERO]
		change.undo_action = "blit_image"
		change.undo_params = [Global.canvas.prev_image.duplicate(), Vector2.ZERO]
		Global.canvas.make_change(change)
	
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
	queue_redraw()
	show()


func add_image(image: Image) -> void:
	select_image = image
	select_texture = ImageTools.get_texture(select_image)
	select_rect = Rect2(Vector2.ZERO, select_image.get_size())
	has_moved = true
	is_new = true
	queue_redraw()
	show()


func rotate_selection(clockwise: bool) -> void:
	grab_selection()
	ImageTools.image_rotate(select_image, clockwise)
	select_texture = ImageTools.get_texture(select_image)
	select_rect.size = select_image.get_size()
	queue_redraw()


func flip_selection(horizontal: bool) -> void:
	grab_selection()
	if horizontal:
		select_image.flip_x()
	else:
		select_image.flip_y()
	select_texture = ImageTools.get_texture(select_image)
	queue_redraw()
