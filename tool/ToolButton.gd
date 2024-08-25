extends Button

@export var tool_script: Script

func clicked() -> void:
	Command.tool_set(name)
