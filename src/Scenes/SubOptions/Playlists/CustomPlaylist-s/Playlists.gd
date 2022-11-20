extends Control

enum PlaylistType{
	NORMAL_FROM_SCRATCH,
	NORMAL_FROM_FOLDER,
	SMART_FROM_SCRATCH
}

const SCROLL_SPEED : int = 45
const PLAYLIST_CONTAINER_LENGTH : int = 170
const PLAYLIST_CONTAINER : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/PlaylistsContainer.tscn")
const PLAYLIST_FROM_SCRATCH : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/PlaylistFromScratch.tscn")
const PLAYLIST_FROM_FOLDER : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/Creators/PlaylistFromFolder.tscn")
const SMART_PLAYLIST_CREATOR : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/Creators/SmartPlaylistCreator.tscn")

onready var playlists : GridContainer = $VBoxContainer/HBoxContainer/ScrollContainer/Playlists
onready var new_smart_playlist : Button =  $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer/CreatePlaylist
onready var new_playlist_from_folder : Button = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer/CreateFromFolder
onready var new_playlist : Button = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer/CreateSmartPlaylist

func _ready():
	var _err = new_smart_playlist.connect("pressed",self,"_on_create_new_playlist_pressed",[PlaylistType.NORMAL_FROM_SCRATCH])
	_err = new_playlist_from_folder.connect("pressed",self,"_on_create_new_playlist_pressed",[PlaylistType.NORMAL_FROM_FOLDER])
	_err = new_playlist.connect("pressed",self,"_on_create_new_playlist_pressed",[PlaylistType.SMART_FROM_SCRATCH])
	_err = playlists.connect("item_rect_changed",self,"_on_playlists_item_rect_changed")
	load_playlist_grid()


func _on_playlists_item_rect_changed():
	# refactor the Playlists on a change of itself's size
	# +7 so the right pixel won't get cut off on edge cases
	# why 7, 10 is to large -> always one container to little, anything below breaks when resizing down
	var separation_offset : int = playlists.get("custom_constants/hseparation") * (playlists.columns - 1)
	var places : int = int(playlists.rect_size.x / (PLAYLIST_CONTAINER_LENGTH + separation_offset ))
	playlists.columns = places


func load_playlist_grid() -> void:
	# init
	playlists.get_parent().get_v_scrollbar().set_script( load("res://src/Scenes/SubOptions/Playlists/SongVBox/SongVScrollbar.gd") )
	playlists.get_parent().get_v_scrollbar().set_h_size_flags(SIZE_SHRINK_CENTER)
	playlists.get_parent().get_v_scrollbar()._ready()
	
	# normal Playlist
	for idx in SongLists.normal_playlists.size():
		var playlist : Control = PLAYLIST_CONTAINER.instance()
		playlist.idx = idx
		playlists.add_child(playlist)
		playlist.set_owner(self)
		playlist.title.set_text(SongLists.normal_playlists.keys()[idx])
		playlist.cover.set_texture( Playlist.get_playlist_cover(idx) )
	
	# smart Playlists
	for n in SongLists.smart_playlists.size():
		var playlist : Control = PLAYLIST_CONTAINER.instance()
		playlist.idx = - 3 - n
		playlist.find_node("Cover").set_texture( ImageLoader.get_cover(Global.get_current_user_data_folder() + "/Songs/Playlists/Covers/" + SongLists.smart_playlists[n] + ".png") )
		playlists.add_child(playlist)
		playlist.set_owner(self)
		playlist.title.set_text( SongLists.smart_playlists[n] )


