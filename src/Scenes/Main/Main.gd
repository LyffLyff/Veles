extends Control
# main script always being loaded


# all the possible options that can be selected in the left sidebar menu
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

const MESSAGE_CONTAINER : PackedScene = preload("res://src/scenes/ErrorHandling/MessageContainer.tscn")
const GENERAL_DIALOGUE : PackedScene = preload("res://src/scenes/General/GeneralFileDialogue.tscn")
const NORMAL_PLAYLIST_TEMPLATE : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/NormalPlaylist/Playlist.tscn")
const SMART_PLAYLIST_TEMPLATE : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/SmartPlaylist.tscn")

var input_disable_counter : int = 0

onready var sidebar : ScrollContainer = $MarginContainer/VBoxContainer/MiddlePart/VBoxContainer/HBoxContainer/SideBar
onready var options : MarginContainer = $MarginContainer/VBoxContainer/MiddlePart/VBoxContainer/HBoxContainer/Option
onready var player : PanelContainer = $MarginContainer/VBoxContainer/Player
onready var middle_part : MarginContainer = $MarginContainer/VBoxContainer/MiddlePart
onready var window_bar : PanelContainer = $MarginContainer/VBoxContainer/WindowBar
onready var resize_handles : HBoxContainer = $MarginContainer/ResizeHandles
onready var mouse_stopper : Control = $MarginContainer/VBoxContainer/MiddlePart/MouseStopper
onready var top_ui : Control = $TopUI


func _ready():
	init_main(true)


func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		# setting the Framerate to one per second if window is unfocused
		# why? 1 seconds -> for the playback_slider to work
		# why not low processor mode -> that only works if nothing changes on the screen
		# but here the playback slider always moves once per seconds sop it never activates
		# DRAMATICALLY decreases the Performance need in the background
		# GPU -> 9 - 11% to 0,1 - 0,2%
		# CPU -> 1,5 - 3% -> 0% [without audio effects, with them way higher but still way lower]
		toggle_songlist_input(false)
		get_tree().get_root().set_disable_input(true)
		Global.LowFPS = true
		Engine.set_target_fps(4)
		#Engine.set_iterations_per_second(1)
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		# resetting the engine frame rate to 60 fps
		Global.LowFPS = false
		Engine.set_target_fps(60)
		toggle_songlist_input(true)
		get_tree().get_root().set_disable_input(false)


func _unhandled_key_input(event):
	# here all of the options to control the App via Keys is located
	# they need to be in unhabdled input so that when they are actually
	# needed for example a lineedit they won't randomly pause and unpause the music
	if event.is_pressed():
		if !Input.is_key_pressed(KEY_CONTROL):
			
			# load Options Shortcut L + first Character of Option (most of the time)
			if Input.is_key_pressed(KEY_L):
				match event.scancode:
					KEY_O:
						# loading Settings
						load_option(0, true)
					KEY_P:
						# loading Playlists
						load_option(1, true)
					KEY_F:
						# loading Select Folders
						load_option(2, true)
					KEY_A:
						# loading Artists
						load_option(3, true)
					KEY_C:
						# loading Change Tags
						load_option(4, true)
					KEY_D:
						#  loading Downloads
						load_option(5, true)
					KEY_Y:
						# loading Lyrics
						load_option(6, true)
					KEY_S:
						# loading Stats
						load_option(7, true)
					KEY_E:
						# loading Settings
						load_option(8, true)
			
			# random global Shortcuts
			match event.get_scancode():
				KEY_SPACE:
					# a unhandled space-key press toggles the music
					player._on_Playback_pressed()
				KEY_S:
					# toggling the Shuffle feature
					player._on_Shuffle_pressed()
				KEY_R:
					# toggling Song Repeat Mode
					player._on_RepeatMode_pressed()
				KEY_I:
					# toggling Image View
					player._on_Cover_pressed()


