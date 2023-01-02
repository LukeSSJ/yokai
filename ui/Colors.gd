extends MarginContainer

onready var Colors = $HBox/Drawing.get_children()
onready var Palette = $HBox/Palette
onready var ChangePalette = $HBox/ChangePalette

onready var PaletteColor = preload("res://ui/PaletteColor.tscn")

func _ready():
	for i in range (2):
		Colors[i].connect("color_changed", self, "color_set", [i])
		Colors[i].color = Global.colors[i]
	ChangePalette.connect("pressed", Command, "select_palette")

func palette_set(palette: Dictionary) -> void:
	for child in Palette.get_children():
		child.queue_free()
	var i := 1
	for color in palette.colors:
		var paletteColor = PaletteColor.instance()
		paletteColor.set_number_and_color(i, color)
		Palette.add_child(paletteColor)
		paletteColor.connect("gui_input", self, "palette_color_input", [i])
		i += 1

func palette_color_input(event: InputEvent, palette_index: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index in [1,2]:
			Command.palette_select(str(palette_index), str(event.button_index - 1))

func color_set(new_color: Color, color_index: int) -> void:
	Colors[color_index].color = new_color
	Global.colors[color_index] = new_color

func palette_select_color(palette_number: int, color_index: int) -> void:
	var i := palette_number - 1
	if i >= Palette.get_child_count():
		return
	var color: Color = Palette.get_child(i).color
	color_set(color, color_index)
