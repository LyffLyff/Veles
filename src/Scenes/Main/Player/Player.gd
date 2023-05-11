extends Control
# a script controlling the bottom part of the main scene -> player

const VOLUME_CHANGER : PackedScene = preload("res://src/Scenes/Main/Player/VolumeChanger.tscn")
const IMAGE_VIEW : PackedScene = preload("res://src/Scenes/Views/ImageView/ImageView.tscn")
const TW_DURATION : float = 0.1
const ENABLED_DISABLED_OPACITIES : Array = [0.5, 1.0]

var effects_ref = null
var effects_visible : bool = false
var playback_pos : float
var output_device_visible : bool = false
var output_device_ref : Control = null
var volume_change_ref : Control = null
var image_view_ref : Control = null
var is_image_view_active : bool = false
var is_image_view_tweening : bool = false
var is_dragging : bool = false
var current_covers : Array = []
var current_cover_idx : int = -1

onready var prior_song : TextureButton = $Main/MainPlayer/Middle/HBoxContainer/PriorSong
onready var next_song : TextureButton = $Main/MainPlayer/Middle/HBoxContainer/NextSong
onready var playback_button : TextureButton = $Main/MainPlayer/Middle/HBoxContainer/Playback
onready var info_cover : TextureButton = $Main/SongInfo/Info/Cover/Cover
onready var repeat_button : TextureButton = $Main/MainPlayer/Middle/Repeat
onready var shuffle_button : TextureButton = $Main/MainPlayer/Middle/Shuffle
onready var volume_button : TextureButton = $Main/Additional/Volume
onready var output_device : TextureButton = $Main/Additional/OutputDevice
onready var playback_position : Label = $Main/MainPlayer/Bottom/PlaybackPosition
onready var playback_slider : HSlider = $Main/MainPlayer/Bottom/PlaybackSlider
onready var song_title : Label = $Main/SongInfo/Info/Infos/Title
onready var song_artist : LinkButton = $Main/SongInfo/Info/Infos/Artist
onready var song_length : Label = $Main/MainPlayer/Bottom/SongLength
onready var song_playlist : LinkButton = $Main/SongInfo/Info/Infos/Playlist
onready var audio_effects_button : TextureButton = $Main/Additional/Effects
onready var song_options : TextureButton = $Main/Additional/SongOptions


func _ready():
	init_player()
	# initialising background Color
	self.get_stylebox("panel").set_bg_color(
		SettingsData.get_setting(SettingsData.DESIGN_SETTINGS, "PlayerBackground")
	)


func set_playback_button(var playback : bool) -> void:
	var texture : Texture = Global.pause_img if playback else Global.play_img
	playback_button.set_normal_texture(texture)


func init_player() -> void:
	# reset player infos
	song_title.set_text("")
	song_playlist.set_text("")
	song_artist.set_text("")
	info_cover.set_normal_texture(Global.std_music_cover)
	
	# setting the saved values
	set_repeat(SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"Repeat"))
	set_shuffle(SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"Shuffle"))
	if SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"ImageViewActivated"):
		# waits for the root function taaaa o be ready before loadiung the image view on startup :/
		yield(get_owner(),"ready")
		_on_Cover_pressed()
	
	# connecting signals
	var buttons : Array = [
		playback_button, prior_song, next_song, repeat_button, shuffle_button, song_artist,
		song_playlist, output_device, volume_button, audio_effects_button, song_options
	]
	
	for n in buttons.size():
		Modulator.init_modulation(buttons[n])
	
	# connecting Next/Prior Song Buttons
	if !next_song.is_connected("pressed", self, "prior_next_song"):
		if next_song.connect("pressed", self, "prior_next_song", [+1]):
				Global.message("CONNECTING PRESSED SIGNAL TO NEXT SONG BUTTON", Enumerations.MESSAGE_ERROR)
	if !prior_song.is_connected("pressed", self, "prior_next_song"):
		if prior_song.connect("pressed", self, "prior_next_song", [-1]):
			Global.message("CONNECTING PRESSED SIGNAL TO NEXT SONG BUTTON", Enumerations.MESSAGE_ERROR)
	
	# connecting volume button to MainStream -> bus_mute signal
	if !MainStream.is_connected("bus_mute", self, "set_volume_texture"):
		if MainStream.connect("bus_mute", self, "set_volume_texture"):
			Global.message("CONNECTING MAINSTREAM BUS MUTE TO SET VOLUME BUTTON TEXTURE", Enumerations.MESSAGE_ERROR)


