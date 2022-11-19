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


func skip_song() -> void:
	pass
