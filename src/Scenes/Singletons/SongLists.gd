extends Node


#CONSTANTS
const StdUserdataPaths : Array = [
	"user://GlobalSettings/StdUserdata/Folders.dat",
	"user://GlobalSettings/StdUserdata/LastSong.dat",
	"user://GlobalSettings/StdUserdata/LastPlaylist.dat",
	"user://GlobalSettings/StdUserdata/NormalPlaylists.dat",
	"user://GlobalSettings/StdUserdata/SongStreams.dat",
	"user://GlobalSettings/StdUserdata/PlaylistStreams.dat",
	"user://GlobalSettings/StdUserdata/ArtistStreams.dat",
	"user://GlobalSettings/StdUserdata/Settings.dat",
	"user://GlobalSettings/StdUserdata/SonqQueue.dat",
	"user://GlobalSettings/StdUserdata/PlaylistMetadata.dat",
	"user://GlobalSettings/StdUserdata/AllSongs.dat",
	"user://GlobalSettings/StdUserdata/CoverCache.dat",
	"user://GlobalSettings/StdUserdata/Artists.dat",
	"user://GlobalSettings/StdUserdata/SmartPlaylists.dat",
	"user://GlobalSettings/StdUserdata/TempSmartPlaylist.dat",
	"user://GlobalSettings/StdUserdata/AudioEffects.dat",
	"user://GlobalSettings/StdUserdata/DownloadQueue.dat",
	"user://GlobalSettings/AppStats/UsageTime.dat"
]


const FilePaths : Array = [
	"user://Users/USERNAME/Settings/CoreSettings/Folders.dat",
	"user://Users/USERNAME/Settings/CoreSettings/LastSong.dat",
	"user://Users/USERNAME/Settings/CoreSettings/LastPlaylist.dat",
	"user://Users/USERNAME/Songs/Playlists/NormalPlaylists/NormalPlaylists.dat",
	"user://Users/USERNAME/Songs/Streams/SongStreams.dat",
	"user://Users/USERNAME/Songs/Streams/PlaylistStreams.dat",
	"user://Users/USERNAME/Songs/Streams/ArtistStreams.dat",
	"user://Users/USERNAME/Settings/CoreSettings/Settings.dat",
	"user://Users/USERNAME/Settings/CoreSettings/SonqQueue.dat",
	"user://Users/USERNAME/Songs/Playlists/Metadata/PlaylistMetadata.dat",
	"user://Users/USERNAME/Songs/AllSongs/AllSongs.dat",
	"user://Users/USERNAME/Songs/AllSongs/CoverCache.dat",
	"user://Users/USERNAME/Songs/Artists/Names/Artists.dat",
	"user://Users/USERNAME/Songs/Playlists/SmartPlaylists/SmartPlaylists.dat",
	"user://Users/USERNAME/Settings/CoreSettings/TempSmartPlaylist.dat",
	"user://Users/USERNAME/Settings/AudioEffects/AudioEffects.dat",
	"user://Users/USERNAME/Settings/CoreSettings/DownloadQueue.dat",
	"user://Users/USERNAME/Settings/CoreSettings/StdAudioPresets.dat",
]

const GlobalFilePaths : Array = [
	"user://GlobalSettings/UserProfileIdx.dat",
	"user://GlobalSettings/UserNames.dat",
	"user://GlobalSettings/PriorUser.dat",
	"user://GlobalSettings/AppStats/UsageTime.dat"
]

#VARIABLES

#Saves the Paths to all the added Folders
var Folders : Array =  []

#Saves the path of the currently playing Song
#further info has to be fetched from AllSongs
var CurrentSong : String = ""

#Saving the Paths of the currently loaded Smart Playlist,
#so the next/prior song can be calculated correctly
var CurrentTempSmartPlaylist : Dictionary = {}
var PressedTempSmartPlaylist : Dictionary = {}
var TempPlaylistConditions : Dictionary = {}
var CurrentPlayList : int = -1

#Path : Playlist Index
var SongQueue : Dictionary = {} 

