extends "res://src/Scenes/Playlists/General/PlaylistLoader.gd"

var playlist_title : String = ""
var playlist_cover_path : String = ""
var description_path : String = ""

onready var scroller : ScrollContainer = $VBoxContainer/ScrollContainer
onready var header : PanelContainer = $VBoxContainer/ScrollContainer/VBoxContainer/PlaylistHeader
onready var filter : Control = $VBoxContainer/ScrollContainer/VBoxContainer/SongFilters


func _notification(what):
	if what == NOTIFICATION_WM_FOCUS_IN:
		scroller.mouse_filter = Control.MOUSE_FILTER_PASS
	elif what == NOTIFICATION_WM_FOCUS_OUT:
		scroller.mouse_filter = Control.MOUSE_FILTER_IGNORE


func init_playlist(var custom_cover_path : String = "") -> void:
	songs = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer/SongVbox
	song_highlighter = $SongHighlighter
	song_scroller = scroller
	songs.playlist_root = self
	songs.playlist_root_rect = self.get_global_rect()
	scroller.get_v_scrollbar().step = 0.1
	playlist_title = Playlist.get_playlist_name(Global.pressed_playlist_idx)
	playlist_idx = Global.pressed_playlist_idx
	
	# connect signals
	header.play.connect("pressed", self, "on_songspace_left_clicked", [0])
	songs.init_song_scroller()
	var _err = scroller.get_v_scrollbar().connect("mouse_entered", song_highlighter, "set_visible", [false])
	
	connect_song_vbox()
	
	if custom_cover_path != "":
		playlist_cover_path = custom_cover_path
	else:
		playlist_cover_path = Global.get_current_user_data_folder() + "/Songs/Playlists/Covers/" + playlist_title + ".png"
	
	init_header()
	
	if playlist_idx <= -3:
		# smart playlist
		load_songs(get_smart_playlist_songs(load_playlist_conditions()))
		filter.hide()
	elif playlist_idx == -1:
		# my music / all songs
		load_songs(get_smart_playlist_songs({}))
		header.hide()
	elif playlist_idx >= 0:
		# normal/standard playlist
		filter.hide()
		load_songs(get_normal_playlist_songs())
	else:
		# temporary playlist -> init_temp_playlist needs to be called for songs to be loaded
		filter.hide()
		pass
	
	# colors
	self.get_stylebox("panel").set_bg_color(header.bottom_blur.material.get("shader_param/color"))
	
	# various
	scroller.get_v_scrollbar().rect_min_size.x = 5


func init_temporary_playlist(var conditions : Dictionary, var title : String, var custom_description_path : String, var cover_path : String) -> void:
	playlist_title = title
	description_path = custom_description_path
	playlist_cover_path = cover_path
	load_songs(get_smart_playlist_songs(conditions))
	init_header()


func init_header() -> void:
	# general
	header.title_label.text = playlist_title
	header.creation_date_label.text = get_playlist_creation_date()
	header.playlist_duration_label.text = get_playlist_runtime()
	header.song_amount_label.text = str(get_playlist_song_amount())
	header.set_header_cover(ImageLoader.get_cover(playlist_cover_path))
	
	if playlist_idx < -1:
		header.description.load_description(description_path)
	else:
		header.description.hide()


func load_songs(var song_idxs : PoolIntArray) -> void:
	var x : SongLoader = SongLoader.new()
	x.create_songspaces(songs, song_idxs, Global.pressed_playlist_idx)


func load_playlist_conditions() -> Dictionary:
	var temp = SaveData.load_data(Global.get_current_user_data_folder() + "/Songs/Playlists/SmartPlaylists/Conditions/" + playlist_title + ".dat")
	if temp:
		return temp
	return Dictionary()


func get_smart_playlist_songs(var conditions : Dictionary) -> PoolIntArray:
	var condition_functions : SmartPlaylistConditions = SmartPlaylistConditions.new()
	var is_valid_song : bool = true
	var temp_song_path : String = ""
	var song_idxs : PoolIntArray = []
	var temp_smart_playlist : Dictionary = {}
	
	# going through AllSongs
	for x in SongLists.AllSongs.size():
		is_valid_song = true
		temp_song_path = SongLists.AllSongs.keys()[x]
		# checking Conditions
		for y in conditions.size():
			for z in conditions.values()[y].size():
				if !condition_functions.call(conditions.keys()[y], temp_song_path, conditions.values()[y][z]):
					is_valid_song = false
					break;
		
		# adding Songs to return Array if the Conditions are met
		if is_valid_song:
			temp_smart_playlist[temp_song_path] = false
			song_idxs.push_back(x)
	
	# setting the Currently "created" Playlist in a Global Dictionary
	# the Playlist has only been loaded, but is not the one currently playing
	SongLists.pressed_temporary_playlist = temp_smart_playlist
	
	# returning All Songs that fit the Current Description
	return song_idxs;


func get_normal_playlist_songs() -> PoolIntArray:
	var idxs_to_set : PoolIntArray = []
	var temp_path : String = ""
	var temp_main_idx : int = -1
	for n in SongLists.normal_playlists.values()[playlist_idx].size():
		temp_path = SongLists.normal_playlists.values()[playlist_idx].keys()[n]
		temp_main_idx = AllSongs.get_main_idx(temp_path)
		idxs_to_set.push_back(temp_main_idx)
	return idxs_to_set


func _on_NewPlaylist_resized():
	if songs:
		songs.playlist_root_rect = self.get_global_rect()


func on_delete_smart_playlist_pressed():
	SongLists.smart_playlists.erase(playlist_title)
	ExtendedDirectory.delete_file(Global.get_current_user_data_folder() + "/Songs/Playlists/Covers/" + playlist_title + ".png")
	ExtendedDirectory.delete_file(Global.get_current_user_data_folder() + "/Songs/Playlists/Metadata/Descriptions/" + playlist_title + ".txt")
	unload_playlist()


func on_delete_pressed():
	var playlist_key : String = SongLists.normal_playlists.keys()[playlist_idx]
	if !SongLists.normal_playlists.erase(playlist_key):
		Global.root.message("DELETIING PLAYLIST COVER FROM USER DATA",  SaveData.MESSAGE_ERROR )
	ExtendedDirectory.delete_file(OS.get_user_data_dir() + "/Songs/Playlists/Covers/" + playlist_key + ".png")
	SaveData.erase_key_from_file(SongLists.file_paths[9],playlist_key)
	unload_playlist()


func _on_queue_playlist_pressed() -> void:
	# queueing all the Songs in trhe Current Playlist
	for n in SongLists.normal_playlists.values()[playlist_idx].size():
		SongLists.queue_song(SongLists.normal_playlists.values()[playlist_idx].keys()[n])
