extends Node

var main: Node
var tree: SceneTree

func assert_true(condition: bool):
	if condition:
		Testing.assertion_passed()
	else:
		Testing.assertion_failed("Assertion failed")


func assert_equals(value1, value2):
	if value1 == value2:
		Testing.assertion_passed()
	else:
		Testing.assertion_failed("Asset equals failed: %s != %s" % [value1, value2])


func assert_canvas_size(size: Vector2):
	var canvas_size = get_canvas_size()
	if canvas_size[0] == size[0] and canvas_size[1] == size[1]:
		Testing.assertion_passed()
	else:
		Testing.assertion_failed("Assert canvas size failed: %d,%d not %d,%d" % [canvas_size[0], canvas_size[1], size[0], size[1]])


func assert_image_matches(file: String):
	var image := Image.new()
	if image.load(file) != OK:
		Testing.assertion_failed("Assert image failed: could not open file %s" % file)
		return
	
	var canvas_size := get_canvas_size()
	if canvas_size.x != image.get_width() or canvas_size.y != image.get_height():
		Testing.assertion_failed("Assert image failed: size does not match")
		return
	
	image.lock()
	Global.Canvas.image.lock()
	
	for x in canvas_size.x:
		for y in canvas_size.y:
			var canvas_pixel = Global.Canvas.image.get_pixel(x, y)
			var image_pixel = image.get_pixel(x, y)
			if canvas_pixel != image_pixel:
				Testing.assertion_failed("Assert image failed: pixel does not match at %d,%d" % [x, y])
				return
	
	Global.Canvas.image.unlock()
	
	Testing.assertion_passed()


func get_canvas_size() -> Vector2:
	return Global.Canvas.image_size


func node_by_group(group: String) -> Node:
	return tree.get_nodes_in_group(group)[0]
