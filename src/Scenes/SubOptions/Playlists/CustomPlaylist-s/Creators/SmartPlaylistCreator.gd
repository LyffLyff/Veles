extends "res://src/Scenes/SubOptions/Playlists/CustomPlaylist-s/Creators/PlaylistCreatorMain.gd"


#NODES
onready var ConditionVBox : VBoxContainer = $Panel/VBoxContainer2/Main/Conditions/HBoxContainer/VBoxContainer
onready var Title : LineEdit = $Panel/VBoxContainer2/Main/Title/InputEdit
onready var Cover : HBoxContainer = $Panel/VBoxContainer2/Main/Cover

#CONDITIONS
const ConditionFunctions : Array = [
	"Genre",
	"Album",
	"IsLongerThan",
	"IsShorterThan",
	"IncludesArtist",
	"SongRatingIs",
	"SongRatingIsHigher",
	"SongRatingIsLower"
]

func _ready():
	$Panel/VBoxContainer2/Main/Conditions.get_v_scrollbar().rect_min_size.x = 5
	var _err = Cover.connect("DialoguePressed",Global.root, "load_general_file_dialogue",[
		Cover.InputEdit,
		FileDialog.MODE_OPEN_FILE,
		FileDialog.ACCESS_FILESYSTEM,
		"set_text",
		[],
		"Image",
		Global.SupportedImgFormats,
		true
	])


func OnSavePressed() -> void:
	var Conditions : Dictionary = {}
	var ConditionValues : PoolStringArray = []
	var TempCondVal : String = ""
	
	#Retrieving Conditions from LineEdits
	for i in ConditionVBox.get_child_count():
		ConditionValues = PoolStringArray()
		for y in ConditionVBox.get_child(i).get_node("VBoxContainer").get_child_count():
			TempCondVal = ConditionVBox.get_child(i).get_node("VBoxContainer").get_child(y).get_node("LineEdit").get_text()
			if TempCondVal != "":
				ConditionValues.push_back( TempCondVal )
		Conditions[ConditionFunctions[i]] = ConditionValues
	emit_signal( "Save",Title.get_text(),Cover.InputEdit.get_text(),"",Conditions )
	OnClosePressed()
