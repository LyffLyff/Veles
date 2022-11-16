extends "res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/Creators/PlaylistCreatorMain.gd"


#NODES
onready var Title : LineEdit = $Panel/VBoxContainer2/Main/Name/InputEdit
onready var Cover : HBoxContainer = $Panel/VBoxContainer2/Main/Cover


func on_save_pressed() -> void:
	emit_signal("save",Title.get_text(),Cover.input_edit.get_text(),"",{})
	on_close_pressed()
