extends "res://tests/Test.gd"

func test_new() -> void:
	Command.new()
	main.NewImage.Width.text = "61"
	main.NewImage.Height.text = "42"
	main.NewImage.on_confirmed()
	assert_canvas_size(Vector2(61, 42))

func test_open() -> void:
	main.image_open_confirmed("res://tests/assets/fish.png")
	assert_image_matches("res://tests/assets/fish.png")

func test_save() -> void:
	main.image_open_confirmed("res://tests/assets/fish.png")
	main.image_save_confirmed("res://tests/assets/fish_out.png")
	assert_image_matches("res://tests/assets/fish_out.png")
