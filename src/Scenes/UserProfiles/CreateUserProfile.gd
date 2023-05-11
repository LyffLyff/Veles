extends "res://src/Scenes/General/StdPopupBackground.gd"

onready var profile_img_selection : HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/SelectProfileImg
onready var username : HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/Name
onready var menu_footer : HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/MenuFooter

func _ready():
	var _err = profile_img_selection.connect("dialogue_pressed",self,"load_dialogue")
	menu_footer.connect("save_pressed", self, "_on_Save_pressed")
	menu_footer.connect("close_pressed", self, "exit_popup")


func load_dialogue() -> void:
	var _dialog = Global.root.load_general_file_dialogue(
		profile_img_selection.input_edit,
		FileDialog.MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"set_text",
		[],
		UsedFilepaths.USER_COVER,
		Global.supported_img_extensions,
		true,
		"Select User Cover"
	)


func _on_Save_pressed() -> void:
	var new_username : String = username.input_edit.get_text()
	
	if !Global.is_username_valid(new_username):
		Global.message("Invalid Username", Enumerations.MESSAGE_ERROR, true)
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
