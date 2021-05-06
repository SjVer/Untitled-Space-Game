extends Node

var mouseHidden : bool = true


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	#print_tree_pretty()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if mouseHidden == true:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			mouseHidden = false
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouseHidden = true
