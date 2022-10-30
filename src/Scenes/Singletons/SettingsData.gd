#This Script will hold all Settings that Can be changed in Veles.

extends Node

#ENUMS
enum {GENERAL_SETTINGS,SONG_SETTINGS,PLAYLIST_ALBUM_SETTINGS,DESIGN_SETTINGS,STATISTIC_SETTINGS}


var GeneralSettings : Dictionary = {
	"Volume" : 0,
	"Shuffle" : false,
	"Repeat" : false,
	"TempPlaylistTitle" : "",
	"PlaybackPosition" : 0.0,
	"SongFromQueue" : false,
	"ImageViewActivated" : false,
	"ImageViewCoverFocused" : false,
	"ImageViewLastOption" : 0,
	"LyricsFontSize" : 20,
	#centers window on first startup
	"WindowPosition" : (OS.get_screen_size()/2) - (OS.window_size / 2),
	"WindowSize" : Vector2(ProjectSettings.get("display/window/size/width"),ProjectSettings.get("display/window/size/height")),
	#0 = Off, 1 = On
	"TransparentBackground" : 0,
	#0 = STD
	"BackgroundColor" : 0,
	#0 = Wrap around forward, 1 = Wrap around Backwards, 2 = Wrap around Both Ways, 3 = Keep
	"PriorNextFunctionality" : 0,
	#0 = Veles Custom, 1 =  Operating System Standard
	"WindowMode" : 0,
	#Path Used prior ot get Images
	"ImagePath" : "",
	#Path Used Prior to get Folder/Music
	"SongPath" : "",
	
	"CoverExportPath" : "",
	
	"HTMLExportPath" : "",
	
	"LRCExportPath" : "",
	
	"CSVExportPath" : "",
	
	"FolderExportPath" : "",
	
	#Audio Output Device
	"AudioOutputDevice" : "Default",
	
	#Resolution of Window on Startup
	"StartupResolution" : Vector2(),
	
	"LastEditedVLPProjects" : []
}

var SongSettings : Dictionary = {
	#0 = File Explorer with Extension, 1 w.o extension, 2 = Tag Title
	"DisplayNameMode" : 0,
	"StandardSongCover" : "",
	"ShowSongspaceCover" : true,
	
	#0 = Tiled Cover
	#1 = Std Color
	#2 = Auto Color
	"ImageViewBackground" : 2,
	
	#0 = Left
	#1 = Center
	#2 = Right
	"LyricsTextAlignment" : 0,
	
	#0 = No
	#1 = Yes
	"LyricsVisibleTimestamps" : 1
}

var PlaylistAlbumSettings : Dictionary = {
	#0 = Veles Playlist, 1 = ALbum Tag
	"PlaylistSpaceText" : 0,
}
var DesignSettings : Dictionary = {
	"MainBackgroundColor" : Color("242424"),
	"WindowBarColor" : Color("121212"),
	"ImageViewStandardBackgroundColor" : Color("171717"),
	"PlayerBackground" : Color("181818"),
	"MainOptionsBackground" : Color("191919"),
	"SongHighlighterColor" : Color("51191919"),
	"MainSongOptionsBackground" : Color("202020"),
	"PortableSongOptionsBackground" : Color("202020"),
	"ImageViewOption" : Color("00282828"),
	"SidebarMode" : 0,
	"AudioEffectsBackground" : Color("202020"),
	"AudioEffectsHeaderBackground" : Color("202020"),
	"PlaylistHeader" : Color("202020")
}
var StatisticSettings : Dictionary = {
	
}

var Settings : Array = [GeneralSettings,SongSettings,PlaylistAlbumSettings,DesignSettings,StatisticSettings]


func SetSetting(var SettingTypeIdx : int,var key : String, var value) -> void:
	if Settings[SettingTypeIdx].has(key):
		Settings[SettingTypeIdx][key] = value


func GetSetting(var SettingTypeIdx : int, var key : String):
	if !Settings[SettingTypeIdx].has(key):
		return null
	return Settings[SettingTypeIdx][key]
