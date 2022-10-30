extends "res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/Creators/PlaylistCreatorMain.gd"


#NODES
onready var Title : HBoxContainer = $Panel/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/Title
onready var Cover : HBoxContainer = $Panel/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/Cover
onready var Folder : HBoxContainer = $Panel/HBoxContainer/VBoxContainer/HBoxContainer/VBoxContainer/FolderPath


func OnSavePressed() -> void:
	var PFolder : String = Folder.InputEdit.get_text()
	var PTitle : String = Title.InputEdit.get_text()
	var PCoverPath : String = Cover.InputEdit.get_text()
	emit_signal("Save",PTitle,PCoverPath,PFolder,{})
	ExitPopup()
