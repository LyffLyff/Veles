extends Control
# main script always being loaded


# all the possible options that can be selected in the left sidebar menu
const all_songs : PackedScene = preload("res://src/Scenes/SubOptions/MyMusic/MyMusic.tscn")
const playlists : PackedScene = preload("res://src/Scenes/SubOptions/PlaylistGrid/PlaylistGrid.tscn")
const add_folder : PackedScene = preload("res://src/Scenes/SubOptions/Folders/SelectFolder.tscn")
const infos : PackedScene = preload("res://src/Scenes/SubOptions/InfoSettings/Infos.tscn")
const download : PackedScene = preload("res://src/Scenes/SubOptions/Downloader/Download.tscn")
const settings : PackedScene  = preload("res://src/Scenes/SubOptions/InfoSettings/NewSettings.tscn")
const stats : PackedScene = preload("res://src/Scenes/SubOptions/Stats/Stats.tscn")
const change_tags : PackedScene = preload("res://src/Scenes/SubOptions/Tagging/TagEditor.tscn")
const artists : PackedScene = preload("res://src/Scenes/SubOptions/Artists/Artists.tscn")
const lyrics : PackedScene = preload("res://src/Scenes/SubOptions/Lyrics/LyricsProjects.tscn")

const GENERAL_DIALOGUE : PackedScene = preload("res://src/Scenes/General/GeneralFileDialogue.tscn")
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
		self.call_deferred("toggle_songlist_input", true)
		#toggle_songlist_input(true)
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
						# loading MyMusic
						load_option(Enumerations.Options.MY_MUSIC, true)
					KEY_P:
						# loading Playlists
						load_option(Enumerations.Options.PLAYLIST_GRID, true)
					KEY_F:
						# loading Select Folders
						load_option(Enumerations.Options.EDIT_FOLDERS, true)
					KEY_A:
						# loading Artists
						load_option(Enumerations.Options.ARTISTS, true)
					KEY_C:
						# loading Change Tags
						load_option(Enumerations.Options.TAG_EDITOR, true)
					KEY_D:
						# loading Downloads
						load_option(Enumerations.Options.DOWNLOADER, true)
					KEY_Y:
						# loading Lyrics
						load_option(Enumerations.Options.LYRIC_EDITOR, true)
					KEY_S:
						# loading Stats
						load_option(Enumerations.Options.STATISTICS, true)
					KEY_E:
						# loading Settings
						load_option(Enumerations.Options.SETTINGS, true)
					KEY_I:
						# loading Infos
						load_option(Enumerations.Options.INFOS, true)
			else:
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
					KEY_T:
						# scroll to the top of playlist
						var song_scroller = options.find_node("ScrollContainer", true, false)
						if song_scroller != null:
							song_scroller.set_v_scroll(0)
					KEY_A:
						# toggle audio effects
						Global.toggle_audio_effects()


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
				Global.message("CONNECTING WINDOW MAXIMIZED SIGNAL TO RESIZE HANDLE TOGGLE", Enumerations.MESSAGE_ERROR)
		
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


