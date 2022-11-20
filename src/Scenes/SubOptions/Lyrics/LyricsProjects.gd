extends Control

const CLEAR_BUTTON_THEME : Theme = preload("res://src/Themes/Buttons/ClearButtons.tres")

onready var last_edited_projects : VBoxContainer = $VBoxContainer/LastEdited/ScrollContainer/LastEditedProjects
onready var all_projects : VBoxContainer = $VBoxContainer/AllProjects/ScrollContainer/AllProjects

func _ready():
	load_lyrics_projects()


func load_lyrics_projects() -> void:
	var dir : Directory = Directory.new()
	if dir.open(Global.get_current_user_data_folder() + "/Lyrics/Projects/") != OK:	return
	if dir.list_dir_begin(true,false) != OK:	return;
	
	# loading All Projects
	while true:
		var y = dir.get_next()
		if y == "": break;
		var x = Button.new()
		x.align = Button.ALIGN_LEFT
		x.theme = CLEAR_BUTTON_THEME
		x.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		all_projects.add_child(x)
		x.rect_min_size.y = 30
		x.set_text(y)
		x.connect("pressed",Global.root,"load_lyric_editor",[Global.get_current_user_data_folder() + "/Lyrics/Projects/" + y])
		x.size_flags_horizontal = SIZE_EXPAND_FILL
	
	# loading Last Edited
	# counts as Edited when:
	# 1.) An Already existing Project has been opened
	# 2.) A new Project gets saved
	# 3.) Every Saved As Project
	var load_projects : PoolStringArray = SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "LastEditedVLPProjects")
	for i in load_projects.size():
		if !Directory.new().file_exists(load_projects[i]):
			# if the File doesn't exist it will be removed from the Last Edited ones
			var temp : PoolStringArray = SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "LastEditedVLPProjects")
			temp.remove(i)
			SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "LastEditedVLPProjects", temp)
			continue;
		var x = Button.new()
		x.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		x.theme = CLEAR_BUTTON_THEME
		x.rect_min_size.y = 30
		x.align = Button.ALIGN_LEFT
		x.connect("pressed",Global.root,"load_lyric_editor",[load_projects[i]])
		last_edited_projects.add_child(x)
		x.set_text(load_projects[i].get_file())


func _on_NewLyricsProject_pressed():
	Global.root.load_lyric_editor()


func _on_OpenFromFile_pressed():
	var _dialog = Global.root.load_general_file_dialogue(
		Global.root,
		FileDialog.MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"load_lyric_editor",
		[],
		"Lyrics",
		["*.lrc","*.mp3","*.vlp"],
		true
	)
