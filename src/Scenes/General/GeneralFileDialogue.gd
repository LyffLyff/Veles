extends "res://src/Scenes/General/StdPopupBackground.gd"

signal saved
signal exited
signal selection_made

var filepath_idx : int = UsedFilepaths.DESKTOP
var return_as_string : bool = false

onready var dialogue : FileDialog = $FileDialog


func _ready():
	dialogue.visible = true
	var _err = get_tree().connect("files_dropped",self,"_on_files_dropped")


func _enter_tree():
	Global.general_dialogue_visible = true


func _on_files_dropped(var files : PoolStringArray, var _screen_idx : int) -> void:
	dialogue.set_current_dir(files[0].get_base_dir())


func _on_FileDialog_popup_hide():
	self.emit_signal("exited")
	self.exit_popup(dialogue)


func n_ready(var mode_flag : int = 0, var access_flag : int = 0, var used_filepath_idx : int = UsedFilepaths.DESKTOP, var filetype_filters : PoolStringArray = [], var return_string : bool = false, var title_override : String = "", var _file_override : String = ""):
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
	filepath_idx = used_filepath_idx
	dialogue.set_current_dir(UsedFilepaths.get_used_filepath(used_filepath_idx))
	dialogue.popup_centered()


func selection_made(var args) -> void:
	# the function that gets called when any the action of the dialogue was done
	# saving, open dir, open file/s,....
	Global.general_dialogue_visible = false
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
	
	self.exit_popup()


func save_last_folder(var args : String):
	# saving folder for next call of this Scene
	# gets base dir if directory is not existent e.g. is file or invalid directory
	if Directory.new().dir_exists(args):
		UsedFilepaths.save_filepath_type(filepath_idx, args)
	else:
		UsedFilepaths.save_filepath_type(filepath_idx, args.get_base_dir())

