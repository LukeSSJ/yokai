extends CanvasLayer

func update_tool(tool_name: String):
	$Text/Tool.text = tool_name
	$Tool.get_node(tool_name).pressed = true

func update_zoom(zoom: float):
	$Text/Zoom.text = "%d" % (zoom * 100) + "%"

func update_size(size: Vector2):
	$Text/Size.text = str(size.x) + "x" + str(size.y)

func update_cursor(cursor: Vector2):
	$Text/Cursor.text = "(" + str(cursor.x) + "," +  str(cursor.y) + ")"
