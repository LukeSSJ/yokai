extends Node2D

onready var Canvas := $Canvas
onready var UI := $UI
onready var Colors := $UI/Colors
onready var Backdrop := $UI/Backdrop
onready var Dialog := $UI/Backdrop/Dialog
onready var NewImage := $UI/Backdrop/Dialog/NewImage
onready var SaveImage := $UI/Backdrop/Dialog/SaveImage
onready var OpenImage := $UI/Backdrop/Dialog/OpenImage
onready var ResizeCanvas := $UI/Backdrop/Dialog/ResizeCanvas

func _ready():
	for popup in Dialog.get_children():
		if popup.has_signal("popup_hide"):
			popup.connect("popup_hide", self, "dialog_close")
	NewImage.connect("confirmed", self, "image_new_confirmed")
	SaveImage.connect("file_selected", self, "image_save_confirmed")
	OpenImage.connect("file_selected", self, "image_open_confirmed")
	ResizeCanvas.connect("confirmed", self, "resize_canvas_confirmed")
	
	Canvas.connect("update_size", UI, "update_size")
	Canvas.connect("update_cursor", UI, "update_cursor")
	
	Global.Main = self
	Global.Canvas = Canvas
	Global.Colors = Colors
	
	tool_set("Pencil")
	
	for Tool in $Tool.get_children():
		var button := Button.new()
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
			var args : PoolStringArray = command.split(":")
			command = args[0]
			args.remove(0)
			if Command.has_method(command):
				print("Command: " + command + " " + args.join(" "))
				Command.callv(command, args)
			else:
				print("Error unkown command: " + command)

func tool_set(tool_name) -> void:
	var new_tool := $Tool.get_node_or_null(tool_name)
	if new_tool:
		print("Set tool: " + str(tool_name))
		Global.Tool = new_tool
	else:
		print("Error unknown tool: " + str(tool_name))
	UI.update_tool(tool_name)

func image_new() -> void:
	Backdrop.show()
	NewImage.popup_centered(Vector2(200, 100))

func image_new_confirmed() -> void:
	Canvas.image_new()

func image_save() -> void:
	if Canvas.image_file:
		image_save_confirmed(Canvas.image_file)
	else:
		image_save_as()

func image_save_as() -> void:
	Backdrop.show()
	SaveImage.popup_centered()

func image_save_confirmed(file) -> void:
	print("Saved image to: " + file)
	Canvas.image.save_png(file)
	Canvas.image_file = file
	Canvas.image_name = file.get_file()
	OS.set_window_title(Canvas.image_name)

func image_open() -> void:
	Backdrop.show()
	OpenImage.popup_centered()

func image_open_confirmed(file : String) -> void:
	print("Opened file: " + file)
	Canvas.image_load(file)
	Canvas.image_file = file
	Canvas.image_name = file.get_file()
	OS.set_window_title(Canvas.image_name)

func resize_canvas() -> void:
	Backdrop.show()
	ResizeCanvas.popup_centered(Vector2(200, 100))
	ResizeCanvas.on_popup()

func resize_canvas_confirmed() -> void:
	Canvas.resize_canvas(ResizeCanvas.get_size())

func dialog_close() -> void:
	Backdrop.hide()
