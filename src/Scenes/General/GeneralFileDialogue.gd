extends "res://src/Scenes/General/StdPopupBackground.gd"


#SIGNALS
signal Saved
signal SelectionMade
signal Exit

#VARIABLES
var SearchType : String = ""	#Song,Image,Lyrics
var ReturnString : bool = false

#NODES
onready var Dialog : FileDialog = $FileDialog
onready var FileEdit : LineEdit = Dialog.get_child(3).get_child(3).get_child(1)

func _ready():
	var _err = get_tree().connect("files_dropped",self,"OnFilesDropped")


func _enter_tree():
	Global.general_dialogue_visible = true
	Global.root.toggle_songlist_input(false)

func _exit_tree():
	Global.general_dialogue_visible = false
	Global.root.toggle_songlist_input(true)


#Node that needs this Scene has to call this function and give certain Parameters
func NReady(var ModeFlag : int = 0,var AccessFlag : int = 0,var Type : String = "", var FileTypeSpecification : PoolStringArray = [],var ReturnAsString : bool = false, var TitleOverride : String = "", var _FileOverride : String = ""):
	#Mode and Access NEED to be set prior to prevent blocking the set path/dir/file functions
	Dialog.set_access(AccessFlag)
	Dialog.set_mode(ModeFlag)
	Dialog.set_filters(FileTypeSpecification)
	if TitleOverride != "":
		Dialog.window_title = TitleOverride
		Dialog.set_mode_overrides_title(true)
	ReturnString = ReturnAsString
	#Get Last Used Folder
	SearchType = Type
	match SearchType:
		"Image":
			var path : String = SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"ImagePath")
			if path != "":
				Dialog.set_current_dir(path)
		"Song":
			var path : String = SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"SongPath")
			if path != "":
				Dialog.set_current_dir(path)
		"Lyrics":
			Dialog.set_current_dir(Global.GetCurrentUserDataFolder() + "/Lyrics/Projects")
		"ExportCover":
			var path : String = SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"CoverExportPath")
			if path != "":
				Dialog.set_current_dir(path)
		"ExportHTML":
			Dialog.set_current_dir(
				SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"HTMLExportPath")
			)
		"ExportLRC":
			Dialog.set_current_dir(
				SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"LRCExportPath")
			)
		"ExportCSV":
			Dialog.set_current_dir(
				SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"CSVExportPath")
			)
		"ExportFolder":
			Dialog.set_current_dir(
				SettingsData.GetSetting(SettingsData.GENERAL_SETTINGS,"FolderExportPath")
			)
	Dialog.popup_centered()


func SelectionMade(var args) -> void:
	emit_signal("Saved")
	if ReturnString:
		if typeof(args) == TYPE_STRING:
			SaveLastFolder(args)
			emit_signal("SelectionMade",args)
		else:# typeof(args) == TYPE_STRING_ARRAY:
			SaveLastFolder(args[0])
			emit_signal("SelectionMade",args[0])
	else:
		if typeof(args) == TYPE_STRING:
			SaveLastFolder(args)
			emit_signal("SelectionMade",[args])
		else:# typeof(args) == TYPE_STRING_ARRAY:
			SaveLastFolder(args[0])
			emit_signal("SelectionMade",args)
	
	ExitPopup()


func SaveLastFolder(var args : String):
	#Saving Folder for next call of this Scene
	var folder : String
	folder = args.get_base_dir()
	match SearchType:
		"Image":
			SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"ImagePath",folder)
		"Song":
			SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"SongPath",folder)
		"ExportCover":
			SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"CoverExportPath",folder)
		"ExportHTML":
			SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"HTMLExportPath",folder)
		"ExportLRC":
			SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"LRCExportPath",folder)
		"ExportCSV":
			SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"CSVExportPath",folder)
		"ExportFolder":
			SettingsData.SetSetting(SettingsData.GENERAL_SETTINGS,"FolderExportPath",folder)


func OnFilesDropped(var Files : PoolStringArray, var _ScreenIdx : int) -> void:
	Dialog.set_current_dir(Files[0].get_base_dir())


func OnFileDialogHidden():
	emit_signal("Exit")
	ExitPopup()
