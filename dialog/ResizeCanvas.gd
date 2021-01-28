extends AcceptDialog

onready var Width := $Content/Size/Width
onready var Height := $Content/Size/Height

func _ready():
	register_text_enter(Width)
	register_text_enter(Height)

func on_popup() -> void:
	Width.text = str(Global.Canvas.image_size.x)
	Height.text = str(Global.Canvas.image_size.y)
	Width.select_all()
	Width.grab_focus()

func get_size() -> Vector2:
	return Vector2(Width.text, Height.text)
