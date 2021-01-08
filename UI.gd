extends CanvasLayer

func update_size(size):
	$Text/Size.text = str(size.x) + "x" + str(size.y)

func update_cursor(cursor):
	$Text/Cursor.text = "(" + str(cursor.x) + "," +  str(cursor.y) + ")"
