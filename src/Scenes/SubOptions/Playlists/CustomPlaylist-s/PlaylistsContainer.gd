extends Control

var idx : int = -1

onready var title : Label = $HBoxContainer/VBoxContainer/Title
onready var cover : TextureRect = $HBoxContainer/VBoxContainer/Cover

func _on_Playlist_pressed():
	Global.pressed_playlist_idx = idx
	Global.root.load_playlist(idx)
