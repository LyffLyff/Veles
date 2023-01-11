extends Control


func get_playlist_song_amount(var playlist_idx : int) -> int:
	if playlist_idx >= 0:
		# normal Playlists
		return SongLists.normal_playlists.values()[playlist_idx].size();
	elif playlist_idx <= -2:
		# temporary and Smart Playlists
		return SongLists.pressed_temporary_playlist.size();
	elif playlist_idx == -1:
		# all Songs
		return SongLists.AllSongs.size();
	return -1;


func get_playlist_creation_date(var playlist_idx : int) -> String:
	var playlist_name : String = Playlist.get_playlist_name(playlist_idx)
	var temp_date = SaveData.get_key_from_file(SongLists.add_user_to_filepath(SongLists.file_paths[9]),playlist_name,0)
	if temp_date:
		var time_formatter : TimeFormatter = TimeFormatter.new()
		var daytime : String = time_formatter.format_daytime(temp_date.hour, temp_date.minute, temp_date.second)
		var date : String = time_formatter.format_date(temp_date.day,temp_date.month,temp_date.year)
		return daytime + " " + date;
	else:
		return "00:00:00 0000 00 000"


func get_playlist_runtime(var playlist_idx : int) -> String:
	return TimeFormatter.format_seconds(Playlist.get_runtime_seconds(playlist_idx)) + " min"


func rename_playlist(var playlist_idx : int) -> void:
	Global.root.toggle_songlist_input(false)
	var x : Node = load("res://src/Scenes/General/TextInputDialogue.tscn").instance()
	Global.root.add_child(x)
	x.set_topic("New Playlist Title")
	var _err = x.connect("text_saved", Playlist, "rename_playlist", [playlist_idx])
	_err = x.connect("saved",self,"unload")
	_err = x.connect("tree_exited", Global.root, "toggle_songlist_input", [true])


func export_playlist(var playlist_idx : int) -> void:
	var playlist_export_menu : Node = load("res://src/Scenes/Export/PlaylistExportMenu.tscn").instance()
	Global.root.top_ui.add_child(playlist_export_menu)
	playlist_export_menu.init_export_menu(playlist_idx)
