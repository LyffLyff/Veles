extends "res://src/Scenes/SubOptions/PlaylistGrid/Creators/PlaylistCreatorMain.gd"

onready var conditions_list : ScrollContainer = $Panel/MarginContainer/Main/PlaylistConditionsList
onready var title : LineEdit = $Panel/MarginContainer/Main/Title/InputEdit
onready var cover_hbox : HBoxContainer = $Panel/MarginContainer/Main/Cover

func _ready():
	var _err = footer.connect("save_pressed", self, "_on_Save_pressed")
	_err = cover_hbox.connect("dialogue_pressed", Global.root, "load_general_file_dialogue",[
		cover_hbox.input_edit,
		FileDialog.MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"set_text",
		[],
		UsedFilepaths.PLAYLIST_HEADER,
		Global.supported_img_extensions,
		true,
		"Select Playlist Cover"
	])


func _on_Save_pressed():
	conditions_list.save_conditions(title.get_text() + ".dat")
	self.emit_signal("save", title.get_text(), cover_hbox.input_edit.get_text(), "")
	self.exit_popup()
