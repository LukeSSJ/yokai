extends Node2D

onready var canvas_list := $CanvasList
onready var current_tool := $CurrentTool
onready var ui := $UI
onready var dashboard := $UI/Dashboard
onready var color_section := $UI/ColorSection
onready var tools := $UI/Tools
onready var image_tabs = $UI/TopBar/TabWrap/ImageTabs
onready var backdrop := $UI/Backdrop
onready var dialog := $UI/Backdrop/Dialog
onready var unsaved_changes_dialog := $UI/Backdrop/Dialog/UnsavedChanges
onready var unsaved_tab_dialog := $UI/Backdrop/Dialog/UnsavedTab
onready var new_image_dialog := $UI/Backdrop/Dialog/NewImage
onready var save_image_dialog := $UI/Backdrop/Dialog/SaveImage
onready var open_image_dialog := $UI/Backdrop/Dialog/OpenImage
onready var import_image_dialog := $UI/Backdrop/Dialog/ImportImage
onready var resize_canvas_dialog := $UI/Backdrop/Dialog/ResizeCanvas
onready var select_palette_dialog := $UI/Backdrop/Dialog/SelectPalette

onready var Canvas := preload("res://canvas/Canvas.tscn")
onready var Change := preload("res://canvas/Change.gd")

var new_count := 1

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	
	get_tree().connect("files_dropped", self, "files_dropped")
	
	for popup in dialog.get_children():
		if popup is Popup:
			popup.connect("about_to_show", backdrop, "show")
			popup.connect("popup_hide", backdrop, "hide")
	
	Global.main = self
	Global.selected_tool = current_tool
	
	Global.color_section = color_section
	
	Global.session_load()
	Shortcut.load_shortcuts()
	
	tool_set("Pencil")
	
	# Open files from cmd args
	for arg in OS.get_cmdline_args():
		image_open_confirmed(arg)


func _unhandled_input(event) -> void:
	if event is InputEventMouse and Global.canvas:
		Global.canvas.mouse_event(event)
		return
	
	if event is InputEventKey and event.pressed:
		key_event(event)

func _notification(message) -> void:
	if message == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		quit()


func files_dropped(files: PoolStringArray, _screen: int) -> void:
	for file in files:
		image_open_confirmed(file)


func key_event(event: InputEventKey) -> void:
	var key_input = OS.get_scancode_string(event.get_scancode_with_modifiers())
	var command = Shortcut.command.get(key_input)
	if command:
		var args : PoolStringArray = command.split(":")
		command = args[0]
		args.remove(0)
		if Command.has_method(command):
			print("Command: " + command + " " + args.join(" "))
			Command.callv(command, args)
		else:
			printerr("Unkown command: " + command)


func quit() -> void:
	if unsaved_changes_dialog.visible:
		return
		
	var dirty := false
	for canvas in canvas_list.get_children():
		if canvas.dirty:
			dirty = true
			break
	
	if dirty:
		backdrop.show()
		unsaved_changes_dialog.popup_centered(Vector2(200, 100))
		return
	
	quit_confirmed()

func quit_confirmed() -> void:
	Global.session_save()
	get_tree().quit()


func tool_set(tool_name) -> void:
	var new_tool := tools.get_node_or_null(tool_name)
	if not new_tool:
		printerr("Error unknown tool: " + str(tool_name))
		return
	
	current_tool.set_script(new_tool.tool_script)
	current_tool.tool_name = tool_name
	
	ui.update_tool(tool_name)


func tab_changed(tab: int) -> void:
	if not Global.canvas:
		return
	
	Global.canvas.hide()
	Global.canvas = canvas_list.get_child(tab)
	Global.canvas.make_active()
	update_window_title()


func tab_close(tab: int) -> void:
	image_tabs.current_tab = tab
	if Global.canvas.dirty:
		unsaved_tab_dialog.popup_centered(Vector2(200, 100))
		return
	
	tab_close_confirmed()


func tab_close_current() -> void:
	tab_close(image_tabs.current_tab)


