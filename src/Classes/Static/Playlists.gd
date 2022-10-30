extends Reference


class_name Playlist


static func GetPlaylistName(var PlaylistIdx : int = -1) -> String:
	if PlaylistIdx == -1:
		#AllSongs
		return "AllSongs"
	elif PlaylistIdx >= 0:
		#Normal Playlist
		return SongLists.Playlists.keys()[PlaylistIdx]
	elif PlaylistIdx == -2:
		var TempPlaylistTitle = SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS, "TemporaryPlaylistTitle")
		if TempPlaylistTitle != null:
			return TempPlaylistTitle
		else:
			return ""
	elif PlaylistIdx <= -3:
		#Smart Playlist
		if -PlaylistIdx - 3 < SongLists.SmartPlaylists.size():
			return SongLists.SmartPlaylists[-PlaylistIdx - 3]
	return ""


static func GetPlaylistIndex(var Title : String) -> int:
	if SongLists.Playlists.has(Title):
		#Normal Playlist
		return SongLists.Playlists.keys().find(Title, 0)
	elif SongLists.SmartPlaylists.has(Title):
		#Smart Playlist
		return -SongLists.SmartPlaylists.find(Title, 0) - 3
	else:
		return -1


static func GetPlaylistCover(var PlaylistIdx : int) -> Texture:
	if PlaylistIdx == -2 or PlaylistIdx == -1:
		#Ignoring Temporary Playlists and All Songs
		return ImageTexture.new()
	
	var CoverPath : String = Global.GetCurrentUserDataFolder() + "/Songs/Playlists/Covers/" + GetPlaylistName(PlaylistIdx) + ".png"
	return ImageLoader.GetCover(CoverPath)


static func RemoveSong(var path : String, var idx : int) -> void:
	SongLists.Playlists.values()[idx].erase(path)


static func CopyPlaylistCover(var ImgSrc : String,var PlaylistIdx : int,var GetImage : bool = false):
	#Saving Cover Copy in User Data
	var CoverPath : String = Global.GetCurrentUserDataFolder() + "/Songs/Playlists/Covers/" + GetPlaylistName(PlaylistIdx) + ".png"
	var dir : Directory = Directory.new()
	if dir.file_exists(ImgSrc):
		if dir.copy(ImgSrc,CoverPath) != OK:
			Global.root.Message("COPYING PLAYLIST COVER TO USERDATA FROM: " + ImgSrc + " TO: " + CoverPath,SaveData.MESSAGE_ERROR, false, Color() )
	if GetImage:
		return ImageLoader.GetCover(CoverPath)


static func GetRuntimeInSeconds(var PlaylistIdx : int) -> int:
	#Main Index will again be fetched using the Path NOT the Main Index
	var Seconds : int = 0
	if PlaylistIdx >= 0:
		for n in SongLists.Playlists.values()[PlaylistIdx].size():
			Seconds += AllSongs.GetSongDuration(AllSongs.GetMainIdx(SongLists.Playlists.values()[PlaylistIdx].keys()[n]))
	else:
		for i in SongLists.PressedTempSmartPlaylist.size():
			Seconds += AllSongs.GetSongDuration(
				AllSongs.GetMainIdx(
					SongLists.PressedTempSmartPlaylist.keys()[i]
					)
				)
	return Seconds


static func CheckPlaylistTitle(var NewPlaylistTitle : String) -> bool:
	#Checking if equal if other Playlist Titles
	for Title in SongLists.Playlists.keys():
		if Title == NewPlaylistTitle:
			return false;
	
	for Title in SongLists.SmartPlaylists:
		if Title == NewPlaylistTitle:
			return false;

	#Checking if Invalid in other ways
	if NewPlaylistTitle == "":
		return false
	
	return true;


static func RenamePlaylist(var NewPlaylistTitle : String,var PlaylistIdx : int) -> void:
	var OldPlaylistTitle : String = GetPlaylistName(PlaylistIdx)
	if !CheckPlaylistTitle(NewPlaylistTitle):
		return;
		
	var dir : Directory = Directory.new()
	if PlaylistIdx >= 0:
		#Normal
		if dir.rename(
			Global.GetCurrentUserDataFolder() + "/Songs/Playlists/Covers/" + OldPlaylistTitle + ".png",
			Global.GetCurrentUserDataFolder() + "/Songs/Playlists/Covers/" + NewPlaylistTitle + ".png"
		) != OK:
			Global.root.Message("COPYING PLAYLIST COVER TO USERDATA FROM: " + OldPlaylistTitle + " TO: " + NewPlaylistTitle,SaveData.MESSAGE_ERROR, false, Color() )
		SongLists.Playlists = SongLists.ReplaceDictKey(SongLists.Playlists, OldPlaylistTitle, NewPlaylistTitle)
	else:
		#Smart
		if dir.rename(
			Global.GetCurrentUserDataFolder() + "/Songs/Playlists/SmartPlaylists/Conditions/" + OldPlaylistTitle + ".dat",
			Global.GetCurrentUserDataFolder() + "/Songs/Playlists/SmartPlaylists/Conditions/" + NewPlaylistTitle + ".dat"
		) != OK:
			Global.root.Message("RENAMING SmartPlaylistConditions FROM: " + OldPlaylistTitle + " TO " + NewPlaylistTitle,SaveData.MESSAGE_ERROR, false, Color() )
		if dir.rename(
			Global.GetCurrentUserDataFolder() + "/Songs/Playlists/Covers/" + OldPlaylistTitle + ".png",
			Global.GetCurrentUserDataFolder() + "/Songs/Playlists/Covers/" + NewPlaylistTitle + ".png"
		) != OK:
			Global.root.Message("RENAMING SmartPlaylistCovers FROM: " + OldPlaylistTitle + " TO " + NewPlaylistTitle,SaveData.MESSAGE_ERROR, false, Color() )
		SongLists.SmartPlaylists[ (PlaylistIdx * -1) - 3] = NewPlaylistTitle


static func GetPlaylistPaths(var PlaylistIdx : int) -> PoolStringArray:
	if PlaylistIdx == -1:
		return PoolStringArray( SongLists.AllSongs.keys() )
	elif PlaylistIdx >= 0:
		return SongLists.Playlists.values()[PlaylistIdx].keys()
	elif PlaylistIdx <= -2:
		return PoolStringArray( SongLists.PressedTempSmartPlaylist.keys() )
	return PoolStringArray();
