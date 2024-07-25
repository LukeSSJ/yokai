extends Node

var main : Node

func assert_true(condition: bool):
	Testing.assertion_made(condition)
	if not condition:
		printerr("Assertion failed")
