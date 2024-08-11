extends "res://tests/Test.gd"

func test_resize_canvas() -> void:
	main.image_new_confirmed(Vector2(32, 32))
	
	main.resize_canvas()
	node_by_group("resize_canvas_width").text = "48"
	node_by_group("resize_canvas_height").text = "24"
	main.ResizeCanvas.on_confirmed()
	
	assert_canvas_size(Vector2(48, 24))


func test_resize_canvas_top_left() -> void:
	main.image_open_confirmed("res://tests/assets/fish.png")
	main.resize_canvas_confirmed(Vector2(16, 16), Vector2(0, 0))
	assert_image_matches("res://tests/assets/fish_top_left.png")


func test_resize_canvas_bottom_right() -> void:
	main.image_open_confirmed("res://tests/assets/fish.png")
	main.resize_canvas_confirmed(Vector2(48, 48), Vector2(1, 1))
	assert_image_matches("res://tests/assets/fish_bottom_right.png")
