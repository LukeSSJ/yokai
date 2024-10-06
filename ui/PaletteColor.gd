extends Panel

var color: Color

func set_number_and_color(set_number: int, set_color: Color) -> void:
	color = set_color
	
	$Label.text = str(set_number)
	
	var style := StyleBoxFlat.new()
	style.bg_color = set_color
	set("theme_override_styles/panel", style)
