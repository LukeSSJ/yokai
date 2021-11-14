extends Node

var Main : Node
var Canvas : Node
var Colors : Node
var Tool : Node

var colors := [Color.black, Color.white]

var show_grid = false

var session := {
	"save_dir": "",
	"open_dir": "",
	"palete": "",
}

func session_load():
	var file = File.new()
	if file.open("session.json", File.READ) == 0:
		var json : String = file.get_as_text()
		var error := validate_json(json)
		if error == "":
			session = parse_json(json)
			if session.get("maximized"):
				print("maximized")
				OS.window_maximized = true
		else:
			print("Failed to parse session JSON: " + error)

func session_save():
	session.maximized = OS.window_maximized
	
	var file := File.new()
	if file.open("session.json", File.WRITE) == 0:
		file.store_string(to_json(session))
		file.close()
