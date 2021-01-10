extends Node

var drawing
var start_pos
var prev_pos
var use_preview
var button_index
var draw_color
var change_made

func click(pos, set_button_index):
	drawing = true
	use_preview = false
	change_made = false
	start_pos = pos
	prev_pos = pos
	button_index = set_button_index
	draw_color = Global.colors[button_index]
	start(pos)
	draw(pos)

func release(pos):
	if !drawing:
		return
	drawing = false
	end(pos)
	Global.Canvas.image_preview.lock()
	Global.Canvas.image_preview.fill(Color.transparent)
	Global.Canvas.image_preview.unlock()
	if change_made:
		Global.Canvas.undo_add()

func move(pos):
	if drawing:
		draw(pos)
		prev_pos = pos

# Drawing functions

func image_draw_start():
	change_made = true
	if use_preview:
		Global.Canvas.image_preview.lock()
		Global.Canvas.image_preview.fill(Color.transparent)
	else:
		Global.Canvas.image.lock()
	
func image_draw_end():
	if use_preview:
		Global.Canvas.image_preview.unlock()
		Global.Canvas.update_preview()
	else:
		Global.Canvas.image.unlock()
		Global.Canvas.update_output()

func image_draw_point(pos):
	if pos.x >= 0 and pos.y >= 0 and pos.x < Global.Canvas.image_size.x and pos.y < Global.Canvas.image_size.y:
		if use_preview:
			Global.Canvas.image_preview.lock()
			Global.Canvas.image_preview.set_pixelv(pos, draw_color)
			Global.Canvas.image_preview.unlock()
		else:
			Global.Canvas.image.set_pixelv(pos, draw_color)

func image_draw_line(pos1, pos2):
	var dx = pos2.x - pos1.x
	var dy = pos2.y - pos1.y
	var step = max(abs(dx), abs(dy))
	if step == 0:
		image_draw_point(pos1)
	else:
		dx /= step
		dy /= step
		for _i in range(1, step + 1):
			image_draw_point(pos1)
			pos1.x += dx
			pos1.y += dy

func image_draw_rect(pos1, pos2):
	image_draw_point(pos1)
	var step = sign(pos2.x - pos1.x)
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

func image_fill(pos, color_replace):
	if pos.x >= 0 and pos.y >= 0 and pos.x < Global.Canvas.image_size.x and pos.y < Global.Canvas.image_size.y:
		var color_find = Global.Canvas.image.get_pixelv(pos)
		if color_find != color_replace:
			image_fill_recur(pos, color_find, color_replace)
	
func image_fill_recur(pos, color_find, color_replace):
	if Global.Canvas.image.get_pixelv(pos) == color_find:
		Global.Canvas.image.set_pixelv(pos, color_replace)
		if pos.x > 0:
			image_fill_recur(Vector2(pos.x - 1, pos.y), color_find, color_replace)
		if pos.x < Global.Canvas.image_size.x - 1:
			image_fill_recur(Vector2(pos.x + 1, pos.y), color_find, color_replace)
		if pos.y > 0:
			image_fill_recur(Vector2(pos.x, pos.y - 1), color_find, color_replace)
		if pos.y < Global.Canvas.image_size.y - 1:
			image_fill_recur(Vector2(pos.x, pos.y + 1), color_find, color_replace)

func image_grab_color(pos):
	if pos.x >= 0 and pos.y >= 0 and pos.x < Global.Canvas.image_size.x and pos.y < Global.Canvas.image_size.y:
		Global.Main.color_changed(Global.Canvas.image.get_pixelv(pos), button_index)

# Methods for overriding

func start(_pos):
	pass

func draw(_pos):
	pass

func end(_pos):
	pass
