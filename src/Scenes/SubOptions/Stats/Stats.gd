extends Control

const MAX_STATS : int = 40 
const OPTION_HIGHLIGHT_CLR : String = "c1c1c1"

var option_texts : PoolStringArray = []
var current_tab : int = 1
var special_places : int = 3

onready var options : HBoxContainer = $VBoxContainer/HBoxContainer
onready var contents : VBoxContainer = $VBoxContainer/Panel/VBoxContainer/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/Contents
onready var indexes : VBoxContainer = $VBoxContainer/Panel/VBoxContainer/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/Indexes
onready var values : VBoxContainer = $VBoxContainer/Panel/VBoxContainer/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/Values
onready var title : Label = $VBoxContainer/Panel/VBoxContainer/Title/HBoxContainer/Title
onready var scroller : ScrollContainer = $VBoxContainer/Panel/VBoxContainer/HBoxContainer/ScrollContainer
onready var toptitles : HBoxContainer = $VBoxContainer/Panel/VBoxContainer/HBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer2/TopTitles/TopTitles

func _ready():
	for n in options.get_child_count():
		var option : Button = options.get_child(n)
		option_texts.push_back(option.get_child(0).get_text())
		if option.connect("pressed",self,"switch_tab",[n]) != OK:
			Global.root.message("CONNECTING STATS OPTIONS BUTTONS",  SaveData.MESSAGE_ERROR )
	create_spaces(MAX_STATS)
	switch_tab(current_tab)
	options.get_child(current_tab).self_modulate = OPTION_HIGHLIGHT_CLR


func switch_tab(var idx : int) -> void:
	#Scrolling back to the top since else it might seem there aren't any options loaded
	scroller.set_v_scroll(0)
	options.get_child(current_tab).self_modulate = "ffffff"
	current_tab = idx
	options.get_child(current_tab).self_modulate = OPTION_HIGHLIGHT_CLR
	title.set_text(option_texts[idx])
	load_stats(idx)


func load_stats(var idx : int) -> void:
	var songs : PoolVector2Array = get_most_streamed(idx)
	clear_spaces(MAX_STATS)
	set_stats(songs,idx)


func get_most_streamed(var stream_type_idx : int) -> PoolVector2Array:
	# saves the streams in x and index of stream dictionary in y
	var all_songs : PoolVector2Array = []
	all_songs = get_streams(stream_type_idx)
	
	# sorts all the Songs after their "streaming" numbers -> BubbleSort
	for n in all_songs.size():
		for m in all_songs.size()-1:
			if all_songs[m].x > all_songs[m+1].x:
				var x = all_songs[m]
				all_songs[m] = all_songs[m+1]
				all_songs[m+1] = x
	
	# removing all the Songs that are not part of the TOP 40 (MAX_STATS)
	if all_songs.size() >= MAX_STATS:
		for n in all_songs.size() - MAX_STATS:
			all_songs.remove(0)
	
	# returninig top streamed instances
	return all_songs


func set_stats(var songs : PoolVector2Array, var stream_type_idx : int) -> void:
	if songs.size() > 0:
		var index : int = 0
		var value : int = 0
		var song_dict : Dictionary = get_stream_dict(stream_type_idx)
		var amount : int = 0
		var main_idx : int = -1
		if songs.size() > MAX_STATS:
			amount = 40
		else:
			amount = songs.size() 
		for n in range(amount - 1,-1,-1):
			index = amount - 1 - n
			if stream_type_idx == 1:
				main_idx = AllSongs.get_main_idx(song_dict.keys()[songs[n].y])
			if index >= 3:
				value = song_dict.values()[songs[n].y][0]
				if value > 0:
					if main_idx == -1:
						contents.get_child(index - special_places).text = song_dict.keys()[songs[n].y]
					else:
						contents.get_child(index - special_places).text = AllSongs.song_title(main_idx)
					values.get_child(index - special_places).text = "       " + str(song_dict.values()[songs[n].y][0])
					indexes.get_child(n).set_text(str(n+1 + special_places) + ".)")
				else:
					break;
			else:
				if main_idx == -1:
					toptitles.get_node(str(index + 1) + "/Title").set_text(song_dict.keys()[songs[n].y])
				else:
					toptitles.get_node(str(index + 1) + "/Title").set_text(AllSongs.song_title(main_idx))
				toptitles.get_node(str(index + 1) + "/Streams").set_text(str(song_dict.values()[songs[n].y][0]))


func get_stream_dict(var stream_type_idx : int) -> Dictionary:
	match stream_type_idx:
		1:
			return SongLists.Streams
		2:
			return SongLists.playlist_streams
		0:
			return SongLists.artist_streams
	return  {}


func get_streams(var stream_type_idx : int ) -> PoolVector2Array:
	var songs : PoolVector2Array = []
	var streams : Dictionary = get_stream_dict(stream_type_idx)
	for n in streams.size():
		if streams.values()[n][0] > 0:
			songs.push_back(Vector2(streams.values()[n][0],n))
	return songs


func create_spaces(var spaces : int) -> void:
	for _n in range(special_places,spaces):
		var new_song : Label = Label.new()
		var new_streams : Label = Label.new()
		var new_index : Label = Label.new()
		values.add_child(new_streams)
		indexes.add_child(new_index)
		contents.add_child(new_song)


func clear_spaces(var spaces : int) -> void:
	for n in spaces:
		if n >= special_places:
			contents.get_child(n - special_places).text = ""
			indexes.get_child(n - special_places).text = ""
			values.get_child(n - special_places).text = ""
		else:
			toptitles.get_node(str(n + 1) + "/Title").set_text("")
			toptitles.get_node(str(n + 1) + "/Streams").set_text("")


func _on_Export_pressed():
	var current_tab_streams : Dictionary = get_stream_dict(current_tab)
	var sorted_streams : PoolVector2Array = get_most_streamed(current_tab)
	var sorted_streams_list : Array = []
	
	for i in range(sorted_streams.size() - 1, 0, -1):
		#Adding the place, title and streams
		sorted_streams_list.push_back(
			[
				str(sorted_streams.size() - i) + ".)",
				current_tab_streams.keys()[sorted_streams[i].y].get_file(),
				str(sorted_streams[i].x)
			]
		)
	var export_menu : Control = load("res://src/Scenes/Export/export_menu.tscn").instance() 
	Global.root.top_ui.add_child(export_menu)
	export_menu.init_export_menu(sorted_streams_list)
