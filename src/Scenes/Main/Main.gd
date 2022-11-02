extends Control


#NODES
onready var UserProfileBox : PanelContainer = $MarginContainer/VBoxContainer/MiddlePart/VBoxContainer/HBoxContainer/SideBar/HBoxContainer/VBoxContainer/UserProfileBox
onready var Sidebar : ScrollContainer = $MarginContainer/VBoxContainer/MiddlePart/VBoxContainer/HBoxContainer/SideBar
onready var options : MarginContainer = $MarginContainer/VBoxContainer/MiddlePart/VBoxContainer/HBoxContainer/Option
onready var player : PanelContainer = $MarginContainer/VBoxContainer/Player
onready var middle_part : MarginContainer = $MarginContainer/VBoxContainer/MiddlePart
onready var WindowBar : PanelContainer = $MarginContainer/VBoxContainer/WindowBar
onready var play_button : TextureButton = player.play
onready var next_song : TextureButton = player.next_song
onready var prior_song : TextureButton = player.prior_song
onready var song_length_label : Label = player.get_node("Main/MainPlayer/Bottom/SongLength")
onready var title : Label = player.SongTitle
onready var artist : LinkButton = player.get_node("Main/SongInfo/Info/Infos/Artist")
onready var playlist : LinkButton = player.get_node("Main/SongInfo/Info/Infos/Playlist")
onready var cover : TextureButton = $MarginContainer/VBoxContainer/Player/Main/SongInfo/Info/Cover/Cover
onready var ResizeHandles : HBoxContainer = $MarginContainer/ResizeHandles
onready var mouse_stopper : Control = $MarginContainer/VBoxContainer/MiddlePart/MouseStopper
onready var TopUI : Control = $TopUI

#PRELOADS
#all the possible options that can be selected in the left sidebar menu
const all_songs : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/AllSongs/SongsNew.tscn")
const playlists : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/PlaylistGrid.tscn")
const AddFolder : PackedScene = preload("res://src/Scenes/SubOptions/Folders/SelectFolder.tscn")
const infos : PackedScene = preload("res://src/Scenes/SubOptions/InfoSettings/Infos.tscn")
const download : PackedScene = preload("res://src/Scenes/SubOptions/Downloader/Download.tscn")
const settings : PackedScene  = preload("res://src/Scenes/SubOptions/InfoSettings/NewSettings.tscn")
const stats : PackedScene = preload("res://src/Scenes/SubOptions/Stats/Stats.tscn")
const change_tags : PackedScene = preload("res://src/Scenes/SubOptions/Tagging/ChangeTags.tscn")
const artists : PackedScene = preload("res://src/Scenes/SubOptions/Artists/Artists.tscn")
const lyrics : PackedScene = preload("res://src/Scenes/SubOptions/Lyrics/LyricsProjects.tscn")
const MessageContainer : PackedScene = preload("res://src/scenes/ErrorHandling/MessageContainer.tscn")
const GeneralDialogue : PackedScene = preload("res://src/scenes/General/GeneralFileDialogue.tscn")
const NormalPlaylistTemplate : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/NormalPlaylist/Playlist.tscn")
const SmartPlaylistTemplate : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/SmartPlaylist.tscn")

#VARIABLES
var CurrentOption : int = -1
var SongSpaceOption : Control = null
var DisabledCounter : int = 0


