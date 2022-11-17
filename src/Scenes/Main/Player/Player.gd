extends Control
# a script controlling the bottom part of the main scene -> player

enum ViewMode {
	NORMAL_VIEW = 0,
	COVER_VIEW = 1,
}

const VOLUME_CHANGER : PackedScene = preload("res://src/Scenes/Main/Player/VolumeChanger.tscn")
const IMAGE_VIEW : PackedScene = preload("res://src/Scenes/Views/ImageView.tscn")
const TW_DURATION : float = 0.1

var view : int = 0
var effects_ref = null
var effects_visible : bool = false
var playback_pos : float
var output_device_visible : bool = false
var output_device_ref : Control = null
var volume_change_ref : Control = null
var viewer_control : Control = null

onready var prior_song : TextureButton = $Main/MainPlayer/Middle/HBoxContainer/PriorSong
onready var next_song : TextureButton = $Main/MainPlayer/Middle/HBoxContainer/NextSong
onready var playback_button : TextureButton = $Main/MainPlayer/Middle/HBoxContainer/Playback
onready var info_cover : TextureButton = $Main/SongInfo/Info/Cover/Cover
onready var repeat_button : TextureButton = $Main/MainPlayer/Middle/Repeat
onready var shuffle_button : TextureButton = $Main/MainPlayer/Middle/Shuffle
onready var volume_button : TextureButton = $Main/Additional/Volume/Volume
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
		SettingsData.get_setting(SettingsData.DESIGN_SETTINGS,"PlayerBackground")
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
		# waits for the root function to be ready before loadiung the image view on startup :/
		yield(get_owner(),"ready")
		_on_Cover_pressed()
	
	# connecting signals
	var buttons : Array = [
		playback_button,prior_song,next_song,repeat_button,shuffle_button, song_artist,
		song_playlist, output_device, volume_button, audio_effects_button, song_options
	]
	
	for n in buttons.size():
		
		# mouse Entered
		if !buttons[n].is_connected("mouse_entered",Modulator,"modulate_hover"):
			if buttons[n].connect("mouse_entered", Modulator, "modulate_hover", [ buttons[n] ]):
				Global.root.message("CONNECTING MOUSE ENTERED SIGNAL TO PLAYER BUTTONS", SaveData.MESSAGE_ERROR)
		
		# mouse Exited
		if !buttons[n].is_connected("mouse_exited",Modulator,"modulate_normal"):
			if buttons[n].connect("mouse_exited",Modulator,"modulate_normal",[ buttons[n] ]):
				Global.root.message("CONNECTING MOUSE EXITED SIGNAL TO PLAYER BUTTONS", SaveData.MESSAGE_ERROR)
		
		# button Down
		if !buttons[n].is_connected("button_down",Modulator,"modulate_pressed"):
			if buttons[n].connect("button_down",Modulator,"modulate_pressed",[ buttons[n] ]):
				Global.root.message("CONNECTING BUTTON DOWN TO SIGNAL TO PLAYER BUTTONS", SaveData.MESSAGE_ERROR)
		
		# button Up
		if !buttons[n].is_connected("button_up",Modulator,"modulate_hover"):
			if buttons[n].connect("button_up",Modulator,"modulate_hover",[ buttons[n] ]):
				Global.root.message("CONNECTING BUTTON UP TO SIGNAL TO PLAYER BUTTONS", SaveData.MESSAGE_ERROR)
	
	# connecting Next/Prior Song Buttons
	if !next_song.is_connected("pressed",self,"prior_next_song"):
		if next_song.connect("pressed",self,"prior_next_song",[+1]):
				Global.root.message("CONNECTING PRESSED SIGNAL TO NEXT SONG BUTTON", SaveData.MESSAGE_ERROR)
	if !prior_song.is_connected("pressed",self,"prior_next_song"):
		if prior_song.connect("pressed",self,"prior_next_song",[-1]):
			Global.root.message("CONNECTING PRESSED SIGNAL TO NEXT SONG BUTTON", SaveData.MESSAGE_ERROR)
	
	# connecting volume button to MainStream -> bus_mute signal
	if !MainStream.is_connected("bus_mute",self,"set_volume_texture"):
		if MainStream.connect("bus_mute",self,"set_volume_texture"):
			Global.root.message("CONNECTING MAINSTREAM BUS MUTE TO SET VOLUME BUTTON TEXTURE", SaveData.MESSAGE_ERROR)


