class_name Playback extends Reference


func is_song_playable() -> bool: 
	return true


func stop_playback() -> void:
	SongLists.CurrentSong = ""
	MainStream.set_stream_paused(true)
	MainStream.set_stream(null)
	MainStream.ReloadStreamTimer(true)
	Global.root.player.init_player()
	Global.root.player.set_playback_button(false)


func skip_song() -> void:
	pass
