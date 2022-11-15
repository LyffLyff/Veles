extends "res://src/Scenes/General/StdPopupBackground.gd"

#NODES
onready var ProfileImgSelection : HBoxContainer = $PanelContainer/HBoxContainer/VBoxContainer/SelectProfileImg
onready var Username : HBoxContainer = $PanelContainer/HBoxContainer/VBoxContainer/Name


func _ready():
	var _err = ProfileImgSelection.connect("dialogue_pressed",self,"LoadDialogue")


func LoadDialogue() -> void:
	var _dialog = Global.root.load_general_file_dialogue(
		ProfileImgSelection.input_edit,
		FileDialog.MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"set_text",
		[],
		"Cover",
		Global.supported_img_extensions,
		true
	)


func OnSaveProfile() -> void:
	var new_username : String = Username.input_edit.get_text()
	
	if !Global.is_username_valid(new_username):
		Global.root.message("Invalid Username", SaveData.MESSAGE_ERROR, true)
		exit_popup()
		return;
	
	var dir : Directory = Directory.new()
	var CoverSrc : String = ProfileImgSelection.input_edit.get_text()
	if dir.file_exists(CoverSrc):
		var _err = dir.copy( 
			CoverSrc,
			"user://GlobalSettings/UserImages/" + Username.input_edit.get_text() + ".png"
		)
	
	Global.new_user_profile(Username.input_edit.get_text())
	Global.user_profiles.push_back(Username.input_edit.get_text())
	exit_popup()
