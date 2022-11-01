extends AudioStreamPlayer


func _ready():
	
	####Stream Timer#############
	StreamTimer.one_shot = true
	StreamTimer.autostart = false
	self.add_child(StreamTimer)
	############################
	self.set_volume_db(SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"Volume"))


func _exit_tree():
	SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"PlaybackPosition",self.get_playback_position())


func _on_MainStream_finished() -> void: 
	if Global.CurrentProfileIdx == -1:
		#prevents the next song from being played when deleting a user profile
		return
	
	#Repeat Has thee highest Priority
	#before -> Queue and Shuffle
	if !SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"Repeat"):
		Global.root.player.PriorNextSongPressed(+1)
	else:
		self.play(0)
		Global.root.UpdatePlayerInfos()
		ReloadStreamTimer()


func toggle_effects():
	#if the bus is not muted when enabling AudioEffects the stream will reset for some reason
	AudioServer.set_bus_mute(0, true)
	
	#enabling reverb
	AudioServer.call_deferred("set_bus_effect_enabled",0,0,!AudioServer.is_bus_effect_enabled(0,0))
	#AudioServer.set_bus_effect_enabled(0,0,!AudioServer.is_bus_effect_enabled(0,0))
	#enabling pitch shift
	AudioServer.call_deferred("set_bus_effect_enabled",0,1,!AudioServer.is_bus_effect_enabled(0,1))
	AudioServer.set_bus_mute(0, false)


# 30 seconds at the start
# 1  minute after that
# 2  minutes after that
var StreamTimer : Timer = Timer.new()											#waits for a specific amount of time for a "stream" to be counted
var stream_goals : PoolIntArray = [30,60,120]									#saves the amount  of seconds needed for the next stream goal


func ReloadStreamTimer(var is_paused : bool = false) -> void:
	var main_idx : int = AllSongs.GetMainIdx(SongLists.CurrentSong)
	StreamTimer.set_wait_time(stream_goals[0])
	if StreamTimer.is_connected("timeout",self,"StreamTimerTimeout"):
		StreamTimer.disconnect("timeout",self,"StreamTimerTimeout")
	if StreamTimer.connect("timeout",self,"StreamTimerTimeout",[0,main_idx]) != OK:
		Global.root.Message("CONNECTING STREAM TIMER TO TIMEOUT",  SaveData.MESSAGE_ERROR)
	StreamTimer.start()
	StreamTimer.set_deferred("paused",is_paused)


func StreamTimerTimeout(var timer_idx : int, var main_idx):
	#adds one to the stream of the current song
	Streams.AddSongStream(AllSongs.GetSongPath(main_idx),+1)
	Streams.AddPlaylistStream(Playlist.GetPlaylistName(SongLists.CurrentPlayList),+1)
	Streams.AddArtistStream(AllSongs.GetSongArtist(main_idx),+1)
	#disconnect the stream timer so the argument can be changed
	StreamTimer.disconnect("timeout",self,"StreamTimerTimeout")
	timer_idx += 1
	if timer_idx < stream_goals.size():
		if StreamTimer.connect("timeout",self,"StreamTimerTimeout",[timer_idx,main_idx]):
			Global.root.Message("CONNECTING STREAM TIMER TO TIMEOUT",  SaveData.MESSAGE_ERROR)
		StreamTimer.set_wait_time(stream_goals[timer_idx])
		StreamTimer.start()
	#if all goals where reached the timer stops
	#and starts only on another play song call