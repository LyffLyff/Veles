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
	var load_projects : Dictionary = SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "LastEditedVLPProjects")
	for i in load_projects.size():
		if !Directory.new().file_exists(load_projects.keys()[i]):
			# if the File doesn't exist it will be removed from the Last Edited ones
			var temp : Dictionary = SettingsData.get_setting(SettingsData.GENERAL_SETTINGS, "LastEditedVLPProjects")
			temp.erase(load_projects.keys()[i])
			SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "LastEditedVLPProjects", temp)
			continue;
		var new_project_container : Control = PROJECT_CONTAINER.instance()
		var _err = new_project_container.connect("pressed",Global.root,"load_lyric_editor",[load_projects.keys()[i]])
		projects.add_child(new_project_container)
		new_project_container.date.text = str(load_projects.get(load_projects.keys()[i], OS.get_unix_time()))
		new_project_container.file.text = load_projects.keys()[i].get_file()
		new_project_container.path.set_text(load_projects.keys()[i])	#set_text required because of text limiter


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