func _notification(what):
	#toggles the mouse stopper to prevent unintended inputs when reentering focus
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		#Setting the Framerate to one per second if window is unfocused
		#why 1 seconds -> for the PlaybackSlider to work
		#why not low processor mode -> that only works if nothing changes on the screen
		#but here the playback slider always moves once per seconds sop it never activates
		#DRAMATICALLY drecreases the Performance need in the background
		#GPU -> 9 - 11% to 0,1 - 0,2%
		#CPU -> 1,5 - 3% -> 0% [without audio effects, with them way higher but still way lower]
		#if Global.AnimationsRunning != 0:
			#Waiting for important animations to finish before dramativ framerate decrease
			#BUGGY REWORK NEEDED!!
		#	yield(Global,"AnimationsFinished")
		#if options.get_child(0).get("songs"):
		#	if options.get_child(0).songs.get_parent().CurrentScrollSpeed != 0:
		#		yield(options.get_child(0).songs.get_parent(),"decelerated")
		ToggleSongScrollerInput(false)
		get_tree().get_root().set_disable_input(true)
		Global.LowFPS = true
		Engine.set_target_fps(4)
		#Engine.set_iterations_per_second(1)
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		#resetting the engine frame rate to 60 for many mouse detections to work
		Global.LowFPS = false
		Engine.set_target_fps(60)
		#Engine.set_iterations_per_second(60)
		#only disables the mouse stopper if it wasn't enabled manually prior
		ToggleSongScrollerInput(true)
		get_tree().get_root().set_disable_input(false)


func _unhandled_key_input(event):
	#Here all of the options to control the App via Keys is located
	#They need to be in unhabdled input so that when they are actually
	#needed for example a lineedit they won't randomly pause and unpause the music
	if event.is_pressed():
		if !Input.is_key_pressed(KEY_CONTROL):
			#Load Options Shortcut L + First Character of Option
			if Input.is_key_pressed(KEY_L):
				match event.scancode:
					KEY_O:
						#Loading Settings
						LoadOptions(0, true)
					KEY_P:
						#Loading Playlists
						LoadOptions(1, true)
					KEY_F:
						#Loading Select Folders
						LoadOptions(2, true)
					KEY_A:
						#Loading Artists
						LoadOptions(3, true)
					KEY_C:
						#Loading Change Tags
						LoadOptions(4, true)
					KEY_D:
						#Loading Downloads
						LoadOptions(5, true)
					KEY_Y:
						#Loading Lyrics
						LoadOptions(6, true)
					KEY_S:
						#Loading Stats
						LoadOptions(7, true)
					KEY_E:
						#Loading Settings
						LoadOptions(8, true)
			
			#Random Shortcuts
			match event.get_scancode():
				KEY_SPACE:
					#A unhandled Space Press toggles the music
					player._on_Play_Pause_pressed()
				KEY_S:
					#Toggling the Shuffle feature
					player._on_Shuffle_pressed()
				KEY_R:
					#Toggling Song Repeat Mode
					player._on_RepeatMode_pressed()
				KEY_I:
					#Toggling Image View
					player._on_Cover_pressed()
				#KEY_LEFT:
				#	#Backwards thge Current Song 5s
				#	MainStream.seek( MainStream.get_playback_position() - 5.0 )
				#KEY_RIGHT:
				#	#Forwards thge Current Song 5s
				#	MainStream.seek( MainStream.get_playback_position() + 5.0 )


func _ready():
	InitMain(true)


func InitMain(var Load : bool = false) -> void:
	if Global.CurrentProfileIdx != -1:
		#Connecting User Profile Box
		UserProfileBox.InitProfileBox()
		if !self.is_connected("resized",Sidebar,"UpdateSidebar"):
			var _err = self.connect("resized",Sidebar,"UpdateSidebar")
		if !UserProfileBox.LoadUserSelect.is_connected("pressed",self,"LoadUserProfileSelection"):
			var _err = UserProfileBox.LoadUserSelect.connect("pressed",self,"LoadUserProfileSelection")
		
		#Connecting a Signal form the Windowbar when the Window gets maximized or unmaximized
		#hides the resize handles on a true signal
		if !WindowBar.is_connected("WindowMaximized",ResizeHandles,"set_deferred"):
			if WindowBar.connect("WindowMaximized",ResizeHandles,"set_deferred"):
				Global.root.Message("CONNECTING WINDOW MAXIMIZED SIGNAL TO RESIZE HANDLE TOGGLE", SaveData.MESSAGE_ERROR)
		
		#Only Resets if the selected Profiles is NOT the one used before
		if Global.GetCurrentUser() != Global.PriorUser or Load:
			LoadOptions(0, true)
			#Loading Current Song
			if SongLists.CurrentSong != "":
				PlaySong(
					AllSongs.GetMainIdx(SongLists.CurrentSong),
					false,
					Playlist.GetPlaylistName(SongLists.CurrentPlayList)
				)
			else:
				#Resetting
				MainStream.ReloadStreamTimer(true)
				MainStream.set_stream(null)
				SetPlayerImg(0)
				player.InitPlayer()
	else:
		LoadUserProfileSelection()


