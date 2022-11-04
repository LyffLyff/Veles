extends Node

#SIGNALS
signal DownloadsFinished

#CONSTANTS
const SongNamePath : String = "Panel/HBoxContainer/Name"
const SongArtistPath : String = "Panel/HBoxContainer/Artist"
const SongLengthPath : String = "Panel/HBoxContainer/Length"
const SongCoverPath : String = "Panel/HBoxContainer/Cover"
const SupportedImgFormats : Array = ["*.jpg","*.png","*.webp","*.jpeg"]

#NODES
onready var DownloaderRef : YtDlp = YtDlp.new()
onready var root : Control = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)

#VARIABLES
var UserProfiles : PoolStringArray = []
var CurrentProfileIdx : int = -1
var PriorUser : String = ""
var TagPaths : PoolStringArray = []
#will be set to true when the mouse stopper gets enabled 
#by the download of option loader to prevent the
#mouse stoppper from being disabled when reentering focus
var std_cover = null
var std_music_cover = null
#tells if the program has just been started
var InitializeSongs : bool = true
var WindowMaximized : bool = false
var PlaylistPressed : int = -1
var DisplayedMessage : String = ""
var CurrentDownloads : Array = []
var LowFPS : bool
var AppOpenedTime : int = OS.get_unix_time()
var first_skipped_path : String = ""


#PRELOADS
const pause_img : StreamTexture = preload("res://src/Assets/Icons/White/Audio/Replay/pause_72px.png")
const play_img : StreamTexture =  preload("res://src/Assets/Icons/White/Audio/Replay/play_72px.png")


func _exit_tree():
	#Calculating the App usage time on Minutes
	var PriorUsageTimeMin = SaveData.Load(SongLists.GlobalFilePaths[3])
	var NewUsagetime : float = 0.0
	if PriorUsageTimeMin == null:
		PriorUsageTimeMin = 0.0
	NewUsagetime = PriorUsageTimeMin + ( (OS.get_unix_time() - AppOpenedTime) / 60.0 )
	SaveData.Save(SongLists.GlobalFilePaths[3], NewUsagetime ) 


func _ready():
	var _err = DownloaderRef.connect("ready",self,"DownloadFromQueue",[false],CONNECT_ONESHOT)


func WindowChanged(var x : bool) -> void:
	WindowMaximized = x;


func InputToggler(var ToDisable : Node,var x : bool = false) -> void:
	if ToDisable:
		ToDisable.set_process_input(x)
		ToDisable.set_process_unhandled_input(x)


func RequestFPSChange(var fps : int) -> void:
	#allows for the fps of the application to be boosted while being out of focus -> e.g. animations
	if LowFPS:
		Engine.set_target_fps(fps)


func PushTagPath(var NewTagPath : String) -> void:
	TagPaths.push_back(NewTagPath)


#User Profiles
func NewUserProfile(var NewUsername : String) -> void:
	UserProfiles.push_back(NewUsername)
	VelesInit.new().CreateFolders()


func is_username_valid( var new_username : String ) -> bool:
	#Checks if a given username is valid
	if !new_username.is_valid_filename() or new_username == "" or UserProfiles.has(new_username) or new_username.length() > 100:
		return false
	return true


func RenameUser(var new_username : String, var UserIdx : int) -> void:
	if !is_username_valid(new_username):
		root.Message("Invalid Username", SaveData.MESSAGE_ERROR, true)
		return
	
	var dir : Directory = Directory.new()
	var old_username : String = UserProfiles[UserIdx]
	
	#Renaming the Userimage
	var user_imgs : String = "user://GlobalSettings/UserImages/"
	if dir.file_exists( user_imgs + old_username + ".png" ):
		var _err = dir.rename(
			user_imgs + old_username + ".png",
			user_imgs + new_username + ".png"
		)
	
	#Renaming the Directory in the Userdata
	var _err = dir.rename(
		"user://Users/" + old_username,
		"user://Users/" + new_username
	)
	
	#Replacing the Old Username with new s
	UserProfiles[UserIdx] = new_username
 

func RemoveUser(var UserIdx : int) -> void:
	UserProfiles.remove(UserIdx)


func ChangeUserCover(var NewImagePath : String, var UserIdx : int) -> void:
	var Dir : Directory = Directory.new()
	var _err = Dir.remove( OS.get_user_data_dir() + "/GlobalSettings/UserImages/" + UserProfiles[UserIdx] + ".png" )
	_err = Dir.copy(NewImagePath, OS.get_user_data_dir() + "/GlobalSettings/UserImages/" + UserProfiles[UserIdx] + ".png" )


func GetCurrentUser() -> String:
	if CurrentProfileIdx == -1:
		return ""
	return UserProfiles[CurrentProfileIdx]


func GetCurrentUserDataFolder() -> String:
	return OS.get_user_data_dir() + "/Users/" + Global.GetCurrentUser()


#Playlist
func AddToPlaylist(var playlist_selector,var PlaylistIdx : int, var main_idxs : PoolIntArray):
	for main_idx in main_idxs:
		var path : String = AllSongs.GetSongPath(main_idx)
		#creates new key with path as the key and other infos as values
		SongLists.Playlists.values()[PlaylistIdx][path] = [main_idx]
		playlist_selector.queue_free()


#Global Download -> Background loading possible
func PushNewDownload(var URL : String, var Title : String, var DstFolder : String, var IsAudio : bool, var VideoFormat : int, var AudioFormat : int, var IsPlaylist : bool) -> void:
	CurrentDownloads.push_back(
		{
			"URL" : URL,
			"TITLE" : Title,
			"DST_FOLDER" : DstFolder,
			"AUDIO" : IsAudio,
			"VIDEO_FORMAT" : VideoFormat,
			"AUDIO_FORMAT" : AudioFormat,
			"PLAYLIST" : IsPlaylist 
		}
	)
	DownloadFromQueue(false)


func DownloadFromQueue(var CompletedDownload : bool = false) -> void:
	#If Downloader Not ready it waits for it
	if !DownloaderRef._is_ready:
		yield(DownloaderRef,"ready")
	
	if !DownloaderRef.is_connected("download_completed",self,"DownloadFromQueue"):
		var _err = DownloaderRef.connect("download_completed",self,"DownloadFromQueue",[true],CONNECT_ONESHOT)
	
	if CompletedDownload:
		#if a download was completed the first in queue gets freed -> the downloaded one
		if CurrentDownloads.size() > 0:
			CurrentDownloads.remove(0)
			Global.InitializeSongs = true
	if CurrentDownloads.size() > 0:
		DownloaderRef.download(
			CurrentDownloads[0]["URL"],
			CurrentDownloads[0]["DST_FOLDER"],
			CurrentDownloads[0]["TITLE"],
			CurrentDownloads[0]["AUDIO"],
			CurrentDownloads[0]["VIDEO_FORMAT"],
			CurrentDownloads[0]["AUDIO_FORMAT"],
			CurrentDownloads[0]["PLAYLIST"]
		)
	else:
		#All downloads finished
		emit_signal("DownloadsFinished")


func StopQueuedDownload(var idx : int) -> void:
	CurrentDownloads.remove(idx)
