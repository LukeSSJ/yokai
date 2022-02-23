extends WindowDialog

const PALETE_DIR = "usr://paletes"

signal palete_selected

var paletes

onready var PaletePreview = preload("res://dialog/PaletePreview.tscn")

onready var Paletes = $ScrollContainer/Paletes

func load_paletes():
	paletes = []
	var dir := Directory.new()
	if dir.open(PALETE_DIR) != 0:
		print("Failed to read " + PALETE_DIR)
	dir.list_dir_begin()
	var file = dir.get_next()
	while file != "":
		if !dir.current_is_dir():
			load_palete(file)
		file = dir.get_next()
	display_paletes()

func load_palete(fname):
	var file := File.new()
	if file.open(PALETE_DIR + "/" + fname, File.READ) == 0:
		var palete = {
			"file": fname,
			"name": "Palete",
			"colors": [],
		}
		while !file.eof_reached():
			var line := file.get_line()
			if line.begins_with(";"):
				if line.begins_with(";Palette Name: "):
					palete.name = line.substr(15)
			elif len(line) == 8:
				palete.colors.append(line)
		file.close()
		paletes.append(palete)
		if palete.file == Global.session.palete:
			emit_signal("palete_selected", palete)

func display_paletes():
	for palete in paletes:
		var paletePreview = PaletePreview.instance()
		Paletes.add_child(paletePreview)
		paletePreview.set_data(palete)
		paletePreview.connect("pressed", self, "palete_selected", [palete])

func palete_selected(palete):
	emit_signal("palete_selected", palete)
	hide()
