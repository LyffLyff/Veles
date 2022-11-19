extends AudioStreamPlayer

signal bus_mute

const mute_threshold : float = 0.01

# 30 seconds at the start
# 1  minute after that
# 2  minutes after that
var stream_timer : Timer = Timer.new()											#waits for a specific amount of time for a "stream" to be counted
var stream_goals : PoolIntArray = [30,60,120]									#saves the amount  of seconds needed for the next stream goal

func _ready():
	# stream timer
	stream_timer.one_shot = true
	stream_timer.autostart = false
	self.add_child(stream_timer)
	
	# init volume
	self.set_volume(
		db2linear(SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"Volume"))
	)


func _exit_tree():
	SettingsData.set_setting(SettingsData.GENERAL_SETTINGS,"PlaybackPosition",self.get_playback_position())


func _on_MainStream_finished() -> void: 
	if Global.current_profile_idx == -1:
		# prevents the next song from being played when deleting a user profile
		return
	
	# repeat has thee highest Priority
	# before -> Queue and Shuffle
	if !SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"Repeat"):
		Global.root.player.prior_next_song(+1)
	else:
		self.play(0)
		Global.root.update_player_infos()
		reload_stream_timer()


func set_volume(var volume_linear : float) -> void:
	# converting the linear Scale of the volume slider to db values
	var volume_db : float = linear2db(volume_linear)
	
	MainStream.set_volume_db(volume_db)
	
	# saving db value to settings
	SettingsData.set_setting(SettingsData.GENERAL_SETTINGS,"Volume",volume_db)
	
	# checking if stream needs to be muted/unmuted
	if volume_linear <= mute_threshold:
		if !AudioServer.is_bus_mute(0):
			AudioServer.set_bus_mute(0,true)
			emit_signal("bus_mute",true)
	elif AudioServer.is_bus_mute(0):
		AudioServer.set_bus_mute(0,false)
		emit_signal("bus_mute",false)


func reload_stream_timer(var is_paused : bool = false) -> void:
	var main_idx : int = AllSongs.get_main_idx(SongLists.current_song)
	stream_timer.set_wait_time(stream_goals[0])
	if stream_timer.is_connected("timeout",self,"stream_timer_timeout"):
		stream_timer.disconnect("timeout",self,"stream_timer_timeout")
	if stream_timer.connect("timeout",self,"stream_timer_timeout",[0,main_idx]) != OK:
		Global.root.message("CONNECTING STREAM TIMER TO TIMEOUT",  SaveData.MESSAGE_ERROR)
	stream_timer.start()
	stream_timer.set_deferred("paused",is_paused)


func stream_timer_timeout(var timer_idx : int, var main_idx):
	# adds one to the stream of the current song
	Streams.add_song_stream(AllSongs.get_song_path(main_idx),+1)
	Streams.add_playlist_stream(Playlist.get_playlist_name(SongLists.current_playlist_idx),+1)
	Streams.add_artist_stream(AllSongs.get_song_artist(main_idx),+1)
	# disconnect the stream timer so the argument can be changed
	stream_timer.disconnect("timeout",self,"stream_timer_timeout")
	timer_idx += 1
	if timer_idx < stream_goals.size():
		if stream_timer.connect("timeout",self,"stream_timer_timeout",[timer_idx,main_idx]):
			Global.root.message("CONNECTING STREAM TIMER TO TIMEOUT",  SaveData.MESSAGE_ERROR)
		stream_timer.set_wait_time(stream_goals[timer_idx])
		stream_timer.start()
	# if all goals where reached the timer stops
	# and starts only on another play song call
