extends AcceptDialog

signal new_image

@onready var width := $Content/Size/Width
@onready var height := $Content/Size/Height

func _ready() -> void:
	connect("confirmed", Callable(self, "on_confirmed"))


func on_popup() -> void:
	width.select_all()
	width.grab_focus()


func on_confirmed() -> void:
	var image_size := Vector2(int(width.text), int(height.text))
	if image_size.x > 0 and image_size.y > 0:
		new_image.emit(image_size)
		hide()
