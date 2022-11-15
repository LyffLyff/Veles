extends "res://src/Scenes/Song/SongOptions/SongOptions.gd"
# a script hadnling the song options menu called from the player

onready var bottom_buffer : Control = $BottomEmpty

func _ready():
	# background Color
	$PanelContainer.get_stylebox("panel").set_bg_color(
		SettingsData.get_setting(SettingsData.DESIGN_SETTINGS,"MainSongOptionsBackground")
	)
	
	# remove From Playlist, only visible when inside of playlist
	var main_remove_from_playlist : Button = get_node("PanelContainer/HBoxContainer/VBoxContainer/remove_from_playlist");
	if main_remove_from_playlist:
		if SongLists.current_playlist_idx >= 0:
			# only showing option to remove song from playlist, if the song
			# is from a normal playlist
			main_remove_from_playlist.show()
		else:
			main_remove_from_playlist.hide()


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
