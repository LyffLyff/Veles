extends Reference


class_name Playback
# song playback script


const playable_fmts : Array = [0,1,2]


func is_song_playable(var path : String) -> bool:
	if !Directory.new().file_exists(path):
		return false
	if FormatChecker.GetMusicFormat( SaveData.LoadBuffer(path,1024).hex_encode() ) != -1:
		return true
	if FormatChecker.FileNameFormat(path) in playable_fmts:
		return true
	return false


func stop_playback() -> void:
	SongLists.CurrentSong = ""
	Global.root.player.InitPlayer()
	MainStream.set_stream_paused(true)
	MainStream.ReloadStreamTimer(true)
	MainStream.set_stream(null)
