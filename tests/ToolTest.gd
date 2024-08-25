extends "res://tests/Test.gd"

func test_tools() -> void:
	check_tool("Pencil")
	check_tool("Line")
	check_tool("Rect")
	check_tool("Circle")
	check_tool("Fill")
	check_tool("Rubber")
	check_tool("Eyedropper")
	check_tool("Select")

func check_tool(tool_name: String) -> void:
	Command.tool_set(tool_name)
	assert_equals(Global.selected_tool.tool_name, tool_name)
