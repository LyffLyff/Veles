extends "res://src/Scenes/General/PlayerOption.gd"
# a script that includes all possible options that can be called on a song

# this value is set when right clicking a songspace
var song_idx : int = -1
var is_ready : bool = false

func _ready():
	is_ready = true
	
	# hides the remove from playlist button if it isn't inside a playlist
	if Global.pressed_playlist_idx == -1:
		if self.has_node("PanelContainer/HBoxContainer/VBoxContainer/RemoveFromPlaylist"):
			self.get_node("PanelContainer/HBoxContainer/VBoxContainer/RemoveFromPlaylist").hide()
		else:
			self.get_node("VBoxContainer/HBoxContainer/VBoxContainer/RemoveFromPlaylist").hide()
	else:
		if self.has_node("PanelContainer/HBoxContainer/VBoxContainer/RemoveFromPlaylist"):
			self.get_node("PanelContainer/HBoxContainer/VBoxContainer/RemoveFromPlaylist").show()
		else:
			self.get_node("VBoxContainer/HBoxContainer/VBoxContainer/RemoveFromPlaylist").show()


func _enter_tree():
	Global.root.toggle_songlist_input(false)


func _exit_tree():
	Global.root.toggle_songlist_input(true)


func _process(_delta):
	if !is_ready:
		return
	if !self.get_global_rect().has_point( get_global_mouse_position() ):
		exit_player_option()
		set_process(false)	# if not will be called during tween


func get_clicked_song_path() -> String:
	if song_idx >= 0:
		var option : Control = Global.root.options.get_child(0)
		if option.get("songs") != null:
			var songs : VBoxContainer = option.songs
			return songs.get_child(song_idx).path
	return ""


func _on_ChangeTag_pressed(var main_idx : int = -1):
	Global.root.player.disable_image_view()
	var song_path : String = AllSongs.get_song_path(main_idx)
	if main_idx != -1:
			Global.push_tag_path( song_path )
	else:
		if get_clicked_song_path() in SongLists.highlighted_songs:
			Global.temp_tag_paths = SongLists.highlighted_songs
		else:
			Global.push_tag_path( get_clicked_song_path() )
	
	# since this changes the option the Input Toggler is called manually 
	Global.root.load_option(4,true)
	exit_player_option()


func _on_AddToPlaylist_pressed(var main_idx : int = -1):
	if main_idx == -1:
		if get_clicked_song_path() in SongLists.highlighted_songs:
			var main_idxs : PoolIntArray = []
			for HighlightedSong in SongLists.highlighted_songs:
				main_idxs.push_back( AllSongs.get_main_idx(HighlightedSong) )
			load_playlist_selector(main_idxs)
		else:
			#Adding the Current Song need no Argument Passed
			var idx : int = AllSongs.get_main_idx( get_clicked_song_path() )
			load_playlist_selector([idx])
	else:
		#Adding a Specific Song need the Main Index
		load_playlist_selector([main_idx])
	exit_player_option()


func _on_Close_pressed():
	exit_player_option()


func _on_ShowInFilesystem_pressed(var main_idx : int = -1):
	var dir : String
	var titles : PoolStringArray = []
	var paths : PoolStringArray  = []
	if main_idx == -1:
		# loads from a randomly picked song in list
		if get_clicked_song_path() in SongLists.highlighted_songs:
			# if the "SongOptioned" Song is one of many highlighted songs
			# ALL of the highlighted songs will be added
			for path in SongLists.highlighted_songs:
				paths.push_back( path)
				titles.push_back( AllSongs.get_song_filename( AllSongs.get_main_idx(path)) )
		else:
			# the needed song is NOT one of the highlighted
			paths.push_back( get_clicked_song_path() )
			titles.push_back( AllSongs.get_song_filename( AllSongs.get_main_idx(paths[0])) )
	else:
		# loads from the currently playing song
		titles.push_back( AllSongs.get_song_filename(main_idx) )
		paths.push_back( AllSongs.get_song_path(main_idx) )
	# removes title from path and uses this as directory
	for i in paths.size():
		dir = paths[i].replace(titles[i],"")
		
		# automatically detects duplicates and doesn't open them
		ExtendedDirectory.open_directory(dir)
	exit_player_option()


func _on_ShowCoverInFilesystem_pressed():
	exit_player_option()
	ExtendedDirectory.open_directory(Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/")


func _on_QueueSong_pressed(var main_idx : int = -1):
	if main_idx == -1:
		if get_clicked_song_path() in SongLists.highlighted_songs:
			for Song in SongLists.highlighted_songs:
				SongLists.queue_song( Song )
		else:
			SongLists.queue_song( get_clicked_song_path() )
	else:
		SongLists.queue_song()
	exit_player_option()


func _on_Clear_Queue_pressed():
	SongLists.clear_queue()
	exit_player_option()


func load_playlist_selector(var main_idxs : PoolIntArray) -> void:
	var playlist_selector = load("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/PlaylistSelector.tscn").instance()
	Global.root.middle_part.add_child(playlist_selector)
	for n in SongLists.normal_playlists.size():
		var std_playlist_button = load("res://src/Scenes/SubOptions/Playlists/StdPlaylistButton.tscn").instance()
		playlist_selector.Playlists.add_child(std_playlist_button)
		if std_playlist_button.connect("pressed",Global,"add_to_playlist",[playlist_selector,n,main_idxs]):
			Global.root.message("ADDING SONG TO PLAYLIST", SaveData.MESSAGE_ERROR)
		std_playlist_button.get_child(0).text = SongLists.normal_playlists.keys()[n]


func extract_cover(var main_idx : int = -1) -> void: 
	var song_paths : PoolStringArray = []
	if main_idx != -1:
		song_paths.push_back( AllSongs.get_song_path(main_idx) )
	else:
		if get_clicked_song_path() in SongLists.highlighted_songs:
			song_paths = SongLists.highlighted_songs
		else:
			song_paths.push_back( get_clicked_song_path() )
	
	var _dialog = Global.root.load_general_file_dialogue(
		Exporter.new(),
		FileDialog.MODE_SAVE_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"to_image",
		[song_paths],
		"ExportCover",
		["*png","*jpg","*webp"],
		true
	)


func remove_from_playlist(var main_idx : int = -1) -> void:
	var keys : PoolStringArray
	if main_idx != -1:
		keys.push_back( AllSongs.get_song_path(main_idx) )
	else:
		if get_clicked_song_path() in SongLists.highlighted_songs:
			keys = SongLists.highlighted_songs
		else:
			keys.push_back( SongLists.normal_playlists.values()[Global.pressed_playlist_idx].keys()[song_idx] )
	
	for i in keys.size():
		SongLists.normal_playlists.values()[Global.pressed_playlist_idx].erase(keys[i])
	
	Global.root.reload_option()
	exit_player_option()

