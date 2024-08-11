extends MarginContainer

onready var file_button = $Buttons/File
onready var edit_button = $Buttons/Edit
onready var canvas_button = $Buttons/Canvas
onready var transform_button = $Buttons/Transform
onready var view_button = $Buttons/View
onready var testing_button = $Buttons/Testing

var menu_file: PopupMenu
var menu_edit: PopupMenu
var menu_canvas: PopupMenu
var menu_transform: PopupMenu
var menu_view: PopupMenu
var menu_testing: PopupMenu

func _ready():
	menu_file = file_button.get_popup()
	menu_file.connect("id_pressed", self, "file_pressed")
	menu_file.add_item("New (Ctrl + N)")
	menu_file.add_separator()
	menu_file.add_item("Open (Ctrl + O)")
	menu_file.add_separator()
	menu_file.add_item("Save (Ctrl + S)")
	menu_file.add_item("Save As (Shift + Ctrl + S)")
	
	menu_edit = edit_button.get_popup()
	menu_edit.connect("id_pressed", self, "edit_pressed")
	menu_edit.add_item("Undo (Ctrl + Z)")
	menu_edit.add_item("Redo (Ctrl + Y)")
	menu_edit.add_separator()
	menu_edit.add_item("Select All (Ctrl + A)")
	menu_edit.add_item("Deselect (Ctrl + D)")
	menu_edit.add_separator()
	menu_edit.add_item("Delete (Delete)")
	menu_edit.add_item("Cut (Ctrl + X)")
	menu_edit.add_item("Copy (Ctrl + C)")
	menu_edit.add_item("Paste (Ctrl + P)")
	menu_edit.add_separator()
	menu_edit.add_item("Import (Ctrl + I)")
	
	menu_canvas = canvas_button.get_popup()
	menu_canvas.connect("id_pressed", self, "canvas_pressed")
	menu_canvas.add_item("Resize Canvas (Shift + Ctrl + C)")
	
	menu_transform = transform_button.get_popup()
	menu_transform.connect("id_pressed", self, "transform_pressed")
	menu_transform.add_item("Flip Horizontally (Ctrl + F)")
	menu_transform.add_item("Flip Vertically (Shift + Ctrl + F)")
	menu_transform.add_separator()
	menu_transform.add_item("Rotate 90° Clockwise (Ctrl + R)")
	menu_transform.add_item("Rotate 90° Anticlockwise (Shift + Ctrl + R)")
	
	menu_view = view_button.get_popup()
	menu_view.connect("id_pressed", self, "view_pressed")
	menu_view.add_check_item("Toggle Grid")
	menu_view.add_separator()
	menu_view.add_item("Zoom In (Ctrl + =)")
	menu_view.add_item("Zoom Out (Ctrl + -)")
	menu_view.add_item("Zoom Reset (Ctrl + 0)")
	
	if OS.is_debug_build():
		testing_button.show()
		menu_testing = testing_button.get_popup()
		menu_testing.connect("id_pressed", self, "testing_pressed")
		menu_testing.add_item("Run Tests")


func file_pressed(id: int):
	var cmds := ["new", "", "open", "", "save", "save_as"]
	Command.call(cmds[id])


func edit_pressed(id: int):
	var cmds := ["undo", "redo", "", "select_all", "deselect", "", "delete", "cut", "copy", "paste", "", "import"]
	Command.call(cmds[id])


func canvas_pressed(id: int):
	var cmds := ["resize_canvas"]
	Command.call(cmds[id])


func transform_pressed(id: int):
	var cmds := ["flip_horizontal", "flip_vertical", "", "rotate_clockwise", "rotate_anticlockwise"]
	Command.call(cmds[id])


func view_pressed(id: int):
	var cmds := ["toggle_grid", "", "zoom_in", "zoom_out", "zoom_reset"]
	menu_view.toggle_item_checked(id)
	Command.call(cmds[id])


func testing_pressed(id: int):
	var cmds := ["run_tests"]
	Command.call(cmds[id])
