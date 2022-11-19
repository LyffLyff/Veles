extends "res://src/Scenes/SubOptions/Playlists/PlaylistLoader.gd"


#NODES
onready var SongFilter : Control = $HBoxContainer/VBoxContainer/SongFilters


func _ready():
	Global.pressed_playlist_idx = -1
	if SongFilter.connect("is_filtering",SongScroller,"SetFilterStatus"):
		Global.root.message("Connecting Song filters with ScrollContainer",  SaveData.MESSAGE_ERROR )
	#child one and two of ScrollContainer are the Scrollbars
	songs = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller/Songs
	SongScroller = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller
	SongHighlighter = $SongHighlighter
	var _err = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller.connect("SpeedThresholdExceeded",self,"set_deferred", ["ScrollingFast",true])
	_err = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller.connect("SpeedThresholdSubceeded",self,"set_deferred", ["ScrollingFast",false])
	ConnectScrollContainer()
	#if Global.init_songs:
	var x : SongLoader = SongLoader.new()
	if Global.init_songs:
		x.reload()
		Global.init_songs = false
	x.create_songspaces(songs)
	root.update_highlighted_song(SongLists.current_song)
