extends Control
# main script always being loaded


# all the possible options that can be selected in the left sidebar menu
const all_songs : PackedScene = preload("res://src/Scenes/SubOptions/MyMusic/MyMusic.tscn")
const playlists : PackedScene = preload("res://src/Scenes/SubOptions/PlaylistGrid/CustomPlaylist-s/PlaylistGrid.tscn")
const add_folder : PackedScene = preload("res://src/Scenes/SubOptions/Folders/SelectFolder.tscn")
const infos : PackedScene = preload("res://src/Scenes/SubOptions/InfoSettings/Infos.tscn")
const download : PackedScene = preload("res://src/Scenes/SubOptions/Downloader/Download.tscn")
const settings : PackedScene  = preload("res://src/Scenes/SubOptions/InfoSettings/NewSettings.tscn")
const stats : PackedScene = preload("res://src/Scenes/SubOptions/Stats/Stats.tscn")
const change_tags : PackedScene = preload("res://src/Scenes/SubOptions/Tagging/ChangeTags.tscn")
const artists : PackedScene = preload("res://src/Scenes/SubOptions/Artists/Artists.tscn")
const lyrics : PackedScene = preload("res://src/Scenes/SubOptions/Lyrics/LyricsProjects.tscn")

const MESSAGE_CONTAINER : PackedScene = preload("res://src/scenes/ErrorHandling/MessageContainer.tscn")
const GENERAL_DIALOGUE : PackedScene = preload("res://src/scenes/General/GeneralFileDialogue.tscn")
const PLAYLIST_TEMPLATE : PackedScene = preload("res://src/Scenes/Playlists/General/GeneralPlaylist.tscn")

var input_disable_counter : int = 0

onready var sidebar : ScrollContainer = $MarginContainer/VBoxContainer/MiddlePart/VBoxContainer/HBoxContainer/SideBar
onready var options : MarginContainer = $MarginContainer/VBoxContainer/MiddlePart/VBoxContainer/HBoxContainer/Option
onready var player : PanelContainer = $MarginContainer/VBoxContainer/Player
onready var middle_part : MarginContainer = $MarginContainer/VBoxContainer/MiddlePart
onready var window_bar : PanelContainer = $MarginContainer/VBoxContainer/WindowBar
onready var resize_handles : HBoxContainer = $MarginContainer/ResizeHandles
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
		Global.is_low_fps = true
		Engine.set_target_fps(4)
	elif what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		# resetting the engine frame rate to 60 fps
		Global.is_low_fps = false
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
						# loading Downloads
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
	if Global.current_profile_idx != -1:
		# connecting User Profile Box
		sidebar.user_profile_container.init_profile_box()
		sidebar.update_sidebar(0.0)
		
		init_context_menus()
		if !self.is_connected("resized",sidebar,"update_sidebar"):
			var _err = self.connect("resized",sidebar,"update_sidebar")
		if !sidebar.user_profile_container.load_user_select.is_connected("pressed",self,"load_user_profile_selection"):
			var _err = sidebar.user_profile_container.load_user_select.connect("pressed",self,"load_user_profile_selection")
		
		# connecting a Signal form the Windowbar when the Window gets maximized or unmaximized
		# hides the resize handles on a true signal
		if !window_bar.is_connected("window_maximized",resize_handles,"set_deferred"):
			if window_bar.connect("window_maximized",resize_handles,"set_deferred"):
				message("CONNECTING WINDOW MAXIMIZED SIGNAL TO RESIZE HANDLE TOGGLE", SaveData.MESSAGE_ERROR)
		
		# only Resets if the selected Profiles is NOT the one used before
		if Global.get_current_user() != Global.last_loaded_user or load_current_song:
			
			# loading all songs suboption
			load_option(0, true)
			
			# loading current sing
			if SongLists.current_song != "":
				playback_song(
					AllSongs.get_main_idx(SongLists.current_song),
					false,
					Playlist.get_playlist_name(SongLists.current_playlist_idx)
				)
			else:
				# resetting
				Playback.new().stop_playback()
	else:
		load_user_profile_selection()


