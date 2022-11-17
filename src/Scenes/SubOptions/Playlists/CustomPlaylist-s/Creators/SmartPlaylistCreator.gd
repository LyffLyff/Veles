extends "res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/Creators/PlaylistCreatorMain.gd"


#NODES
onready var ConditionVBox : VBoxContainer = $Panel/VBoxContainer2/Main/Conditions/HBoxContainer/VBoxContainer
onready var Title : LineEdit = $Panel/VBoxContainer2/Main/Title/InputEdit
onready var Cover : HBoxContainer = $Panel/VBoxContainer2/Main/Cover

#CONDITIONS
const ConditionFunctions : Array = [
	"genre",
	"album",
	"is_longer_than",
	"is_shorter_than",
	"includes_artist",
	"song_rating_is",
	"song_rating_is_greater",
	"song_rating_is_lesser"
]

func _ready():
	var _err = Cover.connect("dialogue_pressed",Global.root, "load_general_file_dialogue",[
		Cover.input_edit,
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
	var ConditionValues : PoolStringArray = []
	var TempCondVal : String = ""
	
	#Retrieving Conditions from LineEdits
	for i in ConditionVBox.get_child_count():
		ConditionValues = PoolStringArray()
		for y in ConditionVBox.get_child(i).get_node("VBoxContainer").get_child_count():
			TempCondVal = ConditionVBox.get_child(i).get_node("VBoxContainer").get_child(y).get_node("LineEdit").get_text()
			if TempCondVal != "":
				ConditionValues.push_back( TempCondVal )
		conditions[ConditionFunctions[i]] = ConditionValues
	emit_signal("save",Title.get_text(),Cover.input_edit.get_text(),"",conditions)
	on_close_pressed()
