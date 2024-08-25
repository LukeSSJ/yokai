extends Node

var canvas: Node
var action := ""
var params := []
var undo_action := ""
var undo_params := []

func apply() -> void:
	canvas.callv(action, params)


func undo() -> void:
	canvas.callv(undo_action, undo_params)
