extends "res://src/Scenes/Playlists/Options/GeneralPlaylistOptions.gd"

onready var option_vbox : VBoxContainer = $MarginContainer/OptionVBox
onready var playlist_cover : Button = $MarginContainer/OptionVBox/SetPlaylistCover
onready var export_playlist : Button = $MarginContainer/OptionVBox/Export
onready var tag_playlist : Button = $MarginContainer/OptionVBox/TagPlaylist
onready var close : Button = $MarginContainer/OptionVBox/Close

func init_options() -> void:
	var _err : int = playlist_cover.connect("pressed", playlist_root, "change_playlist_cover", [Vector2(145, 145) * 3])
	_err = playlist_cover.connect("pressed", self, "unload_popup")
	
	_err = export_playlist.connect("pressed", playlist_root, "export_playlist")
	_err = export_playlist.connect("pressed", self, "unload_popup")
	
	_err = tag_playlist.connect("pressed", playlist_root, "tag_playlist")
	_err = tag_playlist.connect("pressed", self, "unload_popup")
	
	_err = close.connect("pressed" ,self, "unload_popup")
