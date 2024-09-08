extends Node

@onready var Change = preload("res://canvas/Change.gd")

func new() -> void:
	Global.main.image_new()


func save() -> void:
	Global.main.image_save()


func save_as() -> void:
	Global.main.image_save_as()


func open() -> void:
	Global.main.image_open()


func undo() -> void:
	if Global.canvas:
		Global.canvas.undo()


func redo() -> void:
	if Global.canvas:
		Global.canvas.redo()


func select_all() -> void:
	if Global.canvas:
		Global.canvas.select_all()


func deselect() -> void:
	if Global.canvas:
		Global.canvas.deselect()


func delete() -> void:
	if Global.canvas:
		Global.canvas.delete()


func cut() -> void:
	if Global.canvas:
		Global.canvas.cut()


func copy() -> void:
	if Global.canvas:
		Global.canvas.copy()


func paste() -> void:
	if Global.canvas:
		Global.canvas.paste()


func import() -> void:
	Global.main.import_image()


func rotate_clockwise() -> void:
	if Global.canvas:
		var change = Change.new()
		change.action = "rotate_clockwise"
		change.undo_action = "rotate_anticlockwise"
		Global.canvas.make_change(change)


func rotate_anticlockwise() -> void:
	if Global.canvas:
		var change = Change.new()
		change.action = "rotate_anticlockwise"
		change.undo_action = "rotate_clockwise"
		Global.canvas.make_change(change)


func flip_horizontal() -> void:
	if Global.canvas:
		var change = Change.new()
		change.action = "flip_horizontal"
		change.undo_action = "flip_horizontal"
		Global.canvas.make_change(change)


func flip_vertical() -> void:
	if Global.canvas:
		var change = Change.new()
		change.action = "flip_vertical"
		change.undo_action = "flip_vertical"
		Global.canvas.make_change(change)


func resize_canvas() -> void:
	Global.main.resize_canvas()


func toggle_grid() -> void:
	Global.toggle_grid()


func edit_grid_size() -> void:
	Global.main.edit_grid_size()


func zoom_in() -> void:
	if Global.canvas:
		Global.canvas.zoom_in()


func zoom_out() -> void:
	if Global.canvas:
		Global.canvas.zoom_out()


func zoom_reset() -> void:
	if Global.canvas:
		Global.canvas.zoom_reset()


func close_tab():
	Global.main.tab_close_current()

# Keyboard only

func select_palette() -> void:
	Global.main.select_palette()


func confirm() -> void:
	if Global.canvas:
		Global.canvas.confirm()


func cancel() -> void:
	if Global.canvas:
		Global.canvas.cancel()


func tool_set(new_tool : String) -> void:
	Global.main.tool_set(new_tool)


func palette_select(palette_number: String, color_index:="0"):
	Global.color_section.palette_select_color(int(palette_number), int(color_index))


func shift_left() -> void:
	if Global.canvas:
		Global.canvas.shift_selection(Vector2(-1, 0))


func shift_right() -> void:
	if Global.canvas:
		Global.canvas.shift_selection(Vector2(1, 0))


func shift_up() -> void:
	if Global.canvas:
		Global.canvas.shift_selection(Vector2(0, -1))


func shift_down() -> void:
	if Global.canvas:
		Global.canvas.shift_selection(Vector2(0, 1))


func run_tests() -> void:
	Testing.run_tests()
