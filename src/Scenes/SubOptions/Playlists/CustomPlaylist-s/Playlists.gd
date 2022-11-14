extends Control


#ENUMS
enum PlaylistType{
	NORMAL_FROM_SCRATCH,
	NORMAL_FROM_FOLDER,
	SMART_FROM_SCRATCH
}

#CONST
const SCROLL_SPEED : int = 45
const PLAYLIST_CONTAINER_LENGTH : int = 170

#PRELOADS
const playlist_container : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/PlaylistsContainer.tscn")
const PlaylistFromScratch : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/PlaylistFromScratch.tscn")
const PlaylistFromFolder : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/Creators/PlaylistFromFolder.tscn")
const SmartPlaylistCreator : PackedScene = preload("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/Creators/SmartPlaylistCreator.tscn")

#NODES
onready var main : Control = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)
onready var playlists : GridContainer = $VBoxContainer/HBoxContainer/ScrollContainer/Playlists
onready var CreatePlaylistFromScratch : Button =  $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer/CreatePlaylist
onready var CreatePlaylistFromFolder : Button = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer/CreateFromFolder
onready var CreateSmartPlaylistFromScratch : Button = $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer/CreateSmartPlaylist


func _ready():
	var _err = CreatePlaylistFromScratch.connect("pressed",self,"CreateNewPlaylistPressed",[PlaylistType.NORMAL_FROM_SCRATCH])
	_err = CreatePlaylistFromFolder.connect("pressed",self,"CreateNewPlaylistPressed",[PlaylistType.NORMAL_FROM_FOLDER])
	_err = CreateSmartPlaylistFromScratch.connect("pressed",self,"CreateNewPlaylistPressed",[PlaylistType.SMART_FROM_SCRATCH])
	_err = playlists.connect("item_rect_changed",self,"OnPlaylistsItemRectChanged")
	LoadPlaylistGrid()


func OnPlaylistsItemRectChanged():
	#Refactor the Playlists on a change of itself's size
	#+7 so the right pixel won't get cut off on edge cases
	#why 7, 10 is to large -> always one container to little, anything below breaks when resizing down
	var separation_offset : int = playlists.get("custom_constants/hseparation") * (playlists.columns - 1)
	var places : int = int( playlists.rect_size.x / (PLAYLIST_CONTAINER_LENGTH + separation_offset ) )
	playlists.columns = places


func LoadPlaylistGrid() -> void:
	#Init
	playlists.get_parent().get_v_scrollbar().set_script( load("res://src/Scenes/SubOptions/Playlists/SongVBox/SongVScrollbar.gd") )
	playlists.get_parent().get_v_scrollbar().set_h_size_flags(SIZE_SHRINK_CENTER)
	playlists.get_parent().get_v_scrollbar()._ready()
	
	#Normal Playlist
	for Idx in SongLists.Playlists.size():
		var playlist : Control = playlist_container.instance()
		#playlist.set_owner(self)
		playlist.idx = Idx
		playlists.add_child(playlist)
		playlist.set_owner(self)
		playlist.Title.set_text(SongLists.Playlists.keys()[Idx])
		playlist.Cover.set_texture( Playlist.GetPlaylistCover(Idx) )
	
	#Smart Playlists
	for n in SongLists.SmartPlaylists.size():
		var playlist : Control = playlist_container.instance()
		playlist.idx = - 3 - n
		playlist.find_node("Cover").set_texture( ImageLoader.GetCover(Global.GetCurrentUserDataFolder() + "/Songs/Playlists/Covers/" + SongLists.SmartPlaylists[n] + ".png") )
		playlists.add_child(playlist)
		playlist.set_owner(self)
		playlist.Title.set_text( SongLists.SmartPlaylists[n] )


