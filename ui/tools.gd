extends GridContainer

func _ready() -> void:
	var group := ButtonGroup.new()
	for button in get_children():
		button.button_group = group
