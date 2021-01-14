extends MarginContainer

onready var Palete = $HBox/Palete

var colors = "#9ee7d7,#6ac0bd,#5889a2,#462c4b,#724254,#c18c72,#fcebb6,#a9f05f,#5fad67,#4e5e5e"

func _ready():
	for color in colors.split(","):
		var palete_color = Panel.new()
		palete_color.rect_min_size = Vector2(20, 40)
		var style = StyleBoxFlat.new()
		style.bg_color = color
		palete_color.set("custom_styles/panel", style)
		Palete.add_child(palete_color)
		palete_color.connect("gui_input", self, "palete_color_input", [Color(color)])

func palete_color_input(event, color):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == 1:
			Global.Main.color_changed(color, 0)
		elif event.button_index == 2:
			Global.Main.color_changed(color, 1)
