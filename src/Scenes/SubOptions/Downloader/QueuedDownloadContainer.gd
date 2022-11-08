extends PanelContainer

#NODES
onready var QTitle : Label = $HBoxContainer/VBoxContainer/HBoxContainer/Left/Title
onready var QURL : Label = $HBoxContainer/VBoxContainer/HBoxContainer/Left/URL
onready var QSoundVideo : Label = $HBoxContainer/VBoxContainer/HBoxContainer/Right/AudioVideo
onready var QFileformat : Label = $HBoxContainer/VBoxContainer/HBoxContainer/Right/Format
onready var DstFolder : LinkButton = $HBoxContainer/VBoxContainer/HBoxContainer2/DstFolder
onready var Stop : TextureButton = $HBoxContainer/Stop


func InitDownloadContainer(var CurrentDownload : Dictionary) -> void:
	QTitle.set_text("Title: " + CurrentDownload["TITLE"])
	QURL.set_text("URL: " + CurrentDownload["URL"])
	QSoundVideo.set_text( "Audio" ) if CurrentDownload["AUDIO"] else QSoundVideo.set_text( "Video" )
	QFileformat.set_text("Format: " + Global.audio_formats[CurrentDownload["AUDIO_FORMAT"]] ) if CurrentDownload["AUDIO"] else QSoundVideo.set_text("Format: " + Global.video_formats[CurrentDownload["VIDEO_FORMAT"]] )
	DstFolder.set_text(CurrentDownload["DST_FOLDER"])



func OnDstFolderPressed():
	var _err = OS.shell_open(DstFolder.get_text())
