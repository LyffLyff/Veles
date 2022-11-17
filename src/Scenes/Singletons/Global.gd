extends Node
# global script holding random globally needed variables and functions

signal downloads_finished

const supported_img_extensions : Array = ["*.jpg","*.png","*.webp","*.jpeg"]
const audio_formats : Array = ["AAC","FLAC","MP3","M4A","OGG-OPUS","OGG-VORBIS","WAV"]
const video_formats : Array = ["MP4","WEBM"]
const pause_img : StreamTexture = preload("res://src/Assets/Icons/White/Audio/Replay/pause_72px.png")
const play_img : StreamTexture =  preload("res://src/Assets/Icons/White/Audio/Replay/play_72px.png")

var user_profiles : PoolStringArray = []
var current_profile_idx : int = -1
var last_loaded_user : String = ""
var temp_tag_paths : PoolStringArray = []
# will be set to true when the mouse stopper gets enabled 
# by the download of option loader to prevent the
# mouse stoppper from being disabled when reentering focus
var std_cover = null
var std_music_cover = null
# tells if the program has just been started
var init_songs : bool = true
var window_maximized : bool = false
var pressed_playlist_idx : int = -1
var displayed_message : String = ""
var current_downloads : Array = []
var is_low_fps : bool
var app_opened_time : int = OS.get_unix_time()
var last_direction : int = 1				# either if the next or prior song was played
var first_skipped_path : String = ""
var general_dialogue_visible : bool = false

onready var downloader_ref : YtDlp = YtDlp.new()
onready var root : Control = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)


func _ready():
	var _err = downloader_ref.connect("ready",self,"download_from_queue",[false],CONNECT_ONESHOT)


func _exit_tree():
	# calculating the App usage time on Minutes
	var PriorUsageTimeMin = SaveData.load_data(SongLists.global_file_paths[3])
	var NewUsagetime : float = 0.0
	if PriorUsageTimeMin == null:
		PriorUsageTimeMin = 0.0
	NewUsagetime = PriorUsageTimeMin + ( (OS.get_unix_time() - app_opened_time) / 60.0 )
	SaveData.save(SongLists.global_file_paths[3], NewUsagetime ) 


func window_changed(var x : bool) -> void:
	window_maximized = x;


func set_node_input(var ref : Node, var input : bool = false) -> void:
	if ref:
		ref.set_process_input(input)
		ref.set_process_unhandled_input(input)


func request_fps_change(var fps : int) -> void:
	# allows for the fps of the application to be boosted while being out of focus -> e.g. animations
	if is_low_fps:
		Engine.set_target_fps(fps)


func push_tag_path(var new_tag_path : String) -> void:
	temp_tag_paths.push_back(new_tag_path)


func new_user_profile(var NewUsername : String) -> void:
	user_profiles.push_back(NewUsername)
	VelesInit.new().create_folders()


func is_username_valid( var new_username : String ) -> bool:
	# checks if a given username is valid
	if !new_username.is_valid_filename():
		return false
	if new_username.to_ascii().get_string_from_ascii() != new_username:
		return false
	if new_username == "":
		return false
	if user_profiles.has(new_username):
		return false
	if new_username.length() > 100:
		return false
	if new_username.length() > 100:
		return false
	return true


func rename_user(var new_username : String, var user_idx : int) -> void:
	if !is_username_valid(new_username):
		root.message("Invalid Username", SaveData.MESSAGE_ERROR, true)
		return
	
	var dir : Directory = Directory.new()
	var old_username : String = user_profiles[user_idx]
	
	# renaming the user profile image
	var user_imgs : String = "user://GlobalSettings/UserImages/"
	if dir.file_exists( user_imgs + old_username + ".png" ):
		var _err = dir.rename(
			user_imgs + old_username + ".png",
			user_imgs + new_username + ".png"
		)
	
	# renaming the Directory in the Userdata
	var _err = dir.rename(
		"user://Users/" + old_username,
		"user://Users/" + new_username
	)
	
	# replacing the Old Username with new s
	user_profiles[user_idx] = new_username
 

func remove_user(var user_idx : int) -> void:
	user_profiles.remove(user_idx)


func change_user_cover(var new_img_path : String, var user_idx : int) -> void:
	var dir : Directory = Directory.new()
	var _err = dir.remove( OS.get_user_data_dir() + "/GlobalSettings/UserImages/" + user_profiles[user_idx] + ".png" )
	_err = dir.copy(new_img_path, OS.get_user_data_dir() + "/GlobalSettings/UserImages/" + user_profiles[user_idx] + ".png" )


func get_current_user() -> String:
	if current_profile_idx == -1:
		return ""
	return user_profiles[current_profile_idx]


func get_current_user_data_folder() -> String:
	return OS.get_user_data_dir() + "/Users/" + Global.get_current_user()


func add_to_playlist(var playlist_selector, var playlist_idx : int, var main_idxs : PoolIntArray):
	for main_idx in main_idxs:
		var path : String = AllSongs.get_song_path(main_idx)
		# creates new key with path as the key and other infos as values
		SongLists.normal_playlists.values()[playlist_idx][path] = [main_idx]
		playlist_selector.queue_free()


func push_new_download(var url : String, var title : String, var dst_folder : String, var is_audio : bool, var video_format : int, var AudioFormat : int, var is_playlist : bool) -> void:
	# global Download -> Background loading possible
	current_downloads.push_back(
		{
			"URL" : url,
			"TITLE" : title,
			"DST_FOLDER" : dst_folder,
			"AUDIO" : is_audio,
			"VIDEO_FORMAT" : video_format,
			"AUDIO_FORMAT" : AudioFormat,
			"PLAYLIST" : is_playlist 
		}
	)
	download_from_queue(false)


func download_from_queue(var is_download_completed : bool = false) -> void:
	# if downloader Not ready it waits for it
	if !downloader_ref._is_ready:
		yield(downloader_ref,"ready")
	
	if !downloader_ref.is_connected("download_completed",self,"download_from_queue"):
		var _err = downloader_ref.connect("download_completed",self,"download_from_queue",[true],CONNECT_ONESHOT)
	
	if is_download_completed:
		# if a download was completed the first in queue gets freed -> the downloaded one
		if current_downloads.size() > 0:
			current_downloads.remove(0)
			Global.init_songs = true
	
	if current_downloads.size() > 0:
		if !downloader_ref._thread.is_active():
			downloader_ref.download(
				current_downloads[0]["URL"],
				current_downloads[0]["DST_FOLDER"],
				current_downloads[0]["TITLE"],
				current_downloads[0]["AUDIO"],
				current_downloads[0]["VIDEO_FORMAT"],
				current_downloads[0]["AUDIO_FORMAT"],
				current_downloads[0]["PLAYLIST"]
			)
	else:
		# all downloads finished
		emit_signal("downloads_finished")


func stop_queued_download(var idx : int) -> void:
	current_downloads.remove(idx)
