extends "res://src/Scenes/General/StdPopupBackground.gd"

#SIGNALS
signal close
signal save


func on_close_pressed() -> void:
	emit_signal("close")
	exit_popup()

