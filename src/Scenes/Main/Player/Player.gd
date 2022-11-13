extends Control


#ENUM
enum view_mode {
	NORMAL_VIEW = 0,
	COVER_VIEW = 1,
}

#NODES
onready var play : TextureButton = $Main/MainPlayer/Middle/HBoxContainer/Play
onready var prior_song : TextureButton = $Main/MainPlayer/Middle/HBoxContainer/PriorSong
onready var next_song : TextureButton = $Main/MainPlayer/Middle/HBoxContainer/NextSong
onready var PlayerInfoCover : TextureButton = $Main/SongInfo/Info/Cover/Cover
onready var repeat_button : TextureButton = $Main/MainPlayer/Middle/Repeat
onready var shuffle_button : TextureButton = $Main/MainPlayer/Middle/Shuffle
onready var VolumeButton : TextureButton = $Main/Additional/Volume/Volume
onready var root : Control = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)
onready var viewer_control : Control = null
onready var VolChangerRef : Control = null
onready var OutputDevice : TextureButton = $Main/Additional/OutputDevice
onready var PlaybackPosition : Label = $Main/MainPlayer/Bottom/PlaybackPosition
onready var PlaybackSlider : HSlider = $Main/MainPlayer/Bottom/PlaybackSlider
onready var SongTitle : Label = $Main/SongInfo/Info/Infos/Title
onready var SongArtist : LinkButton = $Main/SongInfo/Info/Infos/Artist
onready var SongPlaylist : LinkButton = $Main/SongInfo/Info/Infos/Playlist
onready var AudioEffects : TextureButton = $Main/Additional/Effects
onready var SongOptions : TextureButton = $Main/Additional/SongOptions

# PRELOADS
const VolumeChanger : PackedScene = preload("res://src/Scenes/Main/Player/VolumeChanger.tscn")
const image_view : PackedScene = preload("res://src/scenes/views/ImageView.tscn")

# CONSTANTS
const tw_duration : float = 0.1

# VARIABLES
var view : int = 0
var EffectsRef = null
var EffectsShown : bool = false
var PlaybackPos : float
var mouse_button_input : bool = false
var scrolling : bool = false
var repeat : bool = false
var shuffle : bool = false


func _ready():
	InitPlayer()
	#Background Color
	self.get_stylebox("panel").set_bg_color(
		SettingsData.GetSetting(SettingsData.DESIGN_SETTINGS,"PlayerBackground")
	)


func InitPlayer() -> void:
	#Reset Player Info
	SongTitle.set_text("")
	SongPlaylist.set_text("")
	SongArtist.set_text("")
	PlayerInfoCover.set_normal_texture(Global.std_music_cover)
	
	
	
	#setting the saved values
	set_repeat(SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"Repeat"))
	set_shuffle(SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"Shuffle"))
	if SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"ImageViewActivated"):
		#Waits for the root function to be ready before loadiung the image view on startup :/
		yield(get_owner(),"ready")
		_on_Cover_pressed()
	
	
	#Connectring Signals
	var buttons : Array = [
		play,prior_song,next_song,repeat_button,shuffle_button, SongArtist,
		SongPlaylist, OutputDevice, VolumeButton, AudioEffects, SongOptions
	]
	for n in buttons.size():
		
		#Mouse Entered
		if !buttons[n].is_connected("mouse_entered",Modulator,"modulate_hover"):
			if buttons[n].connect("mouse_entered", Modulator, "modulate_hover", [ buttons[n] ]):
				Global.root.Message("CONNECTING MOUSE ENTERED SIGNAL TO PLAYER BUTTONS", SaveData.MESSAGE_ERROR)
		
		#Mouse Exited
		if !buttons[n].is_connected("mouse_exited",Modulator,"modulate_normal"):
			if buttons[n].connect("mouse_exited",Modulator,"modulate_normal",[ buttons[n] ]):
				Global.root.Message("CONNECTING MOUSE EXITED SIGNAL TO PLAYER BUTTONS", SaveData.MESSAGE_ERROR)
		
		#Button Down
		if !buttons[n].is_connected("button_down",Modulator,"modulate_pressed"):
			if buttons[n].connect("button_down",Modulator,"modulate_pressed",[ buttons[n] ]):
				Global.root.Message("CONNECTING BUTTON DOWN TO SIGNAL TO PLAYER BUTTONS", SaveData.MESSAGE_ERROR)
		
		#Button Up
		if !buttons[n].is_connected("button_up",Modulator,"modulate_hover"):
			if buttons[n].connect("button_up",Modulator,"modulate_hover",[ buttons[n] ]):
				Global.root.Message("CONNECTING BUTTON UP TO SIGNAL TO PLAYER BUTTONS", SaveData.MESSAGE_ERROR)
	
	#Connecting Next/Prior Song Buttons
	if !next_song.is_connected("pressed",self,"PriorNextSongPressed"):
		if next_song.connect("pressed",self,"PriorNextSongPressed",[+1]):
				Global.root.Message("CONNECTING PRESSED SIGNAL TO NEXT SONG BUTTON", SaveData.MESSAGE_ERROR)
	if !prior_song.is_connected("pressed",self,"PriorNextSongPressed"):
		if prior_song.connect("pressed",self,"PriorNextSongPressed",[-1]):
			Global.root.Message("CONNECTING PRESSED SIGNAL TO NEXT SONG BUTTON", SaveData.MESSAGE_ERROR)
	
	# connecting volume button to MainStream -> bus_mute signal
	if !MainStream.is_connected("bus_mute",self,"set_volume_texture"):
		if MainStream.connect("bus_mute",self,"set_volume_texture"):
			Global.root.Message("CONNECTING MAINSTREAM BUS MUTE TO SET VOLUME BUTTON TEXTURE", SaveData.MESSAGE_ERROR)
	

