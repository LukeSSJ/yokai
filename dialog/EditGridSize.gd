extends ConfirmationDialog

@onready var width = $Content/Inputs/Width
@onready var height = $Content/Inputs/Height


func on_popup() -> void:
	width.text = str(Global.grid_size.x)
	height.text = str(Global.grid_size.y)
	
	width.select_all()
	width.grab_focus()


func on_confirmed() -> void:
	var new_size := Vector2(int(width.text), int(height.text))
	if new_size.x > 0 and new_size.y > 0:
		Global.set_grid_size(new_size)
		hide()