func tab_close_confirmed() -> void:
	var tab: int = image_tabs.current_tab
	image_tabs.remove_tab(tab)
	canvas_list.get_child(tab).queue_free()
	
	if image_tabs.current_tab == -1:
		Global.canvas = null
		dashboard.show()
		return
	
	Global.canvas = canvas_list.get_child(image_tabs.current_tab)
	
	if Global.canvas.is_queued_for_deletion():
		Global.canvas = canvas_list.get_child(image_tabs.current_tab + 1)
	
	Global.canvas.show()
	Global.canvas.make_active()


func tab_move(new_index: int):
	var canvas := canvas_list.get_child(image_tabs.current_tab)
	canvas_list.move_child(canvas, new_index)


func tab_rename(new_name):
	image_tabs.set_tab_title(image_tabs.current_tab, new_name)


func image_new() -> void:
	new_image_dialog.popup_centered(Vector2(200, 100))
	new_image_dialog.on_popup()


func image_new_confirmed(size := Vector2.ZERO) -> void:
	var canvas = Canvas.instance()
	var tab := canvas_list.get_child_count()
	
	if size != Vector2.ZERO:
		canvas.image_size = size
	
	canvas_list.add_child(canvas)
	canvas.image_name = "new" + str(new_count)
	
	new_count += 1
	
	if Global.canvas:
		Global.canvas.hide()
	
	dashboard.hide()
	
	canvas.connect("update_title", self, "tab_rename")
	canvas.connect("update_zoom", ui, "update_zoom")
	canvas.connect("update_size", ui, "update_size")
	canvas.connect("update_cursor", ui, "update_cursor")
	
	image_tabs.add_tab(canvas.image_name)
	image_tabs.current_tab = tab
	Global.canvas = canvas
	Global.canvas.make_active()


func image_save() -> void:
	if not Global.canvas:
		return
	
	if Global.canvas.image_file:
		image_save_confirmed(Global.canvas.image_file)
	else:
		image_save_as()


func image_save_as() -> void:
	if not Global.canvas:
		return
	
	# NOTE: When saving the filename defaults to the top filename
	
	if Global.session.get("save_dir"):
		save_image_dialog.current_dir = Global.session.save_dir
		
	if Global.canvas.image_name.ends_with(".png"):
		save_image_dialog.current_file = Global.canvas.image_name
	
	backdrop.show()
	save_image_dialog.popup_centered()


func image_save_confirmed(file: String) -> void:
	print("Saved image to: " + file)
	Global.session_set("save_dir", file.get_base_dir())
	Global.canvas.image_save(file)
	update_window_title()


func image_open() -> void:
	backdrop.show()
	open_image_dialog.popup_centered()
	
	if Global.session.get("open_dir"):
		open_image_dialog.current_dir = Global.session.open_dir


func image_open_confirmed(file: String) -> void:
	print("Opened file: " + file)
	Global.session_set("open_dir", file.get_base_dir())
	
	image_new_confirmed()
	new_count -= 1
	
	if Global.canvas.image_load(file):
		update_window_title()


func import_image() -> void:
	if not Global.canvas:
		return
	
	backdrop.show()
	import_image_dialog.popup_centered()
	
	if Global.session.get("open_dir"):
		import_image_dialog.current_dir = Global.session.open_dir


func import_image_confirmed(file: String) -> void:
	print("Importing file " + file)
	Global.session_set("open_dir", file.get_base_dir())
	Global.canvas.import_image(file)


func resize_canvas() -> void:
	if not Global.canvas:
		return
	
	backdrop.show()
	resize_canvas_dialog.popup_centered(Vector2(200, 100))
	resize_canvas_dialog.on_popup()


func resize_canvas_confirmed(size: Vector2, image_position: Vector2) -> void:
	var change = Change.new()
	change.action = "resize_canvas"
	change.params = [size, image_position]
	change.undo_action = "load_image"
	change.undo_params = [Global.canvas.image.duplicate()]
	Global.canvas.make_change(change)


func select_palette() -> void:
	select_palette_dialog.popup_centered(Vector2(800, 400))


func palette_selected(palette) -> void:
	Global.session_set("palette", palette.file)
	color_section.palette_set(palette)


func update_window_title() -> void:
	OS.set_window_title(Global.canvas.title + " - GSprite")
