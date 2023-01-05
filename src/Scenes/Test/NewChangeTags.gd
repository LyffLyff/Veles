extends Control

const song_formats : Array = ["mp3","ogg","flac","wav","opus"]
const dialogue_song_formats : Array = ["*.mp3","*.ogg","*.flac","*.wav","*.opus"]

onready var opened_files : ScrollContainer  = $VBoxContainer/HBoxContainer/DividedContainer

func _ready():
	init_headers()
	Global.temp_tag_paths = song_formats
	update_opened_files(Global.temp_tag_paths)


func init_headers() -> void:
	var headers : PoolStringArray = ["Filename:", "Title:", "Artist:"]
	opened_files.clear_sections()
	for i in range(len(headers)):
		opened_files.append_section()
		opened_files.set_header(i, headers[i])


func update_opened_files(var filepaths : PoolStringArray) -> void:
	opened_files.clear_items()
	for i in len(filepaths):
		opened_files.append_item([filepaths[i]])


func _on_OpenFiles_pressed():
	var dialog = Global.root.load_general_file_dialogue(
		self,
		FileDialog.MODE_OPEN_FILES,
		FileDialog.ACCESS_FILESYSTEM,
		"update_opened_files",
		[],
		UsedFilepaths.TAG_PATH,
		dialogue_song_formats,
		false,
		"Select Files"
	)
