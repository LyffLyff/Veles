extends "res://src/Scenes/General/MovablePopupMenu.gd"
# a script that includes all possible options that can be called on a song

# this value is set when right clicking a songspace
var song_idx : int = -1

func _ready():
	# hides the remove from playlist button if it isn't inside a playlist
	var remove_from_playlist : Node = self.find_node("RemoveFromPlaylist")
	if remove_from_playlist != null:
		remove_from_playlist.visible = (Global.pressed_playlist_idx >= 0)


func get_clicked_song_path() -> String:
	if song_idx >= 0:
		var option : Control = Global.root.options.get_child(0)
		if option.get("song_vbox") != null:
			var song_vbox : VBoxContainer = option.song_vbox
			return song_vbox.get_child(song_idx).path
	return ""


func _on_ChangeTag_pressed(var main_idx : int = -1):
	Global.root.disable_image_view()
	var song_path : String = AllSongs.get_song_path(main_idx)
	if main_idx != -1:
			Global.push_tag_path(song_path)
	else:
		if get_clicked_song_path() in SongLists.highlighted_songs:
			Global.temp_tag_paths = SongLists.highlighted_songs
		else:
			Global.push_tag_path(get_clicked_song_path())
	
	# since this changes the option the Input Toggler is called manually 
	Global.root.load_option(4,true)
	unload_popup()


func _on_AddToPlaylist_pressed(var main_idx : int = -1):
	if main_idx == -1:
		if get_clicked_song_path() in SongLists.highlighted_songs:
			var main_idxs : PoolIntArray = []
			for highlighted_song in SongLists.highlighted_songs:
				main_idxs.push_back(AllSongs.get_main_idx(highlighted_song))
			load_playlist_selector(main_idxs)
		else:
			# adding the Current Song need no Argument Passed
			var idx : int = AllSongs.get_main_idx(get_clicked_song_path())
			load_playlist_selector([idx])
	else:
		# adding a Specific Song need the Main Index
		load_playlist_selector([main_idx])
	unload_popup()


func _on_Close_pressed():
	unload_popup()


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
	unload_popup()


func _on_ShowCoverInFilesystem_pressed():
	unload_popup()
	ExtendedDirectory.open_directory(Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/")


func _on_QueueSong_pressed(var main_idx : int = -1):
	if main_idx == -1:
		if get_clicked_song_path() in SongLists.highlighted_songs:
			SongLists.queue_songs(SongLists.highlighted_songs)
		else:
			SongLists.queue_songs([get_clicked_song_path()])
	else:
		SongLists.queue_songs([SongLists.current_song])
	unload_popup()


func _on_Clear_Queue_pressed():
	SongLists.clear_queue()
	unload_popup()


func load_playlist_selector(var main_idxs : PoolIntArray) -> void:
	var playlist_selector = load("res://src/Scenes/Playlists/Selection/PlaylistSelector.tscn").instance()
	Global.root.middle_part.add_child(playlist_selector)
	playlist_selector.init_selector(main_idxs)


func extract_cover(var main_idx : int = -1) -> void: 
	var song_paths : PoolStringArray = []
	if main_idx != -1:
		song_paths.push_back(AllSongs.get_song_path(main_idx))
	else:
		if get_clicked_song_path() in SongLists.highlighted_songs:
			song_paths = SongLists.highlighted_songs
		else:
			song_paths.push_back(get_clicked_song_path())
	
	Global.load_export_menu(song_paths[0])
	unload_popup()


func remove_from_playlist(var main_idx : int = -1) -> void:
	var keys : PoolStringArray
	if main_idx != -1:
		keys.push_back(AllSongs.get_song_path(main_idx))
	else:
		if get_clicked_song_path() in SongLists.highlighted_songs:
			keys = SongLists.highlighted_songs
		else:
			keys.push_back(SongLists.normal_playlists.values()[Global.pressed_playlist_idx].keys()[song_idx])
	
	for i in keys.size():
		SongLists.normal_playlists.values()[Global.pressed_playlist_idx].erase(keys[i])
	
	Global.root.reload_option()
	unload_popup()


func go_to_artist(var main_idx : int = -1) -> void:
	if main_idx == -1:
		main_idx = AllSongs.get_main_idx(get_clicked_song_path())
	Artist.load_artist_playlist(AllSongs.get_song_artist(main_idx))
	unload_popup()
