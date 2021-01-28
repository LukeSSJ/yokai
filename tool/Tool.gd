extends Button

var drawing : bool
var start_pos : Vector2
var prev_pos : Vector2
var use_preview : bool
var button_index : int
var draw_color : Color
var change_made : bool

func click(pos: Vector2, set_button_index: int) -> void:
	drawing = true
	use_preview = false
	change_made = false
	start_pos = pos
	prev_pos = pos
	button_index = set_button_index
	draw_color = Global.colors[button_index]
	if Global.Canvas.Select.visible:
		Global.Canvas.Select.confirm_selection()
	start(pos)
	draw(pos)

func release(pos: Vector2) -> void:
	if !drawing:
		return
	end(pos)
	cancel_drawing()
	

func move(pos: Vector2) -> void:
	if drawing:
		draw(pos)
		prev_pos = pos

func cancel_drawing():
	if drawing:
		drawing = false
		Global.Canvas.image_preview.lock()
		Global.Canvas.image_preview.fill(Color.transparent)
		Global.Canvas.image_preview.unlock()
		Global.Canvas.update_preview()
		if change_made:
			Global.Canvas.undo_add()

# Drawing functions

func image_draw_start() -> void:
	change_made = true
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
#	pos = pos.round()
	if Global.Canvas.image_rect.has_point(pos):
		if use_preview:
			Global.Canvas.image_preview.lock()
			Global.Canvas.image_preview.set_pixelv(pos, draw_color)
			Global.Canvas.image_preview.unlock()
		else:
			Global.Canvas.image.set_pixelv(pos, draw_color)

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
	
#	for x in range(top_left.x, center.x):
	var x := int(top_left.x)
	while x <= center.x:
		var angle := acos((x - center.x) / r.x)
		var y := round(r.y * sin(angle) + center.y)
		if !is_nan(y):
			image_draw_point(Vector2(x - even.x, y))
			image_draw_point(Vector2(x - even.x, 2 * center.y - y - even.y))
			image_draw_point(Vector2(2 * center.x - x, y))
			image_draw_point(Vector2(2 * center.x - x, 2 * center.y - y - even.y))
		x += 1
#	for y in range(top_left.y, center.y):
	var y := int(top_left.y)
	while y <= center.y:
		var angle := asin((y - center.y) / r.y)
		x = round(r.x * cos(angle) + center.x)
		image_draw_point(Vector2(x, y - even.y))
		image_draw_point(Vector2(2 * center.x - x - even.x, y - even.y))
		image_draw_point(Vector2(x, 2 * center.y - y))
		image_draw_point(Vector2(2 * center.x - x - even.x, 2 * center.y - y))
		y += 1

func image_draw_ellipse_old(pos1: Vector2, pos2: Vector2) -> void:
	var pos := pos1.linear_interpolate(pos2, 0.5)
	var r := ((pos1 - pos2).abs() / 2)
	var x : float = 0
	var y : float = r.y
	var d1 := (r.y * r.y) - (r.x * r.x * r.y) + (0.25 * r.x * r.x)
	var dx := 2 * r.y * r.y * x
	var dy := 2 * r.x * r.x * y
	
	var xmin = 999
	var xmax = 0
	
	while dx < dy:
		image_draw_point(Vector2(x + pos.x, y + pos.y))
		image_draw_point(Vector2(-x + pos.x, y + pos.y))
		image_draw_point(Vector2(x + pos.x, -y + pos.y))
		image_draw_point(Vector2(-x + pos.x, -y + pos.y))
		if d1 < 0:
			x += 1
			dx += 2 * r.y * r.y
			d1 += dx + (r.y * r.y)
		else:
			x += 1
			y -= 1
			dx += 2 * r.y * r.y
			dy -= 2 * r.x * r.x
			d1 += dx - dy + (r.y * r.y)
	
	var d2 := ((r.y * r.y) * ((x + 0.5) * (x + 0.5))) + ((r.x * r.x) * ((y - 1) * (y - 1))) - (r.x * r.x * r.y * r.y)
	
	while y >= 0:
		image_draw_point(Vector2(x + pos.x, y + pos.y))
		image_draw_point(Vector2(-x + pos.x, y + pos.y))
		image_draw_point(Vector2(x + pos.x, -y + pos.y))
		image_draw_point(Vector2(-x + pos.x, -y + pos.y))
		xmin = min(xmin, -x + pos.x)
		xmax = max(xmax, x + pos.x)
		if d2 > 0:
			y -= 1
			dy = dy - (2 * r.x * r.x)
			d2 = d2 + (r.x * r.x) - dy
		else:
			y -= 1
			x += 1
			dx = dx + (2 * r.y * r.y)
			dy = dy - (2 * r.x * r.x)
			d2 = d2 + dx - dy + (r.x * r.x)
	print(xmin)
	print(xmax)

func image_fill(pos: Vector2, color_replace: Color) -> void:
	if Global.Canvas.image_rect.has_point(pos):
		var color_find = Global.Canvas.image.get_pixelv(pos)
		if color_find != color_replace:
			image_fill_recur(pos, color_find, color_replace)
	
func image_fill_recur(pos: Vector2, color_find: Color, color_replace: Color) -> void:
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
