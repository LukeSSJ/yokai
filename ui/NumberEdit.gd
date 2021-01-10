extends LineEdit

func _ready():
	self.connect("text_entered", self, "force_int")
	self.connect("focus_exited", self, "force_int")

func force_int(_val=null):
	text = str(text.to_int())
