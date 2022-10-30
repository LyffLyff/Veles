extends "res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/Creators/PlaylistCreatorMain.gd"


#NODES
onready var Title : LineEdit = $Panel/VBoxContainer2/Main/Name/InputEdit
onready var Cover : HBoxContainer = $Panel/VBoxContainer2/Main/Cover


func OnSavePressed() -> void:
	emit_signal("Save",Title.get_text(),Cover.InputEdit.get_text(),"",{})
	OnClosePressed()
