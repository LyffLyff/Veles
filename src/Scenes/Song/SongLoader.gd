class_name SongLoader extends Reference

var SongsSpaceScene : PackedScene = preload("res://src/scenes/song/SongSpace.tscn")


signal SongsReloaded


func Reload() -> void:
	
	#Variables
	var Title : String = ""
	var song_path : String = ""
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
	for FolderIdx in SongLists.folders.size():
		
		var dir = Directory.new()
		if dir.open(SongLists.folders[FolderIdx]) == OK:
			if dir.list_dir_begin(true,true) == OK:
					while true:
						
						Title  = dir.get_next()
						if Title == "":
							#End of folder
							break;
						
						if FormatChecker.get_music_filename_extension(Title) != -1:
							song_path = dir.get_current_dir()+ "/" + Title
							if SongLists.AllSongs.has(song_path):
								AllSongs.set_main_idx(song_path,MainIndex)
								NewAllSongs[song_path] = SongLists.AllSongs.get(song_path)
								
							else:
								#Adding all Artists to List
								var Artist : String = Tags.get_artist(song_path)
								var DividedArtists : PoolStringArray = Streams.divide_artists(Artist)
								for n in DividedArtists.size():
									
									if DividedArtists[n] == "":
										continue;
									if SongLists.artists.has( [ DividedArtists[n] ] ):
										continue;
										
									SongLists.artists.push_back( 
										[ DividedArtists[n] ] 
									);
								
								NewAllSongs[song_path] = [
									Title,
									Artist,
									MainIndex,
									0,
									str(song_path.hash()),
									Tags.get_title(song_path),
									Tags.get_song_duration(song_path),
									false
								]
								#the new Song in the folder that has just been added will be at the end of the Dictionary
								#should be loaded with the other songs from its folder
								#SongLists.PushAllSongIdx(SongLists.AllSongs.size() - 1)
								NewSongs.push_back(song_path)
							MainIndex += 1
	SongLists.AllSongs = NewAllSongs
	var x : CoverLoader = CoverLoader.new()
	x.NewSongCovers(NewSongs)
	emit_signal("SongsReloaded")


func CreateSongsSpaces(var SongVBOX : VBoxContainer,var ToSet : PoolIntArray = [], var playlist_idx : int = -1) -> void:
	var NewSong : HBoxContainer
	var Loop = SongLists.AllSongs.size()
	if !ToSet.empty():
		Loop = ToSet
	
	
	for n in Loop:
		NewSong = SongsSpaceScene.instance()
		SongVBOX.add_child(NewSong)
		#Set Song Space Properties
		NewSong.main_index = n
		NewSong.playlist_idx = playlist_idx
		NewSong.path = AllSongs.get_song_path(n)
		
		#Filling in Songspace Data
		SetSongspaceCover(NewSong,n,playlist_idx)
		SetSongspaceTitle(NewSong,n)
		SetSongspaceArtist(NewSong,n)
		SetSongspaceLength(NewSong,n)


func SetSongspaceCover(var SongSpace : HBoxContainer,var main_idx : int, var playlist_idx : int = -1) -> void:
	var CoverImg : Texture = null
	var CoverSpace : TextureRect = SongSpace.get_node("Panel/HBoxContainer/Cover")
	
	if SettingsData.get_setting(SettingsData.SONG_SETTINGS, "ShowSongspaceCover"):
		var CoverHash : String = AllSongs.get_song_coverhash(main_idx)
		if SongLists.cached_covers.has(CoverHash):
			CoverImg = SongLists.cached_covers.get(CoverHash)
		else:
			CoverImg = ImageLoader.get_cover("", Playlist.get_playlist_name(playlist_idx) )
	CoverSpace.set_deferred("texture",CoverImg)


func SetSongspaceTitle(var SongSpace : HBoxContainer,var main_idx : int) -> void:
	SongSpace.get_node("Panel/HBoxContainer/Name").set_deferred("text",AllSongs.song_title(main_idx))


func SetSongspaceArtist(var SongSpace : HBoxContainer,var main_idx : int) -> void:
	SongSpace.get_node("Panel/HBoxContainer/Artist").set_deferred("text",AllSongs.get_song_artist(main_idx))


func SetSongspaceLength(var SongSpace : HBoxContainer,var main_idx : int) -> void:
	SongSpace.get_node("Panel/HBoxContainer/Length").set_deferred("text",TimeFormatter.format_seconds(AllSongs.get_song_duration(main_idx)))
