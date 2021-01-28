extends Node2D

onready var CanvasList := $CanvasList
onready var UI := $UI
onready var Colors := $UI/Colors
onready var ImageTabs = $UI/VBox/ImageTabs
onready var Backdrop := $UI/Backdrop
onready var Dialog := $UI/Backdrop/Dialog
onready var UnsavedChanges := $UI/Backdrop/Dialog/UnsavedChanges
onready var UnsavedTab := $UI/Backdrop/Dialog/UnsavedTab
onready var NewImage := $UI/Backdrop/Dialog/NewImage
onready var SaveImage := $UI/Backdrop/Dialog/SaveImage
onready var OpenImage := $UI/Backdrop/Dialog/OpenImage
onready var ImportImage := $UI/Backdrop/Dialog/ImportImage
onready var ResizeCanvas := $UI/Backdrop/Dialog/ResizeCanvas
onready var SelectPalete := $UI/Backdrop/Dialog/SelectPalete

onready var Canvas = preload("res://Canvas.tscn")

var new_count := 1
var palete_file : String

func _ready():
	get_tree().set_auto_accept_quit(false)
	
	ImageTabs.connect("tab_changed", self, "tab_changed")
	ImageTabs.connect("tab_close", self, "tab_close")
	ImageTabs.connect("reposition_active_tab_request", self, "tab_move")
	for popup in Dialog.get_children():
		if popup is Popup:
			popup.connect("about_to_show", Backdrop, "show")
			popup.connect("popup_hide", Backdrop, "hide")
	UnsavedChanges.connect("confirmed", self, "quit")
	UnsavedTab.connect("confirmed", self, "tab_close_confirmed")
	NewImage.connect("confirmed", self, "image_new_confirmed")
	SaveImage.connect("file_selected", self, "image_save_confirmed")
	OpenImage.connect("file_selected", self, "image_open_confirmed")
	ImportImage.connect("file_selected", self, "import_image_confirmed")
	ResizeCanvas.connect("confirmed", self, "resize_canvas_confirmed")
	SelectPalete.connect("palete_selected", self, "palete_selected")
	
	Global.Main = self
	Global.Colors = Colors
	
	Global.session_load()
	SelectPalete.load_paletes()
		
	for button in $UI/Tool.get_children():
		button.text = button.name
		button.connect("pressed", Command, "tool_set", [button.name])
	tool_set("Pencil")
	image_new()

func _unhandled_input(event):
	if event is InputEventMouse:
		Global.Canvas.mouse_event(event)
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

func _notification(message):
	if message == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if Global.dirty:
			Backdrop.show()
			UnsavedChanges.popup_centered(Vector2(200, 100))
		else:
			quit()

func quit():
	Global.session_save()
	get_tree().quit()

func tool_set(tool_name) -> void:
	var new_tool := $UI/Tool.get_node_or_null(tool_name)
	if new_tool:
		Global.Tool = new_tool
		UI.update_tool(tool_name)
	else:
		print("Error unknown tool: " + str(tool_name))

func tab_changed(tab : int):
	Global.Canvas.hide()
	Global.Canvas = CanvasList.get_child(tab)
	Global.Canvas.show()

func tab_close(_tab: int):
	if CanvasList.get_child_count() == 1:
		return
	if Global.Canvas.dirty:
		UnsavedTab.popup_centered(Vector2(200, 100))
	else:
		tab_close_confirmed()

func tab_close_confirmed():
	var tab : int = ImageTabs.current_tab
	ImageTabs.remove_tab(tab)
	CanvasList.get_child(tab).queue_free()
	Global.Canvas = CanvasList.get_child(ImageTabs.current_tab)
	if Global.Canvas.is_queued_for_deletion():
		Global.Canvas = CanvasList.get_child(ImageTabs.current_tab + 1)
	Global.Canvas.show()

func tab_move(new_index: int):
	var canvas := CanvasList.get_child(ImageTabs.current_tab)
	CanvasList.move_child(canvas, new_index)

func tab_rename(new_name):
	ImageTabs.set_tab_title(ImageTabs.current_tab, new_name)

func image_new() -> void:
	var canvas = Canvas.instance()
	var tab := CanvasList.get_child_count()
	CanvasList.add_child(canvas)
	canvas.image_name = "new" + str(new_count)
	if Global.Canvas:
		Global.Canvas.hide()
	Global.Canvas = canvas
	canvas.connect("update_title", self, "tab_rename")
	canvas.connect("update_zoom", UI, "update_zoom")
	canvas.connect("update_size", UI, "update_size")
	canvas.connect("update_cursor", UI, "update_cursor")
	ImageTabs.add_tab(canvas.image_name)
	new_count += 1
	ImageTabs.current_tab = tab
#	Backdrop.show()
#	NewImage.popup_centered(Vector2(200, 100))

#func image_new_confirmed() -> void:
#	Canvas.image_new()

func image_save() -> void:
	if Global.Canvas.image_file:
		image_save_confirmed(Global.Canvas.image_file)
	else:
		image_save_as()

func image_save_as() -> void:
	Backdrop.show()
	SaveImage.popup_centered()

func image_save_confirmed(file) -> void:
	print("Saved image to: " + file)
	Global.Canvas.image_save(file)
	OS.set_window_title("GSprite - " + Global.Canvas.title)

func image_open() -> void:
	Backdrop.show()
	OpenImage.popup_centered()

func image_open_confirmed(file : String) -> void:
	print("Opened file: " + file)
	if Global.Canvas.dirty:
		image_new()
		new_count -= 1
	Global.Canvas.image_load(file)
	OS.set_window_title(Global.Canvas.image_name)

func import_image() -> void:
	Backdrop.show()
	ImportImage.popup()

func import_image_confirmed(file : String) -> void:
	print("Importing file " + file)
	Global.Canvas.import_image(file)

func resize_canvas() -> void:
	Backdrop.show()
	ResizeCanvas.popup_centered(Vector2(200, 100))
	ResizeCanvas.on_popup()

func resize_canvas_confirmed() -> void:
	Global.Canvas.resize_canvas(ResizeCanvas.get_size())
	Global.Canvas.undo_add()

func select_palete() -> void:
	SelectPalete.popup_centered()

func palete_selected(palete) -> void:
	palete_file = palete.file
	Colors.palete_set(palete)