func _on_Playback_pressed():
	if MainStream.stream:
		if !MainStream.get_stream_paused():
			set_playback_button(0)
			MainStream.set_stream_paused(true)
			MainStream.StreamTimer.set_deferred("paused",true)
		else:
			set_playback_button(1)
			MainStream.set_stream_paused(false)
			MainStream.StreamTimer.set_deferred("paused",false)


func _on_PlaybackSlider_value_changed(value):
	# only changes the value of the Playback slider if the difference
	# in either direction is greater than 1 second
	# allows scrolling and won't cause accidental scrolling
	if abs(value - MainStream.get_playback_position()) > 1:
		MainStream.seek(value)


func _on_RepeatMode_pressed():
	if !SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"Repeat"):
		var _tw : PropertyTweener = create_tween().tween_property(repeat_button, "modulate:a", 1.0, TW_DURATION )
		SettingsData.set_setting(SettingsData.GENERAL_SETTINGS,"Repeat",true)
	else:
		var _tw : PropertyTweener = create_tween().tween_property(repeat_button, "modulate:a", 0.5, TW_DURATION )
		SettingsData.set_setting(SettingsData.GENERAL_SETTINGS,"Repeat",false)


func _on_Shuffle_pressed():
	if shuffle_button.modulate.a == 0.5:
		var _tw : PropertyTweener = create_tween().tween_property(shuffle_button, "modulate:a", 1.0, TW_DURATION )
		SettingsData.set_setting(SettingsData.GENERAL_SETTINGS,"Shuffle",true)
	else:
		SettingsData.set_setting(SettingsData.GENERAL_SETTINGS,"Shuffle",false)
		var _tw : PropertyTweener = create_tween().tween_property(shuffle_button, "modulate:a", 0.5, TW_DURATION )


func _on_Cover_pressed():
	if view == ViewMode.NORMAL_VIEW:
		#root.middle_part.get_child(0).hide()
		SettingsData.set_setting(SettingsData.GENERAL_SETTINGS,"ImageViewActivated",true)
		viewer_control = IMAGE_VIEW.instance()
		view = ViewMode.COVER_VIEW
		Global.root.middle_part.add_child(viewer_control)
		update_player_covers( Playlist.get_playlist_name(SongLists.current_playlist_idx) )
	else:
		SettingsData.set_setting(SettingsData.GENERAL_SETTINGS,"ImageViewActivated",false)
		viewer_control.end()
		view = ViewMode.NORMAL_VIEW


func _on_Effects_pressed():
	if !effects_visible:
		effects_visible = true
		effects_ref = load("res://src/Scenes/SubOptions/AudioEffects/Effects/NewAudioEffects.tscn").instance()
		var _err = effects_ref.connect("tree_exited",self,"set",["effects_visible",false])
		Global.root.middle_part.add_child(effects_ref)
	else:
		effects_ref.FreeAudioEffects()


func _on_Volume_pressed():
	if volume_change_ref == null:
		var Volume = VOLUME_CHANGER.instance()
		
		if Volume.connect("tree_exited",self,"set",["volume_change_ref",null]):
			Global.root.message("CONNECTING VOLUME CHANGER IN PLAYER TO TREE EXITED SIGNAL", SaveData.MESSAGE_ERROR)
		Global.root.top_ui.add_child(Volume)
		volume_change_ref = Volume
		Volume.rect_global_position = Vector2(volume_button.rect_global_position.x,self.get_global_position().y - (self.rect_size.y / 1.2))
	else:
		volume_change_ref.exit_player_option()
		volume_change_ref = null


func _on_OutputDevice_pressed():
	if !output_device_visible:
		output_device_ref = load("res://src/Scenes/Main/Player/OutputDeviceSelection.tscn").instance()
		if output_device_ref.connect("tree_exited",self,"set_deferred",["output_device_visible",false]):
			Global.root.message("CONNECTING TREE EXITED SIGNAL TO set('output_device_visible',false) ", SaveData.MESSAGE_ERROR)
		output_device_visible = true
		var pos : Vector2 = output_device.rect_global_position
		output_device_ref.set_global_position(Vector2(pos.x - 200,pos.y - self.rect_size.y))
		Global.root.top_ui.add_child(output_device_ref)
		output_device_ref.rect_global_position.y = OS.get_window_size().y - output_device_ref.rect_size.y
		output_device_ref.rect_global_position.x = output_device.rect_global_position.x - (output_device_ref.rect_size.x / 2) + (output_device.rect_size.x / 2)
	else:
		output_device_visible = false
		output_device_ref.exit_player_option()


