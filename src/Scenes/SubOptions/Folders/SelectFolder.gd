extends Control

const SEPARATION : int = 60
const folder_space : PackedScene = preload("res://src/Scenes/SubOptions/Folders/FolderSpace.tscn")

var current_folder : int = -1					#the folder which the mouse is inside
var folder_selection : int = -1					#the folder that has been selected

onready var folder_control : VBoxContainer = $VBoxContainer/HBoxContainer/Folders/HBoxContainer/Folders

func _ready():
	if get_tree().connect("files_dropped",self,"_on_FileDialog_dir_selected"):
		Global.root.message("CANNOT CONNECT FILES DROPPED SIGNAL TO _on_FileDialog_dir_selected FUNCTION",  SaveData.MESSAGE_ERROR)
	load_folders()


func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				if current_folder != -1:
					if folder_selection != -1:
						#Remove Highlighting fromt the priorly Pressed Song
						folder_control.get_child(folder_selection).unhighlight()
					
					#Highlight Newly Pressed Song
					folder_selection = current_folder
					if folder_selection < folder_control.get_child_count():
						folder_control.get_child(folder_selection).pressed()


func load_folders() -> void:
	for n in SongLists.folders.size():
		add_folder(SongLists.folders[n])


func set_current_folder(var folder_idx : int) -> void:
	current_folder = folder_idx


func GetValidSongAmount(var directory : String) -> String:
	#Returns the Amount of Valid songs inside of a given folder
	var dir : Directory = Directory.new()
	var SongCounter : int = 0
	if dir.open(directory) == OK:
		if dir.list_dir_begin(true,true) == OK:
			var temp : String = dir.get_next()
			while temp != "":
				if FormatChecker.get_music_filename_extension(temp) != -1:
					SongCounter += 1
				temp = dir.get_next()
			return "Songs: " + str(SongCounter)
	return "Songs: 0"


func add_folder(var folder : String):
	var new_label : PanelContainer = new_folder_space()
	if new_label.connect("set_folder_space_idx",self,"set_current_folder"):
		Global.root.message("CONNECTING FOLDER SPACE WITH SET CURRENT FOLDER FUNCTION",  SaveData.MESSAGE_ERROR)
	new_label.folder_space_label.set_text(folder)
	new_label.song_amount_label.set_text(GetValidSongAmount(folder))


func new_folder_space() -> Control:
	var folder : Control = folder_space.instance()
	folder_control.add_child(folder)
	return folder


func _on_AddFolder_pressed():
	var _dialog = Global.root.load_general_file_dialogue(
		self,
		FileDialog.MODE_OPEN_DIR,
		FileDialog.ACCESS_FILESYSTEM,
		"_on_FileDialog_dir_selected",
		[],
		"Song",
		[],
		false,
		"Add Folders"
	)


func _on_FileDialog_dir_selected(var new_folders : PoolStringArray,var _screen_idx : int = -1):
	if Global.general_dialogue_visible:
		return

	var dir : Directory = Directory.new()
	for folder in new_folders:
		if !dir.dir_exists(folder):
			folder = folder.get_base_dir()
		
		# checking validity of folder
		if !dir.dir_exists(folder):
			Global.root.message("Folder not found", SaveData.MESSAGE_WARNING, true)
			continue
		if SongLists.folders.has(folder):
			Global.root.message("Folders can only be added once", SaveData.MESSAGE_WARNING, true)
			continue
		
		# adding the folder
		SongLists.add_folder(folder)
		add_folder(folder)


func _on_Remove_pressed():
	if folder_selection != -1:
		# able to remove after the child index because they are loaded in the correct order already
		var dir_to_remove : String = folder_control.get_child(folder_selection).folder_space_label.get_text()
		SongLists.remove_folder(dir_to_remove)
		folder_control.get_child(folder_selection).queue_free()
		folder_selection = -1
		current_folder = -1
		Global.init_songs = true
		if SongLists.current_song.get_base_dir() == dir_to_remove:
			SongLists.current_song = ""
			Global.root.init_main()
			#Playback.new().stop_playback()
		Global.root.message("Removed selected folder", SaveData.MESSAGE_NOTICE, true)
	else:
		Global.root.message("Cannot remove -> No Folder Selected", SaveData.MESSAGE_NOTICE, true)