var SongFromQueue : bool = false

#Saves the last Song that wasn't played from the Queue the start playing from there
var LastRegularSong : String = ""

#Cover Hash [String] : ImageData [PoolByteArray],
#Using this Cache reduced the Texture and Video Memory usage by a factor of 4 -> ~400MB to ~100MB
var CoverCache : Dictionary = {}

#PATH : [TITLE, ARTIST,ALLSONGS_IDX,Streams,COVER_HASH,TAG,DURATION IN SECONDS, LIKED(TRUE/FALSE]
var AllSongs : Dictionary = {}

#PlaylistName : {SongPath : MainIdx}
var Playlists : Dictionary = {}

#Titles of each Smart Playlist
var SmartPlaylists : Array = []

#SongTitle : Streams
var Streams : Dictionary = {}

#PlalistName : Streams
var PlaylistStreams : Dictionary = {}

#ArtistName : Streams
var ArtistStreams : Dictionary = {}

var Artists : Array = []

var MainEnabled : bool = false

var HighlightedSongs : PoolStringArray = []


var AudioEffects : Array = [
	#Effect in this Array == Effect Idx in AudioBus
	#Index 0 in each dictionary saves if the effect is enabled
	{
		"enabled" : false,
		"room_size" : 0.0,
		"damping" : 0.0,
		"spread" : 0.6,
		"hipass" : 0.0,
		"dry" : 0.0,
		"wet" : 1.0,
		"predelay_msec" : 0.0,
		"predelay_feedback" : 0.0,
	},
	{
		"enabled" : false,
		"pan_pullout" : 0.0,
		"time_pullout_ms" : 0.0,
		"surround" : 0.0,
	},
	{
		"enabled" : false,
		"pitch_scale" : 1.0,
	},
	{
		"enabled" : false,
		"cutoff_hz" : 2000.0,
		"resonance" : 0.5,
		"db" : 0.0,
	},
	{
		"enabled" : false,
		"pan" : 0.0
	},
	{
		"enabled" : false,
		"band_db/32_hz" : 0.0,
		"band_db/100_hz" : 0.0,
		"band_db/320_hz" : 0.0,
		"band_db/1000_hz" : 0.0,
		"band_db/3200_hz" : 0.0,
		"band_db/10000_hz" : 0.0
	},
	{
		"enabled" : false,
		"band_db/22_hz" : 0.0,
		"band_db/32_hz" : 0.0,
		"band_db/44_hz" : 0.0,
		"band_db/63_hz" : 0.0,
		"band_db/90_hz" : 0.0,
		"band_db/125_hz" : 0.0,
		"band_db/175_hz" : 0.0,
		"band_db/250_hz" : 0.0,
		"band_db/350_hz" : 0.0,
		"band_db/500_hz" : 0.0,
		"band_db/700_hz" : 0.0,
		"band_db/1000_hz" : 0.0,
		"band_db/1400_hz" : 0.0,
		"band_db/2000_hz" : 0.0,
		"band_db/2800_hz" : 0.0,
		"band_db/4000_hz" : 0.0,
		"band_db/5600_hz" : 0.0,
		"band_db/8000_hz" : 0.0,
		"band_db/11000_hz" : 0.0,
		"band_db/16000_hz"  : 0.0,
		"band_db/22000_hz" : 0.0
	},
	{
		"main_enabled" : false
	}
]


func _enter_tree():
	#Pros: apparently should have a better performance on GLES2
	#Cons: Window Flashing when resizing window -> ugly
	get_tree().get_root().render_direct_to_screen = true
	
	#Disabling 3d since it's never used
	get_tree().get_root().set_disable_3d(true)
	get_tree().get_root().usage = Viewport.USAGE_2D
	get_viewport().render_target_clear_mode = Viewport.CLEAR_MODE_ALWAYS
	
	get_tree().get_root().set_transparent_background( SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"TransparentBackground") )
	VelesInit.new().CreateFolders()
	
	var temp = null
	#Saving Std Userdata Values to GlobalSettings
	SaveUserSpecificData(StdUserdataPaths)
	
	#Global Data
	for i in GlobalFilePaths.size():
		temp = SaveData.Load(GlobalFilePaths[i])
		if temp != null:
			match i:
				0:
					Global.CurrentProfileIdx = temp
				1:
					Global.UserProfiles = temp
				2:
					Global.PriorUser = temp
	#User Specific Data
	LoadUserSpecificData(FilePaths)
	var x : VelesInit = VelesInit.new()
	x.CreateFolders()
	x.InitAudioEffects()
	x.InitRandomSettings()
	x.InitStdCovers()


