extends LineEdit

func force_int(_val = null) -> void:
	if not text:
		return
	
	var expression := Expression.new()
	if expression.parse(text) != OK:
		return
	
	var result = expression.execute([], null, false)
	if expression.has_execute_failed():
		return
	
	text = str(int(result))
