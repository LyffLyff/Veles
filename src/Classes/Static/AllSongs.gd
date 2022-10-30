extends Reference

class_name AllSongs


static func GetSongPath(var main_idx : int) -> String:
	return SongLists.AllSongs.keys()[main_idx]


static func GetSongArtist(var main_idx : int) -> String:
	return SongLists.AllSongs.values()[main_idx][1]


static func GetSongTitle(var main_idx : int) -> String:
	return SongLists.AllSongs.values()[main_idx][0]


static func GetSongTitleTag(var main_idx : int) -> String:
	return SongLists.AllSongs.values()[main_idx][5]


static func GetSongStreams(var main_idx : int) -> int:
	return SongLists.AllSongs.values()[main_idx][3]


static func GetSongDuration(var main_idx : int) -> int:
	return SongLists.AllSongs.values()[main_idx][6]

static func GetSongCoverHash(var main_idx : int) -> String:
	return SongLists.AllSongs.values()[main_idx][4]


static func SetCoverHash(var Hash : String, var main_idx : int) -> void:
	SongLists.AllSongs.values()[main_idx][4] = Hash


static func SetSongArtist(var NewArtist : String, var main_idx : int) -> void:
	SongLists.AllSongs.values()[main_idx][1] = NewArtist


static func SetSongTitleTag(var NewTitle : String, var main_idx : int) -> void:
	SongLists.AllSongs.values()[main_idx][5] = NewTitle


static func SetSongLiked(var main_idx : int, var Liked : bool) -> void:
	SongLists.AllSongs.values()[main_idx][7] = Liked


static func GetSongLiked(var main_idx : int) -> bool:
	return SongLists.AllSongs.values()[main_idx][7]


static func GetMainIdx(var path : String) -> int:
	if SongLists.AllSongs.has(path):
		return SongLists.AllSongs.keys().find(path)
	else:
		return -1


static func GetSongCoverPath(var MainIdx : int) -> String:
	return Global.GetCurrentUserDataFolder() + "/Songs/AllSongs/Covers/" + GetSongCoverHash(MainIdx) + ".png"


static func GetSongAmount() -> int:
	return SongLists.AllSongs.values().size()


static func SongTitle(var main_idx : int) -> String:
	match SettingsData.GetSetting(SettingsData.SONG_SETTINGS,"DisplayNameMode"):
		0:
			return GetSongTitle(main_idx)
		1:
			return GetSongTitle(main_idx).get_basename()
		2:
			return GetSongTitleTag(main_idx)
		_:
			return "ERROR://UNINTENDED BEHAVIOUR"


static func UpdateMainIndex(var path : String,var NewMainIdx : int) -> void:
	SongLists.AllSongs[path][2] = NewMainIdx


static func UpdateCoverHash(var path : String,var NewCoverHash : String) -> void:
	SongLists.AllSongs[path][4] = NewCoverHash



