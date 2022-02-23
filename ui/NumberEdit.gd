extends LineEdit

func _ready():
	self.connect("focus_entered", self, "select_all")
	self.connect("text_entered", self, "force_int")
	self.connect("focus_exited", self, "force_int")

func force_int(_val=null):
	var expression := Expression.new()
	expression.parse(text)
	var result := int(expression.execute())
	text = str(result)
