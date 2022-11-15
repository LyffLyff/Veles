extends Control


#NODES
onready var OptionTypes : Array = [
	preload("res://src/Scenes/SubOptions/InfoSettings/OptionTypes/GeneralSettings.tscn"),
	preload("res://src/Scenes/SubOptions/InfoSettings/OptionTypes/SongSettings.tscn"),
	preload("res://src/Scenes/SubOptions/InfoSettings/OptionTypes/PlaylistAlbumSettings.tscn"),
	preload("res://src/Scenes/SubOptions/InfoSettings/OptionTypes/DesignSettings.tscn"),
	preload("res://src/Scenes/SubOptions/InfoSettings/OptionTypes/StatisticSettings.tscn")
]
onready var Settings : ScrollContainer = $Select
onready var InfoText : RichTextLabel = $VBoxContainer/Info
onready var InfoTitle : Label = $VBoxContainer/InfoTitle
onready var SettingAnimations : AnimationPlayer = $SettingAnimations


#VARIABLES
#A variable that saves references to all the File Settings,
#so when files are Dropped they can be handled and entered automatically
var CurrentFileEdits : Array = []

var OptionRef : HBoxContainer = null


func _ready():
	LoadOption(0)
	var _err = get_tree().connect("files_dropped", self, "OnFilesDropped")

func LoadOption(var OptionIdx : int) -> void:
	if Settings.get_child_count() > 2:		
		OptionRef.queue_free()
	
	
	OptionRef = OptionTypes[ OptionIdx ].instance()
	Settings.add_child( OptionRef )
	
	
	var OptionVBox : VBoxContainer = OptionRef.get_child(0)
	
	for n in OptionVBox.get_child_count():
		if OptionVBox.get_child(n).is_in_group("Buffer"):
			continue;
		
		if OptionVBox.get_child(n).get_child(2).connect("mouse_entered",self,"OnMouseEntered",[n]):
			Global.root.message("CONNECTING SETTING CONTAINERS TO MOUSE ENTERED",  SaveData.MESSAGE_ERROR )
		if OptionVBox.get_child(n).get_child(2).connect("mouse_exited",self,"OnMouseExited"):
			Global.root.message("CONNECTING SETTING CONTAINERS TO MOUSE EXITED",  SaveData.MESSAGE_ERROR )
	
		#Normal Options
		if OptionVBox.get_child(n).get_child(2) is OptionButton:
			if OptionVBox.get_child(n).get_child(2).has_method("NormalSettingItemSelected"):
				if OptionVBox.get_child(n).get_child(2).connect("item_selected",OptionVBox.get_child(n).get_child(2),"NormalSettingItemSelected"):
					Global.root.message("CONNECTING SETTING CONTAINERS TO PARENTD",  SaveData.MESSAGE_ERROR )
		
		#Design Options
		if OptionVBox.get_child(n).get_child(2) is ColorPickerButton:
			if OptionVBox.get_child(n).get_child(2).connect("pressed",self,"OnColorChangerShown",[n]):
				Global.root.message("COULDN'T CONNECT picker_created SIGNAL TO OnColorChangerShown FUNCTION",  SaveData.MESSAGE_ERROR )
			if OptionVBox.get_child(n).get_child(2).connect("popup_closed",self,"OnColorChangerFreed"):
				Global.root.message("COULDN'T CONNECT popup_closed SIGNAL TO OnColorChangerFreed FUNCTION",  SaveData.MESSAGE_ERROR )
			if OptionVBox.get_child(n).get_child(2).connect("color_changed",self,"OnColorChanged"):
				Global.root.message("COULDN'T CONNECT color_changed SIGNAL TO OnColorChanged FUNCTION",  SaveData.MESSAGE_ERROR )
	
	InitCurrentFileEdits()




func OnMouseEntered(var idx : int) -> void:
	SettingAnimations.play("InfoInOut")
	InfoTitle.text = OptionRef.get_child(0).Infos.keys()[idx]
	InfoText.set_bbcode( OptionRef.get_child(0).Infos.values()[idx] )


func OnMouseExited() -> void:
	SettingAnimations.play_backwards("InfoInOut")


var ColPicker : ColorPicker = null
var DesignSetter : DesignPaths = null
var ChangingStyleBox : StyleBox = null
var StyleBoxProperty : String = ""
var PickerColor = null
var SettingsKey : String = ""


func OnColorChangerShown(var ChildIdx : int) -> void:
	DesignSetter = DesignPaths.new()
	StyleBoxProperty = OptionRef.get_child(0).get_child(ChildIdx).StyleboxColorProperty
	SettingsKey = OptionRef.get_child(0).get_child(ChildIdx).ColorSettingKey
	#Setting the Color in realtime
	if OptionRef.get_child(0).get_child(ChildIdx).ColorChangeRealtime:
		ChangingStyleBox = Global.root.get_node(OptionRef.get_child(0).get_child(ChildIdx).ColorNodePath).get_stylebox(OptionRef.get_child(0).get_child(ChildIdx).StyleboxTitle)


func OnColorChangerFreed() -> void:
	if ChangingStyleBox:
		SettingsData.set_setting(SettingsData.DESIGN_SETTINGS, SettingsKey, ChangingStyleBox.get(StyleBoxProperty) )
	else:
		SettingsData.set_setting(SettingsData.DESIGN_SETTINGS, SettingsKey, PickerColor)
	PickerColor = null
	DesignSetter = null
	ChangingStyleBox = null
	SettingsKey = ""


func OnColorChanged(var clr : Color) -> void:
	if ChangingStyleBox:
		ChangingStyleBox.set(StyleBoxProperty,clr)
	else:
		PickerColor = clr


func OnFilesDropped(var file_paths : PoolStringArray, var _ScreenIdx : int) -> void:
	#A function that finds the Closest Reference of a Node inside of an Array,
	#relative to the Mouse Position
	#the Dropped File will then be entered automatically
	if Global.general_dialogue_visible: return;
	
	if CurrentFileEdits.size() <= 0:
		return;
	
	var ClosestFileEditIdx : int = -1
	var ClosestDistance : float = -1.0
	var MousePos : Vector2 = get_global_mouse_position()
	
	
	for i in CurrentFileEdits.size():
		if MousePos.distance_to( CurrentFileEdits[i].rect_global_position ) < ClosestDistance or ClosestDistance == -1.0:
			ClosestFileEditIdx = i
			ClosestDistance = MousePos.distance_to( CurrentFileEdits[i].rect_global_position )
	
	
	CurrentFileEdits[ ClosestFileEditIdx ].FileEdit.set_text( file_paths[0] )
	CurrentFileEdits[ ClosestFileEditIdx ].FileEdit.emit_signal("text_entered",file_paths[0])


func InitCurrentFileEdits() -> void:
	#Searching all the File Settings in the Current Settings
	CurrentFileEdits.resize(0)
	
	
	for i in OptionRef.get_child(0).get_child_count():
		if !OptionRef.get_child(0).get_child(i).is_in_group("Buffer"):
			if OptionRef.get_child(0).get_child(i).SettingType == "File":
				CurrentFileEdits.push_back( OptionRef.get_child(0).get_child(i).get_child(2) )
