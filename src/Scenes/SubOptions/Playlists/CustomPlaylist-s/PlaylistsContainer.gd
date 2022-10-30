extends Control


#NODES
onready var Title : Label = $HBoxContainer/VBoxContainer/Title
onready var Cover : TextureRect = $HBoxContainer/VBoxContainer/Cover

#VARIABLES
var idx : int = -1


func _on_Playlist_pressed():
	Global.PlaylistPressed = idx
	Global.root.LoadPlaylist(idx)