func _on_PlaybackTimer_timeout() -> void:
	playback_pos = MainStream.get_playback_position()
	playback_position.set_text( TimeFormatter.format_seconds( playback_pos ) )
	playback_slider.set_value( int( playback_pos ) )


func _on_Playlist_pressed():
	# updating playback position every timeout
	Global.pressed_playlist_idx =  Playlist.get_playlist_index( song_playlist.get_text().replace("in ","") )
	if Global.pressed_playlist_idx >= 0 or Global.pressed_playlist_idx <= -3:
		Global.root.load_playlist(Global.pressed_playlist_idx)


func _on_Artist_pressed():
	var Artist : String = song_artist.get_text().substr(3)
	SongLists.temporary_playlist_conditions = {
		"includes_artist" : [ Artist ]
		}
	Global.root.load_temporary_playlist( 
		Artist,
		Global.get_current_user_data_folder() + "/Songs/Artists/Descriptions/" + Artist + ".txt",
		Global.get_current_user_data_folder() + "/Songs/Artists/Covers/" + Artist + ".png",
		3
	)
	disable_image_view()


func prior_next_song(var direction : int) -> void:
	#if the Song that is currently playing is over the 5s mark and
	#the prior song button is pressed the song will be reset to zero,
	#without changing the song
	if direction == -1:
		if MainStream.get_playback_position() > 5.0:
			update_player_covers()
			MainStream.seek(0.0)
			return;
	
	if SongLists.AllSongs.size() > 0:
		if SongLists.is_song_from_queue:
			SongLists.queue_song_finished()
		if SongLists.song_queue.empty() and SongLists.last_non_queued_song == "":
			set_repeat(false)
			if !SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"Shuffle"):
				Global.root.change_song(direction)
			else:
				Global.root.random_song()
		else:
			if !SongLists.song_queue.empty():
				var path : String = SongLists.song_queue.keys()[0]
				var playlist_idx : int = SongLists.song_queue.get(path)
				var main_idx : int = AllSongs.get_main_idx(path)
				SongLists.is_song_from_queue = true
				Global.root.update_highlighted_song(path)
				Global.root.playback_song(
					main_idx,
					true,
					Playlist.get_playlist_name(playlist_idx)
				)
			else:
				#plays the next song from the last on the was NOT in the queue
				Global.root.update_highlighted_song(SongLists.last_non_queued_song)
				SongLists.current_song = SongLists.last_non_queued_song
				Global.root.change_song(+1)
				SongLists.last_non_queued_song = ""
		set_playback_button(1)


func disable_image_view() -> void:
	if view == ViewMode.COVER_VIEW:
		viewer_control.end()
		view = ViewMode.NORMAL_VIEW


func update_player_covers(var playlist_name : String = "") -> void:
	if AllSongs.get_main_idx(SongLists.current_song) != -1:
		var CoverHash : String =  AllSongs.get_song_coverhash(AllSongs.get_main_idx(SongLists.current_song))
		var CacheImg = ImageLoader.get_covercache_texture(CoverHash, playlist_name)
		info_cover.set_deferred("texture_normal",CacheImg)
		set_image_view_cover( CacheImg )


func set_image_view_cover(var img : Texture) -> void:
	if view == ViewMode.COVER_VIEW:
		viewer_control.image_view_cover.set_normal_texture(img)
		viewer_control.UpdateOption()
		viewer_control.SetImageViewBackgroundColor()


func set_volume_texture(var is_mute : bool) -> void:
	if is_mute:
		volume_button.set_deferred("texture_normal", load("res://src/Assets/Icons/White/Audio/Volume/mute_72px.png"))
	else:
		volume_button.set_deferred("texture_normal", load("res://src/Assets/Icons/White/Audio/Volume/high volume_72px.png"))


func set_repeat(var x : bool) ->void:
	if !x:
		var _tw : PropertyTweener = create_tween().tween_property(repeat_button, "modulate:a", 0.5, TW_DURATION )
	else:
		var _tw : PropertyTweener = create_tween().tween_property(repeat_button, "modulate:a", 1.0, TW_DURATION )
	SettingsData.set_setting(SettingsData.GENERAL_SETTINGS,"Repeat",x)


func set_shuffle(var x : bool) -> void:
	if !x:
		var _tw : PropertyTweener = create_tween().tween_property(shuffle_button, "modulate:a", 0.5, TW_DURATION )
	else:
		var _tw : PropertyTweener = create_tween().tween_property(shuffle_button, "modulate:a", 1.0, TW_DURATION )
	SettingsData.set_setting(SettingsData.GENERAL_SETTINGS,"Shuffle",x)
