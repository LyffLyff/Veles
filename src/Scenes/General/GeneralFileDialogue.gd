extends "res://src/Scenes/General/StdPopupBackground.gd"

signal saved
signal exited
signal selection_made

var search_type : String = ""	# Song,Image,Lyrics
var return_as_string : bool = false

onready var dialogue : FileDialog = $FileDialog


func _ready():
	var _err = get_tree().connect("files_dropped",self,"_on_files_dropped")


func _enter_tree():
	Global.general_dialogue_visible = true
	Global.root.toggle_songlist_input(false)


func _exit_tree():
	Global.general_dialogue_visible = false
	Global.root.toggle_songlist_input(true)


func _on_files_dropped(var files : PoolStringArray, var _screen_idx : int) -> void:
	dialogue.set_current_dir(files[0].get_base_dir())


func _on_FileDialog_popup_hide():
	emit_signal("exited")
	exit_popup()


func n_ready(var mode_flag : int = 0, var access_flag : int = 0, var type : String = "", var filetype_filters : PoolStringArray = [], var return_string : bool = false, var title_override : String = "", var _file_override : String = ""):
	# node that needs this Scene has to call this function and give certain Parameters
	# mode and Access NEED to be set prior to prevent blocking the set path/dir/file functions
	dialogue.set_access(access_flag)
	dialogue.set_mode(mode_flag)
	dialogue.set_filters(filetype_filters)
	if title_override != "":
		dialogue.window_title = title_override
		dialogue.set_mode_overrides_title(true)
	return_as_string = return_string
	# get Last Used Folder
	search_type = type
	match search_type:
		"Image":
			var path : String = SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"ImagePath")
			if path != "":
				dialogue.set_current_dir(path)
		"Song":
			var path : String = SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"SongPath")
			if path != "":
				dialogue.set_current_dir(path)
		"Lyrics":
			dialogue.set_current_dir(Global.get_current_user_data_folder() + "/Lyrics/Projects")
		"ExportCover":
			var path : String = SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"CoverExportPath")
			if path != "":
				dialogue.set_current_dir(path)
		"ExportHTML":
			dialogue.set_current_dir(
				SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"HTMLExportPath")
			)
		"ExportLRC":
			dialogue.set_current_dir(
				SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"LRCExportPath")
			)
		"ExportCSV":
			dialogue.set_current_dir(
				SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"CSVExportPath")
			)
		"ExportFolder":
			dialogue.set_current_dir(
				SettingsData.get_setting(SettingsData.GENERAL_SETTINGS,"FolderExportPath")
			)
	dialogue.popup_centered()


func selection_made(var args) -> void:
	# the function that gets called when any the action of the dialogue was done
	# saving, open dir, open file/s,....
	emit_signal("saved")
	
	if return_as_string:
		if typeof(args) == TYPE_STRING:
			save_last_folder(args)
			emit_signal("selection_made",args)
		else:	# typeof(args) == TYPE_STRING_ARRAY:
			save_last_folder(args[0])
			emit_signal("selection_made",args[0])
	else:
		if typeof(args) == TYPE_STRING:
			save_last_folder(args)
			emit_signal("selection_made",[args])
		else:	# typeof(args) == TYPE_STRING_ARRAY:
			save_last_folder(args[0])
			emit_signal("selection_made",args)
	
	exit_popup()


func save_last_folder(var args : String):
	# saving folder for next call of this Scene
	var folder : String = args.get_base_dir()
	match search_type:
		"Image":
			SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "ImagePath", folder)
		"Song":
			SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "song_path", folder)
		"ExportCover":
			SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "CoverExportPath", folder)
		"ExportHTML":
			SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "HTMLExportPath", folder)
		"ExportLRC":
			SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "LRCExportPath", folder)
		"ExportCSV":
			SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "CSVExportPath", folder)
		"ExportFolder":
			SettingsData.set_setting(SettingsData.GENERAL_SETTINGS, "FolderExportPath", folder)
