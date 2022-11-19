extends PanelContainer

onready var queued_title : Label = $HBoxContainer/VBoxContainer/HBoxContainer/Left/Title
onready var queued_url : Label = $HBoxContainer/VBoxContainer/HBoxContainer/Left/URL
onready var queued_audio_video : Label = $HBoxContainer/VBoxContainer/HBoxContainer/Right/AudioVideo
onready var queued_fileformat : Label = $HBoxContainer/VBoxContainer/HBoxContainer/Right/Format
onready var dst_folder : LinkButton = $HBoxContainer/VBoxContainer/HBoxContainer2/DstFolder
onready var stop : TextureButton = $HBoxContainer/Stop


func init_download_container(var current_downloads : Dictionary) -> void:
	queued_title.set_text("Title: " + current_downloads["TITLE"])
	queued_url.set_text("URL: " + current_downloads["URL"])
	queued_audio_video.set_text( "Audio" ) if current_downloads["AUDIO"] else queued_audio_video.set_text( "Video" )
	queued_fileformat.set_text("Format: " + Global.audio_formats[current_downloads["AUDIO_FORMAT"]] ) if current_downloads["AUDIO"] else queued_audio_video.set_text("Format: " + Global.video_formats[current_downloads["VIDEO_FORMAT"]] )
	dst_folder.set_text(current_downloads["DST_FOLDER"])


func OnDstFolderPressed():
	var _err = OS.shell_open(dst_folder.get_text())
