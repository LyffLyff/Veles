extends Control

const CLEAR_BUTTON_THEME : Theme = preload("res://src/Themes/Buttons/ClearButtons.tres")
const PROJECT_CONTAINER : PackedScene = preload("res://src/Scenes/SubOptions/Lyrics/ProjectContainer.tscn")

onready var projects : VBoxContainer = $VBoxContainer/VBoxContainer/ScrollContainer/Projects

func _ready():
	Global.root.init_context_menus()
	load_lyrics_projects()


func load_lyrics_projects() -> void:
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
		var x = PROJECT_CONTAINER.instance()
		x.connect("pressed",Global.root,"load_lyric_editor",[load_projects[i]])
		projects.add_child(x)
		x.file.text = load_projects[i].get_file()
		x.path.set_text(load_projects[i])	#set_text required because of text limiter


func _on_NewLyricsProject_pressed():
	Global.root.load_lyric_editor()


func _on_OpenFromFile_pressed():
	var _dialog = Global.root.load_general_file_dialogue(
		Global.root,
		FileDialog.MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"load_lyric_editor",
		[],
		UsedFilepaths.LRC_FILE,
		["*.lrc","*.mp3","*.vlp"],
		true,
		"Open Lyrics"
	)
