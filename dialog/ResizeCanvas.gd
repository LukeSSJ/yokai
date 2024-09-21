extends AcceptDialog

signal resize_canvas

@onready var width := $Content/VBox/Size/Width
@onready var height := $Content/VBox/Size/Height
@onready var resize_position := $Content/VBox/Position

var image_position := Vector2.ZERO

func _ready() -> void:
	connect("confirmed", Callable(self, "on_confirmed"))
	
	for i in resize_position.get_child_count():
		resize_position.get_child(i).connect("pressed", Callable(self, "set_image_position").bind(i))
	
	resize_position.get_child(4).button_pressed = true
	set_image_position(4)


func on_popup() -> void:
	width.text = str(Global.canvas.image_size.x)
	height.text = str(Global.canvas.image_size.y)
	
	width.select_all()
	width.grab_focus()


func on_confirmed() -> void:
	var image_size := Vector2(int(width.text), int(height.text))
	if image_size.x > 0 and image_size.y > 0:
		resize_canvas.emit(image_size, image_position)
		hide()

@warning_ignore("integer_division")
func set_image_position(i: int) -> void:
	image_position.x = (i % 3) * 0.5
	image_position.y = floor(i / 3) * 0.5
