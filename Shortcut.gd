extends Node

var command

func _ready():
	command = {
		"Control+S": "save",
		"Shift+Control+S": "save_as",
		"Control+O": "open",
		"Control+N": "new",
		"Control+A": "select_all",
		"Control+D": "deselect",
		"Control+Z": "undo",
		"Control+Y": "redo",
		"Control+C": "copy",
		"Control+P": "paste",
		"Control+X": "cut",
		"Control+E": "resize_canvas",
		"Control+R": "rotate_clockwise",
		"Shift+Control+R": "rotate_anticlockwise",
		"Control+F": "flip_horizontal",
		"Shift+Control+F": "flip_vertical",
		"Delete": "delete_selection",
		"Q": "tool_set:Rubber",
		"D": "tool_set:Pencil",
		"F": "tool_set:Fill",
		"S": "tool_set:Select",
		"A": "tool_set:Line",
		"R": "tool_set:Rect",
		"C": "tool_set:Circle",
		"E": "tool_set:Eyedropper",
	}
