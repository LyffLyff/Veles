extends Control

const song_formats : Array = ["mp3","ogg","flac","wav","opus"]
const dialogue_song_formats : Array = ["*.mp3","*.ogg","*.flac","*.wav","*.opus"]

onready var opened_files : ScrollContainer  = $VBoxContainer/HBoxContainer/DividedContainer

func _ready():
	var x = []
	for i in 1000:
		x.push_back("erguhvephnsödjnasödfjhdjfsdfsdfjjsdöf")
	update_opened_files(x)


func update_opened_files(var filepaths : PoolStringArray) -> void:
	var temp_item : Label
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
