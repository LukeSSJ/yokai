extends AcceptDialog

signal resize_canvas

onready var width := $Content/VBox/Size/Width
onready var height := $Content/VBox/Size/Height
onready var position := $Content/VBox/Position

var image_position := Vector2.ZERO

func _ready() -> void:
	connect("confirmed", self, "on_confirmed")
	
	for i in position.get_child_count():
		position.get_child(i).connect("pressed", self, "set_image_position", [i])
	
	position.get_child(4).pressed = true
	set_image_position(4)


func on_popup() -> void:
	width.text = str(Global.canvas.image_size.x)
	height.text = str(Global.canvas.image_size.y)
	
	width.select_all()
	width.grab_focus()


func on_confirmed() -> void:
	var size := Vector2(width.text, height.text)
	if size.x > 0 and size.y > 0:
		emit_signal("resize_canvas", size, image_position)
		hide()


func set_image_position(i) -> void:
	image_position.x = (i % 3) * 0.5
	image_position.y = floor(i / 3) * 0.5
