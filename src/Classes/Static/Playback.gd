extends Reference
class_name Playback


func is_song_playable() -> bool: 
	return true


func stop_playback() -> void:
	SongLists.CurrentSong = ""
	MainStream.set_stream_paused(true)
	MainStream.set_stream(null)
	Global.root.player.InitPlayer()
	MainStream.ReloadStreamTimer(true)
	#set_playback_button -> to paused


func skip_song() -> void:
	pass
