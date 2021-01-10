extends AcceptDialog

onready var Width = $Content/Size/Width
onready var Height = $Content/Size/Height

#func _ready():
#	Width.connect("text_changed", Width, "force_int")
#	Height.connect("text_changed", Height, "force_int")

func on_popup():
	Width.text = str(Global.Canvas.image_size.x)
	Height.text = str(Global.Canvas.image_size.y)
	Width.select_all()
	Width.grab_focus()

func get_size():
	return Vector2(Width.text, Height.text)
