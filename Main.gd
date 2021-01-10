extends Node2D

onready var Canvas = $Canvas
onready var UI = $UI
onready var Dialog = $UI/Dialog
onready var Save = $UI/Dialog/Save
onready var Open = $UI/Dialog/Open
onready var ResizeCanvas = $UI/Dialog/ResizeCanvas
onready var Colors = [$UI/Colors/Primary, $UI/Colors/Secondary]

func _ready():
	for popup in Dialog.get_children():
		if popup.has_signal("popup_hide"):
			popup.connect("popup_hide", self, "dialog_close")
	Save.connect("file_selected", self, "save_confirmed")
	Open.connect("file_selected", self, "open_confirmed")
	ResizeCanvas.connect("confirmed", self, "resize_canvas_confirmed")
	
	Canvas.connect("update_size", UI, "update_size")
	Canvas.connect("update_cursor", UI, "update_cursor")
	
	for i in range (2):
		Colors[i].connect("color_changed", self, "color_changed", [i])
		Colors[i].color = Global.colors[i]
	
	Global.Main = self
	Global.Canvas = Canvas
	
	tool_set("Pencil")
	
	for Tool in $Tool.get_children():
		var button = Button.new()
		button.text = Tool.name
		button.connect("pressed", Command, "tool_set", [Tool.name])
		$UI/Tool.add_child(button)

func _unhandled_input(event):
	if event is InputEventMouse:
		Canvas.mouse_event(event)
	if event is InputEventKey and event.pressed:
		# Keyboard shortcuts
		var key_input = OS.get_scancode_string(event.get_scancode_with_modifiers())
#		print(key_input)
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
	else:
		print("Error unknown tool: " + str(tool_name))
	UI.update_tool(tool_name)

func new():
	pass

func save():
	if Canvas.image_file:
		save_confirmed(Canvas.image_file)
	else:
		save_as()

func save_as():
	Dialog.show()
	Save.popup_centered()

func save_confirmed(file):
	print("Saved image to: " + file)
	Canvas.image.save_png(file)
	Canvas.image_file = file
	Canvas.image_name = file.get_file()
	OS.set_window_title(Canvas.image_name)

func open():
	Dialog.show()
	Open.popup_centered()

func open_confirmed(file):
	print("Opened file: " + file)
	Canvas.load_image(file)
	Canvas.image_file = file
	Canvas.image_name = file.get_file()
	OS.set_window_title(Canvas.image_name)

func resize_canvas():
	Dialog.show()
	ResizeCanvas.popup_centered(Vector2(200, 100))
	ResizeCanvas.on_popup()

func resize_canvas_confirmed():
	Canvas.resize_canvas(ResizeCanvas.get_size())

func dialog_close():
	Dialog.hide()

func color_changed(color, index):
	Colors[index].color = color
	Global.colors[index] = color
