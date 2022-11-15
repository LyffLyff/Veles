extends Control

#PRELOADS
const ClearButtonTheme : Theme = preload("res://src/Themes/Buttons/ClearButtons.tres")

#NODES
onready var LastEditedProjects : VBoxContainer = $VBoxContainer/LastEdited/ScrollContainer/LastEditedProjects
onready var AllProjects : VBoxContainer = $VBoxContainer/AllProjects/ScrollContainer/AllProjects


func _ready():
	LoadLyricsProjects()


func LoadLyricsProjects() -> void:
	var dir : Directory = Directory.new()
	if dir.open(Global.get_current_user_data_folder() + "/Lyrics/Projects/") != OK:	return
	if dir.list_dir_begin(true,false) != OK:	return;
	
	#Loading All Projects
	while true:
		var y = dir.get_next()
		if y == "": break;
		var x = Button.new()
		x.align = Button.ALIGN_LEFT
		x.theme = ClearButtonTheme
		x.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		AllProjects.add_child(x)
		x.rect_min_size.y = 30
		x.set_text(y)
		x.connect("pressed",Global.root,"load_lyric_editor",[Global.get_current_user_data_folder() + "/Lyrics/Projects/" + y])
		x.size_flags_horizontal = SIZE_EXPAND_FILL
	
	#Loading Last Edited
	#Counts as Edited when:
	#1.) An Already existing Project has been opened
	#2.) A new Project gets saved
	#3.) Every Saved As Project
	var LastProjects : PoolStringArray = SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"LastEditedVLPProjects")
	for i in LastProjects.size():
		if !Directory.new().file_exists(LastProjects[i]):
			#if the File doesn't exist it will be removed from the Last Edited ones
			var Temp : PoolStringArray = SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"LastEditedVLPProjects")
			Temp.remove(i)
			SettingsData.set_setting(SettingsData.GENERAL_SETTINGS,"LastEditedVLPProjects",Temp)
			continue;
		var x = Button.new()
		x.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		x.theme = ClearButtonTheme
		x.rect_min_size.y = 30
		x.align = Button.ALIGN_LEFT
		x.connect("pressed",Global.root,"load_lyric_editor",[LastProjects[i]])
		LastEditedProjects.add_child(x)
		x.set_text(LastProjects[i].get_file())


func OnNewLyricsProjectPressed():
	Global.root.load_lyric_editor()


func OnOpenLRCFilePressed():
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