func _on_create_new_playlist_pressed(var new_playlist_type : int) -> void:
	var playlist_creator_ref : Node = null
	
	match new_playlist_type:
		
		PlaylistType.NORMAL_FROM_SCRATCH:
			playlist_creator_ref = PLAYLIST_FROM_SCRATCH.instance()
			Global.root.top_ui.add_child(playlist_creator_ref)
			if playlist_creator_ref.cover_hbox.connect("dialogue_pressed", Global.root, "load_general_file_dialogue",[
				playlist_creator_ref.cover_hbox.input_edit,
				FileDialog.MODE_OPEN_FILE,
				FileDialog.ACCESS_FILESYSTEM,
				"set_text",
				[],
				"Image",
				Global.supported_img_extensions,
				true
				]):
				Global.root.message("CONNECTING DIALOGUE PRESSED SIGNAL",  SaveData.MESSAGE_ERROR )
		
		PlaylistType.NORMAL_FROM_FOLDER:
			playlist_creator_ref = PLAYLIST_FROM_FOLDER.instance()
			Global.root.top_ui.add_child(playlist_creator_ref)
			if playlist_creator_ref.cover_hbox.connect("dialogue_pressed", Global.root, "load_general_file_dialogue",[playlist_creator_ref.cover_hbox.input_edit,FileDialog.MODE_OPEN_FILE,FileDialog.ACCESS_FILESYSTEM,"set_text",[],"Image",Global.supported_img_extensions,true]):
				Global.root.message("CONNECTING DIALOGUE PRESSED SIGNAL",  SaveData.MESSAGE_ERROR )
			if playlist_creator_ref.folder.connect("dialogue_pressed", Global.root, "load_general_file_dialogue",[
				playlist_creator_ref.folder.input_edit,
				FileDialog.MODE_OPEN_DIR,
				FileDialog.ACCESS_FILESYSTEM,
				"set_text",
				[],
				"Song",
				[],
				true
				]):
				Global.root.message("CONNECTING DIALOGUE PRESSED SIGNAL",  SaveData.MESSAGE_ERROR )
		
		PlaylistType.SMART_FROM_SCRATCH:
			playlist_creator_ref = SMART_PLAYLIST_CREATOR.instance()
			Global.root.top_ui.add_child(playlist_creator_ref)
	var _err = playlist_creator_ref.connect("save",self,"save_new_playlist",[new_playlist_type])


func save_new_playlist(var playlist_title : String, var playlist_cover_path : String, var folder : String, var conditions : Dictionary , var new_playlist_type : int) -> void:
	if !Playlist.is_valid_playlist_title(playlist_title):
		Global.root.message("Illegal Title!!\nTitle Can't be empty or the same as another Playlist", SaveData.MESSAGE_ERROR, true)
		return

	match new_playlist_type:
		
		PlaylistType.NORMAL_FROM_SCRATCH:
			SongLists.new_playlist(playlist_title)
		
		PlaylistType.NORMAL_FROM_FOLDER:
			var dir : Directory = Directory.new()
			if dir.open(folder) != OK:
				Global.root.message("Selected Folder Could not be opened", SaveData.MESSAGE_ERROR, true)
			var folder_already_added : bool = false
			if folder in SongLists.folders:
				# checking if New Folder has already been added
				folder_already_added = true
			else:
				SongLists.add_folder(folder)
			SongLists.new_playlist(playlist_title)
			
			# adding the Songs from folder to Playlist
			var counter : int = AllSongs.get_song_amount()
			if dir.list_dir_begin(true,true) == OK:
				while true:
					var song : String = dir.get_next()
					if song != "":
						if FormatChecker.get_music_filename_extension(song) != -1:
							var song_path : String = dir.get_current_dir() + "/" + song
							# adding to AllSongs if not already in there
							var main_idx : int = 0
							if folder_already_added:
								main_idx = AllSongs.get_main_idx(song_path)
							else:
								main_idx = counter
								counter += 1
							# adding to Playlist
							SongLists.normal_playlists.values()[SongLists.normal_playlists.size() - 1][song_path] = [main_idx]
					else:
						break;
		
		PlaylistType.SMART_FROM_SCRATCH:
			SongLists.new_smart_playlist(playlist_title,conditions)
	
	Playlist.copy_playlist_cover(playlist_cover_path, Playlist.get_playlist_index(playlist_title) )
	Global.root.reload_option()


func add_new_playlist_to_grid(var is_smart : bool, var playlist_cover_path : String) -> void:
	var new_playlist_container : Control = PLAYLIST_CONTAINER.instance()
	var playlist_title : String = ""
	var playlist_idx : int
	
	if is_smart:
		var smart_playlist_idx : int = SongLists.smart_playlists.size() - 1
		playlist_idx = -3 - smart_playlist_idx
		playlist_title = SongLists.smart_playlists[smart_playlist_idx]
	else:
		playlist_idx = SongLists.normal_playlists.size() - 1
		playlist_title = SongLists.normal_playlists.keys()[playlist_idx]
	
	playlists.add_child(new_playlist_container)
	new_playlist_container.set_owner(self)
	new_playlist_container.title.set_text(playlist_title)
	new_playlist_container.Cover.set_texture( ImageLoader.get_cover(playlist_cover_path) )
	new_playlist_container.idx = playlist_idx
