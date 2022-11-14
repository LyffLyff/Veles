extends VBoxContainer


#PRELOADS
const plus_texture : StreamTexture = preload("res://src/Assets/Icons/White/General/add_1_72px.png")
const minus_texture : StreamTexture = preload("res://src/Assets/Icons/White/General/remove_1_72px.png")

#SIGNALS
signal SubInfoPressed

#NODES
onready var SubInfoMain : Button = $SubInfoMain
onready var SubInfoVBox : VBoxContainer = $HBoxContainer/SubInfoVBox
onready var ExpandableSpace : HBoxContainer = $HBoxContainer

#EXPORTS
export var SubInfoTitle : String = ""

#VARIABLES
var SubInfoExpanded : bool = false
var SubInfos : int = -1
var SubInfoTitles : PoolStringArray = []


func _ready():
	SubInfoMain.set_text( SubInfoTitle )


func OnSubInfoMainPressed():
	ToggleSubInfo()


func ToggleSubInfo() -> void:
	SubInfoExpanded =  !SubInfoExpanded
	if !SubInfoExpanded:
		UnloadSubOptions()
		SubInfoMain.icon = plus_texture
	else:
		LoadSubOptions()
		SubInfoMain.icon = minus_texture
	ExpandableSpace.set_visible(SubInfoExpanded)


func LoadSubOptions() -> void:
	for i in SubInfos:
		var x : Button = Button.new()
		x.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		if x.connect("pressed",self,"emit_signal",["SubInfoPressed",i]):
			Global.root.message("CANNOT CONNECT pressed signal to emit_signal SubInfoPressed",  SaveData.MESSAGE_ERROR)
		x.theme = load("res://src/Themes/Buttons/ClearButtons.tres")
		x.rect_min_size.y = 30
		x.set_text(
			SubInfoTitles[i]
		)
		SubInfoVBox.add_child( x )


func UnloadSubOptions() -> void:
	for n in SubInfoVBox.get_children():
		SubInfoVBox.remove_child(n)
		n.queue_free()
