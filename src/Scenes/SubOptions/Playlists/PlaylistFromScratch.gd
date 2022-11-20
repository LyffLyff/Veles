extends "res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/Creators/PlaylistCreatorMain.gd"

onready var title : LineEdit = $Panel/VBoxContainer2/Main/Name/InputEdit
onready var cover_hbox : HBoxContainer = $Panel/VBoxContainer2/Main/Cover

func _on_Save_pressed() -> void:
	emit_signal("save",title.get_text(), cover_hbox.input_edit.get_text(), "", {})
	on_close_pressed()
