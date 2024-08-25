extends Node

const SESSION_FILE := "usr://.gsprite"

var main: Node
var canvas: Node
var color_section: Node
var selected_tool: Node

var colors := [Color.BLACK, Color.WHITE]
var show_grid := false
var session := {
	"save_dir": "",
	"open_dir": "",
	"palette": "",
}
var session_has_changed := false
var clipboard_image : Image

func session_load() -> void:
	var file := FileAccess.open(SESSION_FILE, FileAccess.READ)
	if not file:
		return
	
	var session_string := file.get_as_text()
	
	var json = JSON.new()
	var error := json.parse(session_string)
	if error != OK:
		print("Failed to parse session JSON: " + json.get_error_message())
		return
	
	var test_json_conv = JSON.new()
	test_json_conv.parse(json)
	session = test_json_conv.get_data()
	if session.get("maximized"):
		get_window().mode = Window.MODE_MAXIMIZED if (true) else Window.MODE_WINDOWED


func session_save() -> void:
	if not session_has_changed:
		return
	
	session.maximized = (get_window().mode == Window.MODE_MAXIMIZED)
	
	var file := FileAccess.open(SESSION_FILE, FileAccess.WRITE)
	if not file:
		printerr("Failed to write session file")
		return
	
	file.store_string(JSON.stringify(session))


func session_set(key: String, value: String) -> void:
	session_has_changed = true
	session[key] = value
