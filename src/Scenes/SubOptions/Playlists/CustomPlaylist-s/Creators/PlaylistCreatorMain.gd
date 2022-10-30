extends "res://src/Scenes/General/StdPopupBackground.gd"

#SIGNALS
signal Close
signal Save


func OnClosePressed() -> void:
	emit_signal("Close")
	ExitPopup()

