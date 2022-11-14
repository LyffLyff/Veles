extends Reference

class_name SongLoader

var SongsSpaceScene : PackedScene = preload("res://src/scenes/song/SongSpace.tscn")


signal SongsReloaded


func Reload() -> void:
	
	#Variables
	var Title : String = ""
	var SongPath : String = ""
	var MainIndex : int = 0
	var NewSongs : PoolStringArray = []
	var NewAllSongs : Dictionary = {}
	
	#Checking and Deleting Invalif Paths
	for n in SongLists.AllSongs.keys():
		var d : Directory = Directory.new()
		if !d.file_exists(n):
			if !SongLists.AllSongs.erase(n):
				Global.root.message("COULD NOT ERASE INDEX " + str(n) + "FROM ALLSONGS DICTIONARY", SaveData.MESSAGE_ERROR)
	
	#Loading New Songs from Folder if any
	for FolderIdx in SongLists.Folders.size():
		
		var dir = Directory.new()
		if dir.open(SongLists.Folders[FolderIdx]) == OK:
			if dir.list_dir_begin(true,true) == OK:
					while true:
						
						Title  = dir.get_next()
						if Title == "":
							#End of folder
							break;
						
						if FormatChecker.FileNameFormat(Title) != -1:
							SongPath = dir.get_current_dir()+ "/" + Title
							if SongLists.AllSongs.has(SongPath):
								AllSongs.UpdateMainIndex(SongPath,MainIndex)
								NewAllSongs[SongPath] = SongLists.AllSongs.get(SongPath)
								
							else:
								#Adding all Artists to List
								var Artist : String = Tags.GetArtist(SongPath)
								var DividedArtists : PoolStringArray = Streams.DivideMultipleArtists(Artist)
								for n in DividedArtists.size():
									
									if DividedArtists[n] == "":
										continue;
									if SongLists.Artists.has( [ DividedArtists[n] ] ):
										continue;
										
									SongLists.Artists.push_back( 
										[ DividedArtists[n] ] 
									);
								
								NewAllSongs[SongPath] = [
									Title,
									Artist,
									MainIndex,
									0,
									str(SongPath.hash()),
									Tags.GetTitle(SongPath),
									Tags.GetSongDuration(SongPath),
									false
								]
								#the new Song in the folder that has just been added will be at the end of the Dictionary
								#should be loaded with the other songs from its folder
								#SongLists.PushAllSongIdx(SongLists.AllSongs.size() - 1)
								NewSongs.push_back(SongPath)
							MainIndex += 1
	SongLists.AllSongs = NewAllSongs
	var x : CoverLoader = CoverLoader.new()
	x.NewSongCovers(NewSongs)
	emit_signal("SongsReloaded")


func CreateSongsSpaces(var SongVBOX : VBoxContainer,var ToSet : PoolIntArray = [], var PlaylistIdx : int = -1) -> void:
	var NewSong : HBoxContainer
	var Loop = SongLists.AllSongs.size()
	if !ToSet.empty():
		Loop = ToSet
	
	
	for n in Loop:
		NewSong = SongsSpaceScene.instance()
		SongVBOX.add_child(NewSong)
		#Set Song Space Properties
		NewSong.main_index = n
		NewSong.PlaylistIdx = PlaylistIdx
		NewSong.path = AllSongs.GetSongPath(n)
		
		#Filling in Songspace Data
		SetSongspaceCover(NewSong,n,PlaylistIdx)
		SetSongspaceTitle(NewSong,n)
		SetSongspaceArtist(NewSong,n)
		SetSongspaceLength(NewSong,n)


func SetSongspaceCover(var SongSpace : HBoxContainer,var MainIdx : int, var PlaylistIdx : int = -1) -> void:
	var CoverImg : Texture = null
	var CoverSpace : TextureRect = SongSpace.get_node(Global.SongCoverPath)
	
	if SettingsData.GetSetting(SettingsData.SONG_SETTINGS, "ShowSongspaceCover"):
		var CoverHash : String = AllSongs.GetSongCoverHash(MainIdx)
		if SongLists.CoverCache.has(CoverHash):
			CoverImg = SongLists.CoverCache.get(CoverHash)
		else:
			CoverImg = ImageLoader.GetCover("", Playlist.GetPlaylistName(PlaylistIdx) )
	CoverSpace.set_deferred("texture",CoverImg)


func SetSongspaceTitle(var SongSpace : HBoxContainer,var MainIdx : int) -> void:
	SongSpace.get_node(Global.SongNamePath).set_deferred("text",AllSongs.SongTitle(MainIdx))


func SetSongspaceArtist(var SongSpace : HBoxContainer,var MainIdx : int) -> void:
	SongSpace.get_node(Global.SongArtistPath).set_deferred("text",AllSongs.GetSongArtist(MainIdx))


func SetSongspaceLength(var SongSpace : HBoxContainer,var MainIdx : int) -> void:
	SongSpace.get_node(Global.SongLengthPath).set_deferred("text",TimeFormatter.FormatSeconds(AllSongs.GetSongDuration(MainIdx)))