func init_main(var load_current_song : bool = false) -> void:
	if Global.CurrentProfileIdx != -1:
		
		# connecting User Profile Box
		sidebar.user_profile_container.InitProfileBox()
		sidebar.update_sidebar()
		if !self.is_connected("resized",sidebar,"update_sidebar"):
			var _err = self.connect("resized",sidebar,"update_sidebar")
		if !sidebar.user_profile_container.LoadUserSelect.is_connected("pressed",self,"load_user_profile_selection"):
			var _err = sidebar.user_profile_container.LoadUserSelect.connect("pressed",self,"load_user_profile_selection")
		
		# connecting a Signal form the Windowbar when the Window gets maximized or unmaximized
		# hides the resize handles on a true signal
		if !window_bar.is_connected("window_maximized",resize_handles,"set_deferred"):
			if window_bar.connect("window_maximized",resize_handles,"set_deferred"):
				message("CONNECTING WINDOW MAXIMIZED SIGNAL TO RESIZE HANDLE TOGGLE", SaveData.MESSAGE_ERROR)
		
		# only Resets if the selected Profiles is NOT the one used before
		if Global.GetCurrentUser() != Global.PriorUser or load_current_song:
			
			# loading all songs suboption
			load_option(0, true)
			
			# loading current sing
			if SongLists.CurrentSong != "":
				playback_song(
					AllSongs.get_main_idx(SongLists.CurrentSong),
					false,
					Playlist.get_playlist_name(SongLists.CurrentPlayList)
				)
			else:
				# resetting
				Playback.new().stop_playback()
	else:
		load_user_profile_selection()


func playback_song(var main_idx : int, var play : bool = false, var _PlaylistName : String = ""):
	# function that handles the replay of a given file 
	# only plays if play is true, otherwise just prepares and pauses
	if SongLists.CurrentPlayList == Playlist.get_playlist_index(_PlaylistName) and AllSongs.get_song_path(main_idx) == SongLists.CurrentSong:
		# if the song that was just presed is the same that was playing
		# the AudioPlayer justs seeks the start instead of loading the song from scratch
		MainStream.seek(0.0)
		MainStream.ReloadStreamTimer()
	
	var file = File.new()
	var song_path : String = AllSongs.get_song_path(main_idx)
	if file.open(song_path, File.READ) == OK:
		
		#GET DATA
		var song_data : PoolByteArray = file.get_buffer(file.get_len())
		
		#CHECK MUSIC FORMAT WITH HEADER
		var RealFormatFlag : int = FormatChecker.get_music_format_from_data(song_data.subarray(0,1024).hex_encode())
		if RealFormatFlag == -1:
			RealFormatFlag = FormatChecker.get_music_filename_extension(song_path) 
		
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
				var FmtOffset : int = WavProperties.find_fmt_in_file(song_data)
				var Header : PoolByteArray = song_data.subarray(0,45 + FmtOffset)
				if FmtOffset == -1:
					#if a the "fmt " specifier could not be found the song will be skipped
					RealFormatFlag = -1
					
				var FormatType : int = WavProperties.get_format_type(Header, FmtOffset)
				if FormatType <= 2:
					stream.format = FormatType
				else:
					message("UNKNOWN WAV FORMAT: " + str(FormatType), SaveData.MESSAGE_ERROR)
					RealFormatFlag = -1
				
				song_data = song_data.subarray( 128 * 10, song_data.size() - 1 )
				stream.stereo = WavProperties.is_channel_stereo(Header, FmtOffset)
				stream.mix_rate = WavProperties.get_mix_rate(Header, FmtOffset)
				
				var BitsPerSample : int = WavProperties.get_bits_per_sample(Header, FmtOffset)
				if BitsPerSample > 16:
					#24Bit, 32Bits per sample 
					#song_data = WavProperties.convert_32_and_24_to_16_bits(song_data, BitsPerSample)
					RealFormatFlag = -1
				
				song_data = WavProperties.audio_pop_workaround(song_data)
			-1:
				pass
		
		if RealFormatFlag != -1 and RealFormatFlag != 3 and RealFormatFlag != 4 and RealFormatFlag != 5:
			stream.data = song_data
			
			#Setting Stream
			MainStream.set_stream(stream)
			if !MainStream.stream:
				#Last Check to see if the decoding of Music Data worked
				message("Unsupported Musicformat -> Failed to Decode: " + song_path, SaveData.MESSAGE_ERROR)
				skip_song(main_idx)
			
			#Updating Player Music replay data
			var song_length : float = MainStream.stream.get_length()
			player.song_length.text = TimeFormatter.format_seconds(song_length)
			player.playback_slider.max_value = int(song_length)
			
			#Valid Song -> reset first skipped song
			Global.first_skipped_path = ""
			
			#Updating Current Song
			SongLists.SetCurrentSong(AllSongs.get_song_path(main_idx))
			
			#Update Player Infos
			update_player_infos()
			
			#Play
			MainStream.play(0)
			if !play:
				player.set_playback_button(0)
				MainStream.seek(SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"PlaybackPosition"))
				MainStream.set_stream_paused(true)
				#pauses the stream timer on start
				MainStream.ReloadStreamTimer(true)
			else:
				player.set_playback_button(1)
				MainStream.set_stream_paused(false)
				MainStream.ReloadStreamTimer()
		else:
			message("Unsupported Fileformat: " + song_path, SaveData.MESSAGE_ERROR)
			skip_song(main_idx)
	else:
		message("Could not open specified song path:" + song_path, SaveData.MESSAGE_ERROR)
		skip_song(main_idx)
	file.close()


