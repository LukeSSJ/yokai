extends AcceptDialog

signal resize_canvas

onready var Width := $Content/VBox/Size/Width
onready var Height := $Content/VBox/Size/Height
onready var Position := $Content/VBox/Position

var image_position := Vector2.ZERO

func _ready() -> void:
	connect("confirmed", self, "on_confirmed")
	for i in Position.get_child_count():
		Position.get_child(i).connect("pressed", self, "set_image_position", [i])
	Position.get_child(4).pressed = true
	set_image_position(4)

func on_popup() -> void:
	Width.text = str(Global.Canvas.image_size.x)
	Height.text = str(Global.Canvas.image_size.y)
	Width.select_all()
	Width.grab_focus()

func on_confirmed():
	var size := Vector2(Width.text, Height.text)
	if size.x > 0 and size.y > 0:
		emit_signal("resize_canvas", size, image_position)
		hide()

func set_image_position(i) -> void:
	image_position.x = (i % 3) * 0.5
	image_position.y = floor(i / 3) * 0.5
