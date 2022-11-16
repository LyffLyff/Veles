extends Control


#CONSTANTS
const SEPARATION : int = 60

#NODES
onready var root : Control = get_tree().get_root().get_child(get_tree().get_root().get_child_count()-1)
onready var FolderControl : VBoxContainer = $VBoxContainer/HBoxContainer/Folders/HBoxContainer/Folders

#PRELOADS
const FolderSpace : PackedScene = preload("res://src/Scenes/SubOptions/Folders/FolderSpace.tscn")

#VARIABLES
var CurrentFolder : int = -1					#the folder which the mouse is inside
var FolderSelection : int = -1					#the folder that has been selected


func _ready():
	if get_tree().connect("files_dropped",self,"_on_FileDialog_dir_selected"):
		Global.root.message("CANNOT CONNECT FILES DROPPED SIGNAL TO _on_FileDialog_dir_selected FUNCTION",  SaveData.MESSAGE_ERROR)
	LoadFolders()


func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == BUTTON_LEFT:
				if CurrentFolder != -1:
					if FolderSelection != -1:
						#Remove Highlighting fromt the priorly Pressed Song
						FolderControl.get_child(FolderSelection).Unhighlight()
					
					#Highlight Newly Pressed Song
					FolderSelection = CurrentFolder
					if FolderSelection < FolderControl.get_child_count():
						FolderControl.get_child(FolderSelection).Pressed()


func LoadFolders() -> void:
	for n in SongLists.folders.size():
		add_folder(SongLists.folders[n])


func SetCurrentFolder(var FolderIdx : int) -> void:
	CurrentFolder = FolderIdx


func GetValidSongAmount(var FolderPath : String) -> String:
	#Returns the Amount of Valid songs inside of a given folder
	var dir : Directory = Directory.new()
	var SongCounter : int = 0
	if dir.open(FolderPath) == OK:
		if dir.list_dir_begin(true,true) == OK:
			var temp : String = dir.get_next()
			while temp != "":
				if FormatChecker.get_music_filename_extension(temp) != -1:
					SongCounter += 1
				temp = dir.get_next()
			return "Songs: " + str(SongCounter)
	return "Songs: 0"


func add_folder(var Folder : String):
	var NewLabel : PanelContainer = NewFolderSpace()
	if NewLabel.connect("SetFolder",self,"SetCurrentFolder"):
		Global.root.message("CONNECTING FOLDER SPACE WITH SET CURRENT FOLDER FUNCTION",  SaveData.MESSAGE_ERROR)
	NewLabel.FolderLabel.set_text( Folder )
	NewLabel.SongAmountLabel.set_text( GetValidSongAmount(Folder) )


func NewFolderSpace() -> Control:
	var folder : Control = FolderSpace.instance()
	FolderControl.add_child(folder)
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


func _on_FileDialog_dir_selected(var NewFolders : PoolStringArray,var _screen : int = -1):
	if Global.general_dialogue_visible:
		return

	var dir : Directory = Directory.new()
	for folder in NewFolders:
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
	if FolderSelection != -1:
		#Able to remove after the child index because they are loaded in the correct order already
		var dir_to_remove : String = FolderControl.get_child(FolderSelection).FolderLabel.get_text()
		SongLists.remove_folder(dir_to_remove)
		FolderControl.get_child(FolderSelection).queue_free()
		FolderSelection = -1
		CurrentFolder = -1
		Global.init_songs = true
		if SongLists.current_song.get_base_dir() == dir_to_remove:
			SongLists.current_song = ""
			Global.root.init_main()
			#Playback.new().stop_playback()
		root.message("Removed selected folder", SaveData.MESSAGE_NOTICE, true)
	else:
		root.message("Cannot remove -> No Folder Selected", SaveData.MESSAGE_NOTICE, true)
