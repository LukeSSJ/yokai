extends Node

onready var Change = preload("res://canvas/Change.gd")

func new() -> void:
	Global.Main.image_new()


func save() -> void:
	Global.Main.image_save()


func save_as() -> void:
	Global.Main.image_save_as()


func open() -> void:
	Global.Main.image_open()


func undo() -> void:
	if Global.Canvas:
		Global.Canvas.undo()


func redo() -> void:
	if Global.Canvas:
		Global.Canvas.redo()


func select_all() -> void:
	if Global.Canvas:
		Global.Canvas.select_all()


func deselect() -> void:
	if Global.Canvas:
		Global.Canvas.deselect()


func delete() -> void:
	if Global.Canvas:
		Global.Canvas.delete()


func cut() -> void:
	if Global.Canvas:
		Global.Canvas.cut()


func copy() -> void:
	if Global.Canvas:
		Global.Canvas.copy()


func paste() -> void:
	if Global.Canvas:
		Global.Canvas.paste()


func import() -> void:
	Global.Main.import_image()


func rotate_clockwise() -> void:
	if Global.Canvas:
		var change = Change.new()
		change.action = "rotate_clockwise"
		change.undo_action = "rotate_anticlockwise"
		Global.Canvas.make_change(change)


func rotate_anticlockwise() -> void:
	if Global.Canvas:
		var change = Change.new()
		change.action = "rotate_anticlockwise"
		change.undo_action = "rotate_clockwise"
		Global.Canvas.make_change(change)


func flip_horizontal() -> void:
	if Global.Canvas:
		var change = Change.new()
		change.action = "flip_horizontal"
		change.undo_action = "flip_horizontal"
		Global.Canvas.make_change(change)


func flip_vertical() -> void:
	if Global.Canvas:
		var change = Change.new()
		change.action = "flip_vertical"
		change.undo_action = "flip_vertical"
		Global.Canvas.make_change(change)


func resize_canvas() -> void:
	Global.Main.resize_canvas()


func toggle_grid() -> void:
	Global.show_grid = not Global.show_grid
	
	if Global.Canvas:
		Global.Canvas.toggle_grid()


func zoom_in() -> void:
	if Global.Canvas:
		Global.Canvas.zoom_in()


func zoom_out() -> void:
	if Global.Canvas:
		Global.Canvas.zoom_out()


func zoom_reset() -> void:
	if Global.Canvas:
		Global.Canvas.zoom_reset()


func close_tab():
	Global.Main.tab_close_current()

# Keyboard only

func select_palette() -> void:
	Global.Main.select_palette()


func confirm() -> void:
	if Global.Canvas:
		Global.Canvas.confirm()


func cancel() -> void:
	if Global.Canvas:
		Global.Canvas.cancel()


func tool_set(new_tool : String) -> void:
	Global.Main.tool_set(new_tool)


func palette_select(palette_number: String, color_index:="0"):
	Global.Colors.palette_select_color(int(palette_number), int(color_index))


func shift_left() -> void:
	if Global.Canvas:
		Global.Canvas.shift_selection(Vector2(-1, 0))


func shift_right() -> void:
	if Global.Canvas:
		Global.Canvas.shift_selection(Vector2(1, 0))


func shift_up() -> void:
	if Global.Canvas:
		Global.Canvas.shift_selection(Vector2(0, -1))


func shift_down() -> void:
	if Global.Canvas:
		Global.Canvas.shift_selection(Vector2(0, 1))


func run_tests() -> void:
	Testing.run_tests()
