extends Control

const SONG_OPTIONS_OFFSET : int = 40
const MIN_HEADER_SIZE : int = 55
const MAX_HEADER_SIZE : int = 154
const HEADER_LABEL_HEIGHT : int = 16
const HIGHLIGHTED_SONG : Resource = preload("res://src/Ressources/Themes/Song/HighlightedSong.tres")

onready var songs : VBoxContainer = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller/Songs
onready var song_scroller : ScrollContainer = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller
onready var song_highlighter : HBoxContainer = null
onready var title : Label = null
onready var playlist_options : TextureButton
onready var header_cover : TextureRect = null
onready var infos : Array = []

var song_scroller_rect : Rect2
var idx : int = -1
var temp_pos : float = -1.0
var temp_idx : int = -1
var song_options_ref : Node = null
var playlist_idx : int = -1
var is_scrolling_fast : bool = false
var header_expanded : bool = true
var last_scroll_value : float = 0.0

func _ready():
	_on_SongScroller_resized()


func _exit_tree():
	free_highlighted_songs()


func _process(_delta):
	temp_idx =  song_scroller.real_index(song_scroller.calc_idx())
	if !is_scrolling_fast:
		if song_scroller_rect.has_point(get_global_mouse_position()):
			idx = temp_idx
			if idx >= 0:
				temp_pos = songs.rect_position.y
				song_highlighter.rect_global_position.y = songs.get_child(temp_idx).rect_position.y + song_scroller.rect_global_position.y + temp_pos
	else:
		if temp_idx >= 0:
			if song_scroller_rect.has_point(get_global_mouse_position()):
				song_highlighter.rect_global_position.y = get_global_mouse_position().y


func connect_scroll_container() -> void:
	if songs.get_parent().connect("space_pressed",self,"on_songspace_left_clicked"):
		Global.root.message("CONNECTING SPACE PRESSED SIGNAL WITH LEFT BUTTON CLICKED FUNCTION",  SaveData.MESSAGE_ERROR )
	if songs.get_parent().connect("space_rightclick",self,"on_songspace_right_clicked"):
		Global.root.message("CONNECTING SPACE RIGHTCLICKED SIGNAL WITH RIGHT BUTTON CLICKED FUNCTION",  SaveData.MESSAGE_ERROR )


func unload_playlist():
	Global.root.delete_current_option()
	Global.root.load_option(1, true)


func get_songspace_path(var l_idx : int) -> String:
	return songs.get_child(l_idx).path


func get_index_from_songlist(var path : String) -> int:
	for songspace in songs.get_children():
		if songspace.path == path:
			return songspace.get_index();
	return -1;


func highlight_song(var songspace : HBoxContainer) ->  void:
	songspace.get_child(0).set_deferred("custom_styles/panel", HIGHLIGHTED_SONG)


func unhighlight_song(var l_idx : int) -> void:
	if l_idx != -1:
		songs.get_child(l_idx).get_child(0).set_deferred("custom_styles/panel", null)


func free_highlighted_songs() -> void:
	# clearing CTRL highlighted songs
	for highlighted_song in SongLists.highlighted_songs:
		songs.get_child( get_index_from_songlist(highlighted_song) ).modulate = Color("ffffff")
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
	if l_idx >= 0:
		if !Input.is_key_pressed(KEY_CONTROL):
			free_highlighted_songs()
			# playing pressed song
			var song_ : Control = songs.get_child(l_idx)
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
			SongLists.add_highlighted_song(songs, l_idx)


func  _on_SongScroller_resized():
	song_scroller_rect =  song_scroller.get_global_rect()


func get_playlist_song_amount() -> int:
	if playlist_idx >= 0:
		# normal Playlists
		return SongLists.normal_playlists.values()[playlist_idx].size();
	elif playlist_idx <= -2:
		# temporary and Smart Playlists
		return SongLists.pressed_temporary_playlist.size();
	elif playlist_idx == -1:
		# all Songs
		return SongLists.AllSongs.size();
	return -1;