func _on_Playback_pressed():
	if !MainStream.stream:
		return
	
	var toggle : bool = !MainStream.get_stream_paused()
	set_playback_button(!toggle)
	MainStream.set_stream_paused(toggle)
	MainStream.stream_timer.set_deferred("paused", toggle)


func _on_RepeatMode_pressed():
	# get current button state by the opacity of it and toggle it
	var toggle : bool = !(repeat_button.modulate.a == ENABLED_DISABLED_OPACITIES[1])
	toggle_player_option(repeat_button, toggle)
	SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "Repeat", toggle)


func _on_Shuffle_pressed():
	var toggle : bool = !(shuffle_button.modulate.a == ENABLED_DISABLED_OPACITIES[1])
	toggle_player_option(shuffle_button, toggle)
	SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "Shuffle", toggle)


func _on_Cover_pressed():
	if is_image_view_tweening:
		return
	
	if !is_image_view_active:
		SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "ImageViewActivated", true)
		image_view_ref = IMAGE_VIEW.instance()
		var _err : int = image_view_ref.connect("image_view_exit_started", self, "set", ["image_view_ref", null])
		is_image_view_tweening = true
		_err = image_view_ref.connect("init_tween_ended", self, "set", ["is_image_view_tweening", false])
		Global.root.middle_part.add_child(image_view_ref)
		_err = image_view_ref.image_view_cover.connect("update_cover", self, "set_player_covers")
		self.set_image_view_cover(get_current_cover(), current_cover_idx)
	else:
		SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "ImageViewActivated", false)
		image_view_ref.exit_image_view()
	is_image_view_active = !is_image_view_active


func _on_Effects_pressed():
	if !effects_visible:
		effects_visible = true
		effects_ref = load("res://src/Scenes/SubOptions/AudioEffects/Effects/NewAudioEffects.tscn").instance()
		var _err = effects_ref.connect("tree_exited",self,"set",["effects_visible",false])
		Global.root.middle_part.add_child(effects_ref)
	else:
		effects_ref.free_audio_effects()


func _on_Volume_pressed():
	if volume_change_ref == null:
		var volume = VOLUME_CHANGER.instance()
		if volume.connect("tree_exited",self,"set",["volume_change_ref",null]):
			Global.message("CONNECTING VOLUME CHANGER IN PLAYER TO TREE EXITED SIGNAL", Enumerations.MESSAGE_ERROR)
		Global.root.top_ui.add_child(volume)
		volume_change_ref = volume
		volume.rect_global_position = Vector2(volume_button.rect_global_position.x,self.get_global_position().y - (self.rect_size.y / 1.2))
	else:
		volume_change_ref.exit_player_option()
		volume_change_ref = null


func _on_OutputDevice_pressed():
	if !output_device_visible:
		output_device_ref = load("res://src/Scenes/Main/Player/OutputDeviceSelection.tscn").instance()
		if output_device_ref.connect("tree_exited",self,"set_deferred",["output_device_visible",false]):
			Global.message("CONNECTING TREE EXITED SIGNAL TO set('output_device_visible',false) ", Enumerations.MESSAGE_ERROR)
		output_device_visible = true
		var pos : Vector2 = output_device.rect_global_position
		output_device_ref.set_global_position(Vector2(pos.x - 200,pos.y - self.rect_size.y))
		Global.root.top_ui.add_child(output_device_ref)
		output_device_ref.rect_global_position.y = OS.get_window_size().y - output_device_ref.rect_size.y
		output_device_ref.rect_global_position.x = output_device.rect_global_position.x - (output_device_ref.rect_size.x / 2) + (output_device.rect_size.x / 2)
	else:
		output_device_visible = false
		output_device_ref.unload_popup()


