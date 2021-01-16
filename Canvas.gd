extends Node2D

signal update_size
signal update_cursor

const MAX_UNDOS : int = 10

var image_file : String
var image_name : String
var image_size := Vector2(32, 32)
var image := Image.new()
var image_preview := Image.new()
var zoom_level : float = 10.0
var undo_stack : Array
var undo_index : int

onready var Output := $Output
onready var Preview := $Preview
onready var Select := $Select

func _ready():
	#OS.window_maximized = true
	ImageTools.blank_image(image, image_size)
	ImageTools.blank_image(image_preview, image_size)
	
	position = OS.get_window_size() / 2
	undo_stack_reset()
	update_output()
	update_preview()
	emit_signal("update_size", image_size)

func mouse_event(event : InputEventMouse) -> void:
	var mouse_pos : Vector2 = get_global_mouse_position() - position + image_size / 2
	mouse_pos.x = floor(mouse_pos.x)
	mouse_pos.y = floor(mouse_pos.y)
	emit_signal("update_cursor", mouse_pos)
	if Select.visible and Select.mouse_event_with_pos(event, mouse_pos):
		return
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT:
			if event.pressed:
				Global.Tool.click(mouse_pos, 0)
			else:
				Global.Tool.release(mouse_pos)
		elif event.button_index == BUTTON_RIGHT:
			if event.pressed:
				Global.Tool.click(mouse_pos, 1)
			else:
				Global.Tool.release(mouse_pos)
		elif event.button_index == BUTTON_WHEEL_UP:
			Command.zoom_in()
		elif event.button_index == BUTTON_WHEEL_DOWN:
			Command.zoom_out()
	else:
		Global.Tool.move(mouse_pos)

func image_new():
	ImageTools.blank_image(image, image_size)
	undo_stack_reset()
	update_output()

func image_load(filename : String) -> void:
	image.load(filename)
	image_size = image.get_size()
	undo_stack_reset()
	update_output()
	emit_signal("update_size", image_size)

func zoom_update() -> void:
	zoom_level = clamp(zoom_level, 1, 100)
	var zoom : float = 1 / zoom_level
	$Camera.zoom = Vector2(zoom, zoom)

func zoom_in() -> void:
	zoom_level += 1
	zoom_update()

func zoom_out() -> void:
	zoom_level -= 1
	zoom_update()

func zoom_reset() -> void:
	zoom_level = 1.0
	zoom_update()

func select_all() -> void:
	Select.select_region(Rect2(Vector2.ZERO, image_size))

func deselect() -> void:
	Select.cancel_selection()

func cut() -> void:
	if Select.visible:
		Select.hide()
		Select.copy_selection()
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

func delete_selection() -> void:
	var blank_image := Image.new()
	var rect : Rect2 = Select.select_rect
	ImageTools.blank_image(blank_image, rect.size)
	image.blit_rect(blank_image, Rect2(Vector2.ZERO, rect.size), rect.position)
	update_output()

func rotate_clockwise() -> void:
	print("Rotate clockwise")
	if image_size.x != image_size.y:
		print("Can only rotate square images atm :/")
		return
	var new_image : Image = image.duplicate()
	image.lock()
	new_image.lock()
	for x in image_size.x:
		for y in image_size.y:
			var color = image.get_pixel(x, y)
			new_image.set_pixel(image_size.x - 1 - y, x, color)
	image = new_image
	image.unlock()
	new_image.unlock()
	update_output()
	undo_add()

func rotate_anticlockwise() -> void:
	print("Rotate anticlockwise")
	if image_size.x != image_size.y:
		print("Can only rotate square images atm :/")
		return
	var new_image = image.duplicate()
	image.lock()
	new_image.lock()
	for x in image_size.x:
		for y in image_size.y:
			var color = image.get_pixel(x, y)
			new_image.set_pixel(y, image_size.y - 1 - x, color)
	image = new_image
	image.unlock()
	new_image.unlock()
	update_output()
	undo_add()

func flip_horizontal() -> void:
	var new_image : Image = image.duplicate()
	image.lock()
	new_image.lock()
	for x in image_size.x:
		for y in image_size.y:
			var color = image.get_pixel(x, y)
			new_image.set_pixel(image_size.y - 1 - x, y, color)
	image = new_image
	image.unlock()
	new_image.unlock()
	update_output()
	undo_add()

func flip_vertical() -> void:
	var new_image : Image = image.duplicate()
	image.lock()
	new_image.lock()
	for y in image_size.y:
		for x in image_size.x:
			var color = image.get_pixel(x, y)
			new_image.set_pixel(x, image_size.y - 1 - y, color)
	image = new_image
	image.unlock()
	new_image.unlock()
	update_output()
	undo_add()

func undo_stack_reset() -> void:
	undo_stack = []
	undo_index = -1
	undo_add()

func undo_add() -> void:
	undo_stack.resize(undo_index + 1)
	undo_stack.append(image.duplicate())
	if len(undo_stack) > MAX_UNDOS:
		undo_stack.pop_front()
	else:
		undo_index += 1

func undo() -> void:
	if undo_index > 0:
		undo_index -= 1
		image = undo_stack[undo_index].duplicate()
		update_output()
	else:
		print("Nothing to undo")

func redo() -> void:
	if undo_index < len(undo_stack) - 1:
		undo_index += 1
		image = undo_stack[undo_index].duplicate()
		update_output()
	else:
		print("Nothing to redo")

func resize_canvas(size : Vector2) -> void:
	print("Resize canvas to: " + str(size))
	var old_size : Vector2 = image_size
	image_size = size
	var old_image : Image = image.duplicate()
	ImageTools.blank_image(image, image_size)
	ImageTools.blank_image(image_preview, image_size)
	image.blit_rect(old_image, Rect2(Vector2.ZERO, old_size), Vector2.ZERO)
	$Background.region_rect.size = image_size
	update_output()

func select_region(rect : Rect2) -> void:
	Select.select_region(rect)

func update_output() -> void:
	Output.texture = ImageTools.get_texture(image)

func update_preview() -> void:
	Preview.texture = ImageTools.get_texture(image_preview)
