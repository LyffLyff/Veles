extends Control


#NODES
onready var title : Label = $HBoxContainer/VBoxContainer/Title
onready var Cover : TextureRect = $HBoxContainer/VBoxContainer/Cover

#VARIABLES
var idx : int = -1


func _on_Playlist_pressed():
	Global.pressed_playlist_idx = idx
	Global.root.load_playlist(idx)