func LoadUserProfileSelection() -> void:
	#Saving AudioEffects
	SongLists.SaveUserSpecificData( SongLists.AddUsersToFilepaths(SongLists.FilePaths) )
	
	var x = load("res://src/Scenes/UserProfiles/UserProfileSelection.tscn").instance()
	var _err = x.connect("tree_exited",self,"InitMain")
	middle_part.call_deferred("add_child",x)


#doesn't play unless said so -> play : bool
func PlaySong(var main_idx : int, var play : bool = false, var _PlaylistName : String = ""):
	if SongLists.CurrentPlayList == Playlist.GetPlaylistIndex(_PlaylistName) and AllSongs.GetSongPath(main_idx) == SongLists.CurrentSong:
		#if the song that was just presed is the same that was playing
		#the AudioPlayer justs seeks the start instead of loading the song from scratch
		MainStream.seek(0.0)
		MainStream.ReloadStreamTimer()
	
	var file = File.new()
	var song_path : String = AllSongs.GetSongPath(main_idx)
	if file.open(song_path, File.READ) == OK:
		
		#GET DATA
		var song_data : PoolByteArray = file.get_buffer(file.get_len())
		
		#CHECK MUSIC FORMAT WITH HEADER
		var RealFormatFlag : int = FormatChecker.GetMusicFormat(song_data.subarray(0,1024).hex_encode())
		if RealFormatFlag == -1:
			RealFormatFlag = FormatChecker.FileNameFormat(song_path) 
		
		#CREATE STREAM
		var stream = null
		match RealFormatFlag:
			0:
				stream = AudioStreamOGGVorbis.new()
			1:
				stream = AudioStreamMP3.new()
			2:
				stream = AudioStreamSample.new()
				
				#Set WAV Properties
				var WavProperties : WAV = WAV.new()
				var FmtOffset : int = WavProperties.FindFMTInFile(song_data)
				var Header : PoolByteArray = song_data.subarray(0,45 + FmtOffset)
				if FmtOffset == -1:
					#if a the "fmt " specifier could not be found the song will be skipped
					RealFormatFlag = -1
					
				var FormatType : int = WavProperties.GetWAVFormatType(Header, FmtOffset)
				if FormatType <= 2:
					stream.format = FormatType
				else:
					Message("UNKNOWN WAV FORMAT: " + str(FormatType), SaveData.MESSAGE_ERROR)
					RealFormatFlag = -1
				
				song_data = song_data.subarray( 128 * 10, song_data.size() - 1 )
				stream.stereo = WavProperties.IsChannelTypeStereo(Header, FmtOffset)
				stream.mix_rate = WavProperties.GetMixRate(Header, FmtOffset)
				
				var BitsPerSample : int = WavProperties.GetBitsPerSample(Header, FmtOffset)
				if BitsPerSample > 16:
					#24Bit, 32Bits per sample 
					#song_data = WavProperties.Convert32And24BitsTo16(song_data, BitsPerSample)
					RealFormatFlag = -1
				
				song_data = WavProperties.AudioPopWorkAround(song_data)
			-1:
				pass
		
		if RealFormatFlag != -1 and RealFormatFlag != 3 and RealFormatFlag != 4 and RealFormatFlag != 5:
			stream.data = song_data
			
			#Setting Stream
			MainStream.set_stream(stream)
			if !MainStream.stream:
				#Last Check to see if the decoding of Music Data worked
				Message("Unsupported Musicformat -> Failed to Decode: " + song_path, SaveData.MESSAGE_ERROR)
				SkipSong(main_idx)
			
			#Updating Player Music replay data
			var song_length : float = MainStream.stream.get_length()
			song_length_label.text = TimeFormatter.FormatSeconds(song_length)
			player.PlaybackSlider.max_value = int(song_length)
			
			#Updating Current Song
			SongLists.SetCurrentSong(AllSongs.GetSongPath(main_idx))
			
			#Update Player Infos
			UpdatePlayerInfos()
			
			#Play
			MainStream.play(0)
			if !play:
				SetPlayerImg(0)
				MainStream.seek(SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"PlaybackPosition"))
				MainStream.set_stream_paused(true)
				#pauses the stream timer on start
				MainStream.ReloadStreamTimer(true)
			else:
				SetPlayerImg(1)
				MainStream.set_stream_paused(false)
				MainStream.ReloadStreamTimer()
		else:
			Message("Unsupported Fileformat: " + song_path, SaveData.MESSAGE_ERROR)
			SkipSong(main_idx)
	else:
		Message("Could not open specified song path:" + song_path, SaveData.MESSAGE_ERROR)
		SkipSong(main_idx)
	file.close()


