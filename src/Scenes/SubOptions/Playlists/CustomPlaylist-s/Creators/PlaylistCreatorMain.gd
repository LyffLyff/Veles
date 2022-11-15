extends "res://src/Scenes/General/StdPopupBackground.gd"

#SIGNALS
signal Close
signal Save


func on_close_pressed() -> void:
	emit_signal("Close")
	exit_popup()

