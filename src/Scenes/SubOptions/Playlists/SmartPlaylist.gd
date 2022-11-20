extends "res://src/Scenes/SubOptions/Playlists/PlaylistLoader.gd"

var playlist_title : String = ""
var description_path : String = ""
var temp_playlist_coverpath : String = ""

onready var scroll : ScrollContainer = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller
onready var header : PanelContainer = $HBoxContainer/VBoxContainer/Header
onready var song_vbox : VBoxContainer = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller/Songs
onready var smart_playlist_title : Label = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Title
onready var smart_playlist_cover : TextureRect = $HBoxContainer/VBoxContainer/Header/HBoxContainer/HeaderCover/Cover
onready var runtime_label : Label = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Length/Time
onready var creation_date_label : Label = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Creation/Date
onready var song_amount_label : Label = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Songs/Amount
onready var description : VBoxContainer = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Description

func n_ready( var conditions : Dictionary = {}, var title = "", var custom_description_path : String = "", var cover_path : String = ""):
	var _err = scroll.get_v_scrollbar().connect("value_changed", self, "on_scroll_value_changed")
	song_highlighter = $SongHighlighter
	playlist_options = $HBoxContainer/VBoxContainer/Header/HBoxContainer/PlaylistOptions
	header_cover = $HBoxContainer/VBoxContainer/Header/HBoxContainer/HeaderCover/Cover
	infos = [
		$HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Creation,
		$HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Songs,
		$HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Length,
		$HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Description
	]
	songs = song_vbox 
	temp_playlist_coverpath = cover_path
	ConnectScrollContainer()
	if conditions.empty():
		playlist_idx = Global.pressed_playlist_idx
		playlist_title = SongLists.smart_playlists[ -playlist_idx - 3 ]
		conditions = load_playlist_conditions()
	else:
		playlist_title = title
		playlist_idx = -2
		
	smart_playlist_title.set_text( playlist_title )
	if temp_playlist_coverpath == "":
		smart_playlist_cover.set_texture( ImageLoader.get_cover(Global.get_current_user_data_folder() + "/Songs/Playlists/Covers/" + playlist_title + ".png") )
	else:
		smart_playlist_cover.set_texture( ImageLoader.get_cover(temp_playlist_coverpath))
	var song_idxs : PoolIntArray = get_smart_playlist_songs(conditions)
	if song_idxs.size() > 0:
		load_songs(song_idxs)
	if custom_description_path == "":
		description_path = Global.get_current_user_data_folder() + "/Songs/Playlists/Metadata/Descriptions/" + playlist_title + ".txt"
	else:
		# used when Displaying Artists
		description_path = custom_description_path
	description.load_description(description_path)
	
	# header Info
	var playlist_idx : int = Playlist.get_playlist_index(playlist_title) 
	song_amount_label.text = str(song_idxs.size())
	runtime_label.text = get_playlist_runtime()
	if playlist_idx <= -3:
		# No Temporary Playlists
		creation_date_label.text = get_playlist_creation_date()
	else:
		creation_date_label.text = ""
	
	# setting Current Song
	Global.root.update_highlighted_song(SongLists.current_song)


func load_songs(var song_idxs : PoolIntArray) -> void:
	var x : SongLoader = SongLoader.new()
	x.create_songspaces(song_vbox, song_idxs, Global.pressed_playlist_idx )


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
	for x  in SongLists.AllSongs.size():
		is_valid_song = true
		temp_song_path = SongLists.AllSongs.keys()[x]
		# checking Conditions
		for y in conditions.size():
			for z in conditions.values()[y].size():
				if !condition_functions.call( conditions.keys()[y], temp_song_path, conditions.values()[y][z]):
					is_valid_song = false
					break;
		
		# adding Songs to return Array if the Conditions are met
		if is_valid_song:
			temp_smart_playlist[temp_song_path] = false
			song_idxs.push_back( x )
	
	# setting the Currently "created" Playlist in a Global Dictionary
	# the Playlist has only been loaded, but is not the one currently playing
	SongLists.pressed_temporary_playlist = temp_smart_playlist
	
	# returning All Songs that fit the Current Description
	return song_idxs;


func on_delete_smart_playlist_pressed():
	SongLists.smart_playlists.erase( playlist_title )
	ExtendedDirectory.delete_file(Global.get_current_user_data_folder() + "/Songs/Playlists/Covers/" + playlist_title + ".png")
	ExtendedDirectory.delete_file(Global.get_current_user_data_folder() + "/Songs/Playlists/Metadata/Descriptions/" + playlist_title + ".txt")
	unload_playlist()

   
func on_cover_selected(var img_src : String):
	# saving Cover Copy in User Data
	if temp_playlist_coverpath == "":
		smart_playlist_cover.texture = Playlist.copy_playlist_cover(
			img_src,
			Playlist.get_playlist_index( playlist_title ),
			true
			)
	else:
		var _err : int = Directory.new().copy(
			img_src,
			temp_playlist_coverpath
		)
		smart_playlist_cover.texture = ImageLoader.get_cover(temp_playlist_coverpath)



