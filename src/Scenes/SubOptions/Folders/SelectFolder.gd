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
		Global.root.Message("CANNOT CONNECT FILES DROPPED SIGNAL TO _on_FileDialog_dir_selected FUNCTION",  SaveData.MESSAGE_ERROR)
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
	for n in SongLists.Folders.size():
		AddFolder(SongLists.Folders[n])


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
				if FormatChecker.FileNameFormat(temp) != -1:
					SongCounter += 1
				temp = dir.get_next()
			return "Songs: " + str(SongCounter)
	return "Songs: 0"


func AddFolder(var Folder : String):
	var NewLabel : PanelContainer = NewFolderSpace()
	if NewLabel.connect("SetFolder",self,"SetCurrentFolder"):
		Global.root.Message("CONNECTING FOLDER SPACE WITH SET CURRENT FOLDER FUNCTION",  SaveData.MESSAGE_ERROR)
	NewLabel.FolderLabel.set_text( Folder )
	NewLabel.SongAmountLabel.set_text( GetValidSongAmount(Folder) )


func NewFolderSpace() -> Control:
	var folder : Control = FolderSpace.instance()
	FolderControl.add_child(folder)
	return folder


func _on_AddFolder_pressed():
	var _dialog = Global.root.OpenGeneralFileDialogue(
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
	for Folder in NewFolders:
		if !SongLists.Folders.has(Folder):
			SongLists.AddFolder(Folder)
			AddFolder(Folder)
		else:
			Global.root.Message("Folders can only be added once", SaveData.MESSAGE_WARNING)


func _on_Remove_pressed():
	if FolderSelection != -1:
		#Able to remove after the child index because they are loaded in the correct order already
		var ToRemove : String = FolderControl.get_child(FolderSelection).FolderLabel.get_text()
		SongLists.RemoveFolder(ToRemove)
		FolderControl.get_child(FolderSelection).queue_free()
		FolderSelection = -1
		Global.InitializeSongs = true
		root.Message("Removed selected folder", SaveData.MESSAGE_NOTICE, true)
	else:
		root.Message("Cannot remove -> No Folder Selected", SaveData.MESSAGE_NOTICE, true)
