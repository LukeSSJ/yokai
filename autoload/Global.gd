extends Node

const SESSION_FILE := "user://session.json"

var main: Node
var canvas: Node
var color_section: Node
var selected_tool: Node

var colors := [Color.BLACK, Color.WHITE]
var session := {
	"save_dir": "",
	"open_dir": "",
	"palette": "",
}
var session_has_changed := false
var clipboard_image : Image

var show_grid := false
var grid_size := Vector2(16, 16)

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
	
	if session.get("show_grid"):
		toggle_grid()
	
	var new_size = session.get("grid_size")
	if new_size is Array and len(new_size) == 2:
		set_grid_size(Vector2(new_size[0], new_size[1]))


func session_save() -> void:
	session_set("maximized", get_window().mode == Window.MODE_MAXIMIZED)
	
	if not session_has_changed:
		return
	
	var file := FileAccess.open(SESSION_FILE, FileAccess.WRITE)
	if not file:
		printerr("Failed to write session file: %d" % FileAccess.get_open_error())
		return
	
	file.store_string(JSON.stringify(session))


func session_set(key: String, value) -> void:
	var existing = session.get(key)
	if typeof(existing) == typeof(value) and existing == value:
		return
	
	session_has_changed = true
	session[key] = value

func toggle_grid() -> void:
	show_grid = not show_grid
	session_set("show_grid", show_grid)
	
	if canvas:
		canvas.update_grid()

func set_grid_size(new_size: Vector2) -> void:
	Global.grid_size = new_size
	session_set("grid_size", [grid_size.x, grid_size.y])
	
	if canvas:
		canvas.update_grid()