func SkipSong(var main_idx : int) -> void:
	#skips to the next Song if the Header FileFormat is not supported or the path couldn't be opened
	#when loading Veles checks for the Filename extension not the "REAL" format
	SongLists.SetCurrentSong(AllSongs.GetSongPath(main_idx))
	ChangeSong(+1)


func LoadOptions(var index : int, var ignore_same : bool = false):
	var del : bool = true
	#if there isn't an option loaded it won't try to free it
	if CurrentOption == -1:
		del = false
	if CurrentOption != index or ignore_same:
		var option : Control
		match index:
			0:
				option = all_songs.instance()
			1:
				option = playlists.instance()
			2:
				option = AddFolder.instance()
			3:
				option = artists.instance()
			4:
				option = change_tags.instance()
			5:
				option = download.instance()
			6:
				option = lyrics.instance()
			7:
				option = stats.instance()
			8:
				option = settings.instance()
			9:
				option = infos.instance()
		if del:
			#frees more than one option in a loop just in case
			FreeOptions()
		
		#Disabling Input in the Loading time of the Option
		self.set_process_input(false)
		var _err = option.connect("ready",self,"set_process_input", [true],CONNECT_ONESHOT)
		
		#Adding option to SceneTree
		Message("LOADED OPTION: " + str(index), SaveData.MESSAGE_NOTICE)
		AddOption(option)
		CurrentOption = index
		ResetInputDisabler()


func ReloadCurrentOption() -> void:
	LoadOptions(CurrentOption,true)


func AddOption(var option : Control) -> void:
	options.add_child(option)


func FreeOptions() -> void:
	#even though the options should only habe one child
	#if something goes wrong looping thourgh all possible children shoudl fix everything again
	#remove_child() is also called since the child needs to be removed immediately from the options Node for the Highlighting to work properlay
	for n in options.get_children():
		n.queue_free()
		options.remove_child(n)


