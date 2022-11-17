extends "res://src/Scenes/General/StdPopupBackground.gd"

onready var profile_img_selection : HBoxContainer = $PanelContainer/HBoxContainer/VBoxContainer/SelectProfileImg
onready var username : HBoxContainer = $PanelContainer/HBoxContainer/VBoxContainer/Name

func _ready():
	var _err = profile_img_selection.connect("dialogue_pressed",self,"load_dialogue")


func load_dialogue() -> void:
	var _dialog = Global.root.load_general_file_dialogue(
		profile_img_selection.input_edit,
		FileDialog.MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"set_text",
		[],
		"Cover",
		Global.supported_img_extensions,
		true
	)


func _on_Save_pressed() -> void:
	var new_username : String = username.input_edit.get_text()
	
	if !Global.is_username_valid(new_username):
		Global.root.message("Invalid Username", SaveData.MESSAGE_ERROR, true)
		exit_popup()
		return;
	
	var dir : Directory = Directory.new()
	var cover_src : String = profile_img_selection.input_edit.get_text()
	if dir.file_exists(cover_src):
		var _err = dir.copy( 
			cover_src,
			"user://GlobalSettings/UserImages/" + username.input_edit.get_text() + ".png"
		)
	
	Global.new_user_profile(username.input_edit.get_text())
	Global.user_profiles.push_back(username.input_edit.get_text())
	exit_popup()
