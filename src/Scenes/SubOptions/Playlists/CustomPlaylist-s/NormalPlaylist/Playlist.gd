extends "res://src/Scenes/SubOptions/Playlists/PlaylistLoader.gd"

onready var scroll : ScrollContainer = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller
onready var header : PanelContainer = $HBoxContainer/VBoxContainer/Header
onready var song_amount_label : Label = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Songs/Amount
onready var creation_date_label : Label = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Creation/Date
onready var runtime_label : Label = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Length/Time

func _ready():
	var _err = scroll.get_v_scrollbar().connect("value_changed",self,"on_scroll_value_changed")
	playlist_idx = Global.pressed_playlist_idx
	playlist_options = $HBoxContainer/VBoxContainer/Header/HBoxContainer/PlaylistOptions
	songs = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller/Songs
	song_highlighter = $SongHighlighter
	header_cover = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer2/Cover
	infos = [
		$HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Creation,
		$HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Songs,
		$HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Length
	]
	var idxs_to_set : PoolIntArray = []
	var temp_path : String = ""
	var temp_main_idx : int = 0
	for n in SongLists.normal_playlists.values()[playlist_idx].size():
		temp_path = SongLists.normal_playlists.values()[playlist_idx].keys()[n]
		temp_main_idx = AllSongs.get_main_idx(temp_path)
		idxs_to_set.push_back(temp_main_idx)
	if idxs_to_set.size() > 0:
		# calling this function with empty Array would load all songs
		var x : SongLoader = SongLoader.new()
		x.create_songspaces(songs, idxs_to_set, playlist_idx)
	connect_scroll_container()
	title = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Title
	var playlist_name : String = Playlist.get_playlist_name(playlist_idx)
	title.set_text(playlist_name)
	
	# setting the header Cover
	var playlist_cover_path : String = Global.get_current_user_data_folder() + "/Songs/Playlists/Covers/" + Playlist.get_playlist_name(playlist_idx) + ".png"
	header_cover.texture = ImageLoader.get_cover(playlist_cover_path,playlist_name)
	
	# setting header Info
	song_amount_label.text = str( get_playlist_song_amount() )
	creation_date_label.text = get_playlist_creation_date()
	runtime_label.text = get_playlist_runtime()


func on_cover_selected(var img_src : String):
	# saving Cover Copy in User Data
	header_cover.texture = Playlist.copy_playlist_cover(img_src, playlist_idx, true)


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
		SongLists.queue_song( SongLists.normal_playlists.values()[playlist_idx].keys()[n] )
