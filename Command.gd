extends Node

func new():
	Global.Main.new()

func save():
	Global.Main.save()

func save_as():
	Global.Main.save_as()

func open():
	Global.Main.open()

func undo():
	Global.Canvas.undo()

func redo():
	Global.Canvas.redo()

func select_all():
	Global.Canvas.select_all()

func deselect():
	Global.Canvas.deselect()

func cut():
	pass

func copy():
	pass

func paste():
	print(OS.clipboard)

func delete():
	Global.Canvas.delete_selection()

func rotate_clockwise():
	Global.Canvas.rotate_clockwise()

func rotate_anticlockwise():
	Global.Canvas.rotate_anticlockwise()

func flip_horizontal():
	Global.Canvas.flip_horizontal()

func flip_vertical():
	Global.Canvas.flip_vertical()

func resize_canvas():
	Global.Main.resize_canvas()

func tool_set(new_tool):
	Global.Main.tool_set(new_tool)

func palete_select(_number):
	pass

func zoom_in():
	Global.Canvas.zoom_in()

func zoom_out():
	Global.Canvas.zoom_out()

func zoom_reset():
	Global.Canvas.zoom_reset()
