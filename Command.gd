extends Node

func save():
	Global.Main.save()

func open():
	Global.Main.open()

func new():
	Global.Main.new()

func undo():
	Global.Canvas.undo()

func redo():
	Global.Canvas.redo()

func resize_canvas():
	Global.Main.resize_canvas()

func tool_set(new_tool):
	Global.Main.tool_set(new_tool)
