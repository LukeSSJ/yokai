extends Node

var command : Dictionary

func _ready():
	command = {
		"Control+N": "new",
		"Control+O": "open",
		"Control+S": "save",
		"Shift+Control+S": "save_as",
		
		"Control+A": "select_all",
		"Control+D": "deselect",
		"Control+Z": "undo",
		"Control+Y": "redo",
		"Control+C": "copy",
		"Control+V": "paste",
		"Control+X": "cut",
		"Delete": "delete",
		"Enter": "confirm",
		"Escape": "cancel",
		
		"Left": "shift_left",
		"Right": "shift_right",
		"Up": "shift_up",
		"Down": "shift_down",
		
		"Control+R": "rotate_clockwise",
		"Shift+Control+R": "rotate_anticlockwise",
		"Control+F": "flip_horizontal",
		"Shift+Control+F": "flip_vertical",
		
		"Shift+Control+C": "resize_canvas",
		
		"Control+G": "toggle_grid",
		
		"Control+P": "select_palete",
		
		"Q": "tool_set:Rubber",
		"D": "tool_set:Pencil",
		"F": "tool_set:Fill",
		"S": "tool_set:Select",
		"A": "tool_set:Line",
		"R": "tool_set:Rect",
		"C": "tool_set:Circle",
		"E": "tool_set:Eyedropper",
		
		"Control+Equal": "zoom_in",
		"Control+Minus": "zoom_out",
		"Control+0": "zoom_reset",
		
		"1": "palete_select:1",
		"2": "palete_select:2",
		"3": "palete_select:3",
		"4": "palete_select:4",
		"5": "palete_select:5",
		"6": "palete_select:6",
		"7": "palete_select:7",
		"8": "palete_select:8",
		"9": "palete_select:9",
		"0": "palete_select:10",
	}

# Load custom shortcuts from config file
func load_shortcuts():
	var config = ConfigFile.new()
	var err = config.load("user://shortcuts.ini")
	if err != OK:
		print("Error: " + str(err))
		return
		
	print(config.get_sections())
