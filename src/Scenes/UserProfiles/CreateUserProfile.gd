extends "res://src/Scenes/General/StdPopupBackground.gd"

#NODES
onready var ProfileImgSelection : HBoxContainer = $PanelContainer/HBoxContainer/VBoxContainer/SelectProfileImg
onready var Username : HBoxContainer = $PanelContainer/HBoxContainer/VBoxContainer/Name


func _ready():
	var _err = ProfileImgSelection.connect("DialoguePressed",self,"LoadDialogue")


func LoadDialogue() -> void:
	var _dialog = Global.root.load_general_file_dialogue(
		ProfileImgSelection.InputEdit,
		FileDialog.MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"set_text",
		[],
		"Cover",
		Global.SupportedImgFormats,
		true
	)


func OnSaveProfile() -> void:
	var new_username : String = Username.InputEdit.get_text()
	
	if !Global.is_username_valid(new_username):
		Global.root.message("Invalid Username", SaveData.MESSAGE_ERROR, true)
		ExitPopup()
		return;
	
	var dir : Directory = Directory.new()
	var CoverSrc : String = ProfileImgSelection.InputEdit.get_text()
	if dir.file_exists(CoverSrc):
		var _err = dir.copy( 
			CoverSrc,
			"user://GlobalSettings/UserImages/" + Username.InputEdit.get_text() + ".png"
		)
	
	Global.NewUserProfile(Username.InputEdit.get_text())
	Global.UserProfiles.push_back(Username.InputEdit.get_text())
	ExitPopup()
