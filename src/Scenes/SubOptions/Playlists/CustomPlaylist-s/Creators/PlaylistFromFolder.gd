extends "res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/Creators/PlaylistCreatorMain.gd"


#NODES
onready var Title : HBoxContainer = $Panel/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/Title
onready var Cover : HBoxContainer = $Panel/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/Cover
onready var Folder : HBoxContainer = $Panel/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/FolderPath


func on_save_pressed() -> void:
	var PFolder : String = Folder.input_edit.get_text()
	var PTitle : String = Title.input_edit.get_text()
	var PCoverPath : String = Cover.input_edit.get_text()
	emit_signal("Save",PTitle,PCoverPath,PFolder,{})
	exit_popup()