func _on_Play_Pause_pressed():
	if MainStream.stream:
		if !MainStream.get_stream_paused():
			root.SetPlayerImg(0)
			MainStream.set_stream_paused(true)
			MainStream.StreamTimer.set_deferred("paused",true)
		else:
			root.SetPlayerImg(1)
			MainStream.set_stream_paused(false)
			MainStream.StreamTimer.set_deferred("paused",false)


func _on_PlaybackSlider_value_changed(value):
	#only changes the value of the Playback slider if the difference
	#in either direction is greater than 1 second
	#allows scrolling and won't cause accidental scrolling
	if abs(value - MainStream.get_playback_position()) > 1:
		MainStream.seek(value)


func PriorNextSongPressed(var direction : int) -> void:
	#if the Song that is currently playing is over the 5s mark and
	#the prior song button is pressed the song will be reset to zero,
	#without changing the song
	if direction == -1:
		if MainStream.get_playback_position() > 5.0:
			UpdatePlayerCovers()
			MainStream.seek(0.0)
			return;
	
	if SongLists.AllSongs.size() > 0:
		if SongLists.SongFromQueue:
			SongLists.QueueSongPassed()
		if SongLists.SongQueue.empty() and SongLists.LastRegularSong == "":
			set_repeat(false)
			if !SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"Shuffle"):
				root.ChangeSong(direction)
			else:
				root.RandomSong()
		else:
			if !SongLists.SongQueue.empty():
				var path : String = SongLists.SongQueue.keys()[0]
				var PlaylistIdx : int = SongLists.SongQueue.get(path)
				var main_idx : int = AllSongs.GetMainIdx(path)
				SongLists.SongFromQueue = true
				root.UpdateHighlightedSong(path)
				root.PlaySong(
					main_idx,
					true,
					Playlist.GetPlaylistName(PlaylistIdx)
				)
			else:
				#plays the next song from the last on the was NOT in the queue
				root.UpdateHighlightedSong(SongLists.LastRegularSong)
				SongLists.CurrentSong = SongLists.LastRegularSong
				root.ChangeSong(+1)
				SongLists.LastRegularSong = ""
		root.SetPlayerImg(1)


func _on_RepeatMode_pressed():
	if !SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"Repeat"):
		var _tw : PropertyTweener = create_tween().tween_property(repeat_button, "modulate:a", 1.0, tw_duration )
		SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"Repeat",true)
	else:
		var _tw : PropertyTweener = create_tween().tween_property(repeat_button, "modulate:a", 0.5, tw_duration )
		SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"Repeat",false)


func set_repeat(var x : bool) ->void:
	if !x:
		var _tw : PropertyTweener = create_tween().tween_property(repeat_button, "modulate:a", 0.5, tw_duration )
	else:
		var _tw : PropertyTweener = create_tween().tween_property(repeat_button, "modulate:a", 1.0, tw_duration )
	SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"Repeat",x)


func set_shuffle(var x : bool) -> void:
	if !x:
		var _tw : PropertyTweener = create_tween().tween_property(shuffle_button, "modulate:a", 0.5, tw_duration )
	else:
		var _tw : PropertyTweener = create_tween().tween_property(shuffle_button, "modulate:a", 1.0, tw_duration )
	SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"Shuffle",x)


func set_volume_texture(var is_mute : bool) -> void:
	if is_mute:
		VolumeButton.set_deferred("texture_normal", load("res://src/Assets/Icons/White/Audio/Volume/mute_72px.png"))
	else:
		VolumeButton.set_deferred("texture_normal", load("res://src/Assets/Icons/White/Audio/Volume/high volume_72px.png"))


func _on_Shuffle_pressed():
	if shuffle_button.modulate.a == 0.5:
		var _tw : PropertyTweener = create_tween().tween_property(shuffle_button, "modulate:a", 1.0, tw_duration )
		SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"Shuffle",true)
	else:
		SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"Shuffle",false)
		var _tw : PropertyTweener = create_tween().tween_property(shuffle_button, "modulate:a", 0.5, tw_duration )


