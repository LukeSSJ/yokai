extends MarginContainer

@onready var colors := $HBox/Drawing.get_children()
@onready var palette_item := $HBox/Palette
@onready var change_palette := $HBox/ChangePalette

@onready var PaletteColor = preload("res://ui/PaletteColor.tscn")

func _ready() -> void:
	for i in range (2):
		colors[i].connect("color_changed", Callable(self, "color_set").bind(i))
		colors[i].color = Global.colors[i]
	
	change_palette.connect("pressed", Callable(Command, "select_palette"))


func palette_set(palette: Dictionary) -> void:
	for child in palette_item.get_children():
		child.queue_free()
	
	var i := 1
	for color in palette.colors:
		var palette_color = PaletteColor.instantiate()
		palette_color.set_number_and_color(i, color)
		palette_item.add_child(palette_color)
		palette_color.connect("gui_input", Callable(self, "palette_color_input").bind(i))
		i += 1


func palette_color_input(event: InputEvent, palette_index: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index in [1,2]:
			Command.palette_select(str(palette_index), str(event.button_index - 1))


func color_set(new_color: Color, color_index: int) -> void:
	colors[color_index].color = new_color
	Global.colors[color_index] = new_color


func palette_select_color(palette_number: int, color_index: int) -> void:
	var i := palette_number - 1
	if i >= palette_item.get_child_count():
		return
	
	var color: Color = palette_item.get_child(i).color
	color_set(color, color_index)
