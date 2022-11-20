extends "res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/GeneralPlaylistOptions.gd"

onready var playlist_cover : Button = $NormalPlaylistOptions/HBoxContainer/OptionVBox/SetPlaylistCover
onready var queue_playlist : Button = $NormalPlaylistOptions/HBoxContainer/OptionVBox/QueuePlaylist
onready var delete_playlist : Button = $NormalPlaylistOptions/HBoxContainer/OptionVBox/DeletePlaylist
onready var export_playlist : Button = $NormalPlaylistOptions/HBoxContainer/OptionVBox/Export
onready var rename : Button = $NormalPlaylistOptions/HBoxContainer/OptionVBox/Rename
onready var return_to_playlists : Button = $NormalPlaylistOptions/HBoxContainer/OptionVBox/ToPlaylists
onready var close : Button = $NormalPlaylistOptions/HBoxContainer/OptionVBox/Close


func connect_option_signals() -> void:
	var _err = return_to_playlists.connect("pressed",self.get_owner(),"unload_playlist")
	_err = playlist_cover.connect("pressed",self.get_owner(),"on_set_cover_pressed")
	
	# queueing Playlist
	_err = queue_playlist.connect("pressed",self.get_owner(),"_on_queue_playlist_pressed")
	_err = queue_playlist.connect("pressed",self,"unload_playlist_options")
	
	_err = export_playlist.connect("pressed",self.get_owner(),"export_playlist")
	_err = rename.connect("pressed", self.get_owner(), "rename_playlist")
	_err = delete_playlist.connect("pressed",self.get_owner(),"on_delete_pressed")
	_err = close.connect("pressed",self,"unload_playlist_options")
