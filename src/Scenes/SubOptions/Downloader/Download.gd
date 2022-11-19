extends Control

const DownloadContainer : PackedScene = preload("res://src/Scenes/SubOptions/Downloader/QueuedDownloadContainer.tscn")

var  std_download_folder : String = Global.get_current_user_data_folder() + "/Downloads/"

onready var url_edit : LineEdit = $ScrollContainer/VBoxContainer/HboxContainer/VBoxContainer/HBoxContainer/DownloadInfos/URL/LineEdit
onready var title : LineEdit = $ScrollContainer/VBoxContainer/HboxContainer/VBoxContainer/HBoxContainer/DownloadInfos/Title/LineEdit
onready var dst_folder : LineEdit = $ScrollContainer/VBoxContainer/HboxContainer/VBoxContainer/HBoxContainer/DownloadInfos/DstFolder/LineEdit
onready var audio_video : OptionButton = $ScrollContainer/VBoxContainer/HboxContainer/VBoxContainer/HBoxContainer/DownloadInfos/AudioVideo/OptionButton
onready var audio_format : OptionButton = $ScrollContainer/VBoxContainer/HboxContainer/VBoxContainer/HBoxContainer/DownloadInfos/Audioformat/OptionButton
onready var video_format : OptionButton = $ScrollContainer/VBoxContainer/HboxContainer/VBoxContainer/HBoxContainer/DownloadInfos/Videoformat/OptionButton
onready var is_playlist : OptionButton = $ScrollContainer/VBoxContainer/HboxContainer/VBoxContainer/HBoxContainer/DownloadInfos/Playlist/OptionButton
onready var current_downloads : VBoxContainer = $ScrollContainer/VBoxContainer/HboxContainer/VBoxContainer/CurrentDownload
onready var queued_downloads : VBoxContainer = $ScrollContainer/VBoxContainer/HboxContainer/VBoxContainer/ScrollContainer/QueuedDownloads


func _ready():
	dst_folder.set_text(std_download_folder)
	var _err = Global.downloader_ref.connect("download_completed",self,"update_downloads")
	_err = Global.downloader_ref._downloader.connect("download_failed",self,"update_downloads")
	_err = get_tree().connect("files_dropped",self,"_on_files_dropped")
	update_downloads()


func _on_files_dropped(var files : Array , var _screen_idx : int) -> void:
	if Global.general_dialogue_visible: return;
	dst_folder.set_text( files[0].replace("\\","/") )


func update_downloads() -> void:
	# freeing prior Download Containers
	for child in current_downloads.get_children():
		if !(child is Label):
			child.queue_free()
	for child in queued_downloads.get_children():
		if !(child is Label):
			child.queue_free()
	
	
	# adding the updated Downloads
	for i in Global.current_downloads.size():
		var new_download_container : Control = DownloadContainer.instance()
		var _err
		if i == 0:
			current_downloads.add_child( new_download_container )
			_err = new_download_container.stop.connect("pressed",Global,"download_from_queue",[true])
		else:
			queued_downloads.add_child(new_download_container)
			_err = new_download_container.stop.connect("pressed",Global,"stop_queued_download",[i])
		_err = new_download_container.stop.connect("pressed",self,"update_downloads")
		new_download_container.init_download_container(Global.current_downloads[i])


func check_setup() -> bool:
	# checking if FFMpeg and FFProbe exist
	var dir : Directory = Directory.new()
	if OS.get_name() == "Windows":
		if !dir.file_exists("user://ffmpeg.exe") or !dir.file_exists("user://ffprobe.exe"):
			return false
	return true


func OnDownloadAdded():
	if !check_setup():
		Global.root.message("Download setup is NOT complete -> see Infos",  SaveData.MESSAGE_ERROR, true, Color(ColorN("dark_red")) )
		return
	
	if !Directory.new().dir_exists( dst_folder.get_text().get_base_dir() ):
		Global.root.message("Destination Folder not found",  SaveData.MESSAGE_ERROR, true, Color(ColorN("red")) )
		return
	
	if title.get_text() == "":
		Global.root.message("No Filename Selected",  SaveData.MESSAGE_ERROR, true, Color(ColorN("red")) )
		return
	if !title.get_text().is_valid_filename():
		Global.root.message("Invalid Filename Title",  SaveData.MESSAGE_ERROR, true, Color(ColorN("red")) )
		return
	
	if url_edit.get_text() == "":
		Global.root.message("No Download link entered",  SaveData.MESSAGE_ERROR, true, Color(ColorN("red")) )
		return
	
	Global.push_new_download(
		url_edit.get_text(),
		title.get_text(),
		dst_folder.get_text().get_base_dir(),
		audio_video.selected,
		video_format.selected,
		audio_format.selected,
		is_playlist.selected
	)
	url_edit.clear()
	title.clear()
	update_downloads()
