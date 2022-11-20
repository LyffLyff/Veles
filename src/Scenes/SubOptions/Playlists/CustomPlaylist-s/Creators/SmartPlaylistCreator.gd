extends "res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/Creators/PlaylistCreatorMain.gd"

const condition_functions : Array = [
	"genre",
	"album",
	"is_longer_than",
	"is_shorter_than",
	"includes_artist",
	"song_rating_is",
	"song_rating_is_greater",
	"song_rating_is_lesser"
]

onready var condition_vbox : VBoxContainer = $Panel/VBoxContainer2/Main/Conditions/HBoxContainer/VBoxContainer
onready var title : LineEdit = $Panel/VBoxContainer2/Main/Title/InputEdit
onready var cover_hbox : HBoxContainer = $Panel/VBoxContainer2/Main/Cover

func _ready():
	var _err = cover_hbox.connect("dialogue_pressed",Global.root, "load_general_file_dialogue",[
		cover_hbox.input_edit,
		FileDialog.MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"set_text",
		[],
		"Image",
		Global.supported_img_extensions,
		true
	])


func on_save_pressed() -> void:
	var conditions : Dictionary = {}
	var condition_values : PoolStringArray = []
	var temp_condition_value : String = ""
	
	# retrieving Conditions from LineEdits
	for i in condition_vbox.get_child_count():
		condition_values = PoolStringArray()
		for y in condition_vbox.get_child(i).get_node("VBoxContainer").get_child_count():
			temp_condition_value = condition_vbox.get_child(i).get_node("VBoxContainer").get_child(y).get_node("LineEdit").get_text()
			if temp_condition_value != "":
				condition_values.push_back( temp_condition_value )
		conditions[condition_functions[i]] = condition_values
	emit_signal("save", title.get_text(), cover_hbox.input_edit.get_text(), "", conditions)
	on_close_pressed()
