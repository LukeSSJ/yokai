extends Node

func open_folder(path: String) -> void:
	if OS.get_name() in ["Linux", "macOS"]:
		OS.execute("open", [path])
		return
	
	if OS.get_name() == "Windows":
		OS.execute("start", [path])
		return
	
	printerr("Sorry I don't know how to open a file explorer on your OS :(")
