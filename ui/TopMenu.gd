extends MarginContainer


func _ready():
	var file : Popup = $Buttons/File.get_popup()
	file.connect("id_pressed", self, "file_pressed")
	file.add_item("New (Ctrl + N)")
	file.add_item("Open (Ctrl + O)")
	file.add_item("Save (Ctrl + S)")
	file.add_item("Save As (Shift + Ctrl + S)")
	
	var edit : Popup = $Buttons/Edit.get_popup()
	edit.connect("id_pressed", self, "edit_pressed")
	edit.add_item("Undo (Ctrl + Z)")
	edit.add_item("Redo (Ctrl + Y)")
	edit.add_item("Select All (Ctrl + A)")
	edit.add_item("Deselect (Ctrl + D)")
	edit.add_item("Cut (Ctrl + X)")
	edit.add_item("Copy (Ctrl + C)")
	edit.add_item("Delete (Delete)")
	edit.add_item("Paste (Ctrl + P)")
	edit.add_item("Import (Ctrl + I)")
	
	var canvas : Popup = $Buttons/Canvas.get_popup()
	canvas.connect("id_pressed", self, "canvas_pressed")
	canvas.add_item("Resize Canvas (Shift + Ctrl + C)")
	
	var transform : Popup = $Buttons/Transform.get_popup()
	transform.connect("id_pressed", self, "transform_pressed")
	transform.add_item("Flip Horizontally (Ctrl + F)")
	transform.add_item("Flip Vertically (Shift + Ctrl + F)")
	transform.add_item("Rotate 90° Clockwise (Ctrl + R)")
	transform.add_item("Rotate 90° Anticlockwise (Shift + Ctrl + R)")

func file_pressed(id):
	var cmds := ["new", "open", "save", "save_as"]
	Command.call(cmds[id])

func edit_pressed(id):
	var cmds := ["undo", "redo", "select_all", "deselect", "cut", "copy", "delete", "paste", "import"]
	Command.call(cmds[id])

func canvas_pressed(id):
	var cmds := ["resize_canvas"]
	Command.call(cmds[id])

func transform_pressed(id):
	var cmds := ["flip_horizontal", "flip_vertical", "rotate_clockwise", "rotate_anticlockwise"]
	Command.call(cmds[id])
