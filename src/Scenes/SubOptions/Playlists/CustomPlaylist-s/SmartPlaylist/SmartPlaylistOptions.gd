extends "res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/GeneralPlaylistOptions.gd"

onready var option_vbox : VBoxContainer = $PanelContainer/HBoxContainer/OptionVBox
onready var return_to_playlists : Button = $PanelContainer/HBoxContainer/OptionVBox/ToPlaylists
onready var playlist_cover : Button = $PanelContainer/HBoxContainer/OptionVBox/SetPlaylistCover
onready var rename : Button = $PanelContainer/HBoxContainer/OptionVBox/Rename
onready var export_playlist : Button = $PanelContainer/HBoxContainer/OptionVBox/Export
onready var delete_playlist : Button = $PanelContainer/HBoxContainer/OptionVBox/DeletePlaylist
onready var close : Button = $PanelContainer/HBoxContainer/OptionVBox/Close

func connect_option_signals() -> void:
	var _err = return_to_playlists.connect("pressed", self.get_owner(), "unload_playlist")
	_err = playlist_cover.connect("pressed", self.get_owner(), "on_set_cover_pressed")
	_err = rename.connect("pressed", self.get_owner(), "rename_playlist")
	_err = export_playlist.connect("pressed", self.get_owner(), "export_playlist")
	_err = delete_playlist.connect("pressed", self.get_owner(), "on_delete_smart_playlist_pressed")
	_err = close.connect("pressed" ,self, "unload_playlist_options")