func playback_song(var main_idx : int, var play : bool = false, var _PlaylistName : String = ""):
	# function that handles the replay of a given file 
	# only plays if play is true, otherwise just prepares and pauses
	if SongLists.current_playlist_idx == Playlist.get_playlist_index(_PlaylistName) and AllSongs.get_song_path(main_idx) == SongLists.current_song:
		# if the song that was just presed is the same that was playing
		# the AudioPlayer justs seeks the start instead of loading the song from scratch
		MainStream.seek(0.0)
		MainStream.reload_stream_timer()
	
	var file = File.new()
	var song_path : String = AllSongs.get_song_path(main_idx)
	if file.open(song_path, File.READ) == OK:
		
		# GET DATA
		var song_data : PoolByteArray = file.get_buffer(file.get_len())
		
		# CHECK MUSIC FORMAT WITH HEADER
		var real_format_flag : int = FormatChecker.get_music_format_from_data(song_data.subarray(0,1024).hex_encode())
		if real_format_flag == -1:
			real_format_flag = FormatChecker.get_music_filename_extension(song_path) 
		
		# CREATE STREAM
		var stream = null
		match real_format_flag:
			0:
				stream = AudioStreamOGGVorbis.new()
			1:
				stream = AudioStreamMP3.new()
			2:
				stream = AudioStreamSample.new()
				
				#Set WAV properties
				var WavProperties : WAV = WAV.new()
				var FmtOffset : int = WavProperties.find_fmt_in_file(song_data)
				var header : PoolByteArray = song_data.subarray(0,45 + FmtOffset)
				if FmtOffset == -1:
					#if a the "fmt " specifier could not be found the song will be skipped
					real_format_flag = -1
					
				var FormatType : int = WavProperties.get_format_type(header, FmtOffset)
				if FormatType <= 2:
					stream.format = FormatType
				else:
					message("UNKNOWN WAV FORMAT: " + str(FormatType), SaveData.MESSAGE_ERROR)
					real_format_flag = -1
				
				song_data = song_data.subarray( 128 * 10, song_data.size() - 1 )
				stream.stereo = WavProperties.is_channel_stereo(header, FmtOffset)
				stream.mix_rate = WavProperties.get_mix_rate(header, FmtOffset)
				
				var BitsPerSample : int = WavProperties.get_bits_per_sample(header, FmtOffset)
				if BitsPerSample > 16:
					#24Bit, 32Bits per sample 
					#song_data = WavProperties.convert_32_and_24_to_16_bits(song_data, BitsPerSample)
					real_format_flag = -1
				
				song_data = WavProperties.audio_pop_workaround(song_data)
			-1:
				pass
		
		if real_format_flag != -1 and real_format_flag != 3 and real_format_flag != 4 and real_format_flag != 5:
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
			SongLists.set_current_song(AllSongs.get_song_path(main_idx))
			
			#update Player Infos
			update_player_infos()
			
			#Play
			MainStream.play(0)
			if !play:
				player.set_playback_button(0)
				MainStream.seek(SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"PlaybackPosition"))
				MainStream.set_stream_paused(true)
				#pauses the stream timer on start
				MainStream.reload_stream_timer(true)
			else:
				player.set_playback_button(1)
				MainStream.set_stream_paused(false)
				MainStream.reload_stream_timer()
		else:
			message("Unsupported Fileformat: " + song_path, SaveData.MESSAGE_ERROR)
			skip_song(main_idx)
	else:
		message("Could not open specified song path:" + song_path, SaveData.MESSAGE_ERROR)
		skip_song(main_idx)
	file.close()


func change_song(var direction : int) -> void:
	if !SongLists.AllSongs.has(SongLists.current_song):
		return;
	
	var next_main_idx : int =  0 
	var curr_main_idx : int = SongLists.AllSongs.get(SongLists.current_song)[2]
	if SongLists.current_playlist_idx == -1:
		if SongLists.AllSongs.size() -1 > curr_main_idx and curr_main_idx + direction > 0:
			next_main_idx = curr_main_idx + direction
		else:
			#wraps around to first Song if at the end
			#or stays at the first if trying to go furthzer prior
			next_main_idx = 0
	else:
		var playlist_n : Dictionary
		
		if SongLists.current_playlist_idx >= 0:
			# if the index of the normal playlist does not exist it switches to AllSongs
			if SongLists.normal_playlists.values().size() <= SongLists.current_playlist_idx:
				SongLists.current_playlist_idx = -1
				change_song(+1)
				return
			playlist_n = SongLists.normal_playlists.values()[SongLists.current_playlist_idx]
		
		elif SongLists.current_playlist_idx <= -2:
			playlist_n = SongLists.current_temporary_playlist
		
		else:
			#if playlist that is currently playing has been deleted
			#redirects to AllSongs
			playlist_n = SongLists.AllSongs
			SongLists.current_playlist_idx = -1
		
		var idx_in_playlist : int = -1
		for n in playlist_n.size():
			#finding the index of the current song inside the playlist
			if playlist_n.keys()[n] == SongLists.current_song:
				if playlist_n.size()  >  n + direction and n + direction >= 0:
					idx_in_playlist = n + direction
				else:
					idx_in_playlist = 0
				break;
		# getting the main idx
		# it is safer to search the path (playlist_n.keys()[idx_in_playlist]) in the AllSongs Dictionary 
		# since the main index can change when reloading AllSongs
		next_main_idx = AllSongs.get_main_idx(playlist_n.keys()[idx_in_playlist])
	
	var path : String = AllSongs.get_song_path( next_main_idx )
	update_highlighted_song(path)
	Global.last_direction = direction
	
	playback_song(
		next_main_idx,
		true,
		Playlist.get_playlist_name(SongLists.current_playlist_idx)
	)


