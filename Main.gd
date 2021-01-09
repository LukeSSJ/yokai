extends Node2D

onready var Canvas = $Canvas
onready var UI = $UI
onready var Save = $UI/Dialog/Save
onready var Open = $UI/Dialog/Open
onready var ColorPrimary = $UI/Colors/Primary
onready var ColorSecondary = $UI/Colors/Secondary

func _ready():
	Save.connect("file_selected", self, "save_confirmed")
	Open.connect("file_selected", self, "open_confirmed")
	
	ColorPrimary.connect("color_changed", self, "color_changed", [0])
	ColorSecondary.connect("color_changed", self, "color_changed", [1])
	
	Canvas.connect("update_size", UI, "update_size")
	Canvas.connect("update_cursor", UI, "update_cursor")
	
	Global.Main = self
	Global.Canvas = Canvas
	
	ColorPrimary.color = Global.colors[0]
	ColorSecondary.color = Global.colors[1]
	
	tool_set("Pencil")

func _input(event):
	if event is InputEventMouse:
		Canvas.mouse_event(event)
	if event is InputEventKey and event.pressed:
		# Keyboard shortcuts
		var key_input = OS.get_scancode_string(event.get_scancode_with_modifiers())
		var command = Shortcut.command.get(key_input)
		if command:
			var args = command.split(":")
			command = args[0]
			args.remove(0)
			if Command.has_method(command):
				Command.callv(command, args)
			else:
				print("Error unkown command: " + command)

func tool_set(tool_name):
	var new_tool = $Tool.get_node_or_null(tool_name)
	if new_tool:
		print("Set tool: " + str(tool_name))
		Global.Tool = new_tool
		Global.Tool.image = Global.Canvas.image
		Global.Tool.image_size = Global.Canvas.image_size
		Global.Tool.image_preview = Global.Canvas.image_preview
	else:
		print("Error unknown tool: " + str(tool_name))
	UI.update_tool(tool_name)

func new():
	pass

func save():
	Save.popup()

func save_confirmed(filename):
	print("Saved image to: " + filename)
	Canvas.image.save_png(filename)

func open():
	Open.popup()

func open_confirmed(filename):
	print("Opened file: " + filename)
	Canvas.load_image(filename)

func resize_canvas():
	$UI/Dialog/ResizeCanvas.popup()

func color_changed(color, index):
	Global.colors[index] = color
