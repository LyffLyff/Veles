extends "res://src/Scenes/SubOptions/Playlists/PlaylistLoader.gd"


#NODES
onready var SongFilter : Control = $HBoxContainer/VBoxContainer/SongFilters


func _ready():
	Global.PlaylistPressed = -1
	if SongFilter.connect("filter_status",SongScroller,"SetFilterStatus"):
		Global.root.message("Connecting Song filters with ScrollContainer",  SaveData.MESSAGE_ERROR )
	#Child one and two of ScrollContainer are the Scrollbars
	songs = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller/Songs
	SongScroller = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller
	SongHighlighter = $SongHighlighter
	var _err = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller.connect("SpeedThresholdExceeded",self,"set_deferred", ["ScrollingFast",true])
	_err = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller.connect("SpeedThresholdSubceeded",self,"set_deferred", ["ScrollingFast",false])
	ConnectScrollContainer()
	#if Global.InitializeSongs:
	var x : SongLoader = SongLoader.new()
	if Global.InitializeSongs:
		x.Reload()
		Global.InitializeSongs = false
	x.CreateSongsSpaces(songs)
	root.update_highlighted_song(SongLists.CurrentSong)
