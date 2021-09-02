extends AcceptDialog

onready var Width := $Content/VBox/Size/Width
onready var Height := $Content/VBox/Size/Height
onready var Position := $Content/VBox/Position

var image_position := Vector2.ZERO

func _ready():
	register_text_enter(Width)
	register_text_enter(Height)
	for i in Position.get_child_count():
		Position.get_child(i).connect("pressed", self, "set_image_position", [i])
	Position.get_child(4).pressed = true
	set_image_position(4)

func on_popup() -> void:
	Width.text = str(Global.Canvas.image_size.x)
	Height.text = str(Global.Canvas.image_size.y)
	Width.select_all()
	Width.grab_focus()

func get_size() -> Vector2:
	return Vector2(Width.text, Height.text)

func set_image_position(i) -> void:
	image_position.x = (i % 3) * 0.5
	image_position.y = floor(i / 3) * 0.5
