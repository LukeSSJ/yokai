extends Button

export var tool_script: Script

func clicked():
	Command.tool_set(name)
