extends Node2D

signal update_title
signal update_zoom
signal update_size
signal update_cursor

const MAX_UNDOS : int = 10

var title : String
var image_file : String
var image_name : String
var image_size := Vector2(32, 32)
var image_rect : Rect2
var image := Image.new()
var image_preview := Image.new()
var zoom_level : float = 10.0
var undo_stack : Array
var undo_index : int
var dirty := false
var blank := false
var panning := false
var pan_start := Vector2.ZERO

onready var Background := $Background
onready var Output := $Output
onready var Preview := $Preview
onready var TopLeft := $TopLeft
onready var Grid := $TopLeft/Grid
onready var Select := $TopLeft/Select

func _ready() -> void:
	position = OS.get_window_size() / 2
	image_new()
	update_size()

func mouse_event(event : InputEventMouse) -> void:
	var mouse_pos : Vector2 = get_global_mouse_position() - position + image_size / 2
	mouse_pos.x = floor(mouse_pos.x)
	mouse_pos.y = floor(mouse_pos.y)
	emit_signal("update_cursor", mouse_pos)
	
	# Panning
	if panning and event is InputEventMouseMotion:
		$Camera.offset -= event.relative * $Camera.zoom
		return
	
	# Handle events for selection
	if Select.visible and Select.mouse_event_with_pos(event, mouse_pos):
		return
	
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT or event.button_index == BUTTON_RIGHT:
			if event.pressed:
				Global.Tool.click(mouse_pos, event)
			else:
				Global.Tool.release(mouse_pos)
		elif event.button_index == BUTTON_MIDDLE:
			if event.pressed:
				panning = true
				pan_start = get_viewport().get_mouse_position()
			else:
				panning = false
		elif event.pressed:
			if event.button_index == BUTTON_WHEEL_UP:
				Command.zoom_in()
			elif event.button_index == BUTTON_WHEEL_DOWN:
				Command.zoom_out()
	else:
		Global.Tool.move(mouse_pos)

func make_active() -> void:
	zoom_update()
	update_title()
	emit_signal("update_size", image_size)
	toggle_grid(Global.show_grid)
	show()
	$Camera.current = true

func image_new() -> void:
	image_file = ""
	image_name = ""
	image_rect = Rect2(Vector2.ZERO, image_size)
	Background.region_rect.size = image_size
	TopLeft.position = -image_size / 2
	ImageTools.blank_image(image, image_size)
	ImageTools.blank_image(image_preview, image_size)
	undo_stack_reset()
	Select.cancel_selection()
	update_output()

func image_save(file : String) -> void:
	image.save_png(file)
	image_file = file
	image_name = file.get_file()
	dirty = false
	update_title()

func image_load(file : String) -> bool:
	var err = image.load(file)
	if err == OK:
		image_file = file
		image_name = file.get_file()
		update_size()
		undo_stack_reset()
		update_title()
		update_output()
		update_preview()
		return true
	return false

func import_image(file : String) -> bool:
	var add_image := Image.new()
	var err = add_image.load(file)
	if err == OK:
		Select.add_image(add_image)
		return true
	return false

func zoom_update() -> void:
	zoom_level = clamp(zoom_level, 1, 100)
	var zoom : float = 1 / zoom_level
	emit_signal("update_zoom", zoom_level)
	$Camera.zoom = Vector2(zoom, zoom)

func zoom_in() -> void:
	zoom_level += 1
	zoom_update()

func zoom_out() -> void:
	zoom_level -= 1
	zoom_update()

func zoom_reset() -> void:
	zoom_level = 10.0
	zoom_update()

func select_all() -> void:
	Select.select_region(Rect2(Vector2.ZERO, image_size))

func deselect() -> void:
	Select.confirm_selection()

func shift_selection(vector) -> void:
	Select.shift(vector)

func cut() -> void:
	if Select.visible:
		Select.copy_selection()
		Select.hide()
		delete_selection()
		undo_add()

func copy() -> void:
	if Select.visible:
		Select.copy_selection()

func paste() -> void:
	Select.paste()

func delete() -> void:
	if Select.visible:
		Select.hide()
		delete_selection()
		undo_add()

func confirm() -> void:
	Select.confirm_selection()

func cancel() -> void:
	if Select.visible:
		Select.cancel_selection()
		return
	Global.Tool.cancel_drawing()

func delete_selection() -> void:
	var blank_image := Image.new()
	var rect : Rect2 = Select.select_rect
	ImageTools.blank_image(blank_image, rect.size)
	image.blit_rect(blank_image, Rect2(Vector2.ZERO, rect.size), rect.position)
	update_output()

func rotate_clockwise() -> void:
	print("Rotate clockwise")
	if Select.visible:
		Select.rotate_selection(true)
		return
	ImageTools.image_rotate(image, true)
	update_size()
	update_output()
	undo_add()

func rotate_anticlockwise() -> void:
	print("Rotate anticlockwise")
	if Select.visible:
		Select.rotate_selection(false)
		return
	ImageTools.image_rotate(image, false)
	update_size()
	update_output()
	undo_add()

func flip_horizontal() -> void:
	if Select.visible:
		Select.flip_selection(true)
		return
	image.flip_x()
	update_output()
	undo_add()

func flip_vertical() -> void:
	if Select.visible:
		Select.flip_selection(false)
		return
	image.flip_y()
	update_output()
	undo_add()

func undo_stack_reset() -> void:
	undo_stack = []
	undo_index = -1
	undo_add()

func undo_add() -> void:
	if !undo_stack.empty():
		dirty = true
		blank = false
		update_title()
	undo_stack.resize(undo_index + 1)
	var image_copy = image.duplicate()
	undo_stack.append(image_copy)
	if len(undo_stack) > MAX_UNDOS:
		undo_stack.pop_front()
	else:
		undo_index += 1
	var sprite = Sprite.new()
	sprite.texture = ImageTools.get_texture(image_copy)
	sprite.position.y += $Undos.get_child_count() * 34
	$Undos.add_child(sprite)

func undo() -> void:
	if undo_index > 0:
		undo_index -= 1
		image = undo_stack[undo_index].duplicate()
		image_size = image.get_size()
		resize_canvas(image.get_size())
	else:
		print("Nothing to undo")

func redo() -> void:
	if undo_index < len(undo_stack) - 1:
		undo_index += 1
		image = undo_stack[undo_index].duplicate()
		resize_canvas(image.get_size())
	else:
		print("Nothing to redo")

func resize_canvas(size : Vector2, image_position := Vector2.ZERO) -> void:
	print("Resize canvas to: " + str(size))
	var old_size : Vector2 = image_size
	var old_image : Image = image.duplicate()
	
	ImageTools.blank_image(image, size)
	var dest := (size - old_size) * image_position
	image.blit_rect(old_image, Rect2(Vector2.ZERO, old_size), dest)
	update_size()
	update_output()

func select_region(rect : Rect2) -> void:
	Select.select_region(rect)

func toggle_grid(set_to:bool):
	Grid.visible = set_to

func update_size() -> void:
	image_size = image.get_size()
	image_rect = Rect2(Vector2.ZERO, image_size)
	emit_signal("update_size", image_size)
	ImageTools.blank_image(image_preview, image_size)
	Background.region_rect.size = image_size
	TopLeft.position = -image_size / 2
	Grid.set_area(image_size)

func update_title():
	title = image_name
	if dirty:
		title += "*"
	emit_signal("update_title", title)

func update_output() -> void:
	Output.texture = ImageTools.get_texture(image)

func update_preview() -> void:
	Preview.texture = ImageTools.get_texture(image_preview)
