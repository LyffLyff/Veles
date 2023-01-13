extends "res://src/Scenes/Playlists/General/PlaylistLoader.gd"

const SMART_PLAYLIST_OPTIONS : PackedScene = preload("res://src/Scenes/Playlists/Options/SmartPlaylistOptions.tscn")
const STANDARD_PLAYLIST_OPTIONS : PackedScene = preload("res://src/Scenes/Playlists/Options/NormalPlaylistOptions.tscn")
const HIGHLIGHTED_SONG : Resource = preload("res://src/Ressources/Themes/Song/HighlightedSong.tres")
const SONG_OPTIONS_OFFSET : int = 40

var temp_idx : int = -1
var playlist_idx : int = -1
var playlist_title : String = ""
var playlist_cover_path : String = ""
var description_path : String = ""

onready var song_scroller : ScrollContainer = $VBoxContainer/ScrollContainer
onready var header : PanelContainer = $VBoxContainer/ScrollContainer/VBoxContainer/PlaylistHeader
onready var filter : Control = $VBoxContainer/ScrollContainer/VBoxContainer/SongFilters
onready var song_vbox : Control = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/VBoxContainer/SongVbox
onready var song_highlighter : Control = $SongHighlighter


func _notification(what): 
	if what == NOTIFICATION_WM_FOCUS_IN:
		Global.root.call_deferred("toggle_songlist_input", true)
	elif what == NOTIFICATION_WM_FOCUS_OUT:
		Global.root.call_deferred("toggle_songlist_input", false)


func _exit_tree():
	free_highlighted_songs()


func _process(_delta):
	temp_idx = song_vbox.calc_idx()
	if self.song_scroller.get_global_rect().has_point(get_global_mouse_position()):
		if temp_idx >= 0:
			song_highlighter.rect_global_position.y = song_vbox.get_child(temp_idx).rect_position.y + song_vbox.rect_global_position.y


func unload() -> void:
	Global.root.delete_current_option()
	Global.root.load_option(1, true)

func connect_song_vbox() -> void:
	if song_vbox.connect("space_pressed", self, "on_songspace_left_clicked"):
		Global.root.message("CONNECTING SPACE PRESSED SIGNAL WITH LEFT BUTTON CLICKED FUNCTION", SaveData.MESSAGE_ERROR)
	if song_vbox.connect("space_rightclicked", self, "on_songspace_right_clicked"):
		Global.root.message("CONNECTING SPACE RIGHTCLICKED SIGNAL WITH RIGHT BUTTON CLICKED FUNCTION", SaveData.MESSAGE_ERROR)


func init_playlist(var custom_cover_path : String = "", var reload : bool = false) -> void:
	song_vbox.playlist_root = self
	song_vbox.playlist_root_rect = self.get_global_rect()
	song_scroller.get_v_scrollbar().step = 0.01
	playlist_title = Playlist.get_playlist_name(Global.pressed_playlist_idx)
	playlist_idx = Global.pressed_playlist_idx
	
	# connect signals
	if !reload:
		header.play.connect("pressed", self, "on_songspace_left_clicked", [0])
		song_vbox.init_song_scroller()
		var _err = song_scroller.get_v_scrollbar().connect("mouse_entered", song_highlighter, "set_visible", [false])
		connect_song_vbox()
	
	if custom_cover_path != "":
		playlist_cover_path = custom_cover_path
	else:
		playlist_cover_path = Global.get_current_user_data_folder() + "/Songs/Playlists/Covers/" + playlist_title + ".png"
	
	if playlist_idx <= -3:
		# smart playlist
		load_songs(get_smart_playlist_songs(load_playlist_conditions()))
		filter.hide()
	elif playlist_idx == -1:
		# my music / all songs
		load_songs(get_smart_playlist_songs({}))
		header.hide()
	elif playlist_idx >= 0:
		# normal/standard playlist
		filter.hide()
		load_songs(get_normal_playlist_songs())
	else:
		# temporary playlist -> init_temp_playlist needs to be called for songs to be loaded
		filter.hide()
	
	init_header()
	
	# colors
	self.get_stylebox("panel").set_bg_color(header.bottom_blur.material.get("shader_param/color"))
	
	# various
	song_scroller.get_v_scrollbar().rect_min_size.x = 5


