extends "res://tests/Test.gd"

func test_rotate_clockwise():
	main.image_open_confirmed("res://tests/assets/fish.png")
	Command.rotate_clockwise()
	assert_image_matches("res://tests/assets/fish_rotated_90c.png")
	Command.rotate_clockwise()
	assert_image_matches("res://tests/assets/fish_rotated_180c.png")
	Command.rotate_clockwise()
	assert_image_matches("res://tests/assets/fish_rotated_270c.png")
	Command.rotate_clockwise()
	assert_image_matches("res://tests/assets/fish.png")


func test_rotate_anticlockwise():
	main.image_open_confirmed("res://tests/assets/fish.png")
	Command.rotate_anticlockwise()
	assert_image_matches("res://tests/assets/fish_rotated_270c.png")
	Command.rotate_anticlockwise()
	assert_image_matches("res://tests/assets/fish_rotated_180c.png")
	Command.rotate_anticlockwise()
	assert_image_matches("res://tests/assets/fish_rotated_90c.png")
	Command.rotate_anticlockwise()
	assert_image_matches("res://tests/assets/fish.png")


func test_flip_horizontal():
	main.image_open_confirmed("res://tests/assets/fish.png")
	Command.flip_horizontal()
	assert_image_matches("res://tests/assets/fish_flipped_horizontal.png")
	Command.flip_horizontal()
	assert_image_matches("res://tests/assets/fish.png")


func test_flip_vertical():
	main.image_open_confirmed("res://tests/assets/fish.png")
	Command.flip_vertical()
	assert_image_matches("res://tests/assets/fish_flipped_vertical.png")
	Command.flip_vertical()
	assert_image_matches("res://tests/assets/fish.png")


func test_flip_both():
	main.image_open_confirmed("res://tests/assets/fish.png")
	Command.flip_horizontal()
	Command.flip_vertical()
	assert_image_matches("res://tests/assets/fish_flipped_both.png")