func random_song() -> void:
	randomize()
	var random_song_idx : int = 0

	if SongLists.current_playlist_idx == -1:
		#AllSongs
		random_song_idx = randi() % SongLists.AllSongs.size()
	
	elif SongLists.current_playlist_idx >= 0:
		#Normal Playlist
		var playlist_idx : int = SongLists.current_playlist_idx
		var temp = randi() % SongLists.normal_playlists.values()[playlist_idx].size()
		
		var random_song_path : String  = SongLists.normal_playlists.values()[playlist_idx].keys()[temp]
		random_song_idx = AllSongs.get_main_idx(random_song_path)
	
	else:
		#Smart Playlist/Automaticly Created
		var temp = randi() % SongLists.current_temporary_playlist.size()
		random_song_idx = AllSongs.get_main_idx( SongLists.current_temporary_playlist.keys()[temp] )
	update_highlighted_song(AllSongs.get_song_path(random_song_idx))
	playback_song(
		random_song_idx,
		true,
		Playlist.get_playlist_name(SongLists.current_playlist_idx)
	)


func skip_song(var main_idx : int) -> void:
	# skips to the next Song if the header FileFormat is not supported or the path couldn't be opened
	# when loading Veles checks for the Filename extension not the "REAL" format
	var path : String = AllSongs.get_song_path(main_idx)
	var to_next : bool = false
	if Global.first_skipped_path == path:
		# only skips if the first song that was skipped does is not the one that wants to be skipped
		# -> prevents an endless loop if EVERY song is invalid
		SongLists.set_current_song("")
		MainStream.set_stream_paused(true)
		return
	else:
		to_next = true
	
	if Global.first_skipped_path == "":
		Global.first_skipped_path = path
		to_next = true
	
	if to_next:
		SongLists.set_current_song(path)
		change_song(Global.last_direction)


func load_option(var index : int, var ignore_same : bool = false):
	var del : bool = true
	# if there isn't an option loaded it won't try to free it
	if sidebar.sub_options.current_option_idx == -1:
		del = false
	if sidebar.sub_options.current_option_idx != index or ignore_same:
		var option : Control
		match index:
			0:
				option = all_songs.instance()
			1:
				option = playlists.instance()
			2:
				option = add_folder.instance()
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
	load_option(sidebar.sub_options.current_option_idx,true)


func free_option() -> void:
	# even though the options should only habe one child
	# if something goes wrong looping thourgh all possible children shoudl fix everything again
	# remove_child() is also called since the child needs to be removed immediately from the options Node for the Highlighting to work properlay
	for n in options.get_children():
		n.queue_free()
		options.remove_child(n)


func update_highlighted_song(var next_highlighted_path : String) -> void:
	# checks first if either AllSongs or a Playlist are shown
	var ref : Node = options.find_node("GeneralPlaylist", true, false)
	if ref != null:
		var highlighted_song : int = ref.get_index_from_songlist(SongLists.current_song) 
		if  ref.song_vbox.get_child_count() < highlighted_song:
			# if a song is next from another Playlist  that is bigger
			return
		# if a song is currently highlighted
		if highlighted_song != -1:
			ref.unhighlight_song(highlighted_song)
			var next_highlighted_idx : int = ref.get_index_from_songlist(next_highlighted_path)
			if next_highlighted_idx == -1:
				return
			ref.highlight_song(ref.song_vbox.get_child(next_highlighted_idx))


func message(var message : String, var message_type : int, var display : bool = false, var bg_clr : Color = Color("1f1f1f")) -> void:
	message = message.to_upper()
	SaveData.log_message(message,message_type)
	if display:
		Global.displayed_message = message;
		var message_ref : Control = MESSAGE_CONTAINER.instance()
		self.add_child(message_ref)
		message_ref.set_background_color(bg_clr)


func toggle_songlist_input(var toggle : bool) -> void:
	# if the toggle gets set to disabled it will be counted
	# so that if it f.e. disabled by the volume and image view, the Songscroller cannot
	# be used when just on of them enabled the Scroller, event though one of them is still there
	var ref : Node = options.find_node("SongVbox", true, false)
	if !ref:
		input_disable_counter = 0
		return
	if !toggle:
		input_disable_counter += 1;
		Global.set_node_input(ref, false)
		ref.emit_signal("panel_visible", false)
	else:
		input_disable_counter -= 1;
		if input_disable_counter < 0:
			input_disable_counter = 0;
			message("PROCESS INPUT DISABLER FOR SONG SCROLLER DISABLED MULTIPLE TIMES", SaveData.MESSAGE_WARNING)
		if input_disable_counter == 0:
			Global.set_node_input(ref, true)


