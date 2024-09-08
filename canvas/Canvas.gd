extends Node2D

signal updated_title
signal updated_zoom
signal updated_size
signal updated_cursor

const MAX_UNDOS := 10

var title := ""
var image_file := ""
var image_name := ""
var image_size := Vector2(32, 32)
var image_rect : Rect2
var image := Image.new()
var image_preview := Image.new()
var prev_image := Image.new()
var zoom_level := 10.0
var dirty := false
var panning := false
var pan_start := Vector2.ZERO
var change_list := []
var change_cursor := -1

@onready var background := $Background
@onready var output := $Output
@onready var preview := $Preview
@onready var top_left := $TopLeft
@onready var grid := $TopLeft/Grid
@onready var select := $TopLeft/Select
@onready var camera := $Camera2D

@onready var Change = preload("res://canvas/Change.gd")

func _ready() -> void:
	position = get_window().get_size() / 2
	image_new()
	update_size()


func mouse_event(event : InputEventMouse) -> void:
	var mouse_pos := get_global_mouse_position() - position + image_size / 2
	mouse_pos.x = floor(mouse_pos.x)
	mouse_pos.y = floor(mouse_pos.y)
	
	emit_signal("updated_cursor", mouse_pos)
	updated_cursor.emit(mouse_pos)
	
	if panning and event is InputEventMouseMotion:
		camera.offset -= event.relative / camera.zoom
		return
	
	if select.visible and select.mouse_event_with_pos(event, mouse_pos):
		return
	
	if event is InputEventMouseButton:
		mouse_button_event(event, mouse_pos)
		return
	
	Global.selected_tool.move(mouse_pos)


func mouse_button_event(event: InputEventMouseButton, mouse_pos: Vector2) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
		if event.pressed:
			Global.selected_tool.click(mouse_pos, event)
		else:
			Global.selected_tool.release(mouse_pos)
		return
			
	if event.button_index == MOUSE_BUTTON_MIDDLE:
		if event.pressed:
			panning = true
			pan_start = get_viewport().get_mouse_position()
		else:
			panning = false
		return
			
	if event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			Command.zoom_in()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			Command.zoom_out()


func make_active() -> void:
	zoom_update()
	update_title()
	toggle_grid()
	show()
	
	updated_size.emit(image_size)
	
	camera.make_current()


func image_new() -> void:
	image_file = ""
	image_name = ""
	image_rect = Rect2(Vector2.ZERO, image_size)
	background.region_rect.size = image_size
	top_left.position = -image_size / 2
	
	image = ImageTools.blank_image(image_size)
	image_preview = ImageTools.blank_image(image_size)
	
	change_list_reset()
	select.cancel_selection()
	update_output()


func image_save(file : String) -> void:
	image.save_png(file)
	
	image_file = file
	image_name = file.get_file()
	dirty = false
	
	update_title()


func image_load(file : String) -> bool:
	var err = image.load(file)
	if err != OK:
		return false
	
	image_file = file
	image_name = file.get_file()
	
	update_size()
	change_list_reset()
	update_title()
	update_output()
	update_preview()
	
	return true


func import_image(file : String) -> bool:
	var add_image := Image.new()
	var err = add_image.load(file)
	
	if err == OK:
		select.add_image(add_image)
		return true
	
	return false


func zoom_update() -> void:
	zoom_level = clamp(zoom_level, 1, 100)
	var zoom : float = 1 * zoom_level
	
	updated_zoom.emit(zoom_level)
	camera.zoom = Vector2(zoom, zoom)


func zoom_in() -> void:
	zoom_level += 1
	zoom_update()


func zoom_out() -> void:
	zoom_level -= 1
	zoom_update()


func zoom_reset() -> void:
	zoom_level = 10.0
	zoom_update()
	camera.offset = Vector2.ZERO


func select_all() -> void:
	select.select_region(Rect2(Vector2.ZERO, image_size))


func deselect() -> void:
	select.confirm_selection()


func shift_selection(vector) -> void:
	select.shift(vector)


func cut() -> void:
	if select.visible:
		select.copy_selection()
		select.hide()
		delete_selection()


