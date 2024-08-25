extends Node

const SESSION_FILE := "user://session.json"

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
		printerr("Failed to parse session JSON: " + json.get_error_message())
		return
	
	if typeof(json.data) == TYPE_ARRAY:
		printerr("Session JSON is array expected dict")
	
	session = json.data
	if session.get("maximized"):
		get_window().mode = Window.MODE_MAXIMIZED


func session_save() -> void:
	#if not session_has_changed:
		#return
	
	session.maximized = (get_window().mode == Window.MODE_MAXIMIZED)
	
	var file := FileAccess.open(SESSION_FILE, FileAccess.WRITE)
	if not file:
		printerr("Failed to write session file: %d" % FileAccess.get_open_error())
		return
	
	file.store_string(JSON.stringify(session))


func session_set(key: String, value: String) -> void:
	session_has_changed = true
	session[key] = value