func get_playlist_creation_date() -> String:
	var playlist_name : String = Playlist.get_playlist_name(playlist_idx)
	var temp_date = SaveData.get_key_from_file(SongLists.add_user_to_filepath(SongLists.file_paths[9]),playlist_name,0)
	if temp_date:
		var time_formatter : TimeFormatter = TimeFormatter.new()
		var daytime : String = time_formatter.format_daytime(temp_date.hour, temp_date.minute, temp_date.second)
		var date : String = time_formatter.format_date(temp_date.day,temp_date.month,temp_date.year)
		return daytime + " " + date;
	else:
		return "00:00:00 0000 00 000"


func get_playlist_runtime() -> String:
	return TimeFormatter.format_seconds(Playlist.get_runtime_seconds(playlist_idx)) + "min"


func _on_PlaylistOptions_pressed(var is_smart : bool = false):
	if !song_options_ref:
		Global.root.toggle_songlist_input(false)
		var x : Node
		if !is_smart:
			x = load("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/NormalPlaylist/NormalPlaylistOptions.tscn").instance()
		else:
			x = load("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/SmartPlaylist/SmartPlaylistOptions.tscn").instance()
		song_options_ref = x
		var _err = x.connect("tree_exiting",self,"set",["song_options_ref",null])
		_err = x.connect("tree_exiting",Global.root,"toggle_songlist_input",[true])
		self.add_child(song_options_ref)
		song_options_ref.set_owner(self)
		song_options_ref.connect_option_signals()
		song_options_ref.rect_global_position = playlist_options.rect_global_position
		song_options_ref.rect_global_position.x -= song_options_ref.rect_size.x / 2.25
		song_options_ref.rect_global_position.y -= 10
	else:
		song_options_ref.queue_free()


func rename_playlist() -> void:
	Global.root.toggle_songlist_input(false)
	var x : Node = load("res://src/Scenes/General/TextInputDialogue.tscn").instance()
	Global.root.add_child(x)
	x.set_topic("New Playlist Title")
	var _err = x.connect("text_saved",Playlist,"rename_playlist",[playlist_idx])
	_err = x.connect("tree_exited",self,"unload_playlist")
	_err = x.connect("tree_exited",Global.root,"toggle_songlist_input",[true])


func export_playlist() -> void:
	var playlist_export_menu : Node = load("res://src/Scenes/Export/PlaylistExportMenu.tscn").instance()
	Global.root.top_ui.add_child(playlist_export_menu)
	playlist_export_menu.init_export_menu(playlist_idx)


func on_scroll_value_changed(var val : float) -> void:
	# header Expanding/Contracting
	val /= 2.0
	var new_height : float
	
	if val > 0.0 and header_expanded:
		toggle_header_infos(false)
	elif val <= 0.0:
		toggle_header_infos(true,MAX_HEADER_SIZE)
	
	if !header_expanded:
		new_height = MAX_HEADER_SIZE - val
		if new_height > MIN_HEADER_SIZE:
			if val - last_scroll_value > 0.0:
				# scrolling Down
				set_header_infos_height(
					# If the 1st part is greater zero then the 2nd part defines height,
					# else it's 0, since x * 0 = 0 
					int(val <= HEADER_LABEL_HEIGHT) * (HEADER_LABEL_HEIGHT - val)
				)
				
			else:
				# scrolling Up
				set_header_infos_height(
					#If the 1st part is greater zero then the 2nd part defines height,
					#else it's 0, since x * 0 = 0 
					int(HEADER_LABEL_HEIGHT - val >= 0.0) * (HEADER_LABEL_HEIGHT - val)
				)
			var _ptw : PropertyTweener = create_tween().tween_property(
				header_cover,
				"rect_min_size:y",
				new_height,
				0.1
			)
		else:
			header_cover.rect_min_size.y = MIN_HEADER_SIZE
	# saving Last Scroll Value to see Scroll trend (up/down)
	last_scroll_value = val


func toggle_header_infos(var toggle : bool, var min_height : int = -1) -> void:
	for x in infos:
		for i in x.get_children():
			if i.has_method("set_visible"):
				i.set_visible(toggle)
	header_expanded = toggle
	if min_height != -1: header_cover.rect_min_size.y = min_height;


func set_header_infos_height(var new_height : float) -> void:
	for i in infos:
		i.rect_min_size.y = new_height


func on_set_cover_pressed():
	var _dialog = Global.root.load_general_file_dialogue(
		self,
		FileDialog.MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"on_cover_selected",
		[],
		"Image",
		Global.supported_img_extensions,
		true,
		"Select New Playlist Cover"
	)
