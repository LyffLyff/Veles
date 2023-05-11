extends "res://src/Scenes/General/StdPopupBackground.gd"

const supported_filetypes : Array = ["*.mp3", "*.wav", "*.ogg", "*.flac"]

onready var menu_footer : HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/MenuFooter
onready var destination : HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Destination
onready var source : HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/Source
onready var cover_switcher : Control = $PanelContainer/MarginContainer/VBoxContainer/Header/CoverSwitcher
onready var file : HBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/File
onready var format : OptionButton = $PanelContainer/MarginContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/Format
onready var export_all : CheckBox = $PanelContainer/MarginContainer/VBoxContainer/PanelContainer/MarginContainer/VBoxContainer/HBoxContainer2/ExportAll


func _ready():
	var _err : int = menu_footer.connect("save_pressed", self, "_on_save_pressed")
	_err = menu_footer.connect("close_pressed", self, "exit_popup")
	_err = destination.connect("dialogue_pressed", self, "open_dst_dialogue")
	_err = source.connect("dialogue_pressed", self, "open_src_dialogue")


func init_export_menu(var src_path : String, var cover_idx : int = 0) -> void:
	var covers = ImageLoader.new().get_embedded_covers(src_path)
	if covers[0].size() > 0:
		cover_switcher.set_covers(covers[0])
		source.input_edit.text = src_path
	else:
		Global.message("No Covers to Extract", Enumerations.MESSAGE_NOTICE, true)
		exit_popup()


func open_src_dialogue() -> void:
	Global.root.load_general_file_dialogue(
		destination.input_edit,
		FileDialog.MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"init_export_menu",
		[],
		UsedFilepaths.DESKTOP,
		supported_filetypes,
		true,
		"Select Export Source"
	)


func open_dst_dialogue() -> void:
	Global.root.load_general_file_dialogue(
		destination.input_edit,
		FileDialog.MODE_OPEN_DIR,
		FileDialog.ACCESS_FILESYSTEM,
		"set_text",
		[],
		UsedFilepaths.EXPORT_COVER,
		supported_filetypes,
		true,
		"Select Export Destination"
	)


func get_destination_extension() -> String:
	if format.selected == 0:
		return "." + AllSongs.get_song_coverhash(AllSongs.get_main_idx(source.input_edit.text)).get_extension()
	else:
		return ".png"


func _on_save_pressed() -> void:
	var dst_path : String = destination.input_edit.text + "/" + file.input_edit.text + get_destination_extension()
	
	# check src/dst/filename
	var dir : Directory = Directory.new()
	if !dir.dir_exists(destination.input_edit.text) or destination.input_edit.text == "":
		Global.message("Invalid Directory", Enumerations.MESSAGE_ERROR, true)
		exit_popup()
		return
	if !dir.file_exists(source.input_edit.text):
		Global.message("Source File does not exist", Enumerations.MESSAGE_ERROR, true)
		exit_popup()
		return
	if dir.file_exists(dst_path):
		Global.message("Destination File already exists", Enumerations.MESSAGE_ERROR, true)
		exit_popup()
		return
	
	# export image
	if !export_all.toggle_mode:
		Tags.copy_embedded_covers([source.input_edit.text], [dst_path], 0)
	else:
		# get_basename -> but extension from dst path
		Tagging.new().export_all_embedded_covers(source.input_edit.text, dst_path.get_basename())
	OS.shell_open(dst_path.get_base_dir())
	Global.message("Successfully Exported Cover/s", Enumerations.MESSAGE_SUCCESS, true)
	exit_popup()
