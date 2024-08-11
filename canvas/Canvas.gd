extends Node2D

signal update_title
signal update_zoom
signal update_size
signal update_cursor

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

onready var Background := $Background
onready var Output := $Output
onready var Preview := $Preview
onready var TopLeft := $TopLeft
onready var Grid := $TopLeft/Grid
onready var Select := $TopLeft/Select

onready var Change = preload("res://canvas/Change.gd")

func _ready() -> void:
	position = OS.get_window_size() / 2
	image_new()
	update_size()


func mouse_event(event : InputEventMouse) -> void:
	var mouse_pos := get_global_mouse_position() - position + image_size / 2
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
	toggle_grid()
	show()
	
	emit_signal("update_size", image_size)	
	
	$Camera.current = true


func image_new() -> void:
	image_file = ""
	image_name = ""
	image_rect = Rect2(Vector2.ZERO, image_size)
	Background.region_rect.size = image_size
	TopLeft.position = -image_size / 2
	ImageTools.blank_image(image, image_size)
	ImageTools.blank_image(image_preview, image_size)
	change_list_reset()
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


func copy() -> void:
	if Select.visible:
		Select.copy_selection()


func paste() -> void:
	Select.paste()


func delete() -> void:
	if Select.visible:
		Select.hide()
		delete_selection()


func confirm() -> void:
	Select.confirm_selection()


func cancel() -> void:
	if Select.visible:
		Select.cancel_selection()
		return
	
	Global.Tool.cancel()


func delete_selection() -> void:
	var rect: Rect2 = Select.select_rect
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
	# Cancel selection if there is one
	if Select.visible:
		Select.cancel_selection()
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
	Select.select_region(rect)


func toggle_grid():
	Grid.visible = Global.show_grid


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
	if Select.visible:
		Select.rotate_selection(true)
		return
	ImageTools.image_rotate(image, true)


func rotate_anticlockwise() -> void:
	if Select.visible:
		Select.rotate_selection(false)
		return
	ImageTools.image_rotate(image, false)


func flip_horizontal() -> void:
	if Select.visible:
		Select.flip_selection(true)
		return
	image.flip_x()


func flip_vertical() -> void:
	if Select.visible:
		Select.flip_selection(false)
		return
	image.flip_y()


func resize_canvas(size : Vector2, image_position := Vector2.ZERO) -> void:
	var old_size := image_size
	var old_image := image.duplicate()
	
	ImageTools.blank_image(image, size)
	var dest := (size - old_size) * image_position
	image.blit_rect(old_image, Rect2(Vector2.ZERO, old_size), dest)


func load_image(new_image: Image):
	Global.Canvas.image = new_image.duplicate()


func delete_rect(rect: Rect2) -> void:
	var blank_image := Image.new()
	ImageTools.blank_image(blank_image, rect.size)
	image.blit_rect(blank_image, Rect2(Vector2.ZERO, rect.size), rect.position)

# end of Canvas operations
