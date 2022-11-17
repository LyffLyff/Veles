extends "res://src/Scenes/General/StdPopupBackground.gd"

onready var rename : Button = $HBoxContainer/VBoxContainer/Rename
onready var change_cover : Button = $HBoxContainer/VBoxContainer/ChangeCover
onready var delete : Button = $HBoxContainer/VBoxContainer/Delete

func _process(var _delta : float):
	if !self.get_global_rect().has_point(get_global_mouse_position()):
		exit_popup()