func _exit_tree():
	#Retrive Settgins to be Saved
	SettingsData.Settings[SettingsData.GENERAL_SETTINGS].SongFromQueue = SongFromQueue
	SettingsData.Settings[SettingsData.GENERAL_SETTINGS].WindowPosition = OS.get_window_position()
	SettingsData.Settings[SettingsData.GENERAL_SETTINGS].WindowSize = OS.get_window_size()
	
	#Global Data
	SaveData.Save( GlobalFilePaths[0], Global.CurrentProfileIdx)
	SaveData.Save( GlobalFilePaths[1], Global.UserProfiles)
	SaveData.Save( GlobalFilePaths[2], Global.PriorUser)
	
	#User Specific Data
	SaveUserSpecificData( AddUsersToFilepaths(FilePaths) )


func LoadUserSpecificData(var Paths : PoolStringArray) -> void:
	var temp
	for i in Paths.size():
		temp = SaveData.Load( AddUserToFilepath( Paths[i] ) )
		if temp != null:
			match i:
				0:
					Folders = temp
				1:
					CurrentSong = temp
				2:
					CurrentPlayList = temp
				3:
					Playlists = temp
				4:
					Streams = temp
				5:
					PlaylistStreams = temp
				6:
					ArtistStreams = temp
				7:
					SettingsData.Settings = temp
				8:
					SongQueue = temp
				9:
					#Playlist Metadata
					pass
				10:
					#AllSong Paths
					AllSongs = temp
				11:
					CoverCache = temp
					InitialisingCoverCache()
				12:
					Artists = temp
				13:
					SmartPlaylists = temp
				14:
					CurrentTempSmartPlaylist = temp
				15:
					AudioEffects = temp
				16:
					Global.CurrentDownloads = temp
	SongFromQueue = SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"SongFromQueue")


func AddUsersToFilepaths(var UPaths : PoolStringArray) -> PoolStringArray:
	var FPaths : PoolStringArray = []
	for i in UPaths.size():
		FPaths.push_back( AddUserToFilepath(UPaths[i]) )
	return FPaths;


func SaveUserSpecificData(var Paths : PoolStringArray) -> void:
	SaveData.Save( Paths[0] , Folders)
	SaveData.Save( Paths[1] , CurrentSong)
	SaveData.Save( Paths[2] , CurrentPlayList)
	SaveData.Save( Paths[3] , Playlists)
	SaveData.Save( Paths[4] , Streams)
	SaveData.Save( Paths[5] , PlaylistStreams)
	SaveData.Save( Paths[6] , ArtistStreams)
	
	SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS, "PlaybackPosition", MainStream.get_playback_position())
	SaveData.Save( Paths[7] , SettingsData.Settings)
	SaveData.Save( Paths[8] , SongQueue)
	SaveData.Save( Paths[10] , AllSongs)
	SaveData.Save( Paths[11] , CoverCache)
	SaveData.Save( Paths[12] , Artists)
	SaveData.Save( Paths[13] , SmartPlaylists )
	SaveData.Save( Paths[14] , CurrentTempSmartPlaylist )
	SaveData.Save( Paths[15] , AudioEffects )
	SaveData.Save( Paths[16], Global.CurrentDownloads)


func ResetUserdata() -> void:
	LoadUserSpecificData(StdUserdataPaths)


func AddUserToFilepath(var Filepath : String) -> String:
	return Filepath.format([Global.GetCurrentUser()],"USERNAME")


