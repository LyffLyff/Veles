class_name SongLoader extends Reference
# script to check through all added directories
# and add all audiofiles to Veles that are valid
# also sends the newly added paths to the Coverloader for filtering of duplicates

signal songs_reloaded

const songspace_scene : PackedScene = preload("res://src/Scenes/Song/SongSpace.tscn")

var temp_playlist_cover : ImageTexture = null

func reload() -> void:
	# checks through all folders and searches for audiofiles 
	# not already added to AllSongs
	var filename : String = ""
	var song_path : String = ""
	var main_idx : int = 0
	var new_songs : PoolStringArray = []
	var new_all_songs : Dictionary = {}
	
	# checking and Deleting Invalid Paths
	for n in SongLists.AllSongs.keys():
		var d : Directory = Directory.new()
		if !d.file_exists(n):
			if !SongLists.AllSongs.erase(n):
				Global.message("COULD NOT ERASE INDEX " + str(n) + "FROM ALLSONGS DICTIONARY", Enumerations.MESSAGE_ERROR)
	
	# loading New Songs from Folder if any
	for folder_idx in SongLists.folders.size():
		var dir = Directory.new()
	
		if dir.open(SongLists.folders[folder_idx]) == OK:
			if dir.list_dir_begin(true,true) == OK:
				
				while true:
					filename = dir.get_next()
					
					if filename == "":
						# end of folder -> skip to next
						break;
					
					if FormatChecker.get_music_filename_extension(filename) != -1:
						song_path = dir.get_current_dir()+ "/" + filename
						if SongLists.AllSongs.has(song_path):
							AllSongs.set_main_idx(song_path,main_idx)
							new_all_songs[song_path] = SongLists.AllSongs.get(song_path)
							
						else:
							# adding all Artists to List
							var artist : String = Tags.get_artist(song_path)
							var divided_artists : PoolStringArray = Artist.divide_artists(artist)
							SongLists.add_new_artist(divided_artists)
							
							new_all_songs[song_path] = [
								filename,
								artist,
								main_idx,
								0,
								str(song_path.hash()),
								Tags.get_title(song_path),
								Tags.get_song_duration(song_path),
								false
							]
							# the new Song in the folder that has just been added will be at the end of the Dictionary
							# should be loaded with the other songs from its folder
							new_songs.push_back(song_path)
						main_idx += 1
	SongLists.AllSongs = new_all_songs
	CoverLoader.new().new_song_covers(new_songs)
	self.emit_signal("songs_reloaded")


func create_songspaces(var songspace_vbox : VBoxContainer, var main_idxs : PoolIntArray = [], var playlist_idx : int = -1) -> void:
	var new_songspace : PanelContainer
	
	for n in main_idxs:
		new_songspace = songspace_scene.instance()
		songspace_vbox.add_child(new_songspace)
		
		# init song Space properties
		new_songspace.main_index = n
		new_songspace.playlist_idx = playlist_idx
		new_songspace.path = AllSongs.get_song_path(n)
		
		# filling in Songspace Data
		set_songspace_cover(new_songspace, n, playlist_idx)
		set_songspace_title(new_songspace, n)
		set_songspace_artist(new_songspace, n)
		set_songspace_length(new_songspace, n)


func set_songspace_cover(var songspace : PanelContainer, var main_idx : int, var playlist_idx : int = -1) -> void:
	var cover_texture : Texture = null
	var coverspace : TextureRect = songspace.get_node("HBoxContainer/Cover")
	
	if SettingsData.get_setting(SettingsData.SONG_SETTINGS, "ShowSongspaceCover"):
		var coverhash : String = AllSongs.get_song_coverhash(main_idx)
		if SongLists.new_cached_covers.has(coverhash):
			cover_texture = SongLists.new_cached_covers.get(coverhash)[1]
		else:
			if !temp_playlist_cover:
				temp_playlist_cover = ImageLoader.get_cover("", ImageLoader.ImageTypes.COVER, Playlist.get_playlist_name(playlist_idx), Vector2(70, 70))
			cover_texture = temp_playlist_cover
	else:
		coverspace.hide()
	coverspace.set_deferred("texture", cover_texture)


func set_songspace_title(var songspace : PanelContainer, var main_idx : int) -> void:
	songspace.get_node("HBoxContainer/Name").set_deferred("text", AllSongs.song_title(main_idx))


func set_songspace_artist(var songspace : PanelContainer, var main_idx : int) -> void:
	songspace.get_node("HBoxContainer/Artist").set_deferred("text", AllSongs.get_song_artist(main_idx))


func set_songspace_length(var songspace : PanelContainer, var main_idx : int) -> void:
	songspace.get_node("HBoxContainer/Length").set_deferred("text", TimeFormatter.format_seconds(AllSongs.get_song_duration(main_idx)))

