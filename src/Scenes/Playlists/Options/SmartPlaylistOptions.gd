extends "res://src/Scenes/Playlists/Options/GeneralPlaylistOptions.gd"

onready var option_vbox : VBoxContainer = $MarginContainer/OptionVBox
onready var return_to_playlists : Button = $MarginContainer/OptionVBox/ToPlaylists
onready var playlist_cover : Button = $MarginContainer/OptionVBox/SetPlaylistCover
onready var rename : Button = $MarginContainer/OptionVBox/Rename
onready var export_playlist : Button = $MarginContainer/OptionVBox/Export
onready var delete_playlist : Button = $MarginContainer/OptionVBox/DeletePlaylist
onready var edit_conditions : Button = $MarginContainer/OptionVBox/EditConditions
onready var tag_playlist : Button = $MarginContainer/OptionVBox/TagPlaylist
onready var close : Button = $MarginContainer/OptionVBox/Close

func init_options() -> void:
	var _err = return_to_playlists.connect("pressed", playlist_root, "unload")
	_err = return_to_playlists.connect("pressed", self, "unload_popup")
	
	_err = playlist_cover.connect("pressed", playlist_root, "change_playlist_cover")
	_err = playlist_cover.connect("pressed", self, "unload_popup")
	
	_err = rename.connect("pressed", playlist_root, "rename_playlist")
	_err = rename.connect("pressed", self, "unload_popup")
	
	_err = export_playlist.connect("pressed", playlist_root, "export_playlist")
	_err = export_playlist.connect("pressed", self, "unload_popup")
	
	_err = delete_playlist.connect("pressed", playlist_root, "on_delete_smart_playlist_pressed")
	_err = delete_playlist.connect("pressed", self, "unload_popup")
	
	_err = edit_conditions.connect("pressed", playlist_root, "on_edit_playlist_conditions_pressed")
	_err = edit_conditions.connect("pressed", self, "unload_popup")
	
	_err = tag_playlist.connect("pressed", playlist_root, "tag_playlist")
	_err = tag_playlist.connect("pressed", self, "unload_popup")
	
	_err = close.connect("pressed", self, "unload_popup")
