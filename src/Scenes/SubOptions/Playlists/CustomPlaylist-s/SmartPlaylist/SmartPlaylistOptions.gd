extends "res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/GeneralPlaylistOptions.gd"

onready var OptionVBox : VBoxContainer = $PanelContainer/HBoxContainer/OptionVBox
onready var Return : Button = $PanelContainer/HBoxContainer/OptionVBox/ToPlaylists
onready var PlaylistCover : Button = $PanelContainer/HBoxContainer/OptionVBox/SetPlaylistCover
onready var rename : Button = $PanelContainer/HBoxContainer/OptionVBox/Rename
onready var Export : Button = $PanelContainer/HBoxContainer/OptionVBox/Export
onready var DeletePlaylist : Button = $PanelContainer/HBoxContainer/OptionVBox/DeletePlaylist
onready var close : Button = $PanelContainer/HBoxContainer/OptionVBox/Close

func ConnectOptionSignals() -> void:
	var _err = Return.connect("pressed",self.get_owner(),"UnloadPlaylist")
	_err = PlaylistCover.connect("pressed",self.get_owner(),"OnSetCoverPressed")
	_err = rename.connect("pressed", self.get_owner(), "rename_playlist")
	_err = Export.connect("pressed", self.get_owner(), "ExportPlaylist")
	_err = DeletePlaylist.connect("pressed",self.get_owner(),"OnDeleteSmartPlaylistpressed")
	_err = close.connect("pressed",self,"UnloadPlaylistOptions")
