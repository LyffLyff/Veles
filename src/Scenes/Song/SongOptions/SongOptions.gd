extends Control


#VARIABLES
#this value is set when right clicking a songspace
var SongIdx : int = -1
var is_ready : bool = false


func _enter_tree():
	Global.root.ToggleSongScrollerInput(false)


func _exit_tree():
	Global.root.ToggleSongScrollerInput(true)


func _ready():
	is_ready = true
	#hides the remove from playlist button if it isn't inside a playlist
	if Global.PlaylistPressed == -1:
		if self.has_node("PanelContainer/HBoxContainer/VBoxContainer/RemoveFromPlaylist"):
			self.get_node("PanelContainer/HBoxContainer/VBoxContainer/RemoveFromPlaylist").hide()
		else:
			self.get_node("VBoxContainer/HBoxContainer/VBoxContainer/RemoveFromPlaylist").hide()
	else:
		if self.has_node("PanelContainer/HBoxContainer/VBoxContainer/RemoveFromPlaylist"):
			self.get_node("PanelContainer/HBoxContainer/VBoxContainer/RemoveFromPlaylist").show()
		else:
			self.get_node("VBoxContainer/HBoxContainer/VBoxContainer/RemoveFromPlaylist").show()
	self.modulate.a = 0.0
	var _err = create_tween().set_trans(Tween.TRANS_LINEAR).tween_property(self,"modulate:a",1.0,0.3)


func _process(_delta):
	if !is_ready:
		return
	if !self.get_global_rect().has_point( get_global_mouse_position() ):
		FreeSongOptions()


func GetClickedSongPath() -> String:
	if SongIdx >= 0:
		var option : Control = Global.root.options.get_child(0)
		if option.get("songs") != null:
			var songs : VBoxContainer = option.songs
			return songs.get_child(SongIdx).path
	return ""


func _on_ChangeTag_pressed(var main_idx : int = -1):
	Global.root.player.DisableImageView()
	var SongPath : String = AllSongs.GetSongPath(main_idx)
	if main_idx != -1:
			Global.PushTagPath( SongPath )
	else:
		if GetClickedSongPath() in SongLists.HighlightedSongs:
			Global.TagPaths = SongLists.HighlightedSongs
		else:
			Global.PushTagPath( GetClickedSongPath() )
	
	#Since this changes the option the Input Toggler is called manually 
	Global.root.LoadOptions(4,true)
	FreeSongOptions()


func _on_AddToPlaylist_pressed(var main_idx : int = -1):
	if main_idx == -1:
		if GetClickedSongPath() in SongLists.HighlightedSongs:
			var main_idxs : PoolIntArray = []
			for HighlightedSong in SongLists.HighlightedSongs:
				main_idxs.push_back( AllSongs.GetMainIdx(HighlightedSong) )
			LoadPlaylistSelector(main_idxs)
		else:
			#Adding the Current Song need no Argument Passed
			var idx : int = AllSongs.GetMainIdx( GetClickedSongPath() )
			LoadPlaylistSelector([idx])
	else:
		#Adding a Specific Song need the Main Index
		LoadPlaylistSelector([main_idx])
	FreeSongOptions()


func _on_Close_pressed():
	FreeSongOptions()


func _on_ShowInFilesystem_pressed(var main_idx : int = -1):
	var dir : String
	var titles : PoolStringArray = []
	var paths : PoolStringArray  = []
	if main_idx == -1:
		#loads from a randomly picked song in list
		if GetClickedSongPath() in SongLists.HighlightedSongs:
			#if the "SongOptioned" Song is one of many highlighted songs
			#ALL of the highlighted songs will be added
			for path in SongLists.HighlightedSongs:
				paths.push_back( path)
				titles.push_back( AllSongs.GetSongTitle( AllSongs.GetMainIdx(path)) )
		else:
			#the needed song is NOT one of the highlighted
			paths.push_back( GetClickedSongPath() )
			titles.push_back( AllSongs.GetSongTitle( AllSongs.GetMainIdx(paths[0])) )
	else:
		#loads from the currently playing song
		titles.push_back( AllSongs.GetSongTitle(main_idx) )
		paths.push_back( AllSongs.GetSongPath(main_idx) )
	#removes title from path and uses this as directory
	for i in paths.size():
		dir = paths[i].replace(titles[i],"")
		
		#Automatically detects duplicates and doesn't open them
		FileChecker.OpenDirectory(dir)
	FreeSongOptions()


func _on_ShowCoverInFilesystem_pressed():
	FreeSongOptions()
	FileChecker.OpenDirectory(Global.GetCurrentUserDataFolder() + "/Songs/AllSongs/Covers/")


func _on_QueueSong_pressed(var main_idx : int = -1):
	if main_idx == -1:
		if GetClickedSongPath() in SongLists.HighlightedSongs:
			for Song in SongLists.HighlightedSongs:
				SongLists.QueueSong( Song )
		else:
			SongLists.QueueSong( GetClickedSongPath() )
	else:
		SongLists.QueueSong()
	FreeSongOptions()


func FreeSongOptions() -> void:
	yield(
		create_tween().set_trans(Tween.TRANS_LINEAR).tween_property(self,"modulate:a",0.0,0.3),
		"finished"
	)
	self.queue_free()


func _on_Clear_Queue_pressed():
	SongLists.ClearQueue()
	FreeSongOptions()


func LoadPlaylistSelector(var main_idxs : PoolIntArray) -> void:
	var PlaylistSelector = load("res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/PlaylistSelector.tscn").instance()
	Global.root.middle_part.add_child(PlaylistSelector)
	for n in SongLists.Playlists.size():
		var PlaylistButton = load("res://src/Scenes/SubOptions/Playlists/StdPlaylistButton.tscn").instance()
		PlaylistSelector.Playlists.add_child(PlaylistButton)
		if PlaylistButton.connect("pressed",Global,"AddToPlaylist",[PlaylistSelector,n,main_idxs]):
			Global.root.Message("ADDING SONG TO PLAYLIST", SaveData.MESSAGE_ERROR)
		PlaylistButton.get_child(0).text = SongLists.Playlists.keys()[n]


func ExtractSongCover(var MainIdx : int = -1) -> void: 
	var SongPaths : PoolStringArray = []
	if MainIdx != -1:
		SongPaths.push_back( AllSongs.GetSongPath(MainIdx) )
	else:
		if GetClickedSongPath() in SongLists.HighlightedSongs:
			SongPaths = SongLists.HighlightedSongs
		else:
			SongPaths.push_back( GetClickedSongPath() )
	
	var _dialog = Global.root.OpenGeneralFileDialogue(
		Exporter.new(),
		FileDialog.MODE_SAVE_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"ToImage",
		[SongPaths],
		"ExportCover",
		["*png","*jpg","*webp"],
		true
	)


func RemoveFromPlaylist(var main_idx : int = -1) -> void:
	var keys : PoolStringArray
	if main_idx != -1:
		keys.push_back( AllSongs.GetSongPath(main_idx) )
	else:
		if GetClickedSongPath() in SongLists.HighlightedSongs:
			keys = SongLists.HighlightedSongs
		else:
			keys.push_back( SongLists.Playlists.values()[Global.PlaylistPressed].keys()[SongIdx] )
	
	for i in keys.size():
		SongLists.Playlists.values()[Global.PlaylistPressed].erase(keys[i])
	
	Global.root.ReloadCurrentOption()
	FreeSongOptions()

