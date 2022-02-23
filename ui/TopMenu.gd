extends MarginContainer

var menu_file : PopupMenu
var menu_edit : PopupMenu
var menu_canvas : PopupMenu
var menu_transform : PopupMenu
var menu_view : PopupMenu

func _ready():
	menu_file = $Buttons/File.get_popup()
	menu_file.connect("id_pressed", self, "file_pressed")
	menu_file.add_item("New (Ctrl + N)")
	menu_file.add_separator()
	menu_file.add_item("Open (Ctrl + O)")
	menu_file.add_separator()
	menu_file.add_item("Save (Ctrl + S)")
	menu_file.add_item("Save As (Shift + Ctrl + S)")
	
	menu_edit = $Buttons/Edit.get_popup()
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
	
	menu_canvas = $Buttons/Canvas.get_popup()
	menu_canvas.connect("id_pressed", self, "canvas_pressed")
	menu_canvas.add_item("Resize Canvas (Shift + Ctrl + C)")
	
	menu_transform = $Buttons/Transform.get_popup()
	menu_transform.connect("id_pressed", self, "transform_pressed")
	menu_transform.add_item("Flip Horizontally (Ctrl + F)")
	menu_transform.add_item("Flip Vertically (Shift + Ctrl + F)")
	menu_transform.add_separator()
	menu_transform.add_item("Rotate 90° Clockwise (Ctrl + R)")
	menu_transform.add_item("Rotate 90° Anticlockwise (Shift + Ctrl + R)")
	
	menu_view = $Buttons/View.get_popup()
	menu_view.connect("id_pressed", self, "view_pressed")
	menu_view.add_check_item("Toggle Grid")

func file_pressed(id):
	var cmds := ["new", "", "open", "", "save", "save_as"]
	Command.call(cmds[id])

func edit_pressed(id):
	var cmds := ["undo", "redo", "", "select_all", "deselect", "", "delete", "cut", "copy", "paste", "", "import"]
	Command.call(cmds[id])

func canvas_pressed(id):
	var cmds := ["resize_canvas"]
	Command.call(cmds[id])

func transform_pressed(id):
	var cmds := ["flip_horizontal", "flip_vertical", "", "rotate_clockwise", "rotate_anticlockwise"]
	Command.call(cmds[id])

func view_pressed(id):
	var cmds := ["toggle_grid"]
	menu_view.toggle_item_checked(id)
	Command.call(cmds[id])