func init_temporary_playlist(var conditions : Dictionary, var title : String, var custom_description_path : String, var cover_path : String) -> void:
	playlist_title = title
	description_path = custom_description_path
	playlist_cover_path = cover_path
	load_songs(get_smart_playlist_songs(conditions))
	init_header()


func init_header() -> void:
	# general
	header.title_label.text = playlist_title
	header.creation_date_label.text = get_playlist_creation_date(playlist_idx)
	header.playlist_duration_label.text = get_playlist_runtime(playlist_idx)
	header.song_amount_label.text = "Songs: " + str(get_playlist_song_amount(playlist_idx))
	header.set_header_cover(ImageLoader.get_cover(playlist_cover_path))
	
	if playlist_idx == -2:
		header.description.load_description(description_path)
	else:
		header.description.hide()


func init_playlist_options(var ref : Control) -> void:
	var options_ref : Control = null
	if playlist_idx >= 0:
		options_ref = STANDARD_PLAYLIST_OPTIONS.instance()
	else:
		options_ref = SMART_PLAYLIST_OPTIONS.instance()
	self.add_child(options_ref)
	options_ref.set_owner(self)
	options_ref.init_options()
	options_ref.rect_global_position = ref.rect_global_position - (ref.rect_size / 2)


func get_index_from_songlist(var path : String) -> int:
	for songspace in song_vbox.get_children():
		if songspace.path == path:
			return songspace.get_index();
	return -1;


func highlight_song(var songspace : HBoxContainer) ->  void:
	songspace.get_child(0).set_deferred("custom_styles/panel", HIGHLIGHTED_SONG)


func unhighlight_song(var l_idx : int) -> void:
	if l_idx != -1:
		song_vbox.get_child(l_idx).get_child(0).set_deferred("custom_styles/panel", null)


func free_highlighted_songs() -> void:
	# clearing CTRL highlighted songs
	for highlighted_song in SongLists.highlighted_songs:
		song_vbox.get_child(get_index_from_songlist(highlighted_song)).modulate = Color("ffffff")
	SongLists.highlighted_songs = []


func on_songspace_right_clicked(var l_idx : int) -> void:
	# no need to check if there is a priorly pressed instance od the SongOptions,
	# since the Input gets disabled anyways
	var x = load("res://src/Scenes/Song/SongOptions/SongOptions.tscn").instance()
	x.rect_position = get_global_mouse_position()
	x.rect_position.x -= SONG_OPTIONS_OFFSET
	x.rect_position.y -= SONG_OPTIONS_OFFSET
	if get_global_mouse_position().y + 200 > OS.get_window_size().y: 
		x.rect_position.y -= 150
	if get_global_mouse_position().x + 200 > OS.get_window_size().x: 
		x.rect_position.x -= 100
	x.song_idx = l_idx
	Global.root.add_child(x)


func on_songspace_left_clicked(var l_idx : int) -> void:
	if l_idx >= 0 and song_vbox.get_child_count() > 0:
		if !Input.is_key_pressed(KEY_CONTROL):
			free_highlighted_songs()
			# playing pressed song
			var song_ : Control = song_vbox.get_child(l_idx)
			var main_idx : int = song_.main_index
			# unhighlights the highlighted song when another one has been pressed
			var highlighted_song : int = get_index_from_songlist(SongLists.current_song)
			if highlighted_song != l_idx:
				if highlighted_song != -1:
					unhighlight_song(highlighted_song)
			# highlighting the current song if it has not been already
			highlight_song(song_)
			SongLists.current_playlist_idx = song_.playlist_idx
			Global.root.playback_song(
				main_idx,
				true,
				Playlist.get_playlist_name(song_.playlist_idx)
			)
			Global.root.player.set_repeat(false)
		else:
			SongLists.add_highlighted_song(song_vbox, l_idx)


func load_songs(var song_idxs : PoolIntArray) -> void:
	var x : SongLoader = SongLoader.new()
	x.create_songspaces(song_vbox, song_idxs, Global.pressed_playlist_idx)


func load_playlist_conditions() -> Dictionary:
	var temp = SaveData.load_data(Global.get_current_user_data_folder() + "/Songs/Playlists/SmartPlaylists/Conditions/" + playlist_title + ".dat")
	if temp:
		return temp
	return Dictionary()


