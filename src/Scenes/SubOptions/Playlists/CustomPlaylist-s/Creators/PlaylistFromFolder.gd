extends "res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/Creators/PlaylistCreatorMain.gd"

onready var title : HBoxContainer = $Panel/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/Title
onready var cover_hbox : HBoxContainer = $Panel/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/Cover
onready var folder : HBoxContainer = $Panel/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/FolderPath


func on_save_pressed() -> void:
	var p_folder : String = folder.input_edit.get_text()
	var p_title : String = title.input_edit.get_text()
	var p_coverpath : String = cover_hbox.input_edit.get_text()
	emit_signal("save", p_title, p_coverpath, p_folder,{})
	exit_popup()
