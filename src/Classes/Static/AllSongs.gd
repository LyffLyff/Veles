class_name AllSongs extends Reference

static func get_song_path(var main_idx : int) -> String:
	return SongLists.AllSongs.keys()[main_idx]


static func get_song_artist(var main_idx : int) -> String:
	return SongLists.AllSongs.values()[main_idx][1]


static func get_song_filename(var main_idx : int) -> String:
	return SongLists.AllSongs.values()[main_idx][0]


static func get_song_title(var main_idx : int) -> String:
	# returns title set in the files tag
	return SongLists.AllSongs.values()[main_idx][5]


static func get_song_streams(var main_idx : int) -> int:
	return SongLists.AllSongs.values()[main_idx][3]


static func get_song_duration(var main_idx : int) -> int:
	return SongLists.AllSongs.values()[main_idx][6]


static func get_song_coverhash(var main_idx : int) -> String:
	return SongLists.AllSongs.values()[main_idx][4]


static func get_main_idx(var path : String) -> int:
	if SongLists.AllSongs.has(path):
		return SongLists.AllSongs.keys().find(path)
	else:
		return -1


static func get_song_liked(var main_idx : int) -> bool:
	return SongLists.AllSongs.values()[main_idx][7]


static func get_song_cover_path(var main_idx : int) -> String:
	return Global.get_current_user_data_folder() + "/Songs/AllSongs/Covers/" + get_song_coverhash(main_idx) + ".png"


static func get_song_amount() -> int:
	return SongLists.AllSongs.values().size()


static func set_song_coverhash(var coverhash : String, var main_idx : int) -> void:
	SongLists.AllSongs.values()[main_idx][4] = coverhash


static func set_song_artist(var new_artist : String, var main_idx : int) -> void:
	SongLists.AllSongs.values()[main_idx][1] = new_artist


static func set_song_title(var new_title : String, var main_idx : int) -> void:
	SongLists.AllSongs.values()[main_idx][5] = new_title


static func set_song_liked(var main_idx : int, var liked : bool) -> void:
	SongLists.AllSongs.values()[main_idx][7] = liked


static func set_main_idx(var path : String, var new_main_idx : int) -> void:
	SongLists.AllSongs[path][2] = new_main_idx


static func set_coverhash(var path : String, var new_coverhash : String) -> void:
	SongLists.AllSongs[path][4] = new_coverhash


static func song_title(var main_idx : int) -> String:
	match SettingsData.get_setting(SettingsData.SONG_SETTINGS,"DisplayNameMode"):
		0:
			return get_song_filename(main_idx)
		1:
			return get_song_filename(main_idx).get_basename()
		2:
			return get_song_title(main_idx)
		_:
			return "ERROR://INVALID SETTING VALUE"