func playback_song(var main_idx : int, var play : bool = false, var playlist_name : String = ""):
	# function that handles the replay of a given file 
	# only plays if play is true, otherwise just prepares and pauses
	if SongLists.current_playlist_idx == Playlist.get_playlist_index(playlist_name) and AllSongs.get_song_path(main_idx) == SongLists.current_song:
		# if the song that was just presed is the same that was playing
		# the AudioPlayer justs seeks the start instead of loading the song from scratch
		MainStream.seek(0.0)
		MainStream.reload_stream_timer()
	
	var file = File.new()
	var song_path : String = AllSongs.get_song_path(main_idx)

	update_highlighted_song(song_path)
	
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
				var wav_properties : WAV = WAV.new()
				var fmt_offset : int = wav_properties.find_fmt_in_file(song_data)
				var header : PoolByteArray = song_data.subarray(0,45 + fmt_offset)
				if fmt_offset == -1:
					#if a the "fmt " specifier could not be found the song will be skipped
					real_format_flag = -1
					
				var format_type : int = wav_properties.get_format_type(header, fmt_offset)
				if format_type <= 2:
					stream.format = format_type
				else:
					Global.message("UNKNOWN WAV FORMAT: " + str(format_type), Enumerations.MESSAGE_ERROR)
					real_format_flag = -1
				
				song_data = song_data.subarray(128 * 10, song_data.size() - 1)
				stream.stereo = wav_properties.is_channel_stereo(header, fmt_offset)
				stream.mix_rate = wav_properties.get_mix_rate(header, fmt_offset)
				
				var bits_per_sample : int = wav_properties.get_bits_per_sample(header, fmt_offset)
				if bits_per_sample > 16:
					#24Bit, 32Bits per sample 
					#song_data = wav_properties.convert_32_and_24_to_16_bits(song_data, bits_per_sample)
					real_format_flag = -1
				
				song_data = wav_properties.audio_pop_workaround(song_data)
			-1:
				pass
		
		if real_format_flag != -1 and real_format_flag != 3 and real_format_flag != 4 and real_format_flag != 5:
			stream.data = song_data
			
			# Setting Stream
			MainStream.set_stream(stream)
			if !MainStream.stream:
				# Last Check to see if the decoding of Music Data worked
				Global.message("Unsupported Musicformat -> Failed to Decode: " + song_path, Enumerations.MESSAGE_ERROR)
				Playback.skip_song(main_idx)
			
			# Updating Player Music replay data
			var song_length : float = MainStream.stream.get_length()
			player.song_length.text = TimeFormatter.format_seconds(song_length)
			player.playback_slider.max_value = int(song_length)
			
			# Valid Song -> reset first skipped song
			Global.first_skipped_path = ""

			# update Player Infos
			update_player_infos(true, true, SongLists.current_song, song_path, playlist_name)
			
			# Updating Current Song 
			SongLists.set_current_song(AllSongs.get_song_path(main_idx))
			
			# Play
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
			Global.message("Unsupported Fileformat: " + song_path, Enumerations.MESSAGE_ERROR)
			Playback.skip_song(main_idx)
	else:
		Global.message("Could not open specified song path:" + song_path, Enumerations.MESSAGE_ERROR)
		Playback.skip_song(main_idx)
	file.close()


func random_song() -> void:
	randomize()
	var random_song_idx : int = 0

	if SongLists.current_playlist_idx == -1:
		# allSongs
		random_song_idx = randi() % SongLists.AllSongs.size()
	
	elif SongLists.current_playlist_idx >= 0:
		# normal Playlist, not in range -> to allsongs
		var playlist_idx : int = SongLists.current_playlist_idx
		if playlist_idx >= SongLists.normal_playlists.size():
			# 
			SongLists.current_playlist_idx = -1
			random_song()
			return
		
		var temp = randi() % SongLists.normal_playlists.values()[playlist_idx].size()
		var random_song_path : String  = SongLists.normal_playlists.values()[playlist_idx].keys()[temp]
		random_song_idx = AllSongs.get_main_idx(random_song_path)
	
	else:
		#Smart Playlist/Automaticly Created
		var temp = randi() % SongLists.current_temporary_playlist.size()
		random_song_idx = AllSongs.get_main_idx( SongLists.current_temporary_playlist.keys()[temp] )
	playback_song(
		random_song_idx,
		true,
		Playlist.get_playlist_name(SongLists.current_playlist_idx)
	)


func load_option(var index : int, var ignore_same : bool = false):
	var del : bool = true
	# if there isn't an option loaded it won't try to free it
	if sidebar.sub_options.current_option_idx == -1:
		del = false
	if sidebar.sub_options.current_option_idx != index or ignore_same:
		var option : Control
		match index:
			Enumerations.Options.MY_MUSIC:
				option = all_songs.instance()
			Enumerations.Options.PLAYLIST_GRID:
				option = playlists.instance()
			Enumerations.Options.EDIT_FOLDERS:
				option = add_folder.instance()
			Enumerations.Options.ARTISTS:
				option = artists.instance()
			Enumerations.Options.TAG_EDITOR:
				option = change_tags.instance()
			Enumerations.Options.DOWNLOADER:
				option = download.instance()
			Enumerations.Options.LYRIC_EDITOR:
				option = lyrics.instance()
			Enumerations.Options.STATISTICS:
				option = stats.instance()
			Enumerations.Options.SETTINGS:
				option = settings.instance()
			Enumerations.Options.INFOS:
				option = infos.instance()
		if del:
			# frees more than one option in a loop just in case
			free_option()
		
		# disabling Input in the Loading time of the Option
		self.set_process_input(false)
		var _err = option.connect("ready",self,"set_process_input", [true],CONNECT_ONESHOT)
		
		# adding option to SceneTree
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
			# if a song is next from another Playlist that is bigger
			return
		# if a song is currently highlighted
		if highlighted_song != -1:
			ref.unhighlight_song(highlighted_song)
			var next_highlighted_idx : int = ref.get_index_from_songlist(next_highlighted_path)
			if next_highlighted_idx == -1:
				return
			ref.highlight_song(ref.song_vbox.get_child(next_highlighted_idx))


