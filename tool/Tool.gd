extends Button

var drawing : bool
var start_pos : Vector2
var prev_pos : Vector2
var use_preview : bool
var button_index : int
var draw_color : Color
var change_made : bool
var control_pressed: bool
var dirty : bool
var dirty_rect : Rect2

onready var Change = preload("res://canvas/Change.gd")

func click(pos: Vector2, event: InputEventMouseButton) -> void:
	drawing = true
	use_preview = false
	change_made = false
	dirty = false
	start_pos = pos
	prev_pos = pos
	
	if event.button_index == BUTTON_LEFT:
		button_index = 0
	elif event.button_index == BUTTON_RIGHT:
		button_index = 1
	control_pressed = event.control
	
	draw_color = Global.colors[button_index]
	
	if Global.Canvas.Select.visible:
		Global.Canvas.Select.confirm_selection()
		
	start(pos)
	draw(pos)


func release(pos: Vector2) -> void:
	if not drawing:
		return
	
	end(pos)
	stop_drawing()


func move(pos: Vector2) -> void:
	if drawing:
		draw(pos)
		prev_pos = pos


func stop_drawing() -> void:
	if not drawing:
		return
	
	drawing = false
	Global.Canvas.image_preview.lock()
	Global.Canvas.image_preview.fill(Color.transparent)
	Global.Canvas.image_preview.unlock()
	Global.Canvas.update_preview()
	
	if change_made:
		var new_image: Image
		var prev_image: Image
		var change_pos: Vector2
		
		if dirty:
			change_pos = dirty_rect.position
			dirty_rect.size += Vector2(1, 1)
			new_image = Global.Canvas.image.get_rect(dirty_rect)
			prev_image = Global.Canvas.prev_image.get_rect(dirty_rect)
		else:
			change_pos = Vector2.ZERO
			new_image = Global.Canvas.image.duplicate()
			prev_image = Global.Canvas.prev_image.duplicate()
		
		var change = Change.new()
		change.action = "blit_image"
		change.params = [new_image, change_pos]
		change.undo_action = "blit_image"
		change.undo_params = [prev_image, change_pos]
		Global.Canvas.make_change(change)


# Drawing functions

func image_draw_start() -> void:
	if use_preview:
		Global.Canvas.image_preview.lock()
		Global.Canvas.image_preview.fill(Color.transparent)
	else:
		Global.Canvas.image.lock()


func image_draw_end() -> void:
	if use_preview:
		Global.Canvas.image_preview.unlock()
		Global.Canvas.update_preview()
	else:
		Global.Canvas.image.unlock()
		Global.Canvas.update_output()


func image_draw_point(pos: Vector2) -> void:
	if not Global.Canvas.image_rect.has_point(pos):
		return
	
	if use_preview:
		Global.Canvas.image_preview.lock()
		Global.Canvas.image_preview.set_pixelv(pos, draw_color)
		Global.Canvas.image_preview.set_pixelv(pos, draw_color)
		Global.Canvas.image_preview.unlock()
	else:
		var new_color := draw_color
		new_color.blend(Global.Canvas.image.get_pixelv(pos))
		Global.Canvas.image.set_pixelv(pos, new_color)
		change_made = true
	
	if dirty:
		dirty_rect = dirty_rect.expand(pos)
	else:
		dirty_rect = Rect2(pos, Vector2(1, 1))
		dirty = true


func image_draw_line(pos1: Vector2, pos2: Vector2) -> void:
	var dx := abs(pos2.x - pos1.x)
	var dy := abs(pos2.y - pos1.y)
	var sx := 1 if pos1.x < pos2.x else -1
	var sy := 1 if pos1.y < pos2.y else -1
	var step := dx - dy
	
	while true:
		image_draw_point(pos1)
		if pos1 == pos2:
			break
		var a := 2 * step
		if a > -dy:
			step -= dy
			pos1.x += sx
		if a < dx:
			step += dx
			pos1.y += sy


func image_draw_rect(pos1: Vector2, pos2: Vector2) -> void:
	image_draw_point(pos1)
	
	var step := sign(pos2.x - pos1.x)
	var i = pos1.x
	
	while i != pos2.x:
		i += step
		image_draw_point(Vector2(i, pos1.y))
		image_draw_point(Vector2(i, pos2.y))
	
	step = sign(pos2.y - pos1.y)
	i = pos1.y
	
	while i != pos2.y:
		i += step
		image_draw_point(Vector2(pos1.x, i))
		image_draw_point(Vector2(pos2.x, i))


func image_draw_ellipse(pos1: Vector2, pos2: Vector2) -> void:
	if pos1 == pos2:
		image_draw_point(pos1)
		return
	
	var top_left := Vector2(min(pos1.x, pos2.x), min(pos1.y, pos2.y))
	var bottom_right := Vector2(max(pos1.x, pos2.x), max(pos1.y, pos2.y))
	var center = ((top_left + bottom_right) / 2).round()
	var even = Vector2(int(top_left.x + bottom_right.x) % 2, int(top_left.y + bottom_right.y) % 2)
	var r = bottom_right - center
	
	if r.x == 0:
		r.x = 1
	if r.y == 0:
		r.y = 1
	
	var x := int(top_left.x)
	while x <= center.x:
		var angle := acos((x - center.x) / r.x)
		var y := round(r.y * sin(angle) + center.y)
		if not is_nan(y):
			image_draw_point(Vector2(x - even.x, y))
			image_draw_point(Vector2(x - even.x, 2 * center.y - y - even.y))
			image_draw_point(Vector2(2 * center.x - x, y))
			image_draw_point(Vector2(2 * center.x - x, 2 * center.y - y - even.y))
		x += 1
	
	# warning-ignore:NARROWING_CONVERSION
	var y := int(top_left.y)
	while y <= center.y:
		var angle := asin((y - center.y) / r.y)
		x = round(r.x * cos(angle) + center.x)
		image_draw_point(Vector2(x, y - even.y))
		image_draw_point(Vector2(2 * center.x - x - even.x, y - even.y))
		image_draw_point(Vector2(x, 2 * center.y - y))
		image_draw_point(Vector2(2 * center.x - x - even.x, 2 * center.y - y))
		y += 1


func image_fill(pos: Vector2, color_replace: Color) -> void:
	if not Global.Canvas.image_rect.has_point(pos):
		return
	
	if ImageTools.image_flood_fill(Global.Canvas.image, pos, color_replace):
		change_made = true


func image_fill_global(pos: Vector2, color_replace: Color) -> void:
	if not Global.Canvas.image_rect.has_point(pos):
		return
	
	change_made = true
	var color_find : Color = Global.Canvas.image.get_pixelv(pos)
	
	for x in Global.Canvas.image_size.x:
		for y in Global.Canvas.image_size.y:
			if ImageTools.colors_match(Global.Canvas.image.get_pixel(x, y), color_find):
				Global.Canvas.image.set_pixel(x, y, color_replace)


func image_grab_color(pos : Vector2) -> void:
	if Global.Canvas.image_rect.has_point(pos):
		Global.Colors.color_set(Global.Canvas.image.get_pixelv(pos), button_index)


# Methods for overriding

func start(_pos : Vector2) -> void:
	pass


func draw(_pos : Vector2) -> void:
	pass


func end(_pos : Vector2) -> void:
	pass


func cancel() -> void:
	pass