func get_smart_playlist_songs(var conditions : Dictionary) -> PoolIntArray:
	var condition_functions : SmartPlaylistConditions = SmartPlaylistConditions.new()
	var is_valid_song : bool = true
	var temp_song_path : String = ""
	var song_idxs : PoolIntArray = []
	var temp_smart_playlist : Dictionary = {}
	
	# going through AllSongs
	for x in SongLists.AllSongs.size():
		is_valid_song = true
		temp_song_path = SongLists.AllSongs.keys()[x]
		# checking Conditions
		for y in conditions.size():
			for z in conditions.values()[y].size():
				if !condition_functions.call(conditions.keys()[y], temp_song_path, conditions.values()[y][z]):
					is_valid_song = false
					break;
		
		# adding Songs to return Array if the Conditions are met
		if is_valid_song:
			temp_smart_playlist[temp_song_path] = false
			song_idxs.push_back(x)
	
	# setting the Currently "created" Playlist in a Global Dictionary
	# the Playlist has only been loaded, but is not the one currently playing
	SongLists.pressed_temporary_playlist = temp_smart_playlist
	
	# returning All Songs that fit the Current Description
	return song_idxs;


func get_normal_playlist_songs() -> PoolIntArray:
	var idxs_to_set : PoolIntArray = []
	var temp_path : String = ""
	var temp_main_idx : int = -1
	for n in SongLists.normal_playlists.values()[playlist_idx].size():
		temp_path = SongLists.normal_playlists.values()[playlist_idx].keys()[n]
		temp_main_idx = AllSongs.get_main_idx(temp_path)
		idxs_to_set.push_back(temp_main_idx)
	return idxs_to_set


func _on_NewPlaylist_resized():
	if song_vbox:
		song_vbox.playlist_root_rect = self.get_global_rect()


func on_delete_smart_playlist_pressed():
	SongLists.smart_playlists.erase(playlist_title)
	ExtendedDirectory.delete_file(Global.get_current_user_data_folder() + "/Songs/Playlists/Covers/" + playlist_title + ".png")
	ExtendedDirectory.delete_file(Global.get_current_user_data_folder() + "/Songs/Playlists/Metadata/Descriptions/" + playlist_title + ".txt")
	unload()


func on_delete_pressed():
	var playlist_key : String = SongLists.normal_playlists.keys()[playlist_idx]
	if !SongLists.normal_playlists.erase(playlist_key):
		Global.root.message("DELETIING PLAYLIST COVER FROM USER DATA",  SaveData.MESSAGE_ERROR )
	ExtendedDirectory.delete_file(OS.get_user_data_dir() + "/Songs/Playlists/Covers/" + playlist_key + ".png")
	SaveData.erase_key_from_file(SongLists.file_paths[9],playlist_key)
	unload()


func _on_queue_playlist_pressed() -> void:
	# queueing all the Songs in trhe Current Playlist
	for n in SongLists.normal_playlists.values()[playlist_idx].size():
		SongLists.queue_song(SongLists.normal_playlists.values()[playlist_idx].keys()[n])


func change_playlist_cover():
	var _dialog = Global.root.load_general_file_dialogue(
		self,
		FileDialog.MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"new_cover_selected",
		[],
		UsedFilepaths.PLAYLIST_COVER,
		Global.supported_img_extensions,
		true,
		"Select New Playlist Cover"
	)


func new_cover_selected(var new_cover_path : String) -> void:
	var dir : Directory = Directory.new()
	var _err : int = dir.copy(new_cover_path, playlist_cover_path)
	self.init_header()


func rename_playlist() -> void:
	Global.root.toggle_songlist_input(false)
	var x : Node = load("res://src/Scenes/General/TextInputDialogue.tscn").instance()
	Global.root.add_child(x)
	x.set_topic("New Playlist Title")
	var _err = x.connect("text_saved", Playlist, "rename_playlist", [playlist_idx])
	_err = x.connect("saved",self,"unload")
	_err = x.connect("tree_exited", Global.root, "toggle_songlist_input", [true])


func export_playlist() -> void:
	var playlist_export_menu : Node = load("res://src/Scenes/Export/PlaylistExportMenu.tscn").instance()
	Global.root.top_ui.add_child(playlist_export_menu)
	playlist_export_menu.init_export_menu(playlist_idx)
