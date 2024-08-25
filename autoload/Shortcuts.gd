extends Node

var command : Dictionary

func _ready():
	command = {
		"Ctrl+N": "new",
		"Ctrl+O": "open",
		"Ctrl+S": "save",
		"Shift+Ctrl+S": "save_as",
		"Ctrl+W": "close_tab",
		
		"Ctrl+A": "select_all",
		"Ctrl+D": "deselect",
		"Ctrl+Z": "undo",
		"Ctrl+Y": "redo",
		"Ctrl+C": "copy",
		"Ctrl+V": "paste",
		"Ctrl+X": "cut",
		"Delete": "delete",
		"Enter": "confirm",
		"Escape": "cancel",
		
		"Left": "shift_left",
		"Right": "shift_right",
		"Up": "shift_up",
		"Down": "shift_down",
		
		"Ctrl+R": "rotate_clockwise",
		"Shift+Ctrl+R": "rotate_anticlockwise",
		"Ctrl+F": "flip_horizontal",
		"Shift+Ctrl+F": "flip_vertical",
		
		"Shift+Ctrl+C": "resize_canvas",
		
		"Ctrl+G": "toggle_grid",
		
		"Ctrl+P": "select_palette",
		
		"Q": "tool_set:Rubber",
		"D": "tool_set:Pencil",
		"F": "tool_set:Fill",
		"S": "tool_set:Select",
		"A": "tool_set:Line",
		"R": "tool_set:Rect",
		"C": "tool_set:Circle",
		"E": "tool_set:Eyedropper",
		
		"Ctrl+Equal": "zoom_in",
		"Ctrl+Minus": "zoom_out",
		"Ctrl+0": "zoom_reset",
		
		"1": "palette_select:1",
		"2": "palette_select:2",
		"3": "palette_select:3",
		"4": "palette_select:4",
		"5": "palette_select:5",
		"6": "palette_select:6",
		"7": "palette_select:7",
		"8": "palette_select:8",
		"9": "palette_select:9",
		"0": "palette_select:10",
		
		"Ctrl+T": "run_tests",
	}


# Load custom shortcuts from config file
func load_shortcuts():
	#var config = ConfigFile.new()
	#config.load("user://shortcuts.ini")
	pass
