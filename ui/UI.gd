extends CanvasLayer

@onready var tools := $Tools
@onready var tool_display := $Text/Tool
@onready var zoom_display := $Text/Zoom
@onready var size_display := $Text/Size
@onready var cursor_display := $Text/Cursor

func update_tool(tool_name: String) -> void:
	tool_display.text = tool_name
	tools.get_node(tool_name).button_pressed = true


func update_zoom(zoom: float) -> void:
	zoom_display.text = "%d%%" % (zoom * 100)


func update_size(size: Vector2) -> void:
	size_display.text = "%dx%d" % [size.x, size.y]


func update_cursor(cursor: Vector2) -> void:
	cursor_display.text = "(%d,%d)" % [cursor.x, cursor.y]
