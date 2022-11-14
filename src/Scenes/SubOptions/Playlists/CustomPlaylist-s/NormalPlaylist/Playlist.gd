extends "res://src/Scenes/SubOptions/Playlists/PlaylistLoader.gd"

#NODES
onready var Scroll : ScrollContainer = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller
onready var Header : PanelContainer = $HBoxContainer/VBoxContainer/Header
onready var SongAmount : Label = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Songs/Amount
onready var CreationDate : Label = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Creation/Date
onready var Runtime : Label = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Length/Time


func _ready():
	var _err = Scroll.get_v_scrollbar().connect("value_changed",self,"OnScrollValueChanged")
	playlist_idx = Global.PlaylistPressed
	PlaylistOptions = $HBoxContainer/VBoxContainer/Header/HBoxContainer/PlaylistOptions
	songs = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller/Songs
	SongHighlighter = $SongHighlighter
	HeaderCover = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer2/Cover
	Infos = [
		$HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Creation,
		$HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Songs,
		$HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Length
	]
	var IdxsToSet : PoolIntArray = []
	var TempPath : String = ""
	var TempMainIdx : int = 0
	for n in SongLists.Playlists.values()[playlist_idx].size():
		TempPath = SongLists.Playlists.values()[playlist_idx].keys()[n]
		TempMainIdx = AllSongs.get_main_idx(TempPath)
		IdxsToSet.push_back(TempMainIdx)
	if IdxsToSet.size() > 0:
		#Calling this function with empty Array would load all songs
		var x : SongLoader = SongLoader.new()
		x.CreateSongsSpaces(songs, IdxsToSet, playlist_idx)
	ConnectScrollContainer()
	title = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Title
	var playlist_name : String = Playlist.get_playlist_name(playlist_idx)
	title.set_text(playlist_name)
	
	#Setting playlist name in Thread so Song without Cover will be overriden with Playlist Cover
	#SongLoader = playlist_name
	
	#Setting the Header Cover
	var playlist_cover_path : String = Global.GetCurrentUserDataFolder() + "/Songs/Playlists/Covers/" + Playlist.get_playlist_name(playlist_idx) + ".png"
	HeaderCover.texture = ImageLoader.get_cover(playlist_cover_path,playlist_name)
	
	#Setting Header Info
	SongAmount.text = str( GetPlaylistSongAmount() )
	CreationDate.text = GetPlaylistCreationDate()
	Runtime.text = GetPlaylistRuntime()


func OnCoverSelected(var ImgSrc : String):
	#Saving Cover Copy in User Data
	HeaderCover.texture = Playlist.copy_playlist_cover(ImgSrc,playlist_idx,true)


func OnDeletePressed():
	var playlist_key : String = SongLists.Playlists.keys()[playlist_idx]
	if !SongLists.Playlists.erase(playlist_key):
		Global.root.message("DELETIING PLAYLIST COVER FROM USER DATA",  SaveData.MESSAGE_ERROR )
	ExtendedDirectory.delete_file(OS.get_user_data_dir() + "/Songs/Playlists/Covers/" + playlist_key + ".png")
	SaveData.erase_key_from_file(SongLists.FilePaths[9],playlist_key)
	UnloadPlaylist()


func OnQueuePlaylistPressed() -> void:
	#Queueing all the Songs in trhe Current Playlist
	for n in SongLists.Playlists.values()[playlist_idx].size():
		SongLists.QueueSong( SongLists.Playlists.values()[playlist_idx].keys()[n] )
