extends MarginContainer

onready var Colors = $HBox/Drawing.get_children()
onready var Palete = $HBox/Palete

onready var PaleteColor = preload("res://ui/PaleteColor.tscn")

var colors = "#9ee7d7,#6ac0bd,#5889a2,#462c4b,#724254,#c18c72,#fcebb6,#a9f05f,#5fad67,#4e5e5e"

func _ready():
	for i in range (2):
		Colors[i].connect("color_changed", self, "color_set", [i])
		Colors[i].color = Global.colors[i]
	
	var i := 1
	for color in colors.split(","):
		var paleteColor = PaleteColor.instance()
		paleteColor.set_number_and_color(i, color)
		Palete.add_child(paleteColor)
		paleteColor.connect("gui_input", self, "palete_color_input", [i])
		i += 1

func palete_color_input(event: InputEvent, palete_index: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index in [1,2]:
			Command.palete_select(str(palete_index), str(event.button_index - 1))

func color_set(new_color, color_index):
	Colors[color_index].color = new_color
	Global.colors[color_index] = new_color

func palete_select(palete_number, color_index):
	var color : Color = Palete.get_child(int(palete_number) - 1).get("custom_styles/panel").bg_color
	color_set(color, color_index)