func change_song(var direction : int) -> void:
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
		next_main_idx = AllSongs.get_main_idx(playlist_n.keys()[idx_in_playlist])
	var path : String = AllSongs.get_song_path( next_main_idx )
	
	update_highlighted_song(path)
	Global.last_direction = direction
	
	playback_song(
		next_main_idx,
		true,
		Playlist.get_playlist_name(SongLists.CurrentPlayList)
	)


func random_song() -> void:
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
		random_song_idx = AllSongs.get_main_idx(random_song_path)
	
	else:
		#Smart Playlist/Automaticly Created
		var temp = randi() % SongLists.CurrentTempSmartPlaylist.size()
		random_song_idx = AllSongs.get_main_idx( SongLists.CurrentTempSmartPlaylist.keys()[temp] )
	update_highlighted_song(AllSongs.get_song_path(random_song_idx))
	playback_song(
		random_song_idx,
		true,
		Playlist.get_playlist_name(SongLists.CurrentPlayList)
	)


func skip_song(var main_idx : int) -> void:
	# skips to the next Song if the Header FileFormat is not supported or the path couldn't be opened
	# when loading Veles checks for the Filename extension not the "REAL" format
	var path : String = AllSongs.get_song_path(main_idx)
	var to_next : bool = false
	if Global.first_skipped_path == path:
		# only skips if the first song that was skipped does is not the one that wants to be skipped
		# -> prevents an endless loop if EVERY song is invalid
		SongLists.SetCurrentSong("")
		MainStream.set_stream_paused(true)
		return
	else:
		to_next = true
	
	if Global.first_skipped_path == "":
		Global.first_skipped_path = path
		to_next = true
	
	if to_next:
		SongLists.SetCurrentSong(path)
		change_song(Global.last_direction)


func load_option(var index : int, var ignore_same : bool = false):
	var del : bool = true
	# if there isn't an option loaded it won't try to free it
	if sidebar.sub_options.CurrentOptionIdx == -1:
		del = false
	if sidebar.sub_options.CurrentOptionIdx != index or ignore_same:
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
			# frees more than one option in a loop just in case
			free_option()
		
		# disabling Input in the Loading time of the Option
		self.set_process_input(false)
		var _err = option.connect("ready",self,"set_process_input", [true],CONNECT_ONESHOT)
		
		# adding option to SceneTree
		message("LOADED OPTION: " + str(index), SaveData.MESSAGE_NOTICE)
		options.add_child(option)
		sidebar.sub_options.set_sidebar_option(index)
		reset_input_disabler()


func delete_current_option() -> void:
	# removes deletes the currently loaded option from node tree
	var to_delete : Node = options.get_child(0)
	options.remove_child(to_delete)
	to_delete.queue_free()


func reload_option() -> void:
	load_option(sidebar.sub_options.CurrentOptionIdx,true)


func free_option() -> void:
	# even though the options should only habe one child
	# if something goes wrong looping thourgh all possible children shoudl fix everything again
	# remove_child() is also called since the child needs to be removed immediately from the options Node for the Highlighting to work properlay
	for n in options.get_children():
		n.queue_free()
		options.remove_child(n)


func update_highlighted_song(var NextHighlighted : String) -> void:
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


func message(var message : String,var message_type : int, var display : bool = false, var bg_clr : Color = Color("9d9d9d")) -> void:
	message = message.to_upper()
	SaveData.log_message(message,message_type)
	if display:
		Global.DisplayedMessage = message;
		var MessageRef : Control = MESSAGE_CONTAINER.instance()
		self.add_child(MessageRef)
		MessageRef.set_background_color(bg_clr)


