extends Node

var Main : Node
var Canvas : Node
var Colors : Node
var Tool : Node

var colors := [Color.black, Color.white]
var dirty = false

func session_load():
	var file = File.new()
	if file.open("session.json", File.READ) == 0:
		var json : String = file.get_as_text()
		var error := validate_json(json)
		if error == "":
			var session : Dictionary = parse_json(json)
			if session.get("maximized", false) == true:
				OS.window_maximized = true
			if session.get("palete", ""):
				Global.Main.palete_file = String(session.get("palete", ""))
		else:
			print("Failed to parse session JSON: " + error)

func session_save():
	var file := File.new()
	if file.open("session.json", File.WRITE) == 0:
		var session := {
			"maximized": OS.window_maximized,
			"palete": Global.Main.palete_file,
		}
		file.store_string(to_json(session))
		file.close()
