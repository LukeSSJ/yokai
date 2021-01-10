extends Node2D

signal update_size
signal update_cursor

const MAX_UNDOS = 10

var image_file
var image_name
var image
var image_size
var image_preview
var zoom_level = 10.0
var zoom
var undo_stack = []
var undo_index = -1

onready var Output = $Output
onready var Preview = $Preview
onready var Select = $Select

func _ready():
	#OS.window_maximized = true
	image = Image.new()
	image_preview = Image.new()
	
	image_size = Vector2(32, 32)
	
	image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	image_preview.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	
	position = OS.get_window_size() / 2
	undo_add()
	update_output()
	update_preview()
	emit_signal("update_size", image_size)

func mouse_event(event):
	var mouse_pos = get_global_mouse_position() - position + image_size / 2
	mouse_pos.x = floor(mouse_pos.x)
	mouse_pos.y = floor(mouse_pos.y)
	emit_signal("update_cursor", mouse_pos)
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

func load_image(filename):
	image.load(filename)
	image_size = image.get_size()
	update_output()
	emit_signal("update_size", image_size)

func zoom_update():
	zoom_level = clamp(zoom_level, 1, 100)
	zoom = 1 / zoom_level
	$Camera.zoom = Vector2(zoom, zoom)

func zoom_in():
	zoom_level += 1
	zoom_update()

func zoom_out():
	zoom_level -= 1
	zoom_update()

func select_all():
	Select.select_region(image_size)

func deselect():
	Select.hide()

func delete_selection():
	if Select.visible:
		Select.hide()
		var blank_image = Image.new()
		blank_image.create(Select.rect.size.x, Select.rect.size.y, false, Image.FORMAT_RGBA8)
		image.blit_rect(blank_image, Rect2(Vector2.ZERO, Select.rect.size), Select.rect.position + Select.rect.size / 2)
		update_output()
		undo_add()

func rotate_clockwise():
	print("Rotate clockwise")
	if image_size.x != image_size.y:
		print("Can only rotate square images atm :/")
		return
	var new_image = image.duplicate()
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

func rotate_anticlockwise():
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

func flip_horizontal():
	var new_image = image.duplicate()
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

func flip_vertical():
	var new_image = image.duplicate()
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

func undo_add():
	undo_stack.resize(undo_index + 1)
	undo_stack.append(image.duplicate())
	if len(undo_stack) > MAX_UNDOS:
		undo_stack.pop_front()
	else:
		undo_index += 1

func undo():
	if undo_index > 0:
		undo_index -= 1
		image = undo_stack[undo_index].duplicate()
		update_output()
	else:
		print("Nothing to undo")

func redo():
	if undo_index < len(undo_stack) - 1:
		undo_index += 1
		image = undo_stack[undo_index].duplicate()
		update_output()
	else:
		print("Nothing to redo")

func resize_canvas(size):
	print("Resize canvas to: " + str(size))
	var old_size = image_size
	image_size = size
	var old_image = image.duplicate()
	image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	image_preview.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	image.blit_rect(old_image, Rect2(Vector2.ZERO, old_size), Vector2.ZERO)
	$Background.region_rect.size = image_size
	update_output()

func select_region(rect):
	Select.select_region(rect)

func update_output():
	var tex = ImageTexture.new()
	tex.create(image_size.x, image_size.y, Image.FORMAT_RGBA8, 0)
	tex.set_data(image)
	Output.set_texture(tex)

func update_preview():
	var tex = ImageTexture.new()
	tex.create(image_size.x, image_size.y, Image.FORMAT_RGBA8, 0)
	tex.set_data(image_preview)
	Preview.set_texture(tex)
