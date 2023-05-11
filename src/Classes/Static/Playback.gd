class_name Playback extends Reference


func is_song_playable() -> bool: 
	return true


func stop_playback() -> void:
	SongLists.current_song = ""
	MainStream.set_stream_paused(true)
	MainStream.set_stream(null)
	MainStream.reload_stream_timer(true)
	Global.root.player.init_player()
	Global.root.player.set_playback_button(false)


static func skip_song(var main_idx : int) -> void:
	# skips to the next Song if the header FileFormat is not supported or the path couldn't be opened
	# when loading Veles checks for the Filename extension not the "REAL" format
	var path : String = AllSongs.get_song_path(main_idx)
	var to_next : bool = false
	if Global.first_skipped_path == path:
		# only skips if the first song that was skipped does is not the one that wants to be skipped
		# -> prevents an endless loop if EVERY song is invalid
		SongLists.set_current_song("")
		MainStream.set_stream_paused(true)
		return
	else:
		to_next = true
	
	if Global.first_skipped_path == "":
		Global.first_skipped_path = path
		to_next = true
	
	if to_next:
		SongLists.set_current_song(path)
		change_song(Global.last_direction)


static func change_song(var direction : int) -> void:
	# this function changes the songs within a playlist (does not watch for queue)
	var next_main_idx : int =  0 
	var current_main_idx : int = AllSongs.get_main_idx(SongLists.current_song)
	
	if !SongLists.AllSongs.has(SongLists.current_song) or SongLists.AllSongs.size() == 0:
		# song is not loaded into Veles or no song is loaded -> error
		return
	
	if SongLists.current_playlist_idx == -1:
		var proposed_main_idx : int = current_main_idx + direction
		if SongLists.AllSongs.size() - 1 > current_main_idx and proposed_main_idx > 0:
			next_main_idx = proposed_main_idx
		else:
			# wraps around to first Song if at the end
			# or stays at the first if trying to go further prior
			next_main_idx = 0
	else:
		var playlist_content : Dictionary = {}
		
		if SongLists.current_playlist_idx >= 0:
			# if the index of the normal playlist does not exist it switches to AllSongs
			if SongLists.normal_playlists.size() <= SongLists.current_playlist_idx:
				SongLists.current_playlist_idx = -1
				change_song(+1)
				return
			playlist_content = SongLists.normal_playlists.values()[SongLists.current_playlist_idx]
		
		elif SongLists.current_playlist_idx <= -2:
			# smart or temporary playlist
			playlist_content = SongLists.current_temporary_playlist
		
		if playlist_content.size() == 0:
			# if current playlist is empty -> change to My Music
			SongLists.current_playlist_idx = -1
			next_main_idx = 0
		else:
			var idx_in_playlist : int = -1
			for song_idx in playlist_content.size():
				# finding the index of the current song inside the playlist
				if playlist_content.keys()[song_idx] == SongLists.current_song:
					var next_song_idx : int = song_idx + direction
					if playlist_content.size() > next_song_idx and next_song_idx >= 0:
						idx_in_playlist = next_song_idx
					else:
						idx_in_playlist = 0
					break;
			
			# fetching main index for playlists
			next_main_idx = AllSongs.get_main_idx(playlist_content.keys()[idx_in_playlist])
	
	var path : String = AllSongs.get_song_path(next_main_idx)
	Global.last_direction = direction
	
	Global.root.playback_song(
		next_main_idx,
		true,
		Playlist.get_playlist_name(SongLists.current_playlist_idx)
	)