func toggle_songlist_input(var x : bool) -> void:
	#if the toggle gets set to disabled it will be counted
	#so that if it f.e. disabled by the volume and image view, the Songscroller cannot
	#be used when just on of them enabled the Scroller, event though one of them is still there
	
	if options.get_child_count() > 0:
		var ref : Node = null
		if options.get_child(0).get("songs"):
			# only set reference if it exists -> input toggler can handle null Nodes
			ref = options.get_child(0).songs.get_parent()
		
		if !x:
			input_disable_counter += 1;
			Global.InputToggler(ref,false)
		else:
			input_disable_counter -= 1;
			if input_disable_counter < 0:
				input_disable_counter = 0;
				message("PROCESS INPUT DISABLER FOR SONG SCROLLER DISABLED MULTIPLE TIMES", SaveData.MESSAGE_WARNING)
			if input_disable_counter == 0:
				Global.InputToggler(ref,true)


func reset_input_disabler() -> void:
	input_disable_counter = 0
	if options.get_child(0).get("songs"):
		Global.InputToggler(options.get_child(0).songs.get_parent(),true)


func load_user_profile_selection() -> void:
	# loads the user profiles selection to change the current user
	
	# saving user specific data
	SongLists.saveUserSpecificData( SongLists.AddUsersToFilepaths(SongLists.FilePaths) )
	
	var x = load("res://src/Scenes/UserProfiles/UserProfileSelection.tscn").instance()
	var _err = x.connect("tree_exited",self,"init_main")
	middle_part.call_deferred("add_child",x)


func load_general_file_dialogue(var ref : Object, var open_mode : int, var file_access : int, var method : String,
		var method_args : Array, var filetype : String, var filetype_filters : PoolStringArray = [],
		var return_string : bool  = false, var title_override : String = "") -> Node:
	# creates an Instance of the General FileDialogue and Autromatically sets thew text where needed
	
	# adding to scene tree
	var dialog = GENERAL_DIALOGUE.instance()
	top_ui.add_child(dialog)
	
	# connecting given mehod to selection_made signal
	if dialog.connect("SelectionMade", ref, method, method_args):
		message("Couldn't not connect Folder Selection to General File Dialogue", SaveData.MESSAGE_ERROR)
	
	# initialising file dialogue
	dialog.n_ready(open_mode,file_access,filetype, filetype_filters, return_string, title_override)
	
	# returning dialogue if needed
	return dialog


func load_playlist(var playlist_idx : int) -> void:
	delete_current_option()
	
	# setting sidebar to playlist suboption
	sidebar.sub_options.set_sidebar_option(1)
	
	# loading a smart or normal playlist depending on the index
	var playlist_scene : Node = null
	if playlist_idx >= 0:
		playlist_scene = NORMAL_PLAYLIST_TEMPLATE.instance()
		options.add_child(playlist_scene)
	else:
		playlist_scene = SMART_PLAYLIST_TEMPLATE.instance()
		options.add_child(playlist_scene)
		playlist_scene.n_ready()


func load_temporary_playlist(var temp_playlist_title : String, var description_path : String, var cover_path : String, var option_idx : int) -> void:
	delete_current_option()
	Global.PlaylistPressed = -2
	SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS, "TempPlaylistTitle", temp_playlist_title)
	
	# setting sidebar to playlist suboption
	sidebar.sub_options.set_sidebar_option(option_idx)
	
	# loading temporary playlist from given arguments
	var new_temp_playlist : Control = SMART_PLAYLIST_TEMPLATE.instance()
	options.add_child( new_temp_playlist )
	new_temp_playlist.n_ready( SongLists.TempPlaylistConditions,temp_playlist_title,description_path, cover_path )


func load_lyric_editor(var ProjectPath : String = "") -> void:
	delete_current_option()
	var x = load("res://src/Scenes/SubOptions/Lyrics/LyricsEditor.tscn").instance()
	options.add_child( x )
	x.get_child(0).n_ready(ProjectPath)


func update_player_infos() -> void:
	var main_idx : int = AllSongs.get_main_idx(SongLists.CurrentSong)
	
	# title
	player.song_title.set_text( AllSongs.song_title(main_idx) )
	
	# artist
	player.song_artist.set_text("by " +  AllSongs.get_song_artist(main_idx) )
	
	# playlist Label
	var playlist_name : String
	if SettingsData.GetSetting(SettingsData.PLAYLIST_ALBUM_SETTINGS,"PlaylistSpaceText") == 0:
		playlist_name = Playlist.get_playlist_name( SongLists.CurrentPlayList )
	else:
		playlist_name = Tags.get_album(SongLists.CurrentSong)
	player.song_playlist.set_text("in " +  playlist_name )
	
	#Covers
	player.update_player_covers(
		Playlist.get_playlist_name(
			SongLists.CurrentPlayList
		)
	)