func unhighlight_current_song() -> void:
	var ref : Node = options.find_node("GeneralPlaylist", true, false)
	if ref != null:
		var highlighted_song : int = ref.get_index_from_songlist(SongLists.current_song) 
		if highlighted_song in range(0, ref.song_vbox.get_child_count()):
			ref.unhighlight_song(highlighted_song)


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
			Global.message("PROCESS INPUT DISABLER FOR SONG SCROLLER DISABLED MULTIPLE TIMES", Enumerations.MESSAGE_WARNING)
		if input_disable_counter == 0:
			Global.set_node_input(ref, true)


func toggle_songlist_visibility(var toggle : bool) -> void:
	var ref : Node = options.find_node("SongVbox", true, false)
	if ref:
		# toggle visibility of songlist when entering ImageView
		# save / load last songlistt scroll value
		var songlist_scroller = options.find_node("ScrollContainer", true, false)
		if !toggle:
			Global.last_songlist_scroll_value = songlist_scroller.get_v_scroll()
			ref.visible = false
		else:
			ref.visible = true
			yield(get_tree(), "idle_frame")
			if is_instance_valid(songlist_scroller):
				songlist_scroller.set_v_scroll(Global.last_songlist_scroll_value)


func reset_input_disabler() -> void:
	input_disable_counter = 0
	if options.get_child(0).get("song_vbox"):
		Global.set_node_input(options.get_child(0).song_vbox.get_parent(),true)


func load_user_profile_selection() -> void:
	# loads the user profiles selection to change the current user
	
	# saving user specific data
	SongLists.save_user_specific_data(SongLists.add_users_to_filepaths(SongLists.file_paths))
	
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
		Global.message("Couldn't not connect Folder Selection to General File Dialogue", Enumerations.MESSAGE_ERROR)
	
	# initialising file dialogue
	dialog.n_ready(open_mode, file_access, filetype, filetype_filters, return_string, title_override)
	
	# returning dialogue if needed
	return dialog


func load_playlist(var _playlist_idx : int) -> void:
	delete_current_option()
	disable_image_view()
	
	# setting sidebar to playlist suboption
	sidebar.sub_options.set_sidebar_option(1)
	
	# loading a smart or normal playlist depending on the index
	var playlist_scene : Node = PLAYLIST_TEMPLATE.instance()
	options.add_child(playlist_scene)
	playlist_scene.init_playlist("", true)


func load_temporary_playlist(var temp_playlist_title : String, var description_path : String, var cover_path : String,  var conditions : Dictionary, var option_idx : int) -> void:
	delete_current_option()
	disable_image_view()
	
	Global.pressed_playlist_idx = -2
	SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "TempPlaylistTitle", temp_playlist_title)
	
	# setting sidebar to playlist suboption
	sidebar.sub_options.set_sidebar_option(option_idx)
	
	# loading temporary playlist from given arguments
	var new_temp_playlist : Control = PLAYLIST_TEMPLATE.instance()
	options.add_child(new_temp_playlist)
	new_temp_playlist.init_playlist("", true)
	new_temp_playlist.init_temporary_playlist(conditions, temp_playlist_title, description_path, cover_path)


func load_lyric_editor(var project_path : String = "") -> void:
	delete_current_option()
	var x = load("res://src/Scenes/SubOptions/Lyrics/LyricsEditor.tscn").instance()
	options.add_child(x)
	x.get_child(0).n_ready(project_path)


func update_player_infos(var reload_covers : bool = true, var threading : bool = true, var old_path : String = "", var new_path : String = "", var playlist_name : String = "") -> void:
	var main_idx : int = AllSongs.get_main_idx(new_path)
	if main_idx == -1:
		return
	
	player.song_title.set_text(AllSongs.song_title(main_idx))
	player.song_artist.set_text("by " +  AllSongs.get_song_artist(main_idx))
	if SettingsData.get_setting(SettingsData.PLAYLIST_SETTINGS,"PlaylistSpaceText") == 0:
		if playlist_name == "":
			playlist_name = Playlist.get_playlist_name(SongLists.current_playlist_idx)
	else:
		playlist_name = Tags.get_album(new_path)
	player.song_playlist.set_text("in " +  playlist_name)
	
	# covers
	player.update_player_covers(
		Playlist.get_playlist_name(SongLists.current_playlist_idx),
		reload_covers,
		old_path, 
		new_path,
		threading
	)


func disable_image_view() -> void:
	if player.image_view_ref:
		player.image_view_ref.exit_image_view()
		player.is_image_view_active = false


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
