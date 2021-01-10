extends Node

func save():
	Global.Main.save()

func save_as():
	Global.Main.save_as()

func open():
	Global.Main.open()

func new():
	Global.Main.new()

func select_all():
	Global.Canvas.select_all()

func deselect():
	Global.Canvas.deselect()

func rotate_clockwise():
	Global.Canvas.rotate_clockwise()

func rotate_anticlockwise():
	Global.Canvas.rotate_anticlockwise()

func flip_horizontal():
	Global.Canvas.flip_horizontal()

func flip_vertical():
	Global.Canvas.flip_vertical()

func delete_selection():
	Global.Canvas.delete_selection()

func undo():
	Global.Canvas.undo()

func redo():
	Global.Canvas.redo()

func resize_canvas():
	Global.Main.resize_canvas()

func tool_set(new_tool):
	Global.Main.tool_set(new_tool)

func zoom_in():
	Global.Canvas.zoom_in()

func zoom_out():
	Global.Canvas.zoom_out()