func SetCurrentSong(var path : String) -> void:
	CurrentSong = path


func SetCurrentPlaylist(var idx : int) -> void:
	#-2 Smart Playlist
	#-1 = AllSongs
	#0 -> INF = Index in Playlists
	CurrentPlayList = idx


func QueueSong(var path : String = "") -> void:
	if SongQueue.size() == 0:
		LastRegularSong = CurrentSong
	if path == "":
		SongQueue[CurrentSong] = CurrentPlayList
	else:
		SongQueue[path] = Global.PlaylistPressed


func ClearQueue() -> void:
	SongQueue.clear()


func QueueSongPassed() -> void:
	if SongQueue.erase(SongQueue.keys()[0]):
		if SongQueue.empty():
			SongFromQueue = false


func SetCoverHash(var CoverHash : String, var main_idx : int) -> void:
	AllSongs.values()[main_idx][4] = CoverHash


func NewPlaylist(var PlaylistName : String) -> void:
	#Creates New Key with an Empty Dictionary as Value
	var value : Dictionary = {}
	Playlists[PlaylistName] = value
	if !SaveData.PushDictKeyAndSave(SongLists.AddUserToFilepath(SongLists.FilePaths[9]),PlaylistName,0,true,OS.get_datetime()):
		Global.root.message("ERROR://CANNOT EDIT REQUESTED KEY", SaveData.MESSAGE_ERROR)


func NewSmartPlaylist(var SmartPlaylistTitle : String, var Conditions : Dictionary) -> void:
	SmartPlaylists.push_back(SmartPlaylistTitle)
	var ConditionsPath : String = Global.GetCurrentUserDataFolder() + "/Songs/Playlists/SmartPlaylists/Conditions/" + SmartPlaylistTitle + ".dat"
	SaveData.Save(ConditionsPath, Conditions)
	if !SaveData.PushDictKeyAndSave(SongLists.AddUserToFilepath(SongLists.FilePaths[9]),SmartPlaylistTitle,0,true,OS.get_datetime()):
		Global.root.message("ERROR://CANNOT EDIT REQUESTED KEY", SaveData.MESSAGE_ERROR)


func AppendArtists(var Idx : int, var NewArtists : PoolStringArray) -> void:
	var x : PoolStringArray = Artists[Idx]
	x.append_array(NewArtists)
	Artists[Idx] = x


func InitialisingCoverCache() -> void:
	#Loads already filtered and sorted Covers into a Cache
	#Saving Loading time and Memory
# warning-ignore:unused_variable
	var counter = 0
	for x in CoverCache.keys():
		counter += 1
		CoverCache[x] = ImageLoader.GetCover(Global.GetCurrentUserDataFolder() + "/Songs/AllSongs/Covers/" + x + ".png","",Vector2(70,70))


func AddFolder(var dir : String):
	Folders.push_back(dir)
	var x : SongLoader = SongLoader.new()
	x.Reload()


func RemoveFolder(var dir : String):
	for n in Folders.size():
		if Folders[n] == dir:
			Folders.remove(n)
			break;


func FreeAllSongs() -> void:
	self.AllSongs.clear()


func ReplaceDictKey( var SrcDict : Dictionary, var OldKey : String, var NewKey : String) -> Dictionary:
	#Replaces a Dictionaries key while retaining order of the Keys and Values
	var NewDictionary : Dictionary = {}
	for i in SrcDict.size():
		if SrcDict.keys()[i] == OldKey:
			NewDictionary[ NewKey ] = SrcDict.values()[i]
		else:
			NewDictionary[ SrcDict.keys()[i] ] = SrcDict.values()[i]
	return NewDictionary


#Higlighted Songs [CTRL]
func AddHighlightedSongs(var SongsVBox : Node, var idx : int) -> void:
	var path : String = SongsVBox.get_child(idx).path
	if !HighlightedSongs.has(path):
		HighlightedSongs.push_back(SongsVBox.get_child(idx).path)
	SongsVBox.get_child(idx).modulate = Color("888888")
