extends "res://tests/Test.gd"

func test_new() -> void:
	Command.new()
	node_by_group("new_image_width").text = "61"
	node_by_group("new_image_height").text = "42"
	main.NewImage.on_confirmed()
	assert_canvas_size(Vector2(61, 42))

func test_open() -> void:
	main.image_open_confirmed("res://tests/assets/fish.png")
	assert_image_matches("res://tests/assets/fish.png")

func test_save() -> void:
	main.image_open_confirmed("res://tests/assets/fish.png")
	main.image_save_confirmed("res://tests/assets/fish_out.png")
	assert_image_matches("res://tests/assets/fish_out.png")
