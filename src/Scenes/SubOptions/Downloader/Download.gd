extends Control


#NODES
onready var URL : LineEdit = $ScrollContainer/VBoxContainer/HboxContainer/VBoxContainer/HBoxContainer/DownloadInfos/URL/LineEdit
onready var Title : LineEdit = $ScrollContainer/VBoxContainer/HboxContainer/VBoxContainer/HBoxContainer/DownloadInfos/Title/LineEdit
onready var dst_folder : LineEdit = $ScrollContainer/VBoxContainer/HboxContainer/VBoxContainer/HBoxContainer/DownloadInfos/DstFolder/LineEdit
onready var AudioVideo : OptionButton = $ScrollContainer/VBoxContainer/HboxContainer/VBoxContainer/HBoxContainer/DownloadInfos/AudioVideo/OptionButton
onready var Audioformat : OptionButton = $ScrollContainer/VBoxContainer/HboxContainer/VBoxContainer/HBoxContainer/DownloadInfos/Audioformat/OptionButton
onready var Videoformat : OptionButton = $ScrollContainer/VBoxContainer/HboxContainer/VBoxContainer/HBoxContainer/DownloadInfos/Videoformat/OptionButton
onready var is_playlist : OptionButton = $ScrollContainer/VBoxContainer/HboxContainer/VBoxContainer/HBoxContainer/DownloadInfos/Playlist/OptionButton
onready var CurrentDownload : VBoxContainer = $ScrollContainer/VBoxContainer/HboxContainer/VBoxContainer/CurrentDownload
onready var QueuedDownloads : VBoxContainer = $ScrollContainer/VBoxContainer/HboxContainer/VBoxContainer/ScrollContainer/QueuedDownloads

#VARIABLES
var StdDownloadFolder : String = Global.get_current_user_data_folder() + "/Downloads/"

#PRELOADS
const DownloadContainer : PackedScene = preload("res://src/Scenes/SubOptions/Downloader/QueuedDownloadContainer.tscn")


func _ready():
	dst_folder.set_text(StdDownloadFolder)
	var _err = Global.downloader_ref.connect("download_completed",self,"UpdateDownloads")
	_err = Global.downloader_ref._downloader.connect("download_failed",self,"UpdateDownloads")
	_err = get_tree().connect("files_dropped",self,"_on_files_dropped")
	UpdateDownloads()


func _on_files_dropped(var files : Array , var _screen : int) -> void:
	if Global.general_dialogue_visible: return;
	dst_folder.set_text( files[0].replace("\\","/") )


func UpdateDownloads() -> void:
	#Freeing prior Download Containers
	for Child in CurrentDownload.get_children():
		if !(Child is Label):
			Child.queue_free()
	for Child in QueuedDownloads.get_children():
		if !(Child is Label):
			Child.queue_free()
	
	
	#Adding the Updated Downloads
	for i in Global.current_downloads.size():
		var NewDownloadContainer : Control = DownloadContainer.instance()
		var _err
		if i == 0:
			CurrentDownload.add_child( NewDownloadContainer )
			_err = NewDownloadContainer.Stop.connect("pressed",Global,"download_from_queue",[true])
		else:
			QueuedDownloads.add_child(NewDownloadContainer)
			_err = NewDownloadContainer.Stop.connect("pressed",Global,"stop_queued_download",[i])
		_err = NewDownloadContainer.Stop.connect("pressed",self,"UpdateDownloads")
		#_err = NewDownloadContainer.Stop.connect("pressed",NewDownloadContainer,"queue_free")
		NewDownloadContainer.InitDownloadContainer(Global.current_downloads[i])


func CheckSetup() -> bool:
	#Checking if FFMpeg and FFProbe exist
	var dir : Directory = Directory.new()
	if OS.get_name() == "Windows":
		if !dir.file_exists("user://ffmpeg.exe") or !dir.file_exists("user://ffprobe.exe"):
			return false
	return true


func OnDownloadAdded():
	if !CheckSetup():
		Global.root.message("Download setup is NOT complete -> see Infos",  SaveData.MESSAGE_ERROR, true, Color(ColorN("dark_red")) )
		return
	
	if !Directory.new().dir_exists( dst_folder.get_text().get_base_dir() ):
		Global.root.message("Destination Folder not found",  SaveData.MESSAGE_ERROR, true, Color(ColorN("red")) )
		return
	
	if Title.get_text() == "":
		Global.root.message("No Filename Selected",  SaveData.MESSAGE_ERROR, true, Color(ColorN("red")) )
		return
	if !Title.get_text().is_valid_filename():
		Global.root.message("Invalid Filename Title",  SaveData.MESSAGE_ERROR, true, Color(ColorN("red")) )
		return
	
	if URL.get_text() == "":
		Global.root.message("No Download link entered",  SaveData.MESSAGE_ERROR, true, Color(ColorN("red")) )
		return
	
	Global.push_new_download(
		URL.get_text(),
		Title.get_text(),
		dst_folder.get_text().get_base_dir(),
		AudioVideo.selected,
		Videoformat.selected,
		Audioformat.selected,
		is_playlist.selected
	)
	URL.clear()
	Title.clear()
	UpdateDownloads()
