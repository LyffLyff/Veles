extends Node
# this script will hold all Settings that can be changed in Veles.

enum {
	GENERAL_SETTINGS,
	SONG_SETTINGS,
	PLAYLIST_SETTINGS,
	DESIGN_SETTINGS,
	STATISTIC_SETTINGS,
}

var general_settings : Dictionary = {
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
	"WindowMode" : 1,
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
	
	"LastEditedVLPProjects" : {},
	
	"OverrideTitleOnPlaylistDownload" : true,
	
	"LastTagFolder" : ["", false],	# [path, recursive (yes/no)]
	
	"LastTagFiles" : []	# paths of loaded files -> if no directory 
}
var song_settings : Dictionary = {
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
	"LyricsVisibleTimestamps" : 1,
	
	# wether webp images will get embedded as pngs instead of webp
	"ConverWebPToPNG" : true
}
var playlist_settings : Dictionary = {
	#0 = Veles Playlist, 1 = ALbum Tag
	"PlaylistSpaceText" : 0,
}
var design_settings : Dictionary = {
	"MainBackgroundColor" : Color("242424"),
	"WindowBarColor" : Color("1a1a1a"),
	"PlayerBackground" : Color("1a1a1a"),
	"ImageViewStandardBackgroundColor" : Color("181818"),
	"MainOptionsBackground" : Color("181818"),
	"SongHighlighter" : Color("80242424"),
	"MainSongOptionsBackground" : Color("121212"),
	"PortableSongOptionsBackground" : Color("121212"),
	"ImageViewOption" : Color("28282828"),
	"SidebarMode" : 2,
	"SidebarBackground" : Color("202020"),
	"AudioEffectsBackground" : Color("1a1a1a"),
	"PlaylistHeader" : Color("1a1a1a")
}
var statistic_settings : Dictionary = {
	
}
var settings : Array = [
	general_settings,
	song_settings,
	playlist_settings,
	design_settings,
	statistic_settings
]


func set_setting(var setting_type_idx : int, var key : String, var new_value) -> void:
	# adding new key -> updates could bring new keys
	settings[setting_type_idx][key] = new_value


func get_setting(var setting_type_idx : int, var key : String):
	if !settings[setting_type_idx].has(key):
		return null
	return settings[setting_type_idx][key]
