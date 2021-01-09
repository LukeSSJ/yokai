extends Node

var command

func _ready():
	command = {
		"Control+S": "save",
		"Control+O": "open",
		"Control+N": "new",
		"Control+Z": "undo",
		"Control+Y": "redo",
		"Control+C": "copy",
		"Control+P": "paste",
		"Control+X": "cut",
		"Control+R": "resize_canvas",
		"Q": "tool_set:Rubber",
		"D": "tool_set:Pencil",
		"S": "tool_set:Select",
		"A": "tool_set:Line",
		"R": "tool_set:Rect",
		"C": "tool_set:Circle",
		"E": "tool_set:Eyedropper",
	}
