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
	if dir.open(Global.GetCurrentUserDataFolder() + "/Lyrics/Projects/") != OK:	return
	if dir.list_dir_begin(true,false) != OK:	return;
	
	#Loading All Projects
	while true:
		var y = dir.get_next()
		if y == "": break;
		var x = Button.new()
		x.align = Button.ALIGN_LEFT
		x.theme = ClearButtonTheme
		AllProjects.add_child(x)
		x.rect_min_size.y = 30
		x.set_text(y)
		x.connect("pressed",Global.root,"LoadLyricEditor",[Global.GetCurrentUserDataFolder() + "/Lyrics/Projects/" + y])
		x.size_flags_horizontal = SIZE_EXPAND_FILL
	
	#Loading Last Edited
	#Counts as Edited when:
	#1.) An Already existing Project has been opened
	#2.) A new Project gets saved
	#3.) Every Saved As Project
	var LastProjects : PoolStringArray = SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"LastEditedVLPProjects")
	for i in LastProjects.size():
		if !Directory.new().file_exists(LastProjects[i]):
			#if the File doesn't exist it will be removed from the Last Edited ones
			var Temp : PoolStringArray = SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"LastEditedVLPProjects")
			Temp.remove(i)
			SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"LastEditedVLPProjects",Temp)
			continue;
		var x = Button.new()
		x.theme = ClearButtonTheme
		x.rect_min_size.y = 30
		x.align = Button.ALIGN_LEFT
		x.connect("pressed",Global.root,"LoadLyricEditor",[LastProjects[i]])
		LastEditedProjects.add_child(x)
		x.set_text(LastProjects[i])


func OnNewLyricsProjectPressed():
	Global.root.LoadLyricEditor()


func OnOpenLRCFilePressed():
	var _dialog = Global.root.OpenGeneralFileDialogue(
		Global.root,
		FileDialog.MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"LoadLyricEditor",
		[],
		"Lyrics",
		["*.lrc","*.mp3","*.vlp"],
		true
	)
