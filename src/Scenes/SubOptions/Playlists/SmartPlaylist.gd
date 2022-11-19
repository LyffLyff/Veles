extends "res://src/Scenes/SubOptions/Playlists/PlaylistLoader.gd"


#NODES
onready var scroll : ScrollContainer = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller
onready var header : PanelContainer = $HBoxContainer/VBoxContainer/Header
onready var SongVBox : VBoxContainer = $HBoxContainer/VBoxContainer/HBoxContainer/SongScroller/Songs
onready var SmartPlaylistTitleLabel : Label = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Title
onready var SmartPlaylistCover : TextureRect = $HBoxContainer/VBoxContainer/Header/HBoxContainer/HeaderCover/Cover
onready var Runtime : Label = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Length/Time
onready var CreationDate : Label = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Creation/Date
onready var SongAmount : Label = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Songs/Amount
onready var Description : VBoxContainer = $HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Description

#VARIABLES
var PlaylistTitle : String = ""
var DescriptionPath : String = ""
var TempPlaylistCoverPath : String = ""



func n_ready( var conditions : Dictionary = {}, var title = "",var CustomDescriptionPath : String = "", var TmpPlaylistCvrPth : String = ""):
	var _err = scroll.get_v_scrollbar().connect("value_changed", self, "OnScrollValueChanged")
	SongHighlighter = $SongHighlighter
	PlaylistOptions = $HBoxContainer/VBoxContainer/Header/HBoxContainer/PlaylistOptions
	HeaderCover = $HBoxContainer/VBoxContainer/Header/HBoxContainer/HeaderCover/Cover
	infos = [
		$HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Creation,
		$HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Songs,
		$HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Length,
		$HBoxContainer/VBoxContainer/Header/HBoxContainer/VBoxContainer/Description
	]
	songs = SongVBox 
	TempPlaylistCoverPath = TmpPlaylistCvrPth
	ConnectScrollContainer()
	if conditions.empty():
		playlist_idx = Global.pressed_playlist_idx
		PlaylistTitle = SongLists.smart_playlists[ -playlist_idx - 3 ]
		conditions = LoadPlaylistConditions()
	else:
		PlaylistTitle = title
		playlist_idx = -2
		
	SmartPlaylistTitleLabel.set_text( PlaylistTitle )
	if TempPlaylistCoverPath == "":
		SmartPlaylistCover.set_texture( ImageLoader.get_cover(Global.get_current_user_data_folder() + "/Songs/Playlists/Covers/" + PlaylistTitle + ".png") )
	else:
		SmartPlaylistCover.set_texture( ImageLoader.get_cover(TempPlaylistCoverPath))
	var SongIdxs : PoolIntArray = GetSmartPlaylistSongs(conditions)
	if SongIdxs.size() > 0:
		LoadSongs(SongIdxs)
	if CustomDescriptionPath == "":
		DescriptionPath = Global.get_current_user_data_folder() + "/Songs/Playlists/Metadata/Descriptions/" + PlaylistTitle + ".txt"
	else:
		#Used when Displaying Artists
		DescriptionPath = CustomDescriptionPath
	Description.LoadDescription(DescriptionPath)
	
	#header Info
	var playlist_idx : int = Playlist.get_playlist_index(PlaylistTitle) 
	SongAmount.text = str( SongIdxs.size() )
	Runtime.text = GetPlaylistRuntime()
	if playlist_idx <= -3:
		#No Temporary Playlists
		CreationDate.text = GetPlaylistCreationDate()
	else:
		CreationDate.text = ""
	
	#Setting Current Song
	root.update_highlighted_song(SongLists.current_song)


func LoadPlaylistConditions() -> Dictionary:
	var Temp = SaveData.load_data(Global.get_current_user_data_folder() + "/Songs/Playlists/SmartPlaylists/Conditions/" + PlaylistTitle + ".dat")
	if Temp:
		return Temp
	return Dictionary()


func GetSmartPlaylistSongs(var conditions : Dictionary) -> PoolIntArray:
	var ConditionFunctions : SmartPlaylistConditions = SmartPlaylistConditions.new()
	var ValidSong : bool = true
	var TempSongPath : String = ""
	var SongIdxs : PoolIntArray = []
	var TempSmartPlaylist : Dictionary = {}
	
	#Going through AllSongs
	for x  in SongLists.AllSongs.size():
		ValidSong = true
		TempSongPath = SongLists.AllSongs.keys()[x]
		#Checking Conditions
		for y in conditions.size():
			for z in conditions.values()[y].size():
				if !ConditionFunctions.call( conditions.keys()[y], TempSongPath, conditions.values()[y][z]):
					ValidSong = false
					break;
		
		#Adding Songs to Return Array if the Conditions are met
		if ValidSong:
			TempSmartPlaylist[TempSongPath] = false
			SongIdxs.push_back( x )
	
	#Setting the Currently "created" Playlist in a Global Dictionary
	#the Playlist has only been loaded, but is not the one currently playing
	SongLists.pressed_temporary_playlist = TempSmartPlaylist
	
	#Returning All Songs that fit the Current Description
	return SongIdxs;


func LoadSongs(var SongIdxs : PoolIntArray) -> void:
	var x : SongLoader = SongLoader.new()
	x.create_songspaces(SongVBox, SongIdxs, Global.pressed_playlist_idx )


func OnDeleteSmartPlaylistpressed():
	SongLists.smart_playlists.erase( PlaylistTitle )
	ExtendedDirectory.delete_file(Global.get_current_user_data_folder() + "/Songs/Playlists/Covers/" + PlaylistTitle + ".png")
	ExtendedDirectory.delete_file(Global.get_current_user_data_folder() + "/Songs/Playlists/Metadata/Descriptions/" + PlaylistTitle + ".txt")
	UnloadPlaylist()

   
func OnCoverSelected(var ImgSrc : String):
	#Saving Cover Copy in User Data
	if TempPlaylistCoverPath == "":
		SmartPlaylistCover.texture = Playlist.copy_playlist_cover(
			ImgSrc,
			Playlist.get_playlist_index( PlaylistTitle ),
			true
			)
	else:
		var _err : int = Directory.new().copy(
			ImgSrc,
			TempPlaylistCoverPath
		)
		SmartPlaylistCover.texture = ImageLoader.get_cover(TempPlaylistCoverPath)



