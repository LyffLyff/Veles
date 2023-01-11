extends "res://src/Scenes/SubOptions/PlaylistGrid/CustomPlaylist-s/GeneralPlaylistOptions.gd"

onready var option_vbox : VBoxContainer = $HBoxContainer/OptionVBox
onready var return_to_playlists : Button = $HBoxContainer/OptionVBox/ToPlaylists
onready var playlist_cover : Button = $HBoxContainer/OptionVBox/SetPlaylistCover
onready var rename : Button = $HBoxContainer/OptionVBox/Rename
onready var export_playlist : Button = $HBoxContainer/OptionVBox/Export
onready var delete_playlist : Button = $HBoxContainer/OptionVBox/DeletePlaylist
onready var close : Button = $HBoxContainer/OptionVBox/Close

func init_options() -> void:
	var _err = return_to_playlists.connect("pressed", self.get_owner(), "unload")
	_err = playlist_cover.connect("pressed", self.get_owner(), "change_playlist_cover")
	_err = rename.connect("pressed", self.get_owner(), "rename_playlist")
	_err = export_playlist.connect("pressed", self.get_owner(), "export_playlist")
	_err = delete_playlist.connect("pressed", self.get_owner(), "on_delete_smart_playlist_pressed")
	_err = close.connect("pressed" ,self, "unload_playlist_options")
