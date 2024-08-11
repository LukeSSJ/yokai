extends AcceptDialog

signal new_image

onready var width := $Content/Size/Width
onready var height := $Content/Size/Height

func _ready():
	connect("confirmed", self, "on_confirmed")


func on_popup() -> void:
	width.select_all()
	width.grab_focus()


func on_confirmed() -> void:
	var size := Vector2(width.text, height.text)
	if size.x > 0 and size.y > 0:
		emit_signal("new_image", size)
		hide()