func copy() -> void:
	if select.visible:
		select.copy_selection()


func paste() -> void:
	select.paste()


func delete() -> void:
	if select.visible:
		select.hide()
		delete_selection()


func confirm() -> void:
	select.confirm_selection()


func cancel() -> void:
	if select.visible:
		select.cancel_selection()
		return
	
	Global.selected_tool.cancel()


func delete_selection() -> void:
	var rect: Rect2 = select.select_rect
	var change = Change.new()
	change.action = "delete_rect"
	change.params = [rect]
	change.undo_action = "load_image"
	change.undo_params = [image.duplicate()]
	make_change(change)


func change_list_reset() -> void:
	change_list = []
	change_cursor = -1
	prev_image = image.duplicate()


func undo() -> void:
	if select.visible:
		select.cancel_selection()
		return
	
	if change_cursor > -1:
		var change = change_list[change_cursor]
		change.undo()
		change_cursor -= 1
		update_size()
		update_output()
		prev_image = image.duplicate()


func redo() -> void:
	if change_cursor < len(change_list) - 1:
		change_cursor += 1
		var change = change_list[change_cursor]
		change.apply()
		update_size()
		update_output()
		prev_image = image.duplicate()


func select_region(rect : Rect2) -> void:
	select.select_region(rect)


func toggle_grid() -> void:
	grid.visible = Global.show_grid


func update_size() -> void:
	image_size = image.get_size()
	image_rect = Rect2(Vector2.ZERO, image_size)
	
	emit_signal("updated_size", image_size)
	
	image_preview = ImageTools.blank_image(image_size)
	
	background.region_rect.size = image_size
	top_left.position = -image_size / 2
	grid.set_area(image_size)


func update_title() -> void:
	title = image_name
	if dirty:
		title += "*"
	
	updated_title.emit(title)


func update_output() -> void:
	output.texture = ImageTools.get_texture(image)


func update_preview() -> void:
	preview.texture = ImageTools.get_texture(image_preview)


func make_change(change: Node) -> void:
	# Delete undone changes
	if len(change_list) > change_cursor + 1:
		change_list.resize(change_cursor + 1)
	
	change.canvas = self
	change_list.append(change)
	change_cursor += 1
	change.apply()
	
	update_size()
	update_output()
	
	prev_image = image.duplicate()
	
	# Limit undos
	if len(change_list) >= MAX_UNDOS:
		change_list.pop_front()
		change_cursor -= 1
	
	dirty = true
	update_title()

# Canvas operations

func blend_image(add_image: Image, pos: Vector2) -> void:
	var rect := Rect2(Vector2.ZERO, add_image.get_size())
	image.blend_rect(add_image, rect, pos)


func blit_image(add_image: Image, pos: Vector2) -> void:
	var rect := Rect2(Vector2.ZERO, add_image.get_size())
	image.blit_rect(add_image, rect, pos)


func rotate_clockwise() -> void:
	if select.visible:
		select.rotate_selection(true)
		return
	image = ImageTools.image_rotate(image, true)


func rotate_anticlockwise() -> void:
	if select.visible:
		select.rotate_selection(false)
		return
	image = ImageTools.image_rotate(image, false)


func flip_horizontal() -> void:
	if select.visible:
		select.flip_selection(true)
		return
	image.flip_x()


func flip_vertical() -> void:
	if select.visible:
		select.flip_selection(false)
		return
	image.flip_y()


func resize_canvas(size : Vector2, image_position := Vector2.ZERO) -> void:
	var old_size := image_size
	var old_image := image.duplicate()
	
	image = ImageTools.blank_image(size)
	var dest := (size - old_size) * image_position
	image.blit_rect(old_image, Rect2(Vector2.ZERO, old_size), dest)


func load_image(new_image: Image) -> void:
	Global.canvas.image = new_image.duplicate()


func delete_rect(rect: Rect2) -> void:
	var blank_image := ImageTools.blank_image(rect.size)
	image.blit_rect(blank_image, Rect2(Vector2.ZERO, rect.size), rect.position)

# end of Canvas operations
