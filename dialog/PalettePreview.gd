extends MarginContainer

signal pressed

@onready var palette_name = $Content/VBox/Name
@onready var palette_colors = $Content/VBox/Colors

@onready var PaletteColor = preload("res://ui/PaletteColor.tscn")

func _ready():
	connect("gui_input", Callable(self, "gui_input"))


func set_data(palette: Dictionary) -> void:
	palette_name.text = palette.name
	
	var i := 1
	for color in palette.colors:
		var paletteColor = PaletteColor.instantiate()
		palette_colors.add_child(paletteColor)
		paletteColor.mouse_filter = MOUSE_FILTER_PASS
		paletteColor.set_number_and_color(i, color)
		i += 1


func gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			pressed.emit()