func CreateNewPlaylistPressed(var NewPlaylistType : int) -> void:
	var PlaylistCreator : Node = null
	
	match NewPlaylistType:
		
		PlaylistType.NORMAL_FROM_SCRATCH:
			PlaylistCreator = PlaylistFromScratch.instance()
			Global.root.top_ui.add_child(PlaylistCreator)
			if PlaylistCreator.Cover.connect("DialoguePressed",main,"load_general_file_dialogue",[PlaylistCreator.Cover.InputEdit,FileDialog.MODE_OPEN_FILE,FileDialog.ACCESS_FILESYSTEM,"set_text",[],"Image",Global.SupportedImgFormats,true]):
				Global.root.message("CONNECTING DIALOGUE PRESSED SIGNAL",  SaveData.MESSAGE_ERROR )
		
		PlaylistType.NORMAL_FROM_FOLDER:
			PlaylistCreator = PlaylistFromFolder.instance()
			Global.root.top_ui.add_child(PlaylistCreator)
			if PlaylistCreator.Cover.connect("DialoguePressed",main,"load_general_file_dialogue",[PlaylistCreator.Cover.InputEdit,FileDialog.MODE_OPEN_FILE,FileDialog.ACCESS_FILESYSTEM,"set_text",[],"Image",Global.SupportedImgFormats,true]):
				Global.root.message("CONNECTING DIALOGUE PRESSED SIGNAL",  SaveData.MESSAGE_ERROR )
			if PlaylistCreator.Folder.connect("DialoguePressed",main,"load_general_file_dialogue",[PlaylistCreator.Folder.InputEdit,FileDialog.MODE_OPEN_DIR,FileDialog.ACCESS_FILESYSTEM,"set_text",[],"Song",[],true]):
				Global.root.message("CONNECTING DIALOGUE PRESSED SIGNAL",  SaveData.MESSAGE_ERROR )
		
		PlaylistType.SMART_FROM_SCRATCH:
			PlaylistCreator = SmartPlaylistCreator.instance()
			Global.root.top_ui.add_child(PlaylistCreator)
	
	var _err = PlaylistCreator.connect("Save",self,"SaveNewPlaylist",[NewPlaylistType])


func SaveNewPlaylist(var PlaylistTitle : String, var PlaylistCoverPath : String, var Folder : String, var Conditions : Dictionary ,var NewPlaylistType : int) -> void:
	if !Playlist.CheckPlaylistTitle(PlaylistTitle):
		main.message("Illegal Title!!\n Title Can't be Empty or the same as another Playlist", SaveData.MESSAGE_ERROR)
	
	match NewPlaylistType:
		
		PlaylistType.NORMAL_FROM_SCRATCH:
			SongLists.NewPlaylist(PlaylistTitle)
		
		PlaylistType.NORMAL_FROM_FOLDER:
			var dir : Directory = Directory.new()
			if dir.open(Folder) != OK:
				Global.root.message("Selected Folder Could not be opened", SaveData.MESSAGE_ERROR, true)
			var InFolders : bool = false
			if Folder in SongLists.Folders:
				#Checking if New Folder has already been added
				InFolders = true
			else:
				SongLists.AddFolder(Folder)
			SongLists.NewPlaylist(PlaylistTitle)
			
			#Adding the Songs from folder to Playlist
			var counter : int = AllSongs.GetSongAmount()
			if dir.list_dir_begin(true,true) == OK:
				while true:
					var song : String = dir.get_next()
					if song != "":
						if FormatChecker.FileNameFormat(song) != -1:
							var song_path : String = dir.get_current_dir() + "/" + song
							#Adding to AllSongs if not already in there
							var main_idx : int = 0
							if InFolders:
								main_idx = AllSongs.GetMainIdx(song_path)
							else:
								main_idx = counter
								counter += 1
							#Adding to Playlist
							SongLists.Playlists.values()[SongLists.Playlists.size() - 1][song_path] = [main_idx]
					else:
						break;
		
		PlaylistType.SMART_FROM_SCRATCH:
			SongLists.NewSmartPlaylist(PlaylistTitle,Conditions)
	
	Playlist.CopyPlaylistCover(PlaylistCoverPath, Playlist.GetPlaylistIndex(PlaylistTitle) )
	Global.root.reload_option()


func AddNewPlaylistToGrid(var IsSmart : bool, var PlaylistCoverPath : String) -> void:
	var NewPlaylistContainer : Control = playlist_container.instance()
	var PlaylistTitle : String = ""
	var PlaylistIdx : int
	
	if IsSmart:
		var SmartPlaylistIdx : int = SongLists.SmartPlaylists.size() - 1
		PlaylistIdx = -3 - SmartPlaylistIdx
		PlaylistTitle = SongLists.SmartPlaylists[ SmartPlaylistIdx ]
	else:
		PlaylistIdx = SongLists.Playlists.size() - 1
		PlaylistTitle = SongLists.Playlists.keys()[PlaylistIdx]
	
	playlists.add_child(NewPlaylistContainer)
	NewPlaylistContainer.set_owner(self)
	NewPlaylistContainer.Title.set_text(PlaylistTitle)
	NewPlaylistContainer.Cover.set_texture( ImageLoader.GetCover(PlaylistCoverPath) )
	NewPlaylistContainer.idx = PlaylistIdx