func ChangeSong(var direction : int) -> void:
	if !SongLists.AllSongs.has(SongLists.CurrentSong):
		return;
	
	var next_main_idx : int =  0 
	var curr_main_idx : int = SongLists.AllSongs.get(SongLists.CurrentSong)[2]
	if SongLists.CurrentPlayList == -1:
		if SongLists.AllSongs.size() -1 > curr_main_idx and curr_main_idx + direction > 0:
			next_main_idx = curr_main_idx + direction
		else:
			#wraps around to first Song if at the end
			#or stays at the first if trying to go furthzer prior
			next_main_idx = 0
	else:
		var playlist_n : Dictionary
		
		if SongLists.CurrentPlayList >= 0:
			playlist_n = SongLists.Playlists.values()[SongLists.CurrentPlayList]
		
		elif SongLists.CurrentPlayList <= -2:
			playlist_n = SongLists.CurrentTempSmartPlaylist
		
		else:
			#if playlist that is currently playing has been deleted
			#redirects to AllSongs
			playlist_n = SongLists.AllSongs
			SongLists.CurrentPlayList = -1
		
		var idx_in_playlist : int = -1
		for n in playlist_n.size():
			#finding the index of the current song inside the playlist
			if playlist_n.keys()[n] == SongLists.CurrentSong:
				if playlist_n.size()  >  n + direction and n + direction >= 0:
					idx_in_playlist = n + direction
				else:
					idx_in_playlist = 0
				break;
		#getting the main idx
		#it is safer to search the path (playlist_n.keys()[idx_in_playlist]) in the AllSongs Dictionary 
		#since the main index can change when reloading AllSongs
		next_main_idx = AllSongs.GetMainIdx(playlist_n.keys()[idx_in_playlist])
	var path : String = AllSongs.GetSongPath( next_main_idx )
	
	UpdateHighlightedSong(path)
	PlaySong(
		next_main_idx,
		true,
		Playlist.GetPlaylistName(SongLists.CurrentPlayList)
	)


func RandomSong() -> void:
	randomize()
	var random_song_idx : int = 0

	if SongLists.CurrentPlayList == -1:
		#AllSongs
		random_song_idx = randi() % SongLists.AllSongs.size()
	
	elif SongLists.CurrentPlayList >= 0:
		#Normal Playlist
		var playlist_idx : int = SongLists.CurrentPlayList
		var temp = randi() % SongLists.Playlists.values()[playlist_idx].size()
		
		var random_song_path : String  = SongLists.Playlists.values()[playlist_idx].keys()[temp]
		random_song_idx = AllSongs.GetMainIdx(random_song_path)
	
	else:
		#Smart Playlist/Automaticly Created
		var temp = randi() % SongLists.CurrentTempSmartPlaylist.size()
		random_song_idx = AllSongs.GetMainIdx( SongLists.CurrentTempSmartPlaylist.keys()[temp] )
	UpdateHighlightedSong(AllSongs.GetSongPath(random_song_idx))
	PlaySong(
		random_song_idx,
		true,
		Playlist.GetPlaylistName(SongLists.CurrentPlayList)
	)


func UpdateHighlightedSong(var NextHighlighted : String) -> void:
	#checks first if either AllSongs or a Playlist are shown
	if options.get_child(0).get("songs") != null:
		var highlighted_song : int = options.get_child(0).SongListHasThis(SongLists.CurrentSong)
		if  options.get_child(0).get("songs").get_child_count() < highlighted_song:
			#if a song is next from another Playlist  that is bigger
			return
		#if a song is currently highlighted
		if highlighted_song != -1:
			options.get_child(0).UnHighlightSong(highlighted_song)
			var NextHighlightedIdx : int = options.get_child(0).SongListHasThis(NextHighlighted)
			if NextHighlightedIdx == -1:
				return
			options.get_child(0).HighlightSong(options.get_child(0).songs.get_child( NextHighlightedIdx ) )


func LoadTemporaryPlaylist(var TemporaryPlaylistTitle : String, var PlaylistDescriptionPath : String, var PlaylistCoverPath : String) -> void:
	Global.PlaylistPressed = -2
	SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS, "TempPlaylistTitle", TemporaryPlaylistTitle)
	DeleteCurrentoption()
	var NewTempPlaylist : Control = SmartPlaylistTemplate.instance()
	options.add_child( NewTempPlaylist )
	NewTempPlaylist.NReady( SongLists.TempPlaylistConditions,TemporaryPlaylistTitle,PlaylistDescriptionPath, PlaylistCoverPath )


func LoadLyricEditor(var ProjectPath : String = "") -> void:
	DeleteCurrentoption()
	var x = load("res://src/Scenes/SubOptions/Lyrics/LyricsEditor.tscn").instance()
	options.add_child( x )
	x.get_child(0).NReady(ProjectPath)


