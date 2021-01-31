extends MarginContainer

onready var Colors = $HBox/Drawing.get_children()
onready var Palete = $HBox/Palete
onready var ChangePalete = $HBox/ChangePalete

onready var PaleteColor = preload("res://ui/PaleteColor.tscn")

func _ready():
	for i in range (2):
		Colors[i].connect("color_changed", self, "color_set", [i])
		Colors[i].color = Global.colors[i]
	ChangePalete.connect("pressed", Command, "select_palete")

func palete_set(palete : Dictionary) -> void:
	for child in Palete.get_children():
		child.queue_free()
	var i := 1
	for color in palete.colors:
		var paleteColor = PaleteColor.instance()
		paleteColor.set_number_and_color(i, color)
		Palete.add_child(paleteColor)
		paleteColor.connect("gui_input", self, "palete_color_input", [i])
		i += 1

func palete_color_input(event: InputEvent, palete_index: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index in [1,2]:
			Command.palete_select(str(palete_index), str(event.button_index - 1))

func color_set(new_color : Color, color_index: int):
	Colors[color_index].color = new_color
	Global.colors[color_index] = new_color

func palete_select_color(palete_number : int, color_index: int):
	var color : Color = Palete.get_child(int(palete_number) - 1).get("custom_styles/panel").bg_color
	color_set(color, color_index)
