extends "res://src/Scenes/SubOptions/Playlists/PlaylistLoader.gd"

onready var song_filter : Control = $HBoxContainer/VBoxContainer/SongFilters

func _ready():
	Global.pressed_playlist_idx = -1
	if song_filter.connect("is_filtering",song_scroller,"set_filter_status"):
		Global.root.message("Connecting Song filters with ScrollContainer",  SaveData.MESSAGE_ERROR )
	#child one and two of ScrollContainer are the Scrollbars
	songs = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller/Songs
	song_scroller = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller
	song_highlighter = $SongHighlighter
	var _err = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller.connect("speed_threshold_exceeded",self,"set_deferred", ["is_scrolling_fast",true])
	_err = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller.connect("speed_threshold_subceeded",self,"set_deferred", ["is_scrolling_fast",false])
	ConnectScrollContainer()
	# if Global.init_songs:
	var x : SongLoader = SongLoader.new()
	if Global.init_songs:
		x.reload()
		Global.init_songs = false
	x.create_songspaces(songs)
	Global.root.update_highlighted_song(SongLists.current_song)
