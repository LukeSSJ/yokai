extends LineEdit

func force_int(_val = null) -> void:
	var expression := Expression.new()
	expression.parse(text)
	
	var result := int(expression.execute())
	text = str(result)
