extends "res://src/Scenes/Song/SongOptions/SongOptions.gd"
# a script handling the song options menu called from the player


func _on_AddToPlaylistMain_pressed():
	_on_AddToPlaylist_pressed(AllSongs.get_main_idx(SongLists.current_song))


func _on_ChangeTagMain_pressed():
	_on_ChangeTag_pressed(AllSongs.get_main_idx(SongLists.current_song))


func _on_ShowInFilesystemMain_pressed():
	_on_ShowInFilesystem_pressed(AllSongs.get_main_idx(SongLists.current_song))


func _on_QueueSongMain_pressed():
	_on_QueueSong_pressed(AllSongs.get_main_idx(SongLists.current_song))


func _on_RemoveFromPlaylist_pressed():
	remove_from_playlist(AllSongs.get_main_idx(SongLists.current_song))


func _on_ExtractCurrentCover_pressed():
	extract_cover(AllSongs.get_main_idx(SongLists.current_song))


func _on_GoToArtist_pressed():
	go_to_artist(AllSongs.get_main_idx(SongLists.current_song))
