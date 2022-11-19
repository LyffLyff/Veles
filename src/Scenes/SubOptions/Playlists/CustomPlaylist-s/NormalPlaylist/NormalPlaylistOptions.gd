extends "res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/GeneralPlaylistOptions.gd"

onready var PlaylistCover : Button = $NormalPlaylistOptions/HBoxContainer/OptionVBox/SetPlaylistCover
onready var QueuePlaylist : Button = $NormalPlaylistOptions/HBoxContainer/OptionVBox/QueuePlaylist
onready var DeletePlaylist : Button = $NormalPlaylistOptions/HBoxContainer/OptionVBox/DeletePlaylist
onready var ExportPlaylist : Button = $NormalPlaylistOptions/HBoxContainer/OptionVBox/Export
onready var rename : Button = $NormalPlaylistOptions/HBoxContainer/OptionVBox/Rename
onready var Return : Button = $NormalPlaylistOptions/HBoxContainer/OptionVBox/ToPlaylists
onready var close : Button = $NormalPlaylistOptions/HBoxContainer/OptionVBox/Close


func ConnectOptionSignals() -> void:
	var _err = Return.connect("pressed",self.get_owner(),"UnloadPlaylist")
	_err = PlaylistCover.connect("pressed",self.get_owner(),"OnSetCoverPressed")
	
	#Queueing Playlist
	_err = QueuePlaylist.connect("pressed",self.get_owner(),"OnQueuePlaylistPressed")
	_err = QueuePlaylist.connect("pressed",self,"UnloadPlaylistOptions")
	
	_err = ExportPlaylist.connect("pressed",self.get_owner(),"ExportPlaylist")
	_err = rename.connect("pressed", self.get_owner(), "rename_playlist")
	_err = DeletePlaylist.connect("pressed",self.get_owner(),"OnDeletePressed")
	_err = close.connect("pressed",self,"UnloadPlaylistOptions")
