extends Node

var canvas
var action := ""
var params := []
var undo_action := ""
var undo_params = []

func apply():
	canvas.callv(action, params)

func undo():
	canvas.callv(undo_action, undo_params)
