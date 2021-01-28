extends MarginContainer

signal pressed

onready var Name = $Content/VBox/Name
onready var Colors = $Content/VBox/Colors

onready var PaleteColor = preload("res://ui/PaleteColor.tscn")

func _ready():
	connect("gui_input", self, "gui_input")

func set_data(palete: Dictionary) -> void:
	Name.text = palete.name
	var i := 1
	for color in palete.colors:
		var paleteColor = PaleteColor.instance()
		Colors.add_child(paleteColor)
		paleteColor.mouse_filter = MOUSE_FILTER_PASS
		paleteColor.set_number_and_color(i, color)
		i += 1

func gui_input(event : InputEvent):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("pressed")
