extends Node2D

var image
var image_size
var zoom_level = 1.0
var zoom

onready var Output = $Output

func _ready():
	#OS.window_maximized = true
	image_size = Vector2(32, 32)
	image = Image.new()
	image.create(image_size.x, image_size.y, false, Image.FORMAT_RGBA8)
	image.fill(Color("#ffffff"))
	position = OS.get_window_size() / 2
	update_output()

#func _unhandled_input(event):
#	if event is InputEventMouse:
#		print(event.position)

func _process(_delta):
	if Input.is_action_pressed("click1"):
		var mouse_pos = get_global_mouse_position() - position + image_size / 2
		mouse_pos.x = floor(mouse_pos.x)
		mouse_pos.y = floor(mouse_pos.y)
		if mouse_pos.x >= 0 and mouse_pos.y >= 0 and mouse_pos.x < image_size.x and mouse_pos.y < image_size.y:
			image.lock()
			image.set_pixel(mouse_pos.x, mouse_pos.y, Color("#000000"))
			image.unlock()
			update_output()
	if Input.is_action_just_released("scroll_up"):
		zoom_level += 1
		print()
		zoom = 1 / zoom_level
		$Camera.zoom = Vector2(zoom, zoom)
	elif Input.is_action_just_released("scroll_down"):
		zoom_level = max(zoom_level - 1, 1)
		zoom = 1 / zoom_level
		$Camera.zoom = Vector2(zoom, zoom)

func update_output():
	var tex = ImageTexture.new()
	tex.create(image_size.x, image_size.y, Image.FORMAT_RGBA8, 0)
	tex.set_data(image)
	Output.set_texture(tex)