func toggle_songlist_visibility(var toggle : bool) -> void:
	var ref : Node = options.find_node("SongVbox", true, false)
	if ref:
		ref.set_visible(toggle)

func reset_input_disabler() -> void:
	input_disable_counter = 0
	if options.get_child(0).get("song_vbox"):
		Global.set_node_input(options.get_child(0).song_vbox.get_parent(),true)


func load_user_profile_selection() -> void:
	# loads the user profiles selection to change the current user
	
	# saving user specific data
	SongLists.save_user_specific_data( SongLists.add_users_to_filepaths(SongLists.file_paths) )
	
	var x = load("res://src/Scenes/UserProfiles/UserProfileSelection.tscn").instance()
	var _err = x.connect("tree_exited",self,"init_main")
	middle_part.call_deferred("add_child",x)


func load_general_file_dialogue(var ref : Object, var open_mode : int, var file_access : int, var method : String,
		var method_args : Array, var filetype : int, var filetype_filters : PoolStringArray = [],
		var return_string : bool  = false, var title_override : String = "") -> Node:
	# creates an Instance of the General FileDialogue and Autromatically sets thew text where needed
	
	# adding to scene tree
	var dialog = GENERAL_DIALOGUE.instance()
	top_ui.add_child(dialog)
	
	# connecting given mehod to selection_made signal
	if dialog.connect("selection_made", ref, method, method_args):
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
	var playlist_scene : Node = PLAYLIST_TEMPLATE.instance()
	options.add_child(playlist_scene)
	playlist_scene.init_playlist()


func load_temporary_playlist(var temp_playlist_title : String, var description_path : String, var cover_path : String, var option_idx : int) -> void:
	delete_current_option()
	Global.pressed_playlist_idx = -2
	SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "TempPlaylistTitle", temp_playlist_title)
	
	# setting sidebar to playlist suboption
	sidebar.sub_options.set_sidebar_option(option_idx)
	
	# loading temporary playlist from given arguments
	var new_temp_playlist : Control = PLAYLIST_TEMPLATE.instance()
	options.add_child(new_temp_playlist)
	new_temp_playlist.init_playlist()
	new_temp_playlist.init_temporary_playlist(SongLists.temporary_playlist_conditions, temp_playlist_title, description_path, cover_path)


func load_lyric_editor(var project_path : String = "") -> void:
	delete_current_option()
	var x = load("res://src/Scenes/SubOptions/Lyrics/LyricsEditor.tscn").instance()
	options.add_child(x)
	x.get_child(0).n_ready(project_path)


func update_player_infos() -> void:
	var main_idx : int = AllSongs.get_main_idx(SongLists.current_song)
	
	# title
	player.song_title.set_text( AllSongs.song_title(main_idx) )
	
	# artist
	player.song_artist.set_text("by " +  AllSongs.get_song_artist(main_idx) )
	
	# playlist Label
	var playlist_name : String
	if SettingsData.get_setting(SettingsData.PLAYLIST_SETTINGS,"PlaylistSpaceText") == 0:
		playlist_name = Playlist.get_playlist_name( SongLists.current_playlist_idx )
	else:
		playlist_name = Tags.get_album(SongLists.current_song)
	player.song_playlist.set_text("in " +  playlist_name )
	
	# covers
	player.update_player_covers(
		Playlist.get_playlist_name(
			SongLists.current_playlist_idx
		)
	)


func init_context_menus() -> void:
	if self.is_inside_tree():
		var context_nodes : Array = get_tree().get_nodes_in_group("Context")
		var _err
		for i in context_nodes:
			if !i.is_connected("mouse_entered", self, "show_context_menu"):
				_err = i.connect("mouse_entered", self, "show_context_menu", [i])


func show_context_menu(var ref : Control) -> void:
	var new_context_label : Label = load("res://src/Scenes/General/ContextLabel.tscn").instance()
	top_ui.add_child(new_context_label)
	var _err = ref.connect("mouse_exited", new_context_label, "queue_free")
	# so when the buttion for the  context exits the tree the label does aswell
	_err = ref.connect("tree_exited", new_context_label, "queue_free")
	var context : String = ""
	if ref.get("context"):
		context = ref.get("context")
	else:
		context = ref.name
	new_context_label.init_context_label(context)