func _on_Cover_pressed():
	if view == view_mode.NORMAL_VIEW:
		#root.middle_part.get_child(0).hide()
		SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"ImageViewActivated",true)
		viewer_control = image_view.instance()
		view = view_mode.COVER_VIEW
		root.middle_part.add_child(viewer_control)
		UpdatePlayerCovers( Playlist.GetPlaylistName(SongLists.CurrentPlayList) )
	else:
		SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"ImageViewActivated",false)
		viewer_control.end()
		view = view_mode.NORMAL_VIEW


func DisableImageView() -> void:
	if view == view_mode.COVER_VIEW:
		viewer_control.end()
		view = view_mode.NORMAL_VIEW


func SetImageViewCover(var img : Texture) -> void:
	if view == view_mode.COVER_VIEW:
		viewer_control.ImageViewCover.set_normal_texture(img)
		viewer_control.UpdateOption()
		viewer_control.SetImageViewBackgroundColor()


func OnEffectsPressed():
	if !EffectsShown:
		EffectsShown = true
		EffectsRef = load("res://src/Scenes/SubOptions/AudioEffects/Effects/NewAudioEffects.tscn").instance()
		var _err = EffectsRef.connect("tree_exited",self,"set",["EffectsShown",false])
		root.middle_part.add_child(EffectsRef)
	else:
		EffectsRef.FreeAudioEffects()


func UpdatePlayerCovers(var PlaylistName : String = "") -> void:
	if AllSongs.GetMainIdx(SongLists.CurrentSong) != -1:
		var CoverHash : String =  AllSongs.GetSongCoverHash(AllSongs.GetMainIdx(SongLists.CurrentSong))
		var CacheImg = ImageLoader.GetCoverCacheImageTexture(CoverHash, PlaylistName)
		PlayerInfoCover.set_deferred("texture_normal",CacheImg)
		SetImageViewCover( CacheImg )


func OnVolumePressed():
	if VolChangerRef == null:
		var Volume = VolumeChanger.instance()
		
		if Volume.connect("tree_exited",self,"set",["VolChangerRef",null]):
			Global.root.Message("CONNECTING VOLUME CHANGER IN PLAYER TO TREE EXITED SIGNAL", SaveData.MESSAGE_ERROR)
		root.TopUI.add_child(Volume)
		VolChangerRef = Volume
		Volume.rect_global_position = Vector2(VolumeButton.rect_global_position.x,self.get_global_position().y - (self.rect_size.y / 1.2))
	else:
		VolChangerRef.ExitPlayerOption()
		VolChangerRef = null


var OutputDeviceShown : bool = false
var OutputDeviceRef : Control = null

func _on_OutputDevice_pressed():
	if !OutputDeviceShown:
		OutputDeviceRef = load("res://src/Scenes/Main/Player/OutputDeviceSelection.tscn").instance()
		if OutputDeviceRef.connect("tree_exited",self,"set_deferred",["OutputDeviceShown",false]):
			Global.root.Message("CONNECTING TREE EXITED SIGNAL TO set('OutputDeviceShown',false) ", SaveData.MESSAGE_ERROR)
		OutputDeviceShown = true
		var pos : Vector2 = OutputDevice.rect_global_position
		OutputDeviceRef.set_global_position(Vector2(pos.x - 200,pos.y - self.rect_size.y))
		root.TopUI.add_child(OutputDeviceRef)
		OutputDeviceRef.rect_global_position.y = OS.get_window_size().y - OutputDeviceRef.rect_size.y
		OutputDeviceRef.rect_global_position.x = OutputDevice.rect_global_position.x - (OutputDeviceRef.rect_size.x / 2) + (OutputDevice.rect_size.x / 2)
	else:
		OutputDeviceShown = false
		OutputDeviceRef.ExitPlayerOption()


func SetPlayback() -> void:
	PlaybackPos = MainStream.get_playback_position()
	PlaybackPosition.set_text( TimeFormatter.FormatSeconds( PlaybackPos ) )
	PlaybackSlider.set_value( int( PlaybackPos ) )



func OnPlaylistLabelPressed():
	Global.PlaylistPressed =  Playlist.GetPlaylistIndex( SongPlaylist.get_text().replace("in ","") )
	if Global.PlaylistPressed >= 0 or Global.PlaylistPressed <= -3:
		root.LoadPlaylist(Global.PlaylistPressed)


func OnArtistPressed():
	var Artist : String = SongArtist.get_text().substr(3)
	SongLists.TempPlaylistConditions = {
		"IncludesArtist" : [ Artist ]
		}
	root.LoadTemporaryPlaylist( 
		Artist,
		Global.GetCurrentUserDataFolder() + "/Songs/Artists/Descriptions/" + Artist + ".txt",
		Global.GetCurrentUserDataFolder() + "/Songs/Artists/Covers/" + Artist + ".png",
		3
	)
	DisableImageView()