func _on_PlaybackTimer_timeout() -> void:
	playback_pos = MainStream.get_playback_position()
	playback_position.set_text(TimeFormatter.format_seconds(playback_pos))
	if !is_dragging:
		playback_slider.set_value(int(playback_pos))


func _on_PlaybackSlider_drag_ended(var _value_changed : bool):
	is_dragging = false
	var new_value : float = playback_slider.get_current_hover_value()
	playback_slider.value = new_value
	MainStream.seek(new_value)


func _on_PlaybackSlider_drag_started():
	is_dragging = true


func _on_Playlist_pressed():
	# updating playback position every timeout
	var playlist_title : String = song_playlist.uncut_string.substr(3)
	if playlist_title == "":
		Global.message("Cannot load empty Playlist/Album Title", Enumerations.MESSAGE_WARNING, true)
		return
	
	Global.pressed_playlist_idx = Playlist.get_playlist_index(playlist_title)
	if Global.pressed_playlist_idx >= 0 or Global.pressed_playlist_idx <= -3:
		Global.root.load_playlist(Global.pressed_playlist_idx)
	else:
		Global.root.load_temporary_playlist( 
			playlist_title,
			"",
			"",
			{"album" : [playlist_title]},
			1
		)


func _on_Artist_pressed():
	var artist : String = song_artist.uncut_string.substr(3)
	if artist == "":
		Global.message("Cannot load empty Artist Name", Enumerations.MESSAGE_WARNING, true)
		return
	
	Artist.load_artist_playlist(artist)


func prior_next_song(var direction : int) -> void:
	# if the Song that is currently playing is over the 5s mark and
	# the prior song button is pressed the song will be reset to zero,
	# without changing the song
	if direction == -1 and MainStream.get_playback_position() > 5.0:
		MainStream.seek(0.0)
		return;
	
	# no songs loaded
	if SongLists.AllSongs.size() == 0:
		return;
	
	if SongLists.is_song_from_queue:
		SongLists.queue_song_finished(direction)
	
	if SongLists.queue_idx != -1:
		var path : String = SongLists.song_queue.keys()[SongLists.queue_idx]
		var playlist_idx : int = SongLists.song_queue.get(path)
		var main_idx : int = AllSongs.get_main_idx(path)
		SongLists.is_song_from_queue = true
		Global.root.playback_song(
			main_idx,
			true,
			Playlist.get_playlist_name(playlist_idx)
		)
	elif SongLists.last_non_queued_song != "":
		#plays the next song from the last on the was NOT in the queue
		Global.root.unhighlight_current_song()
		SongLists.current_song = SongLists.last_non_queued_song
		Playback.change_song(direction)
		SongLists.last_non_queued_song = ""
	else:
		self.set_repeat(false)
		if !SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"Shuffle"):
			Playback.change_song(direction)
		else:
			Global.root.random_song()
	self.set_playback_button(1)


