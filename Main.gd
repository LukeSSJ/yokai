extends Node2D

@onready var canvas_list := $CanvasList
@onready var current_tool := $CurrentTool
@onready var UI := $UI
@onready var dashboard := $UI/Dashboard
@onready var color_section := $UI/ColorSection
@onready var tools := $UI/Tools
@onready var image_tabs = $UI/TopBar/TabWrap/ImageTabs
@onready var backdrop := $UI/Backdrop
@onready var unsaved_changes_dialog := $UI/UnsavedChanges
@onready var unsaved_tab_dialog := $UI/UnsavedTab
@onready var new_image_dialog := $UI/NewImage
@onready var save_image_dialog := $UI/SaveImage
@onready var open_image_dialog := $UI/OpenImage
@onready var import_image_dialog := $UI/ImportImage
@onready var resize_canvas_dialog := $UI/ResizeCanvas
@onready var edit_grid_size_dialog := $UI/EditGridSize
@onready var select_palette_dialog := $UI/SelectPalette

@onready var Canvas := preload("res://canvas/Canvas.tscn")
@onready var Change := preload("res://canvas/Change.gd")

var new_count := 1

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	
	get_viewport().connect("files_dropped", Callable(self, "files_dropped"))
	
	for popup in get_tree().get_nodes_in_group("dialog"):
		popup.connect("visibility_changed", dialog_visibility_changed.bind(popup))
	
	Global.main = self
	Global.selected_tool = current_tool
	
	Global.color_section = color_section
	
	Global.session_load()
	Shortcuts.load_shortcuts()
	
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
	if message == NOTIFICATION_WM_CLOSE_REQUEST:
		quit()


func files_dropped(files: PackedStringArray) -> void:
	
	for file in files:
		image_open_confirmed(file)


func key_event(event: InputEventKey) -> void:
	var key_input = OS.get_keycode_string(event.get_keycode_with_modifiers())
	var command = Shortcuts.command.get(key_input)
	if command:
		var args : PackedStringArray = command.split(":")
		command = args[0]
		args.remove_at(0)
		if Command.has_method(command):
			print("Command: " + command + " " + " ".join(args))
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
		unsaved_changes_dialog.popup_centered(Vector2(200, 100))
		return
	
	quit_confirmed()


func quit_confirmed() -> void:
	Global.session_save()
	get_tree().quit()


func dialog_visibility_changed(popup: Node) -> void:
	backdrop.visible = popup.visible


func tool_set(tool_name) -> void:
	var new_tool := tools.get_node_or_null(tool_name)
	if not new_tool:
		printerr("Error unknown tool: " + str(tool_name))
		return
	
	current_tool.set_script(new_tool.tool_script)
	current_tool.tool_name = tool_name
	
	UI.update_tool(tool_name)


func tab_changed(tab: int) -> void:
	if not Global.canvas:
		return
	
	Global.canvas.hide()
	Global.canvas = canvas_list.get_child(tab)
	Global.canvas.make_active()
	update_window_title()


func tab_closed(tab: int) -> void:
	image_tabs.current_tab = tab
	if Global.canvas.dirty:
		unsaved_tab_dialog.popup_centered(Vector2(200, 100))
		return
	
	tab_close_confirmed()


func tab_close_current() -> void:
	tab_closed(image_tabs.current_tab)


func tab_close_confirmed() -> void:
	if image_tabs.tab_count == 1:
		Global.canvas = null
		dashboard.show()
		UI.all_tabs_closed()
	
	var tab: int = image_tabs.current_tab
	image_tabs.remove_tab(tab)
	canvas_list.get_child(tab).queue_free()
	
	if image_tabs.current_tab == -1:
		update_window_title()
		return
	
	Global.canvas = canvas_list.get_child(image_tabs.current_tab)
	
	if Global.canvas.is_queued_for_deletion():
		Global.canvas = canvas_list.get_child(image_tabs.current_tab + 1)
	
	Global.canvas.show()
	Global.canvas.make_active()
	
	update_window_title()


func tab_move(new_index: int):
	var canvas := canvas_list.get_child(image_tabs.current_tab)
	canvas_list.move_child(canvas, new_index)


func tab_rename(new_name):
	image_tabs.set_tab_title(image_tabs.current_tab, new_name)


func image_new() -> void:
	new_image_dialog.popup_centered(Vector2(200, 100))
	new_image_dialog.on_popup()


func image_new_confirmed(size := Vector2.ZERO) -> void:
	var canvas = Canvas.instantiate()
	var tab := canvas_list.get_child_count()
	
	if size != Vector2.ZERO:
		canvas.image_size = size
	
	canvas_list.add_child(canvas)
	canvas.image_name = "new" + str(new_count)
	
	new_count += 1
	
	if Global.canvas:
		Global.canvas.hide()
	
	dashboard.hide()
	UI.tab_opened()
	
	canvas.connect("updated_title", Callable(self, "tab_rename"))
	canvas.connect("updated_zoom", Callable(UI, "update_zoom"))
	canvas.connect("updated_size", Callable(UI, "update_size"))
	canvas.connect("updated_cursor", Callable(UI, "update_cursor"))
	
	image_tabs.add_tab(canvas.image_name)
	image_tabs.current_tab = tab
	Global.canvas = canvas
	Global.canvas.make_active()
	
	update_window_title()


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
	
	save_image_dialog.popup_centered_ratio()


func image_save_confirmed(file: String) -> void:
	print("Saved image to: " + file)
	Global.session_set("save_dir", file.get_base_dir())
	Global.canvas.image_save(file)
	update_window_title()


func image_open() -> void:
	open_image_dialog.popup_centered_ratio()
	
	if Global.session.get("open_dir"):
		open_image_dialog.current_dir = Global.session.open_dir


func image_open_confirmed(file: String) -> void:
	if not file.ends_with(".png"):
		return
	
	print("Opened file: " + file)
	Global.session_set("open_dir", file.get_base_dir())
	
	image_new_confirmed()
	new_count -= 1
	
	if Global.canvas.image_load(file):
		update_window_title()


func import_image() -> void:
	if not Global.canvas:
		return
	
	import_image_dialog.popup_centered_ratio()
	
	if Global.session.get("open_dir"):
		import_image_dialog.current_dir = Global.session.open_dir


func import_image_confirmed(file: String) -> void:
	print("Importing file " + file)
	Global.session_set("open_dir", file.get_base_dir())
	Global.canvas.import_image(file)


func resize_canvas() -> void:
	if not Global.canvas:
		return
	
	resize_canvas_dialog.popup_centered(Vector2(200, 100))
	resize_canvas_dialog.on_popup()


func resize_canvas_confirmed(size: Vector2, image_position: Vector2) -> void:
	var change = Change.new()
	change.action = "resize_canvas"
	change.params = [size, image_position]
	change.undo_action = "load_image"
	change.undo_params = [Global.canvas.image.duplicate()]
	Global.canvas.make_change(change)


func edit_grid_size() -> void:
	edit_grid_size_dialog.popup_centered()
	edit_grid_size_dialog.on_popup()


func select_palette() -> void:
	select_palette_dialog.popup_centered(Vector2(800, 500))


func palette_selected(palette) -> void:
	Global.session_set("palette", palette.file)
	color_section.palette_set(palette)


func update_window_title() -> void:
	if Global.canvas:
		get_window().set_title(Global.canvas.title + " - Yokai")
	else:
		get_window().set_title("Yokai")
