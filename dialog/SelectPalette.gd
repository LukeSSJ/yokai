extends Window

const PALETE_DIR := "user://palettes"

signal palette_selected

var palettes: Array

@onready var PalettePreview := preload("res://dialog/PalettePreview.tscn")

@onready var palette_items := $Content/Rows/ScrollContainer/Palettes
@onready var no_palettes := $Content/Rows/NoPalettes
@onready var folder_path = $Content/Rows/Folder/Path3D

func _ready() -> void:
	palettes = []
	
	var dir := DirAccess.open(PALETE_DIR)
	
	if not dir:
		print("Creating palette folder " + PALETE_DIR)
		dir.make_dir(PALETE_DIR)
	
	folder_path.text = ProjectSettings.globalize_path(PALETE_DIR)
	
	dir.list_dir_begin()
	
	var file = dir.get_next()
	while file != "":
		if not dir.current_is_dir():
			load_palette(file)
		file = dir.get_next()
	
	display_palettes()

func load_palette(fname) -> void:
	var palette = {
		"file": fname,
		"name": "Palette",
		"colors": [],
	}
	
	var file := FileAccess.open(PALETE_DIR + "/" + fname, FileAccess.READ)
	if not file:
		printerr("Could not open palette file: " + fname)
		return
	
	while not file.eof_reached():
		var line := file.get_line()
		if line.begins_with(";"):
			if line.begins_with(";Palette Name: "):
				palette.name = line.substr(15)
		elif len(line) == 8:
			palette.colors.append(line)
	
	palettes.append(palette)
	
	if palette.file == Global.session.get("palette"):
		palette_selected.emit(palette)

func display_palettes() -> void:
	for palette in palettes:
		var palettePreview = PalettePreview.instantiate()
		palette_items.add_child(palettePreview)
		palettePreview.set_data(palette)
		palettePreview.connect("pressed", Callable(self, "palette_selected").bind(palette))
	
	no_palettes.visible = len(palettes) == 0

func select_palette(palette) -> void:
	emit_signal("palette_selected", palette)
	hide()