func update_player_covers(var _playlist_name : String = "", var reload_multiple_covers = true, var old_path : String = "", var new_path : String = "", var threading : bool = true) -> void:
	if AllSongs.get_main_idx(SongLists.current_song) == -1:
		return 

	# loading the covers from the file itself if there are more than one -> slow
	# loading the covers from the covercache if there is only one -> fast
	var new_coverhash : String = AllSongs.get_song_coverhash(AllSongs.get_main_idx(new_path))
	if Tagging.new().get_embedded_cover_count(new_path) > 1 or !reload_multiple_covers:
		# load multiple embedded covers
		if reload_multiple_covers and old_path != new_path or current_covers.size() == 0:
			var image_loader : ImageLoader = ImageLoader.new()
			var thread : Thread = Thread.new()
			if threading and thread.start(image_loader, "get_embedded_covers", new_path, Thread.PRIORITY_NORMAL) == OK:
				# temporarly setting the covers to the standard cover if thread was successfull
				Global.thread_of_multiple_covers = new_path
				var _err : int = image_loader.connect("covers_loaded", self, "on_multiple_covers_loaded", [thread], CONNECT_ONESHOT)
				current_covers = [ImageLoader.get_cover("", ImageLoader.ImageTypes.COVER)]
			else:
				# if thread could not be started covers will be loaded within the main thread
				current_covers = image_loader.get_embedded_covers(SongLists.current_song)[0]
				limit_cover_size()
	elif SongLists.new_cached_covers.has(new_coverhash):
		# load single covercache texture
		var is_new_cover : bool = true
		
		if old_path != "" and new_path != "":
			# only loading single cover for new song  if it has a different coverhash from the old one)
			is_new_cover = (AllSongs.get_song_coverhash(AllSongs.get_main_idx(old_path)) != new_coverhash) or current_covers.empty()
		
		if is_new_cover:
			current_covers = [ImageLoader.get_covercache_texture(new_coverhash)]
	else:
		# load playlist or standard cover
		current_covers = [ImageLoader.get_cover("", ImageLoader.ImageTypes.COVER, _playlist_name)]

	if current_covers.size() > 0:
		set_player_covers(0)
	else:
		info_cover.set_deferred("texture_normal", Global.std_cover)


func on_multiple_covers_loaded(var thread_instance : Thread) -> void:
	var output = thread_instance.wait_to_finish()
	if SongLists.current_song == Global.thread_of_multiple_covers:
		current_covers = output[0]
		limit_cover_size()
		set_player_covers(0)


func limit_cover_size(var max_size : int = 1500) -> void:
	# limiting temporarly saved covers to max_size x max_size pixels since everything above is waste
	for i in current_covers.size():
		if not current_covers[i] is ImageTexture:
			continue;
		current_covers[i] = ImageLoader.resize_texture(current_covers[i], Vector2(max_size,max_size))


func set_player_covers(var cover_idx : int) -> void:
	if cover_idx < current_covers.size():
		current_cover_idx = cover_idx
		info_cover.set_deferred("texture_normal", ImageLoader.resize_texture(current_covers[cover_idx], Vector2(info_cover.rect_size.x, info_cover.rect_size.x)))
		self.set_image_view_cover(current_covers[cover_idx], cover_idx)


func get_current_cover() -> Texture:
	if current_cover_idx == -1: return ImageLoader.get_cover("")
	return current_covers[current_cover_idx]


func set_image_view_cover(var cover : Texture, var cover_idx : int = -1) -> void:
	if image_view_ref:
		image_view_ref.image_view_cover.update_cover(cover, cover_idx, current_covers.size())
		image_view_ref.update_option()


func set_volume_texture(var is_mute : bool) -> void:
	if is_mute:
		volume_button.set_deferred("texture_normal", load("res://src/Assets/Icons/White/Audio/Volume/mute_72px.png"))
	else:
		volume_button.set_deferred("texture_normal", load("res://src/Assets/Icons/White/Audio/Volume/high volume_72px.png"))


func set_repeat(var toggle : bool) ->void:
	toggle_player_option(repeat_button, toggle)
	SettingsData.set_setting(SettingsData.GENERAL_SETTINGS,"Repeat", toggle)


func set_shuffle(var toggle : bool) -> void:
	toggle_player_option(shuffle_button, toggle)
	SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "Shuffle", toggle)


func toggle_player_option(var ref : Control, var toggle : bool) -> void:
	var _tw : PropertyTweener = get_tree().create_tween().tween_property(ref, "modulate:a", ENABLED_DISABLED_OPACITIES[int(toggle)], TW_DURATION)
