extends Panel

func set_number_and_color(set_number: int, set_color: Color):
	$Label.text = str(set_number)
	var style := StyleBoxFlat.new()
	style.bg_color = set_color
	set("custom_styles/panel", style)