func SetPlayerImg(var flag : int) -> void:
	match flag:
		0:
			play_button.set_normal_texture(Global.play_img)
		1:
			play_button.set_normal_texture(Global.pause_img)


func Message(var message : String,var message_type : int, var display : bool = false, var bg_clr : Color = Color("9d9d9d")) -> void:
	message = message.to_upper()
	SaveData.LogMessage(message,message_type)
	if display:
		Global.DisplayedMessage = message;
		var MessageRef : Control = MessageContainer.instance()
		self.add_child(MessageRef)
		MessageRef.SetBackgroundColor(bg_clr)


func ToggleSongScrollerInput(var x : bool) -> void:
	#if the toggle gets set to disabled it will be counted
	#so that if it f.e. disabled by the volume and image view, the Songscroller cannot
	#be used when just on of them enabled the Scroller, event though one of them is still there
	
	if options.get_child_count() > 0:
		if options.get_child(0).get("songs"):
			if !x:
				DisabledCounter += 1;
				Global.InputToggler(options.get_child(0).songs.get_parent(),false)
			else:
				DisabledCounter -= 1;
				if DisabledCounter < 0:
					DisabledCounter = 0;
					Message("PROCESS INPUT DISIABLER FOR SONG SCROLLER CALLED WITH MULTIPLE DISABLERS", SaveData.MESSAGE_WARNING)
				if DisabledCounter == 0:
					Global.InputToggler(options.get_child(0).songs.get_parent(),true)


func ResetInputDisabler() -> void:
	DisabledCounter = 0
	if options.get_child(0).get("songs"):
		Global.InputToggler(options.get_child(0).songs.get_parent(),true)


func DeleteCurrentoption() -> void:
	var ToBeDeleted = options.get_child(0)
	options.remove_child(ToBeDeleted)
	ToBeDeleted.queue_free()


#Creates an Insatance of the General FileDialogue and Autromatically sets thew text where needed
func OpenGeneralFileDialogue(var NodeRef : Object, var OpenMode : int, var FileAccess : int, var Method : String,
		var MethodArgs : Array, var FileType : String, var FileTypeFilters : PoolStringArray = [],
		var ReturnString : bool  = false, var TitleOverride : String = "") -> Node:
	var dialog = GeneralDialogue.instance()
	TopUI.add_child(dialog)
	if dialog.connect("SelectionMade",NodeRef,Method, MethodArgs):
		Message("Couldn't not connect Folder Selection to General File Dialogue", SaveData.MESSAGE_ERROR)
	dialog.NReady(OpenMode,FileAccess,FileType, FileTypeFilters, ReturnString, TitleOverride)
	return dialog


func LoadPlaylist(var PlaylistIdx : int) -> void:
	DeleteCurrentoption()
	var PlaylistTemplate : Node = null
	
	if PlaylistIdx >= 0:
		PlaylistTemplate = NormalPlaylistTemplate.instance()
		options.add_child(PlaylistTemplate)
	else:
		PlaylistTemplate = SmartPlaylistTemplate.instance()
		options.add_child(PlaylistTemplate)
		PlaylistTemplate.NReady()


func UpdatePlayerInfos() -> void:
	var MainIdx : int = AllSongs.GetMainIdx(SongLists.CurrentSong)
	var PlalistText : String = ""
	
	#Title
	player.SongTitle.set_text( AllSongs.SongTitle(MainIdx) )
	
	#Artist
	player.SongArtist.set_text("by " +  AllSongs.GetSongArtist(MainIdx) )
	
	#Playlist Label
	if SettingsData.GetSetting(SettingsData.PLAYLIST_ALBUM_SETTINGS,"PlaylistSpaceText") == 0:
		PlalistText = Playlist.GetPlaylistName( SongLists.CurrentPlayList )
	else:
		PlalistText = Tags.GetAlbum(SongLists.CurrentSong)
	player.SongPlaylist.set_text("in " +  PlalistText )
	
	#Covers
	player.UpdatePlayerCovers(
		Playlist.GetPlaylistName(
			SongLists.CurrentPlayList
		)
	)
