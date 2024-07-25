extends AcceptDialog

signal new_image

onready var Width := $Content/Size/Width
onready var Height := $Content/Size/Height

func _ready():
	connect("confirmed", self, "on_confirmed")


func on_popup() -> void:
	Width.select_all()
	Width.grab_focus()


func on_confirmed() -> void:
	var size := Vector2(Width.text, Height.text)
	if size.x > 0 and size.y > 0:
		emit_signal("new_image", size)
		hide()
