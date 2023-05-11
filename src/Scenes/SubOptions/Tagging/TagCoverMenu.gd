extends "res://src/Scenes/General/MovablePopupMenu.gd"

onready var add_cover : Button = $MarginContainer/VBoxContainer/Add
onready var remove_cover : Button = $MarginContainer/VBoxContainer/Remove
onready var remove_all_covers : Button = $MarginContainer/VBoxContainer/RemoveAll
onready var extract_cover : Button = $MarginContainer/VBoxContainer/Extract

func _ready():
	# unloading
	var _err : int = add_cover.connect("pressed", self, "unload_popup")
	_err = remove_cover.connect("pressed", self, "unload_popup")
	_err = remove_all_covers.connect("pressed", self, "unload_popup")
	_err = extract_cover.connect("pressed", self, "unload_popup")


func init_options(var filepath : String, var cover_idx : int) -> void:
	# connecting  the options to the actual function that does the stuff written on them
	
	var _err : int = extract_cover.connect("pressed", Global, "load_export_menu", [filepath, cover_idx])
	
	_err = remove_cover.connect("pressed", Tags, "remove_cover", [filepath, cover_idx])
	
	_err = remove_all_covers.connect("pressed", Tags, "remove_all_covers", [filepath])
	
	_err = add_cover.connect("pressed", Global.root, "load_general_file_dialogue", [
		Tags,
		FileDialog.MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"add_cover",
		[filepath, ImageLoader.identify_image_mime_type(filepath)],
		UsedFilepaths.TAG_COVER,
		Global.supported_img_extensions,
		true,
		"Select Image to Add"
	])
