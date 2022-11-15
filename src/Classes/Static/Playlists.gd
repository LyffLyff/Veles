class_name Playlist extends Reference


static func get_playlist_name(var playlist_idx : int = -1) -> String:
	if playlist_idx == -1:
		# AllSongs
		return "AllSongs"
	elif playlist_idx >= 0:
		# normal Playlist
		return SongLists.normal_playlists.keys()[playlist_idx]
	elif playlist_idx == -2:
		var TempPlaylistTitle = SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "TemporaryPlaylistTitle")
		if TempPlaylistTitle != null:
			return TempPlaylistTitle
		else:
			return ""
	elif playlist_idx <= -3:
		# smart Playlist
		if -playlist_idx - 3 < SongLists.smart_playlists.size():
			return SongLists.smart_playlists[-playlist_idx - 3]
	return ""


static func get_playlist_index(var title : String) -> int:
	if SongLists.normal_playlists.has(title):
		# normal Playlist
		return SongLists.normal_playlists.keys().find(title, 0)
	elif SongLists.smart_playlists.has(title):
		# smart Playlist
		return -SongLists.smart_playlists.find(title, 0) - 3
	else:
		return -1


static func get_playlist_cover(var playlist_idx : int) -> Texture:
	if playlist_idx == -2 or playlist_idx == -1:
		# ignoring Temporary Playlists and All Songs
		return ImageTexture.new()
	
	var cover_path : String = Global.get_current_user_data_folder() + "/Songs/Playlists/Covers/" + get_playlist_name(playlist_idx) + ".png"
	return ImageLoader.get_cover(cover_path)


static func copy_playlist_cover(var img_src : String,var playlist_idx : int,var return_texture : bool = false):
	# copies the set playlist cover to the users data folder
	var cover_path : String = Global.get_current_user_data_folder() + "/Songs/Playlists/Covers/" + get_playlist_name(playlist_idx) + ".png"
	var dir : Directory = Directory.new()
	if dir.file_exists(img_src):
		if dir.copy(img_src, cover_path) != OK:
			Global.root.message("COPYING PLAYLIST COVER TO USERDATA FROM: " + img_src + " TO: " + cover_path,SaveData.MESSAGE_ERROR, false, Color() )
	
	if return_texture:
		return ImageLoader.get_cover(cover_path)


static func get_runtime_seconds(var playlist_idx : int) -> int:
	# returns the runtime of the playlist, by adding the duration of all the songs within
	# main Index will again be fetched using the Path NOT the Main Index
	var seconds : int = 0
	if playlist_idx >= 0:
		for n in SongLists.normal_playlists.values()[playlist_idx].size():
			seconds += AllSongs.get_song_duration(AllSongs.get_main_idx(SongLists.normal_playlists.values()[playlist_idx].keys()[n]))
	else:
		for i in SongLists.pressed_temporary_playlist.size():
			seconds += AllSongs.get_song_duration(
				AllSongs.get_main_idx(
					SongLists.pressed_temporary_playlist.keys()[i]
					)
				)
	return seconds


static func is_valid_playlist_title(var new_title : String) -> bool:
	# checks if a new playlist name is valid and can be used
	
	# comparing to other playlist titles
	for Title in SongLists.normal_playlists.keys():
		if Title == new_title:
			return false;
	
	for Title in SongLists.smart_playlists:
		if Title == new_title:
			return false;

	# checking if Invalid in other ways
	if new_title == "":
		return false
	
	return true;


static func rename_playlist(var new_title : String, var playlist_idx : int) -> void:
	var old_title : String = get_playlist_name(playlist_idx)
	
	if !is_valid_playlist_title(new_title):
		return;
		
	
	var dir : Directory = Directory.new()
	
	if playlist_idx >= 0:
		# normal playlists
		SongLists.normal_playlists = SongLists.replace_dict_key(SongLists.normal_playlists, old_title, new_title)
	else:
		# smart playlists
		if dir.rename(
			Global.get_current_user_data_folder() + "/Songs/Playlists/SmartPlaylists/Conditions/" + old_title + ".dat",
			Global.get_current_user_data_folder() + "/Songs/Playlists/SmartPlaylists/Conditions/" + new_title + ".dat"
		) != OK:
			Global.root.message("RENAMING SmartPlaylistConditions FROM: " + old_title + " TO " + new_title,SaveData.MESSAGE_ERROR, false, Color() )
		SongLists.smart_playlists[ (playlist_idx * -1) - 3] = new_title
	
	# changing Cover path
	if dir.rename(
		Global.get_current_user_data_folder() + "/Songs/Playlists/Covers/" + old_title + ".png",
		Global.get_current_user_data_folder() + "/Songs/Playlists/Covers/" + new_title + ".png" ) != OK:
		Global.root.message("RENAMING Playlist's Cover FROM: " + old_title + " TO " + new_title,SaveData.MESSAGE_ERROR, false, Color() )
	
	# metadata Changes
	# replacing the Playlists metadata key(name) in dictionary file, with the new one
	SaveData.replace_key_from_file(
		SongLists.add_user_to_filepath(SongLists.file_paths[9]),
		old_title,
		new_title
	)


static func get_playlist_paths(var playlist_idx : int) -> PoolStringArray:
	# returns paths of all the songs inside of playlist
	if playlist_idx == -1:
		return PoolStringArray( SongLists.AllSongs.keys() )
	elif playlist_idx >= 0:
		return SongLists.normal_playlists.values()[playlist_idx].keys()
	elif playlist_idx <= -2:
		return PoolStringArray( SongLists.pressed_temporary_playlist.keys() )
	return PoolStringArray();
