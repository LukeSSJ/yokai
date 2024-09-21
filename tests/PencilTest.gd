extends "res://tests/Test.gd"

func test_draw() -> void:
	Command.tool_set("Pencil")
	main.image_new_confirmed(Vector2(32, 32))
	Global.selected_tool.click(Vector2(0, 0), 0, false)
	Global.selected_tool.move(Vector2(31, 31))
	Global.selected_tool.release(Vector2(31, 31), 0)
	
	assert_true(true)

func test_draw_secondary() -> void:
	Command.tool_set("Pencil")
	main.image_new_confirmed(Vector2(32, 32))
	Global.selected_tool.click(Vector2(31, 0), 1, false)
	Global.selected_tool.move(Vector2(0, 31))
	Global.selected_tool.release(Vector2(0, 31), 1)
	
	assert_true(true)
